import cv2
from scipy import misc
from matplotlib import pyplot as plt
import sys
from bottle import route, run, template, static_file, get, post, request
import urllib2
import requests
from PIL import Image
from io import BytesIO
import json
import time

sl = [350, 420, 490, 560, 630, 700, 770]
sn = ["6", "5", "4", "3", "2", "1"]

def get_main_color(file):
    img = Image.open("image2.jpg")
    colors = img.getcolors(65536)
    max_occurence, most_present = 0, 0
    try:
        for c in colors:
            if c[0] > max_occurence:
                (max_occurence, most_present) = c
        return most_present
    except TypeError:
        return 3

def getUrl(path):
    files = {
        ('upload', open(path,'rb')),
    }

    same = requests.post('http://uploads.im/api', files=files)

    data = same.text
    json1_data = json.loads(data)
    return json1_data["data"]["img_url"]

global action

def timer(action, uid):
    start = time.time()
    time.clock()
    elapsed = 0
    while action == "start":
        elapsed = time.time() - start
        time.sleep(1)
    if action == "stop":
        time = urllib2.urlopen('https://uvdetection.firebaseio.com/users/' + uid + 'dayTime.json').read()
        total = urllib2.urlopen('https://uvdetection.firebaseio.com/users/' + uid + 'totalTime.json').read()

        newTime = elapsed + time;
        totalTime = elapsed + total;

        same = newTime
        same1 = totalTime

        r = requests.put('https://uvdetection.firebaseio.com/users/' + uid + 'dayTime.json', data=same)
        r2 = requests.put('https://uvdetection.firebaseio.com/users' + uid + 'totalTime.json', data = same1);


@route('/')
def index():
    return "same"

login = ""

print "hi"
@get('/login')
#
def same():
    global login
    print "got here"
    image = urllib2.urlopen('https://uvdetection.firebaseio.com/base64string.json').read()
    image = image[1:-1]
    image = image.replace("\\r\\n", "")

    fh = open("imageToSave.png", "wb")
    fh.write(image.decode('base64'))
    fh.close()


    image = "imageToSave.png"
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

    same = json1_data[0]["faceRectangle"]
    left = same["left"]
    top = same["top"]
    width = same["width"]
    height = same["height"]

    img = cv2.imread(image)
    print width
    print height
    crop_img = img[top:top+height-5, left:left+width-5]

    cv2.imwrite("image2.jpg", crop_img)
    same2 = get_main_color("image2.jpg")

    print (same2)
    total = same2[0]+same2[1]+same2[2]
    print "hallo"
    for x in xrange(len(sn)):
        if(total > sl[x] and total < sl[x+1]):
            print (sn[x])
            return sn[x]


@get('/reset')
def reseto():
    global login
    print ("reset")
    login = ""

@get('/update')
def update():
    global action
    print "got here"
    # same = request.args
    print request
    print same
    userid = same["user"]
    action = same["action"]
    print userid
    print action
    timer(action, userid)
    return {"HALLO", "ya"}

    # image = urllib2.urlopen('https://uvdetection.firebaseio.com/base64string.json').read()






run(host='localhost', port=8000)
