# EC2 Module

This module creates a secure AWS EC2 instance following AWS best practices.

## Features

- IMDSv2 enforced by default (prevents SSRF-based metadata attacks)
- Encrypted EBS root volume by default
- Detailed monitoring enabled by default
- KMS encryption support for EBS volumes

## Usage

```hcl
module "ec2_instance" {
  source = "../../service/ec2"

  name          = "my-instance"
  ami_id        = "ami-0abcdef1234567890"
  instance_type = "t3.small"
  subnet_id     = "subnet-12345678"

  vpc_security_group_ids = ["sg-12345678"]
  iam_instance_profile   = "my-instance-profile"

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the EC2 instance. | `string` | n/a | yes |
| ami_id | AMI ID for the EC2 instance. | `string` | n/a | yes |
| subnet_id | Subnet ID to launch the instance in. | `string` | n/a | yes |
| instance_type | EC2 instance type. | `string` | `"t3.micro"` | no |
| vpc_security_group_ids | List of security group IDs. | `list(string)` | `[]` | no |
| key_name | Key pair name for SSH access. | `string` | `""` | no |
| iam_instance_profile | IAM instance profile name. | `string` | `""` | no |
| root_volume_size | Size of the root EBS volume in GiB. | `number` | `20` | no |
| root_volume_type | Type of the root EBS volume. | `string` | `"gp3"` | no |
| root_volume_encrypted | Enable encryption on the root EBS volume. | `bool` | `true` | no |
| kms_key_id | KMS key ID for EBS volume encryption. | `string` | `""` | no |
| monitoring_enabled | Enable detailed monitoring. | `bool` | `true` | no |
| user_data | User data to provide when launching the instance. | `string` | `""` | no |
| metadata_options | Metadata options (IMDSv2 settings). | `object` | `{}` | no |
| tags | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | The ID of the EC2 instance. |
| instance_arn | The ARN of the EC2 instance. |
| private_ip | The private IP address. |
| public_ip | The public IP address (if applicable). |
