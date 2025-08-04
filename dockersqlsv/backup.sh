#!/bin/bash

# Thông tin kết nối
DB_NAME="YourDatabaseName"
SA_PASSWORD="YourStrong@Pass1"
BACKUP_DIR="/var/opt/mssql/backup"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP_FILE="$BACKUP_DIR/$DB_NAME-$TIMESTAMP.bak"

# Chạy lệnh backup
docker exec sqlserver-container /opt/mssql-tools/bin/sqlcmd \
  -S localhost -U SA -P "$SA_PASSWORD" \
  -Q "BACKUP DATABASE [$DB_NAME] TO DISK = N'$BACKUP_FILE' WITH INIT, NAME = 'Database Backup';"

echo "Backup completed: $BACKUP_FILE"
