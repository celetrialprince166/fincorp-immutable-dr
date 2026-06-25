variable "project" {
  description = "Project name; used to prefix repo Name tags and as the default domain name."
  type        = string
  default     = "fincorp"
}

variable "domain_name" {
  description = "CodeArtifact domain name. Defaults to the project name."
  type        = string
  default     = null
}
