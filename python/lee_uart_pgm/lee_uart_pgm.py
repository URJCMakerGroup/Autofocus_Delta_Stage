"""
 El código abre el puerto serie durante 20segundos para obtener los bytes de la UART,
 una vez creado el archivo, se modifica para adecuarlo al formato .PGM
 Es neceario definir los siguientes parámetros:
    - configuración del puerto
    - nombre del archivo donde guardar los bytes obtenidos
    - nombre del archivo en el cual adecuar la información al formato .pgm
    - dimensiones de la imagen
"""
import time
import serial
import math
import numpy as np
import os

#///////////////////////////////////////////////////////////////
#------- Obtención de los datos por el puerto serie ------------
#///////////////////////////////////////////////////////////////
# Configuración de la conexión por el puerto serie
ser = serial.Serial(
    port='COM7',
    baudrate=9600,
    timeout=2,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_TWO,
    bytesize=serial.EIGHTBITS
)
ser.isOpen()

# Archivo donde voy a guardar los bytes obtenidos por la UART
img_uart = 'test_uart.bin'
fout=open(img_uart, 'wb')

# Temporizador de 20s para obtener los datos por el puerto serie.
# NOTA: aquí hay que implementar alguna mejora, pero si leo el tamaño del archivo puedo perder algun byte. 
t_end = time.time() + 20 
while  time.time() < t_end:
        bytesToRead = ser.inWaiting()
        data = ser.read(bytesToRead)
        fout.write(data)
fout.close()
# Compruebo si se han mandado todos los bytes verificando la dimensión del archivo
file = open('D:/carlo/UNIVERSIDAD/TFM/3 - PYTHON/test_uart.bin')
file.seek(0, os.SEEK_END)
print("Tamaño del archivo UART :", file.tell(), "bytes")


#///////////////////////////////////////////////////////////////
#------------- Creación del archivo .PGM -----------------------
#///////////////////////////////////////////////////////////////
# Defino la ubicación del archivo, añado un cero al final porque la uart no me manda el último pxl
# y lo ajusto al formato de la imagen 128x128
arr = np.fromfile("test_uart.bin",  dtype=np.uint8, count=-1, sep='', offset=0)
arr2 = np.append ( arr,[0])
ancho = 128
alto = 128
img = arr2.reshape((ancho,alto))

#creo el archivo para escribir
img_pgm = 'test_img_uart.pgm'
fout=open(img_pgm, 'wb')
# defino las primeras lineas con el formato pgm P2 - modificar si uso P5
pgmHeader = 'P2'  +  '\n' + str(ancho) + ' ' + str(alto) +  '\n' + str(255) +  '\n'
pgmHeader_byte = bytearray(pgmHeader,'utf-8')
fout.write(pgmHeader_byte)
# recorro la matriz creada creando un salto de línea cada 128 bytes
for j in range(ancho):
    bnd = list(img[j,:])
    bnd_str = np.char.mod('%d',bnd)
    bnd_str = np.append(bnd_str,'\n')
    bnd_str = [' '.join(bnd_str)][0]    
    bnd_byte = bytearray(bnd_str,'utf-8') 
    fout.write(bnd_byte)

fout.close()
