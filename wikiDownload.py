import urllib.request, json
from datetime import datetime

timeStop = "2018-11-07 00:00:00"
ts = datetime.strptime(timeStop, "%Y-%m-%d %H:%M:%S")

stopToken = True

while(stopToken):
    with urllib.request.urlopen("https://en.wikipedia.org/w/api.php?action=query&format=json&list=recentchanges&rcprop=ids%7Csizes%7Cfrcshow=!bot%7Clags%7Cuserid%7Ctimestamp&rclimit=500&rcstart=1538949600&rcdir=newer") as url:
        data = json.loads(url.read().decode())
        query = data['query']
        content = query['recentchanges']
        lastTime = content[-1]['timestamp']
        lastTime = lastTime.replace('T',r' ')
        lastTime = lastTime.replace('Z',r'')
        tc = datetime.strptime(lastTime, "%Y-%m-%d %H:%M:%S")


        contentStr = ','.join(str(v) for v in content)
        contentStr = contentStr.replace('\'',r'"')
        print(contentStr, file=open("wikiData.json", "a"))
    if tc >= ts:
         break
    print(",", file=open("wikiData.json", "a"))

print("]}", file=open("wikiData.json", "a"))
#print(data, file=open("wikiData.json", "a"))
