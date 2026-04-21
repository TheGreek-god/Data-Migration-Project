# Quick Start Guide

## 🚀 Get Started in 3 Steps

### Step 1: Start the Application
```bash
cd /mnt/c/Users/myvm/devops-migration-project
docker-compose up --build -d
```

### Step 2: Access the Web UI
Open your browser: **http://localhost:8082**

### Step 3: View Migration Status
```bash
docker exec employee-postgres psql -U postgres -d employeedb \
  -c "SELECT version, description, installed_on FROM flyway_schema_history;"
```

## 📋 What You'll See

**Web Interface:**
- Employee list with 5 sample employees
- Add/Edit/Delete functionality
- Clean, modern UI

**Database:**
- 3 migrations automatically applied:
  - V1: Created employees table
  - V2: Inserted sample data
  - V3: Added phone column

## 🛠️ DevOps Practice Scenarios

### Scenario 1: Add a New Migration
```bash
# 1. Create migration file
cat > src/main/resources/db/migration/V4__Add_status_column.sql << 'EOF'
ALTER TABLE employees ADD COLUMN status VARCHAR(20) DEFAULT 'active';
UPDATE employees SET status = 'active';
EOF

# 2. Deploy with DevOps script
./scripts/deploy.sh

# 3. Verify in UI
# Open http://localhost:8082 and check employees
```

### Scenario 2: Rollback
```bash
# Run rollback script
./scripts/rollback.sh

# Select a backup file when prompted
```

### Scenario 3: Deploy to Kubernetes
```bash
# Deploy to Minikube
./scripts/deploy-k8s.sh

# Access via NodePort
# http://localhost:30082
```

### Scenario 4: CI/CD Pipeline
```bash
# 1. Initialize Git repository
git init
git add .
git commit -m "Initial commit"

# 2. Create GitHub repository
# 3. Push code
git remote add origin <your-repo-url>
git push -u origin main

# 4. Pipeline runs automatically!
```

## 📊 Monitoring

### Check Application Health
```bash
curl http://localhost:8082/actuator/health | jq
```

### View Flyway Status
```bash
curl http://localhost:8082/actuator/flyway | jq
```

### Check Logs
```bash
docker-compose logs -f app
```

## 🎯 Learning Objectives

After completing this project, you'll understand:

✅ **Migration Management**
- Creating version-controlled schema changes
- Validating migrations before deployment
- Tracking migration history

✅ **CI/CD Pipeline**
- Automated testing and validation
- Docker image building and pushing
- Multi-environment deployments
- Blue-green deployment strategy

✅ **Backup & Recovery**
- Automated database backups
- Rollback procedures
- Disaster recovery

✅ **Kubernetes Deployment**
- StatefulSets for databases
- Init containers for dependencies
- Health checks and probes
- Zero-downtime deployments

✅ **Monitoring & Observability**
- Health endpoints
- Migration status tracking
- Log aggregation

## 🔧 Troubleshooting

**Port already in use?**
```bash
# Change port in docker-compose.yml
ports:
  - "8083:8080"  # Use 8083 instead
```

**Database connection failed?**
```bash
# Check if PostgreSQL is ready
docker-compose ps
docker-compose logs postgres
```

**Migrations not running?**
```bash
# Check Flyway logs
docker-compose logs app | grep Flyway
```

## 📚 Next Steps

1. **Read DEVOPS_GUIDE.md** for detailed DevOps procedures
2. **Explore the CI/CD pipeline** in `.github/workflows/ci-cd.yml`
3. **Practice adding migrations** and deploying them
4. **Set up GitHub Actions** for automated deployments
5. **Deploy to Kubernetes** and practice zero-downtime updates

## 🎓 Key Takeaways

**As a DevOps Engineer, you:**
- Automate the migration deployment process
- Ensure zero-downtime deployments
- Manage backups and rollbacks
- Monitor migration success/failure
- Build CI/CD pipelines
- Handle production deployments

**You DON'T:**
- Write the SQL migration code (that's developers)
- Decide what schema changes to make (that's architects)

---

**Happy Learning! 🚀**

For detailed DevOps procedures, see **DEVOPS_GUIDE.md**
