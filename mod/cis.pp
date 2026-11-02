control "cis_v300_1_4" {
  title       = "1.4 Ensure no 'root' user account access key exists"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 1.4."
  sql = <<-EOQ
select account_name as resource,
  case when root_access_keys_present::bool then 'alarm' else 'ok' end as status,
  case when root_access_keys_present::bool then 'Root user has active access keys' else 'No root access keys' end as reason,
  account_id as scope, 'global' as region
from csv.aws_account_settings
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "1.4"
  }
}

control "cis_v300_1_5" {
  title       = "1.5 Ensure MFA is enabled for the 'root' user account"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 1.5."
  sql = <<-EOQ
select account_name as resource,
  case when root_mfa_enabled::bool then 'ok' else 'alarm' end as status,
  case when root_mfa_enabled::bool then 'Root MFA enabled' else 'Root MFA not enabled' end as reason,
  account_id as scope, 'global' as region
from csv.aws_account_settings
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "1.5"
  }
}

control "cis_v300_1_8" {
  title       = "1.8 Ensure IAM password policy requires minimum length of 14 or greater"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 1.8."
  sql = <<-EOQ
select account_name as resource,
  case when nullif(password_min_length,'')::int >= 14 then 'ok' else 'alarm' end as status,
  'Minimum password length is ' || password_min_length as reason,
  account_id as scope, 'global' as region
from csv.aws_account_settings
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "1.8"
  }
}

control "cis_v300_1_10" {
  title       = "1.10 Ensure MFA is enabled for all IAM users that have a console password"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 1.10."
  sql = <<-EOQ
select user_name as resource,
  case when not console_access::bool then 'skip' when mfa_enabled::bool then 'ok' else 'alarm' end as status,
  case when not console_access::bool then 'No console password'
       when mfa_enabled::bool then 'Console user has MFA' else 'Console user without MFA' end as reason,
  account_id as scope, 'global' as region
from csv.aws_iam_users
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "1.10"
  }
}

control "cis_v300_1_12" {
  title       = "1.12 Ensure credentials unused for 45 days or greater are disabled"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 1.12."
  sql = <<-EOQ
select user_name as resource,
  case when greatest(coalesce(nullif(password_last_used_days,'')::int,0), coalesce(nullif(access_key_last_used_days,'')::int,0)) >= 45
       then 'alarm' else 'ok' end as status,
  'Password last used: ' || coalesce(nullif(password_last_used_days,'') || ' days ago','no password')
    || '; access key last used: ' || coalesce(nullif(access_key_last_used_days,'') || ' days ago','no key') as reason,
  account_id as scope, 'global' as region
from csv.aws_iam_users
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "1.12"
  }
}

control "cis_v300_1_14" {
  title       = "1.14 Ensure access keys are rotated every 90 days or less"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 1.14."
  sql = <<-EOQ
select user_name as resource,
  case when nullif(active_access_keys,'')::int = 0 then 'skip' when nullif(oldest_access_key_age_days,'')::int > 90 then 'alarm' else 'ok' end as status,
  case when nullif(active_access_keys,'')::int = 0 then 'No active access keys'
       else 'Oldest active key is ' || oldest_access_key_age_days || ' days old' end as reason,
  account_id as scope, 'global' as region
from csv.aws_iam_users
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "1.14"
  }
}

control "cis_v300_2_1_4" {
  title       = "2.1.4 Ensure that S3 Buckets are configured with 'Block public access (bucket settings)'"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 2.1.4."
  sql = <<-EOQ
select bucket_name as resource,
  case when block_public_access::bool then 'ok' else 'alarm' end as status,
  case when block_public_access::bool then 'Block public access on' else 'Block public access off' end as reason,
  account_id as scope, region
from csv.aws_s3_buckets
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "2.1.4"
  }
}

control "cis_v300_2_2_1" {
  title       = "2.2.1 Ensure EBS Volume Encryption is Enabled in all Regions (per-volume proxy)"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 2.2.1."
  sql = <<-EOQ
select volume_id as resource,
  case when encrypted::bool then 'ok' else 'alarm' end as status,
  case when encrypted::bool then 'Volume encrypted' else 'Volume not encrypted' end as reason,
  account_id as scope, region
from csv.aws_ebs_volumes
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "2.2.1"
  }
}

control "cis_v300_2_3_1" {
  title       = "2.3.1 Ensure that encryption-at-rest is enabled for RDS Instances"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 2.3.1."
  sql = <<-EOQ
select db_instance_id as resource,
  case when storage_encrypted::bool then 'ok' else 'alarm' end as status,
  case when storage_encrypted::bool then 'Storage encrypted' else 'Storage not encrypted' end as reason,
  account_id as scope, region
from csv.aws_rds_instances
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "2.3.1"
  }
}

control "cis_v300_2_3_3" {
  title       = "2.3.3 Ensure that public access is not given to RDS Instance"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 2.3.3."
  sql = <<-EOQ
select db_instance_id as resource,
  case when publicly_accessible::bool then 'alarm' else 'ok' end as status,
  case when publicly_accessible::bool then 'Instance is publicly accessible' else 'Not publicly accessible' end as reason,
  account_id as scope, region
from csv.aws_rds_instances
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "2.3.3"
  }
}

control "cis_v300_3_1" {
  title       = "3.1 Ensure CloudTrail is enabled in all regions"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 3.1."
  sql = <<-EOQ
select trail_name as resource,
  case when is_multi_region::bool and is_logging::bool then 'ok' else 'alarm' end as status,
  case when is_multi_region::bool and is_logging::bool then 'Multi-region trail logging' else 'Trail is not multi-region and logging' end as reason,
  account_id as scope, home_region as region
from csv.aws_cloudtrail
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "3.1"
  }
}

control "cis_v300_3_2" {
  title       = "3.2 Ensure CloudTrail log file validation is enabled"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 3.2."
  sql = <<-EOQ
select trail_name as resource,
  case when log_file_validation::bool then 'ok' else 'alarm' end as status,
  case when log_file_validation::bool then 'Log file validation on' else 'Log file validation off' end as reason,
  account_id as scope, home_region as region
from csv.aws_cloudtrail
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "3.2"
  }
}

control "cis_v300_3_5" {
  title       = "3.5 Ensure CloudTrail logs are encrypted at rest using KMS CMKs"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 3.5."
  sql = <<-EOQ
select trail_name as resource,
  case when kms_encrypted::bool then 'ok' else 'alarm' end as status,
  case when kms_encrypted::bool then 'Encrypted with KMS key' else 'Not encrypted with KMS key' end as reason,
  account_id as scope, home_region as region
from csv.aws_cloudtrail
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "3.5"
  }
}

control "cis_v300_5_2" {
  title       = "5.2 Ensure no security groups allow ingress from 0.0.0.0/0 to remote server administration ports"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 5.2."
  sql = <<-EOQ
select group_id || ' (' || group_name || ':' || from_port || ')' as resource,
  case when cidr = '0.0.0.0/0' and (nullif(from_port,'')::int <= 22 and nullif(to_port,'')::int >= 22 or nullif(from_port,'')::int <= 3389 and nullif(to_port,'')::int >= 3389)
       then 'alarm' else 'ok' end as status,
  'Ingress ' || cidr || ' to port ' || from_port as reason,
  account_id as scope, region
from csv.aws_security_group_rules where cidr not like '%:%'
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "5.2"
  }
}

control "cis_v300_5_3" {
  title       = "5.3 Ensure no security groups allow ingress from ::/0 to remote server administration ports"
  description = "CIS AWS Foundations Benchmark v3.0.0 recommendation 5.3."
  sql = <<-EOQ
select group_id || ' (' || group_name || ':' || from_port || ')' as resource,
  case when cidr = '::/0' and (nullif(from_port,'')::int <= 22 and nullif(to_port,'')::int >= 22 or nullif(from_port,'')::int <= 3389 and nullif(to_port,'')::int >= 3389)
       then 'alarm' else 'ok' end as status,
  'Ingress ' || cidr || ' to port ' || from_port as reason,
  account_id as scope, region
from csv.aws_security_group_rules where cidr like '%:%'
  EOQ
  tags = {
    framework = "cis_aws_v3.0.0"
    cis_item_id = "5.3"
  }
}

benchmark "cis_aws_v300_subset" {
  title       = "CIS AWS Foundations Benchmark v3.0.0 (subset)"
  description = "Selected CIS v3.0.0 recommendations run against the synthetic Koala Freight estate."
  children = [
    control.cis_v300_1_4,
    control.cis_v300_1_5,
    control.cis_v300_1_8,
    control.cis_v300_1_10,
    control.cis_v300_1_12,
    control.cis_v300_1_14,
    control.cis_v300_2_1_4,
    control.cis_v300_2_2_1,
    control.cis_v300_2_3_1,
    control.cis_v300_2_3_3,
    control.cis_v300_3_1,
    control.cis_v300_3_2,
    control.cis_v300_3_5,
    control.cis_v300_5_2,
    control.cis_v300_5_3
  ]
}
