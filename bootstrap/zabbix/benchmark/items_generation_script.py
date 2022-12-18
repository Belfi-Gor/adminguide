import json
import sys
if (sys.argv[1] == '-generate_items'):
    result = []
    for i in range(int(sys.argv[2])):
        #if (sys.argv[3] == 'random_text_value'):
        row = {"{#ITEMNAME}": f"{sys.argv[3]}{i+1}"}
        row["{#ITEMVALUE}"] = sys.argv[3]
        row["{#ITEMNUMBER}"] = i+1
        result.append(row)
    
    print(json.dumps(result))
else: # In other cases
        print(f"unknown input: {sys.argv[1]}") # print unknown input 