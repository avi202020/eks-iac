# creates database

# Declare the data source
data "aws_availability_zones" "available" {}

# availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
# availability_zones = ["${slice(data.aws_availability_zones.available.names, 0, 2)}"]

resource "aws_rds_cluster" "brightloom_db_cluster" {
  cluster_identifier      = "${var.cluster_name}"
  engine                  = "${var.aurora_db_engine}"
  availability_zones      = ["us-west-2a", "us-west-2b"]
  database_name           = "${var.aurora_db_name}"
  backup_retention_period = "${var.aurora_db_backup_retention_period}"
  preferred_backup_window = "${var.aurora_db_preferred_backup_window}"
  preferred_maintenance_window = "${var.aurora_db_preferred_maintenance_window}"
  vpc_security_group_ids = [ "${aws_security_group.rds.id}" ]
  db_subnet_group_name   = "${aws_db_subnet_group.rds_subnet_group.name}"
  master_username        = "edgarroot"
  master_password        = "edgar$edgar"
  skip_final_snapshot  = false
  final_snapshot_identifier = "${var.cluster_name}-cluster-backup"
}

resource "aws_rds_cluster_instance" "rds_instance" {
  count                = 2
  identifier           = "instance-0${count.index + 1}"
  cluster_identifier   = "${aws_rds_cluster.brightloom_db_cluster.id}"
  instance_class       = "db.r4.large"
  db_subnet_group_name = "${aws_db_subnet_group.rds_subnet_group.name}"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rdsmain-private"
  description = "Private subnets for RDS instance"
  subnet_ids  = "${var.rds_subnet_ids}"

  tags = {
    Name = "${var.aurora_db_name}"
  }
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow database traffic to rds"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "eks_to_rds" {
  type              = "ingress"
  from_port         = "${var.aurora_db_port}"
  to_port           = "${var.aurora_db_port}"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.rds.id}"
  cidr_blocks       = "${var.app_cidr_block}"
}