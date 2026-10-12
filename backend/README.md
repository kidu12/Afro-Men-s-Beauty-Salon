# AFRO-BARBER — XAMPP / MYSQL BACKEND SETUP GUIDE

This backend provides a high-performance, concurrency-safe REST API for the **Afro-Barber** mobile application using PHP 8+ and MySQL/MariaDB (PDO) on local XAMPP.

---

## 1. Prerequisites
- **XAMPP** (with PHP 8.0+ and MySQL / MariaDB)
- **Apache** and **MySQL** services running in XAMPP Control Panel.

---

## 2. Database Setup (phpMyAdmin)

1. Open your browser and navigate to **[http://localhost/phpmyadmin](http://localhost/phpmyadmin)**.
2. Click **New** in the left sidebar and create a database named:
   ```sql
   Afro_Barber
   ```
   *(Collation: `utf8mb4_unicode_ci`)*
3. Select the `Afro_Barber` database, click the **Import** tab, and import:
   - `backend/database/schema.sql` (Creates tables, foreign keys, and indexes)
   - `backend/database/seed.sql` (Inserts initial branch, demo users, unpriced services, and barbers)

---

## 3. Backend Deployment in XAMPP

1. Copy the entire `backend/` directory into your XAMPP `htdocs/` folder:
   - Path on Windows: `C:\xampp\htdocs\afro_barber_api\`
2. Verify directory structure:
   ```
   C:\xampp\htdocs\afro_barber_api\
   ├── config/
   │   ├── config.php
   │   └── database.php
   ├── controllers/
   ├── middleware/
   ├── public/
   │   ├── index.php
   │   └── .htaccess
   ├── routes/
   ├── services/
   ├── uploads/
   └── utils/
   ```

---

## 4. Test the API

Open your browser or Postman and test the health check endpoint:
- **URL**: `http://localhost/afro_barber_api/public/api/health`
- **Expected Response**:
  ```json
  {
    "success": true,
    "data": {
      "status": "ok",
      "database": "connected",
      "timezone": "Africa/Addis_Ababa"
    }
  }
  ```

---

## 5. Demo Accounts

| Role | Email | Password |
|---|---|---|
| **Admin** | `admin@afrobarber.com` | `password123` |
| **Barber (Mike)** | `mike@afrobarber.com` | `password123` |
| **Customer (Kidus)** | `customer@afrobarber.com` | `password123` |

---

## 6. Running Flutter with the XAMPP Backend

### Android Emulator
The Android emulator accesses host machine's localhost via `10.0.2.2`:
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2/afro_barber_api/public
```

### Physical Android Device (over Wi-Fi)
Find your computer's local network IP (e.g. `192.168.1.100` via `ipconfig`):
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100/afro_barber_api/public
```

### Windows / macOS / Web
```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost/afro_barber_api/public
```
