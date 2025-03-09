## About

Demo is a base repository containing code for the following component - 

- Control Plane - Submodule 
- Worker - Submodule 
- Infrastrcture - Contains the terraform scripts to create control and data plane infra in AWS
- Infrastrcture/appcharts - Contains helm charts for deploying control plane and worker changes in AWS


## Overview  

The Model Serving Infrastructure enables data scientists and DevOps engineers to seamlessly deploy models and obtain a serving endpoint. It provides a structured mechanism to streamline the deployment process, ensuring efficient and scalable model serving while minimizing operational complexities.


## High Level Design

- **Control Plane** - Manages user inputs for provisioning model serving endpoints, orchestrates hardware infrastructure, and handles the endpoint lifecycle.

- **Data Plane** - Processes real-time prediction requests, performs AuthN/Z, invokes the model, returns predictions, and collects model and infrastructure metrics.

![High Level Design Diagram](/static/imgs/user-flow.drawio.png)

## Detailed Design 

The Control Plane is a stateless application server that provides REST APIs for managing model deployment resources. It is deployed as pods on AWS EKS within its own Virtual Private Cloud (VPC) and a dedicated subnet, ensuring isolation. The deployment follows a multi-AZ cluster strategy for high availability.
User requests are routed through an Internet Gateway and an Elastic Load Balancer before reaching the API pods. To accommodate fluctuating workloads, the pods leverage HPA (Horizontal Pod Autoscaler) for dynamic scaling.
Control Plane API nodes process CRUD requests for model deployments, store the data persistently, and enqueue tasks in Kafka or Redis for worker nodes to handle the provisioning workflow. 

The Data Plane is deployed as an independent stack, responsible for processing customer prediction requests and generating predictions. It runs in a separate VPC from the Control Plane, ensuring isolation for enhanced scalability and security.

![Detailed Design in AWS](/static/imgs/inference_service_design.drawio.png)

### Control Plane API

- POST /v1/modelDeployment - Sample Payload 
`
{
  "type": "cpu",
  "model": {
    "version": "v1",
    "type": "single",
    "bucket": "s3://demmodels/",
    "prefix": "models"
  },
  "replicas": 1,
  "request_res": {
    "cpu": "500m",
    "memory": "512Mi"
  },
  "limit_res": {
    "cpu": "1",
    "memory": "1Gi"
  }
}
`
- GET /v1/modelDeployment/{:id} - Sample Response - Once model deployment is active, you will get the predict URL like in response. Sample Response - 
`
{
    "status": "active",
    "url": "https://DP_DNS/v2/models/md-26/infer",
    "request_res": {
        "cpu": "500m",
        "memory": "512Mi"
    },
    "created_at": "2025-03-09T02:16:33.792720",
    "updated_at": "2025-03-09T02:16:33.792735",
    "model": {
        "version": "v1",
        "type": "single",
        "bucket": "s3://demmodels/",
        "prefix": "models"
    },
    "type": "cpu",
    "id": 26,
    "replicas": 1,
    "limit_res": {
        "cpu": "1",
        "memory": "1Gi"
    }
}
`

### Data Plane API (Inference API)


- POST - https://DP_DNS/v2/models/md-{:id}/infer - To sever real time REST predict endpoint 
- GET -  POST - https://DP_DNS/v2/models/md-{:id}/health/live - To see the health of the model 

## Infrasture Setup

### Prerequisiste 
You'd need the following utility installed to setup infra in AWS 
- aws cli 
- terraform 
- helm

### Control Plane Infrastrure 

- Git clone the repo 
- Go to infrastrure folder 
- Run the following - You would need to configure aws cli before this
  - terraform init 
  - terraform plan
  - terraform apply

Once it executes, it provisiones the followin infra 

- Control Plane (CP) VPC (Virtual Private Network)
- Internet Gateway ingress traffic ( internet -> CP VPC ), ingress traffic is for Model Deployment CRUD
- NAT Gateway - Egress Traffic originating from CP API or Worker 
- Setups security rules and routing tables 
- Three public and private subnets in 3 Avalablity Zones (AZ) for HA
- Creates EKS cluster spanned across 3-AZ

### Data Plane Infrastrure 

- Git clone the repo 
- Go to infrastrure folder 
- Run the following - You would need to configure aws cli before this
  - terraform init 
  - terraform plan
  - terraform apply 

Once it executes, it provisiones the followin infra 

- Data Plane (CP) VPC (Virtual Private Network)
- Internet Gateway Predict Ingress traffic ( internet -> DP VPC )
- NAT Gateway - Egress Traffic originating from Data Plane
- Setups security rules and routing tables 
- Three public and private subnets in 3 Avalablity Zones (AZ) for HA
- Creates EKS cluster spanned across 3-AZ

### Application Deployment 

To automicatlly deploy, control plane API and Worker, please follow the steps 
- Go to infrastrure folder 
- Run following commands 
  - helm init 
  - helm install <my-release-01> appcharts/ 




