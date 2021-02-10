import struct
import smbus
import sys
import time
import RPi.GPIO as GPIO

import Adafruit_GPIO.SPI as SPI
import Adafruit_SSD1306

from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont

import os
import subprocess

import re
import datetime

WAIT_FOR_NEXT_FRAME = 10
SCREENS = 3

KNOX = 0

RST = None
DC = 23
SPI_PORT = 0
SPI_DEVICE = 0

disp = Adafruit_SSD1306.SSD1306_128_64(rst=RST)


# Initialize library.
disp.begin()

# Clear display.
disp.clear()
disp.display()

# Create blank image for drawing.
# Make sure to create image with mode '1' for 1-bit color.
width = disp.width
height = disp.height
image = Image.new('1', (width, height))

# Get drawing object to draw on image.
draw = ImageDraw.Draw(image)

# Draw a black filled box to clear the image.
draw.rectangle((0,0,width,height), outline=0, fill=0)

# Draw some shapes.
# First define some constants to allow easy resizing of shapes.
padding = -2
top = padding
bottom = height-padding
# Move left to right keeping track of the current x position for drawing shapes.
x = 0


# Load default font.
font = ImageFont.load_default()

# Alternatively load a TTF font.  Make sure the .ttf font file is in the same directory as the python script!
# Some other nice fonts to try: http://www.dafont.com/bitmap.php
# font = ImageFont.truetype('Minecraftia.ttf', 8)


GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(4,GPIO.IN)
BUS = smbus.SMBus(1)

#SCREENS -= 1

def main():
    PowerOnReset(BUS)
    QuickStart(BUS)

    try:
        while_true()
    except KeyboardInterrupt:
        # print('Вы здесь.')
        clear_disp()
        return 1


def replacer(changed_string, list_replace):
    changed_string = str(changed_string)
    for r in list_replace:
        changed_string = changed_string.replace(r, '')
    return changed_string


def screens(number_screen):
    # ups_lite
    voltage = round(readVoltage(BUS), 2)

    if GPIO.input(4) == GPIO.HIGH:
        charged = "(charge) "
    elif GPIO.input(4) == GPIO.LOW:
        charged = ""
    else:
        charged = 'wft'

    global KNOX
    capacity = round(readCapacity(BUS))
    if (capacity < 15 or voltage <= 3.5) and KNOX > 3 and charged == "":
        clear_disp()
        os.system("sudo poweroff")
    KNOX += 1
    if KNOX == 254:
        KNOX = 5

    battery = '{0}% {1}{2}V'.format(capacity, charged, voltage)

    # date and time with seconds '%d-%m-%Y %H:%M:%S'
    date_and_time = datetime.datetime.now().strftime('%d-%m-%Y %H:%M')
    date_and_time = '{0}/{1}  '.format(
        number_screen + 1, SCREENS
    ) + date_and_time

    trimmer = '+-+-+-+-+-+-+-+-+-+-+'

    to_return = [date_and_time, battery, trimmer]

    if number_screen == 0:
        # network screen
        network_status = 'Connected to:'
        #cmd = "iwconfig wlan0 | sed -n 's/.*Access Point: \([0-9\:A-F]\{17\}\).*/\1/p'"
        cmd = "iwgetid -r"
        bssid_name = subprocess.check_output(cmd, shell = True)
        #print(type(bssid_name))
        #bssid_name = 'Wi-Fi: ' + str(bssid_name)
        #print(bssid_name)

        cmd = "hostname -I | cut -d\' \' -f1"
        ip = subprocess.check_output(cmd, shell = True)
        ip = 'IP: ' + replacer(ip, ["'", 'b', '\\', 'n'])

        if_return = [
            network_status, bssid_name, ip
        ]
        pass

    elif number_screen == 1:
        cmd = "top -bn1 | grep load | awk '{printf \"CPU Load: %.2f\", $(NF-2)}'"
        cpu = subprocess.check_output(cmd, shell = True )
        cpu = replacer(cpu, ["'", 'b']) + '%'

        cmd = "free -m | awk 'NR==2{printf \"Mem: %s/%sMB %.2f%%\", $3,$2,$3*100/$2 }'"
        memory_usage = subprocess.check_output(cmd, shell = True )
        memory_usage = replacer(memory_usage, ["'", 'b', '\\', 'n'])

        cmd = "df -h | awk '$NF==\"/\"{printf \"Disk: %d/%dGB %s\", $3,$2,$5}'"
        disk_usage = subprocess.check_output(cmd, shell = True )
        disk_usage = replacer(disk_usage, ["'", 'b'])

        cmd = "vcgencmd measure_temp"
        temp = subprocess.check_output(cmd, shell = True )
        temp = 'CPU Temp: ' + replacer(temp, ['"', 'b', '\\', 'n', 'temp='])

        if_return = [
            cpu, temp, disk_usage
        ]
        pass

    elif number_screen == 2:
        cmd = "uptime -p"
        uptime = subprocess.check_output(cmd, shell = True )
        uptime = 'Uptime: ' + replacer(uptime.strip(), ['"', '\n', 'b', 'up ', "'"])
        # uptime = 'Uptime: 5 days, 2 hours, 15 minutes'
        uptime = uptime.split(', ')

        if_return = uptime

    else:
        if_return = ['error with screen']
        pass

    return to_return + if_return


def while_true():
    now = 0
    while True:
        # Draw a black filled box to clear the image.
        draw.rectangle((0,0,width,height), outline=0, fill=0)

        number_screen = round(now % SCREENS)
        # screen_line = 'Screen {0} of {1}.'.format(number_screen, SCREENS - 1)
        # text_list = [screen_line] + screens(number_screen)
        text_list = screens(number_screen)
        for index, d_text in enumerate(text_list):
            draw.text((0, top + index * 9), d_text, font=font, fill=255)
        

        # Display image.
        disp.image(image)
        disp.display()
        time.sleep(WAIT_FOR_NEXT_FRAME)
        now += 1
        if now == SCREENS * 10:
            now = 0



def readVoltage(bus):
    "This function returns as float the voltage from the Raspi UPS Hat via the provided SMBus object"
    address = 0x36
    read = bus.read_word_data(address, 0X02)
    swapped = struct.unpack("<H", struct.pack(">H", read))[0]
    voltage = swapped * 1.25 /1000/16
    return voltage


def readCapacity(bus):
    "This function returns as a float the remaining capacity of the battery connected to the Raspi UPS Hat via the provided SMBus object"
    address = 0x36
    read = bus.read_word_data(address, 0X04)
    swapped = struct.unpack("<H", struct.pack(">H", read))[0]
    capacity = swapped/256
    return capacity


def QuickStart(bus):
    address = 0x36
    bus.write_word_data(address, 0x06,0x4000)
      

def PowerOnReset(bus):
    address = 0x36
    bus.write_word_data(address, 0xfe,0x0054)


def clear_disp():
    disp.clear()
    disp.display()


if __name__ == '__main__':
    main()
