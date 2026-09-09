import 'package:flutter/material.dart';
import 'browser.dart';
import 'lessons.dart';
import 'main.dart';

const comparisons = <List<(String, String, String)>>[
  [
    ('คำสั่ง', 'ใช้เพียง “หุ่นยนต์สีดำ”', 'ระบุ ONYX-01 พร้อมลักษณะเฉพาะ'),
    (
      'รายละเอียด',
      'AI เลือกรูปร่าง ฉาก และแสงเอง',
      'มีภาพอ้างอิงและตัวอย่างการใช้แสง',
    ),
    ('การใช้บนเว็บ', 'พื้นที่ข้อความไม่ชัดเจน', 'เว้นด้านซ้ายสำหรับชื่อรุ่น'),
  ],
  [
    ('แบบจำลอง', 'เส้นตรงแสดงแนวโน้ม', 'พลังงานหารด้วยกำลังไฟ'),
    (
      'การตรวจค่า',
      'ยังไม่เชื่อมกับแบตเตอรี่',
      'มีค่าตัวอย่าง 0 / 20 / 40 km/h',
    ),
    ('การอธิบาย', 'ความเร็วเพิ่ม เวลาลด', 'ระบุหน่วย โดเมน และข้อจำกัด'),
  ],
  [
    ('โครงสร้าง', 'ลำดับ 3 ขั้น', 'มีเงื่อนไขและ feedback'),
    ('แบตเตอรี่ต่ำ', 'ไม่ระบุ', 'หยุดภารกิจเมื่อเหลือต่ำกว่า 20%'),
    ('สิ่งกีดขวาง', 'ไม่ระบุ', 'หยุดและวางแผนใหม่'),
  ],
  [
    ('เนื้อหา', 'บทความแนะนำสั้น ๆ', 'บทคัดย่อ ตาราง สมการ ข้อจำกัด'),
    ('ข้อมูลกลาง', 'ไม่มีตัวเลขให้เทียบ', 'ใช้แบบจำลองเดียวกับกราฟ'),
    ('หลักฐาน PDF', 'PDF จาก Overleaf 1 หน้า', 'PDF จาก Overleaf 2 หน้า'),
  ],
  [
    ('โจทย์', 'สรุปเอกสารเป็นสไลด์', 'กำหนด 6 หน้าและตัวอย่างโครงหน้า'),
    ('ข้อมูล', 'ใช้เอกสารที่แนบ', 'ย้ำให้ใช้เฉพาะข้อมูลในเอกสาร'),
    ('ไฟล์ประกอบ', 'ฉบับจำลอง 3 หน้า', 'PDF จริงจาก NotebookLM 10 หน้า'),
  ],
  [
    ('รูปแบบ', 'เว็บแนะนำหุ่นยนต์หน้าเดียว', 'หน้าแรกและผลงานแยกตามหัวข้อ'),
    (
      'เนื้อหา',
      'ชื่อรุ่น คำอธิบาย และตารางข้อมูล',
      'Prompt ภาพ กราฟ และเอกสารประกอบ',
    ),
    (
      'การใช้งาน',
      'อ่านข้อมูลพื้นฐาน',
      'ข้ามหัวข้อ คัดลอก Prompt และดาวน์โหลด PDF',
    ),
  ],
];

class ComparisonTable extends StatelessWidget {
  final int index;
  const ComparisonTable({super.key, required this.index});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      if (c.maxWidth < 650) {
        return Column(
          children: [
            for (final row in comparisons[index])
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: edge)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.$1, style: const TextStyle(color: ice)),
                    const SizedBox(height: 8),
                    Text(
                      'ก่อน: ${row.$2}',
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                    Text(
                      'หลัง: ${row.$3}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        );
      }
      return Table(
        columnWidths: const {
          0: FlexColumnWidth(.7),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1.2),
        },
        border: const TableBorder(horizontalInside: BorderSide(color: edge)),
        children: [
          for (final row in [
            ('เกณฑ์เปรียบเทียบ', 'ZERO-SHOT', 'FEW-SHOT'),
            ...comparisons[index],
          ])
            TableRow(
              children: [
                for (final value in [row.$1, row.$2, row.$3])
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                  ),
              ],
            ),
        ],
      );
    },
  );
}

class ChapterDownloads extends StatelessWidget {
  final Lesson lesson;
  const ChapterDownloads({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    final chapterPath = 'downloads/pdfs/onyx-${lesson.id}.pdf';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: panel, border: Border.all(color: edge)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('CHAPTER DOWNLOADS / PDF'),
          const SizedBox(height: 12),
          Text(
            'สไลด์ประกอบหัวข้อ ${lesson.category}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ActionButton(
                'ดาวน์โหลด PDF ทั้งหัวข้อ · 5 หน้า',
                () => openLink(chapterPath),
                primary: true,
                icon: Icons.download,
              ),
              ActionButton(
                'เปิดอ่าน PDF',
                () => viewLink(chapterPath),
                icon: Icons.open_in_new,
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (lesson.id == 'math') ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ActionButton(
                  'กราฟ Zero-shot',
                  () => openLink(desmosZeroShotUrl),
                  icon: Icons.open_in_new,
                ),
                ActionButton(
                  'กราฟรอบปรับปรุง',
                  () => openLink(desmosRefinedUrl),
                  icon: Icons.open_in_new,
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
          if (lesson.id == 'document') ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ActionButton(
                  'PDF Overleaf · Zero-shot',
                  () => viewLink('downloads/onyx_zero.pdf'),
                  icon: Icons.picture_as_pdf,
                ),
                ActionButton(
                  'PDF Overleaf · Few-shot',
                  () => viewLink('downloads/onyx_few.pdf'),
                  icon: Icons.picture_as_pdf,
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
