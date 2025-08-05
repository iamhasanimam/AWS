# Cloud-Native Microservice Architecture

This document outlines the application and system dependencies for the three core microservices in our architecture: **UserService**, **ProductService**, and **OrderService**.

---

## 1. UserService (Node.js + PostgreSQL)

### Purpose
- Manages user accounts: signup, login, and profile updates.
- Serves as the authentication and identity layer for the system.
- Stores user data in **PostgreSQL (RDS)**.

### Rationale
- Keeps user data isolated from other business logic (microservice principle).
- Scales independently — user traffic often differs from product/order traffic.
- Enables central authentication for multiple applications.

### Application Dependencies
- **Node.js** runtime (v18+ recommended)
- **npm** package manager  
- Required packages:
  - `express` → Web server
  - `pg` → PostgreSQL client
  - `jsonwebtoken` → Authentication token management
  - `bcrypt` → Password hashing
  - `dotenv` → Environment variables

**Example `package.json` snippet:**
```json
{
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.7.3",
    "jsonwebtoken": "^9.0.0",
    "bcrypt": "^5.1.0",
    "dotenv": "^16.0.3"
  }
}
```

### System Dependencies
- **Ubuntu 22.04 LTS** (or compatible)
- `build-essential` → Required for compiling npm modules
- `git` → Pull code from GitHub
- `postgresql-client` → Test DB connections

---

## 2. ProductService (Python + FastAPI + MongoDB)

### Purpose
- Manages product catalog: create, update, delete, and list products.
- Stores product data in **MongoDB Atlas** (NoSQL).

### Rationale
- Product data is flexible — MongoDB handles dynamic schemas efficiently.
- Supports fast queries for e-commerce-style listings.
- Scales independently from other services.

### Application Dependencies
- **Python 3.11+**
- **pip** package manager  
- Required packages:
  - `fastapi` → Web framework
  - `uvicorn` → ASGI server
  - `pymongo` → MongoDB client
  - `python-dotenv` → Environment variables

**Example `requirements.txt`:**
```
fastapi==0.95.2
uvicorn[standard]==0.22.0
pymongo==4.3.3
python-dotenv==1.0.0
```

### System Dependencies
- **Ubuntu 22.04 LTS**
- `git` → Pull code from GitHub
- `python3-venv` → Virtual environments
- MongoDB Atlas network access (IP whitelisting)

---

## 3. OrderService (Node.js + PostgreSQL)

### Purpose
- Handles order lifecycle: placing, updating, tracking.
- Stores order records in **PostgreSQL (RDS)**.
- Integrates with:
  - **UserService** → Identify who placed the order
  - **ProductService** → Determine what was ordered

### Rationale
- Orders require **ACID compliance** — PostgreSQL is ideal.
- Isolates high-load order operations from authentication/product services.
- Supports event-driven scaling (handle spikes without impacting other services).

### Application Dependencies
- **Node.js** runtime (v18+ recommended)
- **npm** package manager  
- Required packages:
  - `express` → Web server
  - `pg` → PostgreSQL client
  - `jsonwebtoken` → User authentication verification
  - `dotenv` → Environment variables

**Example `package.json` snippet:**
```json
{
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.7.3",
    "jsonwebtoken": "^9.0.0",
    "dotenv": "^16.0.3"
  }
}
```

### System Dependencies
- **Ubuntu 22.04 LTS**
- `build-essential` → Required for compiling npm modules
- `git` → Pull code from GitHub
- `postgresql-client` → Test DB connections

---

## Why Microservices Instead of a Monolith?

| Aspect            | Microservices | Monolith |
|-------------------|--------------|----------|
| **Scalability**   | Scale services independently | Must scale entire app |
| **Fault Isolation** | One service failure doesn't impact others | A single bug can affect the whole app |
| **Tech Flexibility** | Different stacks per service | One stack for all |
| **Deployment**    | Deploy independently | Full redeploy required |

---
