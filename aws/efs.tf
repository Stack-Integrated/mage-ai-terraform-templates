# efs.tf | Elastic File System Configuration

resource "aws_efs_file_system" "file_system" {
  encrypted         = true
  performance_mode  = "generalPurpose"
  throughput_mode   = "elastic"

  tags = {
    Name        = "${var.app_name}-efs"
    Environment = var.app_environment
  }
}

resource "aws_efs_mount_target" "mount_target" {
  for_each = data.aws_subnet.public
  file_system_id = aws_efs_file_system.file_system.id
  subnet_id      = each.value.id
  security_groups = [ aws_security_group.mount_target_security_group.id ]
}


resource "aws_security_group" "mount_target_security_group" {
  vpc_id = data.aws_vpc.aws-vpc.id

  ingress {
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    security_groups  = [aws_security_group.service_security_group.id]
  }

  tags = {
    Name        = "${var.app_name}-efs-sg"
    Environment = var.app_environment
  }
}
