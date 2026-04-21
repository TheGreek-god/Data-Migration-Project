# DevOps Migration Project - Employee Management System

A full-stack web application demonstrating DevOps best practices for database schema migrations, CI/CD pipelines, and Kubernetes deployments.

## Project Overview

**Application:** Employee Management System with Web UI
**Tech Stack:** 
- Frontend: HTML/CSS/JavaScript (Thymeleaf templates)
- Backend: Spring Boot
- Database: PostgreSQL
- Migrations: Flyway
- CI/CD: GitHub Actions
- Deployment: Docker, Kubernetes

## DevOps Focus Areas

### 1. Automated Database Migrations
- Version-controlled schema changes
- Automated migration execution
- Rollback procedures
- Migration validation

### 2. CI/CD Pipeline
- Automated testing
- Docker image building
- Migration validation
- Kubernetes deployment
- Blue-green deployment strategy

### 3. Infrastructure as Code
- Kubernetes manifests
- Docker Compose for local dev
- Environment-specific configurations

### 4. Monitoring & Rollback
- Migration status tracking
- Automated rollback on failure
- Health checks

## Quick Start

### Local Development
```bash
docker-compose up --build
```
Access: http://localhost:8082

### Deploy to Kubernetes
```bash
kubectl apply -f k8s/
```

## Project Structure
```
devops-migration-project/
├── src/
│   ├── main/
│   │   ├── java/
│   │   ├── resources/
│   │   │   ├── db/migration/     # Flyway migrations
│   │   │   ├── templates/        # Web UI templates
│   │   │   └── static/           # CSS/JS
│   │   └── application.yml
├── .github/workflows/            # CI/CD pipelines
├── k8s/                          # Kubernetes manifests
├── scripts/                      # DevOps scripts
├── Dockerfile
└── docker-compose.yml
```

## CI/CD Pipeline Stages

1. **Build & Test**
2. **Migration Validation**
3. **Docker Build & Push**
4. **Deploy to Staging**
5. **Run Migrations**
6. **Deploy to Production**
7. **Rollback on Failure**

## Features

- Employee CRUD operations with web interface
- Automated database migrations
- Zero-downtime deployments
- Automated backups before migrations
- Migration rollback capability
- Health monitoring
