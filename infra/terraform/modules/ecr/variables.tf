variable "project" {
  description = "Project name; repos are named <project>-<repo>."
  type        = string
}

variable "repositories" {
  description = "ECR repository short names to create (named <project>-<repo>). This lab builds a single application image, but the module stays generic via list + for_each for reuse."
  type        = list(string)
  default     = ["app"]
}

variable "max_image_count" {
  description = "How many tagged images to retain per repo."
  type        = number
  default     = 15
}
