# Spring Boot Microservices Kubernetes Deployment Script
Write-Host "🚀 Starting Kubernetes Deployment for Spring Boot Microservices" -ForegroundColor Green

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

if (!(Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "❌ kubectl not found. Please install kubectl first." -ForegroundColor Red
    exit 1
}

if (!(Test-Path ".\kind.exe")) {
    Write-Host "❌ Kind not found. Please download Kind first." -ForegroundColor Red
    exit 1
}

if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker not found. Please install Docker first." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Prerequisites check passed" -ForegroundColor Green

# Create Kind cluster
Write-Host "📦 Creating Kind cluster..." -ForegroundColor Yellow
$clusterExists = .\kind.exe get clusters 2>$null | Select-String "microservices-cluster"
if ($clusterExists) {
    Write-Host "⚠️  Cluster already exists. Deleting old cluster..." -ForegroundColor Yellow
    .\kind.exe delete cluster --name microservices-cluster
}

.\kind.exe create cluster --config k8s/kind/kind-config.yaml --name microservices-cluster
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Kind cluster created successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to create Kind cluster" -ForegroundColor Red
    exit 1
}

# Load Docker images
Write-Host "📥 Loading Docker images into cluster..." -ForegroundColor Yellow
$images = @(
    "akhilnakka5/product-service:latest",
    "akhilnakka5/order-service:latest", 
    "akhilnakka5/inventory-service:latest",
    "akhilnakka5/notification-service:latest",
    "akhilnakka5/api-gateway:latest"
)

foreach ($image in $images) {
    Write-Host "Loading $image..." -ForegroundColor Cyan
    .\kind.exe load docker-image $image --name microservices-cluster
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ $image loaded" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Failed to load $image" -ForegroundColor Yellow
    }
}

# Deploy infrastructure
Write-Host "🏗️  Deploying infrastructure..." -ForegroundColor Yellow
kubectl apply -f k8s/manifests/infrastructure/
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Infrastructure deployed" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to deploy infrastructure" -ForegroundColor Red
    exit 1
}

# Wait for infrastructure to be ready
Write-Host "⏳ Waiting for infrastructure to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# Deploy applications
Write-Host "🚀 Deploying microservices..." -ForegroundColor Yellow
kubectl apply -f k8s/manifests/applications/
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Microservices deployed" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to deploy microservices" -ForegroundColor Red
    exit 1
}

# Wait for applications to be ready
Write-Host "⏳ Waiting for microservices to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Show deployment status
Write-Host "📊 Deployment Status:" -ForegroundColor Cyan
kubectl get pods
Write-Host ""
kubectl get services

Write-Host ""
Write-Host "🎉 Kubernetes deployment completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Port-forward API Gateway: kubectl port-forward svc/api-gateway 9000:9000" -ForegroundColor White
Write-Host "2. Port-forward Keycloak: kubectl port-forward svc/keycloak 8181:8080" -ForegroundColor White
Write-Host "3. Port-forward Grafana: kubectl port-forward svc/grafana 3000:3000" -ForegroundColor White
Write-Host "4. Access API Gateway at: http://localhost:9000" -ForegroundColor White
Write-Host "5. Access Keycloak Admin at: http://localhost:8181/admin (admin/admin)" -ForegroundColor White 