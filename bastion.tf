resource "aws_instance" "ubuntu_bastion" {
  
  
  ami = "ami-0c9c942bd7bf113a2"
  availability_zone = var.azs[0]
  instance_type = "t2.micro"
  key_name = "grooom"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("../grooom.pem")
    host = self.public_ip
  }

  provisioner "file" {
    source      = "./deploy.sh"
    destination = "/home/ubuntu/deploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh deploy.sh"
    ]
  }


  provisioner "file" {
    source      = "./lb_controller.sh"
    destination = "/home/ubuntu/lb_controller.sh"
  }

  provisioner "file" {
    source      = "./lb_controller.yaml"
    destination = "/home/ubuntu/lb_controller.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh lb_controller.sh"
    ]
  }

  provisioner "file" {
    source      = "./ebs_csi_driver.sh"
    destination = "/home/ubuntu/ebs_csi_driver.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh ebs_csi_driver.sh"
    ]
  }
  provisioner "file" {
    source      = "./vpc_cni.sh"
    destination = "/home/ubuntu/vpc_cni.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh vpc_cni.sh"
    ]
  }
  tags = {
      Name = "ubuntu_bastion"
  }
  depends_on = [module.eks]
}
