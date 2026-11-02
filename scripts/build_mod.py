#!/usr/bin/env python3
"""Single source of truth for controls. Writes the Powerpipe .pp files in ../mod/.

Every control query returns: resource, status, reason, scope, region
(scope and region become Powerpipe dimensions). Run after editing: python3 scripts/build_mod.py
"""
from pathlib import Path

MOD = Path(__file__).resolve().parent.parent / "mod"

def i(col):  # csv plugin columns are text; empty -> null -> int
    return f"nullif({col},'')::int"

# ---------- CIS AWS Foundations Benchmark v3.0.0 (subset) ----------
CIS = [
 ("cis_v300_1_4", "1.4", "Ensure no 'root' user account access key exists", f"""
select account_name as resource,
  case when root_access_keys_present::bool then 'alarm' else 'ok' end as status,
  case when root_access_keys_present::bool then 'Root user has active access keys' else 'No root access keys' end as reason,
  account_id as scope, 'global' as region
from csv.aws_account_settings"""),
 ("cis_v300_1_5", "1.5", "Ensure MFA is enabled for the 'root' user account", f"""
select account_name as resource,
  case when root_mfa_enabled::bool then 'ok' else 'alarm' end as status,
  case when root_mfa_enabled::bool then 'Root MFA enabled' else 'Root MFA not enabled' end as reason,
  account_id as scope, 'global' as region
from csv.aws_account_settings"""),
 ("cis_v300_1_8", "1.8", "Ensure IAM password policy requires minimum length of 14 or greater", f"""
select account_name as resource,
  case when {i('password_min_length')} >= 14 then 'ok' else 'alarm' end as status,
  'Minimum password length is ' || password_min_length as reason,
  account_id as scope, 'global' as region
from csv.aws_account_settings"""),
 ("cis_v300_1_10", "1.10", "Ensure MFA is enabled for all IAM users that have a console password", f"""
select user_name as resource,
  case when not console_access::bool then 'skip' when mfa_enabled::bool then 'ok' else 'alarm' end as status,
  case when not console_access::bool then 'No console password'
       when mfa_enabled::bool then 'Console user has MFA' else 'Console user without MFA' end as reason,
  account_id as scope, 'global' as region
from csv.aws_iam_users"""),
 ("cis_v300_1_12", "1.12", "Ensure credentials unused for 45 days or greater are disabled", f"""
select user_name as resource,
  case when greatest(coalesce({i('password_last_used_days')},0), coalesce({i('access_key_last_used_days')},0)) >= 45
       then 'alarm' else 'ok' end as status,
  'Password last used: ' || coalesce(nullif(password_last_used_days,'') || ' days ago','no password')
    || '; access key last used: ' || coalesce(nullif(access_key_last_used_days,'') || ' days ago','no key') as reason,
  account_id as scope, 'global' as region
from csv.aws_iam_users"""),
 ("cis_v300_1_14", "1.14", "Ensure access keys are rotated every 90 days or less", f"""
select user_name as resource,
  case when {i('active_access_keys')} = 0 then 'skip' when {i('oldest_access_key_age_days')} > 90 then 'alarm' else 'ok' end as status,
  case when {i('active_access_keys')} = 0 then 'No active access keys'
       else 'Oldest active key is ' || oldest_access_key_age_days || ' days old' end as reason,
  account_id as scope, 'global' as region
from csv.aws_iam_users"""),
 ("cis_v300_2_1_4", "2.1.4", "Ensure that S3 Buckets are configured with 'Block public access (bucket settings)'", f"""
select bucket_name as resource,
  case when block_public_access::bool then 'ok' else 'alarm' end as status,
  case when block_public_access::bool then 'Block public access on' else 'Block public access off' end as reason,
  account_id as scope, region
from csv.aws_s3_buckets"""),
 ("cis_v300_2_2_1", "2.2.1", "Ensure EBS Volume Encryption is Enabled in all Regions (per-volume proxy)", f"""
select volume_id as resource,
  case when encrypted::bool then 'ok' else 'alarm' end as status,
  case when encrypted::bool then 'Volume encrypted' else 'Volume not encrypted' end as reason,
  account_id as scope, region
from csv.aws_ebs_volumes"""),
 ("cis_v300_2_3_1", "2.3.1", "Ensure that encryption-at-rest is enabled for RDS Instances", f"""
select db_instance_id as resource,
  case when storage_encrypted::bool then 'ok' else 'alarm' end as status,
  case when storage_encrypted::bool then 'Storage encrypted' else 'Storage not encrypted' end as reason,
  account_id as scope, region
from csv.aws_rds_instances"""),
 ("cis_v300_2_3_3", "2.3.3", "Ensure that public access is not given to RDS Instance", f"""
select db_instance_id as resource,
  case when publicly_accessible::bool then 'alarm' else 'ok' end as status,
  case when publicly_accessible::bool then 'Instance is publicly accessible' else 'Not publicly accessible' end as reason,
  account_id as scope, region
from csv.aws_rds_instances"""),
 ("cis_v300_3_1", "3.1", "Ensure CloudTrail is enabled in all regions", f"""
select trail_name as resource,
  case when is_multi_region::bool and is_logging::bool then 'ok' else 'alarm' end as status,
  case when is_multi_region::bool and is_logging::bool then 'Multi-region trail logging' else 'Trail is not multi-region and logging' end as reason,
  account_id as scope, home_region as region
from csv.aws_cloudtrail"""),
 ("cis_v300_3_2", "3.2", "Ensure CloudTrail log file validation is enabled", f"""
select trail_name as resource,
  case when log_file_validation::bool then 'ok' else 'alarm' end as status,
  case when log_file_validation::bool then 'Log file validation on' else 'Log file validation off' end as reason,
  account_id as scope, home_region as region
from csv.aws_cloudtrail"""),
 ("cis_v300_3_5", "3.5", "Ensure CloudTrail logs are encrypted at rest using KMS CMKs", f"""
select trail_name as resource,
  case when kms_encrypted::bool then 'ok' else 'alarm' end as status,
  case when kms_encrypted::bool then 'Encrypted with KMS key' else 'Not encrypted with KMS key' end as reason,
  account_id as scope, home_region as region
from csv.aws_cloudtrail"""),
 ("cis_v300_5_2", "5.2", "Ensure no security groups allow ingress from 0.0.0.0/0 to remote server administration ports", f"""
select group_id || ' (' || group_name || ':' || from_port || ')' as resource,
  case when cidr = '0.0.0.0/0' and ({i('from_port')} <= 22 and {i('to_port')} >= 22 or {i('from_port')} <= 3389 and {i('to_port')} >= 3389)
       then 'alarm' else 'ok' end as status,
  'Ingress ' || cidr || ' to port ' || from_port as reason,
  account_id as scope, region
from csv.aws_security_group_rules where cidr not like '%:%'"""),
 ("cis_v300_5_3", "5.3", "Ensure no security groups allow ingress from ::/0 to remote server administration ports", f"""
select group_id || ' (' || group_name || ':' || from_port || ')' as resource,
  case when cidr = '::/0' and ({i('from_port')} <= 22 and {i('to_port')} >= 22 or {i('from_port')} <= 3389 and {i('to_port')} >= 3389)
       then 'alarm' else 'ok' end as status,
  'Ingress ' || cidr || ' to port ' || from_port as reason,
  account_id as scope, region
from csv.aws_security_group_rules where cidr like '%:%'"""),
]

# ---------- ACSC Essential Eight, Maturity Level One (Nov 2023 model) ----------
E8 = [
 ("e8_ml1_patch_applications", "Patch applications",
  "Office suites, browsers, email clients, PDF software and security products patched within two weeks", f"""
select hostname as resource,
  case when {i('app_patch_age_days')} <= 14 then 'ok' else 'alarm' end as status,
  'Oldest missing application patch released ' || app_patch_age_days || ' days ago (limit 14)' as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints"""),
 ("e8_ml1_patch_operating_systems", "Patch operating systems",
  "OS patched within two weeks (internet-facing) or one month (workstations, other servers)", f"""
select hostname as resource,
  case when {i('os_patch_age_days')} <= case when internet_facing::bool then 14 else 31 end then 'ok' else 'alarm' end as status,
  'OS patch age ' || os_patch_age_days || ' days (limit ' || case when internet_facing::bool then '14' else '31' end || ')' as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints"""),
 ("e8_ml1_os_supported", "Patch operating systems",
  "Operating systems that are no longer supported by vendors are replaced", f"""
select hostname as resource,
  case when os_vendor_supported::bool then 'ok' else 'alarm' end as status,
  os || case when os_vendor_supported::bool then ' is vendor supported' else ' is no longer vendor supported' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints"""),
 ("e8_ml1_multi_factor_authentication", "Multi-factor authentication",
  "MFA used to authenticate users to the organisation's online services (AWS console, Entra ID)", f"""
select user_name as resource,
  case when mfa_enabled::bool then 'ok' else 'alarm' end as status,
  case when mfa_enabled::bool then 'AWS console user has MFA' else 'AWS console user without MFA' end as reason,
  account_id as scope, 'aws' as region
from csv.aws_iam_users where console_access::bool
union all
select user_principal_name, case when mfa_registered::bool then 'ok' else 'alarm' end,
  case when mfa_registered::bool then 'Entra ID user has MFA' else 'Entra ID user without MFA' end,
  tenant, 'azure'
from csv.azure_ad_users where account_enabled::bool"""),
 ("e8_ml1_restrict_administrative_privileges", "Restrict administrative privileges",
  "Privileged user accounts are prevented from accessing the internet, email and web services", f"""
select hostname as resource,
  case when privileged_accounts_internet_blocked::bool then 'ok' else 'alarm' end as status,
  case when privileged_accounts_internet_blocked::bool then 'Privileged accounts blocked from internet/email'
       else 'Privileged accounts can reach internet/email' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints"""),
 ("e8_ml1_application_control", "Application control",
  "Application control is implemented on workstations", f"""
select hostname as resource,
  case when device_type <> 'workstation' then 'skip' when application_control_enabled::bool then 'ok' else 'alarm' end as status,
  case when device_type <> 'workstation' then 'ML1 scope is workstations only'
       when application_control_enabled::bool then 'Application control enforced' else 'No application control' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints"""),
 ("e8_ml1_restrict_microsoft_office_macros", "Restrict Microsoft Office macros",
  "Microsoft Office macros in files originating from the internet are blocked", f"""
select hostname as resource,
  case when device_type <> 'workstation' then 'skip' when macros_blocked_from_internet::bool then 'ok' else 'alarm' end as status,
  case when device_type <> 'workstation' then 'Server, no Office install'
       when macros_blocked_from_internet::bool then 'Internet macros blocked' else 'Internet macros not blocked' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints"""),
 ("e8_ml1_user_application_hardening", "User application hardening",
  "Web browsers do not process Java or web advertisements from the internet", f"""
select hostname as resource,
  case when device_type <> 'workstation' then 'skip'
       when browser_java_blocked::bool and browser_ads_blocked::bool then 'ok' else 'alarm' end as status,
  case when device_type <> 'workstation' then 'Server, no user browsing'
       else 'Java blocked: ' || browser_java_blocked || ', ads blocked: ' || browser_ads_blocked end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints"""),
 ("e8_ml1_regular_backups", "Regular backups",
  "Backups are performed and restoration is tested (org threshold: test recorded in last 12 months)", f"""
select hostname as resource,
  case when backup_enabled::bool and {i('backup_last_tested_days')} <= 365 then 'ok' else 'alarm' end as status,
  case when not backup_enabled::bool then 'No backup configured'
       else 'Restore last tested ' || backup_last_tested_days || ' days ago' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints"""),
]

# ---------- Koala Freight custom controls (org policy + Azure starter set) ----------
CUSTOM = [
 ("kf_required_tags", "KF-01", "Data stores carry owner and data-classification tags", "org", f"""
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
  subscription_id, location from csv.azure_storage_accounts"""),
 ("kf_iam_users_unused_90_days", "KF-02", "No IAM users left unused for more than 90 days", "org", f"""
select user_name as resource,
  case when least(coalesce({i('password_last_used_days')},99999), coalesce({i('access_key_last_used_days')},99999)) > 90 then 'alarm' else 'ok' end as status,
  'Most recent activity ' || least({i('password_last_used_days')}, {i('access_key_last_used_days')}) || ' days ago' as reason,
  account_id as scope, 'global' as region
from csv.aws_iam_users"""),
 ("kf_backups_tested_90_days", "KF-03", "Restores tested within the last 90 days (servers and databases)", "org", f"""
select hostname as resource, case when {i('backup_last_tested_days')} <= 90 then 'ok' else 'alarm' end as status,
  'Restore last tested ' || backup_last_tested_days || ' days ago' as reason, device_type as scope, 'on-prem' as region
from csv.endpoints where device_type = 'server'
union all
select db_instance_id, case when {i('last_restore_test_days')} <= 90 and {i('backup_retention_days')} > 0 then 'ok' else 'alarm' end,
  'Retention ' || backup_retention_days || ' days; restore last tested ' || last_restore_test_days || ' days ago', account_id, region
from csv.aws_rds_instances"""),
 ("kf_s3_encrypted_versioned", "KF-04", "S3 buckets have default encryption and versioning", "org", f"""
select bucket_name as resource, case when default_encryption::bool and versioning::bool then 'ok' else 'alarm' end as status,
  'encryption=' || default_encryption || ', versioning=' || versioning as reason, account_id as scope, region
from csv.aws_s3_buckets"""),
 ("kf_az_storage_secure", "KF-AZ-01", "Azure storage: secure transfer required and no anonymous blob access", "azure", f"""
select name as resource, case when https_only::bool and not allow_blob_public_access::bool then 'ok' else 'alarm' end as status,
  'https_only=' || https_only || ', public_blob_access=' || allow_blob_public_access as reason, subscription_id as scope, location as region
from csv.azure_storage_accounts"""),
 ("kf_az_nsg_admin_ports", "KF-AZ-02", "Azure NSGs: no inbound 22/3389 from the internet", "azure", f"""
select nsg_name || '/' || rule_name as resource,
  case when destination_port in ('22','3389') and source_prefix in ('*','0.0.0.0/0','Internet','Any') and access = 'Allow' then 'alarm' else 'ok' end as status,
  'Allow ' || source_prefix || ' to port ' || destination_port as reason, subscription_id as scope, location as region
from csv.azure_nsg_rules where direction = 'Inbound'"""),
 ("kf_az_key_vault_recoverable", "KF-AZ-03", "Azure Key Vaults: soft delete and purge protection on", "azure", f"""
select vault_name as resource, case when soft_delete_enabled::bool and purge_protection_enabled::bool then 'ok' else 'alarm' end as status,
  'soft_delete=' || soft_delete_enabled || ', purge_protection=' || purge_protection_enabled as reason, subscription_id as scope, location as region
from csv.azure_key_vaults"""),
]

def q(s):
    return s.replace('"', '\\"')

def control(name, title, desc, tags, sql):
    t = "\n".join(f'    {k} = "{v}"' for k, v in tags.items())
    return f'''control "{name}" {{
  title       = "{q(title)}"
  description = "{q(desc)}"
  sql = <<-EOQ{sql}
  EOQ
  tags = {{
{t}
  }}
}}
'''

def bench(name, title, desc, ctrls):
    children = ",\n    ".join(f"control.{c}" for c in ctrls)
    return f'''benchmark "{name}" {{
  title       = "{title}"
  description = "{desc}"
  children = [
    {children}
  ]
}}
'''

def main():
    MOD.mkdir(exist_ok=True)
    rows = []  # (framework, control_name, framework_id, sql) for the dashboard union
    out = []
    for n, cid, title, sql in CIS:
        out.append(control(n, f"{cid} {title}", f"CIS AWS Foundations Benchmark v3.0.0 recommendation {cid}.",
                           {"framework": "cis_aws_v3.0.0", "cis_item_id": cid}, sql))
        rows.append(("CIS AWS v3.0.0", n, cid, sql))
    out.append(bench("cis_aws_v300_subset", "CIS AWS Foundations Benchmark v3.0.0 (subset)",
                     "Selected CIS v3.0.0 recommendations run against the synthetic Koala Freight estate.", [c[0] for c in CIS]))
    (MOD / "cis.pp").write_text("\n".join(out))

    out = []
    for n, strat, title, sql in E8:
        out.append(control(n, f"{strat}: {title}", f"ACSC Essential Eight Maturity Model (Nov 2023), Maturity Level One, mitigation strategy '{strat}'.",
                           {"framework": "acsc_essential_eight", "e8_strategy": strat, "e8_maturity_level": "ML1"}, sql))
        rows.append(("Essential Eight ML1", n, strat, sql))
    out.append(bench("essential_eight_ml1", "ACSC Essential Eight - Maturity Level One",
                     "One or more checks for each of the eight mitigation strategies at Maturity Level One.", [c[0] for c in E8]))
    (MOD / "essential_eight.pp").write_text("\n".join(out))

    out = []
    for n, cid, title, scope, sql in CUSTOM:
        out.append(control(n, f"{cid} {title}", "Koala Freight internal policy control (synthetic).",
                           {"framework": "koala_freight_custom", "kf_control_id": cid, "cloud": "aws" if scope == "org" else "azure"}, sql))
        rows.append(("Koala Freight custom", n, cid, sql))
    out.append(bench("koala_freight_custom", "Koala Freight custom controls",
                     "Org-specific policy checks plus an Azure starter set.", [c[0] for c in CUSTOM]))
    (MOD / "custom.pp").write_text("\n".join(out))

    union = "\n  union all\n".join(
        f"  select '{fw}' as framework, '{n}' as control, '{fid}' as framework_id, r.* from ({sql}\n  ) r" for fw, n, fid, sql in rows)
    (MOD / "all_results.sql").write_text(union + "\n")
    print(f"controls: CIS={len(CIS)} E8={len(E8)} custom={len(CUSTOM)} total={len(rows)}")

if __name__ == "__main__":
    main()
