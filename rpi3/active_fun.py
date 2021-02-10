#!/usr/bin/python
# -*- coding: utf-8 -*-

import RPi.GPIO as GPIO                     # Импортируем библиотеку по работе с GPIO
import sys, traceback                       # Импортируем библиотеки для обработки исключений

from time import sleep                      # Импортируем библиотеку для работы со временем
from re import findall                      # Импортируем библиотеку по работе с регулярными выражениями
from subprocess import check_output         # Импортируем библиотеку по работе с внешними процессами

def get_temp():
    temp = check_output(["vcgencmd","measure_temp"]).decode()    # Выполняем запрос температуры
    temp = float(findall('\d+\.\d+', temp)[0])                   # Извлекаем при помощи регулярного выражения значение температуры из строки "temp=47.8'C"
    return(temp)                            # Возвращаем результат

try:
    tempOn =  60                            # Температура включения кулера
    controlPin = 14                         # Пин отвечающий за управление
    pinState = False                        # Актуальное состояние кулера
    
    # === Инициализация пинов ===
    GPIO.setmode(GPIO.BCM)                  # Режим нумерации в BCM
    GPIO.setup(controlPin, GPIO.OUT, initial=0) # Управляющий пин в режим OUTPUT

    while True:                             # Бесконечный цикл запроса температуры
        temp = get_temp()                   # Получаем значение температуры

        if temp > tempOn and not pinState or temp < tempOn - 10 and pinState:
            pinState = not pinState         # Меняем статус состояния
            GPIO.output(controlPin, pinState) # Задаем новый статус пину управления

        print(str(temp) + "  " + str(pinState)) # Выводим температуру в консоль
        sleep(1)                            # Пауза - 1 секунда

except KeyboardInterrupt:
    # ...
    print("Exit pressed Ctrl+C")            # Выход из программы по нажатию Ctrl+C
except:
    # ...
    print("Other Exception")                # Прочие исключения
    print("--- Start Exception Data:")
    traceback.print_exc(limit=2, file=sys.stdout) # Подробности исключения через traceback
    print("--- End Exception Data:")
finally:
    print("CleanUp")                        # Информируем о сбросе пинов
    GPIO.cleanup()                          # Возвращаем пины в исходное состояние
    print("End of program")                 # Информируем о завершении работы программы

