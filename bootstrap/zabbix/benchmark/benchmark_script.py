import sys
import os
import re
import random
if (sys.argv[1] == '-ping'): # Если -ping
        result=os.popen("ping -c 1 " + sys.argv[2]).read() # Делаем пинг по заданному адресу
        result=re.findall(r"time=(.*) ms", result) # Выдёргиваем из результата время
        print(result[0]) # Выводим результат в консоль
elif (sys.argv[1] == '-simple_print'): # Если simple_print
    if (sys.argv[2] == 'RTV'): #Random text value
        result = ["test_value_1", "test_value_2", "test_value_3", "test_value_4"]
        print(result[random.randrange(len(result))])
    elif (sys.argv[2] == 'RIV'):
        # Needed to generate random int valuse for benchmark zabbix
        # Example of usage:
        # python3 ./benchmark_script.py -simple_print random_int_value
        # 138
        # python3 ./benchmark_script.py -simple_print random_int_value
        # 782
        # python3 ./benchmark_script.py -simple_print random_int_value
        # 405
        print(random.randrange(1000))
    elif (sys.argv[2] == 'RFV'): # Random Float Value
        print(random.uniform(0, 100))
    else:
        print(sys.argv[2]) # Выводим в консоль содержимое sys.arvg[2]
else: # Во всех остальных случаях
        print(f"unknown input: {sys.argv[1]}") # Выводим непонятый запрос в консоль.
