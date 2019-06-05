variable "ami" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "vpc_security_group_id" {}
variable "Identity" {}
variable "num_webs" {
  default = 3
}
resource "aws_key_pair" "training" {
	key_name = "${var.Identity}-key"
	public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "sg_jihin" {	
	name = "sg_80"
	vpc_id = "vpc-00e3bf973de77d348"
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
	}

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["212.250.145.34/32"]
  }

	egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
	}
}

resource "aws_instance" "web" {
  availability_zone = "eu-west-1b"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.vpc_security_group_id}", "${aws_security_group.sg_jihin.id}"]
  key_name = "${aws_key_pair.training.key_name}"
  count = "${var.num_webs}"
  tags = {
    "Identity" = "${var.Identity}"
    "Name"     = "Jihin ${count.index+1}/${var.num_webs}"
    "Training" = "Academy"
  }

  connection {
    user = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    source = "assets"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh /tmp/assets/setup-web.sh"
    ]
  }
}


resource "aws_ebs_volume" "extra10gb" {
	availability_zone = "eu-west-1b"
	size = 10
	count = 6
}

resource "aws_volume_attachment" "ebs_att0_1" {
  device_name = "/dev/sdh"
  volume_id   = "${element(aws_ebs_volume.extra10gb.*.id, count.index+3)}"
  instance_id = "${element(aws_instance.web.*.id, count.index)}"
}

resource "aws_volume_attachment" "ebs_att0_2" {
  device_name = "/dev/sde"
  volume_id   = "${element(aws_ebs_volume.extra10gb.*.id, count.index)}"
  instance_id = "${element(aws_instance.web.*.id, count.index)}"
}


output "public_ip" {
  value = "${aws_instance.web.*.public_ip}"
}
