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

output "instance_ip_addr" {
  value = aws_instance.example.private_ip
}

/*
output "Kop EC2 Public IP" {
  value = "${aws_instance.Kops.public_ip}"
}
*/