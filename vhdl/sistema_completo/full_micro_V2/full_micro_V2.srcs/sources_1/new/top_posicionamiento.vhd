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
   s_inic_cam: out std_logic;
   s_uart: in std_logic;
        dir: in std_logic; 
       
     sw_ref: in std_logic;
   sw_enfoque: in std_logic;
--    led_dir: out std_logic;
   
        led_e: out std_logic_vector(5 downto 0); 
           
    btn_motor_a: in std_logic;
  -- motor 1:
     motor1: in std_logic;  
   endstop1: in std_logic;
--     led_m1: out std_logic;
       int1: out std_logic_vector(3 downto 0);
--   led_pos1: out std_logic;
  -- motor 2:
     motor2: in std_logic;  
   endstop2: in std_logic;
--     led_m2: out std_logic;
       int2: out std_logic_vector(3 downto 0);
--   led_pos2: out std_logic;
  -- motor 3:
     motor3: in std_logic;  
   endstop3: in std_logic;
--     led_m3: out std_logic;
       int3: out std_logic_vector(3 downto 0);
--   led_pos3: out std_logic;
  -- display     
--        an: out std_logic_vector(7 downto 0);
--       seg: out std_logic_vector(6 downto 0);
maximo : in STD_LOGIC_VECTOR (bram_addr downto 0);
       
       
   c_rev_relativo: out std_logic_vector(4-1 downto 0);
   c_rev_abs_m3: out std_logic_vector(4-1 downto 0);
   c_rev_abs_m2: out std_logic_vector(4-1 downto 0);
   c_rev_abs_m1: out std_logic_vector(4-1 downto 0)
 );
end top_posicionamiento;
-------------------------------------------------------------
architecture Behavioral of top_posicionamiento is
 component control is
  Port ( 
          clk: in std_logic;
          rst: in std_logic; 
   s_inic_cam: out std_logic;
       s_uart: in std_logic;
       
        led_e: out std_logic_vector(5 downto 0); 
          
        sw_ref: in std_logic;
   sw_enfoque: in std_logic;
        
          dir: in std_logic;
        s_dir: out std_logic;
--      led_dir: out std_logic;
        
    btn_motor_a: in std_logic;
        
    btn_motor3: in std_logic;
    endstop_m3: in std_logic;
      s_motor3: out std_logic;
    lim_sup_m3: out std_logic;
--        led_m3: out std_logic;
--      led_pos3: out std_logic;
 s_funciona_m3: in std_logic;
        
    btn_motor2: in std_logic;
    endstop_m2: in std_logic;
      s_motor2: out std_logic;
    lim_sup_m2: out std_logic;
--        led_m2: out std_logic;
--      led_pos2: out std_logic;
 s_funciona_m2: in std_logic;
        
    btn_motor1: in std_logic;
    endstop_m1: in std_logic;
      s_motor1: out std_logic;
    lim_sup_m1: out std_logic;
--        led_m1: out std_logic;
--      led_pos1: out std_logic;
 s_funciona_m1: in std_logic;
maximo : in STD_LOGIC_VECTOR (bram_addr downto 0);
       
  c_rev_relativo: out std_logic_vector(4-1 downto 0);
  c_rev_abs_m3: out std_logic_vector(4-1 downto 0);
  c_rev_abs_m2: out std_logic_vector(4-1 downto 0);
  c_rev_abs_m1: out std_logic_vector(4-1 downto 0)
    );
   end component;
   
 component stepper_motor is
   Port ( 
          clk: in std_logic;
          rst: in std_logic; 
       enable: in std_logic; 
          dir: in std_logic; 
      endstop: in std_logic; 
      lim_sup: in std_logic;
   s_funciona: out std_logic; 
          int: out std_logic_vector(3 downto 0)
   );
   end component;
   
--  component disp7seg is
--    port (
--          rst: in  std_logic;
--          clk: in  std_logic;
--      en_disp: in  std_logic_vector(7 downto 0);
--         num0: in  std_logic_vector(3 downto 0);
--         num1: in  std_logic_vector(3 downto 0);
--         num2: in  std_logic_vector(3 downto 0);
--         num3: in  std_logic_vector(3 downto 0);
--         num4: in  std_logic_vector(3 downto 0);
--         num5: in  std_logic_vector(3 downto 0);
--         num6: in  std_logic_vector(3 downto 0);
--         num7: in  std_logic_vector(3 downto 0);
--          seg: out std_logic_vector(6 downto 0);
--        anode: out std_logic_vector(7 downto 0)
--     );
--  end component;

---------------------------------------------------------------
    
   signal s_motor1 : std_logic;
   signal lim_sup_m1 : std_logic;
   signal s_funciona_m1 : std_logic;
   
   signal s_motor2 : std_logic;
   signal lim_sup_m2 : std_logic;
   signal s_funciona_m2 : std_logic;
   
   signal s_motor3 : std_logic;
   signal lim_sup_m3 : std_logic;
   signal s_funciona_m3 : std_logic;
   
   signal s_dir : std_logic;
   signal endstop_aux : std_logic;
   
   
   --display
--   signal en_seg7_disp : std_logic_vector(7 downto 0);
--   signal seg7_num0 : std_logic_vector(3 downto 0);
--   signal seg7_num1 : std_logic_vector(3 downto 0);
--   signal seg7_num2 : std_logic_vector(3 downto 0);
--   signal seg7_num3 : std_logic_vector(3 downto 0);
--   signal seg7_num4 : std_logic_vector(3 downto 0);
--   signal seg7_num5 : std_logic_vector(3 downto 0);
--   signal seg7_num6 : std_logic_vector(3 downto 0);
--   signal seg7_num7 : std_logic_vector(3 downto 0);
---------------------------------------------------------------
begin

control_posicion: control 
  port map(
               rst => rst,
               clk => clk,
               s_inic_cam => s_inic_cam,
               s_uart => s_uart,
               
               maximo => maximo,
               
             led_e => led_e,
            sw_ref => sw_ref,
        sw_enfoque => sw_enfoque,
               dir => dir,
             s_dir => s_dir,
--           led_dir => led_dir,
           
        btn_motor_a => btn_motor_a,
           
        btn_motor3 => motor3,
        endstop_m3 => endstop3,
        lim_sup_m3 => lim_sup_m3,
          s_motor3 => s_motor3,
--            led_m3 => led_m3,
--          led_pos3 => led_pos3,
        s_funciona_m3 => s_funciona_m3,
           
        btn_motor2 => motor2,
        endstop_m2 => endstop2,
        lim_sup_m2 => lim_sup_m2,
          s_motor2 => s_motor2,
--            led_m2 => led_m2,
--          led_pos2 => led_pos2,
        s_funciona_m2 => s_funciona_m2,
           
        btn_motor1 => motor1,
        endstop_m1 => endstop1,
        lim_sup_m1 => lim_sup_m1,
          s_motor1 => s_motor1,
--            led_m1 => led_m1,
--          led_pos1 => led_pos1,
        s_funciona_m1 => s_funciona_m1,
            
        c_rev_relativo => c_rev_relativo,
        c_rev_abs_m3 => c_rev_abs_m3,
        c_rev_abs_m2 => c_rev_abs_m2,
        c_rev_abs_m1 => c_rev_abs_m1
  );
  
step_motor_r: stepper_motor 
  port map(
            rst => rst,
            clk => clk,
            dir => s_dir,
         enable => s_motor1,
        endstop => endstop1,
        lim_sup => lim_sup_m1,
     s_funciona => s_funciona_m1,
            int => int1
  );
  
    
step_motor_c: stepper_motor 
  port map(
            rst => rst,
            clk => clk,
            dir => s_dir,
         enable => s_motor2,
        endstop => endstop2,
        lim_sup => lim_sup_m2,
     s_funciona => s_funciona_m2,
            int => int2
  );
  
 step_motor_l: stepper_motor 
  port map(
            rst => rst,
            clk => clk,
            dir => s_dir,
         enable => s_motor3,
        endstop => endstop3,
        lim_sup => lim_sup_m3,
     s_funciona => s_funciona_m3,
            int => int3
  ); 
--   seg7_num0 <= (others => '0');
--   seg7_num1 <= (others => '0');
--   seg7_num2 <= (others => '0'); 
--   seg7_num3 <= (others => '0'); 
--   seg7_num4 <= c_rev_relativo(3 downto 0);
--   seg7_num5 <= c_rev_abs_m1(3 downto 0);
--   seg7_num6 <= c_rev_abs_m2(3 downto 0);
--   seg7_num7 <= c_rev_abs_m3(3 downto 0);
--   en_seg7_disp <= "11111111";
   
--  display: disp7seg
--    port map (
--            rst => rst,
--            clk => clk,
--        en_disp => en_seg7_disp,
--           num0 => seg7_num0,
--           num1 => seg7_num1,
--           num2 => seg7_num2,
--           num3 => seg7_num3,
--           num4 => seg7_num4,
--           num5 => seg7_num5,
--           num6 => seg7_num6,
--           num7 => seg7_num7,
--            seg => seg,
--          anode => an
--     );

end Behavioral;
