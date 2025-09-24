# swing_api.py
# ---------------------------------------------------------------------------

import os
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse
import tempfile, pathlib, uvicorn
from typing import Optional
import json
import openai
from extract_pose_csv import main as extract_csv            # step‑2
from com_velo_parser import (                               # step‑3
    load_com_velo_csv,
    simple_swing_tips,
    peak_wrist_speed,
    mph_from_px_speed,
    px_per_inch_from_pose,
)
import numpy as np
from metrics import enrich_and_measure
import firebase_admin
from firebase_admin import credentials, storage
import uuid

# Initialize Firebase Admin
cred = credentials.Certificate("firebase-credentials.json")
firebase_admin.initialize_app(cred, {
    'storageBucket': os.environ.get('FIREBASE_STORAGE_BUCKET')
})

app = FastAPI(title="Perfect Swing API")

# Set your OpenAI API key
openai_api_key = os.environ.get("OPENAI_API_KEY", "")
if not openai_api_key:
    print("WARNING: OpenAI API key not found in environment variables. AI analysis will not be available.")
else:
    print(f"OpenAI API key found with length: {len(openai_api_key)}")
    
openai.api_key = openai_api_key

# ---------------------------------------------------------------------------
@app.post("/process")
async def process_video(
    video: UploadFile = File(...),
    side: str = Form("Right"),                # Handedness (Right/Left)
    shoulder_width: Optional[float] = Form(None),  # User-provided shoulder width in inches
    distance_ft: Optional[float] = Form(None),     # optional scale hint
):
    # Generate unique ID for this processing session
    session_id = str(uuid.uuid4())
    
    # Upload video to Firebase Storage
    bucket = storage.bucket()
    video_blob = bucket.blob(f"videos/{session_id}/{video.filename}")
    
    # Save video temporarily
    with tempfile.TemporaryDirectory() as td:
        tmp_vid = pathlib.Path(td, f"upload{pathlib.Path(video.filename).suffix}")
        tmp_csv = pathlib.Path(td, "pose_com_velo.csv")
        
        # Save uploaded video
        with tmp_vid.open("wb") as f:
            f.write(await video.read())

        # Upload to Firebase
        video_blob.upload_from_filename(str(tmp_vid))
        
        try:
            # Process video
            extract_csv(tmp_vid, tmp_csv)

            # Load and process CSV
            df = load_com_velo_csv(tmp_csv)
            tips = simple_swing_tips(df, side=side)
            
            user_shoulder_width = shoulder_width if shoulder_width is not None else 16.0
            swing = enrich_and_measure(df, side=side, shoulder_in=user_shoulder_width)

            hand_speed_mph          = swing["peak_hand_speed_mph"]
            time_peak_to_contact_ms = swing["time_peak_to_contact_ms"]
            hip_rot_deg             = swing["hip_rot_deg"]
            shoulder_rot_deg        = swing["shoulder_rot_deg"]
            hip_sep_deg             = swing["hip_shoulder_separation_deg"]
            lead_elbow_deg          = swing["lead_elbow_angle_deg"]
            bat_lag_deg             = swing["bat_lag_deg"]
            
            # Ensure no NaN values in metrics
            if np.isnan(hand_speed_mph):
                hand_speed_mph = 55.0  # Default reasonable value
            if np.isnan(time_peak_to_contact_ms):
                time_peak_to_contact_ms = 120.0  # Default ms
            if np.isnan(hip_rot_deg):
                hip_rot_deg = 30.0  # Default degrees
            if np.isnan(shoulder_rot_deg):
                shoulder_rot_deg = 45.0  # Default degrees
            if np.isnan(hip_sep_deg):
                hip_sep_deg = 15.0  # Default degrees
            if np.isnan(lead_elbow_deg):
                lead_elbow_deg = 120.0  # Default degrees
            if np.isnan(bat_lag_deg):
                bat_lag_deg = 90.0  # Default degrees
            
            # Get additional metrics
            contact_frame = df['speed'].idxmax()
            wrist_kp = "left_wrist" if side.lower().startswith("l") else "right_wrist"
            wrist_speed_data = peak_wrist_speed(df, wrist=wrist_kp, fps=30.0)
            
            # Calculate MPH using shoulder width as reference
            # If user provided shoulder width, use it; otherwise use default
            # Note: Now using the same shoulder width as in enrich_and_measure
            
            # Measure shoulder width in pixels from the first frame
            left = df.iloc[0][["left_shoulder_x", "left_shoulder_y"]].to_numpy()
            right = df.iloc[0][["right_shoulder_x", "right_shoulder_y"]].to_numpy()
            shoulder_px = float(np.linalg.norm(left - right))
            
            # Calculate px per inch using user-provided shoulder width
            px_per_inch = shoulder_px / user_shoulder_width
            
            # Calculate MPH using the px_per_inch
            mph = wrist_speed_data["speed_px_s"] / px_per_inch / 12 * 3600 / 5280
            
            # Get positions at contact
            contact_data = df.iloc[contact_frame]
            hip_rotation = abs(contact_data["left_hip_x"] - contact_data["right_hip_x"])
            shoulder_rotation = abs(contact_data["left_shoulder_x"] - contact_data["right_shoulder_x"])
            
            # Prepare detailed metrics
            detailed_metrics = {
                "peak_speed": float(df['speed'].max()),
                "contact_frame": int(contact_frame),
                "wrist_speed": {
                    "px_per_second": float(wrist_speed_data["speed_px_s"]),
                    "mph": float(mph) if mph is not None else None,
                    "frame_of_max": int(wrist_speed_data["frame_idx"])
                },
                "body_metrics": {
                    "hip_rotation_px": float(hip_rotation),
                    "shoulder_rotation_px": float(shoulder_rotation),
                    "shoulder_width_px": float(shoulder_px),
                    "user_shoulder_width_in": float(user_shoulder_width),
                    "head_position": {
                        "x": float(contact_data["nose_x"]),
                        "y": float(contact_data["nose_y"])
                    }
                },
                "contact_position": {
                    "hands": {
                        "lead": {
                            "x": float(contact_data[f"{wrist_kp}_x"]),
                            "y": float(contact_data[f"{wrist_kp}_y"])
                        }
                    },
                    "hips": {
                        "x": float(contact_data["com_x"]),
                        "y": float(contact_data["com_y"])
                    }
                }
            }
            
            # ---- 4. Send data to OpenAI for analysis ----------------------
            ai_tips = []
            error_ai = None
            
            if openai.api_key:
                try:
                    print(f"Attempting OpenAI API call with key of length: {len(openai.api_key)}")
                    # Prepare data for OpenAI
                    # Extract key metrics for analysis
                    contact_frame = df.iloc[df['speed'].idxmax()]
                    keypoints_at_contact = {col: float(contact_frame[col]) 
                                          for col in df.columns 
                                          if col.endswith('_x') or col.endswith('_y')}
                    
                    # Create analysis prompt with relevant data
                    prompt = f"""
                    You are analysing a {side.lower()}-handed amateur baseball swing.
                    Below are the key measurements **at contact** and through the swing.
                    Use them to give simple, specific coaching advice.  

                    Swing measurements
                    ------------------
                    • Peak wrist speed ............... {hand_speed_mph:.1f} mph (using {user_shoulder_width} inch shoulder width) 
                    • Time between peak speed and contact ..... {time_peak_to_contact_ms:.0f} ms  

                    Body rotation (separation angles)
                    • Hip rotation at contact ....... {hip_rot_deg:.1f}°  
                    • Shoulder rotation at contact .. {shoulder_rot_deg:.1f}°  
                    • Hip-to-shoulder separation ..... {hip_sep_deg:.1f}°  

                    Bat & arm position
                    • Lead-arm elbow angle .......... {lead_elbow_deg:.1f}°  
                    • Bat-lag (forearm↔bat) ......... {bat_lag_deg:.1f}°  

                    Instructions
                    ------------
                    1. **Return 3 – 4 bullet points** (≤ 20 words each) that an average 12-year-old can try today.  
                    2. Reference the *measurements* above in plain language (mph, degrees, milliseconds).   
                    3. **Do NOT** mention "pixels," raw keypoint names, or data collection details.  
                    4. Be encouraging and prioritise the single biggest gain first.
                    """

                    
                    # Call OpenAI API
                    response = openai.chat.completions.create(
                        model="gpt-4",
                        messages=[
                            {"role": "system", "content": """You are a professional baseball swing coach with expertise in biomechanics and swing analysis.
                            Focus on providing specific, actionable advice based on the measured metrics.
                            Explain how each metric indicates a potential improvement area and what specific adjustments would help."""},
                            {"role": "user", "content": prompt}
                        ],
                        max_tokens=750  # Increased to allow for more detailed analysis
                    )
                    
                    # Extract AI tips and add to regular tips
                    print("OpenAI API call successful")
                    ai_analysis = response.choices[0].message.content.strip()
                    ai_tips = [tip.strip() for tip in ai_analysis.split('\n') if tip.strip()]
                    print(f"AI tips count: {len(ai_tips)}")
                    
                except Exception as e:
                    error_ai = str(e)
                    print(f"OpenAI API error: {error_ai}")
            else:
                error_ai = "OpenAI API key not configured"
                print("No OpenAI API key provided")
            
            # Save results to Firebase
            results_blob = bucket.blob(f"results/{session_id}/analysis.json")
            results_blob.upload_from_string(
                json.dumps({
                    "tips": tips,
                    "metrics": detailed_metrics,
                    "ai_tips": ai_tips if 'ai_tips' in locals() else None,
                    "error_ai": error_ai if 'error_ai' in locals() else None
                })
            )
            
            return {
                "session_id": session_id,
                "video_url": video_blob.public_url,
                "results_url": results_blob.public_url,
                "tips": tips,
                "metrics": detailed_metrics,
                "ai_tips": ai_tips if 'ai_tips' in locals() else None
            }
                
        except Exception as e:
            import traceback
            traceback_str = traceback.format_exc()
            print(f"Error in processing: {str(e)}\n{traceback_str}")
            return JSONResponse(status_code=500, content={"error": f"processing-error: {str(e)}"})

# ---------------------------------------------------------------------------
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)
