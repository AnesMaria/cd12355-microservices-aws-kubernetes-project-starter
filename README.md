# Coworking Space Service Extension
The Coworking Space Service is a set of APIs that enables users to request one-time tokens and administrators to authorize access to a coworking space. This service follows a microservice pattern and the APIs are split into distinct services that can be deployed and managed independently of one another.

For this project, you are a DevOps engineer who will be collaborating with a team that is building an API for business analysts. The API provides business analysts basic analytics data on user activity in the service. The application they provide you functions as expected locally and you are expected to help build a pipeline to deploy it in Kubernetes.

## Implemented AWS EKS deployment (project-specific)

This implementation uses AWS CodeBuild to build `analytics/Dockerfile`, pushes versioned images to Amazon ECR, and deploys Flask plus PostgreSQL on Amazon EKS with separate Deployments and Services. The `deployment/` manifests below are the implemented alternative to the starter Helm walkthrough above, so do not install a second PostgreSQL release with Helm.

**Prerequisites:** AWS CLI and kubectl configured for `us-east-1`, a working EKS node in `Ready` state, the EBS CSI driver with its IAM permissions, and permission to create the Kubernetes resources.

```bash
aws eks update-kubeconfig --region us-east-1 --name coworking-eks
kubectl get nodes
# Stop if no node is Ready.
bash deployment/generate-postgresql-init-configmap.sh
kubectl apply -f deployment/db-configmap.yaml
# Create a nonempty password without storing it in Git or shell history:
read -rsp "PostgreSQL password: " DB_PASSWORD; echo
kubectl create secret generic coworking-db-secret --from-literal=DB_PASSWORD="$DB_PASSWORD"
unset DB_PASSWORD
kubectl apply -f deployment/gp3-storageclass.yaml
kubectl apply -f deployment/postgresql-init-configmap.yaml
kubectl apply -f deployment/postgresql-pvc.yaml
kubectl apply -f deployment/postgresql-service.yaml
kubectl apply -f deployment/postgresql-deployment.yaml
kubectl rollout status deployment/postgresql
kubectl apply -f deployment/coworking-deployment.yaml
kubectl rollout status deployment/coworking
# Optionally create a public endpoint (LoadBalancer incurs extra cost):
# kubectl apply -f deployment/coworking-service.yaml
kubectl get pods
kubectl get svc
kubectl describe svc postgresql-service
kubectl describe deployment coworking
```

PostgreSQL loads `1_create_tables.sql`, `2_seed_users.sql`, and `3_seed_tokens.sql` from its ConfigMap only on initial startup with an empty data directory. The database uses the 1 GiB EBS-backed `coworking-gp3` PersistentVolumeClaim and a Kubernetes Secret for the database password. To test the Flask API without creating a paid LoadBalancer, use `kubectl port-forward deployment/coworking 5153:5153` in one terminal and run `curl http://localhost:5153/health_check`, `curl http://localhost:5153/readiness_check`, `curl http://localhost:5153/api/reports/daily_usage`, and `curl http://localhost:5153/api/reports/user_visits` in another.

### Release and observability

Push an application change to GitHub and start `coworking-codebuild` (or use a configured GitHub webhook) to build and push `coworking:1.0.<build-number>` to ECR; update the `image:` tag in `deployment/coworking-deployment.yaml`, apply it, and verify `kubectl rollout status deployment/coworking`. The verified second CodeBuild run succeeded and published `810716384126.dkr.ecr.us-east-1.amazonaws.com/coworking:1.0.2`, while CodeBuild logs are available in CloudWatch at `/aws/codebuild/coworking-codebuild`. Application container logs require additional collection, such as CloudWatch Container Insights, and should not be claimed as present until the agents are healthy and logs are visible.

For a small demonstration, one `t3.medium` node may be sufficient if system pods and workload memory fit, but capacity must be checked before deployment. To limit costs, avoid a public LoadBalancer when port-forwarding suffices, minimize node capacity, monitor CodeBuild/EBS costs, and delete unused EKS/EC2/EBS resources after evidence has been saved.

**Current lab limitation (2026-10-22):** The Udacity AWS organization service-control policy explicitly denies `ec2:DescribeInstances` to the EC2 node role, causing Amazon Linux 2023 `nodeadm` initialization to fail. Consequently, `kubectl get nodes` returned no registered nodes, all system pods were pending, and EBS CSI reported `DEGRADED`, so PostgreSQL and Flask have not been verified running on EKS. The lab administrator must lift the restriction or supply a permitted environment before capturing genuine live EKS application and CloudWatch container-logging evidence.

## Getting Started

### Dependencies
#### Local Environment
1. Python Environment - run Python 3.6+ applications and install Python dependencies via `pip`
2. Docker CLI - build and run Docker images locally
3. `kubectl` - run commands against a Kubernetes cluster
4. `helm` - apply Helm Charts to a Kubernetes cluster

#### Remote Resources
1. AWS CodeBuild - build Docker images remotely
2. AWS ECR - host Docker images
3. Kubernetes Environment with AWS EKS - run applications in k8s
4. AWS CloudWatch - monitor activity and logs in EKS
5. GitHub - pull and clone code

### Setup
#### 1. Configure a Database
Set up a Postgres database using a Helm Chart.

1. Set up Bitnami Repo
```bash
helm repo add <REPO_NAME> https://charts.bitnami.com/bitnami
```

2. Install PostgreSQL Helm Chart
```
helm install <SERVICE_NAME> <REPO_NAME>/postgresql
```

This should set up a Postgre deployment at `<SERVICE_NAME>-postgresql.default.svc.cluster.local` in your Kubernetes cluster. You can verify it by running `kubectl svc`

By default, it will create a username `postgres`. The password can be retrieved with the following command:
```bash
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default <SERVICE_NAME>-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)

echo $POSTGRES_PASSWORD
```

<sup><sub>* The instructions are adapted from [Bitnami's PostgreSQL Helm Chart](https://artifacthub.io/packages/helm/bitnami/postgresql).</sub></sup>

3. Test Database Connection
The database is accessible within the cluster. This means that when you will have some issues connecting to it via your local environment. You can either connect to a pod that has access to the cluster _or_ connect remotely via [`Port Forwarding`](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)

* Connecting Via Port Forwarding
```bash
kubectl port-forward --namespace default svc/<SERVICE_NAME>-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432
```

* Connecting Via a Pod
```bash
kubectl exec -it <POD_NAME> bash
PGPASSWORD="<PASSWORD HERE>" psql postgres://postgres@<SERVICE_NAME>:5432/postgres -c <COMMAND_HERE>
```

4. Run Seed Files
We will need to run the seed files in `db/` in order to create the tables and populate them with data.

```bash
kubectl port-forward --namespace default svc/<SERVICE_NAME>-postgresql 5432:5432 &
    PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < <FILE_NAME.sql>
```

### 2. Running the Analytics Application Locally
In the `analytics/` directory:

1. Install dependencies
```bash
pip install -r requirements.txt
```
2. Run the application (see below regarding environment variables)
```bash
<ENV_VARS> python app.py
```

There are multiple ways to set environment variables in a command. They can be set per session by running `export KEY=VAL` in the command line or they can be prepended into your command.

* `DB_USERNAME`
* `DB_PASSWORD`
* `DB_HOST` (defaults to `127.0.0.1`)
* `DB_PORT` (defaults to `5432`)
* `DB_NAME` (defaults to `postgres`)

If we set the environment variables by prepending them, it would look like the following:
```bash
DB_USERNAME=username_here DB_PASSWORD=password_here python app.py
```
The benefit here is that it's explicitly set. However, note that the `DB_PASSWORD` value is now recorded in the session's history in plaintext. There are several ways to work around this including setting environment variables in a file and sourcing them in a terminal session.

3. Verifying The Application
* Generate report for check-ins grouped by dates
`curl <BASE_URL>/api/reports/daily_usage`

* Generate report for check-ins grouped by users
`curl <BASE_URL>/api/reports/user_visits`

## Project Instructions
1. Set up a Postgres database with a Helm Chart
2. Create a `Dockerfile` for the Python application. Use a base image that is Python-based.
3. Write a simple build pipeline with AWS CodeBuild to build and push a Docker image into AWS ECR
4. Create a service and deployment using Kubernetes configuration files to deploy the application
5. Check AWS CloudWatch for application logs

### Deliverables
1. `Dockerfile`
2. Screenshot of AWS CodeBuild pipeline
3. Screenshot of AWS ECR repository for the application's repository
4. Screenshot of `kubectl get svc`
5. Screenshot of `kubectl get pods`
6. Screenshot of `kubectl describe svc <DATABASE_SERVICE_NAME>`
7. Screenshot of `kubectl describe deployment <SERVICE_NAME>`
8. All Kubernetes config files used for deployment (ie YAML files)
9. Screenshot of AWS CloudWatch logs for the application
10. `README.md` file in your solution that serves as documentation for your user to detail how your deployment process works and how the user can deploy changes. The details should not simply rehash what you have done on a step by step basis. Instead, it should help an experienced software developer understand the technologies and tools in the build and deploy process as well as provide them insight into how they would release new builds.


### Stand Out Suggestions
Please provide up to 3 sentences for each suggestion. Additional content in your submission from the standout suggestions do _not_ impact the length of your total submission.
1. Specify reasonable Memory and CPU allocation in the Kubernetes deployment configuration
2. In your README, specify what AWS instance type would be best used for the application? Why?
3. In your README, provide your thoughts on how we can save on costs?

### Best Practices
* Dockerfile uses an appropriate base image for the application being deployed. Complex commands in the Dockerfile include a comment describing what it is doing.
* The Docker images use semantic versioning with three numbers separated by dots, e.g. `1.2.1` and  versioning is visible in the  screenshot. See [Semantic Versioning](https://semver.org/) for more details.