# Lab 7.2 Submission

## Task 2: Kubernetes Hardening

### Manifests

`namespace.yaml` PSS labels:

```yaml
pod-security.kubernetes.io/enforce: restricted
pod-security.kubernetes.io/warn: restricted
pod-security.kubernetes.io/audit: restricted
```

`deployment.yaml` pod security context:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault
```

`deployment.yaml` container security context:

```yaml
securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL
```

The Deployment uses the dedicated `juice-shop-sa` service account and sets `automountServiceAccountToken: false`. The image is pinned to `bkimminich/juice-shop@sha256:fd58bdc9745416afce8184ee0666278a436574633ea7880365153a63bfd418b0`.

`networkpolicy.yaml` ingress and egress:

```yaml
policyTypes:
  - Ingress
  - Egress
ingress:
  - from:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: ingress-nginx
    ports:
      - protocol: TCP
        port: 3000
egress:
  - to:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: kube-system
        podSelector:
          matchLabels:
            k8s-app: kube-dns
    ports:
      - protocol: UDP
        port: 53
  - ports:
      - protocol: TCP
        port: 443
```

Localhost access was tested through `kubectl port-forward`. Port-forward traffic is handled by the Kubernetes API and does not require a NetworkPolicy ingress rule from a pod namespace.

### Pod is running

```text
NAME                          READY   STATUS    RESTARTS   AGE
juice-shop-7bd758c7cf-8llfh   1/1     Running   0          2m23s
```

### Trivy K8s scan

Trivy version: `0.69.3`

| Severity | Count |
|----------|------:|
| Critical | 20 |
| High | 126 |

The counts include vulnerabilities and secrets reported for the Juice Shop workload by Trivy's Kubernetes scan. The deployment itself did not produce a critical or high misconfiguration finding in the summary.

### What broke and how it was fixed

With `readOnlyRootFilesystem: true`, Juice Shop initially failed because startup writes to application data, FTP files, generated frontend assets, translated files, logs, and `.well-known` files. I kept the root filesystem read-only and used an `emptyDir` mounted at `/tmp` plus a writable application `emptyDir` at `/juice-shop`; a hardened init container copies the image's application files into that volume before the main container starts.

