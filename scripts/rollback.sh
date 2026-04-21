#!/bin/bash
# Rollback Script

set -e

echo "========================================="
echo "  Database Rollback Script"
echo "========================================="

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# List available backups
echo -e "${YELLOW}Available backups:${NC}"
ls -lh backups/

# Prompt for backup file
read -p "Enter backup filename to restore (or 'cancel'): " BACKUP_FILE

if [ "$BACKUP_FILE" == "cancel" ]; then
    echo "Rollback cancelled"
    exit 0
fi

if [ ! -f "backups/$BACKUP_FILE" ]; then
    echo -e "${RED}Backup file not found!${NC}"
    exit 1
fi

# Confirm rollback
echo -e "${RED}WARNING: This will restore the database to a previous state!${NC}"
read -p "Are you sure? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Rollback cancelled"
    exit 0
fi

# Stop application
echo -e "${YELLOW}Stopping application...${NC}"
docker-compose stop app

# Restore database
echo -e "${YELLOW}Restoring database from backup...${NC}"
docker exec -i employee-postgres psql -U postgres -d employeedb < "backups/$BACKUP_FILE"

# Restart application
echo -e "${YELLOW}Restarting application...${NC}"
docker-compose up -d

echo -e "${GREEN}Rollback completed successfully!${NC}"
