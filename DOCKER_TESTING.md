# Docker Testing Guide

คู่มือการทดสอบ MSME Keycloak Theme ด้วย Docker

## 🚀 Quick Start

### วิธีที่ 1: ใช้ Automated Test Script (แนะนำ)

```bash
# รัน script ทดสอบอัตโนมัติ
./scripts/test-with-docker.sh
```

Script นี้จะ:
- ✅ ตรวจสอบ Docker installation
- ✅ Start Keycloak 26.0.4 container
- ✅ Mount theme directory
- ✅ รอให้ Keycloak พร้อม
- ✅ ทดสอบ endpoints อัตโนมัติ
- ✅ ตรวจสอบ logs หา errors
- ✅ แสดง summary และคำแนะนำ

### วิธีที่ 2: Manual Docker Run

```bash
# Start Keycloak container
docker run -d \
  --name keycloak-test \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -v $(pwd):/opt/keycloak/themes/msme-bigdata \
  quay.io/keycloak/keycloak:26.0.4 \
  start-dev \
  --spi-theme-static-max-age=-1 \
  --spi-theme-cache-themes=false \
  --spi-theme-cache-templates=false

# รอ 60 วินาที
sleep 60

# เปิด browser
open http://localhost:8080
```

### วิธีที่ 3: Docker Compose

```bash
# Start
docker compose -f docker-compose.test.yml up -d

# View logs
docker compose -f docker-compose.test.yml logs -f keycloak

# Stop
docker compose -f docker-compose.test.yml down
```

---

## 📋 ขั้นตอนการทดสอบแบบละเอียด

### 1. เริ่ม Keycloak Container

```bash
cd /path/to/msme-bigdata-keycloak-theme
./scripts/test-with-docker.sh
```

**Output ที่คาดหวัง:**
```
======================================
Keycloak Theme Testing Script
======================================

[INFO] Checking Docker installation...
[SUCCESS] Docker is installed
[INFO] Cleaning up existing containers...
[SUCCESS] Cleanup complete
[INFO] Theme directory: /path/to/msme-bigdata-keycloak-theme
[INFO] Starting Keycloak 26.0.4 container...
[SUCCESS] Keycloak container started
[INFO] Waiting for Keycloak to start (max 120s)...
..........
[SUCCESS] Keycloak is ready!
```

### 2. รอให้ Keycloak Start

Keycloak จะใช้เวลาประมาณ **30-90 วินาที** ในการ start

**สัญญาณว่า ready:**
- ✅ Script แสดง "[SUCCESS] Keycloak is ready!"
- ✅ Health endpoint ตอบกลับ: `curl http://localhost:8080/health/ready`
- ✅ Logs แสดง "Listening on: http://0.0.0.0:8080"

### 3. ทดสอบ Welcome Page

```bash
# Test ด้วย curl
curl http://localhost:8080

# หรือเปิด browser
open http://localhost:8080
```

**สิ่งที่ต้องตรวจสอบ:**
- ✅ Page โหลดได้ (HTTP 200)
- ✅ แสดง "Welcome to Keycloak"
- ✅ มี Administration Console link
- ✅ Layout ถูกต้อง

### 4. Login และเปิดใช้ Theme

#### 4.1 เข้า Admin Console

```bash
# เปิด browser
open http://localhost:8080/admin
```

**Login:**
- Username: `admin`
- Password: `admin`

#### 4.2 ตั้งค่า Theme

1. ไปที่ **Realm Settings** (เมนูซ้าย)
2. คลิกแท็บ **Themes**
3. เลือก `msme-bigdata` สำหรับ:
   - **Login theme**
   - **Account theme**
   - **Admin console theme**
   - **Email theme**
   - **Welcome theme** (ไม่จำเป็นต้องเลือกถ้าไม่มีใน dropdown)
4. คลิก **Save**

**Screenshot:**
```
╔═══════════════════════════════════╗
║ Realm Settings                     ║
║ ├─ General                         ║
║ ├─ Login                           ║
║ ├─ Email                           ║
║ └─ Themes ← คลิกที่นี่             ║
╚═══════════════════════════════════╝

Login theme:         [msme-bigdata ▼]
Account theme:       [msme-bigdata ▼]
Admin console theme: [msme-bigdata ▼]
Email theme:         [msme-bigdata ▼]

[Save] [Cancel]
```

### 5. ทดสอบ Login Theme

#### 5.1 Logout

คลิก username มุมขวาบน → **Sign out**

#### 5.2 ทดสอบ Login Page

**URL:** `http://localhost:8080/admin`

**สิ่งที่ต้องตรวจสอบ:**
- ✅ Background image SMEGP แสดง
- ✅ สีน้ำเงิน (#0177c1)
- ✅ ฟอนต์ Kanit สำหรับข้อความไทย
- ✅ Form มี PatternFly styling
- ✅ Responsive layout

#### 5.3 ตรวจสอบ Browser Console

**เปิด DevTools (F12):**

**Console Tab:**
```
✓ ไม่มี errors สีแดง
✓ ไม่มี "Refused to apply style" errors
✓ ไม่มี "Cannot set properties of undefined" errors
```

**Network Tab:**
```
✓ login.css         → 200 OK
✓ tile.css          → 200 OK
✓ login.js          → 200 OK
✓ background images → 200 OK
✓ ไม่มี 404 errors
```

**Elements Tab:**
```html
<body class="login-pf">
  <div class="login-pf-page">
    <!-- PatternFly classes applied correctly -->
  </div>
</body>
```

### 6. ทดสอบ Multi-language

#### 6.1 เปลี่ยนภาษา

ที่มุมล่างขวาของ login page มี language selector

**ทดสอบ:**
1. เลือก **ไทย** → ข้อความแสดงเป็นภาษาไทย
2. เลือก **English** → ข้อความแสดงเป็นภาษาอังกฤษ
3. เลือก **日本語** → ข้อความแสดงเป็นภาษาญี่ปุ่น

**ตรวจสอบ:**
- ✅ ภาษาเปลี่ยนถูกต้อง
- ✅ ฟอนต์ render ได้ดี (โดยเฉพาะภาษาไทยใช้ Kanit)
- ✅ Layout ไม่เพี้ยน

### 7. ทดสอบ Account Console

#### 7.1 Login เข้าไป

Login ด้วย admin/admin

#### 7.2 ไปที่ Account Console

**URL:** `http://localhost:8080/realms/master/account`

**ทดสอบ:**
- ✅ Personal Info page
- ✅ Account Security page
- ✅ Applications page
- ✅ Custom styling applied

### 8. ทดสอบ Responsive Design

#### 8.1 Desktop

**Browser width: 1920px**
- ✅ Layout กว้างเต็ม
- ✅ Login form อยู่กึ่งกลาง
- ✅ Background image แสดงเต็ม

#### 8.2 Tablet

**Browser width: 768px**
- ✅ Layout ปรับเป็น 2 columns
- ✅ Login form responsive
- ✅ ไม่มี horizontal scroll

#### 8.3 Mobile

**Browser width: 375px**
- ✅ Layout เป็น single column
- ✅ Form กว้างเต็มหน้าจอ
- ✅ Touch-friendly buttons

**วิธีทดสอบ:**
```
Chrome DevTools (F12) → Toggle device toolbar (Ctrl+Shift+M)
เลือก device: iPhone 12, iPad, Responsive
```

---

## 🔍 การ Debug

### ดู Keycloak Logs

```bash
# Real-time logs
docker logs -f keycloak-test

# Last 100 lines
docker logs --tail 100 keycloak-test

# Filter for errors
docker logs keycloak-test 2>&1 | grep -i error

# Filter for theme-related logs
docker logs keycloak-test 2>&1 | grep -i theme
```

### เข้าไปใน Container

```bash
# Shell access
docker exec -it keycloak-test bash

# ตรวจสอบ theme files
ls -la /opt/keycloak/themes/msme-bigdata/

# ตรวจสอบ theme cache
ls -la /opt/keycloak/data/tmp/
```

### ปัญหาที่พบบ่อย

#### 1. Theme ไม่ปรากฏใน Dropdown

**สาเหตุ:**
- Theme files ไม่ถูก mount ถูกต้อง
- Keycloak ยังไม่ scan theme directory

**วิธีแก้:**
```bash
# Restart container
docker restart keycloak-test

# หรือลบ cache
docker exec keycloak-test rm -rf /opt/keycloak/data/tmp/kc-gzip-cache/*
docker restart keycloak-test
```

#### 2. CSS ไม่โหลด

**สาเหตุ:**
- File permissions ผิด
- Theme cache ยังไม่ refresh

**วิธีแก้:**
```bash
# ตรวจสอบ permissions
ls -la login/resources/css/

# Fix permissions
chmod -R 755 login/resources/

# Clear browser cache
# Chrome: Ctrl+Shift+Del → Clear cached images and files
```

#### 3. JavaScript Errors

**สาเหตุ:**
- DOM elements ไม่มี
- Script โหลดก่อน DOM ready

**วิธีแก้:**
- ตรวจสอบว่า login.js มี null checking แล้ว (ควรแก้ไขแล้ว)
- ดู browser console สำหรับ error details

#### 4. Container ไม่ Start

**สาเหตุ:**
- Port 8080 ถูกใช้งานอยู่
- Docker resources ไม่พอ

**วิธีแก้:**
```bash
# ตรวจสอบ port
lsof -i :8080

# Kill process ที่ใช้ port
kill -9 <PID>

# หรือใช้ port อื่น
docker run -p 8081:8080 ...
```

---

## 📊 ผลลัพธ์ที่คาดหวัง

### Automated Test Output

```
======================================
Test Summary
======================================

Test 1: Welcome Page
[SUCCESS] Welcome page loads (HTTP 200)
[SUCCESS] Welcome page content loaded

Test 2: Admin Console
[SUCCESS] Admin console loads (HTTP 200)

Test 3: Account Console
[SUCCESS] Account console loads (HTTP 200)

Test 4: Theme Files
[SUCCESS] login.css is accessible
[SUCCESS] login.js is accessible

Test 5: Keycloak Logs
[SUCCESS] No theme errors in logs
[SUCCESS] No CSS loading errors in logs

======================================

[INFO] Keycloak is running at: http://localhost:8080
[INFO] Admin Console: http://localhost:8080/admin
[INFO] Username: admin
[INFO] Password: admin

Testing complete! Container is still running for manual testing.
```

### Browser Console (ควรเป็น)

```
Console (F12):
  ✓ 0 errors
  ✓ 0 warnings about CSS MIME type
  ✓ 0 JavaScript TypeErrors

Network (F12):
  ✓ All CSS files: 200 OK
  ✓ All JS files: 200 OK
  ✓ All images: 200 OK
  ✓ Total size: ~30 MB (due to large images)
  ✓ Load time: 1-3 seconds
```

---

## 🧹 Clean Up

### หยุด Container

```bash
# Stop
docker stop keycloak-test

# Remove
docker rm keycloak-test

# หรือทำพร้อมกัน
docker stop keycloak-test && docker rm keycloak-test
```

### ลบ Images (ถ้าต้องการ)

```bash
# ดู images
docker images | grep keycloak

# ลบ
docker rmi quay.io/keycloak/keycloak:26.0.4
```

### Clean All

```bash
# Stop และลบทุก containers
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# ลบ volumes ที่ไม่ใช้
docker volume prune -f

# ลบ networks ที่ไม่ใช้
docker network prune -f
```

---

## ✅ Checklist การทดสอบ

### Pre-deployment Checklist

- [ ] Validation script ผ่าน (0 errors)
- [ ] Docker test script รันสำเร็จ
- [ ] Welcome page แสดงถูกต้อง
- [ ] Login page มี SMEGP branding
- [ ] Browser console ไม่มี errors
- [ ] CSS files โหลดได้ (200 OK)
- [ ] JavaScript ทำงานไม่ error
- [ ] Multi-language ทำงาน (ทดสอบ TH, EN, JA)
- [ ] Account console accessible
- [ ] Responsive design ทดสอบแล้ว
- [ ] Mobile view ใช้งานได้
- [ ] Tablet view ใช้งานได้
- [ ] Desktop view ใช้งานได้
- [ ] Theme files permissions ถูกต้อง
- [ ] Keycloak logs ไม่มี theme errors
- [ ] Images optimize แล้ว (recommended)

### Production Checklist

- [ ] Theme tested บน Keycloak 26.4.5
- [ ] Backup theme เดิมแล้ว
- [ ] Images optimized
- [ ] Theme cache enabled
- [ ] Documentation updated
- [ ] Rollback plan prepared
- [ ] Monitoring setup
- [ ] User communication sent

---

## 📞 Support

หากพบปัญหา ให้เก็บข้อมูลเหล่านี้:

1. **Screenshot ของ error**
2. **Browser console logs** (F12 → Console tab)
3. **Network logs** (F12 → Network tab)
4. **Keycloak logs**: `docker logs keycloak-test`
5. **Docker version**: `docker --version`
6. **OS และ browser version**

---

**Happy Testing!** 🎉
