data "aws_availability_zones" "available" {}

resource "aws_subnet" "gateway" {
  count = "${var.subnet_count}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.1${count.index}.0/24"
  vpc_id            = "${aws_vpc.main_vpc.id}"
  tags = "${
    map(
     "Name", "${var.cluster_name}_gateway"
    )
  }"
}

# kubernetes will run on the application subnet
resource "aws_subnet" "application" {
  count = "${var.subnet_count}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.2${count.index}.0/24"
  vpc_id            = "${aws_vpc.main_vpc.id}"
  tags = "${
    map(
     "Name", "${var.cluster_name}_application",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

# RDS / data will run in database.
resource "aws_subnet" "database" {
  count = "${var.subnet_count}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.3${count.index}.0/24"
  vpc_id            = "${aws_vpc.main_vpc.id}"
  
  tags = "${
    map(
     "Name", "${var.cluster_name}_database"
    )
  }"
}