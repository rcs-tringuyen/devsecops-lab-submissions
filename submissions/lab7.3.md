# Lab 7.3 Submission

## Bonus: Conftest Policy

### Policy

```rego
package main

deny contains msg if {
  input.kind == "Deployment"
  pod_context := object.get(input.spec.template.spec, "securityContext", {})
  object.get(pod_context, "runAsNonRoot", false) != true
  msg := "Pod must set spec.securityContext.runAsNonRoot to true"
}

deny contains msg if {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  context := object.get(container, "securityContext", {})
  object.get(context, "readOnlyRootFilesystem", false) != true
  msg := sprintf("Container %q must set readOnlyRootFilesystem to true", [container.name])
}

deny contains msg if {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  context := object.get(container, "securityContext", {})
  object.get(context, "allowPrivilegeEscalation", true) != false
  msg := sprintf("Container %q must set allowPrivilegeEscalation to false", [container.name])
}

deny contains msg if {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  context := object.get(container, "securityContext", {})
  capabilities := object.get(context, "capabilities", {})
  dropped := object.get(capabilities, "drop", [])
  not "ALL" in dropped
  msg := sprintf("Container %q must drop ALL capabilities", [container.name])
}
```

### Output: PASS on hardened manifest

```text
4 tests, 4 passed, 0 warnings, 0 failures, 0 exceptions
```

### Output: FAIL on bad manifest

```text
FAIL - /tmp/bad-pod.yaml - main - Container "app" must drop ALL capabilities
FAIL - /tmp/bad-pod.yaml - main - Container "app" must set allowPrivilegeEscalation to false
FAIL - /tmp/bad-pod.yaml - main - Container "app" must set readOnlyRootFilesystem to true
FAIL - /tmp/bad-pod.yaml - main - Pod must set spec.securityContext.runAsNonRoot to true

4 tests, 0 passed, 0 warnings, 4 failures, 0 exceptions
```

### What this prevents at CI time

This policy catches insecure pod settings before `kubectl apply` runs, including root execution, writable root filesystems, privilege escalation, and retained Linux capabilities. CI gives developers feedback during a pull request, before the manifest reaches a cluster admission controller, which reduces deployment failures and shortens the time needed to fix the issue.

## Task 3: GitHub Actions Container Security Pipeline

### Workflow file

The workflow is stored at `.github/workflows/lab7-container-security.yml`. It runs Trivy image and configuration scans as informational checks and uses Conftest as the hard policy gate.

### Workflow run

- Direct link to a green workflow run: https://github.com/rcs-tringuyen/devsecops-lab-submissions/actions/runs/34137629447
- The workflow uploads `lab7-trivy-image-report`, `lab7-trivy-config-report`, and `lab7-conftest-report` artifacts.

### Triggers

The workflow runs for pushes to `main`, pull requests targeting `main`, and manual dispatches. Running on both pushes and pull requests checks proposed changes before merge and also checks the resulting main branch state.

### Job: `trivy-image`

The job checks the Juice Shop image for HIGH and CRITICAL vulnerabilities. It uses `exit-code: "0"` because the exercise image is intentionally expected to contain known vulnerabilities; the JSON report is retained for triage without blocking the workflow. The report upload uses `if: always()` so results remain available even when the scan action itself has an error.

### Job: `trivy-config`

This job scans the Kubernetes manifest files with Trivy's `config` scanner. This analyzes the files as configuration, while the local `k8s` mode inspects resources from the live Kubernetes cluster and can also assess the running workload and cluster components.

### Job: `conftest`

The job installs Conftest 0.68.0 and evaluates the Deployment against the local Rego policy. The policy result is allowed to finish so the JSON, text output, and stderr files can be uploaded. The final step checks the result and fails the job when the policy reports violations, making Conftest the hard gate.

### Reflection

The CI workflow repeats the important local checks from Labs 7.1 and 7.2 on every proposed change, while Conftest prevents the hardening requirements from being removed accidentally. Local scans are still useful for faster feedback while editing manifests and for debugging a live kind deployment before opening a pull request.
