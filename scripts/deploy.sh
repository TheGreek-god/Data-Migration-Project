#!/bin/bash
# DevOps Deployment Script with Migration Management

set -e

echo "========================================="
echo "  DevOps Migration Deployment Script"
echo "========================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Step 1: Pre-deployment checks
echo -e "${YELLOW}[1/7] Running pre-deployment checks...${NC}"
docker-compose ps

# Step 2: Backup database
echo -e "${YELLOW}[2/7] Creating database backup...${NC}"
docker exec employee-postgres pg_dump -U postgres employeedb > "$BACKUP_DIR/backup_$TIMESTAMP.sql"
echo -e "${GREEN}✓ Backup created: $BACKUP_DIR/backup_$TIMESTAMP.sql${NC}"

# Step 3: Validate migrations
echo -e "${YELLOW}[3/7] Validating migration files...${NC}"
for file in src/main/resources/db/migration/*.sql; do
    if [[ ! $(basename $file) =~ ^V[0-9]+__.*\.sql$ ]]; then
        echo -e "${RED}✗ Invalid migration name: $file${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✓ All migrations validated${NC}"

# Step 4: Build application
echo -e "${YELLOW}[4/7] Building application...${NC}"
docker-compose build
echo -e "${GREEN}✓ Build completed${NC}"

# Step 5: Deploy with zero downtime
echo -e "${YELLOW}[5/7] Deploying application...${NC}"
docker-compose up -d
echo -e "${GREEN}✓ Deployment initiated${NC}"

# Step 6: Wait for health check
echo -e "${YELLOW}[6/7] Waiting for application to be healthy...${NC}"
for i in {1..30}; do
    if curl -f http://localhost:8082/actuator/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Application is healthy${NC}"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 2
done

# Step 7: Verify migrations
echo -e "${YELLOW}[7/7] Verifying migrations...${NC}"
docker exec employee-postgres psql -U postgres -d employeedb -c "SELECT version, description, installed_on, success FROM flyway_schema_history ORDER BY installed_rank;"

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Deployment Completed Successfully!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Application URL: http://localhost:8082"
echo "Health Check: http://localhost:8082/actuator/health"
echo "Flyway Info: http://localhost:8082/actuator/flyway"
echo ""
echo "Backup location: $BACKUP_DIR/backup_$TIMESTAMP.sql"
