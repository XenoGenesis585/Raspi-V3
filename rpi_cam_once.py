#!/usr/bin/env python3
import os, shutil, datetime, pathlib, sys

def ask(prompt, default=None):
    s = input(f"{prompt}" + (f"（預設: {default}）" if default is not None else "") + ": ").strip()
    return s if s else (str(default) if default is not None else "")

def ask_int(prompt, default):
    while True:
        s = ask(prompt, default)
        try:
            return int(s)
        except ValueError:
            print("請輸入整數數字。")

def ts():
    return datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

home = str(pathlib.Path.home())
saved_marker = os.path.join(home, "last_saved.txt")  # <--- 新增：固定結果檔路徑
try:
    if os.path.exists(saved_marker):
        os.remove(saved_marker)
except:
    pass

print("\n=== 樹莓派 V3 鏡頭一次性控制（可被PC自動下載） ===")
mode = ask("選擇模式（1=拍照, 2=錄影）", "1")

width  = ask_int("輸入寬度（例如 1920）", 1920)
height = ask_int("輸入高度（例如 1080）", 1080)

saved_path = None
exit_code = 1

if mode == "1":
    default_name = f"photo_{ts()}.jpg"
    filename = ask("輸出檔名（含 .jpg）", default_name)
    if not filename.endswith(".jpg"):
        filename += ".jpg"
    out_path = os.path.abspath(filename)
    cmd = f"libcamera-still --width {width} --height {height} --autofocus-on-capture -o '{out_path}'"
    print(f"\n> {cmd}")
    code = os.system(cmd)
    if code == 0 and os.path.exists(out_path):
        saved_path = out_path
        exit_code = 0
    else:
        print("❌ 拍照失敗。")

elif mode == "2":
    fps   = ask_int("輸入 FPS（例如 30）", 30)
    secs  = ask_int("輸入錄影時間（秒）", 10)
    default_name = f"video_{ts()}.mp4"
    out_mp4 = ask("輸出檔名（含 .mp4）", default_name)
    if not out_mp4.endswith(".mp4"):
        out_mp4 += ".mp4"
    out_mp4 = os.path.abspath(out_mp4)
    tmp_h264 = os.path.abspath(f"tmp_{ts()}.h264")

    vid_cmd = (
        f"libcamera-vid --width {width} --height {height} "
        f"--framerate {fps} --codec h264 --inline -t {secs*1000} -o '{tmp_h264}'"
    )
    print(f"\n> {vid_cmd}")
    vcode = os.system(vid_cmd)
    if vcode == 0 and os.path.exists(tmp_h264):
        if shutil.which("MP4Box"):
            mux_cmd = f"MP4Box -add '{tmp_h264}' '{out_mp4}'"
        elif shutil.which("ffmpeg"):
            mux_cmd = f"ffmpeg -y -r {fps} -i '{tmp_h264}' -c:v copy '{out_mp4}'"
        else:
            mux_cmd = None

        if mux_cmd:
            print(f"> {mux_cmd}")
            mcode = os.system(mux_cmd)
            if mcode == 0 and os.path.exists(out_mp4):
                try: os.remove(tmp_h264)
                except: pass
                saved_path = out_mp4
                exit_code = 0
            else:
                print("⚠️ 封裝 MP4 失敗，保留 H.264：", tmp_h264)
        else:
            print("⚠️ 未安裝 MP4Box/ffmpeg，保留 H.264：", tmp_h264)
    else:
        print("❌ 錄影失敗。")

else:
    print("❌ 無效選項。")

# ---- 關鍵：同時把結果寫入家目錄固定檔（給 Windows 後續取得） ----
try:
    with open(saved_marker, "w", encoding="utf-8") as f:
        if saved_path:
            f.write(saved_path.strip() + "\n")
        else:
            f.write("FAILED\n")
except Exception as e:
    print("⚠️ 寫入 last_saved.txt 失敗：", e)

# 也印出一行方便肉眼看
if saved_path:
    print(f"SAVED:{saved_path}")
else:
    print("FAILED")

sys.exit(exit_code)

