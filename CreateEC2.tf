// Configuring the provider information
provider "aws" {
    region = "us-east-1"
}

data "aws_iam_role" "existing_role" {
  name = "Jenkins_Role"
}

resource "aws_iam_role" "new_role" {
  count = length(data.aws_iam_role.existing_role.arn) == 0 ? 1 : 0

  name = "Jenkins_Role"
  description = "Jenkins Access ECR and Deploy Docker Image to ECS"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

locals {
  create_new_role = length(data.aws_iam_role.existing_role.arn) == 0 ? 1 : 0
  new_role_name   = aws_iam_role.new_role[count.index].name
}

resource "aws_iam_role_policy_attachment" "attach_policy_ecr" {
  count      = local.create_new_role
  role       = local.new_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "attach_policy_ecs" {
  count      = local.create_new_role
  role       = local.new_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSFullAccess"
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  count      = local.create_new_role
  name = "JenkinsInstanceProfile"
  role = local.new_role_name
}

//=============================================================

// Launching new EC2 instance
resource "aws_instance" "JenkinsServer" {
  //ami = "ami-03e7e7eac160da024"  //JenkinsServerImg13_EBS_add_2GiB with t2.small
  //ami = "ami-0e0b480b46e7c831c"  //JenkinsServerImg14_SonarQG_Webhook with t2.small
  ami = "ami-01154da512f2d3d4b"  //JenkinsServerImg15_Sonar_Docker_ECR with t2.small
  instance_type = "t2.small"
  key_name = "jenkins-key"
  vpc_security_group_ids = ["sg-0f8aa01fc499922a6"] //JenkinsSG
  subnet_id = "subnet-0153eaf2e8d59b0a0" //charleensideproject-web-1a
  private_ip = "172.16.10.31" //固定使用指定的private ip
  associate_public_ip_address = true //啟用公共IP
  iam_instance_profile = aws_iam_instance_profile.jenkins_instance_profile
  tags = {
      Name = "JenkinsServer"
  }
}


// Launching new EC2 instance
resource "aws_instance" "SonarServer" {
  //ami = "ami-0372de3628f01e650" //SonarServerImg2_jenkins_token
  //ami = "ami-04c873a0c4329d144"  //SonarServerImg3_FirstAnalysisReportTriggerByJenkins
  ami = "ami-0d0ff2521dcc4bb94"  //SonarServerImg4_QG_webhook_JKImg14 with t2.medium
  instance_type = "t2.medium"
  key_name = "sonar-key"
  vpc_security_group_ids = ["sg-045c57d2935ed51b9"] //SonarSG
  subnet_id = "subnet-0153eaf2e8d59b0a0" //charleensideproject-web-1a
  private_ip = "172.16.10.32"  //固定使用指定的private ip，好在jenkins的system設定上可以填固定的URL：http://172.16.10.133:9000
  associate_public_ip_address = true //啟用公共IP
  tags = {
      Name = "SonarServer"
  }
}

//===========================================================

//添加 ECS Cluster 的配置
resource "aws_ecs_cluster" "vprofile" {
  name = "vprofile"
}

//建立 ECS Task Definition：添加 ECS 任務定義，使用 ECR 映像
resource "aws_ecs_task_definition" "vprofile_task" {
  family                   = "vprofile-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "vprofileappimg"
      image     = "167804136284.dkr.ecr.us-east-1.amazonaws.com/vprofileappimg:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

//建立 ECS Service：添加 ECS 服務的配置
resource "aws_ecs_service" "vprofile_service" {
  name            = "vprofileappsvc"
  cluster         = aws_ecs_cluster.vprofile.id
  task_definition = aws_ecs_task_definition.vprofile_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["subnet-0153eaf2e8d59b0a0"] //charleensideproject-web-1a
    security_groups  = ["sg-0e77561a9a7811a44"]     //charleensidepojrect-web-sg
    assign_public_ip = true
  }
}


//===========================================================

output "JenkinsServerURL_PrivateIP" {
  value = "http://${aws_instance.JenkinsServer.private_ip}:8080"
}
output "JenkinsServerURL_PublicIP" {
  value = "http://${aws_instance.JenkinsServer.public_ip}:8080"
}
output "JenkinsServer_SSH" {
  value = "ssh -i ${aws_instance.JenkinsServer.key_name}.pem ubuntu@${aws_instance.JenkinsServer.public_ip}"
}

output "SonarServerURL_PrivateIP" {
  value = "http://${aws_instance.SonarServer.private_ip}:9000"
}
output "SonarServerURL_PublicIP" {
  value = "http://${aws_instance.SonarServer.public_ip}:9000"
}
output "SonarServer_SSH" {
  value = "ssh -i ${aws_instance.SonarServer.key_name}.pem ubuntu@${aws_instance.SonarServer.public_ip}"
}

output "ECS_Service_Public_IP" {
  value = aws_ecs_service.vprofile_service.network_configuration[0].assign_public_ip
}
