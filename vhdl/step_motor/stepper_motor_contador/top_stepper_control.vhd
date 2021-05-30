----------------------------------------------------------------------------------
-- Engineer: Carlos Sánchez Cortés
-- https://github.com/sanchezco/TFM_Autofocus_Delta_Stage
--
-- Create Date: 18.03.2021 
-- Module Name: top_stepper_control - Behavioral
-- Description: 
--   Control de movimiento para el microscopio DeltaStage. 
--      sw0: modifica el sentido del movimiento de los motores, mostrando en el display de 7 segmentos "UP" o "do"
--      btn_up: mueve los tres motores a la vez, haciendo que suba o baje la muestra.
--      btn_right: mueve el motor 1 
--      btn_left: mueve el motor 2 
--      btn_down: mueve el motor 3
--  Cuando el movimiento es descendente se han utilizado finales de carrera para evitar daños en el miscroscopio.
--------------------------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity top_stepper_control is
  Port ( 
       clk: in std_logic;
       rst: in std_logic; -- sw 15
   led_rst: out std_logic;
       
       dir: in std_logic; -- sw 1: ON - sentido horario; OFF - sent
   led_dir: out std_logic;
   
       sw_mod: in std_logic; 
      led_mod: out std_logic;
   
    
     en_all_motor: in std_logic;
    motor1: in std_logic;
    motor2: in std_logic;
    motor3: in std_logic;
   
  endstop1: in std_logic;
  endstop2: in std_logic;
  endstop3: in std_logic;
    
      int1: out std_logic_vector(3 downto 0); -- salidas para el motor1
      int2: out std_logic_vector(3 downto 0); -- salidas para el motor1
      int3: out std_logic_vector(3 downto 0); -- salidas para el motor1
        
    led_m1: out std_logic;
    led_m2: out std_logic;
    led_m3: out std_logic; 
    
       seg: out  STD_LOGIC_VECTOR (7 downto 0);
        an: out  STD_LOGIC_VECTOR (7 downto 0)
 );

end top_stepper_control;

architecture Behavioral of top_stepper_control is

   component stepper_motor is
   port(
       clk: in std_logic;
       sw_mod: in std_logic;
       rst: in std_logic; -- sw 15
     en_all_motor: in std_logic;
     en_motor: in std_logic;
       dir: in std_logic; -- sw 1: ON - sentido horario; OFF - sentido antihorario
   endstop: in std_logic;
    
       int: out std_logic_vector(3 downto 0); -- salidas para el motor
       
     led_m: out std_logic;
   led_dir: out std_logic;
   led_mod: out std_logic;
   led_rst: out std_logic
   );
   end component;
   
   component disp_7seg is
   port(
       clk: in std_logic;
       rst: in std_logic; -- sw 15
       dir: in std_logic;
       
       seg: out  STD_LOGIC_VECTOR (7 downto 0);
        an: out  STD_LOGIC_VECTOR (7 downto 0)
   );
   end component;

begin

step_motor_r: stepper_motor 
  port map(
    rst => rst,
    clk => clk,
    sw_mod => sw_mod,
    en_motor => motor1,
    en_all_motor => en_all_motor,
    dir => dir,
    endstop => endstop1,
    
    int => int1,
    led_m => led_m1,
    led_mod => led_mod,
    led_dir => led_dir,
    led_rst => led_rst
  );

step_motor_l: stepper_motor 
  port map(
    rst => rst,
    clk => clk,
    sw_mod => sw_mod,
    en_motor => motor2,
    en_all_motor => en_all_motor,
    dir => dir,
    endstop => endstop2,
    
    int => int2,
    led_m => led_m2,
    led_mod => led_mod,
    led_dir => led_dir,
    led_rst => led_rst
  );

step_motor_c: stepper_motor 
  port map(
    rst => rst,
    clk => clk,
    sw_mod => sw_mod,
    en_motor => motor3,
    en_all_motor => en_all_motor,
    dir => dir,
    endstop => endstop3,
    
    int => int3,
    led_m => led_m3,
    led_mod => led_mod,
    led_dir => led_dir,
    led_rst => led_rst
  );

 display7seg: disp_7seg
 port map(
    rst => rst,
    clk => clk,
    dir => dir,
    seg => seg,
    an => an
 );
 
end Behavioral;
