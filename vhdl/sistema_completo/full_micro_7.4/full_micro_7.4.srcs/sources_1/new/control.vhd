----------------------------------------------------------------------------------
-- Engineer: Carlos Sanchez
-- Create Date: 16.01.2021 
-- Module Name: stepper_motor
-- Project Name: TFM
-- Description: 
--        Modulo principal que controla los motores y sus diferentes movimientos según
--         la maquina de estados diseñada


-- Contador de posicion limitado a 16, 4 bits porque no puedo ver mas en el display de 7 seg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.ov7670_pkg.all;
use work.osc_pkg.all;
use work.pkg_sum.all;

entity control is
  Port ( 
          clk: in std_logic;
          rst: in std_logic;
    btn_motor1: in std_logic;
 --   endstop_m1: in std_logic;
 --     s_motor1: out std_logic;
--    lim_sup_m1: out std_logic; --led
-- s_funciona_m1: in std_logic;
      
          dir: in std_logic -- sw que modifica la dirección de ajuste '0'-ARRIBA  '1'- ABAJO
    --    s_dir: out std_logic; -- señal que modifica la direccion del motor 
    );
end control;

architecture Behavioral of control is
    signal  reg1_m1: std_logic;
    signal  reg2_m1: std_logic;
    signal pulso_m1: std_logic;
    signal cuenta_step_m1: natural range 0 to 2**12-1;
    signal s_fin_step_m1: std_logic;
    signal c_rev_abs_aux_m1: unsigned( 4-1 downto 0);
    signal  reg1_p1: std_logic;
    signal  reg2_p1: std_logic;
    signal pulso_p1: std_logic;
    signal s_m1_aux: std_logic;
   -- 
    signal  reg1_a: std_logic;
    signal  reg2_a: std_logic;
    signal pulso_a: std_logic;
   --
    signal  dir_aux: std_logic;
    signal  endstop: std_logic;
    constant fin_cuenta_step: natural := 2048;--1536; --1000000
    
    --Defino maquina de estados:
    type sist_posicion is ( inicio );--, referencia, ajuste, autoenfoque, pos_max, env_img);
    signal estado_actual, estado_siguiente: sist_posicion;
    --
    signal c_enfoq: natural range 0 to 2**12-1;
--    constant fin_c_enfoq: natural := 16;
    signal s_fin_c_enfoq: std_logic;
    --
--    constant pos_maximo: natural := 3;----------será la variable del comparador
    signal s_fin_c_maximo: std_logic;
    signal cuenta_rev_aux: unsigned( 4-1 downto 0);
    signal fin_cnt_rev: std_logic; 
    signal pulso_p: std_logic; 
         
begin
--Detector_pulso: process(rst, clk)
--    begin
--        if rst='1' then
--            reg1_m1 <='0';
--            reg2_m1 <='0';
--            reg1_p1 <='0';
--            reg2_p1 <='0';
--        elsif clk' event and clk='1' then  
--            reg1_m1 <= btn_motor1;
--            reg2_m1 <= reg1_m1;
--            reg1_p1 <= s_fin_step_m1;
--            reg2_p1 <= reg1_p1;
--        end if;
--    end process;
--  pulso_m1 <='1' when (reg1_m1 = '1' and reg2_m1 ='0');
      
-- Guarda el valor del btn para mantener activo el motor 1   
bies_T_btn_m1 : process(rst, clk)
    begin
        if rst='1' then
            s_m1_aux <='0';
        elsif clk' event and clk='1' then
            if btn_motor1 = '1' then 
                s_m1_aux <= not s_m1_aux;
            else
                s_m1_aux <= s_m1_aux;
            end if;
      end if;
    end process;      

 
-- Señal al realizar una revolución completa del motor 1
cnt_steps_m1: process(rst, clk)
    begin
        if rst='1' then
            cuenta_step_m1 <= 0;
        elsif clk' event and clk='1' then
            if s_funciona_m1 = '1' and endstop = '0' then
                 if cuenta_step_m1 = fin_cuenta_step-1 then
                    cuenta_step_m1 <= 0;
                 else
                    cuenta_step_m1 <= cuenta_step_m1 +1;
                end if;
           end if;
      end if;
    end process;   
 s_fin_step_m1 <= '1' when (cuenta_step_m1 = fin_cuenta_step-1) else '0'; --maximo 40
 
 endstop <= '1' when endstop_m1 = '1' else '0'; --and endstop_m2 = '0' and endstop_m3 = '0' else '1'; -- 
 
-- Maquina estados-------------------------------------------------------
P_cambio_estado: Process (estado_actual)--, sw_ref, sw_enfoque, s_fin_c_maximo, s_fin_c_enfoq, endstop)
begin
    case estado_actual is 
   ----------------------------------
   -- cambia al pulsar el sw_referencia, que me lleva a la posición del endstop
        when inicio =>  --if estado actual =autoenfoque
               estado_siguiente <= inicio;       
    end case;
end process;

P_comb_salidas: Process (estado_actual, dir, s_m1_aux)--, s_m2_aux, s_m3_aux)
begin
       case estado_actual is
         ------------------------------
         when inicio => 
              dir_aux <= dir;
             s_motor1 <= s_m1_aux;

        end case;
end process;

 s_dir <= dir_aux;
 led_dir <= dir_aux;
 
p_secuencia: Process (rst, clk)
begin
  if rst='1' then
    estado_actual <= inicio;
  elsif clk'event and clk= '1' then
    estado_actual <= estado_siguiente;
  end if;
end process;    

end Behavioral;
