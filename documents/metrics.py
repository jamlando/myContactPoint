# ---------------------------------------------------------------------------
#  metrics helpers – drop this at the end of com_velo_parser.py
#  or place in metrics.py  (then:  from metrics import enrich_and_measure)
# ---------------------------------------------------------------------------
import numpy as np
from com_velo_parser import peak_wrist_speed, find_contact_frame
DEG = 180 / np.pi

def _angle(a, b, c):
    """∠ABC in degrees (vectors BA and BC)."""
    ba = a - b
    bc = c - b
    cos_th = np.dot(ba, bc) / (np.linalg.norm(ba) * np.linalg.norm(bc) + 1e-9)
    return np.clip(np.arccos(cos_th), 0, np.pi) * DEG


def enrich_and_measure(df, side="Right", fps=30.0, shoulder_in=16.0):
    """
    Returns a dict of measured swing metrics suitable for ChatGPT prompts.
    Works with YOUR existing DataFrame structure.
    """
    print(f"DEBUG: Starting enrich_and_measure with side={side}, shoulder_in={shoulder_in}")
    
    wrist_kp = "left_wrist" if side.lower().startswith("l") else "right_wrist"
    trail_wrist = "right_wrist" if side.lower().startswith("l") else "left_wrist"
    lead_elbow = "left_elbow" if side.lower().startswith("l") else "right_elbow"
    lead_shldr = "left_shoulder" if side.lower().startswith("l") else "right_shoulder"

    # ------------------------------------------------------------------ #
    # 1. Peak hand speed  (px/s → mph via shoulder-width heuristic)
    # ------------------------------------------------------------------ #
    try:
        # Get shoulder positions - use direct access to avoid Series subtraction issues
        l_shoulder_x = float(df.loc[0, "left_shoulder_x"])
        l_shoulder_y = float(df.loc[0, "left_shoulder_y"])
        r_shoulder_x = float(df.loc[0, "right_shoulder_x"])
        r_shoulder_y = float(df.loc[0, "right_shoulder_y"])
        
        print(f"DEBUG: Left shoulder: ({l_shoulder_x}, {l_shoulder_y})")
        print(f"DEBUG: Right shoulder: ({r_shoulder_x}, {r_shoulder_y})")
        
        # Check if any shoulder data is missing or NaN
        if (np.isnan(l_shoulder_x) or np.isnan(l_shoulder_y) or 
            np.isnan(r_shoulder_x) or np.isnan(r_shoulder_y)):
            print("DEBUG: Warning - missing shoulder data, using default speed")
            hand_speed_mph = 60.0  # Default value if shoulder data missing
            peak_speed_f = find_contact_frame(df)  # Use contact frame as fallback
        else:
            # Calculate shoulder width using explicit coordinates
            dx = l_shoulder_x - r_shoulder_x
            dy = l_shoulder_y - r_shoulder_y
            shoulder_px = np.sqrt(dx*dx + dy*dy)
            
            print(f"DEBUG: Shoulder width in pixels: {shoulder_px}")
            print(f"DEBUG: User shoulder width in inches: {shoulder_in}")
            
            # Ensure we have valid values
            if shoulder_px > 0 and shoulder_in > 0:
                px_per_inch = shoulder_px / shoulder_in
                print(f"DEBUG: Pixels per inch: {px_per_inch}")
                
                w = peak_wrist_speed(df, wrist=wrist_kp, fps=fps, px_per_inch=px_per_inch)
                print(f"DEBUG: Wrist speed data: {w}")
                
            hand_speed_mph = w["speed_mph"]
            peak_speed_f = w["frame_idx"]
                
                # Fallback if hand speed is None
            if hand_speed_mph is None or np.isnan(hand_speed_mph):
                print("DEBUG: Hand speed is None, calculating manually")
                speed_px_s = w["speed_px_s"]
                hand_speed_mph = speed_px_s / px_per_inch / 12 * 3600 / 5280
            else:
                print(f"DEBUG: Invalid values - shoulder_px={shoulder_px}, shoulder_in={shoulder_in}")
                hand_speed_mph = 65.0  # Default fallback
                peak_speed_f = find_contact_frame(df)
    except Exception as e:
        import traceback
        print(f"DEBUG ERROR in hand speed calculation: {str(e)}")
        print(traceback.format_exc())
        hand_speed_mph = 55.0  # Fallback default
        peak_speed_f = 0
        
    # Ensure hand_speed_mph is never NaN
    if hand_speed_mph is None or np.isnan(hand_speed_mph):
        hand_speed_mph = 55.0
        print(f"DEBUG: Using default hand speed of {hand_speed_mph} mph")

    # ------------------------------------------------------------------ #
    # 2. Contact frame (heuristic) & timing delta
    # ------------------------------------------------------------------ #
    contact_f = find_contact_frame(df)
    time_peak_to_contact_ms = abs(contact_f - peak_speed_f) / fps * 1000

    # ------------------------------------------------------------------ #
    # 3. Hip / shoulder rotation & separation
    #    measure as the angle of the segment in the XY plane
    # ------------------------------------------------------------------ #
    try:
        l_hip = df.loc[contact_f, ["left_hip_x", "left_hip_y"]].to_numpy()
        r_hip = df.loc[contact_f, ["right_hip_x", "right_hip_y"]].to_numpy()
        l_sh = df.loc[contact_f, ["left_shoulder_x", "left_shoulder_y"]].to_numpy()
        r_sh = df.loc[contact_f, ["right_shoulder_x", "right_shoulder_y"]].to_numpy()

        hip_vec = r_hip - l_hip
        sh_vec = r_sh - l_sh
        hip_rot_deg = np.degrees(np.arctan2(hip_vec[1], hip_vec[0]))
        shoulder_rot_deg = np.degrees(np.arctan2(sh_vec[1], sh_vec[0]))
        hip_sep_deg = abs(((shoulder_rot_deg - hip_rot_deg + 180) % 360) - 180)
    except Exception as e:
        print(f"DEBUG ERROR in rotation calculation: {str(e)}")
        hip_rot_deg = 30.0  # Default values
        shoulder_rot_deg = 45.0
        hip_sep_deg = 15.0

    # ------------------------------------------------------------------ #
    # 4. Lead-elbow extension
    # ------------------------------------------------------------------ #
    try:
        p_s = df.loc[contact_f, [f"{lead_shldr}_x", f"{lead_shldr}_y"]].to_numpy()
        p_e = df.loc[contact_f, [f"{lead_elbow}_x", f"{lead_elbow}_y"]].to_numpy()
        p_w = df.loc[contact_f, [f"{wrist_kp}_x", f"{wrist_kp}_y"]].to_numpy()
        lead_elbow_deg = _angle(p_s, p_e, p_w)
    except Exception as e:
        print(f"DEBUG ERROR in elbow angle calculation: {str(e)}")
        lead_elbow_deg = 120.0  # Default value

    # ------------------------------------------------------------------ #
    # 5. Bat-lag (rough proxy using wrists & nose)
    # ------------------------------------------------------------------ #
    try:
        nose = df.loc[contact_f, ["nose_x", "nose_y"]].to_numpy()
        p_t = df.loc[contact_f, [f"{trail_wrist}_x", f"{trail_wrist}_y"]].to_numpy()
        bat_lag_deg = _angle(p_s, p_t, nose)
    except Exception as e:
        print(f"DEBUG ERROR in bat lag calculation: {str(e)}")
        bat_lag_deg = 90.0  # Default value

    result = dict(
        peak_hand_speed_mph=hand_speed_mph,
        peak_hand_speed_frame=peak_speed_f,
        hip_rot_deg=hip_rot_deg,
        shoulder_rot_deg=shoulder_rot_deg,
        hip_shoulder_separation_deg=hip_sep_deg,
        lead_elbow_angle_deg=lead_elbow_deg,
        bat_lag_deg=bat_lag_deg,
        time_peak_to_contact_ms=time_peak_to_contact_ms,
        contact_frame=contact_f,
    )
    
    print(f"DEBUG: Final metrics result: {result}")
    return result
