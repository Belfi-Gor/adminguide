# import sys
# if (sys.argv[1] == 'generate_items'):

# else: # Во всех остальных случаях
#         print(f"unknown input: {sys.argv[1]}") #Выводим непонятый запрос в консоль.

import json
result = []
result.append({"{#test_item}":"test1","{#test_item}":"test2"})
result.append({"{#test_item}":"test3","{#test_item}":"test4"})
print(json.dumps(result))
