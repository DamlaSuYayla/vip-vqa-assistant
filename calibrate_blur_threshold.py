
import argparse
import glob
import json
import os

import cv2
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

RESIZE_LONG_SIDE = 640


def load_labels(annotation_files, blur_votes):
    labels = {}
    for path in annotation_files:
        with open(path) as f:
            data = json.load(f)
        for entry in data:
            flaws = entry.get("flaws")
            if not flaws:
                continue
            name = entry["image"]
            labels[name] = 1 if flaws.get("BLR", 0) >= blur_votes else 0
    return labels


def compute_lap_var(path):
    img = cv2.imread(path, cv2.IMREAD_COLOR)
    if img is None:
        return None
    h, w = img.shape[:2]
    scale = RESIZE_LONG_SIDE / max(h, w)
    if scale < 1.0:
        img = cv2.resize(img, (int(w * scale), int(h * scale)), interpolation=cv2.INTER_AREA)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    return float(cv2.Laplacian(gray, cv2.CV_64F).var())


def find_images(image_dirs):
    found = {}
    for d in image_dirs:
        for ext in ("*.jpg", "*.jpeg", "*.png", "*.JPG"):
            for p in glob.glob(os.path.join(d, "**", ext), recursive=True):
                found[os.path.basename(p)] = p
    return found


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--images", nargs="+", required=True, help="folder(s) of VizWiz images")
    ap.add_argument("--annotations", nargs="+", required=True, help="VizWiz-QualityIssues JSON file(s)")
    ap.add_argument("--blur-votes", type=int, default=3, help="min BLR votes (0-5) to call an image blurry")
    ap.add_argument("--out", default="metrics.csv", help="where to save per-image metrics")
    args = ap.parse_args()

    labels = load_labels(args.annotations, args.blur_votes)
    print(f"Loaded {len(labels)} labelled images (BLR >= {args.blur_votes} => blurry).")

    files = find_images(args.images)
    print(f"Found {len(files)} image files in the given folders.")

    rows = []
    processed = 0
    for name, is_blurry in labels.items():
        path = files.get(name)
        if path is None:
            continue
        lv = compute_lap_var(path)
        if lv is None:
            continue
        rows.append({"filename": name, "lap_var": lv, "is_blurry": is_blurry})
        processed += 1
        if processed % 1000 == 0:
            print(f"  processed {processed} images...")

    df = pd.DataFrame(rows)
    if df.empty:
        print("No overlap between labelled images and image files. Check --images paths / filenames.")
        return

    sharp = df[df.is_blurry == 0].lap_var
    blur = df[df.is_blurry == 1].lap_var
    print(f"\n{len(df)} images matched: {len(sharp)} sharp, {len(blur)} blurry.")
    print(f"  sharp  lap_var: median {np.median(sharp):8.1f}")
    print(f"  blurry lap_var: median {np.median(blur):8.1f}")

    lo, hi = np.percentile(df.lap_var, 1), np.percentile(df.lap_var, 90)
    best = None
    print("\n  threshold   precision   recall     F1   (detecting blurry)")
    shown = set()
    for t in np.linspace(lo, hi, 80):
        pred = df.lap_var < t
        tp = int((pred & (df.is_blurry == 1)).sum())
        fp = int((pred & (df.is_blurry == 0)).sum())
        fn = int((~pred & (df.is_blurry == 1)).sum())
        prec = tp / (tp + fp) if (tp + fp) else 0.0
        rec = tp / (tp + fn) if (tp + fn) else 0.0
        f1 = 2 * prec * rec / (prec + rec) if (prec + rec) else 0.0
        if best is None or f1 > best[3]:
            best = (t, prec, rec, f1)
        b = round(t / 20) * 20
        if b not in shown:
            shown.add(b)
            print(f"  {t:8.1f}    {prec:7.3f}    {rec:7.3f}   {f1:6.3f}")

    t, prec, rec, f1 = best
    print(f"\n>>> Recommended kBlurThreshold = {t:.1f}   (precision {prec:.3f}, recall {rec:.3f}, F1 {f1:.3f})")

    plt.figure(figsize=(8, 5))
    cap = np.percentile(df.lap_var, 95)
    plt.hist(sharp, bins=60, alpha=0.6, label="sharp", color="#1D9E75", range=(0, cap))
    plt.hist(blur, bins=60, alpha=0.6, label="blurry", color="#D85A30", range=(0, cap))
    plt.axvline(100, color="black", linestyle="--", label="threshold 100 (selected)")
    plt.axvline(t, color="gray", linestyle=":", label=f"threshold {t:.0f} (F1-max)")
    plt.xlabel("Laplacian variance (sharpness)")
    plt.ylabel("Image count")
    plt.title(f"Sharp vs blurry (BLR >= {args.blur_votes})")
    plt.legend()
    plt.tight_layout()
    plt.savefig("blur_distribution.png", dpi=130)

    df.to_csv(args.out, index=False)
    print(f"\nSaved histogram -> blur_distribution.png")
    print(f"Saved per-image metrics -> {args.out}")


if __name__ == "__main__":
    main()
