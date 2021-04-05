import os                                   # Импортируем библиотеку по работе с ОС
from time import sleep                      # Импортируем библиотеку для работы со временем
from re import findall                      # Импортируем библиотеку по работе с регулярными выражениями

def get_temp():
    temp = os.popen("vcgencmd measure_temp").readline()  # Выполняем запрос температуры
    temp = float(findall('\d+\.\d+', temp)[0]) # Извлекаем при помощи RE значение температуры из строки "temp=47.8'C"
    return(temp)                            # Возвращаем результат

while True:                                 # Бесконечный цикл запроса температуры
    temp = get_temp()                       # Получаем значение температуры
    print(temp)                             # Выводим температуру в консоль
    sleep(1)                                # Ждем 1 секунду

