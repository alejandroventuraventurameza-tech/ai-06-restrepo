"""Render all pages for visual inspection; reject unresolved references."""
from pathlib import Path
import hashlib
import re
import subprocess
from PIL import Image, ImageDraw
root = Path("extra/audit/qa-render")
root.mkdir(parents=True, exist_ok=True)
paths = [("slide", Path("presentation"), 4),
         ("derivation", Path("derivation/derivation"), 4),
         ("tutorial", Path("extra/tutorial/tutorial"), 4)]
manifest = []
warnings = []
for stem, base, group in paths:
    log = base.with_suffix(".log").read_text(errors="replace")
    if re.search(r"LaTeX Error|There were undefined references|Citation .* undefined|Reference .* undefined", log):
        raise SystemExit(f"Unresolved reference or error in {base}")
    for line in log.splitlines():
        match = re.search(r"Overfull \\[hv]box \(([\d.]+)pt too (?:wide|high)\)", line)
        if match:
            warnings.append(f"{base}: {line}")
            if float(match.group(1)) > 2:
                print("LAYOUT REVIEW REQUIRED:", line)
    pdf = base.with_suffix(".pdf")
    subprocess.run(["pdfinfo", str(pdf)], check=True)
    subprocess.run(["pdftoppm", "-scale-to", "960", "-png", str(pdf), str(root/stem)], check=True)
    pages = sorted(root.glob(stem+"-*.png"))
    assert pages
    for start in range(0, len(pages), group):
        subset = pages[start:start+group]
        w,h = (800,460) if stem == "slide" else (560,795)
        sheet=Image.new("RGB",(2*w,2*(h+25)),"white")
        draw=ImageDraw.Draw(sheet)
        for j,path in enumerate(subset):
            img=Image.open(path).convert("RGB")
            img.thumbnail((w-10,h))
            x,y=(j%2)*w,(j//2)*(h+25)
            sheet.paste(img,(x+(w-img.width)//2,y))
            draw.text((x+10,y+h+4),path.stem,fill="black")
        sheet.save(root/f"{stem}-sheet-{start//group+1:02d}.jpg",quality=90)
    for p in pages:
        p.unlink()
    for suffix in (".tex",".pdf"):
        p=base.with_suffix(suffix)
        manifest.append(f"{hashlib.sha256(p.read_bytes()).hexdigest()}  {p}")
(root/"SHA256SUMS.txt").write_text("\n".join(manifest)+"\n")
(root/"layout-warnings.txt").write_text("\n".join(warnings)+"\n")
print("Rendered all documents; visual review is required before merge.")
