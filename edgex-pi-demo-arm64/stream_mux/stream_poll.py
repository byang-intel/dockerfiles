#!/usr/bin/env python3

import os
import sys
from time import sleep
import cv2

if __name__ == '__main__':
    video = cv2.VideoCapture(sys.argv[1])
    while True:
        retry = 10
        while retry > 1:
            success, image = video.read()
            if success:
                break
            retry = retry - 1
        if not success:
            break
        cv2.imwrite(".tmp.out.jpg", image)
        os.system("cp -f .tmp.out.jpg out.jpg")
        sleep(0.03)
