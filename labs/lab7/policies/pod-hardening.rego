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
