import cv2
from scipy import misc
from matplotlib import pyplot as plt
import sys

from bottle import route, run, template, static_file, get, post, request

import urllib2
# import urllib.request  as urllib2 
import json
import requests
from PIL import Image
from io import BytesIO
import datetime
import time

sl = [0, 420, 490, 560, 630, 700, 770]
sn = ["6", "5", "4", "3", "2", "1"]

def get_main_color(file):
    img = Image.open(file)
    colors = img.getcolors(4096)
    max_occurence, most_present = 0, 0
    try:
        for c in colors:
            if c[0] > max_occurence:
                (max_occurence, most_present) = c
        return most_present
    except TypeError:
        return [184,184,184]

def getUrl(path):
    files = {         
        ('upload', open(path,'rb')), 
    }           
    same = requests.post('http://uploads.im/api', files=files) 
    data = same.text 
    json1_data = json.loads(data) 
    return json1_data["data"]["img_url"]       

global action


def stopTimer(uid,index, tim):
    skin = urllib2.urlopen('https://uvdetection.firebaseio.com/users/' + uid + 'skin.json').read()
    weight = urllib2.urlopen('https://uvdetection.firebaseio.com/users/' + uid + 'weight.json').read()
    startTime = urllib2.urlopen('https://uvdetection.firebaseio.com/users/' + uid + 'startTime.json').read()


    epoch_time = float(time.time())
    print epoch_time
    difference = epoch_time - float(tim)
    minutes = int(difference)/60
    amount = minutes * int(index/3) * int(weight)
    return amount;
   

@route('/')
def index():
    return "same"

login = ""

print ("hi")
@get('/login')
#
def login():
    global login
    print ("got here")
    userid = request.GET.get('userid')
    print userid

    image = urllib2.urlopen('https://uvdetection.firebaseio.com/users/' + userid + '/base64.json').read()
    image = image.replace("\\r\\n", "")

    fh = open("imageToSave.png", "wb")
    fh.write(image.decode('base64'))
    fh.close()


    image = "imageToSave.png"

    img = Image.open(image)
    new_width  = 128
    new_height = 128
    img = img.rotate(270)
    img = img.resize((new_width, new_height), Image.ANTIALIAS)

    img.save(image)

    # fh = open("imageToSave.png", "wb")
    # fh.write(img)
    # fh.close()

    url = getUrl(image)
    print (url)

    data = {
        'url': url
    }
    headers = {
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key':'0fa6e8389bda4b8892cc050782811926'
    }

    url = 'https://westus.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=false'

    r = requests.post(url, data=json.dumps(data), headers=headers)
    json1_data = json.loads(r.text)

    print r.text
    print json1_data
    same = json1_data[0]["faceRectangle"]
    left = same["left"]
    top = same["top"]
    width = same["width"]
    height = same["height"]

    img = cv2.imread(image)
    print (width)
    print (height)
    crop_img = img[top:top+height, left:left+width]

    cv2.imwrite("image2.jpg", crop_img)
    same2 = get_main_color("image2.jpg")

    total = same2[0]+same2[1]+same2[2]

    print (total)
    for x in xrange(len(sn)):
        if(total > sl[x] and total < sl[x+1]):
            print (sn[x])
            response = {"response": sn[x]}
            return response
    response = {"response": 4}
    return response


@get('/reset')
def reseto():
    global login
    print ("reset")
    login = ""

@get('/end')
def end():
    userid = request.GET.get('userid')
    index = request.GET.get('index')
    time = request.GET.get('date')

    amount = stopTimer(userid,index,time)
    return amount

run(host='localhost', port=8000)
