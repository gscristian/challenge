provider "aws" {
  region     = "eu-west-1"
}
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_secretsmanager_secret" "auroradbpassword" {
  name = "auroradb/admin/credentials"
  description = "AuroraDB Admin credentials"
}

resource "aws_secretsmanager_secret_version" "auroradbpassword" {
  secret_id     = "${aws_secretsmanager_secret.auroradbpassword.id}"
  secret_string = "Str0n9p4Ssw0Rd"
}

data "aws_iam_policy_document" "secretsmanageraurorapolicy" {
  statement {
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${aws_secretsmanager_secret.auroradbpassword.name}",
    ]
  }
}
module "rds-aurora" {
  source                          = "terraform-aws-modules/rds-aurora/aws"
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.12"
  vpc_id                          = "vpc-12345678"
  subnets                         = ["subnet-12345678", "subnet-12345679"]
  replica_count                   = 1
  instance_type                   = "db.t2.small"
  name                            = "auroradb"
  username                        = "admin"
  password                        = "${aws_secretsmanager_secret_version.auroradbpassword.secret_string}"
  db_parameter_group_name         = "default.aurora-mysql5.7"
  db_cluster_parameter_group_name = "default.aurora-mysql5.7"
  apply_immediately               = true
  monitoring_interval             = 10
  publicly_accessible             = true
}
