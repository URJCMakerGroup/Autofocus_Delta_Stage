----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.06.2021 19:07:03
-- Design Name: 
-- Module Name: top_posicionamiento - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.ov7670_pkg.all;
use work.osc_pkg.all;
use work.pkg_sum.all;


entity top_posicionamiento is
 Port ( 
        clk: in std_logic;
        rst: in std_logic;
        
        dir: in std_logic; 
 s_e_ajuste: out std_logic;
 
s_funciona_m1: out std_logic; 
       motor1: in std_logic;  
     endstop1: in std_logic;
         int1: out std_logic_vector(3 downto 0);
       
s_funciona_m2: out std_logic; 
      motor2: in std_logic;  
     endstop2: in std_logic;
         int2: out std_logic_vector(3 downto 0);
        
s_funciona_m3: out std_logic; 
       motor3: in std_logic;  
     endstop3: in std_logic;
         int3: out std_logic_vector(3 downto 0)
 );
end top_posicionamiento;
-------------------------------------------------------------
architecture Behavioral of top_posicionamiento is
  
    
   signal s_motor1 : std_logic;
   signal lim_sup_m1 : std_logic;
   signal s_funciona_m1_aux : std_logic;
   
   signal s_motor2 : std_logic;
   signal lim_sup_m2 : std_logic;
   
   signal s_motor3 : std_logic;
   signal lim_sup_m3 : std_logic;
                 
   
begin

--control_posicion: entity work.control 
--  port map(
--               clk => clk,
--               rst => rst,
--               dir => dir,
--             s_dir => s_dir,
--        btn_motor1 => motor1,
--     --   endstop_m1 => endstop1,
--          s_motor1 => s_motor1,
--     s_funciona_m1 => s_funciona_m1_aux
--  );
  
s_e_ajuste<= '1' when (endstop1 = '0' and endstop2 = '0' and endstop3 = '0' and dir = '0') else '0'; 

 
step_motor_1: entity work.stepper_motor 
  port map(
               rst => rst,
               clk => clk,
               dir => dir,
            enable => motor1,--s_motor1,
           endstop => endstop1,
        s_funciona => s_funciona_m1,
               int => int1
  ); 
    
step_motor_2: entity work.stepper_motor 
  port map(
               rst => rst,
               clk => clk,
               dir => dir,
            enable => motor2,
           endstop => endstop2,
        s_funciona => s_funciona_m2,
               int => int2
  );   
step_motor_3: entity work.stepper_motor 
  port map(
               rst => rst,
               clk => clk,
               dir => dir,
            enable => motor3,
           endstop => endstop3,
        s_funciona => s_funciona_m3,
               int => int3
  ); 
    
end Behavioral;
