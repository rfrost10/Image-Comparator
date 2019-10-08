import csv
import numpy as np
from collections import defaultdict
d = defaultdict(list)

thisFile="/Users/jayashreekalpathy-cramer/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/classify/set34_taskToImage.csv"
newFile="/Users/jayashreekalpathy-cramer/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/classify/set34_taskToImage_noDup.csv"
delListFile="/Users/jayashreekalpathy-cramer/Syncplicity/retinalImaging/website/Image-Comparator/data/recentResults/classify/set34_delTask.csv"


def removeDups(inFile, outFile):
    csvF = np.genfromtxt (inFile, delimiter=",", skip_header=1)
    delList=[]
    for k, v in csvF:
            d[v].append(k)

            #print len(d[v])
            if len(d[v])==2:
                print v
                print d[v]
                print k
                delList.append(d[v][1])
                del(d[v][1])
                print d[v]
    print delList
    delL=csv.writer(open(delListFile,'wb'))
    rows = zip(delList)
    delL.writerow(['taskID'])
    for row in rows:
        delL.writerow(row)

    dw = csv.writer(open(outFile, 'wb'))
    dw.writerow(['imageId', 'taskID'])
    for key, value in d.items():
       dw.writerow([key, value[0]])

removeDups(thisFile, newFile)
