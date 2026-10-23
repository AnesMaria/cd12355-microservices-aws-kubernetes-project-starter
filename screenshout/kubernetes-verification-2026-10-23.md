# Kubernetes and API validation — 23 October 2026

These are verified **text transcriptions of commands actually executed in AWS CloudShell**. They are **not terminal screenshots** and do not replace the screenshots requested by the Udacity reviewer.

Cluster: `coworking-eks`. Region: `us-east-1`. EKS nodegroup: `coworking-nodegroup` (`ACTIVE`); Kubernetes node: `Ready`. EBS CSI driver: `ACTIVE`.

## kubectl get pods

```text
NAME                          READY   STATUS    RESTARTS   AGE
coworking-7d4db9647c-6mpp2    1/1     Running   0          5m38s
postgresql-775f688bd5-psw8w   1/1     Running   0          6m20s
```

## kubectl get svc

```text
NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)
coworking            LoadBalancer   10.100.244.13    a46e9cf4470084a67a7d90dc7578a37c-604475378.us-east-1.elb.amazonaws.com   5153:31022/TCP
kubernetes           ClusterIP      10.100.0.1       <none>                                                                   443/TCP
postgresql-service   ClusterIP      10.100.211.238   <none>                                                                   5432/TCP
```

## kubectl describe deployment coworking

```text
Name:        coworking
Namespace:   default
Selector:    app=coworking
Replicas:    1 desired | 1 updated | 1 total | 1 available | 0 unavailable
Image:       810716384126.dkr.ecr.us-east-1.amazonaws.com/coworking:1.0.2
Port:        5153/TCP
Liveness:    http-get http://:5153/health_check
Readiness:   http-get http://:5153/readiness_check
Available    True    MinimumReplicasAvailable
Progressing  True    NewReplicaSetAvailable
```

## kubectl describe svc postgresql-service

```text
Name:        postgresql-service
Namespace:   default
Selector:    app=postgresql
Type:        ClusterIP
IP:          10.100.211.238
Port:        postgresql  5432/TCP
TargetPort:  5432/TCP
Endpoints:   172.31.83.182:5432
```

## kubectl get pvc

```text
NAME             STATUS   CAPACITY   ACCESS MODES   STORAGECLASS
postgresql-pvc   Bound    5Gi        RWO            coworking-gp3
```

## HTTP API checks

On 23 October 2026 the four deployed endpoints returned `HTTP/1.1 200 OK`:

- `/health_check` — response `ok`
- `/readiness_check` — response `ok`
- `/api/reports/daily_usage` — JSON statistics
- `/api/reports/user_visits` — JSON user visits

The HTTP responses were obtained via the AWS LoadBalancer. The two reporting endpoints returned populated JSON, confirming successful database-backed reporting.

## Reviewer screenshots

The required **original screenshots have been uploaded** as:
- [Pods Running](kubernetes-01-pods-running.png)
- [Services](kubernetes-02-services.png)
- [Coworking deployment](kubernetes-03-coworking-deployment.png)
- [PostgreSQL service](kubernetes-04-postgresql-service.png)

This transcript is supplementary evidence only and does not replace those actual screenshots.
