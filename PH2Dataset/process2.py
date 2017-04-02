import cv2 as cv2
import numpy as numpy
import imutils


si = 3;
sl = ["n","a","m"]
sn = ["nevus","atypical","melonoma"]

for siii in xrange(3):
	for sxxx in range(46):
		roi = "/users/kevin/desktop/uvradiation/PH2Dataset/" + sn[siii]+ "/" + sn[siii] + str(sxxx+1) + "/lesion.bmp"
		print roi
		gray = cv2.imread(roi,0)
		ratio = gray.shape[0] / 300.0
		orig = gray.copy()
		image = imutils.resize(gray, height = 300)

		ret,thresh = cv2.threshold(image,127,255,0)
		contours,hierarchy = cv2.findContours(thresh, 1, 2)
		
		cnt = contours[0]
		x,y,w,h = cv2.boundingRect(cnt)
		print x, y, w, h
		if(h > w):
			w = h;
		else:
			h=w;

		if(x > y):
			x = y;
		else:
			y = x;
	
		print x, y, w, h

		cv2.rectangle(image,(x,y),(x+w,y+h),(0,255,0),2)
		# e = [x y w h];
		# BW = imcrop(img,e);

		realImPath = "/users/kevin/desktop/uvradiation/PH2Dataset/" + sn[siii]+ "/" + sn[siii] + str(sxxx+1) + "/picture.bmp"
		realImage = cv2.imread(realImPath)
		crop_img = realImage[y:h, x:w]
		cv2.imwrite(realImPath, crop_img)







