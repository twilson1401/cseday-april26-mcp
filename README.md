# Confluent MCP Server Setup - CSE Day April 26

This repository provides a streamlined way to provision Confluent Cloud resources using Terraform and connect them to a Model Context Protocol (MCP) server. By following these steps, you will set up a Confluent Cloud environment (Environment, Cluster, Topics) and configure an MCP server to interact with it.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed.
- A [Confluent Cloud](https://confluent.cloud/) account.
- [Node.js and npm](https://docs.npmjs.com/) installed (for the MCP server).

---

## Getting Started

### 1. Generate Confluent Cloud API Keys
Before running Terraform, you need credentials with sufficient permissions to manage resources:

1. Log in to the [Confluent Cloud Console](https://confluent.cloud/).

2. Navigate to **API Keys** (under the Cloud Console side menu).

3. Create a **Resource Management** API Key.

4. Download or save the **API Key** and **Secret** immediately; you won't be able to see the secret again.


### 2. Configure Terraform Variables

1. Locate the `terraform.tfvars.example` file.

2. Rename it to `terraform.tfvars`.

3. Open the file and enter your Confluent Cloud API Key and Secret:
   ```hcl
   confluent_cloud_api_key    = "YOUR_KEY_HERE"
   confluent_cloud_api_secret = "YOUR_SECRET_HERE"
   ```
4. **(Recommended)** Customize your resource names: Change the environment or cluster name variables in the Terraform script to something unique to avoid naming clashes with other users.


### 3. Provision Infrastructure
Run the following commands to create your Confluent Cloud resources:

```bash
terraform init
terraform plan
terraform apply
```
> **Note:** Due to the propagation time of cloud resources, you may encounter a minor error during the first run. If the process fails or doesn't create all resources, simply run `terraform apply` a second time.


### 4. Configure Environment Variables
Once Terraform finishes, it will output several values (like Bootstrap Servers, API Keys, etc.).

1. Locate the `.env.example` file.

2. Rename it to `.env`. If it doesn't exist, create a new .env file and use this file to help you populate it: https://github.com/confluentinc/mcp-confluent/blob/main/.env.example

3. Plug the **Terraform outputs** into the corresponding fields in the `.env` file. You might need to run the following to obtain the sensitive outputs:
   ```bash
   terraform output -json
   ```
   Please note that this script does not create Tableflow API Keys: this is out of scope for this demo, so you can remove from the .env file.

4. Add the **Resource Management API Key and Secret** you generated in Step 1 to this file as well.



### 5. MCP Server Setup
With your infrastructure live and your `.env` file configured, you can now set up the MCP server to interface with LLMs (like Claude).

Follow the detailed instructions in the official Confluent MCP repository:
[Confluent MCP Server Setup Guide](https://github.com/confluentinc/mcp-confluent/blob/main/README.md)

---

## Project Structure
- `/terraform`: Contains the HCL files to provision Confluent Cloud environments, clusters, and credentials.
- `.env.example`: Template for the environment variables required by the MCP server.
- `terraform.tfvars.example`: Template for Confluent Cloud authentication variables.
