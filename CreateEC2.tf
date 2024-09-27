// Configuring the provider information
provider "aws" {
    region = "us-east-1"
}

// Launching new EC2 instance
resource "aws_instance" "JenkinsServer" {
  //ami = "ami-040caf1245aa2f480" //JenkinsServerImg11_ConfigSonnerScannerNSonarServer
  //ami = "ami-0d53f16220577f919"  //JenkinsServerImg12_GenFirstSonarAnalysisReport
  //ami = "ami-03e7e7eac160da024"  //JenkinsServerImg13_EBS_add_2GiB with t2.small
  ami = "ami-0e0b480b46e7c831c"  //JenkinsServerImg14_SonarQG_Webhook with t2.small
  instance_type = "t2.small"
  key_name = "jenkins-key"
  vpc_security_group_ids = ["sg-0f8aa01fc499922a6"] //JenkinsSG
  subnet_id = "subnet-0153eaf2e8d59b0a0" //charleensideproject-web-1a
  private_ip = "172.16.10.31" //固定使用指定的private ip
  associate_public_ip_address = true //啟用公共IP
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
