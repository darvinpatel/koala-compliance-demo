control "e8_ml1_patch_applications" {
  title       = "Patch applications: Office suites, browsers, email clients, PDF software and security products patched within two weeks"
  description = "ACSC Essential Eight Maturity Model (Nov 2023), Maturity Level One, mitigation strategy 'Patch applications'."
  sql = <<-EOQ
select hostname as resource,
  case when nullif(app_patch_age_days,'')::int <= 14 then 'ok' else 'alarm' end as status,
  'Oldest missing application patch released ' || app_patch_age_days || ' days ago (limit 14)' as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  EOQ
  tags = {
    framework = "acsc_essential_eight"
    e8_strategy = "Patch applications"
    e8_maturity_level = "ML1"
  }
}

control "e8_ml1_patch_operating_systems" {
  title       = "Patch operating systems: OS patched within two weeks (internet-facing) or one month (workstations, other servers)"
  description = "ACSC Essential Eight Maturity Model (Nov 2023), Maturity Level One, mitigation strategy 'Patch operating systems'."
  sql = <<-EOQ
select hostname as resource,
  case when nullif(os_patch_age_days,'')::int <= case when internet_facing::bool then 14 else 31 end then 'ok' else 'alarm' end as status,
  'OS patch age ' || os_patch_age_days || ' days (limit ' || case when internet_facing::bool then '14' else '31' end || ')' as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  EOQ
  tags = {
    framework = "acsc_essential_eight"
    e8_strategy = "Patch operating systems"
    e8_maturity_level = "ML1"
  }
}

control "e8_ml1_os_supported" {
  title       = "Patch operating systems: Operating systems that are no longer supported by vendors are replaced"
  description = "ACSC Essential Eight Maturity Model (Nov 2023), Maturity Level One, mitigation strategy 'Patch operating systems'."
  sql = <<-EOQ
select hostname as resource,
  case when os_vendor_supported::bool then 'ok' else 'alarm' end as status,
  os || case when os_vendor_supported::bool then ' is vendor supported' else ' is no longer vendor supported' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  EOQ
  tags = {
    framework = "acsc_essential_eight"
    e8_strategy = "Patch operating systems"
    e8_maturity_level = "ML1"
  }
}

control "e8_ml1_multi_factor_authentication" {
  title       = "Multi-factor authentication: MFA used to authenticate users to the organisation's online services (AWS console, Entra ID)"
  description = "ACSC Essential Eight Maturity Model (Nov 2023), Maturity Level One, mitigation strategy 'Multi-factor authentication'."
  sql = <<-EOQ
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
  EOQ
  tags = {
    framework = "acsc_essential_eight"
    e8_strategy = "Multi-factor authentication"
    e8_maturity_level = "ML1"
  }
}

control "e8_ml1_restrict_administrative_privileges" {
  title       = "Restrict administrative privileges: Privileged user accounts are prevented from accessing the internet, email and web services"
  description = "ACSC Essential Eight Maturity Model (Nov 2023), Maturity Level One, mitigation strategy 'Restrict administrative privileges'."
  sql = <<-EOQ
select hostname as resource,
  case when privileged_accounts_internet_blocked::bool then 'ok' else 'alarm' end as status,
  case when privileged_accounts_internet_blocked::bool then 'Privileged accounts blocked from internet/email'
       else 'Privileged accounts can reach internet/email' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  EOQ
  tags = {
    framework = "acsc_essential_eight"
    e8_strategy = "Restrict administrative privileges"
    e8_maturity_level = "ML1"
  }
}

control "e8_ml1_application_control" {
  title       = "Application control: Application control is implemented on workstations"
  description = "ACSC Essential Eight Maturity Model (Nov 2023), Maturity Level One, mitigation strategy 'Application control'."
  sql = <<-EOQ
select hostname as resource,
  case when device_type <> 'workstation' then 'skip' when application_control_enabled::bool then 'ok' else 'alarm' end as status,
  case when device_type <> 'workstation' then 'ML1 scope is workstations only'
       when application_control_enabled::bool then 'Application control enforced' else 'No application control' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  EOQ
  tags = {
    framework = "acsc_essential_eight"
    e8_strategy = "Application control"
    e8_maturity_level = "ML1"
  }
}

control "e8_ml1_restrict_microsoft_office_macros" {
  title       = "Restrict Microsoft Office macros: Microsoft Office macros in files originating from the internet are blocked"
  description = "ACSC Essential Eight Maturity Model (Nov 2023), Maturity Level One, mitigation strategy 'Restrict Microsoft Office macros'."
  sql = <<-EOQ
select hostname as resource,
  case when device_type <> 'workstation' then 'skip' when macros_blocked_from_internet::bool then 'ok' else 'alarm' end as status,
  case when device_type <> 'workstation' then 'Server, no Office install'
       when macros_blocked_from_internet::bool then 'Internet macros blocked' else 'Internet macros not blocked' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  EOQ
  tags = {
    framework = "acsc_essential_eight"
    e8_strategy = "Restrict Microsoft Office macros"
    e8_maturity_level = "ML1"
  }
}

control "e8_ml1_user_application_hardening" {
  title       = "User application hardening: Web browsers do not process Java or web advertisements from the internet"
  description = "ACSC Essential Eight Maturity Model (Nov 2023), Maturity Level One, mitigation strategy 'User application hardening'."
  sql = <<-EOQ
select hostname as resource,
  case when device_type <> 'workstation' then 'skip'
       when browser_java_blocked::bool and browser_ads_blocked::bool then 'ok' else 'alarm' end as status,
  case when device_type <> 'workstation' then 'Server, no user browsing'
       else 'Java blocked: ' || browser_java_blocked || ', ads blocked: ' || browser_ads_blocked end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  EOQ
  tags = {
    framework = "acsc_essential_eight"
    e8_strategy = "User application hardening"
    e8_maturity_level = "ML1"
  }
}

control "e8_ml1_regular_backups" {
  title       = "Regular backups: Backups are performed and restoration is tested (org threshold: test recorded in last 12 months)"
  description = "ACSC Essential Eight Maturity Model (Nov 2023), Maturity Level One, mitigation strategy 'Regular backups'."
  sql = <<-EOQ
select hostname as resource,
  case when backup_enabled::bool and nullif(backup_last_tested_days,'')::int <= 365 then 'ok' else 'alarm' end as status,
  case when not backup_enabled::bool then 'No backup configured'
       else 'Restore last tested ' || backup_last_tested_days || ' days ago' end as reason,
  device_type as scope, 'on-prem' as region
from csv.endpoints
  EOQ
  tags = {
    framework = "acsc_essential_eight"
    e8_strategy = "Regular backups"
    e8_maturity_level = "ML1"
  }
}

benchmark "essential_eight_ml1" {
  title       = "ACSC Essential Eight - Maturity Level One"
  description = "One or more checks for each of the eight mitigation strategies at Maturity Level One."
  children = [
    control.e8_ml1_patch_applications,
    control.e8_ml1_patch_operating_systems,
    control.e8_ml1_os_supported,
    control.e8_ml1_multi_factor_authentication,
    control.e8_ml1_restrict_administrative_privileges,
    control.e8_ml1_application_control,
    control.e8_ml1_restrict_microsoft_office_macros,
    control.e8_ml1_user_application_hardening,
    control.e8_ml1_regular_backups
  ]
}
