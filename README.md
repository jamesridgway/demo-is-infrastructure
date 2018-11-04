# Immutable Servers Infrastucture Demo Repository

This repository is designed to be used alongside [demo-is-vm-images](https://github.com/jamesridgway/demo-is-vm-images) and [demo-salt](https://github.com/jamesridgway/demo-salt).

These repositories demonstrates setting up a pipeline for building immutable servers, including:
* How to **build AMIs using packer** (incorporating existing config management via SaltStack)
* Create immutable **infrastructure with terraform**
* Fully automating Jenkins to:
  * run on **spot instances**
  * **automate the installation** using groovy scripts
  * automatically **create jobs for GitHub repositories**
  * spawn jenkins **slaves as spot instances**


## Getting started
Follow the steps below to setup the entire pipeline including initial AMI images, and Jenkins build pipeline.

1. Clone `demo-is-vm-images`:

   ```
   git clone https://github.com/jamesridgway/demo-is-vm-images.git
   ```
2. Build all of the packer images using:

   ```
   ./build-all.sh
   ```
   This needs to be run manually to initialise your AWS account with the AMIs. Once you've done this the Jenkins setup produced by the remaining steps can be used to produce new AMI images.
   
3. Clone `demo-is-infrastructure`:

   ```
   git clone https://github.com/jamesridgway/demo-is-infrastructure.git
   ```
   
4. Create a `terraform.tfvars` (see `varaibles.tf` for a description of each varibale).

   E.g.
   ```
   domain = "demo.james-ridgway.co.uk"
   admin_username = "james"
   admin_password = "********"
   github_token = "********"
   github_webhook_username = "github"
   github_webhook_password = "********"
   github_webhook_secret = "********"
   github_username = "jamesridgway"
   github_repos = "demo-salt,demo-is-vm-images,demo-is-infrastructure"
   ```
   *Note that `*.tfvars` files are gitignored.*
   
5. Create the infrastructure

   ```
   terraform apply
   ```
