# 使用方式（PowerShell）：在你的 repo 根目錄執行
#   1) 右鍵「在此開啟 PowerShell」
#   2) 將本檔案儲存為 setup-opcv-repo.ps1，然後執行：
#      powershell -ExecutionPolicy Bypass -File .\setup-opcv-repo.ps1
#   3) 執行後會建立/覆寫以下檔案與資料夾：
#      README.md, LICENSE, .gitignore, CONTRIBUTING.md, CODE_OF_CONDUCT.md,
#      requirements.txt, .github/ISSUE_TEMPLATE/*, .github/PULL_REQUEST_TEMPLATE.md,
#      .github/workflows/python-ci.yml, docs/ARCHITECTURE.md
#   4) 完成後：
#      git add .
#      git commit -m "chore(repo): 初始化專案說明、模板與 CI"
#      git push origin main

# 確保目錄
mkdir -Force .github/ISSUE_TEMPLATE | Out-Null
mkdir -Force docs | Out-Null

# ----------------------------- README.md -----------------------------
$readme = @'
# OPCV — Real‑time Grid Detection & TCP Streaming (Raspberry Pi + OpenCV)

> 即時 H.264 影像串流（TCP） + 九宮格偵測與視角校正（OpenCV / Python）。

![status](https://img.shields.io/badge/status-active-brightgreen) ![python](https://img.shields.io/badge/python-3.10%2B-blue) ![opencv](https://img.shields.io/badge/OpenCV-4.x-red)

## ✨ 特色 Highlights
- **低延遲 TCP 串流**：Raspberry Pi 端使用 `libcamera-vid` 推送 H.264，Windows 端以 Python/FFmpeg/OpenCV 接收。
- **九宮格偵測穩定化**：從外框偵測演進為 **9 小矩形偵測＋自動排序**，支援粗黑框版本，搭配強化 Canny 與形態學操作。
- **視角校正（透視變換）**：把傾斜的九宮格轉為正視角，便於後續標註與互動。
- **模組化程式**：以 `OPCV032` 為主的結構，含 AI 推論/幾何處理/追蹤/投影等管線，可持續擴充。

> 備註：本 README 以你目前的專案脈絡整理（Pi 5 + Camera v3、TCP、Windows 端解碼、九宮格偵測）。如與實際檔名有出入，請依你的檔案調整。

---

## 🧱 專案結構（建議）
```
OPCV/
├─ src/
│  ├─ streaming/            # 串流收/發相關
│  ├─ detection/            # 邊緣、輪廓、九宮格小矩形偵測與排序
│  ├─ calibration/          # 透視校正、影像翻轉
│  ├─ tracking/             #（選配）光流 / Kalman
│  └─ utils/                # 共用工具
├─ scripts/
│  ├─ start_pi_tcp.sh       # Pi 端啟動 TCP 串流（libcamera-vid）
│  └─ win_recv_demo.py      # Windows 端接收展示（FFmpeg + OpenCV）
├─ docs/
│  └─ ARCHITECTURE.md       # 系統流程、Mermaid 圖
├─ .github/
│  ├─ ISSUE_TEMPLATE/
│  │  ├─ bug_report.md
│  │  └─ feature_request.md
│  ├─ PULL_REQUEST_TEMPLATE.md
│  └─ workflows/
│     └─ python-ci.yml
├─ requirements.txt
├─ README.md
├─ LICENSE
└─ .gitignore
```

---

## 🚀 快速開始 Quick Start
### 1) 安裝相依套件（Windows）
```bash
python -m venv .venv
. .venv/Scripts/Activate.ps1
pip install -r requirements.txt
```
> 若你使用 Tesseract OCR，請另外安裝系統版 Tesseract，並確認路徑（本專案先不強制依賴）。

### 2) Raspberry Pi 端（TCP 推流範例）
```bash
# CAM0 / Camera v3；解析度與 FPS 依需求調整
libcamera-vid -t 0 --inline --codec h264 \
  --width 1280 --height 720 --framerate 30 \
  --listen -o tcp://0.0.0.0:8554
```

### 3) Windows 端接收（Python + FFmpeg + OpenCV）
```bash
python .\scripts\win_recv_demo.py --url tcp://<Pi-IP>:8554
```

---

## 🧪 九宮格偵測概念（粗黑框版本）
- 使用 **強化版 Canny** + **線條膨脹** 提升粗線條的連續性。
- **連通區域/輪廓篩選**：面積與長寬比過濾，取得符合「小矩形」候選。
- **九格聚合**：以距離/格點拓撲關係自動排序，得到 3×3 座標矩陣。
- **透視校正**：從四角估計單應性（Homography），校正到正視角。

> 參考版本：`OPCV07 → OPCV08 → OPCV011 → OPCV013/014 → OPCV020/032` 的迭代方向。

---

## 📁 常用腳本
- `scripts/start_pi_tcp.sh`：Pi 端一鍵推流（請賦予可執行權限）。
- `scripts/win_recv_demo.py`：Windows 端接收＋顯示畫面（可加入九宮格偵測疊圖）。

---

## 🛠️ 開發與貢獻
- 風格：PEP8，使用 `ruff` 自動格式化與靜態檢查。
- Commit 訊息慣例：`type(scope): summary`（例如 `feat(detection): add 3x3 grid sort`）。
- 送 PR 前請執行：`ruff format && ruff check && pytest`。

詳見 [CONTRIBUTING.md](CONTRIBUTING.md) 與 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)。

---

## 📜 授權 License
本專案預設採用 **MIT License**。若你需改為 GPL/Apache，請直接替換 `LICENSE`。

'@
Set-Content -Path README.md -Value $readme -Encoding UTF8

# ----------------------------- LICENSE (MIT) -----------------------------
$license = @'
MIT License

Copyright (c) 2025 XenoGenesis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'@
Set-Content -Path LICENSE -Value $license -Encoding UTF8

# ----------------------------- .gitignore -----------------------------
$gitignore = @'
# OS/Editor
.DS_Store
Thumbs.db
.vscode/
.idea/

# Python
__pycache__/
*.py[cod]
*.pyo
*.pyd
*.egg-info/
.venv/
.env
.env.*

# Build/Artifacts
build/
dist/
*.log

# Images / cache (視需求保留)
*.mp4
*.h264
*.png.cache
*.jpg.cache

# Notebooks
.ipynb_checkpoints/
'@
Set-Content -Path .gitignore -Value $gitignore -Encoding UTF8

# ----------------------------- CONTRIBUTING.md -----------------------------
$contrib = @'
# Contributing Guide

感謝你的貢獻！提交 PR 前請先：

1. Fork 並建立分支：`feat/your-feature` 或 `fix/your-bug`
2. 安裝開發依賴：`pip install -r requirements.txt`
3. 風格檢查：`ruff format && ruff check`
4. 測試（若有）：`pytest`
5. 提交 PR 時附上：變更摘要、動機、測試方式、截圖（如 UI/視覺化）

## Commit 訊息範例
- `feat(detection): add 3x3 grid sort`
- `fix(streaming): handle tcp reconnect`
- `chore(ci): enable ruff + pytest`

'@
Set-Content -Path CONTRIBUTING.md -Value $contrib -Encoding UTF8

# ----------------------------- CODE_OF_CONDUCT.md -----------------------------
$coc = @'
# Code of Conduct

本專案採用 Contributor Covenant 行為準則。請以尊重、包容、務實的態度參與討論與協作。

基本原則：
- 尊重不同背景與經驗
- 聚焦技術議題與可驗證事實
- 拒絕人身攻擊、歧視與騷擾

違規請回報至專案維護者。
'@
Set-Content -Path CODE_OF_CONDUCT.md -Value $coc -Encoding UTF8

# ----------------------------- requirements.txt -----------------------------
$req = @'
opencv-python>=4.9
numpy>=1.24
matplotlib>=3.8
pillow>=10.2
imutils>=0.5.4
# 若使用 OCR，解除以下註解並安裝系統版 Tesseract
# pytesseract>=0.3.10
# 若使用串流相關封裝，可視情況加入 gstreamer-python 綁定或 ffmpeg-python
# ffmpeg-python>=0.2.0
# scipy>=1.11  # 若有濾波/最佳化需求
# filterpy>=1.4.5  # 若使用 Kalman
'@
Set-Content -Path requirements.txt -Value $req -Encoding UTF8

# ----------------------------- ISSUE TEMPLATE: bug -----------------------------
$bug = @'
---
name: Bug report
about: 回報錯誤以便修復
labels: bug
---

**描述問題**
清楚描述遇到的錯誤與期望行為。

**重現步驟**
1. 指令/程式碼：
2. 參數：
3. 環境（OS / Python / OpenCV 版本）：

**截圖/影片**
如有請附上。
'@
Set-Content -Path .github/ISSUE_TEMPLATE/bug_report.md -Value $bug -Encoding UTF8

# ----------------------------- ISSUE TEMPLATE: feature -----------------------------
$feature = @'
---
name: Feature request
about: 提出新功能或改善
labels: enhancement
---

**動機**
為何需要這個功能？

**提案**
簡述功能設計、可能的 API / CLI。

**額外資訊**
相關參考或替代方案。
'@
Set-Content -Path .github/ISSUE_TEMPLATE/feature_request.md -Value $feature -Encoding UTF8

# ----------------------------- PULL_REQUEST_TEMPLATE -----------------------------
$pr = @'
## 摘要
- 變更內容：
- 動機與背景：

## 檢查清單
- [ ] 程式碼通過 `ruff format && ruff check`
- [ ] 本地測試通過（如有 `pytest`）
- [ ] 有更新 README / Docs（必要時）

## 截圖 / 影片（如有 UI/視覺化）
'@
Set-Content -Path .github/PULL_REQUEST_TEMPLATE.md -Value $pr -Encoding UTF8

# ----------------------------- GitHub Actions: python-ci -----------------------------
$ci = @'
name: python-ci

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.10'
      - name: Install deps
        run: |
          python -m pip install --upgrade pip
          pip install ruff pytest
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
      - name: Ruff format check
        run: ruff format --check
      - name: Ruff lint
        run: ruff check .
      - name: Run tests
        run: |
          if [ -d tests ]; then pytest -q; else echo "No tests"; fi
'@
Set-Content -Path .github/workflows/python-ci.yml -Value $ci -Encoding UTF8

# ----------------------------- docs/ARCHITECTURE.md -----------------------------
$arch = @'
# 系統架構 Architecture

```mermaid
flowchart LR
  A[Pi Camera v3] --> B(libcamera-vid H.264 TCP :8554)
  B --> C[Windows FFmpeg demux]
  C --> D[OpenCV decode]
  D --> E[Preprocess: denoise -> Canny -> dilate]
  E --> F[Contours -> Rect filter -> 9 cells]
  F --> G[Grid sort 3x3]
  G --> H[Homography -> Warp (正視角)]
  H --> I[Overlay/Annotate -> Display/Record]
```

## 模組說明
- **streaming/**：處理 TCP 串流（接收、斷線重連、緩衝策略）。
- **detection/**：邊緣偵測、輪廓過濾、小矩形聚合與排序。
- **calibration/**：單應性估計與透視校正；上下翻轉設定。
- **tracking/**（選配）：光流 / Kalman 平滑化座標。

'@
Set-Content -Path docs/ARCHITECTURE.md -Value $arch -Encoding UTF8

# ----------------------------- scripts/start_pi_tcp.sh -----------------------------
$pi = @'
#!/usr/bin/env bash
set -euo pipefail
# 以 TCP 8554 推流 1280x720@30fps；依需求調整
libcamera-vid -t 0 --inline --codec h264 \
  --width 1280 --height 720 --framerate 30 \
  --listen -o tcp://0.0.0.0:8554
'@
Set-Content -Path scripts/start_pi_tcp.sh -Value $pi -Encoding UTF8

# ----------------------------- scripts/win_recv_demo.py -----------------------------
$winpy = @'
import argparse
import cv2
import numpy as np

# 極簡接收展示：以 OpenCV 直接拉取 FFmpeg 管線
# 若無法直接打開 tcp://，可改以 subprocess 啟動 ffmpeg 並以 pipe 讀取

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--url', required=True, help='e.g., tcp://192.168.254.18:8554')
    args = parser.parse_args()

    cap = cv2.VideoCapture(args.url, cv2.CAP_FFMPEG)
    if not cap.isOpened():
        raise SystemExit(f'Cannot open stream: {args.url}')

    while True:
        ok, frame = cap.read()
        if not ok:
            print('Stream read failed, retrying...')
            break
        # TODO: 呼叫你的九宮格偵測與校正流程，並疊加繪製在 frame 上
        cv2.imshow('OPCV recv demo', frame)
        if cv2.waitKey(1) & 0xFF == 27:
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == '__main__':
    main()
'@
Set-Content -Path scripts/win_recv_demo.py -Value $winpy -Encoding UTF8

