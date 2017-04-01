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
        raise Exception("Too many colors in the image")

def getUrl(path):
    files = {
        ('upload', open(path,'rb')),
    }

    same = requests.post('http://uploads.im/api', files=files)

    data = same.text
    json1_data = json.loads(data)
    return json1_data["data"]["img_url"]


@route('/')
def index():
    return "same"

login = ""

@get('/login')
def login():
    global login
    image = urllib2.urlopen('https://uvdetection.firebaseio.com/base64string.json').read()
    image = image[1:-1]
    image = image.replace("\\r\\n", "")
    
    fh = open("imageToSave.png", "wb")
    fh.write(image.decode('base64'))
    fh.close()

    image = "imageToSave.png"
    url = getUrl(image)
    print url

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

    crop_img = img[top:top+height-5, left+15:left+width-5] 

    cv2.imwrite("image2.jpg", crop_img)
    same2 = get_main_color("image2.jpg")

    print same2
    total = same2[0]+same2[1]+same2[2]

    for x in xrange(len(sn)):
        if(total > sl[x] and total < sl[x+1]):
            print sn[x]
            return sn[x]


@get('/reset')
def reseto():
    global login
    print "reset"
    login = ""


@get('/update')
def hai():
    print "hallo"

run(host='localhost', port=8000)