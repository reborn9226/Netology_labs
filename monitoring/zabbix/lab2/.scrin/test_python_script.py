import sys
import os
import re
if (sys.argv[1] == '-ping'): # Если -ping
        result=os.popen("ping -c 1 " + sys.argv[2]).read() # пингуем указаный адрес
        result=re.findall(r"time=(.*) ms", result) # Выдергиваем из результата время ответа
        print(result[0]) # Выводим результат в консоль
elif (sys.argv[1] == '-simple_print'): # Если simple_print
        print(sys.argv[2]) # Выводим в консоль содеоржимое второго аргумента
else: # Во всех остальных случаях
        print(f"Unknown input: {sys.argv[1]}")