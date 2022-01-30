import numpy as np
import cv2
import time
from matplotlib import pyplot as plt

"""
La función realiza el procesamiento Sobel horizontal a partir de una imagen en png, y 
al finalizar muestra el tiempo empleado para el procesamiento
"""

star = time.time()
#importar la imagen
image_original = cv2.imread('original.png', cv2.IMREAD_COLOR)
#convierlo la imagena a escala de grises
image_gray = cv2.cvtColor(image_original, cv2.COLOR_BGR2GRAY)
#dimensiones de la imagen
[rows, columns] = np.shape(image_gray)
#creo una imagen compuesta por ceros del mismo tamaño que la imagen original
sobel_filtered_image = np.zeros(shape=(rows, columns))
bb = np.zeros(shape=(rows, columns))

# para el cálculo del tiempo de procesamiento
star = time.time()

#sobel kernel, aplico el filtro en los dos sentidos
sobel_horizontal = np.array([[-1, -2, -1],
                        [0, 0, 0],
                        [1, 2, 1]])

for i in range(rows - 2):
    for j in range(columns - 2):
        a = np.sum(np.multiply(sobel_horizontal, image_gray[i:i + 3, j:j + 3]))
        sobel_filtered_image[i + 1, j + 1] = (abs(a))
        if sobel_filtered_image[i,j] >= 255:
            sobel_filtered_image[i,j] = 255
        else:
            sobel_filtered_image[i,j] = sobel_filtered_image[i,j]

print(sobel_filtered_image)
cv2.imwrite('Python.png', sobel_filtered_image)

print("....................................................")

#calculo el tiempo del procesamiento
end=time.time()
diff = np.round(end-star,4)
print("Tiempo de procesamiento: " + str(diff))



original = cv2.imread("original.png")
img1 = cv2.imread("FPGA.png")
img2 = cv2.imread("Python.png")
result = cv2.subtract(img1,img2)

cv2.imshow("original", original)
cv2.imshow("FPGA", img1)
cv2.imshow("Python", img2)
cv2.imshow("resta de imagenes", result)
cv2.imwrite('resta.png', result)



cv2.waitKey(0)
cv2.destroyAllWindows()
