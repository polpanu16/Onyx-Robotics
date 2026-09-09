"""Clean the requested stale sentence and render actual PDF evidence."""
from pathlib import Path
import shutil
import pymupdf as fitz

root = Path(__file__).resolve().parents[1]
pdf = root / 'web/downloads/onyx_few.pdf'
archive = root / 'output/pdf/archive/onyx_few-original-overleaf.pdf'
archive.parent.mkdir(parents=True, exist_ok=True)
if not archive.exists():
    shutil.copy2(pdf, archive)
doc = fitz.open(pdf)
sentence = 'The document source should be compiled and inspected in Overleaf before submission.'
count = 0
for page in doc:
    rectangles = page.search_for(sentence)
    if not rectangles and page.search_for('before submission.'):
        rectangles = page.search_for('The document source should be compiled and in-', flags=0)
        rectangles += page.search_for('spected in Overleaf before submission.', flags=0)
        assert len(rectangles) == 2, 'Unexpected PDF layout; leave original unchanged.'
    for rect in rectangles:
        page.add_redact_annot(rect, fill=(1, 1, 1))
        count += 1
    if rectangles:
        page.apply_redactions(images=0, graphics=0)
if count:
    temporary = pdf.with_suffix('.clean.pdf')
    doc.save(temporary, garbage=4, deflate=True)
    doc.close()
    temporary.replace(pdf)
else:
    doc.close()
check = fitz.open(pdf)
assert 'before submission' not in ''.join(p.get_text() for p in check)
check.close()
for filename, prefix in [('onyx_zero.pdf', 'overleaf-zero'), ('onyx_few.pdf', 'overleaf-few')]:
    with fitz.open(root / 'web/downloads' / filename) as document:
        for i, page in enumerate(document):
            page.get_pixmap(matrix=fitz.Matrix(2, 2), alpha=False).save(
                root / f'assets/images/{prefix}-{i+1}.png')

notebook = fitz.open(root / 'web/downloads/ONYX-01_Digital_Simulation.pdf')
previews = root / 'tmp/pdfs/notebooklm'
previews.mkdir(parents=True, exist_ok=True)
sheet = fitz.open()
canvas = sheet.new_page(width=1280, height=360 * ((len(notebook) + 1) // 2))
for i, page in enumerate(notebook):
    pix = page.get_pixmap(matrix=fitz.Matrix(1, 1), alpha=False)
    pix.save(previews / f'page-{i+1:02}.png')
    x, y = (i % 2) * 640, (i // 2) * 360
    canvas.insert_image(fitz.Rect(x, y, x+640, y+360), pixmap=pix)
canvas.get_pixmap().save(previews / 'contact-sheet.png')
print(f'Overleaf sentence removed; original archived. NotebookLM: {len(notebook)} pages rendered.')
