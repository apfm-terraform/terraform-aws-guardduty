##################################################
# GuardDuty Organizations Delegated Admin
##################################################
variable "guardduty_detector_id" {
  description = "The detector ID of the GuardDuty account."
  type        = string
}

variable "enable_s3_protection" {
  description = "Configure and enable S3 protection. Defaults to `true`."
  type        = bool
  default     = true
}

variable "enable_kubernetes_protection" {
  description = "Configure and enable Kubernetes audit logs as a data source for Kubernetes protection. Defaults to `true`."
  type        = bool
  default     = true
}

variable "enable_malware_protection" {
  description = "Configure and enable Malware Protection as data source for EC2 instances with findings for the detector. Defaults to `true`."
  type        = bool
  default     = true
}

variable "admin_account_id" {
  description = "AWS Organizations Admin Account Id. Defaults to `null`"
  type        = string
  default     = null
}

variable "auto_enable_org_config" {
  description = "When this setting is enabled, all new accounts that are created in, or added to, the organization are added as a member accounts of the organization’s GuardDuty delegated administrator and GuardDuty is enabled in that AWS Region."
  type        = bool
  default     = null
}

variable "auto_enable_organization_members" {
  description = "Indicates the auto-enablement configuration of GuardDuty for the member accounts in the organization. Valid values are `ALL`, `NEW`, `NONE`. Defaults to `NEW`."
  type        = string
  default     = "NEW"
}

variable "organization_configuration_features" {
  description = "Enable new organization GuardDuty protections only available as features"
  type = map(object({
    auto_enable = string
    additional_configuration = map(object({
      auto_enable = string
    }))
  }))
  validation {
    condition     = alltrue([for k in var.organization_configuration_features : contains(["S3_DATA_EVENTS", "EKS_AUDIT_LOGS", "EBS_MALWARE_PROTECTION", "RDS_LOGIN_EVENTS", "EKS_RUNTIME_MONITORING", "LAMBDA_NETWORK_LOGS", "RUNTIME_MONITORING"], k)])
    error_message = "The organization_configuration_features key must be one of: S3_DATA_EVENTS, EKS_AUDIT_LOGS, EBS_MALWARE_PROTECTION, RDS_LOGIN_EVENTS, EKS_RUNTIME_MONITORING, LAMBDA_NETWORK_LOGS, RUNTIME_MONITORING."
  }
  validation {
    condition     = alltrue([for k, v in var.organization_configuration_features : contains(["ALL", "NONE", "NEW"], v.auto_enable)])
    error_message = "The auto_enable value must be one of: ALL, NONE, NEW."
  }
  validation {
    condition     = alltrue([for k, v in var.organization_configuration_features : [for a in v.additional_configuration : contains(["EKS_ADDON_MANAGEMENT", "ECS_FARGATE_AGENT_MANAGEMENT", "EC2_AGENT_MANAGEMENT"], a)]])
    error_message = "The additional_configuration key must be one of: EKS_ADDON_MANAGEMENT, ECS_FARGATE_AGENT_MANAGEMENT, EC2_AGENT_MANAGEMENT."
  }
  validation {
    condition     = alltrue([for k, v in var.organization_configuration_features : [for ak, av in v.additional_configuration : contains(["ALL", "NONE", "NEW"], av.auto_enable)]])
    error_message = "The auto_enable value must be one of: ALL, NONE, NEW."
  }
  default = {}
}
