resource "aws_instance" "this" {
  count = var.instance_count

  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_groups
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  user_data              = var.user_data

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      volume_size = root_block_device.value.volume_size
      volume_type = root_block_device.value.volume_type
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Name"]}-${count.index + 1}"
    }
  )
}