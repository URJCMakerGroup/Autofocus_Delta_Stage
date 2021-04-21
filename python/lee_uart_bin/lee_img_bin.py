"""
El código extrae los valores de un archivo .bin y crea un archivo .pgm 
para poder visualizar la imagen obtenida por la UART.
Proceso:
    - introduzco las dimensiones de la imagen deseada.
    - selecciono el archivo que quiero leer
    - genero un array con los valores del archivo .bin
    - creo una matriz adecuada a las dimensiones establecidas
    - creo un archivo nuevo donde guardar la imagen.pgm
    - defino el formato PGM P2
    - guardo linea a linea los valores de la matriz
--
NOTA: como la imagen debe ser de 128x128 y la uart no me manda el último píxel
he añadido un cero al array. Esto habría que corregirlo.
"""
import numpy as np

#dimensiones de la imagen a tratar:
ancho = 128
alto = 128

#-1 para todos en el count
arr = np.fromfile("lenna.bin",  dtype=np.uint8, count=-1, sep='', offset=0)
arr2 = np.append ( arr,[0])
img = arr2.reshape((ancho,alto))

#creo el archivo para escribir
img_pgm = 'lenna_test.pgm'
fout=open(img_pgm, 'wb')
# defino las primeras lineas con el formato pgm P2 - modificar si uso P5
pgmHeader = 'P2'  +  '\n' + str(ancho) + ' ' + str(alto) +  '\n' + str(255) +  '\n'
pgmHeader_byte = bytearray(pgmHeader,'utf-8')
fout.write(pgmHeader_byte)

for j in range(alto):
    bnd = list(img[j,:])
    bnd_str = np.char.mod('%d',bnd)
    bnd_str = np.append(bnd_str,'\n')
    bnd_str = [' '.join(bnd_str)][0]    
    bnd_byte = bytearray(bnd_str,'utf-8') 
    fout.write(bnd_byte)

fout.close()