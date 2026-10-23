# Coworking Space Service — My AWS DevOps Implementation

## Project Overview

I designed and deployed a cloud-native analytics service using Docker, AWS CodeBuild, Amazon ECR, Amazon EKS, Flask, and PostgreSQL.

My approach focuses on deployment automation, reproducibility, application reliability, and efficient cloud resource management.

## Architecture and CI/CD

The workflow connects GitHub source control, AWS CodeBuild, Docker image creation, Amazon ECR publishing, and Kubernetes deployment.

I use semantic image versioning to improve release traceability and simplify deployment updates.

The validated application image is `810716384126.dkr.ecr.us-east-1.amazonaws.com/coworking:1.0.2`, produced by a successful CodeBuild execution.

## Kubernetes Deployment

I organized the Flask application and PostgreSQL database into independent Kubernetes Deployments and Services.

I configured non-sensitive application settings through ConfigMaps and database credentials through Kubernetes Secrets.

Health and readiness probes allow Kubernetes to verify application availability and database connectivity.

The deployment also defines CPU and memory limits to help control resource consumption.

## Deployment and Validation

To connect to the cluster and inspect the application:

```bash
aws eks update-kubeconfig --region us-east-1 --name coworking-eks
kubectl get nodes
kubectl get pods
kubectl get svc
kubectl describe svc postgresql-service
kubectl describe deployment coworking
```

The deployment verification confirmed that both application workloads were running with one available replica.

The `/health_check` and `/readiness_check` endpoints both returned HTTP 200.

## Release Management

To release an updated version, I commit the changes, run the CodeBuild process, verify the ECR image, update the image reference in the Kubernetes manifest, and validate the new rollout.

Build logs are available in AWS CloudWatch, while Kubernetes logs support application-level troubleshooting.

## My Engineering Decisions

I selected `t3.medium` for this demonstration to balance workload requirements and cloud costs.

My cost optimization approach emphasizes reusable Docker images, controlled resource allocation, and cleanup of unnecessary AWS resources.

I would further strengthen the architecture through persistent storage validation, automated testing, centralized application monitoring, and infrastructure as code.
