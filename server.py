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

def get_main_color(file):
    img = Image.open(file)
    colors = img.getcolors(256)
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


# @route('/')
# def index():
#     return "same"

# login = ""

def same():
# @post('/login') 
    # global login
    # image = urllib2.urlopen('https://uvdetection.firebaseio.com/image.json').read()
    # image = image[1:-1]
    # image = image.replace("\\r\\n", "")

    # fh = open("imageToSave.png", "wb")
    # fh.write(image.decode('base64'))
    # fh.close()

    url = getUrl('banana.jpg')
    print 'url is'
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
    print same
    return same


    # return sn[np.argmax(pr)];

same()


@post('/loggedin')
def loggedin():
    global login
    print request.forms.get('username') + " is trying to login, it is: " + login + "asd"
    if(login == request.forms.get('username')):
        print "got in"
        login = ""
        return "true"
    elif(login == ""):
        login = ""
        return "false"
    else:
        tmp = login
        login = ""
        return tmp


@get('/reset')
def reseto():
    global login
    print "reset"
    login = ""



# run(host='localhost', port=8000)