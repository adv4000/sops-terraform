terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    sops = {
      source = "carlpett/sops"
    }
  }
}

provider "sops" {}
provider "aws" {
  region = "il-central-1"
}

data "sops_file" "secrets" {
  source_file = "secrets-sops.encrypted.yml"
}

#---Direct read from Encrypted Secret File-----------------------------------
output "data" {
  value = nonsensitive(data.sops_file.secrets.data)
}

output "raw" {
  value = nonsensitive(data.sops_file.secrets.raw)
}

output "yaml_to_map" {
  value = nonsensitive(yamldecode(data.sops_file.secrets.raw))
}

output "secret_masterDB" {
  value = nonsensitive(yamldecode(data.sops_file.secrets.raw)).masterDB
}

output "secret_masterDB_password" {
  value = nonsensitive(yamldecode(data.sops_file.secrets.raw)).masterDB.pass
}

output "secret_directors_eng" {
  value = nonsensitive(yamldecode(data.sops_file.secrets.raw)).directors_eng
}

#---------------------------------------------------------------------------
#---Deploy Secret file to AWS Secrets Manager and SSM Parameter Store-------

resource "aws_secretsmanager_secret" "my_secret" {
  name = "my-secrets"
}

resource "aws_secretsmanager_secret_version" "my_secret_version" {
  secret_id     = aws_secretsmanager_secret.my_secret.id
  secret_string = jsonencode(yamldecode(data.sops_file.secrets.raw))
}


resource "aws_ssm_parameter" "my_secret" {
  name  = "my-secrets"
  type  = "SecureString"
  value = jsonencode(yamldecode(data.sops_file.secrets.raw))
}

#---Read Secrets from AWS Secrets Manager and SSM Parameter Store-------
data "aws_secretsmanager_secret_version" "db" {
  secret_id  = aws_secretsmanager_secret.my_secret.id
  depends_on = [aws_secretsmanager_secret_version.my_secret_version]
}

data "aws_ssm_parameter" "db" {
  name = aws_ssm_parameter.my_secret.name
}

#--------------------
output "secret_from_SecretManager" {
  value = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["masterDB"]["pass"])
}

output "secret_from_ParameterStore" {
  value = nonsensitive(jsondecode(data.aws_ssm_parameter.db.value)["masterDB"]["pass"])
}
#--------------------
