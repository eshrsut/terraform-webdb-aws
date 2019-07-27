#Sets up an Apache web server (with our own index.html) on an EC2 instance
# using 64bit Amazon Linux on a T2 micro EC2 instance.
#Sets up the supporting security groups and VPC as well

#access key and private key are specified as environment vars
provider "aws" {
  region = "us-east-1"
}

# Use the latest Amazon Linux 2 64bit AMI
data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}


# Create security group with web (80) and ssh (22) access in and all traffic out
resource "aws_security_group" "web_server" {
  name = "web_server"

  # SSH
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Deploy your ssh public key for instance access
resource "aws_key_pair" "deployer" {
  key_name = "web_server"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

#Create EC2 resource for our linux web server
resource "aws_instance" "web_server" {
  ami                    = "${data.aws_ami.amazon-linux-2.id}"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.web_server.id}"]
  key_name               = "web_server"
  tags {
    Name = "web-server"
  }

  #setup the machine with private key
  connection {
    user         = "ec2_user"
    private_key  = "${file("~/.ssh/id_rsa")}"
  }

  #install latest apache 2 on our new server
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install apache2 -y",
      "sudo systemctl enable apache2",
      "sudo systemctl start apache2",
      "sudo chmod 777 /var/www/html/index.html"
    ]
  }

  #we copy our custom local html file to web directory on server
  provisioner "file" {
    source = "index.html"
    destination = "/var/www/html/index.html"
  }

  #we update the html file perms so it can be hosted properly
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 644 /var/www/html/index.html"
    ]
  }
}

#Output the IP of our server so we can make sure it worked...
output "public_ip" {
  value = "Your new webserver is at IP ${aws_instance.web_server.public_ip}"
}
