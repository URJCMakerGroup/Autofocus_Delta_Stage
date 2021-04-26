"""
 El código emplea dos funciones:
 - lee serial: lee el puerto serie y genera un archivo.bin
        * nombre_bin: nombre del archivo .bin donde se almacenarán los bytes recibidos
        * ancho, alto: dimensiones del archivo que se va a recibir

 - bin_to_pgm: a partir del archivo.bin genera un archivo.pgm para poder visualizar la imagen
        * nombre_bin: nombre del archivo binario que se va a emplear
        * alto, ancho: dimensiones de la imagen
        * nombre_pgm: nombre del archivo .pgm que se va a crear
"""
import time
import serial
import math
from cv2 import cv2
import numpy as np
import os

def lee_serial(nombre_bin, ancho, alto):
#Lectura del puerto serie
    ser = serial.Serial(
        port='COM7',
        baudrate=9600, #9600,
        timeout=0,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_TWO,
        bytesize=serial.EIGHTBITS,
        )
    ser.isOpen()

    dimensiones = ancho*alto
    archivo_bin = nombre_bin + ".bin"
    fout=open(archivo_bin, 'wb')

    total_bits = 0
    while total_bits < dimensiones:
        bytesToRead = ser.inWaiting()
        data = ser.read(bytesToRead)
        fout.write(data)
        total_bits = len(data) + total_bits
        print("total bits:" + str(total_bits))
        #time.sleep(0.1)
    ser.close()


def bin_to_pgm(ancho, alto, nombre_bin, nombre_png):
#Generación del archivo PGM:
    #Se crea una array de numpy con los bytes del archivo .bin
    archivo_bin = nombre_bin + ".bin"
    arr = np.fromfile(archivo_bin,  dtype=np.uint8, count=-1, sep='', offset=0)
    img = arr.reshape((ancho,alto))

    #Generación del archivo .pgm
    archivo_png = nombre_png + '.pgm'
    fout=open(archivo_png, 'wb')
    pgmHeader = 'P2'  +  '\n' + str(ancho) + ' ' + str(alto) +  '\n' + str(255) +  '\n'
    pgmHeader_byte = bytearray(pgmHeader,'utf-8')
    fout.write(pgmHeader_byte)

    #Se colocan los bytes según las dimensiones definidas
    for j in range(ancho):
        bnd = list(img[j,:])
        bnd_str = np.char.mod('%d',bnd)
        bnd_str = np.append(bnd_str,'\n')
        bnd_str = [' '.join(bnd_str)][0]    
        bnd_byte = bytearray(bnd_str,'utf-8') 
        fout.write(bnd_byte)
    fout.close()

#Se llama a la función:
lee_serial("test",320,240)
print("- Imagen capturada")
time.sleep(1)
bin_to_pgm(320, 240, "test", "test_pgm")
print("- Archivo procesado, PGM listo")