import argparse
import cv2
import numpy as np

# 璆萇陛?交撅內嚗誑 OpenCV ?湔?? FFmpeg 蝞∠?
# ?亦瘜?交???tcp://嚗?嫣誑 subprocess ?? ffmpeg 銝虫誑 pipe 霈??

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
        # TODO: ?澆雿?銋悅?澆皜祈??⊥迤瘚?嚗蒂??蝜芾ˊ??frame 銝?
        cv2.imshow('OPCV recv demo', frame)
        if cv2.waitKey(1) & 0xFF == 27:
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == '__main__':
    main()
