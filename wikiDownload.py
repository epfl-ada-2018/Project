import urllib.request, json
import contextlib
from datetime import datetime
import time

def call(url):
    req = urllib.request.Request(url)
    with contextlib.closing(urllib.request.urlopen(req)) as response:
        request = response.read()
        request = request.decode("utf-8").replace("'", '"')
        data = json.loads(request)
    return data

timeStop = "2018-11-17 00:00:00"
timeStart = "2018-10-18 00:00:00"
tStop = datetime.strptime(timeStop, "%Y-%m-%d %H:%M:%S")
tIt = datetime.strptime(timeStart, "%Y-%m-%d %H:%M:%S")
timestamp = int(tIt.timestamp())
stopToken = True


wikistamp = datetime.utcfromtimestamp(timestamp).strftime('%Y-%m-%dT%H:%M:%SZ')



while(stopToken):
    url = 'https://en.wikipedia.org/w/api.php?action=query&format=json&list=recentchanges&rcprop=ids%7Csizes%7Cfrcshow=!bot%7Clags%7Cuserid%7Ctimestamp&rclimit=100&rcstart='+wikistamp+'&rcdir=newer'
    print(url)

    data = call(url)
    query = data['query']
    content = query['recentchanges']
    lastTime = content[-1]['timestamp']
    lastTime = lastTime.replace('T',r' ')
    lastTime = lastTime.replace('Z',r'')
    tCurrent = datetime.strptime(lastTime, "%Y-%m-%d %H:%M:%S")


    contentStr = ','.join(str(v) for v in content)
    contentStr = contentStr.replace('\'',r'"')
    print(contentStr,end = "\r\n", file=open("wikiData.json", "a"))
    timestamp = timestamp+900
    wikistamp = datetime.utcfromtimestamp(timestamp).strftime('%Y-%m-%dT%H:%M:%SZ')

    if tCurrent >= tStop:
         break
