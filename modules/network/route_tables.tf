resource "aws_route_table" "application" {
  count = "${length(var.application_subnets)}"
  vpc_id = "${aws_vpc.main_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.the_nat_gateway.*.id[count.index]}"
  }
  tags = {
    Name = "${var.cluster_name}_application"
  }
}

resource "aws_route_table" "database" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags = {
    Name = "${var.cluster_name}-database"
  }
}
resource "aws_route_table" "gateway" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }
  tags = {
    Name = "${var.cluster_name}-gateway"
  }
}

resource "aws_route_table_association" "application" {
  count = "${length(var.application_subnets)}"

  subnet_id      = "${aws_subnet.application.*.id[count.index]}"
  route_table_id = "${aws_route_table.application.*.id[count.index]}"
}

resource "aws_route_table_association" "database" {
  count = "${length(var.database_subnets)}"

  subnet_id      = "${aws_subnet.database.*.id[count.index]}"
  route_table_id = "${aws_route_table.database.id}"
}

resource "aws_route_table_association" "gateway" {
  count = "${length(var.gateway_subnets)}"

  subnet_id      = "${aws_subnet.gateway.*.id[count.index]}"
  route_table_id = "${aws_route_table.gateway.id}"
}