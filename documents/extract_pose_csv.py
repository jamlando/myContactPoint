#!/usr/bin/env python3
"""
extract_pose_csv.py
~~~~~~~~~~~~~~~~~~~
Run YOLO‑v8 Pose on a video and emit **one tidy CSV**:

frame,keypoints,COM,velocity,foot_contact,time

• `keypoints` is a JSON dict {name: [x, y]}        (confidence already filtered)
• `COM`        → midpoint of left/right hip         (pixels, None if hips missing)
• `velocity`   → ΔCOM / dt (px / frame)             first frame = (0,0)
• `foot_contact` dummy placeholder for later logic
• `time` left blank (fill with timestamp if you capture it)

Usage
------
python extract_pose_csv.py --video swing.mp4 --out swing_com_velo.csv
"""
import os
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"

import json, csv, argparse, os, cv2
from pathlib import Path
import numpy as np
from ultralytics import YOLO
import torch.serialization

# Add safe globals for model loading

KEYPOINTS = [
    "nose", "left_eye", "right_eye", "left_ear", "right_ear",
    "left_shoulder", "right_shoulder", "left_elbow", "right_elbow",
    "left_wrist", "right_wrist", "left_hip", "right_hip",
    "left_knee", "right_knee", "left_ankle", "right_ankle",
]

def main(video: Path, out_csv: Path, conf_thr: float = .6):
    # Load model with weights_only=True to avoid pickle compatibility issues
    try:
        print("Attempting to load model with weights_only=True...")
        model = YOLO("yolov8m-pose.pt", task='pose', weights_only=True)
    except Exception as e:
        print(f"Failed with weights_only=True: {str(e)}")
        try:
            print("Trying alternative loading method...")
            # Try compatibility mode for ultralytics models
            import torch
            torch.hub._validate_not_a_forked_repo = lambda a, b, c: True
            model = YOLO("yolov8m-pose.pt", task='pose')
        except Exception as e2:
            print(f"Alternative method also failed: {str(e2)}")
            # Final fallback - try using the public model from Ultralytics
            print("Using fallback to public model...")
            model = YOLO("yolov8m-pose.yaml")  # Load model architecture
            model = YOLO("https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8m-pose.pt")  # Download official weights
    
    # Use CPU if CUDA not available
    device = "cuda" if torch.cuda.is_available() else "cpu"
    print(f"Using device: {device}")
    model.to(device)

    cap = cv2.VideoCapture(str(video))
    fps = cap.get(cv2.CAP_PROP_FPS) or 30.0
    dt  = 1.0 / fps

    out_csv.parent.mkdir(parents=True, exist_ok=True)
    with open(out_csv, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["frame", "keypoints", "COM", "velocity", "foot_contact", "time"])

        prev_com = None
        frame_idx = 0

        # STREAMING inference: yields one Result per frame
        for result in model.predict(source=str(video), conf=conf_thr, stream=True):
            # pick the person with the largest bbox
            best = None
            max_area = 0
            for box, kpts, confs in zip(
                result.boxes.xyxy.cpu().numpy(),
                result.keypoints.xy.cpu().numpy(),
                result.keypoints.conf.cpu().numpy(),
            ):
                x1, y1, x2, y2 = box
                area = (x2 - x1) * (y2 - y1)
                if area > max_area:
                    max_area = area
                    best = (kpts, confs)

            if best is None:
                writer.writerow([frame_idx, "{}", "(None,None)", "(0.0,0.0)", "{}", ""])
                frame_idx += 1
                continue

            kpts_xy, confs = best
            named = {
                name: [float(x), float(y)]
                for name, (x, y), c in zip(KEYPOINTS, kpts_xy, confs)
                if c >= conf_thr
            }

            # compute COM (midpoint of hips)
            if {"left_hip", "right_hip"} <= named.keys():
                x1, y1 = named["left_hip"]
                x2, y2 = named["right_hip"]
                com = ((x1 + x2) / 2.0, (y1 + y2) / 2.0)
            else:
                com = (None, None)

            # compute velocity ΔCOM / dt
            if prev_com and None not in (*com, *prev_com):
                vx = (com[0] - prev_com[0]) / dt
                vy = (com[1] - prev_com[1]) / dt
            else:
                vx, vy = 0.0, 0.0
            prev_com = com

            writer.writerow([
                frame_idx,
                json.dumps(named, separators=(",", ":")),
                json.dumps(com),
                json.dumps((vx, vy)),
                json.dumps({"front": False, "back": False}),
                ""
            ])

            frame_idx += 1

    cap.release()
    print(f"✅ Saved {frame_idx} frames → {out_csv.resolve()}")

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--video", required=True, type=Path)
    p.add_argument("--out",   required=True, type=Path)
    p.add_argument("--conf",  type=float, default=0.6)
    args = p.parse_args()
    main(args.video, args.out, conf_thr=args.conf)
