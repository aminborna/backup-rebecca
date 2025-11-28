#!/bin/bash

DB_HOST="localhost"
DB_NAME="rebecca"
DB_USER="root"
DB_PASS="pass"

BACKUP_DIR="/opt/backup/sql"

CONFIG_BACKUP_DIR="/opt/backup/rebecca"

DATE=$(date +"%Y%m%d_%H%M%S")
FILE_NAME="${DB_NAME}_${DATE}.sql"
FILE_PATH="${BACKUP_DIR}/${FILE_NAME}"

CONFIG_ARCHIVE_NAME="rebecca_${DATE}.zip"
CONFIG_ARCHIVE_PATH="${CONFIG_BACKUP_DIR}/${CONFIG_ARCHIVE_NAME}"

BOT_TOKEN="token"
CHAT_ID="id_admin"

mkdir -p /opt/backup
mkdir -p "$BACKUP_DIR"
mkdir -p "$CONFIG_BACKUP_DIR"

FLAG_FILE="/opt/backup/.first_run_done"
if [ ! -f "$FLAG_FILE" ]; then
  curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
       -d chat_id="${CHAT_ID}" \
       -d text="🔥 تست موفقیت‌آمیز بود! اسکریپت بکاپ فعال شد و از این به بعد بکاپ‌ها به‌صورت خودکار ارسال می‌شن 😉✨"
  touch "$FLAG_FILE"
fi

if mysqldump \
    --host="$DB_HOST" \
    --user="$DB_USER" \
    --password="$DB_PASS" \
    --routines --triggers --events \
    --add-drop-table \
    --default-character-set=utf8mb4 \
    "$DB_NAME" > "$FILE_PATH"; then
    
  gzip -f "$FILE_PATH"
  ARCHIVE_PATH="${FILE_PATH}.gz"

  if [ -f "$ARCHIVE_PATH" ]; then
    CAPTION=$'🔥 '"**${DB_NAME}**"$'\n⏰ '"$(date +'%H:%M:%S')"
    curl -s -F document=@"$ARCHIVE_PATH" \
         -F chat_id="$CHAT_ID" \
         -F caption="$CAPTION" \
         -F parse_mode=Markdown \
         "https://api.telegram.org/bot${BOT_TOKEN}/sendDocument" >/dev/null
  fi

  ls -t "$BACKUP_DIR"/*.gz 2>/dev/null | tail -n +2 | xargs -r rm --

  (
    cd / || exit 1
    zip -r "$CONFIG_ARCHIVE_PATH" \
      opt/rebecca/.env \
      opt/rebecca/docker-compose.yml \
      var/lib/rebecca/xray_config.json
  )

  if [ -f "$CONFIG_ARCHIVE_PATH" ]; then
    CAPTION_FILES=$'🗂 بکاپ فایل‌های rebecca\n⏰ '"$(date +'%H:%M:%S')"
    curl -s -F document=@"$CONFIG_ARCHIVE_PATH" \
         -F chat_id="$CHAT_ID" \
         -F caption="$CAPTION_FILES" \
         "https://api.telegram.org/bot${BOT_TOKEN}/sendDocument" >/dev/null
  fi

  ls -t "$CONFIG_BACKUP_DIR"/*.zip 2>/dev/null | tail -n +2 | xargs -r rm --

else
  curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
       -d chat_id="${CHAT_ID}" \
       -d text="❌ خطا در گرفتن بکاپ از دیتابیس ${DB_NAME} در ${DATE} – لطفاً سرور را چک کن." >/dev/null
  exit 1
fi
