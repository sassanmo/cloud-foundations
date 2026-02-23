# AWS Cognito Terraform Module

This module creates an Amazon Cognito user pool for user authentication and authorization.

## Features

- User pool with customizable attributes
- Password policies
- MFA support (TOTP)
- Multiple app clients
- Account recovery settings
- Custom schemas
- Cognito domain

## Usage

```hcl
module "cognito" {
  source = "../../service/cognito"

  project     = "myapp"
  environment = "prod"
  
  mfa_configuration = "OPTIONAL"
  
  password_policy = {
    minimum_length    = 12
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
  
  clients = {
    web = {
      callback_urls = ["https://myapp.com/callback"]
      logout_urls   = ["https://myapp.com/logout"]
    }
    mobile = {
      generate_secret = true
    }
  }
  
  domain = "myapp-prod"
  
  tags = {
    Team = "platform"
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| user_pool_id | Cognito user pool ID |
| user_pool_endpoint | User pool endpoint |
| client_ids | Map of client IDs |

