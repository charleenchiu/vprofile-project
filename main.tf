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
output "Kop EC2 Public IP" {
  value = "${aws_instance.Kops.public_ip}"
}
//aws_instance.Kops.public_ip