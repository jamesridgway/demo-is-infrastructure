variable "region" {
  default = "eu-west-1"
  description = "The AWS reegion to use for the Short URL project."
}
variable "domain" {
  description = "The domain to use to host the project. This should already exist as a hosted zone in Route 53."
}

variable "admin_username" {
  description = "The username for the Jenkins admin account"
}
variable "admin_password" {
  description = "The password for the Jenkins admin account"
}
variable "github_token" {
  description = "A GitHub token for your jenkins account (with permissions admin:repo_hook, repo, user:email)"
}
variable "github_webhook_username" {
  description = "The username for the Jenkins user that will be used to authenticate webhook calls"
}
variable "github_webhook_password" {
  description = "The password for the Jenkins user that will be used to authenticate webhook calls"
}
variable "github_webhook_secret" {
  description = "The GitHub webhook secret that Jenkins will accept"
}
variable "github_username" {
  description = "Your github username"
}
variable "github_repos" {
  description = "A comma-separated list of GitHub repositories to automatically setup in Jenkins"
}
