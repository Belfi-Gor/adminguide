# import sys
# if (sys.argv[1] == 'generate_items'):

# else: # Во всех остальных случаях
#         print(f"unknown input: {sys.argv[1]}") #Выводим непонятый запрос в консоль.

import json
result = []
result.append({"{#test1}":test1,"{#test2}":test2})
result.append({"{#test3}":test3,"{#test4}":test4})
print(json.dumps(result))
