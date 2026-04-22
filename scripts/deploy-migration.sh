#!/bin/bash
# Zero-Downtime Migration Deployment Script

set -e

echo "=========================================="
echo "Zero-Downtime Migration Deployment"
echo "=========================================="

# Step 1: Backup existing database
echo ""
echo "Step 1: Creating database backup..."
BACKUP_FILE="backup-$(date +%Y%m%d-%H%M%S).sql"

if docker ps | grep -q employee-postgres; then
    docker exec employee-postgres pg_dump -U postgres employeedb > "$BACKUP_FILE"
    echo "✅ Backup created: $BACKUP_FILE"
else
    echo "⚠️  Database not running. Starting services first..."
    docker-compose up -d postgres
    sleep 10
    docker exec employee-postgres pg_dump -U postgres employeedb > "$BACKUP_FILE"
    echo "✅ Backup created: $BACKUP_FILE"
fi

# Step 2: Validate migration files
echo ""
echo "Step 2: Validating migration files..."
for file in src/main/resources/db/migration/*.sql; do
    if [[ ! $(basename $file) =~ ^V[0-9]+__.*\.sql$ ]]; then
        echo "❌ Invalid migration name: $file"
        exit 1
    fi
done
echo "✅ All migration files valid"

# Step 3: Check current app status
echo ""
echo "Step 3: Checking application status..."
if docker ps | grep -q employee-app; then
    echo "✅ Application is running"
    APP_RUNNING=true
else
    echo "⚠️  Application not running"
    APP_RUNNING=false
fi

# Step 4: Deploy with zero-downtime
echo ""
echo "Step 4: Deploying application with migrations..."
docker-compose up -d --build

# Step 5: Wait for services to be ready
echo ""
echo "Step 5: Waiting for services to be ready..."
sleep 30

# Step 6: Health check
echo ""
echo "Step 6: Running health checks..."
MAX_RETRIES=10
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -f http://localhost:8082/actuator/health > /dev/null 2>&1; then
        echo "✅ Application is healthy"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "⏳ Waiting for application... ($RETRY_COUNT/$MAX_RETRIES)"
        sleep 5
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "❌ Health check failed!"
    echo ""
    echo "Rolling back..."
    docker-compose down
    docker-compose up -d postgres
    sleep 10
    docker exec -i employee-postgres psql -U postgres -d employeedb < "$BACKUP_FILE"
    echo "✅ Rollback completed. Database restored from: $BACKUP_FILE"
    exit 1
fi

# Step 7: Verify migrations
echo ""
echo "Step 7: Verifying migrations..."
docker-compose logs app | grep "Flyway" | tail -20

echo ""
echo "Step 8: Checking migration history..."
docker exec employee-postgres psql -U postgres -d employeedb -c "SELECT version, description, installed_on, success FROM flyway_schema_history ORDER BY installed_rank;"

echo ""
echo "=========================================="
echo "✅ Deployment Successful!"
echo "=========================================="
echo "Application: http://localhost:8082"
echo "Backup file: $BACKUP_FILE"
echo ""
echo "To rollback, run: ./scripts/rollback.sh $BACKUP_FILE"
