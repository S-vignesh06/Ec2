# -------------------------
# Latest Amazon Linux 2023
# -------------------------

data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# -------------------------
# EC2 Instance
# -------------------------

resource "aws_instance" "app" {
  ami = data.aws_ssm_parameter.amazon_linux.value

  instance_type = var.instance_type

  subnet_id = aws_subnet.private[0].id

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  user_data = <<-EOF
              #!/bin/bash

              dnf update -y

              dnf install -y docker

              systemctl enable docker
              systemctl start docker

              docker pull golang:1.24-alpine

              docker run -d \
                --name go-api \
                -p ${var.app_port}:8080 \
                golang:1.24-alpine \
                sh -c "while true; do echo 'Go API placeholder running'; sleep 30; done"
              EOF

  tags = {
    Name = "${var.environment}-go-api"
  }
}
