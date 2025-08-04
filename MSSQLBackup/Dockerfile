FROM mcr.microsoft.com/mssql/server:2022-latest

# Cài đặt các công cụ cần thiết và SQLCMD
USER root
RUN apt-get update && \
    apt-get install -y curl gnupg2 apt-transport-https && \
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg && \
    curl https://packages.microsoft.com/config/ubuntu/22.04/prod.list | tee /etc/apt/sources.list.d/mssql-release.list > /dev/null && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev && \
    ACCEPT_EULA=Y apt-get install -y mssql-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Thêm đường dẫn mssql-tools vào PATH
ENV PATH="/opt/mssql-tools/bin:$PATH"

# Cài đặt cron
RUN apt-get update && apt-get install -y cron

# Sao chép cron job vào container
COPY ./cron_jobs/backup_cron /etc/cron.d/backup_cron
RUN chmod 0644 /etc/cron.d/backup_cron

# Sao chép backup.sh vào container và cấp quyền thực thi
COPY ./backup.sh /var/opt/mssql/backup/backup.sh
RUN chmod +x /var/opt/mssql/backup/backup.sh

# Khởi động cron và SQL Server
CMD /bin/bash -c "cron && /opt/mssql/bin/sqlservr"
