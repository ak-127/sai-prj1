Here’s a **clear, beginner-friendly, step-by-step guide** to create an **Amazon EKS cluster** using the AWS CLI (most practical method for real environments).

We’ll use:

* Amazon EKS
* AWS CLI
* eksctl
* kubectl

---

# ✅ Method 1 (Recommended): Create EKS Using `eksctl` (Fastest & Easiest)

---

## 🔹 Step 1: Prerequisites

Make sure you have:

### 1️⃣ AWS Account

Create one at: [https://aws.amazon.com](https://aws.amazon.com)

### 2️⃣ Install AWS CLI

```bash
aws --version
```

If not installed:
[https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

---

### 3️⃣ Configure AWS Credentials

```bash
aws configure
```

Enter:

* Access Key
* Secret Key
* Region (example: us-east-1)
* Output format: json

---

### 4️⃣ Install `eksctl`

Mac:

```bash
brew install eksctl
```

Linux:

```bash
curl --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

Verify:

```bash
eksctl version
```

---

### 5️⃣ Install kubectl

```bash
kubectl version --client
```

Install guide:
[https://kubernetes.io/docs/tasks/tools/](https://kubernetes.io/docs/tasks/tools/)

---

# 🚀 Step 2: Create EKS Cluster

Now run:

```bash
eksctl create cluster \
  --name my-cluster \
  --region us-east-1 \
  --nodegroup-name my-nodes \
  --node-type t3.small \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed
```

### What this does:

* Creates VPC
* Creates EKS Control Plane
* Creates Managed Node Group
* Configures kubectl automatically

⏳ Takes 10–20 minutes.

---

# 🔎 Step 3: Verify Cluster

Check nodes:

```bash
kubectl get nodes
```

You should see 2 worker nodes in `Ready` state.

Check cluster:

```bash
kubectl get svc
```

---

# 🎉 Step 4: Deploy a Test App

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

Check service:

```bash
kubectl get svc
```

After a few minutes, you’ll get an External IP.

---

# 🧹 Step 5: Delete Cluster (Important to Avoid Charges)

```bash
eksctl delete cluster --name my-cluster --region us-east-1
```

---

# 🏗 Alternative: Create EKS via AWS Console (GUI)

1. Login to AWS Console
2. Go to Services → EKS
3. Click “Create Cluster”
4. Configure:

   * Cluster name
   * IAM Role
   * Networking (VPC)
5. Create Node Group

This is slower but good for learning.

---

# 🎯 Production Best Practice (Later)

Instead of manual creation, use:

* Terraform
* CloudFormation
* GitOps tools like ArgoCD

---

# 🧠 Quick Summary

| Step              | Tool                      |
| ----------------- | ------------------------- |
| Install CLI tools | AWS CLI, eksctl, kubectl  |
| Configure AWS     | aws configure             |
| Create cluster    | eksctl create cluster     |
| Verify            | kubectl get nodes         |
| Deploy app        | kubectl create deployment |

---



create EKS cluster

eksctl create cluster   --name django-cluster   --region us-east-1   --nodegroup-name django-nodes   --node-type t3.small   --nodes 2


cert manager 
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml


kubectl get crds | grep cert-manager

kubectl get pods -n cert-manager





### Load Balancer Installation

Perfect 👍

If this command:

```bash
aws eks describe-cluster \
  --name django-cluster \
  --query "cluster.identity.oidc.issuer" \
  --region us-east-1 \
  --output text
```

returns something like:

```
https://oidc.eks.us-east-1.amazonaws.com/id/XXXXXXXXXXXXXXXXXXXXXX
```

✅ **That means your OIDC provider is already enabled for your EKS cluster.**

You do **NOT** need to run:

```bash
eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=my-cluster --approve
```

---

# ✅ Next Step: Create IAM Policy

Download the policy:

```bash
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```

Create it:

```bash
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json
```

If you already created it earlier and get `EntityAlreadyExists`, that's fine — just reuse it.

---

# ✅ Create IAM Role + Service Account (IRSA)

Run:

```bash
eksctl create iamserviceaccount \
  --cluster django-cluster \
  --region us-east-1 \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn arn:aws:iam::<YOUR_ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

👉 Replace `<YOUR_ACCOUNT_ID>` with:

```bash
aws sts get-caller-identity --query Account --output text
```

---




# ✅ Install AWS Load Balancer Controller via Helm

Add repo:

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
```

Install:

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=my-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=<YOUR_VPC_ID>
```

Get VPC ID:

```bash
aws eks describe-cluster \
  --name django-cluster \
  --region us-east-1 \
  --query "cluster.resourcesVpcConfig.vpcId" \
  --output text
```

---

# ✅ Verify

```bash
kubectl get pods -n kube-system
```

You should see:

```
aws-load-balancer-controller-xxxxx   Running
```

---

If you'd like, paste:

* Output of `kubectl get nodes`
* Your VPC ID
* Whether you’re using public or private subnets

I’ll validate your setup before you deploy your Django Ingress. 🚀





### Install EBS CSI driver

Here’s a complete, production-ready guide to install the **AWS EBS CSI driver** on your **Amazon EKS** cluster.

---

# ✅ Install AWS EBS CSI Driver on EKS

There are **two supported methods**:

1. ⭐ **Recommended:** Install as an EKS Managed Add-on
2. Manual Helm installation (less recommended for EKS)

---

# ⭐ Method 1 — Install as EKS Managed Add-on (Recommended)

This is the easiest and safest method.

---

## Step 1 — Make Sure OIDC Is Enabled

If you already enabled OIDC earlier for IRSA, you can skip this.

Otherwise:

```bash
eksctl utils associate-iam-oidc-provider \
  --region us-east-1 \
  --cluster my-cluster \
  --approve
```

---

## Step 2 — Create IAM Role for EBS CSI Driver

Create the service account with required policy:

```bash
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster my-cluster \
  --region us-east-1 \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve
```

This attaches the AWS managed policy:
`AmazonEBSCSIDriverPolicy`

---

## Step 3 — Install the EKS Add-on

```bash
aws eks create-addon \
  --cluster-name my-cluster \
  --addon-name aws-ebs-csi-driver \
  --region us-east-1 \
  --service-account-role-arn arn:aws:iam::<ACCOUNT_ID>:role/AmazonEKS_EBS_CSI_DriverRole
```

---

## Step 4 — Verify Installation

```bash
kubectl get pods -n kube-system | grep ebs
```

You should see:

* ebs-csi-controller
* ebs-csi-node

---

# 🧪 Test It (Create StorageClass)

Create a file `ebs-sc.yaml`:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-sc
provisioner: ebs.csi.aws.com
volumeBindingMode: WaitForFirstConsumer
parameters:
  type: gp3
```

Apply it:

```bash
kubectl apply -f ebs-sc.yaml
```

Now create a PVC and verify EBS volume gets created in AWS.

---

# 🧠 Alternative — Install via Helm (Manual Method)

Only use this if:

* You are not using EKS managed add-ons
* You need custom configuration

Add Helm repo:

```bash
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
```

Install:

```bash
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  -n kube-system
```

⚠️ With Helm, you must manually configure IRSA.

---

# 🚨 Common Issues

### ❌ AccessDenied

IAM role not attached properly.

### ❌ OIDC not found

Run the OIDC association command.

### ❌ PVC stuck in Pending

Check:

```bash
kubectl describe pvc <name>
```

---

# 📦 What You Just Installed

The AWS EBS CSI Driver allows:

* Dynamic provisioning of EBS volumes
* Volume expansion
* Snapshot support
* Better security using IRSA

It replaces the old in-tree EBS plugin (deprecated).

---

# 🎯 Recommended Production Setup

✔ Use EKS managed add-on
✔ Use gp3 volumes
✔ Enable encryption
✔ Use WaitForFirstConsumer

---

If you'd like, I can also guide you for:

* 🔹 AWS EFS CSI driver
* 🔹 Snapshot controller setup
* 🔹 Migrating from in-tree storage to CSI
* 🔹 Multi-AZ storage best practices

///////////////////////////////////////////////////////////////

If failed check by creating policy manually below are the steps

///////////////////////////////////////////////////////////////


Here is the **correct way to manually create proper IAM permissions for the EBS CSI Driver from the AWS Console**.

This assumes you're using **IRSA (IAM Roles for Service Accounts)** in Amazon Elastic Kubernetes Service.

---

# ✅ STEP 1 — Create the IAM Role

### Go to:

**AWS Console → IAM → Roles → Create role**

### Select:

* **Trusted entity type** → Web identity
* **Identity provider** → Your EKS OIDC provider
  (format: `oidc.eks.<region>.amazonaws.com/id/XXXX`)
* **Audience** → `sts.amazonaws.com`

Click **Next**

---

# ✅ STEP 2 — Attach Required Permissions

### Option A (Recommended – Simplest & Correct)

Attach AWS managed policy:

* AmazonEBSCSIDriverPolicy

Search and attach it.

This already includes all required permissions:

* ec2:CreateVolume
* ec2:DeleteVolume
* ec2:AttachVolume
* ec2:DetachVolume
* ec2:CreateSnapshot
* ec2:DeleteSnapshot
* ec2:Describe*
* Create/DeleteTags

Click **Next**

---

# ✅ STEP 3 — Name the Role

Example:

```id="zsc48m"
AmazonEKS_EBS_CSI_DriverRole
```

Create the role.

---

# ✅ STEP 4 — Edit Trust Relationship (IMPORTANT)

After creation:

IAM → Roles → Select your role → **Trust relationships → Edit**

Replace with this template (update region/account/cluster OIDC ID):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/oidc.eks.<REGION>.amazonaws.com/id/<OIDC_ID>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.<REGION>.amazonaws.com/id/<OIDC_ID>:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
```

This ensures:

* Only the **ebs-csi-controller-sa**
* In **kube-system namespace**
* Can assume this role

Save changes.

---

# ✅ STEP 5 — Attach Role to EKS Add-on

Now go to:

**EKS → Clusters → Your Cluster → Add-ons**

Select:

* Amazon EBS CSI Driver
* Click **Edit**
* Choose **Use existing IAM role**
* Select your newly created role
* Save

---

# ✅ If Installed via Helm (Manual Install)

You must annotate the service account:

```bash
kubectl annotate serviceaccount ebs-csi-controller-sa \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::<ACCOUNT_ID>:role/AmazonEKS_EBS_CSI_DriverRole
```

---

# 🔒 Optional: Custom Minimal Policy (Advanced)

If you do NOT want to use the AWS managed policy, create a custom policy with:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "ec2:Describe*",
        "ec2:CreateSnapshot",
        "ec2:DeleteSnapshot",
        "ec2:CreateTags",
        "ec2:DeleteTags"
      ],
      "Resource": "*"
    }
  ]
}
```

But in production, AWS recommends using the managed policy.

---

# ✅ Final Verification Checklist

* OIDC provider exists
* Role created with Web Identity
* Trust relationship restricted to service account
* AmazonEBSCSIDriverPolicy attached
* Role linked to EKS Add-on

---

If you tell me:

* Your region
* Whether you're using Bottlerocket / AL2
* Whether using EKS Add-on or Helm

I can give you a cluster-specific validation checklist.


Role
AmazonEKS_EBS_CSI_DriverRole  

Policy
AmazonEBSCSIDriverPolicy

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInstances",
                "ec2:DescribeSnapshots",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVolumeStatus"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSnapshot",
                "ec2:ModifyVolume"
            ],
            "Resource": "arn:aws:ec2:*:*:volume/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CopyVolumes"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:volume/vol-*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:DetachVolume"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:instance/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateVolume",
                "ec2:EnableFastSnapshotRestores"
            ],
            "Resource": "arn:aws:ec2:*:*:snapshot/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:snapshot/*"
            ],
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": [
                        "CreateVolume",
                        "CreateSnapshot",
                        "CopyVolumes"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteTags"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:snapshot/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateVolume",
                "ec2:CopyVolumes"
            ],
            "Resource": "arn:aws:ec2:*:*:volume/*",
            "Condition": {
                "StringLike": {
                    "aws:RequestTag/ebs.csi.aws.com/cluster": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateVolume",
                "ec2:CopyVolumes"
            ],
            "Resource": "arn:aws:ec2:*:*:volume/*",
            "Condition": {
                "StringLike": {
                    "aws:RequestTag/CSIVolumeName": "*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteVolume"
            ],
            "Resource": "arn:aws:ec2:*:*:volume/*",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteVolume"
            ],
            "Resource": "arn:aws:ec2:*:*:volume/*",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/CSIVolumeName": "*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteVolume"
            ],
            "Resource": "arn:aws:ec2:*:*:volume/*",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/kubernetes.io/created-for/pvc/name": "*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSnapshot"
            ],
            "Resource": "arn:aws:ec2:*:*:snapshot/*",
            "Condition": {
                "StringLike": {
                    "aws:RequestTag/CSIVolumeSnapshotName": "*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSnapshot"
            ],
            "Resource": "arn:aws:ec2:*:*:snapshot/*",
            "Condition": {
                "StringLike": {
                    "aws:RequestTag/ebs.csi.aws.com/cluster": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteSnapshot",
                "ec2:LockSnapshot"
            ],
            "Resource": "arn:aws:ec2:*:*:snapshot/*",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/CSIVolumeSnapshotName": "*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteSnapshot",
                "ec2:LockSnapshot"
            ],
            "Resource": "arn:aws:ec2:*:*:snapshot/*",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
                }
            }
        }
    ]
}


Trust Relation:

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::612356096330:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/51F6EDF0B91E6F854D9C810FA6E93FA7"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.us-east-1.amazonaws.com/id/51F6EDF0B91E6F854D9C810FA6E93FA7:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa",
                    "oidc.eks.us-east-1.amazonaws.com/id/51F6EDF0B91E6F854D9C810FA6E93FA7:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}























### Login ECR 

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 612356096330.dkr.ecr.us-east-1.amazonaws.com

TAG image

docker tag image:tag 612356096330.dkr.ecr.us-east-1.amazonaws.com/saiapp:v1.1

push it 

docker push 612356096330.dkr.ecr.us-east-1.amazonaws.com/saiapp:v1.1





Install DJANGO helm chart

helm upgrade --install django-release ./django-chart   --create-namespace   --namespace django-prod   -f ./django-chart/values.yaml   -f ./secrets-values.yaml






Error:


kubectl describe pvc/postgres-pvc -n django-prod
Name:          postgres-pvc
Namespace:     django-prod
StorageClass:
Status:        Pending
Volume:
Labels:        app.kubernetes.io/managed-by=Helm
Annotations:   meta.helm.sh/release-name: django-release
               meta.helm.sh/release-namespace: django-prod
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:
Access Modes:
VolumeMode:    Filesystem
Used By:       postgres-6588468f47-592gz
Events:
  Type    Reason         Age                   From                         Message
  ----    ------         ----                  ----                         -------
  Normal  FailedBinding  51s (x26 over 6m56s)  persistentvolume-controller  no persistent volumes available for this claim and no storage class is set




  Resolution

  kubectl get storageclass

  Option 1: Set gp2 as default
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'


Check again:

kubectl get storageclass


You should now see:

gp2 (default)  kubernetes.io/aws-ebs  Delete  WaitForFirstConsumer  false  ...


Now your PVCs without a storageClassName will use gp2 automatically.

Option 2: Specify storageClassName in your PVC

Update your PVC manifest:

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: gp2