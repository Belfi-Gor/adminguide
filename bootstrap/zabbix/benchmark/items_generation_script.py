import json
result = []
result.append({"{#TESTITEM1}":"test1","{#TESTITEM2}":"test2"})
result.append({"{#TESTITEM1}":"test3","{#TESTITEM2}":"test4"})
print(json.dumps(result))
