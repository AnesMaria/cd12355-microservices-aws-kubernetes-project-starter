# Udacity submission evidence — Coworking Space Service

This index groups **original screenshots** by the reviewer requirement. The Kubernetes transcript is supplemental text and must not be represented as a screenshot.

## 1. Kubernetes — application and database

| Requirement | Screenshot |
| --- | --- |
| Both pods 1/1 Running — `kubectl get pods` | [kubernetes-01-pods-running.png](kubernetes-01-pods-running.png) |
| Both Kubernetes services — `kubectl get svc` | [kubernetes-02-services.png](kubernetes-02-services.png) |
| App deployment details — `kubectl describe deployment coworking` | [kubernetes-03-coworking-deployment.png](kubernetes-03-coworking-deployment.png) |
| Internal database service — `kubectl describe svc postgresql-service` | [kubernetes-04-postgresql-service.png](kubernetes-04-postgresql-service.png) |

[Supplementary command transcript](kubernetes-verification-2026-10-23.md) records the Bound 5Gi PVC, active workloads, and successful API health/report checks.

## 2. Amazon ECR — container image

| Requirement | Screenshot |
| --- | --- |
| ECR repository exists | [ecr-00-repository.png](ecr-00-repository.png) |
| Image tags in ECR | [ecr-01-images.png](ecr-01-images.png) |
| ECR image URI and digest | [ecr-02-image-details.png](ecr-02-image-details.png) |
| **Automatically triggered CodeBuild #5 pushed image `1.0.5` to ECR**: `Pushed`, `Image published successfully`, `POST_BUILD SUCCEEDED` | [codebuild-05-ecr-push-success.png](codebuild-05-ecr-push-success.png) |

The earlier ECR screenshots document image `1.0.2`; CodeBuild #5 log proves a later `1.0.5` image push. These are different images, not contradictory results.

## 3. AWS CodeBuild — GitHub-triggered CI

| Requirement | Screenshot |
| --- | --- |
| AWS CodeBuild project with successful result | [codebuild-00-project.png](codebuild-00-project.png) |
| Build #5 successful Docker push and post-build | [codebuild-05-ecr-push-success.png](codebuild-05-ecr-push-success.png) |
| **Builds #4 and #5 show GitHub-Hookshot initiator and SUCCEEDED status** | **[Screenshot of the automatic-build history still needs to be uploaded](https://github.com/AnesMaria/cd12355-microservices-aws-kubernetes-project-starter/tree/main/screenshout)** as `codebuild-04-05-github-triggered.png` |

The AWS CodeBuild UI showed automatic builds #4 and #5 as successful, and build #3 as a failed earlier GitHub-triggered attempt. For a concise reviewer evidence set, the successful #4/#5 screenshot is sufficient; older manual build-history evidence has been removed from this index.

## 4. Amazon CloudWatch — centralized logging

| Requirement | Screenshot |
| --- | --- |
| CloudWatch log groups | [cloudwatch-01-log-groups.png](cloudwatch-01-log-groups.png) |
| EKS application log group | [cloudwatch-02-application-log-group.png](cloudwatch-02-application-log-group.png) |
| Flask application log events | [cloudwatch-03-flask-log-events.png](cloudwatch-03-flask-log-events.png) |

## Reviewer notes

The build pipeline automates GitHub push → CodeBuild → ECR push. The demonstrated running EKS deployment is `1.0.2`; no automatic EKS rollout is claimed. No secrets or credentials should be committed to this repository. Remove paid AWS resources when proof is safely preserved.
