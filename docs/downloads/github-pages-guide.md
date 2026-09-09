# ONYX-01: อัปโหลดเว็บไซต์ขึ้น GitHub

## 1. เตรียมไฟล์เว็บไซต์

ใช้ชุดไฟล์เว็บไซต์ที่เตรียมสำหรับเผยแพร่แล้ว ให้มีหน้าแรก `index.html` พร้อมโฟลเดอร์ภาพและเอกสารครบถ้วน คงชื่อไฟล์และโครงสร้างโฟลเดอร์เดิม

## 2. สร้างพื้นที่เก็บงาน

เข้าสู่ระบบ GitHub เลือก New repository ตั้งชื่อพื้นที่เก็บงาน แล้วเลือก Public สำหรับการเผยแพร่ด้วยบัญชีฟรี

## 3. อัปโหลดไฟล์

โครงงานนี้เก็บชุดเว็บไซต์ที่พร้อมเผยแพร่ไว้ในโฟลเดอร์ `docs` บนสาขา `main` พร้อมภาพ เอกสาร และไฟล์ `.nojekyll` โดยมีขั้นตอนเผยแพร่อัตโนมัติใน `.github/workflows/deploy.yml`

## 4. เปิดใช้ GitHub Pages

1. เปิด Settings > Pages
2. ใน Source เลือก GitHub Actions (ต้องใช้บัญชีที่มีสิทธิ์ตั้งค่า repository)
3. เปิดแท็บ Actions แล้วเลือก Publish ONYX-01 หากยังไม่มีการทำงาน ให้กด Run workflow บนสาขา main
4. รอให้ขั้นตอนเผยแพร่สำเร็จ แล้วเปิดลิงก์เว็บไซต์

## 5. เปิดดูและแชร์ผลงาน

เปิดลิงก์เว็บไซต์ ตรวจหน้าแรกและเมนูทั้ง 6 หัวข้อ จากนั้นลองเปิดภาพ กราฟ และดาวน์โหลด PDF เมื่อแต่ละส่วนเปิดได้ครบแล้วจึงนำลิงก์ไปส่งงาน

ลิงก์เว็บไซต์ ONYX-01:

```text
https://polpanu16.github.io/Onyx-Robotics/
```

พื้นที่เก็บงาน: https://github.com/polpanu16/Onyx-Robotics

## แหล่งข้อมูล

- [การสร้างเว็บไซต์บน GitHub Pages](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site)
- [การเลือกสาขาสำหรับเผยแพร่](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
