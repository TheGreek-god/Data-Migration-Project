#!/bin/bash
# Kubernetes Deployment Script

set -e

echo "========================================="
echo "  Kubernetes Deployment Script"
echo "========================================="

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Build Docker image
echo -e "${YELLOW}Building Docker image...${NC}"
docker build -t employee-management:latest .

# Apply Kubernetes manifests
echo -e "${YELLOW}Applying Kubernetes manifests...${NC}"
kubectl apply -f k8s/

# Wait for PostgreSQL
echo -e "${YELLOW}Waiting for PostgreSQL to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=postgres -n employee-system --timeout=5m

# Wait for application
echo -e "${YELLOW}Waiting for application to be ready...${NC}"
kubectl rollout status deployment/employee-app -n employee-system --timeout=5m

# Get service info
echo -e "${GREEN}Deployment completed!${NC}"
echo ""
kubectl get pods -n employee-system
echo ""
kubectl get svc -n employee-system

# Get NodePort
NODEPORT=$(kubectl get svc employee-app -n employee-system -o jsonpath='{.spec.ports[0].nodePort}')
echo ""
echo -e "${GREEN}Application accessible at: http://localhost:$NODEPORT${NC}"
