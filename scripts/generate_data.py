#!/usr/bin/env python3
"""Generate a SYNTHETIC cloud + endpoint estate for the fictional 'Koala Freight Pty Ltd'.

Nothing here comes from a real cloud account. Table names mimic AWS/Azure naming
so the controls read naturally, but these are plain CSVs read by the Steampipe csv plugin.
Ages are whole days relative to the fixed snapshot date below, so output is reproducible.
"""
import csv, random
from pathlib import Path

SEED = 20261101
SNAPSHOT_DATE = "2026-11-01"
OUT = Path(__file__).resolve().parent.parent / "data"
rng = random.Random(SEED)

ACCOUNTS = [("111111111111", "koala-prod"), ("222222222222", "koala-nonprod")]
SUBS = ["sub-koala-corp", "sub-koala-dev"]
OWNERS = ["ops", "data", "platform", "finance", "ops", "data", ""]
CLASSES = ["official", "official-sensitive", "public", "official", "official-sensitive", ""]
B = lambda p: "true" if rng.random() < p else "false"


def write(name, rows):
    OUT.mkdir(exist_ok=True)
    with open(OUT / f"{name}.csv", "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"{name}: {len(rows)} rows")


def aws_account_settings():
    return [
        dict(account_id="111111111111", account_name="koala-prod", snapshot_date=SNAPSHOT_DATE,
             root_mfa_enabled="true", root_access_keys_present="false",
             password_min_length="14", password_reuse_prevention="24"),
        dict(account_id="222222222222", account_name="koala-nonprod", snapshot_date=SNAPSHOT_DATE,
             root_mfa_enabled="false", root_access_keys_present="true",
             password_min_length="8", password_reuse_prevention="0"),
    ]


def aws_iam_users():
    names = ["alice.ng", "ben.okafor", "chloe.martin", "dev.singh", "emma.wright", "finn.oconnor",
             "grace.li", "harry.taylor", "isla.brown", "jack.wilson", "svc-backup", "svc-ci-deploy",
             "svc-reporting", "kate.nguyen"]
    rows = []
    for i, n in enumerate(names):
        svc = n.startswith("svc-")
        keys = rng.choice([1, 1, 2]) if svc else rng.choice([0, 0, 1])
        rows.append(dict(
            account_id=ACCOUNTS[i % 2][0], user_name=n,
            console_access="false" if svc else "true",
            mfa_enabled="false" if svc else B(0.75),
            active_access_keys=str(keys),
            oldest_access_key_age_days=str(rng.choice([12, 40, 75, 130, 400])) if keys else "",
            password_last_used_days="" if svc else str(rng.choice([1, 3, 10, 30, 60, 120, 200])),
            access_key_last_used_days=str(rng.choice([0, 2, 20, 95, 180])) if keys else "",
            is_admin=B(0.25),
        ))
    return rows


def aws_s3_buckets():
    names = ["koala-freight-manifests", "koala-customer-portal-assets", "koala-cloudtrail-logs",
             "koala-data-lake-raw", "koala-finance-exports", "koala-website-static", "koala-tmp-uploads",
             "koala-backups-prod"]
    rows = []
    for i, n in enumerate(names):
        rows.append(dict(account_id=ACCOUNTS[i % 2][0], bucket_name=n, region="ap-southeast-2",
                         block_public_access=B(0.7), default_encryption=B(0.85), versioning=B(0.6),
                         access_logging=B(0.5), tag_owner=rng.choice(OWNERS),
                         tag_data_classification=rng.choice(CLASSES)))
    return rows


def aws_cloudtrail():
    return [
        dict(account_id="111111111111", trail_name="org-trail", home_region="ap-southeast-2",
             is_multi_region="true", is_logging="true", log_file_validation="true", kms_encrypted="true"),
        dict(account_id="222222222222", trail_name="nonprod-trail", home_region="ap-southeast-2",
             is_multi_region="true", is_logging="true", log_file_validation="true", kms_encrypted="false"),
    ]


def aws_security_group_rules():
    rows = []
    specs = [("sg-0a01", "web-alb", 443, "0.0.0.0/0"), ("sg-0a01", "web-alb", 80, "0.0.0.0/0"),
             ("sg-0b02", "bastion", 22, "0.0.0.0/0"), ("sg-0c03", "app-tier", 8080, "10.0.0.0/16"),
             ("sg-0d04", "win-jump", 3389, "0.0.0.0/0"), ("sg-0e05", "db-tier", 5432, "10.0.0.0/16"),
             ("sg-0f06", "legacy-ftp", 22, "::/0"), ("sg-0g07", "ops-vpn", 22, "203.0.113.10/32")]
    for i, (gid, gname, port, cidr) in enumerate(specs):
        rows.append(dict(account_id=ACCOUNTS[i % 2][0], region="ap-southeast-2", group_id=gid,
                         group_name=gname, direction="ingress", protocol="tcp",
                         from_port=str(port), to_port=str(port), cidr=cidr))
    return rows


def aws_ebs_volumes():
    return [dict(account_id=ACCOUNTS[i % 2][0], region="ap-southeast-2", volume_id=f"vol-0{i:03d}k",
                 size_gb=str(rng.choice([20, 50, 100, 500])), encrypted=B(0.75),
                 tag_owner=rng.choice(OWNERS), tag_data_classification=rng.choice(CLASSES))
            for i in range(10)]


def aws_rds_instances():
    names = ["freight-core-db", "customer-portal-db", "reporting-replica", "dev-sandbox-db"]
    return [dict(account_id=ACCOUNTS[i % 2][0], region="ap-southeast-2", db_instance_id=n,
                 engine=rng.choice(["postgres", "mysql"]), storage_encrypted=B(0.7),
                 publicly_accessible=B(0.25), backup_retention_days=str(rng.choice([0, 7, 14, 35])),
                 last_restore_test_days=str(rng.choice([20, 60, 150, 400])),
                 tag_owner=rng.choice(OWNERS), tag_data_classification=rng.choice(CLASSES))
            for i, n in enumerate(names)]


def endpoints():
    rows = []
    for i in range(16):
        server = i >= 12
        rows.append(dict(
            hostname=(f"KF-SRV-{i:02d}" if server else f"KF-LT-{i:03d}"),
            device_type="server" if server else "workstation",
            internet_facing="true" if server and i % 2 == 0 else "false",
            os=rng.choice(["Windows Server 2022", "Windows Server 2012 R2"]) if server
            else rng.choice(["Windows 11 23H2", "Windows 11 23H2", "Windows 10 22H2", "macOS 14"]),
            os_vendor_supported="true",
            os_patch_age_days=str(rng.choice([3, 9, 13, 20, 35, 60])),
            app_patch_age_days=str(rng.choice([2, 6, 12, 18, 45])),
            application_control_enabled=B(0.7),
            macros_blocked_from_internet=B(0.8),
            browser_java_blocked=B(0.9), browser_ads_blocked=B(0.75),
            privileged_accounts_internet_blocked=B(0.7),
            local_admin_users=str(rng.choice([0, 0, 1, 2])),
            backup_enabled=B(0.85),
            backup_last_tested_days=str(rng.choice([10, 45, 80, 120, 300, 500])),
        ))
    for r in rows:
        if r["os"] == "Windows Server 2012 R2":
            r["os_vendor_supported"] = "false"
    return rows


def azure_storage_accounts():
    specs = [("kfcorpdocs", "false", "true"), ("kfdevscratch", "false", "false"),
             ("kfpublicsite", "true", "true"), ("kfarchive", "false", "true")]
    return [dict(subscription_id=SUBS[i % 2], resource_group="rg-koala", name=n, location="australiaeast",
                 allow_blob_public_access=pub, https_only=https, minimum_tls_version="TLS1_2",
                 tag_owner=rng.choice(OWNERS), tag_data_classification=rng.choice(CLASSES))
            for i, (n, pub, https) in enumerate(specs)]


def azure_nsg_rules():
    specs = [("nsg-web", "allow-https", 443, "*"), ("nsg-jump", "allow-rdp", 3389, "Internet"),
             ("nsg-dev", "allow-ssh", 22, "0.0.0.0/0"), ("nsg-app", "allow-ssh-vpn", 22, "10.20.0.0/16")]
    return [dict(subscription_id=SUBS[i % 2], location="australiaeast", nsg_name=n, rule_name=r,
                 direction="Inbound", access="Allow", protocol="Tcp", destination_port=str(p), source_prefix=s)
            for i, (n, r, p, s) in enumerate(specs)]


def azure_key_vaults():
    return [dict(subscription_id=SUBS[i % 2], location="australiaeast", vault_name=n,
                 soft_delete_enabled=sd, purge_protection_enabled=pp)
            for i, (n, sd, pp) in enumerate([("kv-koala-prod", "true", "true"), ("kv-koala-dev", "false", "false"),
                                              ("kv-koala-ci", "true", "false")])]


def azure_ad_users():
    names = ["alice.ng", "ben.okafor", "grace.li", "kate.nguyen", "admin.breakglass", "contractor.temp"]
    return [dict(tenant="koalafreight.onmicrosoft.com", user_principal_name=f"{n}@koalafreight.example",
                 account_enabled="true", mfa_registered=B(0.7), is_privileged=B(0.3),
                 last_sign_in_days=str(rng.choice([1, 5, 30, 100])))
            for n in names]


if __name__ == "__main__":
    for fn in [aws_account_settings, aws_iam_users, aws_s3_buckets, aws_cloudtrail, aws_security_group_rules,
               aws_ebs_volumes, aws_rds_instances, endpoints, azure_storage_accounts, azure_nsg_rules,
               azure_key_vaults, azure_ad_users]:
        write(fn.__name__, fn())
