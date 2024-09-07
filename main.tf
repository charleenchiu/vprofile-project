provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "Kops" {
    ami = "ami-0e86e20dae9224db8"
    instance_type = "t2.micro"
    tags = {
        Name = "Kops"
    }
}

resource "tls_private_key" "ec2_private_key" {
    algorithm = "RSA"
    rsa_bits  = 4096
    provisioner "local-exec" {
        command = "sudo echo '${tls_private_key.ec2_private_key.private_key_pem}' > ~/test.pem"
    }
}

resource "null_resource" "key-perm" {
    depends_on = [
        tls_private_key.ec2_private_key,
    ]
    provisioner "local-exec" {
        command = "sudo chmod 400 ~/test.pem"
    }
}

// Configuring the external volume
resource "null_resource" "setupVol" {
    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user --private-key ~/test.pem -i '${aws_instance.Kops.public_ip},' master.yml"
    }
}

/*
output "instance_ip_addr" {
  value = aws_instance.Kops.public_ip
}
*/
output "Kop_EC2_Public_IP" {
  value = "${aws_instance.Kops.public_ip}"
}

