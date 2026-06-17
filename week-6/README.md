# Week_6 Notes

## Terraform

Terraform is an infrastructure as code tool that lets you define both cloud and on-prem resources in human-readable configuration files that you can version, reuse, and share.

Note: Any infrastructure that can be created using terraforn is called a **resource**.

### Workflow
The core Terraform workflow consists of three stages:

**Write**: You define resources, which may be across multiple cloud providers and services. For example, you might create a configuration to deploy an application on virtual machines in a Virtual Private Cloud (VPC) network with security groups and a load balancer.
**Plan**: Terraform creates an execution plan describing the infrastructure it will create, update, or destroy based on the existing infrastructure and your configuration.
**Apply**: On approval, Terraform performs the proposed operations in the correct order, respecting any resource dependencies.

Write → Init → Plan → Apply → Destroy

## What terraform init Does

When you run init:
Terraform:

Initializes working directory
Downloads providers/plugins
Creates .terraform/ folder
Prepares backend if configured

# Important Files/Folders After Init
**.terraform/** --> Contains provider plugins/modules.

**.terraform.lock.hcl**
-->Dependency lock file.
-->Tracks exact provider versions.

### Features

1.Manage any infrastructure : Has a lot of the platforms and services that are already in use.

2.Track your infrastructure : keeps track of your real infrastructure in a state file. Terraform uses the state file to determine the changes to make to your infrastructure so that it will match your configuration.

3.Automate changes : No step-by-step needed, only needs the end configuration of the infrastructure.Standardize configurations

4.Terraform supports reusable configuration components called modules that define configurable collections of infrastructure, saving time and encouraging best practices. 

### Teraform language - used to create a teraform configuration (*tf)

#### Syntax
<BLOCK TYPE> "<BLOCK LABEL>" "<BLOCK LABEL>" {
  //Block body
  <IDENTIFIER> = <EXPRESSION> //Argument
}

Explanation:
1.Blocks are containers for other content and usually represent the configuration of some kind of object, like a resource.
Blocks have a block type, can have zero or more labels, and have a body that contains any number of arguments and nested blocks.
Most of Terraform's features are controlled by top-level blocks in a configuration file.

2.Expressions represent a value, either literally or by referencing and combining other values. 

Example:
resource "local_file" "example" {
  filename = "test.txt"
  content  = "Hello"
}

| Part               | Meaning             |
| ------------------ | ------------------- |
| `resource`         | Block type          |
| `local_file`       | Resource type       |
| `example`          | Local resource name |
| `{}`               | Block body          |
| `filename/content` | Arguments           |

Comments - # (primary) but // and /* */ also supported but not recommeded.

### Components
1️.Terraform Core

Main engine that:
**Reads** configuration
**Creates** execution plan
**Applies** changes

2️.Providers

Plugins that interact with platforms.

Examples:
AWS provider
Azure provider
Docker provider
Local provider (for Linux commands)

Example:
provider "local" {}

3. Resources

Actual infrastructure objects.

Example:
resource "local_file" "example" {}

### Providers

Terraform relies on **plugins** called providers to interact with cloud providers, SaaS providers, and other APIs.

Terraform configurations must declare which providers they require so that Terraform can install and use them. Additionally, some providers require configuration (like endpoint URLs or cloud regions) before they can be used.

## File names

1.A **backend.tf** file that contains your backend configuration. You can define multiple terraform blocks in your configuration to separate your backend configuration from your Terraform and provider versioning configuration.

2.A **main.tf** file that contains all resource and data source blocks.

3.A **outputs.tf** file that contains all output blocks in alphabetical order.

4.A **providers.tf** file that contains all provider blocks and configuration.

5.A **terraform.tf** file that contains a single terraform block which defines your required_version and required_providers.

6.A **variables.tf** file that contains all variable blocks in alphabetical order.

7.A **locals.tf** file that contains local values. Refer to local values for more information

8.A **network.tf** file that contains your VPC, subnets, load balancers, and all other networking resources.

9.A **storage.tf** file that contains your object storage and related permissions configuration.

10.A **compute.tf** file that contains your compute instances.


### Blocks

| Block     | Purpose                 |
| --------- | ----------------------- |
| terraform | Terraform settings      |
| provider  | Provider configuration  |
| resource  | Infrastructure objects  |
| data      | Read existing resources |
| variable  | Input variables         |
| output    | Output values           |
| locals    | Local reusable values   |
| module    | Reusable module call    |


## 1. Cloud Overview

This section builds the foundation for Cloud Computing + Terraform (IaC).

Learning Objectives
Understand cloud fundamentals
Compare traditional vs cloud infrastructure
Learn service & deployment models
Learn state, backend, and real-world usage

Key Insight:
Terraform is powerful only when you understand the infrastructure it manages.

## 2. Cloud Fundamentals
2.1 What is Cloud Computing?

Cloud computing = on-demand delivery of computing resources over the internet.

Includes:

Compute (VMs)
Storage
Networking
Databases

2.2 Traditional vs Cloud
Traditional	Cloud
Upfront hardware cost	Pay-as-you-go
Manual setup	Automated
Slow scaling	Instant scaling
Maintenance heavy	Managed services

### 2.3 Why Cloud?
Problems (On-Prem)
Slow hardware provisioning
Over/under provisioning
High maintenance

### Benefits (Cloud)
Elastic scaling
High availability
Global access
Cost efficiency

### 2.4 Cloud Service Models
Model	Responsibility
IaaS	You manage OS & apps
PaaS	You manage apps only
SaaS	Fully managed

### 2.5 Deployment Models
Public Cloud
Private Cloud
Hybrid Cloud
Multi-Cloud


### 2.6 Key Characteristics
On-demand self-service
Broad network access
Resource pooling
Rapid elasticity
Pay-per-use

### 2.7 Pricing Models
Pay-as-you-go
Reserved instances
Spot instances


### 2.8 Latency

Latency = time taken for data transfer

Reduce latency by:

Deploying near users
Using CDNs (edge locations)


### 2.9 Disaster Recovery
Strategy	Cost	Speed
Backup & Restore	Low	Slow
Pilot Light	Medium	Medium
Warm Standby	High	Fast
Active-Active	Very High	Very Fast


### 2.10 Cloud Architecture
User → Edge → Region → AZ → Server

3. Terraform Fundamentals
3.1 What is Terraform?

Terraform = Infrastructure as Code (IaC) tool by HashiCorp.

Used to:

Define infrastructure in code
Automate provisioning
Ensure consistency

### 3.2 Why Terraform?

Without Terraform:

Manual setup
Errors & inconsistency

With Terraform:

Version control
Reusable configs
Automated infra

### 3.3 IaC Example
resource "aws_instance" "example" {
  ami           = "ami-123456"
  instance_type = "t2.micro"
}

### 3.4 Terraform vs Others

Tool	Type
Terraform	Declarative
Ansible	Procedural
CloudFormation	AWS-specific

### 3.5 Declarative Nature

You define what, Terraform handles how.

## 4. Terraform Architecture

**Components**

Core
Reads config
Creates execution plan
Providers
API interaction (AWS, Azure, etc.)
State
Tracks infrastructure
Key Concepts
Resource → Any infrastructure object
Provider → Plugin for APIs
State → Current infra snapshot

## 5. Terraform Workflow
Write → Init → Plan → Apply → Destroy
Steps
Write
Define resources

**Init**

terraform init
Downloads providers
Creates .terraform/

**Plan**

terraform plan
Preview changes

**Apply**

terraform apply
Execute changes

**Destroy**

terraform destroy


## 6. Terraform Configuration Basics

**Syntax**

<BLOCK_TYPE> "<TYPE>" "<NAME>" {
  key = value
}

**Example**

resource "local_file" "example" {
  filename = "test.txt"
  content  = "Hello"
}

**Common Blocks**

Block	Purpose

terraform	Settings
provider	Cloud config
resource	Infra
data	Read infra
variable	Inputs
output	Results
locals	Reusable values
module	Reusable configs

## 7. Important Files

main.tf → Resources
variables.tf → Inputs
outputs.tf → Outputs
providers.tf → Providers
backend.tf → Backend config

## 8. Terraform State (Critical)
What is State?

File: terraform.tfstate

Stores:

Resource IDs
Metadata
Dependencies

### Why State?
Tracks infrastructure
Prevents duplication
Enables change detection
Desired vs Current

Type	Source
Desired	.tf
Current	.tfstate
State Workflow
Config → State → Diff → Plan → Apply → Updated State

### State Commands
terraform state list
terraform state show <resource>
terraform show


## 9. Backend (Important)
What is Backend?

Defines:

Where state is stored
How it's accessed


### Types
Local (default)
Remote (S3, etc.)

S3 Backend Example
terraform {
  backend "s3" {
    bucket = "my-bucket"
    key    = "dev/terraform.tfstate"
    region = "ap-south-1"
  }
}

Why Remote Backend?
Team collaboration
State locking
Security


## 10. Provisioners (Advanced)
### Types
Type	Usage
local-exec	Run local commands
remote-exec	Run on remote

Example
resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo Hello > file.txt"
  }
}

**Note**: Warning
Not idempotent
Use only when necessary


## 11. AWS + Terraform
EC2 Basics
AMI → OS
Instance Type → CPU/RAM
Key Pair → SSH
Security Group → Firewall


### Ways to Create Infra
**Method	Type**

Console	Manual
CLI	Script
Terraform	IaC

Terraform EC2 **Example**
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "dev" {
  ami           = "ami-xxxx"
  instance_type = "t2.micro"
}

## 12. AWS CLI Basics
**aws configure**
aws ec2 describe-instances
aws sts get-caller-identity

## 13. Best Practices

**Always run:**

terraform fmt
terraform validate
terraform plan

**Never commit:**

.terraform/
terraform.tfstate
Use:
IAM users (not root)

**Naming convention:**

project-env-resource
Use remote backend for teams