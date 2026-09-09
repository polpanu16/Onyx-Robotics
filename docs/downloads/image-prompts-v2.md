# บันทึกคำสั่งสร้างภาพ: จากหุ่นยนต์สีดำสู่ ONYX-01

เครื่องมือ: imagegen ในตัว สร้างภาพใหม่ทั้งสองรอบตามคำขอของผู้ใช้

## 1. คำสั่งเริ่มต้น (Zero-shot)

หุ่นยนต์สีดำ

นี่คือข้อความทั้งหมดที่ส่งให้เครื่องมือ ไม่มีภาพอ้างอิงหรือรายละเอียดเพิ่มเติม
ผลลัพธ์: assets/images/onyx-zero-simple.png
AI เลือกรูปร่าง ฉาก แสง และตัวหนังสือบนหุ่นเอง รายละเอียดเหล่านี้ไม่ได้อยู่ในคำสั่ง

## 2. คำสั่งที่ปรับปรุงด้วยตัวอย่าง (Few-shot)

สร้างภาพหุ่นยนต์แปลงร่างสีดำชื่อ ONYX-01 โดยใช้ภาพต้นแบบ ONYX-01 ที่แนบเป็นภาพอ้างอิง รักษาครีบหมวกคู่ ดวงตาแคบสีขาวอมฟ้า เกราะอกทรง V และล้อบริเวณไหล่

ตัวอย่างที่ 1: “นาฬิกาสีดำ” → ใช้พื้นผิวดำด้านและแสงขอบสีเงิน เพื่อให้เห็นรูปทรงชัดเจนบนฉากมืด
ตัวอย่างที่ 2: “รถสปอร์ตสีดำ” → ใช้มุมกล้องต่ำ เผยรายละเอียดโลหะ และมีแสงสีฟ้าอ่อนเพียงเล็กน้อย

นำแนวทางทั้งสองมาใช้กับหุ่นยนต์ ให้มีเกราะดำหลายชั้น กลไกสมจริง และท่ายืนสงบน่าเกรงขาม จัดภาพแนวนอน 16:9 เห็นตั้งแต่เข่าขึ้นไป หุ่นยนต์อยู่ด้านขวา เว้นพื้นที่ว่างด้านซ้ายราว 40% สำหรับข้อความ ฉากสตูดิโอสีดำ มีหุ่นยนต์เพียงตัวเดียว ไม่ใส่รถแยก ตัวหนังสือ โลโก้ หรือลายน้ำ

ภาพอ้างอิง: assets/images/onyx-hero.png ซึ่งออกแบบไว้ก่อนการเปรียบเทียบชุดนี้
ผลลัพธ์ใหม่: assets/images/onyx-refined-v2.png

## ภาพประกอบตัวอย่างที่ใช้ใน Few-shot

สร้างภาพประกอบใหม่ด้วย imagegen และแสดงในหน้า “ปรับคำสั่งด้วยตัวอย่าง” ทั้งบนเว็บไซต์และ PDF

### ตัวอย่างที่ 1: นาฬิกาสีดำ

Use case: product-mockup
Asset type: example image for an AI prompt-engineering lesson on a dark futuristic website and PDF
Primary request: premium black wristwatch demonstrating how controlled rim lighting reveals the form of a dark object
Scene/backdrop: seamless deep-black studio background with faint atmospheric haze
Subject: one original unbranded futuristic wristwatch, matte black case and strap, restrained brushed silver rim and precise mechanical detail
Style/medium: photorealistic high-end product photography
Composition/framing: landscape composition, centered three-quarter close-up, full watch visible, generous clean margins
Lighting/mood: thin cool-white and pale-cyan edge lighting, subtle reflection beneath, dramatic but readable silhouette
Color palette: black, graphite, silver, very small pale-cyan highlights
Materials/textures: matte metal, brushed steel edge, fine rubber strap texture
Constraints: single watch only; no robot; no people; no text; no numbers; no logos; no trademarks; no watermark
Avoid: bright colorful lighting, gold, clutter, excessive bloom

ผลลัพธ์: assets/images/ai-example-black-watch.png

### ตัวอย่างที่ 2: รถสปอร์ตสีดำ

Use case: product-mockup
Asset type: example image for an AI prompt-engineering lesson on a dark futuristic website and PDF
Primary request: original futuristic black sports car demonstrating a low camera angle, visible metallic detail, and restrained pale-blue accent lighting
Scene/backdrop: dark studio hangar with a black floor and light atmospheric haze
Subject: one unbranded black sports car concept, low wide stance, crisp aerodynamic body panels, realistic wheels and mechanical details
Style/medium: photorealistic cinematic automotive photography
Composition/framing: landscape composition, low-angle front three-quarter view, entire car visible, generous clean margins
Lighting/mood: controlled cool-white rim light with subtle pale-cyan accents, dark dramatic mood, readable body silhouette
Color palette: black, graphite, gunmetal, very small pale-cyan highlights
Materials/textures: matte and satin black bodywork, brushed metal details, realistic rubber tires
Constraints: single car only; no robot; no people; no text; no logos; no trademarks; no watermark
Avoid: neon rainbow colors, city traffic, motion blur, excessive bloom

ผลลัพธ์: assets/images/ai-example-black-car.png

## หลักการเปรียบเทียบ

รอบแรกระบุเพียงสิ่งที่ต้องการ รอบพัฒนาเพิ่มลักษณะเฉพาะ ตัวอย่างการใช้แสง และหน้าที่ของภาพ ตัวอย่างทำให้เป็น few-shot ส่วนภาพอ้างอิงช่วยรักษาเอกลักษณ์ของ ONYX-01

ภาพและคำสั่งชุดเก่ายังอยู่ใน image-prompts.md เพื่อให้ย้อนดูที่มาได้ ภาพ AI ไม่ใช่แบบวิศวกรรมที่รับรองว่าสร้างได้จริง
