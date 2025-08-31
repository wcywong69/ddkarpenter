terraform {
  backend "s3" {
    bucket = "wong-eks-bucket"
    key    = "eks-terraform-workernodes.tfstate"
    region = "ap-southeast-1"
  }
}

# Get AWS account ID for IAM role
data "aws_caller_identity" "current" {}

# Security group for Karpenter nodes
resource "aws_security_group" "karpenter_nodes" {
  name_prefix = "karpenter-nodes-"
  vpc_id      = aws_vpc.wong-eks-vpc.id

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "karpenter-nodes"
    "karpenter.sh/discovery" = "k8squickstart-cluster"
  }
}

# VPC
resource "aws_vpc" "wong-eks-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "wong-eks-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.wong-eks-vpc.id
  tags = {
    Name = "wong-eks-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.wong-eks-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "wong-eks-public-1a"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.wong-eks-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "wong-eks-public-1b"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.wong-eks-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-southeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "wong-eks-public-1c"
  }
}

# Private Subnets
resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.wong-eks-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "wong-eks-private-1a"
    "karpenter.sh/discovery" = "k8squickstart-cluster"
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.wong-eks-vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-southeast-1b"
  tags = {
    Name = "wong-eks-private-1b"
    "karpenter.sh/discovery" = "k8squickstart-cluster"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id            = aws_vpc.wong-eks-vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "ap-southeast-1c"
  tags = {
    Name = "wong-eks-private-1c"
    "karpenter.sh/discovery" = "k8squickstart-cluster"
  }
}

# NAT Gateways
resource "aws_eip" "nat_1a" {
  domain = "vpc"
  tags = {
    Name = "wong-eks-nat-1a"
  }
}

resource "aws_eip" "nat_1b" {
  domain = "vpc"
  tags = {
    Name = "wong-eks-nat-1b"
  }
}

resource "aws_eip" "nat_1c" {
  domain = "vpc"
  tags = {
    Name = "wong-eks-nat-1c"
  }
}

resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_1a.id
  subnet_id     = aws_subnet.public_1a.id
  tags = {
    Name = "wong-eks-nat-1a"
  }
}

resource "aws_nat_gateway" "nat_1b" {
  allocation_id = aws_eip.nat_1b.id
  subnet_id     = aws_subnet.public_1b.id
  tags = {
    Name = "wong-eks-nat-1b"
  }
}

resource "aws_nat_gateway" "nat_1c" {
  allocation_id = aws_eip.nat_1c.id
  subnet_id     = aws_subnet.public_1c.id
  tags = {
    Name = "wong-eks-nat-1c"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.wong-eks-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "wong-eks-public-rt"
  }
}

resource "aws_route_table" "private_1a" {
  vpc_id = aws_vpc.wong-eks-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1a.id
  }
  tags = {
    Name = "wong-eks-private-rt-1a"
  }
}

resource "aws_route_table" "private_1b" {
  vpc_id = aws_vpc.wong-eks-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1b.id
  }
  tags = {
    Name = "wong-eks-private-rt-1b"
  }
}

resource "aws_route_table" "private_1c" {
  vpc_id = aws_vpc.wong-eks-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1c.id
  }
  tags = {
    Name = "wong-eks-private-rt-1c"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_1a.id
}

resource "aws_route_table_association" "private_1b" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private_1b.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private_1c.id
}

# IAM Role for EKS to have access to the appropriate resources
resource "aws_iam_role" "eks-iam-role" {
  name = "k8squickstart-eks-iam-role"

  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

## Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-iam-role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-iam-role.name
}

## Create the EKS cluster
resource "aws_eks_cluster" "k8squickstart-eks" {
  name = "k8squickstart-cluster"
  role_arn = aws_iam_role.eks-iam-role.arn

  enabled_cluster_log_types = ["api", "audit", "scheduler", "controllerManager"]
  version = var.k8sVersion
  vpc_config {
    subnet_ids = [
      aws_subnet.private_1a.id,
      aws_subnet.private_1b.id,
      aws_subnet.private_1c.id,
      aws_subnet.public_1a.id,
      aws_subnet.public_1b.id,
      aws_subnet.public_1c.id
    ]
  }

  depends_on = [
    aws_iam_role.eks-iam-role,
  ]
}

# OIDC Identity Provider
data "tls_certificate" "eks" {
  url = aws_eks_cluster.k8squickstart-eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.k8squickstart-eks.identity[0].oidc[0].issuer
}

## Worker Nodes
resource "aws_iam_role" "workernodes" {
  name = "eks-node-group-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "CloudWatchAgentServerPolicy-eks" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.workernodes.name
}

resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.workernodes.name
}
resource "aws_eks_node_group" "worker-node-group" {
  cluster_name    = aws_eks_cluster.k8squickstart-eks.name
  node_group_name = "k8squickstart-workernodes"
  node_role_arn   = aws_iam_role.workernodes.arn
  subnet_ids      = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1b.id,
    aws_subnet.private_1c.id
  ]
  instance_types = ["t3.2xlarge"]

  scaling_config {
    desired_size = var.desired_size
    max_size     = 4
    min_size     = var.min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    #aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_addon" "csi" {
  cluster_name = aws_eks_cluster.k8squickstart-eks.name
  addon_name   = "aws-ebs-csi-driver"
}

# IAM role for Karpenter
resource "aws_iam_role" "karpenter" {
  name = "karpenter-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub": "system:serviceaccount:karpenter:karpenter",
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Karpenter controller policy
resource "aws_iam_policy" "karpenter" {
  name        = "KarpenterControllerPolicy-${var.cluster_name}"
  description = "IAM policy for Karpenter controller"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateTags",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstanceStatus",
          "iam:PassRole",
          "ssm:GetParameter"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster"]
        Resource = "arn:aws:eks:*:*:cluster/${var.cluster_name}"
      }
    ]
  })
}

# Attach the policy to the Karpenter role
resource "aws_iam_role_policy_attachment" "karpenter" {
  role       = aws_iam_role.karpenter.name
  policy_arn = aws_iam_policy.karpenter.arn
}

# Instance profile for Karpenter nodes
resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = aws_iam_role.workernodes.name
}