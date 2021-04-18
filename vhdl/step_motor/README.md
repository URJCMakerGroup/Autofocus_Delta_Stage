# Stepper motor
Para el diseño se ha utilizado el motor paso a paso **28BYJ-48**.
- **Stepper_motor_simple:** código básico para comprobar el funcionamiento de los componentes.
- **Stepper_motor_endstop:** código para el control de un motor con un final de carrera incorporado.
- **Stepper_motor_endstop_x3:** código para el control de los tres motores y sus finales de carrera.
- **Stepper_motor_contador:** código con dos sistemas de movimmientos, de forma continua o que se detenga al realizar una revolución.
- **Stepper_motor_v1:** versión completa del sistema de movimiento. Los motores se controlan con los pulsadores y se dispone de dos sistema de funcionamiento: de forma continua o que al pulsar el motor realice una revolución completa.
---
Se han realizado dos versiones del código en función del driver que se utilice:
## - Driver [ULN2003A]:
![La imagen no se ha cargado correctamente](https://github.com/sanchezco/TFM_Autofocus_Delta_Stage/blob/main/schemes/Esquema%20conexion%20ULN2003A%20%20.png)
## - Driver [L293D]:
![La imagen no se ha cargado correctamente](https://github.com/sanchezco/TFM_Autofocus_Delta_Stage/blob/main/schemes/Esquema%20conexion%20L293D.png)

