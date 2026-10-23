# Coworking Space Service — AWS DevOps Implementation

## Overview

I deployed a Flask analytics API and PostgreSQL database to Amazon EKS using Docker, AWS CodeBuild, Amazon ECR, and Kubernetes.
The application image is `810716384126.dkr.ecr.us-east-1.amazonaws.com/coworking:1.0.2`.
The system exposes the Flask API through a Kubernetes LoadBalancer on port `5153` and keeps PostgreSQL internal on port `5432`.

## Build and deployment

The source repository is hosted on GitHub, and successful AWS CodeBuild builds have produced versioned images published to Amazon ECR.
**Builds were started manually because GitHub webhook authentication could not be configured with the permissions available in the AWS training environment, so an automatic GitHub-to-CodeBuild trigger has not been demonstrated.**
The Flask and PostgreSQL workloads are managed as separate Kubernetes Deployments and Services.
Non-sensitive database settings come from a ConfigMap, while the password is referenced from a Kubernetes Secret and is not committed to this repository.
PostgreSQL uses a `5Gi` persistent volume claim backed by the Amazon EBS CSI driver with gp3 storage.
The Flask deployment defines CPU and memory requests and limits as well as liveness and readiness probes.

## Validation

Both workloads were verified as `1/1 Running`, and the PostgreSQL persistent volume claim was `Bound`.
The `/health_check`, `/readiness_check`, `/api/reports/daily_usage`, and `/api/reports/user_visits` endpoints returned HTTP 200 during testing.
Amazon CloudWatch Container Insights collects application logs in `/aws/containerinsights/coworking-eks/application`, including HTTP 200 health checks and periodic `INFO in app` entries.
See the [screenshout folder](screenshout/README.md) for 12 uploaded screenshots covering Kubernetes, CloudWatch, Amazon ECR, and successful CodeBuild builds; the CodeBuild ECR-push log screenshot and automatic GitHub trigger remain outstanding.


aws eks update-kubeconfig --region us-east-1 --name coworking-eks
kubectl get pods
kubectl get svc
kubectl get pvc
kubectl describe deployment coworking
kubectl describe svc postgresql-service

<!-- GitHub webhook test -->
## Engineering decisions and cost

The demonstration runs on a `t3.medium` worker node with resource limits to keep the workload small.
EKS, EC2, EBS, CloudWatch, and the LoadBalancer may incur AWS charges until the environment is cleaned up.
For a production release I would add automatic CI triggering, automated tests, and infrastructure as code once the required permissions are available.
