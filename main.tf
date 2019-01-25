variable "az1" {}
variable "ami_id" {}
variable "instance_type" {}
variable "ssh_key" {}
variable "ssh_key_name" {}
variable "vpc" {}
variable "subnet" {}
variable "region" {}

provider "aws" {
  region = "${var.region}"
}

resource "aws_instance" "test" {
  ami                         = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  availability_zone           = "${var.az1}"
  key_name                    = "${ var.ssh_key_name }"
  security_groups             = ["${aws_security_group.test.id}"]
  associate_public_ip_address = true
  subnet_id                   = "${var.subnet}"

  timeouts {
    create = "10m"
    update = "10m"
  }

  provisioner "local-exec" {
    command = "ping -c 3 8.8.8.8"
  }

  provisioner "local-exec" {
    command = "ping -c 3 ${aws_instance.test.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo testing",
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${var.ssh_key}"
    }
  }
}

resource "aws_security_group" "test" {
  name   = "Test"
  vpc_id = "${var.vpc}"
}

resource "aws_security_group_rule" "mgmt_ping" {
  type      = "ingress"
  from_port = -1
  to_port   = -1
  protocol  = "all"

  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
  description      = "Ping from anywhere"

  security_group_id = "${aws_security_group.test.id}"
}
