# Coworking Space Service — AWS DevOps Implementation

## Overview

This project deploys a Flask analytics API and a PostgreSQL database to Amazon EKS using Docker, AWS CodeBuild, Amazon ECR, and Kubernetes. The application deployment was verified using `810716384126.dkr.ecr.us-east-1.amazonaws.com/coworking:1.0.2`, exposed via a Kubernetes LoadBalancer on port `5153`. PostgreSQL remains internal on port `5432`.

## CI/CD pipeline: GitHub → CodeBuild → Amazon ECR

The `main` branch is connected to AWS CodeBuild through a GitHub push webhook. The build instructions in [buildspec.yml](buildspec.yml) authenticate to ECR, build `analytics/`, tag each image as `1.0.$CODEBUILD_BUILD_NUMBER`, and push the image to the `coworking` ECR repository.

**Automatic triggering is verified.** In the AWS CodeBuild history, runs **#4 and #5** completed successfully and displayed `GitHub-Hookshot/256f04d` as the initiator (unlike earlier manually started runs). Run **#5** published image **`1.0.5`**. Its logs show Docker layers `Pushed`, an image digest, `Image published successfully`, and `POST_BUILD State: SUCCEEDED`.

The existing Kubernetes deployment uses the previously validated image `1.0.2`; publishing `1.0.5` demonstrates the image CI pipeline, **not** an automatic deployment update to EKS.

## Kubernetes deployment

The deployed application and database use separate Deployments and Services:
- [Flask deployment](deployment/coworking-deployment.yaml) and [LoadBalancer Service](deployment/coworking-service.yaml)
- [PostgreSQL deployment](deployment/postgresql-deployment.yaml) and [ClusterIP Service](deployment/postgresql-service.yaml)
- [Database ConfigMap](deployment/db-configmap.yaml), an external Kubernetes Secret for the password, and a persistent `5Gi` PostgreSQL volume on EBS gp3

The `deployment/coworking.yaml` and `deployment/configmap.yaml` files are **original starter templates containing placeholders**, not the manifests used for the demonstrated deployment. Never apply these placeholder files directly.

The Flask deployment specifies CPU/memory requests and limits, and liveness/readiness probes.

## Verified results

Both workloads were observed at `1/1 Running`; the PostgreSQL persistent volume claim was `Bound`. The `/health_check`, `/readiness_check`, `/api/reports/daily_usage`, and `/api/reports/user_visits` endpoints returned HTTP 200. CloudWatch Container Insights recorded Flask application log events.

The [submission evidence index](screenshout/README.md) links Kubernetes, ECR, CodeBuild, and CloudWatch evidence. [Kubernetes verification transcript](screenshout/kubernetes-verification-2026-10-23.md) provides supplementary command output, not substitutes for screenshots.

### Useful validation commands

```bash
aws eks update-kubeconfig --region us-east-1 --name coworking-eks
kubectl get pods
kubectl get svc
kubectl get pvc
kubectl describe deployment coworking
kubectl describe svc postgresql-service
```

## Engineering notes and costs

This demonstration uses a `t3.medium` worker node. A production implementation would add automated tests, infrastructure-as-code validation, deployment-stage approvals, and stronger monitoring. EKS, EC2, EBS, CloudWatch, and the LoadBalancer may incur charges until cleaned up after the required evidence is saved.
