#Sets up an Apache web server (with our own index.html) on an EC2 instance
# using 64bit Amazon Linux on a T2 micro EC2 instance.
#Sets up the supporting security groups and VPC as well

#Use AWS and region specified
#Terraform will expect the AWS IAM account access and secret key to be
#declared already as environmental variables (see README.md)
provider "aws" {
  region = "${var.aws_region}"
}

# Create a VPC to launch our instances into
#resource "aws_vpc" "default" {
#  cidr_block = "10.0.0.0/16"
#}

# Create an internet gateway to give our subnet access to the outside world
#resource "aws_internet_gateway" "default" {
#  vpc_id = "${aws_vpc.default.id}"
#}

# Grant the VPC internet access on its main route table
#resource "aws_route" "internet_access" {
#  route_table_id         = "${aws_vpc.default.main_route_table_id}"
#  destination_cidr_block = "0.0.0.0/0"
#  gateway_id             = "${aws_internet_gateway.default.id}"
#}

# Create a subnet to launch our instances into
#resource "aws_subnet" "default" {
#  vpc_id                  = "${aws_vpc.default.id}"
#  cidr_block              = "10.0.1.0/24"
#  map_public_ip_on_launch = true
#}


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
resource "aws_key_pair" "auth" {
  key_name = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}


#Create EC2 resource for our linux web server
resource "aws_instance" "web_server" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    type         = "ssh"
    user         = "ec2-user"
    private_key = "${file("~/.ssh/terraform")}"
    host         = "${self.public_ip}"
    # The connection will use the local SSH agent for authentication.
  }

  # Lookup the correct AMI based on the region
  # we specified
  ami                    = "${lookup(var.aws_amis, var.aws_region)}"

  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.web_server.id}"]
  key_name               = "${aws_key_pair.auth.id}"


  #install latest apache 2 on our new server
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum -y install httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]
  }

  #we copy our custom local html file to web directory on server
  provisioner "file" {
    source = "index.html"
    destination = "/tmp/index.html"
  }

  #we update the html file perms so it can be hosted properly
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo chmod 644 /var/www/html/index.html"
    ]
  }
}

#Output the IP of our server so we can make sure it worked...
output "public_ip" {
  value = "${aws_instance.web_server.public_ip}"
}
