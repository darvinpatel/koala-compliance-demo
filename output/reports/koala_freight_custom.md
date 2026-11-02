




# Koala Freight custom controls

| | TOTAL | 67 |
|-|-|-|
| ✅ | OK | 41 |
| ⇨ | Skip | 0 |
| ℹ | Info | 0 |
| ❌ | Alarm | 26 |
| ❗ | Error | 0 |


## KF-01 Data stores carry owner and data-classification tags
 
*Koala Freight internal policy control (synthetic).*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 18 | 0 | 0 | 8 | 0 | 26 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | owner=data, data-classification=MISSING| `111111111111` `ap-southeast-2`  |
| ❌ | owner=MISSING, data-classification=official| `222222222222` `ap-southeast-2`  |
| ❌ | owner=ops, data-classification=MISSING| `222222222222` `ap-southeast-2`  |
| ❌ | owner=MISSING, data-classification=public| `111111111111` `ap-southeast-2`  |
| ❌ | owner=ops, data-classification=MISSING| `222222222222` `ap-southeast-2`  |
| ❌ | owner=data, data-classification=MISSING| `sub-koala-dev` `australiaeast`  |
| ❌ | owner=ops, data-classification=MISSING| `sub-koala-dev` `australiaeast`  |
| ❌ | owner=MISSING, data-classification=official-sensitive| `sub-koala-corp` `australiaeast`  |
| ✅ | owner=finance, data-classification=official-sensitive| `111111111111` `ap-southeast-2`  |
| ✅ | owner=ops, data-classification=public| `222222222222` `ap-southeast-2`  |
| ✅ | owner=ops, data-classification=public| `111111111111` `ap-southeast-2`  |
| ✅ | owner=platform, data-classification=official| `222222222222` `ap-southeast-2`  |
| ✅ | owner=data, data-classification=public| `222222222222` `ap-southeast-2`  |
| ✅ | owner=finance, data-classification=official-sensitive| `111111111111` `ap-southeast-2`  |
| ✅ | owner=ops, data-classification=official-sensitive| `111111111111` `ap-southeast-2`  |
| ✅ | owner=ops, data-classification=official| `222222222222` `ap-southeast-2`  |
| ✅ | owner=data, data-classification=official| `111111111111` `ap-southeast-2`  |
| ✅ | owner=finance, data-classification=official| `111111111111` `ap-southeast-2`  |
| ✅ | owner=data, data-classification=official| `111111111111` `ap-southeast-2`  |
| ✅ | owner=data, data-classification=official| `222222222222` `ap-southeast-2`  |
| ✅ | owner=data, data-classification=official-sensitive| `222222222222` `ap-southeast-2`  |
| ✅ | owner=ops, data-classification=official-sensitive| `111111111111` `ap-southeast-2`  |
| ✅ | owner=platform, data-classification=official-sensitive| `222222222222` `ap-southeast-2`  |
| ✅ | owner=data, data-classification=official| `111111111111` `ap-southeast-2`  |
| ✅ | owner=data, data-classification=official| `222222222222` `ap-southeast-2`  |
| ✅ | owner=ops, data-classification=official-sensitive| `sub-koala-corp` `australiaeast`  |

## KF-02 No IAM users left unused for more than 90 days
 
*Koala Freight internal policy control (synthetic).*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 10 | 0 | 0 | 4 | 0 | 14 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Most recent activity 200 days ago| `222222222222` `global`  |
| ❌ | Most recent activity 120 days ago| `222222222222` `global`  |
| ❌ | Most recent activity 95 days ago| `222222222222` `global`  |
| ❌ | Most recent activity 95 days ago| `111111111111` `global`  |
| ✅ | Most recent activity 30 days ago| `222222222222` `global`  |
| ✅ | Most recent activity 3 days ago| `222222222222` `global`  |
| ✅ | Most recent activity 0 days ago| `111111111111` `global`  |
| ✅ | Most recent activity 1 days ago| `111111111111` `global`  |
| ✅ | Most recent activity 3 days ago| `111111111111` `global`  |
| ✅ | Most recent activity 60 days ago| `111111111111` `global`  |
| ✅ | Most recent activity 1 days ago| `111111111111` `global`  |
| ✅ | Most recent activity 2 days ago| `222222222222` `global`  |
| ✅ | Most recent activity 0 days ago| `111111111111` `global`  |
| ✅ | Most recent activity 10 days ago| `222222222222` `global`  |

## KF-03 Restores tested within the last 90 days (servers and databases)
 
*Koala Freight internal policy control (synthetic).*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 4 | 0 | 0 | 4 | 0 | 8 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Restore last tested 120 days ago| `server` `on-prem`  |
| ❌ | Restore last tested 300 days ago| `server` `on-prem`  |
| ❌ | Retention 35 days; restore last tested 150 days ago| `111111111111` `ap-southeast-2`  |
| ❌ | Retention 0 days; restore last tested 60 days ago| `222222222222` `ap-southeast-2`  |
| ✅ | Restore last tested 10 days ago| `server` `on-prem`  |
| ✅ | Restore last tested 45 days ago| `server` `on-prem`  |
| ✅ | Retention 35 days; restore last tested 60 days ago| `111111111111` `ap-southeast-2`  |
| ✅ | Retention 35 days; restore last tested 20 days ago| `222222222222` `ap-southeast-2`  |

## KF-04 S3 buckets have default encryption and versioning
 
*Koala Freight internal policy control (synthetic).*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 4 | 0 | 0 | 4 | 0 | 8 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | encryption=true, versioning=false| `111111111111` `ap-southeast-2`  |
| ❌ | encryption=true, versioning=false| `111111111111` `ap-southeast-2`  |
| ❌ | encryption=true, versioning=false| `222222222222` `ap-southeast-2`  |
| ❌ | encryption=true, versioning=false| `111111111111` `ap-southeast-2`  |
| ✅ | encryption=true, versioning=true| `222222222222` `ap-southeast-2`  |
| ✅ | encryption=true, versioning=true| `222222222222` `ap-southeast-2`  |
| ✅ | encryption=true, versioning=true| `222222222222` `ap-southeast-2`  |
| ✅ | encryption=true, versioning=true| `111111111111` `ap-southeast-2`  |

## KF-AZ-01 Azure storage: secure transfer required and no anonymous blob access
 
*Koala Freight internal policy control (synthetic).*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 2 | 0 | 0 | 2 | 0 | 4 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | https_only=false, public_blob_access=false| `sub-koala-dev` `australiaeast`  |
| ❌ | https_only=true, public_blob_access=true| `sub-koala-corp` `australiaeast`  |
| ✅ | https_only=true, public_blob_access=false| `sub-koala-dev` `australiaeast`  |
| ✅ | https_only=true, public_blob_access=false| `sub-koala-corp` `australiaeast`  |

## KF-AZ-02 Azure NSGs: no inbound 22/3389 from the internet
 
*Koala Freight internal policy control (synthetic).*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 2 | 0 | 0 | 2 | 0 | 4 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Allow 0.0.0.0/0 to port 22| `sub-koala-corp` `australiaeast`  |
| ❌ | Allow Internet to port 3389| `sub-koala-dev` `australiaeast`  |
| ✅ | Allow 10.20.0.0/16 to port 22| `sub-koala-dev` `australiaeast`  |
| ✅ | Allow * to port 443| `sub-koala-corp` `australiaeast`  |

## KF-AZ-03 Azure Key Vaults: soft delete and purge protection on
 
*Koala Freight internal policy control (synthetic).*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 1 | 0 | 0 | 2 | 0 | 3 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | soft_delete=true, purge_protection=false| `sub-koala-corp` `australiaeast`  |
| ❌ | soft_delete=false, purge_protection=false| `sub-koala-dev` `australiaeast`  |
| ✅ | soft_delete=true, purge_protection=true| `sub-koala-corp` `australiaeast`  |


\
_Report run at `2026-11-02 08:18:00` using [`Powerpipe 1.5.6`](https://powerpipe.io) in dir `koala-compliance-demo/mod`._
