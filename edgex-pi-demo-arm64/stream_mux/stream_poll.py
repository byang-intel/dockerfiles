#!/usr/bin/env python3

import os
import sys
from time import sleep
import cv2

if __name__ == '__main__':
    video = cv2.VideoCapture(sys.argv[1])
    while True:
        success, image = video.read()
        if not success:
            break
        cv2.imwrite(".tmp.out.jpg", image)
        os.system("cp -f .tmp.out.jpg out.jpg")
        sleep(0.03)
