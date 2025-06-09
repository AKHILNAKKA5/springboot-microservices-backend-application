# Spring Boot Microservices Backend Application

This repository contains a complete Spring Boot 3 microservices architecture implementation with authentication, monitoring, and messaging.

## Services Overview

- **Product Service** - MongoDB-based product catalog management
- **Order Service** - MySQL-based order processing with Kafka messaging
- **Inventory Service** - MySQL-based inventory management
- **Notification Service** - Kafka consumer for email notifications
- **API Gateway** - Spring Cloud Gateway MVC with Keycloak JWT authentication

## Tech Stack

The technologies used in this project are:

- **Spring Boot 3** - Microservices framework
- **MongoDB** - Product service database
- **MySQL** - Order and inventory services database
- **Apache Kafka** - Event streaming and messaging
- **Keycloak** - Identity and access management (JWT authentication)
- **Docker & Docker Compose** - Containerization and orchestration
- **Observability Stack** - Prometheus, Grafana, Loki and Tempo
- **Test Containers with Wiremock** - Integration testing
- **Kubernetes** - Container orchestration

## Application Architecture
![image](https://github.com/user-attachments/assets/d4ef38bd-8ae5-4cc7-9ac5-7a8e5ec3c969)

## Quick Start with Docker Compose

### Prerequisites
- Java 21
- Maven
- Docker & Docker Compose

### 1. Build the services
```shell
mvn clean package -DskipTests
```

### 2. Build Docker images
```shell
docker build -t akhilnakka5/product-service product-service/
docker build -t akhilnakka5/order-service order-service/
docker build -t akhilnakka5/inventory-service inventory-service/
docker build -t akhilnakka5/notification-service notification-service/
docker build -t akhilnakka5/api-gateway api-gateway/
```

### 3. Start all services
```shell
docker-compose up -d
```

### 4. Test the APIs
Use the provided Postman collection (`Spring-Microservices-Postman-Collection.json`) or:

1. **Get Access Token:**
```bash
curl -X POST http://localhost:8181/realms/spring-microservices-security-realm/protocol/openid-connect/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password&client_id=admin-cli&username=akhilnakka&password=12345"
```

2. **Test Product Service:**
```bash
curl -H "Authorization: Bearer {your_token}" http://localhost:9000/api/product
```

3. **Test Order Service:**
```bash
curl -X POST -H "Authorization: Bearer {your_token}" \
  -H "Content-Type: application/json" \
  -d '{"orderLineItemsList":[{"skuCode":"iphone_15","price":999.99,"quantity":1}]}' \
  http://localhost:9000/api/order
```

## Service Endpoints

All services are accessible through the API Gateway at `localhost:9000`:

- **Product Service**: `http://localhost:9000/api/product`
- **Order Service**: `http://localhost:9000/api/order`
- **Inventory Service**: `http://localhost:9000/api/inventory`

## Admin Interfaces

- **Keycloak Admin Console**: `http://localhost:8181/admin` (admin/admin)
- **Grafana Dashboards**: `http://localhost:3000` (admin/admin)
- **Kafka UI**: `http://localhost:8086`

## Kubernetes Deployment

### Prerequisites
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) or any Kubernetes cluster
- Docker

### Automated Deployment (Recommended)
Use the provided PowerShell script for complete deployment:

```shell
# Download Kind (if not installed)
Invoke-WebRequest -Uri "https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64" -OutFile "kind.exe"

# Run deployment script
PowerShell -ExecutionPolicy Bypass -File deploy-k8s.ps1
```

### Manual Deployment

#### 1. Create Kind Cluster
```shell
kind create cluster --config k8s/kind/kind-config.yaml --name microservices-cluster
```

#### 2. Load Docker Images
```shell
kind load docker-image akhilnakka5/product-service:latest --name microservices-cluster
kind load docker-image akhilnakka5/order-service:latest --name microservices-cluster
kind load docker-image akhilnakka5/inventory-service:latest --name microservices-cluster
kind load docker-image akhilnakka5/notification-service:latest --name microservices-cluster
kind load docker-image akhilnakka5/api-gateway:latest --name microservices-cluster
```

#### 3. Deploy Infrastructure
```shell
kubectl apply -f k8s/manifests/infrastructure/
```

#### 4. Deploy Applications
```shell
kubectl apply -f k8s/manifests/applications/
```

#### 5. Verify Deployment
```shell
kubectl get pods
kubectl get services
```

### Access Services via Port Forwarding
```shell
# API Gateway (Main entry point)
kubectl port-forward svc/api-gateway 9000:9000

# Keycloak Admin Console
kubectl port-forward svc/keycloak 8181:8080

# Grafana Dashboards
kubectl port-forward svc/grafana 3000:3000

# Kafka UI
kubectl port-forward svc/kafka-ui 8086:8080
```

### Service URLs (after port-forwarding)
- **API Gateway**: http://localhost:9000
- **Keycloak Admin**: http://localhost:8181/admin (admin/admin)
- **Grafana**: http://localhost:3000
- **Kafka UI**: http://localhost:8086

## Authentication

The project uses Keycloak for JWT-based authentication. A test user is automatically created:
- **Username**: `akhilnakka`
- **Password**: `12345`

All API endpoints require a valid JWT token in the Authorization header.
