# Lab 7.1 Submission

## Task 1: Trivy Image and Config Scan

### Image scan severity breakdown

Command used:

```bash
trivy image bkimminich/juice-shop:v20.0.0 \
  --severity HIGH,CRITICAL \
  --format json --output labs/lab7/results/trivy-image.json
```

Trivy version: `0.69.3`

| Severity | Total | With fix available |
|----------|------:|-------------------:|
| Critical | 10 | 8 |
| High | 61 | 60 |
| **Total** | **71** | **68** |

The sample Dockerfile configuration scan reported one high-severity finding, `DS-0002`, because the last `USER` instruction was `root`.

### Top 10 CVEs with fixes

| CVE | Severity | Package | Installed | Fix |
|-----|----------|---------|-----------|-----|
| CVE-2023-46233 | CRITICAL | crypto-js | 3.3.0 | 4.2.0 |
| CVE-2026-71851 | CRITICAL | crypto-js | 3.3.0 | 4.0.0 |
| CVE-2015-9235 | CRITICAL | jsonwebtoken | 0.1.0 | 4.2.2 |
| CVE-2015-9235 | CRITICAL | jsonwebtoken | 0.4.0 | 4.2.2 |
| CVE-2019-10744 | CRITICAL | lodash | 2.4.2 | 4.17.12 |
| CVE-2026-59873 | CRITICAL | tar | 4.4.19 | 7.5.19 |
| CVE-2026-59873 | CRITICAL | tar | 6.2.1 | 7.5.19 |
| CVE-2026-59873 | CRITICAL | tar | 7.5.15 | 7.5.19 |
| CVE-2026-14456 | HIGH | libssl3t64 | 3.5.5-1~deb13u2 | 3.5.7-1~deb13u2 |
| CVE-2026-45447 | HIGH | libssl3t64 | 3.5.5-1~deb13u2 | 3.5.6-1~deb13u2 |

### Compared to the Grype scan

The submissions repository did not contain the earlier Lab 4 Grype JSON report, so I ran Grype 0.118.0 against the same `bkimminich/juice-shop:v20.0.0` image for this comparison. The current Grype scan reported 14 critical and 81 high findings, while the Trivy scan reported 10 critical and 61 high findings. The databases and scan dates were not identical to the original Lab 4 run, so the comparison is approximate.

`CVE-2026-14456` was found by both tools in `libssl3t64` version `3.5.5-1~deb13u2`. Both scanners map this package to the same vulnerability and report a fixed version in the 3.5.7 Debian update, which shows agreement when package matching and database records line up.

`CVE-2026-45447` was found by Trivy, while the Grype run used a different set of records for the same Debian package and did not report that CVE. The difference can come from vulnerability database freshness, vendor severity mapping, and the way each scanner matches Debian package versions to vulnerability advisories. This is why scanner output should be treated as complementary rather than as an exact count of all vulnerabilities.

