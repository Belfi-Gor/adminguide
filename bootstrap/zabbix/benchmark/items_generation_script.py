import json
import sys
if (sys.argv[1] == '-generate_items'):
    result = []
    for i in range(int(sys.argv[2])):
        result.append({"{#TESTITEM}": (f"test_value{i+1}")})
    
    print(json.dumps(result))
else: # In other cases
        print(f"unknown input: {sys.argv[1]}") # print unknown input 