




# CIS AWS Foundations Benchmark v3.0.0 (subset)

| | TOTAL | 88 |
|-|-|-|
| ✅ | OK | 53 |
| ⇨ | Skip | 11 |
| ℹ | Info | 0 |
| ❌ | Alarm | 24 |
| ❗ | Error | 0 |


## 1.4 Ensure no 'root' user account access key exists
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 1.4.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 1 | 0 | 0 | 1 | 0 | 2 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Root user has active access keys| `222222222222` `global`  |
| ✅ | No root access keys| `111111111111` `global`  |

## 1.5 Ensure MFA is enabled for the 'root' user account
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 1.5.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 1 | 0 | 0 | 1 | 0 | 2 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Root MFA not enabled| `222222222222` `global`  |
| ✅ | Root MFA enabled| `111111111111` `global`  |

## 1.8 Ensure IAM password policy requires minimum length of 14 or greater
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 1.8.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 1 | 0 | 0 | 1 | 0 | 2 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Minimum password length is 8| `222222222222` `global`  |
| ✅ | Minimum password length is 14| `111111111111` `global`  |

## 1.10 Ensure MFA is enabled for all IAM users that have a console password
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 1.10.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 10 | 3 | 0 | 1 | 0 | 14 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Console user without MFA| `111111111111` `global`  |
| ✅ | Console user has MFA| `222222222222` `global`  |
| ✅ | Console user has MFA| `222222222222` `global`  |
| ✅ | Console user has MFA| `111111111111` `global`  |
| ✅ | Console user has MFA| `222222222222` `global`  |
| ✅ | Console user has MFA| `111111111111` `global`  |
| ✅ | Console user has MFA| `111111111111` `global`  |
| ✅ | Console user has MFA| `222222222222` `global`  |
| ✅ | Console user has MFA| `111111111111` `global`  |
| ✅ | Console user has MFA| `222222222222` `global`  |
| ✅ | Console user has MFA| `222222222222` `global`  |
| ⇨ | No console password| `111111111111` `global`  |
| ⇨ | No console password| `222222222222` `global`  |
| ⇨ | No console password| `111111111111` `global`  |

## 1.12 Ensure credentials unused for 45 days or greater are disabled
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 1.12.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 9 | 0 | 0 | 5 | 0 | 14 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Password last used: 200 days ago; access key last used: no key| `222222222222` `global`  |
| ❌ | Password last used: 60 days ago; access key last used: no key| `111111111111` `global`  |
| ❌ | Password last used: 120 days ago; access key last used: no key| `222222222222` `global`  |
| ❌ | Password last used: no password; access key last used: 95 days ago| `222222222222` `global`  |
| ❌ | Password last used: no password; access key last used: 95 days ago| `111111111111` `global`  |
| ✅ | Password last used: 30 days ago; access key last used: no key| `222222222222` `global`  |
| ✅ | Password last used: 3 days ago; access key last used: no key| `222222222222` `global`  |
| ✅ | Password last used: 1 days ago; access key last used: 0 days ago| `111111111111` `global`  |
| ✅ | Password last used: 1 days ago; access key last used: 2 days ago| `111111111111` `global`  |
| ✅ | Password last used: 3 days ago; access key last used: no key| `111111111111` `global`  |
| ✅ | Password last used: 1 days ago; access key last used: no key| `111111111111` `global`  |
| ✅ | Password last used: 30 days ago; access key last used: 2 days ago| `222222222222` `global`  |
| ✅ | Password last used: no password; access key last used: 0 days ago| `111111111111` `global`  |
| ✅ | Password last used: 10 days ago; access key last used: no key| `222222222222` `global`  |

## 1.14 Ensure access keys are rotated every 90 days or less
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 1.14.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 1 | 8 | 0 | 5 | 0 | 14 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Oldest active key is 130 days old| `111111111111` `global`  |
| ❌ | Oldest active key is 130 days old| `111111111111` `global`  |
| ❌ | Oldest active key is 400 days old| `222222222222` `global`  |
| ❌ | Oldest active key is 400 days old| `222222222222` `global`  |
| ❌ | Oldest active key is 130 days old| `111111111111` `global`  |
| ✅ | Oldest active key is 12 days old| `111111111111` `global`  |
| ⇨ | No active access keys| `222222222222` `global`  |
| ⇨ | No active access keys| `222222222222` `global`  |
| ⇨ | No active access keys| `222222222222` `global`  |
| ⇨ | No active access keys| `111111111111` `global`  |
| ⇨ | No active access keys| `111111111111` `global`  |
| ⇨ | No active access keys| `222222222222` `global`  |
| ⇨ | No active access keys| `111111111111` `global`  |
| ⇨ | No active access keys| `222222222222` `global`  |

## 2.1.4 Ensure that S3 Buckets are configured with 'Block public access (bucket settings)'
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 2.1.4.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 7 | 0 | 0 | 1 | 0 | 8 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Block public access off| `222222222222` `ap-southeast-2`  |
| ✅ | Block public access on| `111111111111` `ap-southeast-2`  |
| ✅ | Block public access on| `111111111111` `ap-southeast-2`  |
| ✅ | Block public access on| `222222222222` `ap-southeast-2`  |
| ✅ | Block public access on| `222222222222` `ap-southeast-2`  |
| ✅ | Block public access on| `111111111111` `ap-southeast-2`  |
| ✅ | Block public access on| `222222222222` `ap-southeast-2`  |
| ✅ | Block public access on| `111111111111` `ap-southeast-2`  |

## 2.2.1 Ensure EBS Volume Encryption is Enabled in all Regions (per-volume proxy)
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 2.2.1.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 8 | 0 | 0 | 2 | 0 | 10 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Volume not encrypted| `111111111111` `ap-southeast-2`  |
| ❌ | Volume not encrypted| `111111111111` `ap-southeast-2`  |
| ✅ | Volume encrypted| `222222222222` `ap-southeast-2`  |
| ✅ | Volume encrypted| `111111111111` `ap-southeast-2`  |
| ✅ | Volume encrypted| `111111111111` `ap-southeast-2`  |
| ✅ | Volume encrypted| `222222222222` `ap-southeast-2`  |
| ✅ | Volume encrypted| `222222222222` `ap-southeast-2`  |
| ✅ | Volume encrypted| `111111111111` `ap-southeast-2`  |
| ✅ | Volume encrypted| `222222222222` `ap-southeast-2`  |
| ✅ | Volume encrypted| `222222222222` `ap-southeast-2`  |

## 2.3.1 Ensure that encryption-at-rest is enabled for RDS Instances
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 2.3.1.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 2 | 0 | 0 | 2 | 0 | 4 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Storage not encrypted| `111111111111` `ap-southeast-2`  |
| ❌ | Storage not encrypted| `222222222222` `ap-southeast-2`  |
| ✅ | Storage encrypted| `111111111111` `ap-southeast-2`  |
| ✅ | Storage encrypted| `222222222222` `ap-southeast-2`  |

## 2.3.3 Ensure that public access is not given to RDS Instance
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 2.3.3.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 3 | 0 | 0 | 1 | 0 | 4 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Instance is publicly accessible| `111111111111` `ap-southeast-2`  |
| ✅ | Not publicly accessible| `222222222222` `ap-southeast-2`  |
| ✅ | Not publicly accessible| `111111111111` `ap-southeast-2`  |
| ✅ | Not publicly accessible| `222222222222` `ap-southeast-2`  |

## 3.1 Ensure CloudTrail is enabled in all regions
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 3.1.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 2 | 0 | 0 | 0 | 0 | 2 |



| | Reason | Dimensions |
|-|--------|------------|
| ✅ | Multi-region trail logging| `222222222222` `ap-southeast-2`  |
| ✅ | Multi-region trail logging| `111111111111` `ap-southeast-2`  |

## 3.2 Ensure CloudTrail log file validation is enabled
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 3.2.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 2 | 0 | 0 | 0 | 0 | 2 |



| | Reason | Dimensions |
|-|--------|------------|
| ✅ | Log file validation on| `222222222222` `ap-southeast-2`  |
| ✅ | Log file validation on| `111111111111` `ap-southeast-2`  |

## 3.5 Ensure CloudTrail logs are encrypted at rest using KMS CMKs
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 3.5.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 1 | 0 | 0 | 1 | 0 | 2 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Not encrypted with KMS key| `222222222222` `ap-southeast-2`  |
| ✅ | Encrypted with KMS key| `111111111111` `ap-southeast-2`  |

## 5.2 Ensure no security groups allow ingress from 0.0.0.0/0 to remote server administration ports
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 5.2.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 5 | 0 | 0 | 2 | 0 | 7 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Ingress 0.0.0.0/0 to port 3389| `111111111111` `ap-southeast-2`  |
| ❌ | Ingress 0.0.0.0/0 to port 22| `111111111111` `ap-southeast-2`  |
| ✅ | Ingress 203.0.113.10/32 to port 22| `222222222222` `ap-southeast-2`  |
| ✅ | Ingress 0.0.0.0/0 to port 80| `222222222222` `ap-southeast-2`  |
| ✅ | Ingress 10.0.0.0/16 to port 8080| `222222222222` `ap-southeast-2`  |
| ✅ | Ingress 0.0.0.0/0 to port 443| `111111111111` `ap-southeast-2`  |
| ✅ | Ingress 10.0.0.0/16 to port 5432| `222222222222` `ap-southeast-2`  |

## 5.3 Ensure no security groups allow ingress from ::/0 to remote server administration ports
 
*CIS AWS Foundations Benchmark v3.0.0 recommendation 5.3.*

| OK | Skip | Info | Alarm | Error | Total |
|-|-|-|-|-|-|
| 0 | 0 | 0 | 1 | 0 | 1 |



| | Reason | Dimensions |
|-|--------|------------|
| ❌ | Ingress ::/0 to port 22| `111111111111` `ap-southeast-2`  |


\
_Report run at `2026-11-02 08:18:00` using [`Powerpipe 1.5.6`](https://powerpipe.io) in dir `koala-compliance-demo/mod`._
