import urllib2
import json

url = 'https://isic-archive.com:443/api/v1/image?limit=10000&offset=0&sort=name&sortdir=1'

same = urllib2.urlopen(url).read()

d = json.loads(same)


count = 0;
count2 = 0;

for x in d:
	url2 = 'https://isic-archive.com:443/api/v1/image/' + x["_id"]
	same2 = urllib2.urlopen(url2).read()
	e = json.loads(same2)
	care = e["meta"]["clinical"]["benign_malignant"]
	print care
	if care == "malignant" and count <= 500:
		url3 = 'https://isic-archive.com:443/api/v1/image/' + x["_id"] + '/download?contentDisposition=inline'
		same3 = urllib2.urlopen(url3).read()
		fh = open("data/malignant" + str(count) + ".png", "wb")
		fh.write(same3)
		fh.close()
		print "count ", count
		count += 1
	elif(count2 <= 1000 and care == "benign"):
		url3 = 'https://isic-archive.com:443/api/v1/image/' + x["_id"] + '/download?contentDisposition=inline'
		same3 = urllib2.urlopen(url3).read()
		fh = open("data/benign" + str(count2) + ".png", "wb")
		fh.write(same3)
		fh.close()
		print "count2 ", count2
		count2 += 1
