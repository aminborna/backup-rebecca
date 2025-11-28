
# بکاپ‌گیری از پنل ربکا

این اسکریپت برای بکاپ گرفتن از دیتابیس و فایل‌های پنل ربکا و ارسال بکاپ به تلگرام استفاده می‌شود.

---

## 1. نصب پیش‌نیازها

روی سرور (به‌عنوان root) این دستورات را اجرا کنید:

```bash
apt update
apt install -y mysql-client zip curl cron
```

---

## 2. دانلود اسکریپت و قرار دادن در مسیر مناسب

اسکریپت در این مسیر قرار می‌گیرد: `/opt/backup/backup_rebecca.sh`

```bash
mkdir -p /opt/backup
cd /opt/backup

# دانلود اسکریپت از گیت‌هاب
curl -fsSL https://raw.githubusercontent.com/aminborna/backup-rebecca/main/backup-rebecca.sh -o backup_rebecca.sh

# قابل اجرا کردن اسکریپت
chmod +x backup_rebecca.sh
```

---

## 3. تنظیم مقادیر داخل اسکریپت

فایل را باز کنید و تنظیمات دیتابیس و تلگرام را درست کنید:

```bash
nano /opt/backup/backup_rebecca.sh
```

مواردی مثل این‌ها را با مقادیر خودتان عوض کنید:

```bash
DB_HOST="localhost"
DB_NAME="marzadmin"
DB_USER="root"
DB_PASS="رمز دیتابیس"

BOT_TOKEN="توکن_ربات_تلگرام"
CHAT_ID="آیدی_عددی_چت"
```

بعد از ویرایش:
- `CTRL + O` → Enter (ذخیره)
- `CTRL + X` (خروج)

---

## 4. اجرای تست دستی

برای تست‌کردن بکاپ:

```bash
/opt/backup/backup_rebecca.sh
```

اگر همه‌چیز درست باشد:
- بکاپ دیتابیس در `/opt/backup/sql/`
- بکاپ فایل‌ها در `/opt/backup/rebecca/`
- فایل‌ها به تلگرام ارسال می‌شوند.

---

## 5. فعال‌سازی اجرای خودکار (هر ۱ ساعت یک‌بار)

برای اجرای خودکار هر ساعت یک‌بار از کرون استفاده می‌کنیم.

فایل کرون را باز کنید:

```bash
crontab -e
```

اگر ادیتور پرسید، `nano` را انتخاب کنید. سپس این خط را به انتهای فایل اضافه کنید:

```bash
0 * * * * /opt/backup/backup_rebecca.sh >/var/log/backup_rebecca.log 2>&1
```

این خط یعنی:
- هر ساعت، دقیقه ۰ (مثلاً 01:00، 02:00، 03:00، ...) اسکریپت اجرا شود.
- خروجی و خطاها در فایل `/var/log/backup_rebecca.log` ذخیره شود.

ذخیره و خروج:
- `CTRL + O` → Enter
- `CTRL + X`

از این لحظه به بعد، اسکریپت بکاپ هر ۱ ساعت یک‌بار به‌صورت خودکار اجرا می‌شود.
