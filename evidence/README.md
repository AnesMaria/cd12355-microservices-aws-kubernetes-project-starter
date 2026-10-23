# Udacity submission evidence

This folder documents evidence from the AWS EKS coworking project, collected on **October 23, 2026**.

## CloudWatch Container Insights screenshots

The following three original screenshots have been prepared for upload to this folder:

| Filename | What the screenshot demonstrates |
| --- | --- |
| `cloudwatch-01-log-groups.png` | Existing CodeBuild and EKS Container Insights log groups |
| `cloudwatch-02-application-log-group.png` | The `/aws/containerinsights/coworking-eks/application` log group |
| `cloudwatch-03-flask-log-events.png` | Timestamped Flask `INFO in app` events and requests collected in CloudWatch |

**Image upload status:** PNG files must be uploaded separately to this folder; this page alone is not a substitute for screenshots.

## Kubernetes screenshots to capture

- `kubectl get pods`
- `kubectl get svc`
- `kubectl describe deployment coworking`
- `kubectl describe svc postgresql-service`
- `kubectl get pvc` showing `postgresql-pvc` as `Bound` at `5Gi`

## AWS console screenshots to capture

- Amazon ECR `coworking` image list showing published tags
- AWS CodeBuild `coworking-codebuild` build history showing `SUCCEEDED` builds
- CloudWatch Container Insights Flask log stream showing periodic `INFO in app` and `HTTP 200` responses

**Known limitation:** CodeBuild executions succeeded when launched manually; the GitHub webhook trigger remains unverified because the training IAM identity was denied the required GitHub connection authorization.

Do not upload Kubernetes Secrets, AWS credentials, IAM trust-policy files, or database backups as evidence.
