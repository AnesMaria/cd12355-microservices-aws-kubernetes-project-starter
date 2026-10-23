# Udacity evidence — Coworking Space Service

This folder contains **12 original screenshots** of the AWS environment, plus the Kubernetes verification transcript.

## Kubernetes — 4 screenshots uploaded

1. [Both pods 1/1 Running](kubernetes-01-pods-running.png) — `kubectl get pods`.
2. [Kubernetes services](kubernetes-02-services.png) — `kubectl get svc`.
3. [Flask deployment and ECR image 1.0.2](kubernetes-03-coworking-deployment.png) — `kubectl describe deployment coworking`.
4. [PostgreSQL service, port 5432 and active endpoint](kubernetes-04-postgresql-service.png) — `kubectl describe svc postgresql-service`.

The [real CloudShell validation transcript](kubernetes-verification-2026-10-23.md) also records the 5Gi `Bound` PostgreSQL PVC and four successful HTTP API tests.

## Amazon ECR — 3 screenshots uploaded

1. [ECR repository](ecr-00-repository.png).
2. [Image tags 1.0.1 and 1.0.2](ecr-01-images.png).
3. [Image 1.0.2, digest, URI and active status](ecr-02-image-details.png).

## AWS CodeBuild — 2 screenshots uploaded

1. [CodeBuild project with successful status](codebuild-00-project.png).
2. [Two successful build executions](codebuild-01-success-history.png).

**Outstanding proof:** screenshot of build `POST_BUILD` logs displaying `docker push` to ECR and `Image published successfully`.

**Unresolved Udacity requirement:** the reviewer requests a build **automatically initiated by a GitHub push**. Existing successful CodeBuild runs were started manually. AWS training account denied `codeconnections:ListConnections` and `codeconnections:StartOAuthHandshake`. Do not misrepresent a manual build as GitHub-triggered.

## Amazon CloudWatch — 3 screenshots uploaded

1. [CloudWatch log groups](cloudwatch-01-log-groups.png).
2. [EKS application log group](cloudwatch-02-application-log-group.png).
3. [Flask application log events](cloudwatch-03-flask-log-events.png).

## Security and costs

Never commit secrets, credentials or database dumps. Stop paid EKS, EC2, EBS and LoadBalancer resources once all evidence is safely saved.
