locals {
  subnet_active_az   = "ca-central-1a"
  subnet_inactive_az = "ca-central-1b"
  name               = "${var.name}-${var.environment}"
}
