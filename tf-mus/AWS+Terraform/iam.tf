# IAM

### EC2 role

resource "aws_iam_role" "service_role_ec2" {
  name = "${var.project_name}-service-role-ec2"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

### EC2 role policy

resource "aws_iam_role_policy" "service_role_ec2_policy" {
  name   = "${var.project_name}-service-role-ec2-policy"
  role   = "${aws_iam_role.service_role_ec2.name}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:AssignPrivateIpAddresses",
        "ec2:AssociateAddress",
        "ec2:DisassociateAddress",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets",
        "s3:Get*",
        "s3:List*",
        "s3:Put*",
        "s3:DeleteObject",
        "ssm:GetParameters",
        "ssm:DescribeParameters",
        "ec2:DescribeSecurityGroups",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


### EC2 instance profile

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-ec2-instance-profile"
  role = "${aws_iam_role.service_role_ec2.name}"
}
