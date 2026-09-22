# Ec2
application
# AWS Terraform Assignment – Go API

This repository contains Terraform infrastructure for deploying a Go API on AWS using two approaches:

* Part 1: EC2-based deployment behind an Application Load Balancer
* Part 2: EKS-based container deployment using Amazon ECR and pod-level AWS permissions
* Automation: GitHub Actions validation for both Terraform configurations


# Prerequisites

The following tools are required:

* Terraform >= 1.6
* AWS CLI
* AWS account
* Git
* Docker
* kubectl for the EKS deployment

Configure AWS credentials using the AWS CLI or another supported AWS authentication mechanism.

No AWS access keys or secrets are stored in Terraform code.

---

# Part 1 – EC2 Deployment

## Architecture

The Go API is deployed on an EC2 instance in a **private subnet** and exposed through an **Application Load Balancer** in public subnets.


## Resources Created

Part 1 creates:

* VPC
* 2 public subnets
* 2 private subnets
* Internet Gateway
* Public route table
* Private route table
* NAT Gateway
* Elastic IP
* Application Load Balancer
* ALB target group
* ALB listener
* EC2 instance
* ALB security group
* EC2 security group
* IAM role
* IAM instance profile
* S3 bucket for supporting application logs
* S3 public-access blocking configuration

---

## Why is EC2 in a Private Subnet?

The EC2 instance is intentionally placed in a private subnet.

The ALB is the only public entry point for the application.


The EC2 instance does not have a public IP and cannot be directly accessed from the Internet.

This provides a basic public-tier/application-tier separation.

---

## Why is NAT Gateway Required?

Because the EC2 instance is in a private subnet, it does not have direct Internet connectivity.

A NAT Gateway allows the instance to initiate outbound connections when required, while preventing unsolicited inbound Internet connections.

The route is:


A single NAT Gateway is used as a time/cost-conscious choice for this assignment.

For a production environment requiring stronger availability, I would consider a NAT Gateway per Availability Zone.

---

# Security Group Design

Two security groups are used.

## ALB Security Group

The ALB security group allows:

```text
Inbound:
TCP 80  from 0.0.0.0/0
TCP 443 from 0.0.0.0/0
```

The ALB is therefore the public-facing component.

## EC2 Security Group

The EC2 security group allows:


Inbound:
TCP 8080 from ALB Security Group only


It does not allow:


TCP 8080 from 0.0.0.0/0


Therefore, users cannot directly access the EC2 application.

The security relationship is:


This is preferable to allowing the EC2 application port from the entire Internet.

---

# EC2 IAM Design

The EC2 instance uses an IAM role through an instance profile.

No AWS credentials are hardcoded in the instance or Terraform configuration.

The IAM role provides limited access to the supporting S3 bucket.

The application is granted:


s3:PutObject


against the required log path only.

Example scope:


arn:aws:s3:::<bucket>/logs/*


This follows the principle of least privilege.

---

# Docker / Go API

The EC2 instance installs Docker during bootstrap using EC2 user data.

The application is intended to run as a Docker container and listen on:


8080


The ALB forwards traffic to the EC2 target on port 8080.

If an external application image is used, the image can be pulled from a container registry such as ECR or Docker Hub.

---

# Part 1 – Terraform Commands

Navigate to:

```bash
cd terraform/ec2
```

Initialize Terraform:

```bash
terraform init
```

Format Terraform files:

```bash
terraform fmt -recursive
```

Validate configuration:

```bash
terraform validate
```

Create the execution plan:

```bash
terraform plan
```

Apply the infrastructure if required:

```bash
terraform apply
```

After testing, destroy the resources to avoid unnecessary AWS charges:

```bash
terraform destroy
```
