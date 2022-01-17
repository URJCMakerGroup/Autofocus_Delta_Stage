import numpy as np
import cv2
import time

"""
La función realiza el procesamiento Sobel horizontal a partir de una imagen en png, y 
al finalizar muestra el tiempo empleado para el procesamiento
"""

star = time.time()
#importar la imagen
image_original = cv2.imread('imagen_FPGA.png', cv2.IMREAD_COLOR)
#convierlo la imagena a escala de grises
image_gray = cv2.cvtColor(image_original, cv2.COLOR_BGR2GRAY)
#muestro la imagen original
cv2.imshow("Imagen original", image_gray)

#dimensiones de la imagen
[rows, columns] = np.shape(image_gray)
#creo una imagen compuesta por ceros del mismo tamaño que la imagen original
sobel_filtered_image = np.zeros(shape=(rows, columns))

# para el cálculo del tiempo de procesamiento
star = time.time()

#sobel kernel, aplico el filtro en los dos sentidos
sobel_bottom = np.array([[-1, -2, -1],
                        [0, 0, 0],
                        [1, 2, 1]])

sobel_top = np.array([[1, 2, 1],
                     [0, 0, 0],
                     [-1, -2, -1]])

#iterate through the image
for i in range(rows - 2):
    for j in range(columns - 2):
        gx_top = np.sum(np.multiply(sobel_bottom, image_gray[i:i + 3, j:j + 3])) #derivdad en una direccion
        gx_bottom = np.sum(np.multiply(sobel_top, image_gray[i:i + 3, j:j + 3])) #derivada en la direccion opuesta

        sobel_filtered_image[i + 1, j + 1] = np.sqrt(gx_top ** 2 + gx_bottom ** 2) #find the megnitude

#normalizo la imagen / valores de 0 a 255
cv2.normalize(sobel_filtered_image, sobel_filtered_image, 0, 255, cv2.NORM_MINMAX)

#redondeo el valor y lo convierto de float a int
sobel_filtered_image = np.round(sobel_filtered_image).astype(np.uint8)

#calculo el tiempo del procesamiento
end=time.time()
diff = end-star

#output x-derivative and y-derivatiive
cv2.imshow("sobel horizontal", sobel_filtered_image)
cv2.imwrite('imagen_proc_sobel.png',sobel_filtered_image)

diff = np.round(diff,4)
print("Tiempo de procesamiento: " + str(diff))
cv2.waitKey(0)
cv2.destroyAllWindows()
