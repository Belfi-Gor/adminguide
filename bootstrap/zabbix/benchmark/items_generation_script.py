import json
import sys

# Example:
# You need something looks like this in your cusctom user parametes
# UserParameter=your_userparameter_name[*], python3 /etc/zabbix/items_generation_script.py $1 $2 $3

# So you will be able to use this usersparameter like this:
# zabbix_get -s 127.0.0.1 -p 10050 -k "your_userparameter_name[-generate_items,10,random_int_value]"
# zabbix_get -s 127.0.0.1 -p 10050 -k "your_userparameter_name[-generate_items,10,random_text_value]"
# zabbix_get -s 127.0.0.1 -p 10050 -k "your_userparameter_name[-generate_items,10,random_float_value]"
# zabbix_get -s 127.0.0.1 -p 10050 -k "your_userparameter_name[-generate_items,10,random_qwe_value]"

# Or you can use it directly from the console
# python3 ./items_generation_script.py -generate_items 10 random_int_value
# [{"{#ITEMNAME}": "random_int_value1", "{#ITEMVALUE}": "random_int_value", "{#ITEMNUMBER}": 1}, {"{#ITEMNAME}": "random_int_value2", "{#ITEMVALUE}": "random_int_value", "{#ITEMNUMBER}": 2}, {"{#ITEMNAME}": "random_int_value3", "{#ITEMVALUE}": "random_int_value", "{#ITEMNUMBER}": 3}, {"{#ITEMNAME}": "random_int_value4", "{#ITEMVALUE}": "random_int_value", "{#ITEMNUMBER}": 4}, {"{#ITEMNAME}": "random_int_value5", "{#ITEMVALUE}": "random_int_value", "{#ITEMNUMBER}": 5}, {"{#ITEMNAME}": "random_int_value6", "{#ITEMVALUE}": "random_int_value", "{#ITEMNUMBER}": 6}, {"{#ITEMNAME}": "random_int_value7", "{#ITEMVALUE}": "random_int_value", "{#ITEMNUMBER}": 7}, {"{#ITEMNAME}": "random_int_value8", "{#ITEMVALUE}": "random_int_value", "{#ITEMNUMBER}": 8}, {"{#ITEMNAME}": "random_int_value9", "{#ITEMVALUE}": "random_int_value", "{#ITEMNUMBER}": 9}, {"{#ITEMNAME}": "random_int_value10", "{#ITEMVALUE}": "random_int_value", "{#ITEMNUMBER}": 10}]

# python3 ./items_generation_script.py -generate_items 10 random_text_value
# [{"{#ITEMNAME}": "random_text_value1", "{#ITEMVALUE}": "random_text_value", "{#ITEMNUMBER}": 1}, {"{#ITEMNAME}": "random_text_value2", "{#ITEMVALUE}": "random_text_value", "{#ITEMNUMBER}": 2}, {"{#ITEMNAME}": "random_text_value3", "{#ITEMVALUE}": "random_text_value", "{#ITEMNUMBER}": 3}, {"{#ITEMNAME}": "random_text_value4", "{#ITEMVALUE}": "random_text_value", "{#ITEMNUMBER}": 4}, {"{#ITEMNAME}": "random_text_value5", "{#ITEMVALUE}": "random_text_value", "{#ITEMNUMBER}": 5}, {"{#ITEMNAME}": "random_text_value6", "{#ITEMVALUE}": "random_text_value", "{#ITEMNUMBER}": 6}, {"{#ITEMNAME}": "random_text_value7", "{#ITEMVALUE}": "random_text_value", "{#ITEMNUMBER}": 7}, {"{#ITEMNAME}": "random_text_value8", "{#ITEMVALUE}": "random_text_value", "{#ITEMNUMBER}": 8}, {"{#ITEMNAME}": "random_text_value9", "{#ITEMVALUE}": "random_text_value", "{#ITEMNUMBER}": 9}, {"{#ITEMNAME}": "random_text_value10", "{#ITEMVALUE}": "random_text_value", "{#ITEMNUMBER}": 10}]

# python3 ./items_generation_script.py -generate_items 2 random_float_value
# [{"{#ITEMNAME}": "random_float_value1", "{#ITEMVALUE}": "random_float_value", "{#ITEMNUMBER}": 1}, {"{#ITEMNAME}": "random_float_value2", "{#ITEMVALUE}": "random_float_value", "{#ITEMNUMBER}": 2}]

# python3 ./items_generation_script.py -generate_items 10 random_qwe_value
# [{"{#ITEMNAME}": "random_qwe_value1", "{#ITEMVALUE}": "random_qwe_value", "{#ITEMNUMBER}": 1}, {"{#ITEMNAME}": "random_qwe_value2", "{#ITEMVALUE}": "random_qwe_value", "{#ITEMNUMBER}": 2}, {"{#ITEMNAME}": "random_qwe_value3", "{#ITEMVALUE}": "random_qwe_value", "{#ITEMNUMBER}": 3}, {"{#ITEMNAME}": "random_qwe_value4", "{#ITEMVALUE}": "random_qwe_value", "{#ITEMNUMBER}": 4}, {"{#ITEMNAME}": "random_qwe_value5", "{#ITEMVALUE}": "random_qwe_value", "{#ITEMNUMBER}": 5}, {"{#ITEMNAME}": "random_qwe_value6", "{#ITEMVALUE}": "random_qwe_value", "{#ITEMNUMBER}": 6}, {"{#ITEMNAME}": "random_qwe_value7", "{#ITEMVALUE}": "random_qwe_value", "{#ITEMNUMBER}": 7}, {"{#ITEMNAME}": "random_qwe_value8", "{#ITEMVALUE}": "random_qwe_value", "{#ITEMNUMBER}": 8}, {"{#ITEMNAME}": "random_qwe_value9", "{#ITEMVALUE}": "random_qwe_value", "{#ITEMNUMBER}": 9}, {"{#ITEMNAME}": "random_qwe_value10", "{#ITEMVALUE}": "random_qwe_value", "{#ITEMNUMBER}": 10}]

# This script is just reciaving name of parameters to generate and amount of them. And returns json as an answear. Useful to generating thousends of items with autodiscovery. Need for benchmarking zabbix.

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