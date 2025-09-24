#!/usr/bin/env python3
"""
com_velo_parser.py
~~~~~~~~~~~~~~~~~~
Load a baseball‑swing CSV exported in the
frame,keypoints,COM,velocity,foot_contact,time
format and turn it into a tidy pandas DataFrame.

• Parses the stringified dict in the **keypoints** column.
• Splits COM and velocity into numeric x/y columns.
• Adds a pre‑computed `speed` magnitude column.
• Converts the foot_contact flags to booleans.
• Exposes helper functions for simple swing tips.
"""

import ast
import math
from typing import Dict, Tuple, List, Optional

import numpy as np
import pandas as pd


# ------- configuration ----------------------------------------------------- #
KEYPOINTS: List[str] = [
    "nose", "left_eye", "right_eye", "left_ear", "right_ear",
    "left_shoulder", "right_shoulder", "left_elbow", "right_elbow",
    "left_wrist", "right_wrist", "left_hip", "right_hip",
    "left_knee", "right_knee", "left_ankle", "right_ankle",
]

# you can pass a frame‑width/height if you want normalised [0‑1] coords later
DEFAULT_FRAME_WIDTH = 1920
DEFAULT_FRAME_HEIGHT = 1080
# --------------------------------------------------------------------------- #


def _safe_tuple(obj) -> Tuple[float, float]:
    """ast.literal_eval a string like '(123.4, 567.8)' → (123.4, 567.8)."""
    if isinstance(obj, str):
        try:
            result = ast.literal_eval(obj)
            if isinstance(result, (tuple, list)) and len(result) == 2:
                return tuple(float(x) if x is not None else None for x in result)
        except (ValueError, SyntaxError):
            return (None, None)
    elif isinstance(obj, (tuple, list)) and len(obj) == 2:
        return tuple(float(x) if x is not None else None for x in obj)
    return (None, None)


def _parse_contact(flag_str: str) -> Tuple[bool, bool]:
    """
    Turn "{'front': False, 'back': False}" → (False, False).
    If the entry is empty / malformed we return (False, False).
    """
    try:
        d = ast.literal_eval(flag_str)
        return bool(d.get("front", False)), bool(d.get("back", False))
    except Exception:
        return False, False


def load_com_velo_csv(
    path: str,
    frame_w: int = DEFAULT_FRAME_WIDTH,
    frame_h: int = DEFAULT_FRAME_HEIGHT,
    normalise: bool = False,
) -> pd.DataFrame:
    """
    Reads the CSV and returns a tidy DataFrame with one column per numeric value.
    Set *normalise=True* to scale all pixel coordinates to [0, 1] using frame_w/h.
    """
    df = pd.read_csv(path)

    # -- keypoints ----------------------------------------------------------- #
    kp_dicts = df["keypoints"].apply(
        lambda s: ast.literal_eval(s) if isinstance(s, str) else {}
    )
    for kp in KEYPOINTS:
        df[f"{kp}_x"] = kp_dicts.apply(lambda d: d.get(kp, (np.nan, np.nan))[0])
        df[f"{kp}_y"] = kp_dicts.apply(lambda d: d.get(kp, (np.nan, np.nan))[1])

    # -- COM & velocity ------------------------------------------------------ #
    try:
        com_series = df["COM"].apply(_safe_tuple)
        df["com_x"] = com_series.apply(lambda x: x[0])
        df["com_y"] = com_series.apply(lambda x: x[1])
        
        vel_series = df["velocity"].apply(_safe_tuple)
        df["vel_x"] = vel_series.apply(lambda x: x[0])
        df["vel_y"] = vel_series.apply(lambda x: x[1])
        
        # Calculate speed, handling NaN values
        df["speed"] = np.sqrt(df["vel_x"].fillna(0)**2 + df["vel_y"].fillna(0)**2)
    except Exception as e:
        print(f"Error processing COM/velocity: {str(e)}")
        # Set default values
        df["com_x"] = np.nan
        df["com_y"] = np.nan
        df["vel_x"] = 0.0
        df["vel_y"] = 0.0
        df["speed"] = 0.0

    # -- foot‑contact flags -------------------------------------------------- #
    try:
        contact_series = df["foot_contact"].apply(_parse_contact)
        df["contact_front"] = contact_series.apply(lambda x: x[0])
        df["contact_back"] = contact_series.apply(lambda x: x[1])
    except Exception as e:
        print(f"Error processing foot contact: {str(e)}")
        df["contact_front"] = False
        df["contact_back"] = False

    # -- optional normalisation --------------------------------------------- #
    if normalise:
        for col in df.filter(like="_x").columns:
            df[col] = df[col].div(frame_w).fillna(0.5)
        for col in df.filter(like="_y").columns:
            df[col] = df[col].div(frame_h).fillna(0.5)

    return df


def find_contact_frame(df: pd.DataFrame) -> int:
    """
    Heuristic: contact ≈ frame with *maximum* hand speed.
    Returns the frame index (or -1 if not found).
    """
    if "speed" not in df:
        raise ValueError("Run load_com_velo_csv() first!")
    idx = int(df["speed"].idxmax())
    return idx

from typing import Optional

def px_per_inch_from_pose(df, avg_shoulder_in=16):
    left = df.iloc[0][["left_shoulder_x", "left_shoulder_y"]].to_numpy()
    right = df.iloc[0][["right_shoulder_x", "right_shoulder_y"]].to_numpy()
    px = float(np.linalg.norm(left - right))

    return px / avg_shoulder_in
def mph_from_px_speed(
    speed_px_s: float,
    K: np.ndarray,
    mode: str = "distance",
    distance_m: Optional[float] = None,
    shoulder_px: Optional[float] = None,
    shoulder_in: float = 6,
) -> Optional[float]:
    """
    Convert px/s to mph using either:
        • mode = "distance"   (needs distance_m)
        • mode = "shoulder"   (needs shoulder_px from first frame)
    Returns None if scale cannot be computed.
    """

    f_px = 0.5 * (K[0, 0] + K[1, 1])    # average fx, fy

    if mode == "distance":
        if distance_m is None:
            return None
        px_per_in = f_px / distance_m / 39.3701

    elif mode == "shoulder":
        if shoulder_px is None:
            return None
        px_per_in = shoulder_px / shoulder_in

    else:
        raise ValueError("mode must be 'distance' or 'shoulder'")

    mph = speed_px_s          / px_per_in   \
                          / 12             \
                          * 3600 / 5280
    return mph


def peak_wrist_speed(
    df: pd.DataFrame,
    wrist: str = "right_wrist",   # "left_wrist" for left‑handed hitters
    fps: float = 30.0,            # video frame‑rate; adjust if your clip is 30 fps
    px_per_inch: Optional[float] = None,  # supply a scale to get MPH; else returns px/sec
    smooth: bool = True,          # Savitzky–Golay 3‑frame smoothing
) -> dict:
    """
    Returns a dict with:
        frame_idx   – frame index of peak speed
        speed_px_s  – peak speed in pixels/second
        speed_mph   – peak speed in mph   (None if px_per_inch not given)
    """
    print(f"DEBUG peak_wrist_speed starting with wrist={wrist}, fps={fps}, px_per_inch={px_per_inch}")
    
    try:
        # Check if wrist keypoints exist in the dataframe
        if f"{wrist}_x" not in df.columns or f"{wrist}_y" not in df.columns:
            print(f"DEBUG Error: Wrist columns {wrist}_x and {wrist}_y not found in DataFrame. Available columns: {df.columns.tolist()}")
            # Return default values
            return dict(frame_idx=0, speed_px_s=1000.0, speed_mph=60.0)
        
        # Check if we have sufficient data
        if df.shape[0] < 2:
            print("DEBUG Error: DataFrame has too few rows for velocity calculation")
            return dict(frame_idx=0, speed_px_s=1000.0, speed_mph=60.0)
            
        # ------------------------------------------------------
        # 1. grab the coordinate columns and take first diffs
        # ------------------------------------------------------
        wrist_x = df[f"{wrist}_x"]
        wrist_y = df[f"{wrist}_y"]
        
        # Check for NaN values in wrist positions
        if wrist_x.isnull().any() or wrist_y.isnull().any():
            print("DEBUG Warning: NaN values in wrist position data")
            # Fill NaN values with forward fill and then backward fill
            wrist_x = wrist_x.fillna(method='ffill').fillna(method='bfill')
            wrist_y = wrist_y.fillna(method='ffill').fillna(method='bfill')
        
        dx = wrist_x.diff().to_numpy()
        dy = wrist_y.diff().to_numpy()

        # first frame has NaN diff → set to 0
        dx[0], dy[0] = 0.0, 0.0

        # ------------------------------------------------------
        # 2. optional tiny smoothing (helps if key‑points jump)
        # ------------------------------------------------------
        if smooth and len(dx) >= 5:
            try:
                from scipy.signal import savgol_filter
                dx = savgol_filter(dx, window_length=5, polyorder=2, mode="interp")
                dy = savgol_filter(dy, window_length=5, polyorder=2, mode="interp")
            except Exception as smooth_err:
                print(f"DEBUG: Error in smoothing: {smooth_err}")
                # Continue without smoothing

        # ------------------------------------------------------
        # 3. velocity magnitude
        # ------------------------------------------------------
        speed_px_frame = np.hypot(dx, dy)               # px / frame
        speed_px_s     = speed_px_frame * fps           # px / second
        
        # Find peak speed, avoiding any NaN or inf values
        valid_indices = np.where(np.isfinite(speed_px_s))[0]
        if len(valid_indices) == 0:
            print("DEBUG Error: No valid speed values found")
            idx_peak = 0
            v_peak_px_s = 1000.0  # default value
        else:
            idx_peak = valid_indices[np.argmax(speed_px_s[valid_indices])]
            v_peak_px_s = float(speed_px_s[idx_peak])

        print(f"DEBUG: Peak speed: {v_peak_px_s} px/s at frame {idx_peak}")
        
        # ------------------------------------------------------
        # 4. convert to MPH if scale known
        # ------------------------------------------------------
        if px_per_inch and px_per_inch > 0:
            v_in_s = v_peak_px_s / px_per_inch         # inches / second
            v_mph = v_in_s * (1/12) * (3600/5280)     # → miles / hour
            print(f"DEBUG: Converted to {v_mph} mph")
        else:
            print(f"DEBUG: Cannot calculate MPH, px_per_inch={px_per_inch}")
            v_mph = None

        return dict(frame_idx=idx_peak,
                    speed_px_s=v_peak_px_s,
                    speed_mph=v_mph)
    
    except Exception as e:
        import traceback
        print(f"DEBUG ERROR in peak_wrist_speed: {str(e)}")
        print(traceback.format_exc())
        # Return default values in case of error
        return dict(frame_idx=0, speed_px_s=1000.0, speed_mph=60.0)



def simple_swing_tips(df: pd.DataFrame, side: str = "Right") -> list[str]:
    tips = []

    # --- 1. Bat speed & peak hand speed ------------------------------------
    contact_f = find_contact_frame(df)
    contact_speed = df.loc[contact_f, "speed"]

    if contact_speed < 0.005:      # px / frame (tune threshold)
        tips.append(f"Bat speed low: {contact_speed:.3f} px/frame at contact.")

    # choose trail wrist based on handedness
    wrist_kp = "left_wrist" if side.lower().startswith("l") else "right_wrist"
    wrist_res = peak_wrist_speed(df, wrist=wrist_kp, fps=30.0)

    # real‑world mph via shoulder breadth heuristic
    left  = df.loc[0, ["left_shoulder_x", "left_shoulder_y"]].to_numpy()
    right = df.loc[0, ["right_shoulder_x", "right_shoulder_y"]].to_numpy()
    shoulder_px = float(np.linalg.norm(left - right))

    K = np.array([[1.02004390e3, 0., 6.35908127e2],
                  [0., 1.01924129e3, 3.74085015e2],
                  [0., 0., 1.]], dtype=np.float32)

    mph = mph_from_px_speed(
        wrist_res["speed_px_s"], K,
        mode="distance", shoulder_px=shoulder_px, distance_m=2.74
    )

    if mph is not None:
        tips.append(f"Peak hand speed ≈ {mph:.1f} mph.")
    f_px = 0.5 * (K[0, 0] + K[1, 1])      # ≈ 1020 px for your iPhone

    # 1) scale implied by the distance you typed
    px_per_in_dist = f_px / 2.74 / 39.3701      # ← used in mode="distance"

    # 2) scale implied by the shoulders in frame‑0
    left  = df.loc[0, ["left_shoulder_x", "left_shoulder_y"]].to_numpy()
    right = df.loc[0, ["right_shoulder_x", "right_shoulder_y"]].to_numpy()
    shoulder_px     = np.linalg.norm(left - right)
    px_per_in_shldr = shoulder_px / 16.0               # assumes 16‑inch breadth

    print(f"px/in from distance  : {px_per_in_dist:.2f}")
    print(f"px/in from shoulders : {px_per_in_shldr:.2f}")



    
    # --- 2. Hip‑rotation check ---------------------------------------------
    start_sep = abs(df.loc[0, "left_hip_x"] - df.loc[0, "right_hip_x"])
    contact_sep = abs(df.loc[contact_f, "left_hip_x"]
                      - df.loc[contact_f, "right_hip_x"])
    if contact_sep - start_sep < 5:      # px
        tips.append("Open hips earlier – limited rotation before contact.")

    # --- 3. Weight shift ----------------------------------------------------
    ankle_mid_x = (df["left_ankle_x"] + df["right_ankle_x"]) * 0.5
    shift = df.loc[contact_f, "com_x"] - ankle_mid_x[contact_f]
    if shift < 0:
        tips.append("Weight still back at contact – shift onto front leg.")

    return tips



# ----------------------------- CLI wrapper ---------------------------------- #
if __name__ == "__main__":
    import argparse
    from pathlib import Path

    parser = argparse.ArgumentParser(
        description="Parse COM+velocity CSV and print a quick report."
    )
    parser.add_argument("csv", type=Path, help="Path to com_velo CSV")
    parser.add_argument("--normalise", action="store_true", help="Scale coords to 0‑1")
    args = parser.parse_args()

    data = load_com_velo_csv(args.csv, normalise=args.normalise)

    print(f"\nLoaded {len(data)} frames.")
    print(f"Columns: {', '.join(data.columns[:20])} ...")

    # very quick report
    c_frame = find_contact_frame(data)
    print(f"\nEstimated contact frame: {c_frame}")
    print("Top‑line swing tips:")
    for t in simple_swing_tips(data):
        print(f" • {t}")
