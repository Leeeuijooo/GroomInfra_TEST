resource "aws_instance" "ubuntu_bastion" {

  ami = "ami-0c9c942bd7bf113a2"
  availability_zone = var.azs[0]
  instance_type = "t2.micro"
  key_name = "Groom"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("../Groom.pem")
    host = self.public_ip
  }

  provisioner "file" {
    source      = "./hello.txt"
    destination = "/home/ubuntu/hello.txt"
  }


  provisioner "remote-exec" {
    inline = [
      "sudo cat hello.txt"
    ]
  }
  tags = {
      Name = "ubuntu_bastion"
  }
}