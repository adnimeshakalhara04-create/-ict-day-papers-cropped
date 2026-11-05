#!/usr/bin/env python3
"""Reproducibly extract original PHY 28–32 question/marking crops from source PDFs."""
import argparse
import re
from pathlib import Path
from collections import defaultdict
import fitz

ANSWERS = {
    28: [5, 1, 1, 2, 1, 3, 4, 2],
    29: [3, 2, 4, 4, 1, 5, 5, 1],
    30: [1, 2, 3, 3, 3, 4, 2, 1],
    31: [5, 1, 1, 4, 2],
    32: [4, 3, 4, 3, 2],
}

def sections(pdf, count, paper=False):
    starts = []
    for page_idx, page in enumerate(pdf):
        for x0, y0, x1, y1, token, *_ in page.get_text("words"):
            m = re.fullmatch(r"(\d{1,2})\.", token)
            if 49 <= x0 <= 54 and m:
                starts.append((page_idx, y0, int(m.group(1))))
    starts.sort()
    if [q for pg, y, q in starts] != list(range(1, count + 1)):
        raise ValueError(f"Question numbering mismatch: {starts}")
    sections = defaultdict(list)
    for i, (p0, y0, q) in enumerate(starts):
        if i + 1 < len(starts):
            p1, y1, _ = starts[i + 1]
        else:
            p1, y1 = len(pdf) - 1, 790
            if paper:
                heads = [w[1] for w in pdf[-1].get_text("words") if w[4] == "Answers:"]
                if len(heads) != 1 or heads[0] <= y0:
                    raise ValueError("Missing last-page answer grid")
                y1 = heads[0] - 6
        for pi in range(p0, p1 + 1):
            top = max(41, y0 - 7 if pi == p0 else 45)
            # Keep the complete final answer-option line without including the answer key.
            if paper and i == len(starts) - 1 and pi == p1:
                bottom = min(790, y1 + 5)  # 1 pt above the printed 'Answers:' grid
            else:
                bottom = min(790, y1 - 7 if pi == p1 else 789)
            # Ignore tiny blank page-edge strips that were mistaken for marking parts.
            if bottom - top > 40:
                sections[q].append((pi, fitz.Rect(48, top, 549, bottom)))
    return sections

def text_in(pdf, clips):
    parts = []
    for pi, rect in clips:
        parts.extend(w[4] for w in pdf[pi].get_text("words")
                     if rect.y0 <= w[1] < rect.y1 and 48 <= w[0] <= 551)
    return " ".join(parts)

def marking_answer(text):
    m = re.findall(r"(?i)\bAnswer\s*:\s*([1-5])\s*\)", text)
    if m: return int(m[0])
    m = re.findall(r"(?i)\bcorrect answer\s+is\s+([1-5])\s*\)", text)
    if m: return int(m[-1])
    return None

def crop(pdf, areas, output, q, marking):
    output.mkdir(parents=True, exist_ok=True)
    for idx, (page, box) in enumerate(areas, start=1):
        part = f"-{idx:02d}" if marking and len(areas) > 1 else ""
        fname = output / f"q-{q:02d}{part}.jpg"
        pixels = pdf[page].get_pixmap(matrix=fitz.Matrix(2.4, 2.4),
                                      clip=box, alpha=False, colorspace=fitz.csRGB)
        jpg = pixels.tobytes("jpeg", jpg_quality=88)
        if len(jpg) < 2000:
            raise ValueError(f"Unexpectedly empty crop {fname}")
        fname.write_bytes(jpg)

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--sources", default="sources/phy28-32")
    p.add_argument("--assets", default="assets")
    args = p.parse_args()
    root, assets = Path(args.sources), Path(args.assets)
    qc = mc = 0
    for n, answers in ANSWERS.items():
        questions = fitz.open(root / f"PHY{n}.pdf")
        marking = fitz.open(root / f"PHY{n}_MARKING.pdf")
        qs = sections(questions, len(answers), paper=True)
        ms = sections(marking, len(answers))
        table = questions[-1].get_text("text").split("Answers:")[-1]
        pairs = re.findall(r"(?m)^\s*(\d{1,2})\.\s*\n\s*([1-5])\s*$", table)
        if [int(i) for i, a in pairs] != list(range(1, len(answers)+1)) or [int(a) for i,a in pairs] != answers:
            raise ValueError(f"PHY {n}: question-paper answer table mismatch")
        folder = f"phy-{n:02d}"
        for q, answer in enumerate(answers, start=1):
            if len(qs[q]) != 1:
                raise ValueError(f"PHY {n}, Q{q}: question spans pages")
            if marking_answer(text_in(marking, ms[q])) != answer:
                raise ValueError(f"PHY {n}, Q{q}: marking answer mismatch")
            crop(questions, qs[q], assets/"questions"/folder, q, False)
            crop(marking, ms[q], assets/"markings"/folder, q, True)
            qc += 1
            mc += len(ms[q])
        print(f"Verified original PHY {n}: {len(answers)} questions")
    if (qc, mc) != (34, 49):
        raise ValueError(f"Wrong new crop totals: {qc} questions, {mc} markings")
    print(f"Verified original-source PHY 28–32 crops: {qc} questions, {mc} markings.")

if __name__ == "__main__":
    main()
