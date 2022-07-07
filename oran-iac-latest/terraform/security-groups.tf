resource "aws_security_group" "smo_nrtric_sg" {
  name        = "SMO_NearRTRic_SG"
  description = "SMO & NearRTRic inbound traffic"
  vpc_id      = aws_vpc.o_ran_vpc_1.id

  ingress {
    description = "SMO Policy Mng service"
    from_port   = 30091
    to_port     = 30093
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.o_ran_vpc_1.cidr_block]
  }

  ingress {
    description = "RestAPI endpoint"
    from_port   = 32080
    to_port     = 32080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.o_ran_vpc_1.cidr_block]
  }

  ingress {
    description = "RestAPI endpoint"
    from_port   = 32088
    to_port     = 32088
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.o_ran_vpc_1.cidr_block]
  }

  ingress {
    description = "All SSH from outside"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_smo_nrtric_sg"
  }
}
