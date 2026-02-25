Have to Deploy a Django application(helm chart) using Github action with Proper Secreate Management

Setup EKS With Preconfiguration of:
Amazon EBS CSI Driver --> EKS addon 
AWS Load Balancer Controller --> 
Cert Manager

Builld Docker Image and push into the ECR

Deploy Django Application by given Helm chart which is available in the codebase(github repo)

Deploy using Github action with Proper Secreate Management

Also let me know what if I create cloud infra manually. and remaning things will go with cicd pipeline ? is it good for deployment or what ??



# Create EKS Cluster

## Job 1
Tools Must have In Provisioning Server:
Docker, kubectl, eksctl, aws-cli, helm

## Job 2
eksctl create cluster \
  --name django-cluster \
  --region us-east-1 \
  --nodegroup-name django-nodes \
  --node-type t3.small \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed

## Job 3 Enable IAM OIDC provider:
Configure OIDS Provider in AWS IAM 


eksctl utils associate-iam-oidc-provider \
  --cluster <cluster-name> \
  --region us-east-1 \
  --approve


### Step 1: Create IAM Role (IRSA)

```
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster <your-cluster-name> \
  --region us-east-1 \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve

```

### Step 2: Create the Add-on

aws eks create-addon \
  --cluster-name <your-cluster-name> \
  --addon-name aws-ebs-csi-driver \
  --region us-east-1 \
  --service-account-role-arn arn:aws:iam::<account-id>:role/AmazonEKS_EBS_CSI_DriverRole

### Step 3: Verify Installation

aws eks describe-addon \
  --cluster-name <your-cluster-name> \
  --region us-east-1 \
  --addon-name aws-ebs-csi-driver

kubectl get pods -n kube-system | grep ebs


## Job 3 Install a Load Balancer Controller

### Step 1
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json

policy for aws load balancer
https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json


### Step 2
kubectl apply -k "github.com/kubernetes-sigs/aws-load-balancer-controller//config/default?ref=v2.12.0"

### Step 3
helm repo add eks https://aws.github.io/eks-charts
helm repo update

eksctl create iamserviceaccount \
  --cluster django-cluster \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --region us-east-1 \
  --attach-policy-arn arn:aws:iam::<account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve


### Step 4

aws eks describe-cluster \
  --name django-cluster \
  --region us-east-1 \
  --query "cluster.resourcesVpcConfig.vpcId" \
  --output text

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=<vpc-id>

### Step 5 Verify Installation

kubectl get deployment -n kube-system aws-load-balancer-controller




## Job 4 Cert Manager