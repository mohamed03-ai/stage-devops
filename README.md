# <Project Name>

> Short one-line description of what this application does.

This repository contains the application source code, the AWS infrastructure (Terraform), and the Kubernetes deployment configuration (Helm) for `<Project Name>`, deployed on **AWS EKS**.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Deployment Guide](#deployment-guide)
  - [1. Infrastructure (Terraform)](#1-infrastructure-terraform)
  - [2. Application (Helm)](#2-application-helm)
- [Configuration / Environment Variables](#configuration--environment-variables)
- [Verifying the Deployment](#verifying-the-deployment)
- [Troubleshooting](#troubleshooting)
- [Rollback / Cleanup](#rollback--cleanup)
- [Maintainers](#maintainers)

---

## Architecture Overview

The diagram below illustrates the overall AWS/EKS architecture used to deploy `<Project Name>`.

![Architecture Diagram](docs/architecture.png)

<!--
Place your architecture diagram image inside a `docs/` folder at the root of the repo,
and update the path above if needed (e.g., docs/architecture.png).
-->

**Summary of the flow:**

1. **Terraform** provisions the core AWS infrastructure: VPC, subnets (public/private), security groups, IAM roles, and the EKS cluster with its node group(s).
2. Once the cluster is created, **kubectl**/**Helm** are configured to communicate with it.
3. **Helm** deploys the application (`<Project Name>`) onto the EKS cluster as Kubernetes resources (Deployments, Services, Ingress, ConfigMaps/Secrets, etc.).
4. External traffic reaches the application through `<Load Balancer / Ingress Controller — e.g., AWS ALB Ingress Controller / NGINX Ingress>`.
5. `<Mention any additional AWS services used, e.g., RDS, S3, ECR, CloudWatch, Secrets Manager>`.

---

## Repository Structure

```
.
├── app/                # Application source code and Dockerfile
├── terraform/           # Infrastructure as Code (VPC, EKS, IAM, networking, etc.)
│   ├── modules/          # Reusable Terraform modules (if any)
│   ├── env/              # Environment-specific variable files (dev, staging, prod)
│   └── main.tf
├── helm/                # Helm chart(s) for deploying the app to EKS
│   ├── templates/
│   ├── values.yaml
│   └── Chart.yaml
├── docs/                 # Documentation assets (architecture diagram, etc.)
└── README.md
```

| Folder | Purpose |
|---|---|
| `app/` | Contains the application source code and the `Dockerfile` used to build the container image. |
| `terraform/` | Defines and provisions all AWS infrastructure required to run the application (networking, EKS cluster, IAM, etc.). |
| `helm/` | Contains the Helm chart used to deploy and configure the application on the EKS cluster. |

---

## Prerequisites

Make sure the following tools are installed and configured before deploying:

| Tool | Minimum Version | Purpose |
|---|---|---|
| [AWS CLI](https://docs.aws.amazon.com/cli/) | `>= <version>` | AWS authentication and resource access |
| [Terraform](https://developer.hashicorp.com/terraform) | `>= <version>` | Infrastructure provisioning |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | `>= <version>` | Interacting with the EKS cluster |
| [Helm](https://helm.sh/) | `>= <version>` | Deploying the application to Kubernetes |
| [Docker](https://www.docker.com/) | `>= <version>` | Building the application image (if applicable) |

**AWS Access:**
- An AWS account with permissions to create VPCs, EKS clusters, IAM roles, and related resources.
- AWS credentials configured locally:
  ```bash
  aws configure --profile <profile-name>
  ```

---

## Deployment Guide

### 1. Infrastructure (Terraform)

```bash
cd terraform/

# Initialize Terraform and download providers/modules
terraform init

# Review the execution plan
terraform plan -var-file="env/<environment>.tfvars"

# Apply the infrastructure changes
terraform apply -var-file="env/<environment>.tfvars"
```

**Required variables** (see `terraform/env/<environment>.tfvars`):

| Variable | Description | Example |
|---|---|---|
| `<var_name>` | `<description>` | `<example_value>` |
| `<var_name>` | `<description>` | `<example_value>` |

Once the EKS cluster is created, update your local kubeconfig to connect `kubectl`/`helm` to it:

```bash
aws eks update-kubeconfig --name <cluster-name> --region <aws-region> --profile <profile-name>
```

Verify the connection:

```bash
kubectl get nodes
```

### 2. Application (Helm)

```bash
cd helm/

# Optional: lint the chart before deploying
helm lint ./<chart-folder>

helm upgrade --install <release-name> ./<chart-folder> \
  --namespace <namespace> \
  --create-namespace \
  -f values.yaml
```

**Key values to review/override in `values.yaml`:**

| Key | Description | Default |
|---|---|---|
| `image.repository` | Container image location (e.g., ECR URL) | `<value>` |
| `image.tag` | Image version to deploy | `<value>` |
| `replicaCount` | Number of pod replicas | `<value>` |
| `resources` | CPU/memory requests and limits | `<value>` |
| `ingress.enabled` | Enable/disable Ingress | `<value>` |

---

## Configuration / Environment Variables

The application relies on the following configuration, injected via Kubernetes Secrets/ConfigMaps:

| Variable | Description | Source |
|---|---|---|
| `<ENV_VAR_NAME>` | `<description>` | K8s Secret / ConfigMap / AWS Secrets Manager |
| `<ENV_VAR_NAME>` | `<description>` | K8s Secret / ConfigMap / AWS Secrets Manager |

> Never commit secrets or `.tfvars` files containing sensitive values to the repository.

---

## Verifying the Deployment

Check that the pods, services, and ingress are running correctly:

```bash
kubectl get pods -n <namespace>
kubectl get svc -n <namespace>
kubectl get ingress -n <namespace>
```

Access the application:

```bash
# Example: port-forward for local testing
kubectl port-forward svc/<service-name> 8080:80 -n <namespace>
```

Then open: `http://localhost:8080`

Or, if exposed via Ingress/Load Balancer:

```bash
kubectl get ingress <ingress-name> -n <namespace>
```

and access the app via the returned DNS/URL.

---

## Troubleshooting

Common issues encountered during infrastructure provisioning and application deployment.

| Problem | Possible Cause | Suggested Fix |
|---|---|---|
| `terraform apply` fails during EKS creation | Insufficient IAM permissions | Ensure the IAM user/role has `eks:CreateCluster`, `eks:*`, and related EC2/VPC permissions |
| `terraform init` fails to fetch backend/state | Remote state (e.g., S3/DynamoDB) not configured or inaccessible | Verify backend configuration in `terraform/main.tf` and bucket/table permissions |
| Pods stuck in `Pending` | Insufficient node capacity or scheduling constraints | Check `kubectl describe pod <pod>`; scale node group or adjust resource requests |
| Pods in `CrashLoopBackOff` | Application error, missing env vars/secrets, misconfigured probe | Check logs: `kubectl logs <pod> -n <namespace>` |
| `helm upgrade` fails | Invalid values or chart syntax error | Run `helm lint ./<chart-folder>` and validate `values.yaml` |
| `kubectl` cannot connect to the cluster | kubeconfig not updated / expired credentials | Re-run `aws eks update-kubeconfig ...`; check `aws sts get-caller-identity` |
| Ingress/ALB not routing traffic | Ingress controller not installed or misconfigured | Verify the Ingress Controller is deployed and check its logs |
| Image pull errors (`ImagePullBackOff`) | Wrong image tag/repository or missing registry credentials | Verify `image.repository`/`image.tag` in `values.yaml` and ECR/registry access |

---

## Rollback / Cleanup

**Roll back a Helm release:**
```bash
helm rollback <release-name> <revision-number> -n <namespace>
```

**Uninstall the application:**
```bash
helm uninstall <release-name> -n <namespace>
```

**Destroy the infrastructure (use with caution):**
```bash
cd terraform/
terraform destroy -var-file="env/<environment>.tfvars"
```

---

## Maintainers

| Name | Role | Contact |
|---|---|---|
| `<Name>` | `<Role>` | `<email>` |

_Last updated: <date>_
