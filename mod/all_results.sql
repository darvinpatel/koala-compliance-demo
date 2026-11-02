  select 'CIS AWS v3.0.0' as framework, 'cis_v300_1_4' as control, '1.4' as framework_id, r.* from (
select account_name as resource,
  case when root_access_keys_present::bool then 'alarm' else 'ok' end as status,
  case when root_access_keys_present::bool then 'Root user has active access keys' else 'No root access keys' end as reason,
  account_id as scope, 'global' as region
from csv.aws_account_settings
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_1_5' as control, '1.5' as framework_id, r.* from (
select account_name as resource,
  case when root_mfa_enabled::bool then 'ok' else 'alarm' end as status,
  case when root_mfa_enabled::bool then 'Root MFA enabled' else 'Root MFA not enabled' end as reason,
  account_id as scope, 'global' as region
from csv.aws_account_settings
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_1_8' as control, '1.8' as framework_id, r.* from (
select account_name as resource,
  case when nullif(password_min_length,'')::int >= 14 then 'ok' else 'alarm' end as status,
  'Minimum password length is ' || password_min_length as reason,
  account_id as scope, 'global' as region
from csv.aws_account_settings
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_1_10' as control, '1.10' as framework_id, r.* from (
select user_name as resource,
  case when not console_access::bool then 'skip' when mfa_enabled::bool then 'ok' else 'alarm' end as status,
  case when not console_access::bool then 'No console password'
       when mfa_enabled::bool then 'Console user has MFA' else 'Console user without MFA' end as reason,
  account_id as scope, 'global' as region
from csv.aws_iam_users
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_1_12' as control, '1.12' as framework_id, r.* from (
select user_name as resource,
  case when greatest(coalesce(nullif(password_last_used_days,'')::int,0), coalesce(nullif(access_key_last_used_days,'')::int,0)) >= 45
       then 'alarm' else 'ok' end as status,
  'Password last used: ' || coalesce(nullif(password_last_used_days,'') || ' days ago','no password')
    || '; access key last used: ' || coalesce(nullif(access_key_last_used_days,'') || ' days ago','no key') as reason,
  account_id as scope, 'global' as region
from csv.aws_iam_users
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_1_14' as control, '1.14' as framework_id, r.* from (
select user_name as resource,
  case when nullif(active_access_keys,'')::int = 0 then 'skip' when nullif(oldest_access_key_age_days,'')::int > 90 then 'alarm' else 'ok' end as status,
  case when nullif(active_access_keys,'')::int = 0 then 'No active access keys'
       else 'Oldest active key is ' || oldest_access_key_age_days || ' days old' end as reason,
  account_id as scope, 'global' as region
from csv.aws_iam_users
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_2_1_4' as control, '2.1.4' as framework_id, r.* from (
select bucket_name as resource,
  case when block_public_access::bool then 'ok' else 'alarm' end as status,
  case when block_public_access::bool then 'Block public access on' else 'Block public access off' end as reason,
  account_id as scope, region
from csv.aws_s3_buckets
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_2_2_1' as control, '2.2.1' as framework_id, r.* from (
select volume_id as resource,
  case when encrypted::bool then 'ok' else 'alarm' end as status,
  case when encrypted::bool then 'Volume encrypted' else 'Volume not encrypted' end as reason,
  account_id as scope, region
from csv.aws_ebs_volumes
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_2_3_1' as control, '2.3.1' as framework_id, r.* from (
select db_instance_id as resource,
  case when storage_encrypted::bool then 'ok' else 'alarm' end as status,
  case when storage_encrypted::bool then 'Storage encrypted' else 'Storage not encrypted' end as reason,
  account_id as scope, region
from csv.aws_rds_instances
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_2_3_3' as control, '2.3.3' as framework_id, r.* from (
select db_instance_id as resource,
  case when publicly_accessible::bool then 'alarm' else 'ok' end as status,
  case when publicly_accessible::bool then 'Instance is publicly accessible' else 'Not publicly accessible' end as reason,
  account_id as scope, region
from csv.aws_rds_instances
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_3_1' as control, '3.1' as framework_id, r.* from (
select trail_name as resource,
  case when is_multi_region::bool and is_logging::bool then 'ok' else 'alarm' end as status,
  case when is_multi_region::bool and is_logging::bool then 'Multi-region trail logging' else 'Trail is not multi-region and logging' end as reason,
  account_id as scope, home_region as region
from csv.aws_cloudtrail
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_3_2' as control, '3.2' as framework_id, r.* from (
select trail_name as resource,
  case when log_file_validation::bool then 'ok' else 'alarm' end as status,
  case when log_file_validation::bool then 'Log file validation on' else 'Log file validation off' end as reason,
  account_id as scope, home_region as region
from csv.aws_cloudtrail
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_3_5' as control, '3.5' as framework_id, r.* from (
select trail_name as resource,
  case when kms_encrypted::bool then 'ok' else 'alarm' end as status,
  case when kms_encrypted::bool then 'Encrypted with KMS key' else 'Not encrypted with KMS key' end as reason,
  account_id as scope, home_region as region
from csv.aws_cloudtrail
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_5_2' as control, '5.2' as framework_id, r.* from (
select group_id || ' (' || group_name || ':' || from_port || ')' as resource,
  case when cidr = '0.0.0.0/0' and (nullif(from_port,'')::int <= 22 and nullif(to_port,'')::int >= 22 or nullif(from_port,'')::int <= 3389 and nullif(to_port,'')::int >= 3389)
       then 'alarm' else 'ok' end as status,
  'Ingress ' || cidr || ' to port ' || from_port as reason,
  account_id as scope, region
from csv.aws_security_group_rules where cidr not like '%:%'
  ) r
  union all
  select 'CIS AWS v3.0.0' as framework, 'cis_v300_5_3' as control, '5.3' as framework_id, r.* from (
select group_id || ' (' || group_name || ':' || from_port || ')' as resource,
  case when cidr = '::/0' and (nullif(from_port,'')::int <= 22 and nullif(to_port,'')::int >= 22 or nullif(from_port,'')::int <= 3389 and nullif(to_port,'')::int >= 3389)
       then 'alarm' else 'ok' end as status,
  'Ingress ' || cidr || ' to port ' || from_port as reason,
  account_id as scope, region
from csv.aws_security_group_rules where cidr like '%:%'
  ) r
  union all
  select 'Essential Eight ML1' as framework, 'e8_ml1_patch_applications' as control, 'Patch applications' as framework_id, r.* from (
select hostname as resource,
  case when nullif(app_patch_age_days,'')::int <= 14 then 'ok' else 'alarm' end as status,
  'Oldest missing application patch released ' || app_patch_age_days || ' days ago (limit 14)' as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  ) r
  union all
  select 'Essential Eight ML1' as framework, 'e8_ml1_patch_operating_systems' as control, 'Patch operating systems' as framework_id, r.* from (
select hostname as resource,
  case when nullif(os_patch_age_days,'')::int <= case when internet_facing::bool then 14 else 31 end then 'ok' else 'alarm' end as status,
  'OS patch age ' || os_patch_age_days || ' days (limit ' || case when internet_facing::bool then '14' else '31' end || ')' as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  ) r
  union all
  select 'Essential Eight ML1' as framework, 'e8_ml1_os_supported' as control, 'Patch operating systems' as framework_id, r.* from (
select hostname as resource,
  case when os_vendor_supported::bool then 'ok' else 'alarm' end as status,
  os || case when os_vendor_supported::bool then ' is vendor supported' else ' is no longer vendor supported' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  ) r
  union all
  select 'Essential Eight ML1' as framework, 'e8_ml1_multi_factor_authentication' as control, 'Multi-factor authentication' as framework_id, r.* from (
select user_name as resource,
  case when mfa_enabled::bool then 'ok' else 'alarm' end as status,
  case when mfa_enabled::bool then 'AWS console user has MFA' else 'AWS console user without MFA' end as reason,
  account_id as scope, 'aws' as region
from csv.aws_iam_users where console_access::bool
union all
select user_principal_name, case when mfa_registered::bool then 'ok' else 'alarm' end,
  case when mfa_registered::bool then 'Entra ID user has MFA' else 'Entra ID user without MFA' end,
  tenant, 'azure'
from csv.azure_ad_users where account_enabled::bool
  ) r
  union all
  select 'Essential Eight ML1' as framework, 'e8_ml1_restrict_administrative_privileges' as control, 'Restrict administrative privileges' as framework_id, r.* from (
select hostname as resource,
  case when privileged_accounts_internet_blocked::bool then 'ok' else 'alarm' end as status,
  case when privileged_accounts_internet_blocked::bool then 'Privileged accounts blocked from internet/email'
       else 'Privileged accounts can reach internet/email' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  ) r
  union all
  select 'Essential Eight ML1' as framework, 'e8_ml1_application_control' as control, 'Application control' as framework_id, r.* from (
select hostname as resource,
  case when device_type <> 'workstation' then 'skip' when application_control_enabled::bool then 'ok' else 'alarm' end as status,
  case when device_type <> 'workstation' then 'ML1 scope is workstations only'
       when application_control_enabled::bool then 'Application control enforced' else 'No application control' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  ) r
  union all
  select 'Essential Eight ML1' as framework, 'e8_ml1_restrict_microsoft_office_macros' as control, 'Restrict Microsoft Office macros' as framework_id, r.* from (
select hostname as resource,
  case when device_type <> 'workstation' then 'skip' when macros_blocked_from_internet::bool then 'ok' else 'alarm' end as status,
  case when device_type <> 'workstation' then 'Server, no Office install'
       when macros_blocked_from_internet::bool then 'Internet macros blocked' else 'Internet macros not blocked' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  ) r
  union all
  select 'Essential Eight ML1' as framework, 'e8_ml1_user_application_hardening' as control, 'User application hardening' as framework_id, r.* from (
select hostname as resource,
  case when device_type <> 'workstation' then 'skip'
       when browser_java_blocked::bool and browser_ads_blocked::bool then 'ok' else 'alarm' end as status,
  case when device_type <> 'workstation' then 'Server, no user browsing'
       else 'Java blocked: ' || browser_java_blocked || ', ads blocked: ' || browser_ads_blocked end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  ) r
  union all
  select 'Essential Eight ML1' as framework, 'e8_ml1_regular_backups' as control, 'Regular backups' as framework_id, r.* from (
select hostname as resource,
  case when backup_enabled::bool and nullif(backup_last_tested_days,'')::int <= 365 then 'ok' else 'alarm' end as status,
  case when not backup_enabled::bool then 'No backup configured'
       else 'Restore last tested ' || backup_last_tested_days || ' days ago' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  ) r
  union all
  select 'Koala Freight custom' as framework, 'kf_required_tags' as control, 'KF-01' as framework_id, r.* from (
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
  ) r
  union all
  select 'Koala Freight custom' as framework, 'kf_iam_users_unused_90_days' as control, 'KF-02' as framework_id, r.* from (
select user_name as resource,
  case when least(coalesce(nullif(password_last_used_days,'')::int,99999), coalesce(nullif(access_key_last_used_days,'')::int,99999)) > 90 then 'alarm' else 'ok' end as status,
  'Most recent activity ' || least(nullif(password_last_used_days,'')::int, nullif(access_key_last_used_days,'')::int) || ' days ago' as reason,
  account_id as scope, 'global' as region
from csv.aws_iam_users
  ) r
  union all
  select 'Koala Freight custom' as framework, 'kf_backups_tested_90_days' as control, 'KF-03' as framework_id, r.* from (
select hostname as resource, case when nullif(backup_last_tested_days,'')::int <= 90 then 'ok' else 'alarm' end as status,
  'Restore last tested ' || backup_last_tested_days || ' days ago' as reason, device_type as scope, 'on-prem' as region
from csv.endpoints where device_type = 'server'
union all
select db_instance_id, case when nullif(last_restore_test_days,'')::int <= 90 and nullif(backup_retention_days,'')::int > 0 then 'ok' else 'alarm' end,
  'Retention ' || backup_retention_days || ' days; restore last tested ' || last_restore_test_days || ' days ago', account_id, region
from csv.aws_rds_instances
  ) r
  union all
  select 'Koala Freight custom' as framework, 'kf_s3_encrypted_versioned' as control, 'KF-04' as framework_id, r.* from (
select bucket_name as resource, case when default_encryption::bool and versioning::bool then 'ok' else 'alarm' end as status,
  'encryption=' || default_encryption || ', versioning=' || versioning as reason, account_id as scope, region
from csv.aws_s3_buckets
  ) r
  union all
  select 'Koala Freight custom' as framework, 'kf_az_storage_secure' as control, 'KF-AZ-01' as framework_id, r.* from (
select name as resource, case when https_only::bool and not allow_blob_public_access::bool then 'ok' else 'alarm' end as status,
  'https_only=' || https_only || ', public_blob_access=' || allow_blob_public_access as reason, subscription_id as scope, location as region
from csv.azure_storage_accounts
  ) r
  union all
  select 'Koala Freight custom' as framework, 'kf_az_nsg_admin_ports' as control, 'KF-AZ-02' as framework_id, r.* from (
select nsg_name || '/' || rule_name as resource,
  case when destination_port in ('22','3389') and source_prefix in ('*','0.0.0.0/0','Internet','Any') and access = 'Allow' then 'alarm' else 'ok' end as status,
  'Allow ' || source_prefix || ' to port ' || destination_port as reason, subscription_id as scope, location as region
from csv.azure_nsg_rules where direction = 'Inbound'
  ) r
  union all
  select 'Koala Freight custom' as framework, 'kf_az_key_vault_recoverable' as control, 'KF-AZ-03' as framework_id, r.* from (
select vault_name as resource, case when soft_delete_enabled::bool and purge_protection_enabled::bool then 'ok' else 'alarm' end as status,
  'soft_delete=' || soft_delete_enabled || ', purge_protection=' || purge_protection_enabled as reason, subscription_id as scope, location as region
from csv.azure_key_vaults
  ) r
