
# 🧱 Cloud-Native Microservice Infrastructure on AWS (Ubuntu + EC2 + Docker + CI/CD)

## ✅ Tech Stack Summary

| Microservice     | Language | DB         | Stack        |
|------------------|----------|------------|--------------|
| UserService      | Node.js  | PostgreSQL | Docker + EC2 |
| ProductService   | Python   | MongoDB    | Docker + EC2 |
| OrderService     | Node.js  | PostgreSQL | Docker + EC2 |

## ✅ AWS Infra Services

| Layer      | Service                        | Purpose                                |
|------------|--------------------------------|----------------------------------------|
| Compute    | EC2 + Docker                   | Run microservices (1 per EC2)          |
| Networking | VPC, Subnets, IGW, SG          | Isolate traffic                        |
| Routing    | ALB                            | Path-based routing                     |
| DNS        | Route 53                       | Map domain (e.g. api.yourdomain.com)   |
| Storage    | EBS                            | EC2 volume, DB persistence             |
| DB Layer   | RDS (Postgres), MongoDB Atlas  | SQL + NoSQL                            |
| Secrets    | SSM Parameter Store            | Secure DB creds, API keys              |
| Monitoring | CloudWatch                     | Logs, alarms, metrics                  |
| CI/CD      | GitHub Actions                 | Auto deploy on code push               |

## 🔧 Phase 1 – Infrastructure Setup (AWS Console)

### Step 1: VPC + Networking

- VPC: `10.0.0.0/16`
- Public Subnets:
  - `10.0.1.0/24` (AZ-a)
  - `10.0.2.0/24` (AZ-b)
- Attach Internet Gateway (IGW)
- Route Table: `0.0.0.0/0` → IGW

### Step 2: Security Groups

- ALB SG: allow HTTP(80), HTTPS(443) from all
- EC2 SG: allow 5000/3000/8000 inbound from ALB SG

### Step 3: EC2 Instances (Ubuntu)

| Instance        | Port | AZ   | Public IP | Notes         |
|----------------|------|------|-----------|---------------|
| UserService     | 5000 | AZ-a | Yes       | Ubuntu 22.04  |
| OrderService    | 3000 | AZ-b | Yes       | Ubuntu 22.04  |
| ProductService  | 8000 | AZ-b | Yes       | Ubuntu 22.04  |

Run on each EC2:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install docker.io docker-compose -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

## 🐳 Phase 2 – Microservice Setup (Docker)

### Example Dockerfiles

#### UserService (Node.js)
```Dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 5000
CMD ["node", "server.js"]
```

#### ProductService (Python + FastAPI)
```Dockerfile
FROM python:3.11
WORKDIR /app
COPY . .
RUN pip install fastapi uvicorn pymongo
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### OrderService (Node.js)
```Dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
CMD ["node", "server.js"]
```

## 🔐 Phase 3 – DB Layer

- RDS: PostgreSQL for User & Order services
- MongoDB Atlas for Product service (Free Tier)
- Store all DB creds in SSM Parameter Store (encrypted)
- Whitelist EC2 Public IPs in MongoDB Atlas

## 🌐 Phase 4 – Domain + SSL

- Route 53 → Create A/ALIAS record → ALB DNS
- ACM → Request certificate for domain → DNS Validation
- Attach cert to ALB Listener (HTTPS 443)

## 🔁 Phase 5 – CI/CD with GitHub Actions

Each repo `.github/workflows/deploy.yml`:

```yaml
name: Deploy to EC2
on:
  push:
    branches:
      - main
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH and Deploy
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.HOST }}
          username: ec2-user
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /app && git pull
            docker-compose down
            docker-compose up -d --build
```

## 📊 Phase 6 – Monitoring with CloudWatch

- Install CloudWatch Agent on each EC2
- Configure `/etc/cloudwatch-agent-config.json`
- Create log groups:
  - `/aws/userservice`
  - `/aws/productservice`
  - `/aws/orderservice`
- Add alarms for:
  - `CPUUtilization > 80%`
  - `StatusCheckFailed`

---

**Author**: Md Hasan Imam  
**GitHub**: [github.com/iamhasanimam](https://github.com/iamhasanimam)  
**LinkedIn**: [linkedin.com/in/iamhasanimam](https://www.linkedin.com/in/iamhasanimam)
#