#!/bin/bash
# Nạp biến môi trường từ file .env
source /var/opt/mssql/backup/.env

# Kiểm tra xem các biến môi trường có được thiết lập đúng không
if [ -z "$DB_NAME" ] || [ -z "$SA_PASSWORD" ] || [ -z "$BACKUP_DIR_CONTAINER" ] || [ -z "$LOG_DIR_CONTAINER" ]; then
  echo "Một số biến môi trường chưa được thiết lập. Vui lòng kiểm tra file .env."
  exit 1
fi

# Thông tin cơ sở dữ liệu và thư mục sao lưu
DATE=$(date +"%Y-%m-%d")  # Ngày hiện tại
TIMESTAMP=$(date +"%Y%m%d%H%M%S")  # Thời gian hiện tại
BACKUP_FILE="$BACKUP_DIR_CONTAINER/full-backup-$TIMESTAMP.bak"  # Tên file sao lưu trong container
LOG_FILE="$LOG_DIR_CONTAINER/backup.log"  # File lưu nhật ký backup trong container

# Tạo thư mục backup và log nếu chưa tồn tại trong container
mkdir -p $BACKUP_DIR_CONTAINER
mkdir -p $LOG_DIR_CONTAINER

# Thực hiện sao lưu cơ sở dữ liệu
echo "$(date +"%Y-%m-%d %H:%M:%S") - Starting backup for $DB_NAME" >> $LOG_FILE
/opt/mssql-tools/bin/sqlcmd \
  -S localhost -U SA -P "$SA_PASSWORD" \
  -Q "BACKUP DATABASE [$DB_NAME] TO DISK = N'$BACKUP_FILE' WITH COMPRESSION;"

# Kiểm tra xem sao lưu có thành công không
if [ $? -eq 0 ]; then
  echo "$(date +"%Y-%m-%d %H:%M:%S") - Backup for $DB_NAME completed successfully" >> $LOG_FILE
else
  echo "$(date +"%Y-%m-%d %H:%M:%S") - Backup for $DB_NAME failed" >> $LOG_FILE
  exit 1
fi

# Xóa các bản sao lưu cũ hơn 7 ngày
find $BACKUP_DIR_CONTAINER -type f -name "*.bak" -mtime +7 -exec rm -f {} \;

# Ghi log sau khi sao lưu xong và xóa bản sao lưu cũ
echo "$(date +"%Y-%m-%d %H:%M:%S") - Backup completed and old backups removed" >> $LOG_FILE
