# OPCV — Real-time Grid Detection & TCP Streaming (Raspberry Pi + OpenCV)

> 即時 H.264 影像串流（TCP） + 九宮格偵測與視角校正（OpenCV / Python）。

![status](https://img.shields.io/badge/status-active-brightgreen) ![python](https://img.shields.io/badge/python-3.10%2B-blue) ![opencv](https://img.shields.io/badge/OpenCV-4.x-red)

---

## ✨ 特色 Highlights
- **低延遲 TCP 串流**：Raspberry Pi 使用 `libcamera-vid` 推送 H.264，Windows 端以 Python/FFmpeg/OpenCV 接收。
- **九宮格偵測穩定化**：採用「9 小矩形偵測＋自動排序」，支援粗黑框版本，搭配強化 Canny 與形態學操作。
- **視角校正（透視變換）**：將傾斜的九宮格轉為正視角，便於後續標註與互動。
- **模組化程式**：以 `OPCV032` 為主的結構，含 AI 推論/幾何處理/追蹤/投影等管線，可持續擴充。

---

## 🧱 專案結構（建議）
