# Coworking Space Service — Cloud-Native DevOps Implementation

## 1. Project Overview

This project demonstrates my implementation of a cloud-native deployment workflow for a coworking space analytics application using AWS, Docker, and Kubernetes.

My main objective was to develop a reliable, reproducible, and maintainable delivery process that connects application development with cloud infrastructure operations.

Rather than focusing only on containerization, I approached the project from an end-to-end DevOps perspective, emphasizing **automation, deployment reliability, scalability, security, and operational efficiency**.

The application consists of a Flask-based analytics API connected to a PostgreSQL database. It provides reporting endpoints for coworking space activity, including daily usage and user visits.

## 2. Architecture and My Design Decisions

I designed the deployment workflow around the following technologies:

| Component | Technology | Purpose |
|---|---|---|
| Source control | GitHub | Version management and collaboration |
| Containerization | Docker | Consistent application packaging |
| Build automation | AWS CodeBuild | Automated Docker image builds |
| Container registry | Amazon ECR | Versioned image storage |
| Container orchestration | Amazon EKS | Kubernetes application deployment |
| Backend | Python Flask | Analytics REST API |
| Database | PostgreSQL | Data storage and analytics |
| Monitoring | CloudWatch and Kubernetes logs | Build monitoring and operational diagnostics |

**My architectural priority was to separate the application lifecycle from the underlying infrastructure lifecycle.**

This separation allows application images to be reused across deployments, reducing unnecessary rebuilds and improving release consistency.

## 3. My CI/CD Strategy

I implemented an automated container build workflow using AWS CodeBuild and Amazon ECR.

The process follows these main stages:

**Source Code → Build → Docker Image → Amazon ECR → Kubernetes Deployment → Validation**

One of my key decisions was to use explicit Docker image versioning to improve release traceability.

The successfully built application image is:

`810716384126.dkr.ecr.us-east-1.amazonaws.com/coworking:1.0.2`

The second AWS CodeBuild execution completed successfully.

Application releases are deployed through Kubernetes manifests, allowing controlled updates and verification independently from the automated image build process.

## 4. Kubernetes Deployment Architecture

I structured the application deployment using separate Kubernetes resources for Flask and PostgreSQL.

This approach provides clear separation of responsibilities and simplifies deployment management.

### Flask application

The Flask service includes:

- A dedicated Kubernetes Deployment.
- A Kubernetes Service exposed through an AWS LoadBalancer.
- Container CPU and memory resource allocations.
- Liveness and readiness probes.
- Environment configuration through ConfigMaps and Secrets.

The health and readiness probes provide automated mechanisms for monitoring application availability and operational readiness.

### PostgreSQL database

I configured PostgreSQL as an independent Kubernetes workload with dedicated configuration and initialization resources.

The database configuration uses Kubernetes ConfigMaps for non-sensitive settings and Kubernetes Secrets for credentials.

The deployment architecture also includes a storage configuration based on the Amazon EBS CSI driver and a Kubernetes PersistentVolumeClaim for persistent database storage.

This storage component forms part of the infrastructure design and requires operational validation.

## 5. Deployment Validation and Results

I adopted a validation-oriented approach rather than considering resource creation alone sufficient evidence of success.

My checks cover Kubernetes node availability, pod status, deployment readiness, network connectivity, and API responsiveness.

The following results were verified during my deployment:

| Verification | Result |
|---|---|
| Amazon EKS cluster | ACTIVE |
| Kubernetes worker node | Ready |
| PostgreSQL Deployment | 1/1 available |
| Flask Deployment | 1/1 available |
| Application Service | AWS LoadBalancer provisioned |
| `/health_check` | HTTP 200 |
| `/readiness_check` | HTTP 200 |
| AWS CodeBuild | SUCCEEDED |
| Amazon ECR | Versioned image available |

These results demonstrate successful application deployment, API availability, and communication between the Flask service and PostgreSQL.

## 6. My Engineering Approach

A key aspect of my implementation was approaching infrastructure deployment as a systematic engineering process.

I emphasized three principles:

**Automation:** I used AWS CodeBuild and Kubernetes declarative manifests to reduce repetitive manual deployment activities.

**Reliability:** I integrated health and readiness probes, resource allocations, and deployment status checks to assess application availability.

**Maintainability:** I separated configuration, credentials, application images, and Kubernetes resources to make the deployment easier to understand and evolve.

I also prioritized reproducibility by maintaining the deployment configurations and technical documentation in the GitHub repository.

## 7. Monitoring and Operational Visibility

I used Kubernetes commands to inspect deployment status, pod health, service configuration, and container logs.

AWS CodeBuild execution logs are available through Amazon CloudWatch.

The architecture supports further integration with centralized application logging and monitoring services, including CloudWatch Container Insights.

For a production environment, I would extend observability through application-level metrics, log aggregation, and automated alerts.

## 8. Infrastructure Sizing and Cost Optimization

For the project environment, I selected a `t3.medium` instance to balance resource availability and infrastructure costs.

My cost optimization strategy includes:

- Using limited compute capacity for development workloads.
- Defining CPU and memory requests and limits.
- Reusing versioned Docker images.
- Avoiding unnecessary build operations.
- Monitoring the costs associated with EC2, EKS, EBS, and networking.
- Removing unused cloud resources when deployment validation is complete.

For a production workload, instance sizing should be revisited based on observed resource utilization, availability requirements, and expected traffic.

## 9. Deployment and Release Guide

### Prerequisites

The deployment environment requires AWS CLI, `kubectl`, an Amazon EKS cluster, Kubernetes worker nodes, and an application image available in Amazon ECR.

### Connect to the EKS cluster

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name coworking-eks

kubectl get nodes
```

### Configure PostgreSQL

```bash
bash deployment/generate-postgresql-init-configmap.sh

kubectl apply -f deployment/db-configmap.yaml

kubectl create -f deployment/postgresql-init-configmap.yaml
```

Create a Kubernetes Secret for the database password before deployment.

### Configure persistent storage

For an environment with a healthy EBS CSI driver and the required IAM permissions:

```bash
kubectl apply -f deployment/gp3-storageclass.yaml
kubectl apply -f deployment/postgresql-pvc.yaml
kubectl get pvc
```

Confirm the PersistentVolumeClaim reaches `Bound` before relying on the database's persistent storage.

### Deploy PostgreSQL

```bash
kubectl apply -f deployment/postgresql-service.yaml
kubectl apply -f deployment/postgresql-deployment.yaml

kubectl rollout status deployment/postgresql
```

### Deploy Flask

```bash
kubectl apply -f deployment/coworking-deployment.yaml
kubectl apply -f deployment/coworking-service.yaml

kubectl rollout status deployment/coworking
```

### Validate the deployment

```bash
kubectl get nodes
kubectl get pods
kubectl get svc
kubectl get deployments

kubectl describe svc postgresql-service
kubectl describe deployment coworking

kubectl logs deployment/coworking
```

The application provides the following endpoints:

- `/health_check`
- `/readiness_check`
- `/api/reports/daily_usage`
- `/api/reports/user_visits`

### Release a new application version

To deploy an updated application version:

1. Commit and push the changes to GitHub.
2. Trigger an AWS CodeBuild execution.
3. Verify the image is successfully published to Amazon ECR.
4. Update the image version in `deployment/coworking-deployment.yaml`.
5. Apply the updated Kubernetes manifest.
6. Verify the rollout and application endpoints.

This workflow supports reproducible and traceable application releases.

## 10. Future Improvements

Based on my implementation experience, I identified several opportunities to further strengthen the deployment architecture:

- Fully automated continuous deployment.
- Deployment rollback and progressive delivery strategies.
- Persistent storage and automated database backup validation.
- Centralized application monitoring and alerting.
- Infrastructure as Code using Terraform.
- Automated integration and security testing.
- Autoscaling based on application workloads.

These improvements would help evolve the demonstration into a more resilient and production-oriented cloud-native system.

## 11. My Personal Reflection

What I value most about this project is the opportunity to connect software engineering practices with real cloud infrastructure operations.

I approached the work not simply as an exercise in deploying containers, but as a practical engineering challenge involving automation, configuration management, application validation, and operational decision-making.

The experience strengthened my understanding of how Docker, AWS CodeBuild, Amazon ECR, and Kubernetes work together to support modern software delivery.

**My personal contribution lies in the structured deployment approach, the technical decisions I made, the validation strategy I implemented, and my focus on maintainability, reliability, and cost efficiency.**

For me, successful DevOps engineering means more than getting an application to run: it means understanding how to build, deploy, verify, operate, and continuously improve a software system.
