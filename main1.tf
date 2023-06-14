# Configure the AWS provider
provider "aws" {
  region = "ap-south-1"  # Change to your desired region
}

# Create a key pair for SSH access
resource "aws_key_pair" "tarun_test" {
  key_name   = "tarun_test"
  public_key = file("~/.ssh/my-key-pair.pub")  # Change to your public key file path
}

# Create a security group
resource "aws_security_group" "tarun_test_sg" {
  name        = "tarun_test_sg"
  description = "Allow access to all"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance
resource "aws_instance" "tarun_example_instance" {
  ami           = "ami-0c94855ba95c71c99"  # CentOS 7 AMI ID, change for different CentOS version
  instance_type = "t2.micro"
  key_name      = "tarun_test"
  security_group_ids = ["sg-04cb6448ed9f9bf8b"]

  tags = {
    Name = "tarun_example-instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",  # Update the instance
      "sudo yum install -y httpd",  # Install Apache web server
      "sudo systemctl start httpd",  # Start Apache
      "sudo systemctl enable httpd"  # Enable Apache to start on boot
    ]
  }

  connection {
    type        = "ssh"
    user        = "centos"
    private_key = file("~/.ssh/my-key-pair")  # Change to your private key file path
    host        = self.public_dns
  }

  lifecycle {
    ignore_changes = [tags]  # Ignore changes to instance tags
  }
}

