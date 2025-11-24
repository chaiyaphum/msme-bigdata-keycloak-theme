# Quick Start Testing Guide

เริ่มทดสอบ theme กับ Keycloak 26.4.5 ได้ง่ายๆ ภายใน 5 นาที

## 🚀 ขั้นตอนที่ 1: ตรวจสอบโครงสร้าง Theme

รันสคริปต์ตรวจสอบความถูกต้อง:

```bash
bash scripts/validate-theme.sh
```

**ผลลัพธ์ที่ควรได้:**
- ✅ Total checks: 44
- ✅ Errors: 0
- ⚠️ Warnings: 3 (เรื่องขนาดของภาพซึ่งไม่ส่งผลต่อการทำงาน)

## 🐳 ขั้นตอนที่ 2: รัน Keycloak ด้วย Docker

### วิธีที่ 1: ใช้ Docker Compose (แนะนำ)

```bash
# เริ่ม Keycloak พร้อม PostgreSQL
docker-compose -f docker-compose.test.yml up -d

# ตรวจสอบ logs
docker-compose -f docker-compose.test.yml logs -f keycloak

# รอจนเห็น "Keycloak ... started"
```

### วิธีที่ 2: ใช้ Docker โดยตรง

```bash
docker run -d \
  --name keycloak-test \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -v $(pwd):/opt/keycloak/themes/msme-bigdata \
  quay.io/keycloak/keycloak:26.0.4 \
  start-dev --spi-theme-cache-themes=false
```

## 🌐 ขั้นตอนที่ 3: เข้าถึง Keycloak

รอประมาณ 30-60 วินาทีสำหรับการเริ่มต้น จากนั้นเปิดเบราว์เซอร์:

### Welcome Page
- **URL**: http://localhost:8080
- **ตรวจสอบ**: ดู MSME branding, layout, และลิงก์ต่างๆ

### Admin Console
- **URL**: http://localhost:8080/admin
- **Username**: `admin`
- **Password**: `admin`

## ⚙️ ขั้นตอนที่ 4: เปิดใช้งาน Theme

### 1. เข้า Admin Console

### 2. ไปที่ Realm Settings

คลิก **Realm Settings** ในเมนูด้านซ้าย

### 3. เปิดแท็บ Themes

### 4. เลือก Theme ทั้ง 5 ประเภท

| Theme Type | เลือก |
|------------|-------|
| **Login theme** | `msme-bigdata` |
| **Account theme** | `msme-bigdata` |
| **Admin console theme** | `msme-bigdata` |
| **Email theme** | `msme-bigdata` |
| **Welcome theme** | `msme-bigdata` |

### 5. คลิก Save

## 🧪 ขั้นตอนที่ 5: ทดสอบ Theme

### ทดสอบ Login Theme

1. Logout จาก Admin Console
2. กลับไปที่หน้า Login: http://localhost:8080/admin
3. **ตรวจสอบ:**
   - ✅ สีหลัก (น้ำเงิน #0177c1) ปรากฏ
   - ✅ โลโก้ SMEGP แสดง
   - ✅ พื้นหลังที่กำหนดเอง
   - ✅ ฟอร์ม login มี PatternFly styling
   - ✅ Responsive (ลองย่อหน้าจอ)

### ทดสอบ Account Console

1. Login เข้าไป
2. ไปที่: http://localhost:8080/realms/master/account
3. **ตรวจสอบ:**
   - ✅ Custom styling ปรากฏ
   - ✅ Personal Info page
   - ✅ Account Security page
   - ✅ Applications page

### ทดสอบ Multi-language

1. ที่หน้า Login เลือก Locale dropdown
2. เปลี่ยนเป็น **ไทย (TH)**
3. **ตรวจสอบ:**
   - ✅ ข้อความภาษาไทยแสดงถูกต้อง
   - ✅ ฟอนต์ Kanit render ได้ดี
4. ลองภาษาอื่นๆ:
   - English (EN)
   - Japanese (JA)
   - Chinese (ZH_CN)

### ทดสอบ Welcome Page

1. ไปที่: http://localhost:8080
2. **ตรวจสอบ:**
   - ✅ MSME branding
   - ✅ Links ทำงาน
   - ✅ Layout responsive

## 📧 ขั้นตอนที่ 6: ทดสอบ Email (ถ้าต้องการ)

### เปิดใช้ MailHog

MailHog จะรันอัตโนมัติถ้าใช้ docker-compose.test.yml

- **SMTP**: localhost:1025
- **Web UI**: http://localhost:8025

### ตั้งค่า SMTP ใน Keycloak

1. ไปที่ **Realm Settings** → **Email**
2. ตั้งค่า:
   ```
   Host: mailhog
   Port: 1025
   From: noreply@example.com
   ```
3. คลิก **Save** และ **Test connection**

### ทดสอบส่ง Email

1. สร้าง user ใหม่
2. คลิก **Send test email**
3. ดูผลใน MailHog UI: http://localhost:8025

## 🔍 ตรวจสอบ Browser Console

เปิด DevTools (F12) และตรวจสอบ:

- ✅ **ไม่มี errors** ใน Console tab
- ✅ **ไม่มี 404** ใน Network tab
- ✅ CSS/JS files โหลดสำเร็จทั้งหมด
- ✅ Images โหลดได้

## 📊 Validation Results

### ผลการตรวจสอบล่าสุด

```
=== Validation Summary ===

Total checks: 44
Errors: 0
Warnings: 3

⚠ Theme validation passed with warnings.
Review warnings above for potential improvements.
```

### รายละเอียด Warnings

1. **Welcome theme doesn't use parent=base**
   - ✅ ปกติ - welcome theme ใช้ `import=common/keycloak` แทน

2. **Large images found**
   - ⚠️ มีรูปภาพขนาดใหญ่ (1-15MB):
     - keycloak-smegp-bg6.png: 15.69MB
     - keycloak-smegp-bg4.png: 7.84MB
     - keycloak-smegp-bg.png: 2.35MB
     - keycloak-smegp-bg5.png: 1.13MB
   - 💡 แนะนำ: Optimize ก่อน deploy production

## 🧹 ทำความสะอาด

### หยุด Docker Compose

```bash
docker-compose -f docker-compose.test.yml down

# ลบ volumes ถ้าต้องการเริ่มใหม่
docker-compose -f docker-compose.test.yml down -v
```

### หยุด Docker Container

```bash
docker stop keycloak-test
docker rm keycloak-test
```

## ⚡ Performance Tips

### Development Mode
```bash
# Theme cache ถูกปิดแล้วใน docker-compose.test.yml
# CSS/JS changes จะมีผลทันทีโดยไม่ต้อง restart
```

### Production Mode
```bash
# เปิด caching
docker run -d \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  -v $(pwd):/opt/keycloak/themes/msme-bigdata \
  quay.io/keycloak/keycloak:26.0.4 \
  start --spi-theme-static-max-age=2592000
```

## 🐛 Troubleshooting

### Theme ไม่ปรากฏใน Dropdown

```bash
# ตรวจสอบ logs
docker logs keycloak-test 2>&1 | grep -i theme

# Restart container
docker restart keycloak-test
```

### CSS ไม่โหลด

1. เปิด Browser DevTools (F12)
2. ดู Network tab
3. หาไฟล์ที่ 404
4. ตรวจสอบ path ใน theme.properties

### Images ไม่แสดง

```bash
# ตรวจสอบว่าไฟล์มีจริง
ls -lh login/resources/img/

# ตรวจสอบ permissions
chmod -R 755 login/resources/img/
```

## 📚 เอกสารเพิ่มเติม

- **รายละเอียดการทดสอบ**: ดูที่ [TESTING.md](TESTING.md)
- **การติดตั้ง**: ดูที่ [README.md](README.md)
- **ประวัติการเปลี่ยนแปลง**: ดูที่ [CHANGELOG.md](CHANGELOG.md)

## ✅ Checklist สำหรับ Production

ก่อน deploy ไป production:

- [ ] รันและผ่าน `scripts/validate-theme.sh`
- [ ] ทดสอบทุก theme types (login, account, admin, email, welcome)
- [ ] ทดสอบ multi-language (อย่างน้อย TH, EN)
- [ ] ทดสอบ responsive (mobile, tablet, desktop)
- [ ] ทดสอบใน browsers หลัก (Chrome, Firefox, Safari, Edge)
- [ ] ไม่มี Console errors
- [ ] ไม่มี 404 Network errors
- [ ] Optimize images (ใช้ imagemin หรือคล้ายๆ)
- [ ] Test email templates
- [ ] Performance test (page load < 2s)
- [ ] Backup theme เดิมก่อน deploy

---

**🎉 สำเร็จ!** Theme พร้อมใช้งานกับ Keycloak 26.4.5
