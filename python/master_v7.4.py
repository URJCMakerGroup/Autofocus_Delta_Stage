import tkinter
from tkinter import *
from tkinter import ttk
import serial
import time
import math
from cv2 import cv2
import numpy as np
import os
import shutil

#puerto serie

#comunicacion puerto serie
global ser
try:
    ser = serial.Serial(
            port='COM7',
            baudrate=115200,  # 9600,
            timeout=0,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_TWO,
            bytesize=serial.EIGHTBITS,
    )
    ser.isOpen()
    print("-- FPGA conectada --")
except:
    print(" -- Problema conexión puerto serie --")

#----------------------------------------------------------------
count_m1 = 0
count_m2 = 0
count_m3 = 0
dirflag= True

def env_serial(arg):
    bin_num = arg.to_bytes(8, byteorder='big')
    #print(bin_num)
    ser.write(bin_num)
    if arg==0 or arg==255:
        pass
    else:
        print("Se ha mandado " + str(arg) + " por el puerto serie")
        print("----")

# cuadro desplegable de modo de movimiento
def box(win):
    selec_prec = tkinter.StringVar()
    global prec_cb
    prec_cb = ttk.Combobox(win, width=13, textvariable= selec_prec)
    prec_cb['values'] = precision
    prec_cb['state'] = 'readonly'  # normal
    prec_cb.bind('<<ComboboxSelected>>', cambio_prec)
    prec_cb.grid(row=3, column=2, sticky=W)
def cambio_prec(event):
    #showinfo(title='Result', message=msg
    if prec_cb.get() == "Mov.continuo":
        print("Modo de movimiento: - Continuo -")
    elif prec_cb.get() == "Rev.completa":
        print("Modo de movimiento: - Rev.completa -")
    else:
        print("Modo de movimiento: - Media rev. -")

class microscopio():
    def __init__(self, log=lambda x: print(x)):
        self.WriteLog = log
        self.WriteLog(" Open App")
        global precision
        precision=["Mov.continuo", "Rev.completa", "Media rev."]

# -------------------------------------------------------------------------
    def lee_serial(self, nombre_bin, ancho, alto):
    #Lectura del puerto serie
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

    def bin_to_pgm(self, ancho, alto, nombre_bin, nombre_png):
    #Generación del archivo PGM:
        #Se crea una array de numpy con los bytes del archivo .bin
        archivo_bin = nombre_bin + ".bin"
        arr = np.fromfile(archivo_bin,  dtype=np.uint8, count=-1, sep='', offset=0)
        print(arr)
        a=arr[:76800]#--------------------------------------------------- corregir
        img = a.reshape((ancho,alto))

        #Generación del archivo .pgm
        archivo_png = nombre_png + '.pgm'
        fout=open(archivo_png, 'wb')
        pgmHeader = 'P2'  +  '\n' + str(ancho) + ' ' + str(alto) +  '\n' + str(255) +  '\n'
        pgmHeader_byte = bytearray(pgmHeader,'utf-8')
        fout.write(pgmHeader_byte)

        #Se colocan los bytes según las dimensiones definidas
        for j in range(ancho):
            bnd = list(img[j, :])
            bnd_str = np.char.mod('%d', bnd)
            bnd_str = np.append(bnd_str, '\n')
            bnd_str = [' '.join(bnd_str)][0]
            bnd_byte = bytearray(bnd_str, 'utf-8')
            fout.write(bnd_byte)
        fout.close()

        suma = np.sum(arr)
        return(suma)

    def save_img_serie(self):
        estado_inicio = True #---------------------------------------------
        pos.config(text = "Estado actual: Mandando img enfocada... ")
        self.root.update()
        env_serial(4)
        #Se llama a la función:
        nombrebin = "testbin"
        nombrepgm = "testpgm"
        dato = []

        for i in range(0, 1, 1):
            print("- Esperando dato...")
            img=(nombrebin+str(i))
            self.lee_serial(img, 320, 240)
            print("- Imagen capturada")
            #time.sleep(1)

            a = self.bin_to_pgm(320, 240, nombrebin+str(i), nombrepgm+str(i))

            print("- Archivo procesado, PGM listo")
            #print("Suma DEC:" +  str(a) ) #str(a[:76800])
            #print("Suma HEX:" + str( hex(a)) )
            print( "----------------------------------" )

            destination =r"C:\Users\carlo\PycharmProjects\pythonProject\serial\img_OV7670"
            dest_pgm = shutil.copy(nombrepgm + str(i) + '.pgm', destination)
            shutil.copy(nombrebin + str(i) + '.bin', destination)

            os.remove(nombrepgm + str(i) + '.pgm')
            os.remove(nombrebin + str(i) + '.bin')
            #print("Destination path:", dest_pgm)
            pos.config(text = "Estado actual: Imagen recibida ")
            self.root.update()

            if estado_inicio == True:
                os.system("C:\\Users\\carlo\\PycharmProjects\\pythonProject\\serial\\img_OV7670\\" + nombrepgm + str(i) + '.pgm')
                estado_inicio = False

            pos.config(text = "Estado actual: Inicio ")
            self.root.update()

    def save_img_autofocus(self):
        estado_inicio = False #---------------------------------------------
        pos.config(text = "Estado actual: recibiendo img... 1/3 ")
        self.root.update()
        env_serial(4)
        #Se llama a la función:
        nombrebin = "testbin"
        nombrepgm = "testpgm"
        dato = []
        lista_datos_enfoque=[]
        max_ele=0

        for i in range(0, 3):
            pos.config(text = "Estado actual: autoenfoque %s/3"%i)
            self.root.update()

            print("- Esperando dato...")
            img=(nombrebin+str(i))
            self.lee_serial(img, 320, 240)
            print("- Imagen capturada")
            #time.sleep(1)

            a = self.bin_to_pgm(320, 240, nombrebin+str(i), nombrepgm+str(i))

            print("- Archivo procesado, PGM listo")
            print(  str(i) + ")------------------------" )
            print("Suma DEC:" +  str(a) ) #str(a[:76800])
            print("Suma HEX:" + str( hex(a)) )
            lista_datos_enfoque.append(a)
            print( "----------------------------------" )

            destination =r"C:\Users\carlo\PycharmProjects\pythonProject\serial\img_OV7670"
            dest_pgm = shutil.copy(nombrepgm + str(i) + '.pgm', destination)
            shutil.copy(nombrebin + str(i) + '.bin', destination)

            os.remove(nombrepgm + str(i) + '.pgm')
            os.remove(nombrebin + str(i) + '.bin')
            #print("Destination path:", dest_pgm)
            pos.config(text = "Estado actual: imagen recibida ")
            self.root.update()

            if estado_inicio == True:
                os.system("C:\\Users\\carlo\\PycharmProjects\\pythonProject\\serial\\img_OV7670\\" + nombrepgm + str(i) + '.pgm')

        #pos.config(text = "Estado actual: inicio")

        for j in range(1,len(lista_datos_enfoque)):
            if int(lista_datos_enfoque[i]) > max_ele:
                max_ele= int(lista_datos_enfoque[i])

        print("Lista de datos obtenidos:")
        print(lista_datos_enfoque)
        print( "- Posición máximo: " + str(lista_datos_enfoque.index(max(lista_datos_enfoque))) + " -  Valor: " + str(max(lista_datos_enfoque)))
        print( "----------------------------------" )

    def captura_img_serie(self):
        global cap_is_on, img
        if cap_is_on:
            cap.config(text = "Activar cam")
            cap_is_on = False
            print("- Imagen capturada")
            env_serial(2)
            pos.config(text = "Estado actual: Inicio ")

        else:
            cap.config(text = "Capturar IMG")
            cap_is_on = True
            print("- Captura deshabilitada")
            estado_microscopio = str("Imagen capturada")
            env_serial(1)
            pos.config(text = "Estado actual: Img. capturada ")

#-------- Motores: ----------

    def reset(self):
        global count_m1, count_m2, count_m3
        pos.config(text = "Estado actual: Inicio ")
        print("Reseteo")
        env_serial(1)
        count_m1=0
        count_m2=0
        count_m3=0
        homeflag==False
        info.configure(text=f"Posición muestra: {count_m1}-{count_m2}-{count_m3}")
        self.root.update()

    def btnHOME(self):
        global btnHOME_is_on, homeflag, count_m1, count_m2, count_m3
        btnDIR.config(text = "Ascendente")
        if btnHOME_is_on:
            pos.config(text = "Estado actual: Colocando en posición incial...")
            btnHOME_is_on = False
            print("btn HOME on")
            env_serial(3)
            info.configure(text=f"Posición muestra: {count_m1}-{count_m2}-{count_m3}")
            homeflag=True
        else:
            pos.config(text = "Estado actual: Inicio ")
            btnHOME_is_on = True
            print("btn HOME off")
            env_serial(0)
            homeflag=False

    def switchDIR(self):
        global DIR_is_on, dirflag
        if DIR_is_on:
            btnDIR.config(text = "Descendente") #elimnino dir_on
            DIR_is_on = False
            print("Movimiento descendente")
            env_serial(128)
            env_serial(0)
            dirflag= False
        else:
            btnDIR.config(text = "Ascendente")
            DIR_is_on = True
            print("Movimiento ascendente")
            env_serial(128)
            env_serial(0)
            dirflag= True

    def switchM1(self):
        global M1_is_on
        global count_m1
        if homeflag==False:
            if M1_is_on:
                btnM1.config(text = off)
                M1_is_on = False
                print("Motor1 on")
                env_serial(129)
                env_serial(0)
            else:
                btnM1.config(text = on)
                M1_is_on = True
                print("Motor1 off")
                env_serial(129)
                env_serial(0)
        else:
            btnM1.config(text = on)
            M1_is_on = False
            print("Motor1 pulsado")
            env_serial(129)
            env_serial(0)
            if dirflag == True:
                count_m1 = count_m1 + 1
            elif dirflag == False:
                if count_m1 == 0:
                    count_m1 = count_m1
                else:
                    count_m1 = count_m1 - 1
            pos.config(text = "Estado actual: Ajuste pre-autoenfoque")
            info.configure(text=f"Posición muestra: {count_m1}-{count_m2}-{count_m3}")
            self.root.update()

    def switchM2(self):
        global M2_is_on
        global count_m2
        if homeflag==False:
            if M2_is_on:
                btnM2.config(text = off)
                M2_is_on = False
                print("Motor2 on")
                env_serial(130)
                env_serial(255)
            else:
                btnM2.config(text = on)
                M2_is_on = True
                print("Motor2 off")
                env_serial(130)
                env_serial(255)
        else:
            btnM2.config(text = on)
            M2_is_on = False
            print("Motor2 pulsado")
            env_serial(130)
            env_serial(255)
            if dirflag == True:
                count_m2 = count_m2 + 1
            elif dirflag == False:
                if count_m2 == 0:
                    count_m2 = count_m2
                else:
                    count_m2 = count_m2 - 1
            pos.config(text = "Estado actual: Ajuste pre-autoenfoque")
            info.configure(text=f"Posición muestra: {count_m1}-{count_m2}-{count_m3}")
            self.root.update()

    def switchM3(self):
        global M3_is_on
        global count_m3
        if homeflag==False:
            if M3_is_on:
                btnM3.config(text = off)
                M3_is_on = False
                print("Motor3 on")
                env_serial(131)
                env_serial(255)
            else:
                btnM3.config(text = on)
                M3_is_on = True
                print("Motor3 off")
                env_serial(131)
                env_serial(255)
        else:
            btnM3.config(text = on)
            M3_is_on = False
            print("Motor2 pulsado")
            env_serial(131)
            env_serial(255)
            if dirflag == True:
                count_m3 = count_m3 + 1
            elif dirflag == False:
                if count_m3 == 0:
                    count_m3 = count_m3
                else:
                    count_m3 = count_m3 - 1
            pos.config(text = "Estado actual: Ajuste pre-autoenfoque")
            info.configure(text=f"Posición muestra: {count_m1}-{count_m2}-{count_m3}")
            self.root.update()

    def switchM(self):
        global M_is_on, M1_is_on, M2_is_on, M3_is_on
        global count_m1, count_m2, count_m3
        if homeflag==False:
            if M_is_on:
                btnM.config(text = off)
                btnM1.config(text = off)
                btnM2.config(text = off)
                btnM3.config(text = off)
                M_is_on = False
                M1_is_on = False
                M2_is_on = False
                M3_is_on = False
                print("All Motor on")
                env_serial(132)
                env_serial(255)
            else:
                btnM.config(text = on)
                btnM1.config(text = on)
                btnM2.config(text = on)
                btnM3.config(text = on)
                M_is_on = True
                M1_is_on = True
                M2_is_on = True
                M3_is_on = True
                print("All Motor off")
                env_serial(132)
                env_serial(255)
        else:
            btnM.config(text = on)
            btnM1.config(text = on)
            btnM2.config(text = on)
            btnM3.config(text = on)
            M_is_on = False
            M1_is_on = False
            M2_is_on = False
            M3_is_on = False
            print("All Motor on")
            env_serial(132)
            env_serial(255)
            if dirflag == True:
                count_m1 = count_m1 + 1
                count_m2 = count_m2 + 1
                count_m3 = count_m3 + 1
            elif dirflag == False:
                if count_m1 == 0:
                    count_m1 = count_m1
                else:
                    count_m1 = count_m1 - 1
                if count_m2 == 0:
                    count_m2 = count_m2
                else:
                    count_m2 = count_m2 - 1
                if count_m3 == 0:
                    count_m3 = count_m3
                else:
                    count_m3 = count_m3 - 1
            pos.config(text = "Estado actual: Ajuste pre-autoenfoque")
            info.configure(text=f"Posición muestra: {count_m1}-{count_m2}-{count_m3}")
            self.root.update()

    def autoenfoque(self):
        if homeflag==True:
            env_serial(5)
            env_serial(0)
            env_serial(133)
            env_serial(0)
            a=0
            #while a <3:
            self.save_img_autofocus() # como no detecto cuando la FGPA termina el mov del motor y manda la siguiente foto lo hago por "software"
            self.save_img_serie()
            print("-- IMANGEN ENFOCADA GUARDADA -- ")

    # ---------------------------INTERFAZ----------------------------------------------
    def createGUI(self):
        self.root = Tk()
        self.root.resizable(width=False, height=False)
        color_fondo="#FFFFFF"
        self.root['background']=color_fondo
        #self.root.geometry("900x500")

        self.M1_is_on = True
        self.M2_is_on = True
        self.M3_is_on = True
        self.DIR_is_on = True
        self.btnHOME_is_on = True


        # titulo de ventana - icono
        self.root.title('- FPGA - Step Motor Control')
        self.root.iconbitmap('C:\\Users\\carlo\\PycharmProjects\\pythonProject\\serial\\img\\logo.ico')
        global on, off, M1_is_on, btnM1, M2_is_on, btnM2, M3_is_on, btnM3, M_is_on, btnM, btnDIR, \
            DIR_is_on, cap, cap_is_on, pos, btnHOME_is_on, btnHOME_is_off, info, homeflag, dirflag #--------------------------

        dirflag= False
        homeflag = False
        M1_is_on = True
        M2_is_on = True
        M3_is_on = True
        M_is_on = True
        DIR_is_on = False
        btnHOME_is_on = True
        cap_is_on = False

        e_microscopio = "Estado actual: Inicio "
        on = " Activar "
        off = " Desactivar "

        pos = Label(self.root, text=e_microscopio, font=("Helvetica", 10), bg=color_fondo)
        pos.grid(row=0, column=2, sticky=NW, padx=10, pady=10, columnspan=4)

        info = Label(self.root, text="Posición muestra: %%-%%-%%", bg=color_fondo)
        info.grid(row=2, column=1, sticky=W, padx=10, pady=0, columnspan=2)
        index = 0

        precision = Label(self.root, text="Precisión:", bg=color_fondo)
        precision.grid(row=3, column=1, sticky=E, padx=10, pady=0)
        box(self.root)

#funcionalidades
        btn_home = Button(self.root, text="HOME",font=("Helvetica", 9),
                                 bg = None, command=lambda: self.btnHOME())
        btn_home.grid(row=1, column=2, sticky=E, padx=5, pady=10)

        btn_focus = Button(self.root, text = "AUTOENFOQUE",font=("Helvetica", 9),
                                 bg = None, command=lambda: self.autoenfoque())
        btn_focus.grid(row = 1, column = 3, sticky = W, padx=5, pady=10)

#Botones movimiento de muestra
        M1 = Label(self.root, text="Motor 1:",font=("Helvetica", 10), bg=color_fondo, fg=None)
        M1.grid(row=4, column=1, sticky=E, pady=2)
        btnM1 = Button(self.root, text = on, font=("Helvetica", 10), command=lambda: self.switchM1())
        btnM1.grid(row=4, column=2, sticky=W, pady=2)

        M2 = Label(self.root, text="Motor 2:",font=("Helvetica", 10), bg=color_fondo)
        M2.grid(row=5, column=1, sticky=E, pady=2)
        btnM2 = Button(self.root, text = on, font=("Helvetica", 10), command=lambda: self.switchM2())
        btnM2.grid(row=5, column=2, sticky=W, pady=2)

        M3 = Label(self.root, text="Motor 3:", font=("Helvetica", 10), bg=color_fondo)
        M3.grid(row=6, column=1, sticky=E, pady=2)
        btnM3 = Button(self.root, text = on, font=("Helvetica", 10), command=lambda: self.switchM3())
        btnM3.grid(row=6, column=2, sticky=W, pady=2)

        M = Label(self.root, text="Todos:", font=("Helvetica", 10), bg=color_fondo)
        M.grid(row=7, column=1, sticky=E, pady=4)
        btnM = Button(self.root, text = on, font=("Helvetica", 10), command=lambda: self.switchM())
        btnM.grid(row=7, column=2, sticky=W, pady=2)

        #Botones de ajuste

        btn_dir = Label(self.root, text="Dirección:", bg=color_fondo)
        btn_dir.grid(row=9, column=1, sticky=E, padx=10, pady=5)
        btnDIR = Button(self.root, text = "Descendente", font=("Helvetica", 10), command=lambda: self.switchDIR())
        btnDIR.grid(row=9, column=2, sticky=W, pady=2)

        cap = Button(self.root, text = "Capturar IMG", bg = None, command=lambda: self.captura_img_serie())
        cap.grid(row = 9, column = 3, sticky =E, padx=5, pady=5)

        recibir_img = Button(self.root, text = "Guardar IMG", bg = None, command=lambda: self.save_img_serie())
        recibir_img.grid(row = 9, column = 4, sticky =W, padx=5, pady=5)

#barra de progreso¿?
        version = Label(self.root, text="v1.4")
        version.grid(row=11, column=1, sticky=W, pady=2)

        img = PhotoImage(file = r"C:\Users\carlo\PycharmProjects\pythonProject\serial\img\delta.png")
        img1 = img.subsample(3, 3)
        Label(self.root, image = img1).grid(row = 2, column = 3, columnspan =2, rowspan = 7, padx = 5, pady = 5)

        # ---MENU ---
        menubar = Menu(self.root)
        filemenu = Menu(menubar, tearoff=0)
        filemenu.add_command(label="Instrucciones", command=self.instrucciones)
        filemenu.add_command(label="About", command=self.about)
        filemenu.add_command(label="Exit", command=self.root.quit)

        configmenu = Menu(menubar, tearoff=0)
        configmenu.add_command(label="Reset", command=self.reset)
        configmenu.add_command(label="Exit", command=self.root.quit)

        filemenu.add_separator()

        menubar.add_cascade(label="Menu", menu=filemenu)
        menubar.add_cascade(label="Configuración", menu=configmenu)


        # configuracion
        self.root.config(menu=menubar)  # background = '#1A1A1A')
        self.root.mainloop()

    # ---------------------------INFORMACIÓN-------------------------------------------
    def about(self):
        toplevel = tkinter.Toplevel(self.root)
        label0 = tkinter.Label(toplevel, text="\n Interfaz de control FPGA", font=("Helvetica", 9, "bold"))
        label0.grid(row=0, column=1, padx=1, sticky="s")

        label1 = ttk.Label(toplevel, text="\n    Esta trabajo forma parte del TFM realizado por Carlos Sánchez Cortés: "
                                          "\n                                           "
                                          "\n     SISTEMA DE AUTOENFOQUE MEDIANTE FPGA PARA MICROSCOPIO DE BAJO        "
                                          "\n     COSTE Y HARDWARE LIBRE CON POSICIONAMIENTO DE BISAGRAS FLEXIBLES     "
                                          "\n                                           "
                                          "\n    La interfaz permite el control del sistema de posicionamiento, la obtención   "
                                          "\n    de imágenes y autoenfoque desarrollado en FPGA.             "
                                          "\n                                                                          "
                                          "\n    Toda la información del proyecto se encuentra disponible en:          "
                                          "\n            https://github.com/URJCMakerGroup/Autofocus_Delta_Stage       "
                                          "\n    ")

        label1.grid(row=1, column=1, padx=1, sticky="s")
        close_btn = ttk.Button(toplevel, text="     ok     ", command=toplevel.destroy)
        close_btn.grid(row=2, column=1)
        label2 = ttk.Label(toplevel, text=" ")
        label2.grid(row=3, column=1, padx=1, sticky="s")
    def instrucciones(self):
        toplevel = tkinter.Toplevel(self.root)
        label0 = tkinter.Label(toplevel, text="\n Instrucciones de uso:", font=("Helvetica", 9, "bold"))
        label0.grid(row=0, column=1, padx=1, sticky="s")

        label1 = ttk.Label(toplevel, text="\n    La interfaz permite el control de los motores para el ajuste"
                                          "\n    de la muestra. "
                                          "\n                                           "
                                          "\n    ")

        label1.grid(row=1, column=1, padx=1, sticky="s")
        close_btn = ttk.Button(toplevel, text="     ok     ", command=toplevel.destroy)
        close_btn.grid(row=2, column=1)
        label2 = ttk.Label(toplevel, text=" ")
        label2.grid(row=3, column=1, padx=1, sticky="s")

#-------------------------------------------------------------------------
if __name__ == "__main__":
        app = microscopio()
        app.createGUI()
