# Screenshout — Udacity project screenshots

This folder holds the screenshots supporting the submitted AWS EKS project, together with a checklist of rubric evidence still needed for a resubmission.

## CloudWatch — screenshots already uploaded

1. [CloudWatch log groups](cloudwatch-01-log-groups.png) — CodeBuild and Container Insights log groups.
2. [EKS application log group](cloudwatch-02-application-log-group.png) — `/aws/containerinsights/coworking-eks/application`.
3. [Flask log events](cloudwatch-03-flask-log-events.png) — timestamps and recurring Flask application events.

## Kubernetes — original terminal screenshots needed

The reviewer specifically requires **screenshots** showing the outputs of all four commands below, not only YAML files or copied terminal text:

```bash
kubectl get pods
kubectl get svc
kubectl describe deployment coworking
kubectl describe svc postgresql-service
```

Additional useful evidence is `kubectl get pvc` displaying the `postgresql-pvc` claim as `Bound` with `5Gi` capacity.

Suggested filenames: `kubernetes-01-pods.png`, `kubernetes-02-services.png`, `kubernetes-03-coworking-deployment.png`, `kubernetes-04-postgresql-service.png`, and `kubernetes-05-pvc.png`.

**Do not recreate terminal screenshots from text and present them as genuine historical captures.** If the EKS cluster was deleted, reuse original screenshots if available or redeploy a working environment to capture new ones.

## AWS ECR and CodeBuild — screenshots needed

- `ecr-01-images.png`: ECR repository `coworking` showing pushed image tags, such as `1.0.2`.
- `codebuild-01-success.png`: actual AWS CodeBuild run with `SUCCEEDED` status and evidence the image was pushed to ECR.
- `codebuild-02-github-trigger.png`: **only if achieved**, a build explicitly identified as initiated automatically by a GitHub push/webhook.

### Known limitation

Previous CodeBuild builds succeeded **manually**. The Udacity requirement specifically asks for an **automatic GitHub-triggered** build, which has not yet been demonstrated due to denied permissions for GitHub connection/webhook authorization in the AWS training account. A successful manual run is not equivalent to an automatic trigger. If the lab still denies the connection, document the limitation honestly and seek permission or an accepted alternative rather than mislabeling a manual build.

## Submission safety and cost

Do not upload Kubernetes Secret values, AWS credentials, IAM policies that expose sensitive setup, or PostgreSQL database dumps. If rebuilding resources for screenshots, verify that the evaluator can view them before cleaning up EKS, EC2, EBS, and Load Balancer resources to avoid ongoing AWS charges.
