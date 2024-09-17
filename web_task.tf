// Configuring the provider information
provider "aws" {
    region = "us-east-1"
}

// 獲取當前工作目錄並存儲在一個文件中
resource "null_resource" "get_pwd" {
  //pwd 路徑會是：/var/lib/jenkins/workspace/vprofile-project/terraform
  provisioner "local-exec" {
    command = "pwd > ${path.module}/current_dir.txt"
  }
}

// 讀取當前工作目錄
data "local_file" "current_dir" {
  depends_on = [null_resource.get_pwd]
  filename   = "${path.module}/current_dir.txt"
}

// Creating the EC2 private key
variable "key_name" {
  default = "charleen_Terraform_test_nfs"
}

// Generate the private key
resource "tls_private_key" "ec2_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Write the private key to a file
// 不在上段產生private key時，用local-exec寫入檔案，以免造成循環
resource "null_resource" "write_private_key" {
  provisioner "local-exec" {
    command = <<EOT
      echo '${tls_private_key.ec2_private_key.private_key_pem}' > ${path.module}/${var.key_name}.pem
      chmod 600 ${path.module}/${var.key_name}.pem
      EOT
  }
}


// 產生公鑰
// 不用depends_on以免造成循環
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_private_key.public_key_openssh
}

// Jenkins public key
// 不用depends_on以免造成循環
locals {
  jenkins_public_key = aws_key_pair.ec2_key_pair.public_key
}

// Creating aws security resource
resource "aws_security_group" "allow_tcp_nfs" {
  name        = "allow_tcp_nfs"
  description = "Allow TCP and NFS inbound traffic"
  vpc_id      = "vpc-02fb581658eb58d45"

  ingress {
    description = "TCP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "NFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tcp_nfs"
  }
}

// Launching new EC2 instance
resource "aws_instance" "myWebServer" {
  ami = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_tcp_nfs.id]
  subnet_id = "subnet-0153eaf2e8d59b0a0"
  associate_public_ip_address = true 
  tags = {
      Name = "myWebServer"
  }

  //file provisioner：將設置好權限的私鑰文件從本地複製到遠端機器。
  //file provisioner 是 Terraform 中的一種 provisioner，用來將本地文件複製到遠端機器上。使用 file provisioner 可以避免使用 sudo 命令來設置文件權限，因為你可以在本地設置好文件權限後再將文件複製到遠端機器。
  provisioner "file" {
    source      = "${path.module}/${var.key_name}.pem"
    destination = "/home/ubuntu/.ssh/${var.key_name}.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.ec2_private_key.private_key_pem
      host        = self.public_ip
    }
  }
 
  //remote-exec provisioner：在遠端機器上設置私鑰文件的權限並添加 jenkins 用戶的公鑰到 authorized_keys 文件中。
  provisioner "remote-exec" {
    inline = [
      "echo '${local.jenkins_public_key}' >> /home/ubuntu/.ssh/authorized_keys"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.ec2_private_key.private_key_pem
      host        = self.public_ip
    }
  }
}

// Creating EFS
resource "aws_efs_file_system" "myWebEFS" {
  creation_token = "CharleenWebFile"

  tags = {
    Name = "CharleenWebFileSystem"
  }
}

// Mounting EFS
resource "aws_efs_mount_target" "mountefs" {
  file_system_id  = aws_efs_file_system.myWebEFS.id
  subnet_id       = "subnet-0153eaf2e8d59b0a0"
  security_groups = [aws_security_group.allow_tcp_nfs.id]
}

// Configuring the external volume
resource "null_resource" "setupVol" {
  depends_on = [aws_efs_mount_target.mountefs]

  //從本機連到新建的EC2，執行Ansible playbook，並將建好的EFS ID傳給那台EC2
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ${path.module}/${var.key_name}.pem -i '${aws_instance.myWebServer.public_ip},' master_ubuntu.yml -e 'file_sys_id=${aws_efs_file_system.myWebEFS.id}'"
  }
}

// Creating private S3 Bucket
resource "aws_s3_bucket" "tera_bucket" {
  bucket = "charleen-terra-bucket-test"

  tags = {
    Name = "terra_bucket"
  }
}


//S3 ACL ↓
// S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "tera_bucket_ownership" {
  bucket = aws_s3_bucket.tera_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

// Block Public Access
resource "aws_s3_bucket_public_access_block" "tera_bucket_acblock" {
  bucket = aws_s3_bucket.tera_bucket.id

  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "tera_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.tera_bucket_ownership,
    aws_s3_bucket_public_access_block.tera_bucket_acblock,
  ]

  bucket = aws_s3_bucket.tera_bucket.id
  acl    = "private"
}
// S3 ACL ↑

// Local variables
locals {
  s3_origin_id = "myS3Origin"
}

// Creating Origin Access Identity for CloudFront
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Tera Access Identity"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.tera_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Terra Access Identity"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  // Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  // Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["CA"]
    }
  }

  tags = {
    Environment = "production"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  retain_on_delete = true
}

// AWS Bucket Policy for CloudFront
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.tera_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tera_bucket.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3BucketPolicy" {
  bucket = aws_s3_bucket.tera_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_object" "bucketObject" {
  for_each = fileset("/var/www/html/", "*")
  bucket = aws_s3_bucket.tera_bucket.id

  key    = each.value
  source = each.value
  etag   = filemd5("${each.value}")
}

output "myWebServer_public_ip" {
  value = aws_instance.myWebServer.public_ip
}