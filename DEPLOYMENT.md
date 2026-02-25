
# 🚀 Deployment Guide – Jenkins CI/CD with Django Application on AWS EC2

This guide explains how to:

* Create and configure an EC2 instance
* Install and configure Jenkins
* Integrate GitHub with Jenkins
* Configure webhook triggers
* Set up environment variables
* Deploy a Django application using CI/CD

---

# 1️⃣ Create EC2 Instance

## Step 1: Launch EC2

* **AMI**: Ubuntu Server 24.04 LTS (HVM)
* **Instance Type**: `c7i-flex.large`
* **Storage**: EBS General Purpose (SSD)
* **Key Pair**:

  * Select an existing key pair OR
  * Create a new one
  * ⚠️ Keep the private key (`.pem`) secure


![EC2 Launch](/docs/img/1-ec2-launch.png)
---

## Step 2: Create Security Group

Create a new Security Group:

**Name:** `sai-prj-sg`

### Inbound Rules

| Type       | Protocol | Port | Source    |
| ---------- | -------- | ---- | --------- |
| HTTP       | TCP      | 80   | 0.0.0.0/0 |
| Custom TCP | TCP      | 8080 | 0.0.0.0/0 |
| SSH        | TCP      | 22   | 0.0.0.0/0 |

Attach this security group to your instance.

---

# 2️⃣ Connect to EC2 Instance

Use the public IP of your EC2 instance:

```bash
chmod 400 key.pem
ssh -i "key.pem" ubuntu@<PUBLIC_IP>
```

---

# 3️⃣ Install Required Packages (Jenkins Setup)

Run the following command:

```bash
wget -qO- https://raw.githubusercontent.com/ak-127/sai-prj1/main/install.sh | bash
```

After installation, open:

```
http://<PUBLIC_IP>:8080/login
```

Replace `0.0.0.0` with your instance public IP.

---

# 4️⃣ Jenkins Initial Setup

## Get Initial Admin Password

![Get Initial Admin Password](/docs/img/2-jen-inst-1.png)

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
Copy the password and paste it into the Jenkins setup page.

---

## Install Suggested Plugins

Click **"Install Suggested Plugins"**

![Install Suggested Plugins](/docs/img/3-jen-inst-2.png)
---

## Create First Admin User

![Install Suggested Plugins](/docs/img/4-jen-inst-3.png)

* Fill in the details
* Click **Save and Continue**

---

## Instance Configuration

![Install Suggested Plugins](/docs/img/5-jen-inst-4.png)

Keep the default configuration and click:

**Save and Finish**

Jenkins installation is now complete.

---

# 5️⃣ GitHub Integration with Jenkins

## Step 1: Create GitHub Personal Access Token

![GitHub PAT](/docs/img/6-gihub-pat.png)

Go to:

```
GitHub → Settings → Developer Settings → Personal Access Tokens
```

* Click **Tokens (classic)**
* Click **Generate New Token**
* Expiration: 7 days (or as required)
* Select permissions:

  * `repo`
  * `admin:repo_hook`

⚠️ IMPORTANT: Copy the secret token immediately. It will not be shown again.

---

## Step 2: Add GitHub Token to Jenkins

![CONFIG JEN GH TOKEN](/docs/img/7-jen-gh-pat.png)

Go to:

```
Manage Jenkins → Credentials → System → Global Credentials
```

Click **Add Credentials**

Fill in:

* **Kind**: Secret text
* **Scope**: Global
* **Secret**: Paste your GitHub token
* **ID**: `GITHUB_TOKEN`

Save.

---

## Step 3: Configure GitHub Server in Jenkins

![CONFIG JEN](/docs/img/8-jen-sys.png)
Go to:

```
Manage Jenkins → System → GitHub
```

Add GitHub Server:

* **Name**: Any name
* **API URL**: `https://api.github.com`
* **Credentials**: Select `GITHUB_TOKEN`
* ✅ Check **Manage Hooks**

You should see:

```
Credentials verified for user <username>, rate limit: XXXX
```

Click **Save**.

---

# 6️⃣ Create GitHub Webhook

![GH WEB HOOK](/docs/img/9-gh-whook.png)

Go to your GitHub repository:

```
Repository → Settings → Webhooks → Add Webhook
```

Fill in:

* **Payload URL**:

  ```
  http://<PUBLIC_IP>:8080/github-webhook/
  ```
* **Content Type**: `application/json`
* **Secret**: Leave blank
* **SSL Verification**: Disable (if HTTP)

Save.

---

# 7️⃣ Create Jenkins Pipeline Job

![PIPE LIEN JOB](/docs/img/10-jen-pipeline.png)

## Step 1: Create New Job

* Click **New Item**
* Enter name
* Select **Pipeline**
* Click OK

---

## Step 2: Configure Pipeline

![CONFIG PIPELINE](/docs/img/11-jen-pepe-config.png)

### Triggers

✔️ Check:

```
GitHub hook trigger for GITScm polling
```

---

### Pipeline Configuration

* **Definition**: Pipeline script from SCM
* **SCM**: Git
* **Repository URL**: Paste GitHub HTTP URL
* **Credentials**: Leave blank (if public repo)
* **Branch Specifier**: `*/main`
* **Script Path**: `Jenkinsfile`
* ✔️ Check **Lightweight checkout**

Click **Save**

---

# 8️⃣ Configure Environment Variables (Credentials)

![VARIABLE](/docs/img/12-jen-env.png)

Go to:

```
Manage Jenkins → Credentials → System → Global Credentials
```

Add the following credentials as **Secret Text** (Scope: Global):

| ID                        | Secret Value      |
| ------------------------- | ----------------- |
| SECRET_KEY                | django secret key |
| POSTGRES_DB               | db_name           |
| POSTGRES_USER             | your_db_user      |
| POSTGRES_PASSWORD         | your_db_password  |
| DJANGO_SUPERUSER_USERNAME | admin username    |
| DJANGO_SUPERUSER_EMAIL    | admin email       |
| DJANGO_SUPERUSER_PASSWORD | admin password    |

---

## Django Secret Key Example

```
django-insecure--5x5)z3(w=24ai6!e3glrop1x$dj5u9pn)i#t!#a=@(t$#!@05
```

⚠️ Change database values according to your configuration.

The container and application scripts will automatically create required database entries.

Refer to `requirements.txt` in the codebase for correct dependency versions.

---

# 9️⃣ Deploy Application

![DEPLOY](/docs/img/13-jen-con-log.png)

Now push your code to GitHub.

The webhook will:

1. Trigger Jenkins
2. Run the `Jenkinsfile`
3. Build and deploy the application

You can monitor progress in:

```
Jenkins → Pipeline → Console Output
```

---

# 🔟 Access the Application

### Application URL


```
http://<PUBLIC_IP>/
```

![WEBSITE](/docs/img/14-website.png)

---

### Django Admin Panel

```
http://<PUBLIC_IP>/login/
```
![LOGIN](/docs/img/16-login.png)  


```
http://<PUBLIC_IP>/login/
```
![DASHBORD](/docs/img/15-dashboard.png)  

### Django Admin Panel


```
http://<PUBLIC_IP>/admin/
```
![DJ ADMIN login](/docs/img/17-admin-login.png)  

![DJ ADMIN Dashboard](/docs/img/19-admin-dashboard.png)


Login using:

* `DJANGO_SUPERUSER_USERNAME`
* `DJANGO_SUPERUSER_PASSWORD`

---

# ✅ Deployment Complete

Your application is now live and automatically deploys using Jenkins CI/CD whenever you push code to GitHub.