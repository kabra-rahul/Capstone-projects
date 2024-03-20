provider "aws" {
  region = "us-east-1"
  access_key = "AKIA3EFKBE26MBQZV23S"
  secret_key = "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"
}

# Creating VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  tags = {
    Name = "dev-vpc"
  }
}

# Creating Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "eks_internet_gateway" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "dev-igw"
  }
}

# Creating Public Subnet
resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_1a"
  }
}
resource "aws_subnet" "public_subnet_1b" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_1b"
  }
}

# Creating Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_internet_gateway.id
  }
  tags = {
    Name = "public_route_table"
  }
}

# Associating Public Subnet  to route table
resource "aws_route_table_association" "public_subnet_1a_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_subnet_1b_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Security Group for the EKS  
resource "aws_security_group" "eks_security_group" {
  name   = "SH security group"
  vpc_id = aws_vpc.eks_vpc.id
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "outbound access"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "dev-EKS-security-group"
  }
}

# Creating IAM role for Master Node
resource "aws_iam_role" "master" {
  name = "EKS-Master"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.master.name
}

# Creating IAM role for Worker Node
resource "aws_iam_role" "worker" {
  name = "ed-eks-worker"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker.name
}

# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker.name
}


# Attaching Policy to IAM role
resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker.name
}

# Creating EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = "kubernetescluster"
  role_arn = aws_iam_role.master.arn
  version = "1.28"
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access = true
    subnet_ids = [aws_subnet.public_subnet_1a.id, aws_subnet.public_subnet_1b.id]
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# Creating Worker Node Group
resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "worker-nodes"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = [aws_subnet.public_subnet_1a.id,aws_subnet.public_subnet_1b.id]
  capacity_type   = "ON_DEMAND"
  disk_size       = 20
  instance_types  = ["t2.medium"]
  ami_type = "AL2_x86_64"
  version = "1.28"
  labels = {
    role = "worker_nodes"
  }
  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only
  ]
}
