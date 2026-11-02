control "kf_required_tags" {
  title       = "KF-01 Data stores carry owner and data-classification tags"
  description = "Koala Freight internal policy control (synthetic)."
  sql = <<-EOQ
select bucket_name as resource, case when tag_owner <> '' and tag_data_classification <> '' then 'ok' else 'alarm' end as status,
  'owner=' || coalesce(nullif(tag_owner,''),'MISSING') || ', data-classification=' || coalesce(nullif(tag_data_classification,''),'MISSING') as reason,
  account_id as scope, region from csv.aws_s3_buckets
union all
select volume_id, case when tag_owner <> '' and tag_data_classification <> '' then 'ok' else 'alarm' end,
  'owner=' || coalesce(nullif(tag_owner,''),'MISSING') || ', data-classification=' || coalesce(nullif(tag_data_classification,''),'MISSING'),
  account_id, region from csv.aws_ebs_volumes
union all
select db_instance_id, case when tag_owner <> '' and tag_data_classification <> '' then 'ok' else 'alarm' end,
  'owner=' || coalesce(nullif(tag_owner,''),'MISSING') || ', data-classification=' || coalesce(nullif(tag_data_classification,''),'MISSING'),
  account_id, region from csv.aws_rds_instances
union all
select name, case when tag_owner <> '' and tag_data_classification <> '' then 'ok' else 'alarm' end,
  'owner=' || coalesce(nullif(tag_owner,''),'MISSING') || ', data-classification=' || coalesce(nullif(tag_data_classification,''),'MISSING'),
  subscription_id, location from csv.azure_storage_accounts
  EOQ
  tags = {
    framework = "koala_freight_custom"
    kf_control_id = "KF-01"
    cloud = "aws"
  }
}

control "kf_iam_users_unused_90_days" {
  title       = "KF-02 No IAM users left unused for more than 90 days"
  description = "Koala Freight internal policy control (synthetic)."
  sql = <<-EOQ
select user_name as resource,
  case when least(coalesce(nullif(password_last_used_days,'')::int,99999), coalesce(nullif(access_key_last_used_days,'')::int,99999)) > 90 then 'alarm' else 'ok' end as status,
  'Most recent activity ' || least(nullif(password_last_used_days,'')::int, nullif(access_key_last_used_days,'')::int) || ' days ago' as reason,
  account_id as scope, 'global' as region
from csv.aws_iam_users
  EOQ
  tags = {
    framework = "koala_freight_custom"
    kf_control_id = "KF-02"
    cloud = "aws"
  }
}

control "kf_backups_tested_90_days" {
  title       = "KF-03 Restores tested within the last 90 days (servers and databases)"
  description = "Koala Freight internal policy control (synthetic)."
  sql = <<-EOQ
select hostname as resource, case when nullif(backup_last_tested_days,'')::int <= 90 then 'ok' else 'alarm' end as status,
  'Restore last tested ' || backup_last_tested_days || ' days ago' as reason, device_type as scope, 'on-prem' as region
from csv.endpoints where device_type = 'server'
union all
select db_instance_id, case when nullif(last_restore_test_days,'')::int <= 90 and nullif(backup_retention_days,'')::int > 0 then 'ok' else 'alarm' end,
  'Retention ' || backup_retention_days || ' days; restore last tested ' || last_restore_test_days || ' days ago', account_id, region
from csv.aws_rds_instances
  EOQ
  tags = {
    framework = "koala_freight_custom"
    kf_control_id = "KF-03"
    cloud = "aws"
  }
}

control "kf_s3_encrypted_versioned" {
  title       = "KF-04 S3 buckets have default encryption and versioning"
  description = "Koala Freight internal policy control (synthetic)."
  sql = <<-EOQ
select bucket_name as resource, case when default_encryption::bool and versioning::bool then 'ok' else 'alarm' end as status,
  'encryption=' || default_encryption || ', versioning=' || versioning as reason, account_id as scope, region
from csv.aws_s3_buckets
  EOQ
  tags = {
    framework = "koala_freight_custom"
    kf_control_id = "KF-04"
    cloud = "aws"
  }
}

control "kf_az_storage_secure" {
  title       = "KF-AZ-01 Azure storage: secure transfer required and no anonymous blob access"
  description = "Koala Freight internal policy control (synthetic)."
  sql = <<-EOQ
select name as resource, case when https_only::bool and not allow_blob_public_access::bool then 'ok' else 'alarm' end as status,
  'https_only=' || https_only || ', public_blob_access=' || allow_blob_public_access as reason, subscription_id as scope, location as region
from csv.azure_storage_accounts
  EOQ
  tags = {
    framework = "koala_freight_custom"
    kf_control_id = "KF-AZ-01"
    cloud = "azure"
  }
}

control "kf_az_nsg_admin_ports" {
  title       = "KF-AZ-02 Azure NSGs: no inbound 22/3389 from the internet"
  description = "Koala Freight internal policy control (synthetic)."
  sql = <<-EOQ
select nsg_name || '/' || rule_name as resource,
  case when destination_port in ('22','3389') and source_prefix in ('*','0.0.0.0/0','Internet','Any') and access = 'Allow' then 'alarm' else 'ok' end as status,
  'Allow ' || source_prefix || ' to port ' || destination_port as reason, subscription_id as scope, location as region
from csv.azure_nsg_rules where direction = 'Inbound'
  EOQ
  tags = {
    framework = "koala_freight_custom"
    kf_control_id = "KF-AZ-02"
    cloud = "azure"
  }
}

control "kf_az_key_vault_recoverable" {
  title       = "KF-AZ-03 Azure Key Vaults: soft delete and purge protection on"
  description = "Koala Freight internal policy control (synthetic)."
  sql = <<-EOQ
select vault_name as resource, case when soft_delete_enabled::bool and purge_protection_enabled::bool then 'ok' else 'alarm' end as status,
  'soft_delete=' || soft_delete_enabled || ', purge_protection=' || purge_protection_enabled as reason, subscription_id as scope, location as region
from csv.azure_key_vaults
  EOQ
  tags = {
    framework = "koala_freight_custom"
    kf_control_id = "KF-AZ-03"
    cloud = "azure"
  }
}

benchmark "koala_freight_custom" {
  title       = "Koala Freight custom controls"
  description = "Org-specific policy checks plus an Azure starter set."
  children = [
    control.kf_required_tags,
    control.kf_iam_users_unused_90_days,
    control.kf_backups_tested_90_days,
    control.kf_s3_encrypted_versioned,
    control.kf_az_storage_secure,
    control.kf_az_nsg_admin_ports,
    control.kf_az_key_vault_recoverable
  ]
}
