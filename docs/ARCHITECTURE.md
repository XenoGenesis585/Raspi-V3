# 蝟餌絞?嗆? Architecture

```mermaid
flowchart LR
  A[Pi Camera v3] --> B(libcamera-vid H.264 TCP :8554)
  B --> C[Windows FFmpeg demux]
  C --> D[OpenCV decode]
  D --> E[Preprocess: denoise -> Canny -> dilate]
  E --> F[Contours -> Rect filter -> 9 cells]
  F --> G[Grid sort 3x3]
  G --> H[Homography -> Warp (甇??閫?]
  H --> I[Overlay/Annotate -> Display/Record]
```

## 璅∠?隤芣?
- **streaming/**嚗???TCP 銝脫?嚗?嗚蝺???楨銵??伐???
- **detection/**嚗?蝺?皜研憚撱?瞈整??拙耦????摨?
- **calibration/**嚗?找摯閮????⊥迤嚗?銝蕃頧身摰?
- **tracking/**嚗??嚗?瘚?/ Kalman 撟單??漣璅?

