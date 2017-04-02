import cv2
import numpy as np
import sys

face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')


# names = ["kevin.jpg","lilia.jpg","michael.png"]
# names = ["lilia.jpg"]
# names = ["michael.jpg"]
# names = ["kevin.jpg"]
#
# for name in names:

name = sys.argv[1]

print name
img = cv2.imread(name)
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

faces = face_cascade.detectMultiScale(gray, 1.3, 5)
print faces
for (x,y,w,h) in faces:
    cv2.rectangle(img,(x,y),(x+w,y+h),(255,0,0),2)
    roi_gray = gray[y:y+h, x:x+w]
    roi_color = img[y:y+h, x:x+w]
    scaled = cv2.resize(roi_gray,(32,32))
    cv2.namedWindow(name, 0)
    cv2.resizeWindow(name,240,240)
    cv2.imshow(name,cv2.resize(scaled,(240,240),interpolation=0))
    cv2.imshow('img',img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    spl = name.split(".jpg")
    spl3 = spl[0]+"Small.jpg"
    print spl3
    cv2.imwrite(spl3,scaled);

# cv2.namedWindow("Final", 0);
# cv2.resizeWindow("Final", 500,500);

# cv2.imshow('img',img)
# cv2.waitKey(0)
# cv2.destroyAllWindows()
