# DevOps Engineer Guide - Database Migration Management

## Overview
This guide covers all DevOps responsibilities for managing database migrations in production.

## 1. Local Development & Testing

### Start the Application
```bash
cd /mnt/c/Users/myvm/devops-migration-project
docker-compose up --build
```

Access: **http://localhost:8082**

### Run DevOps Deployment Script
```bash
./scripts/deploy.sh
```

This script:
- ✅ Creates database backup
- ✅ Validates migration files
- ✅ Builds application
- ✅ Deploys with zero downtime
- ✅ Runs health checks
- ✅ Verifies migrations

## 2. Migration Management

### Check Migration Status
```bash
docker exec employee-postgres psql -U postgres -d employeedb \
  -c "SELECT * FROM flyway_schema_history;"
```

### View Migration Logs
```bash
docker-compose logs app | grep Flyway
```

### Access Flyway Actuator Endpoint
```bash
curl http://localhost:8082/actuator/flyway | jq
```

## 3. Adding New Migrations

### Step 1: Create Migration File
```bash
# Create new migration (DevOps validates, Developers write)
touch src/main/resources/db/migration/V4__Add_address_column.sql
```

### Step 2: Validate Naming Convention
```bash
# Must follow: V{number}__{description}.sql
# Example: V4__Add_address_column.sql
```

### Step 3: Test Locally
```bash
docker-compose down
docker-compose up --build
```

### Step 4: Commit to Git
```bash
git add src/main/resources/db/migration/V4__Add_address_column.sql
git commit -m "feat: add address column migration"
git push origin main
```

## 4. CI/CD Pipeline (GitHub Actions)

### Pipeline Stages

**Stage 1: Build & Test**
- Compiles application
- Runs unit tests
- Creates artifact

**Stage 2: Validate Migrations**
- Checks naming conventions
- Runs Flyway validate
- Tests migrations on test database
- Generates migration report

**Stage 3: Build Docker Image**
- Builds multi-stage Docker image
- Pushes to container registry
- Tags with commit SHA

**Stage 4: Deploy to Staging**
- Backs up staging database
- Applies Kubernetes manifests
- Runs migrations automatically
- Verifies deployment

**Stage 5: Deploy to Production**
- Backs up production database
- Blue-green deployment
- Runs migrations
- Switches traffic
- Auto-rollback on failure

### Required GitHub Secrets

```bash
# Add these to your GitHub repository secrets:
KUBECONFIG_STAGING      # Base64 encoded kubeconfig for staging
KUBECONFIG_PRODUCTION   # Base64 encoded kubeconfig for production
GITHUB_TOKEN            # Automatically provided
```

### Trigger Pipeline
```bash
git push origin main  # Triggers full pipeline
```

## 5. Kubernetes Deployment

### Deploy to Kubernetes
```bash
./scripts/deploy-k8s.sh
```

### Manual Deployment
```bash
# Build image
docker build -t employee-management:latest .

# Apply manifests
kubectl apply -f k8s/

# Check status
kubectl get pods -n employee-system
kubectl logs -f deployment/employee-app -n employee-system
```

### Check Migration Status in K8s
```bash
kubectl exec -it deployment/employee-app -n employee-system -- \
  curl localhost:8080/actuator/flyway
```

## 6. Backup & Restore

### Create Backup
```bash
# Docker Compose
docker exec employee-postgres pg_dump -U postgres employeedb > backup.sql

# Kubernetes
kubectl exec -n employee-system statefulset/postgres -- \
  pg_dump -U postgres employeedb > backup.sql
```

### Restore from Backup
```bash
./scripts/rollback.sh
```

Or manually:
```bash
docker exec -i employee-postgres psql -U postgres -d employeedb < backup.sql
```

## 7. Rollback Procedures

### Scenario 1: Migration Failed
```bash
# 1. Stop application
docker-compose stop app

# 2. Restore database
./scripts/rollback.sh

# 3. Revert code
git revert HEAD
git push origin main
```

### Scenario 2: Production Issue
```bash
# Kubernetes auto-rollback
kubectl rollout undo deployment/employee-app -n employee-system

# Or use CI/CD rollback job
```

## 8. Monitoring & Alerts

### Health Checks
```bash
# Application health
curl http://localhost:8082/actuator/health

# Liveness probe
curl http://localhost:8082/actuator/health/liveness

# Readiness probe
curl http://localhost:8082/actuator/health/readiness
```

### Migration Monitoring
```bash
# Check if migrations succeeded
docker exec employee-postgres psql -U postgres -d employeedb \
  -c "SELECT version, success FROM flyway_schema_history WHERE success = false;"
```

## 9. Zero-Downtime Deployment

### Strategy: Rolling Update
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1        # Add 1 new pod before removing old
    maxUnavailable: 0  # Keep all pods running during update
```

### Process:
1. New pod starts with new code
2. Migrations run automatically
3. Health checks pass
4. Traffic switches to new pod
5. Old pod terminates

## 10. Troubleshooting

### Migration Failed
```bash
# Check logs
docker-compose logs app | grep -i error

# Check Flyway status
docker exec employee-postgres psql -U postgres -d employeedb \
  -c "SELECT * FROM flyway_schema_history ORDER BY installed_rank DESC LIMIT 5;"

# Repair Flyway (if needed)
mvn flyway:repair
```

### Database Connection Issues
```bash
# Test connection
docker exec employee-postgres psql -U postgres -d employeedb -c "SELECT 1;"

# Check network
docker network inspect devops-migration-project_default
```

### Pod Not Starting
```bash
kubectl describe pod <pod-name> -n employee-system
kubectl logs <pod-name> -n employee-system
```

## 11. Best Practices

### ✅ DO:
- Always backup before migrations
- Test migrations in staging first
- Use version control for all migrations
- Never modify applied migrations
- Monitor migration execution
- Have rollback plan ready
- Use health checks
- Implement zero-downtime deployments

### ❌ DON'T:
- Modify existing migration files
- Skip testing in staging
- Deploy without backups
- Ignore failed migrations
- Deploy during peak hours (without blue-green)

## 12. Performance Optimization

### Large Data Migrations
```sql
-- V5__Large_data_migration.sql
-- Use batching for large updates
DO $$
DECLARE
    batch_size INT := 1000;
BEGIN
    LOOP
        UPDATE employees 
        SET status = 'active' 
        WHERE status IS NULL 
        LIMIT batch_size;
        
        EXIT WHEN NOT FOUND;
        COMMIT;
    END LOOP;
END $$;
```

### Index Creation
```sql
-- Create indexes concurrently (no table lock)
CREATE INDEX CONCURRENTLY idx_employee_email ON employees(email);
```

## 13. Security

### Secrets Management
```bash
# Never commit secrets to Git
# Use Kubernetes secrets or environment variables

# Rotate database passwords
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_PASSWORD=new_password \
  --dry-run=client -o yaml | kubectl apply -f -
```

## 14. Documentation

### Migration Checklist
- [ ] Migration file created with correct naming
- [ ] Tested locally
- [ ] Peer reviewed
- [ ] Backup created
- [ ] Staging deployment successful
- [ ] Production deployment scheduled
- [ ] Rollback plan documented
- [ ] Team notified

## Quick Reference Commands

```bash
# Deploy
./scripts/deploy.sh

# Rollback
./scripts/rollback.sh

# K8s Deploy
./scripts/deploy-k8s.sh

# Check migrations
docker exec employee-postgres psql -U postgres -d employeedb \
  -c "SELECT * FROM flyway_schema_history;"

# View logs
docker-compose logs -f app

# Health check
curl http://localhost:8082/actuator/health
```

---

**Remember:** As a DevOps Engineer, you manage the PROCESS, not write the SQL!
