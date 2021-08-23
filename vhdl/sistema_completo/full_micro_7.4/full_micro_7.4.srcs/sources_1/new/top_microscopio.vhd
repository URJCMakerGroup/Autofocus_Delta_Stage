----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.07.2021 13:02:50
-- Design Name: 
-- Module Name: top_microscopio - Behavioral
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

entity top_microscopio is
    Port ( 
    rst : in std_logic; 
    clk : in std_logic;
    
--uart
    uart_rx : in std_logic;
    uart_tx_data : out std_logic;
    led_estado : out std_logic_vector(3-1 downto 0); -- indica en que estado se encuentra la FPGA
    
--ov7670
    sw0_test_cmd : in std_logic; --if '1', step by step SCCB instructions
    sw13_regs : in std_logic_vector(2 downto 0); --choose regs sccb
    sw57_rgbfilter: in std_logic_vector(2 downto 0); --rgbfilter
    sw4_test_osc : in std_logic; --if '1' show oscilloscope

    btnr_test : in std_logic; --if sw='1', SCCB sent one by one
    btnl_oscop : in std_logic; --restart capture oscilloscope(after trig    
    btnc_resend : in std_logic;

    ov7670_sioc : out std_logic;
    ov7670_siod : out std_logic;
    ov7670_rst_n : out std_logic;
    ov7670_pwdn : out std_logic;
    ov7670_vsync : in std_logic;
    ov7670_href : in std_logic;
    ov7670_pclk : in std_logic;
    ov7670_xclk : out std_logic;
    ov7670_d : in std_logic_vector(7 downto 0);

    vga_red : out std_logic_vector(3 downto 0);
    vga_green : out std_logic_vector(3 downto 0);
    vga_blue : out std_logic_vector(3 downto 0);
    vga_hsync : out std_logic;
    vga_vsync : out std_logic;
    
    led : out std_logic_vector(7 downto 0);
    anode7seg : out std_logic_vector(7 downto 0);
    seg7 : out std_logic_vector(6 downto 0);

--m1
   endstop1: in std_logic;
   endstop2: in std_logic;
   endstop3: in std_logic;
   
   s_e_ajuste: out std_logic;
   led_endstop1: out std_logic;
   
   
   led_bram: out std_logic;
   
   led_dir : out std_logic;
   int1    : out std_logic_vector(3 downto 0);  
   int2    : out std_logic_vector(3 downto 0);  
   int3    : out std_logic_vector(3 downto 0)      

  );
end top_microscopio;

architecture Behavioral of top_microscopio is
--uart_rx
    signal i_cap_img   : std_logic; --señal para capturar la img
    signal i_manda_img : std_logic;
    signal instruccion : std_logic_vector(8-1 downto 0); --inst del pc leida
--uart_tx
    signal env_pxl           : std_logic; --señal para mandar la img, leída del la instrucción
    signal fin_manda_img_aux : std_logic; --señal fin del estado "mandar imagen"
    signal s_env_img         : std_logic;
    signal frame_pxl_aux     : std_logic_vector(8-1 downto 0);
    signal frame_addr        : std_logic_vector(c_nb_img_pxls-1 downto 0);
-- ov7670
    signal env_img : std_logic; 
--motores
    signal i_dir : std_logic; 
    signal i_sobel : std_logic_vector(2-1 downto 0); 
    signal i_motor_m1 : std_logic;
    signal i_motor_m2 : std_logic;
    signal i_motor_m3 : std_logic;
    signal i_motor_a  : std_logic;
    
    signal s_funciona_m1  : std_logic;
    signal s_funciona_m2  : std_logic;
    signal s_funciona_m3  : std_logic;
    
    signal sw57_rgbfilter_aux : std_logic_vector(3-1 downto 0); 
    
    signal s_e_ajuste_aux : std_logic; 
    signal c_rev_abs_m1 : std_logic_vector(4-1 downto 0); 
    signal c_rev_abs_m2 : std_logic_vector(4-1 downto 0); 
    signal c_rev_abs_m3 : std_logic_vector(4-1 downto 0);  
                                      
   signal s_en_sum : std_logic;       
   signal inic_sum : std_logic;      
   signal s_env_af_aux : std_logic; 
   signal frame_addr_sum : std_logic_vector(c_nb_img_pxls-1 downto 0);
   signal pxl_sum_aux  : std_logic_vector(25-1 downto 0);------------------------------------------------bram_sum_wide-----------------------------------
   signal test_pulso : std_logic_vector(4-1 downto 0);---------------------------------------------------bram_sum_addr--------------------------------
   signal addr_max_aux : STD_LOGIC_VECTOR (4-1 downto 0);-----------------------------------------------bram_sum_addr
    
begin
led_endstop1 <= i_cap_img;

s_e_ajuste <= s_e_ajuste_aux;
m_uart_rx : entity work.top_uart_rx
  Port map(
               clk => clk,
               rst => rst,
           uart_rx => uart_rx,
        led_estado => led_estado,
        s_e_ajuste => s_e_ajuste_aux,
        
        i_motor_m1 => i_motor_m1,
        i_motor_m2 => i_motor_m2,
        i_motor_m3 => i_motor_m3,
             i_dir => i_dir,
             
     s_funciona_m1 => s_funciona_m1,
     s_funciona_m2 => s_funciona_m2,
     s_funciona_m3 => s_funciona_m3,
             
      c_rev_abs_m1 => c_rev_abs_m1,
      c_rev_abs_m2 => c_rev_abs_m2,
      c_rev_abs_m3 => c_rev_abs_m3,
      
          s_env_af => s_env_af_aux,
        pos_maximo => addr_max_aux,
             
     fin_manda_img => fin_manda_img_aux,
       i_manda_img => i_manda_img,
          inic_sum => inic_sum,
         i_cap_img => i_cap_img --señal para capturar la img, leído de la instruccion
  ); 

m_uart_tx : entity work.top_uart_tx
  Port map(
               clk => clk,
               rst => rst,
         frame_pxl => frame_pxl_aux,
        frame_addr => frame_addr,
           env_pxl => env_pxl,
     fin_manda_img => fin_manda_img_aux,
         s_env_img => i_manda_img,
         
         
          s_env_af => s_env_af_aux,
         
      DatoSerieOut => uart_tx_data
  ); 
  
 led_dir <= i_dir;
---------------------------------------------------------------------------------
--  s_env_img <= '1' when i_manda_img='1' else '0'; --sw_env = '1' or
-----------------------------------------------------------------------------------

m_top_ov7670 : entity work.top_ov7670
  Port map(
               clk => clk,
               rst => rst,
    
      sw0_test_cmd => sw0_test_cmd,
      sw4_test_osc => sw4_test_osc,
         sw13_regs => sw13_regs,
    sw57_rgbfilter => sw57_rgbfilter,
         btnr_test => btnr_test,
        btnl_oscop => btnl_oscop,
    
       ov7670_sioc => ov7670_sioc,
       ov7670_siod => ov7670_siod,
      ov7670_rst_n => ov7670_rst_n,
       ov7670_pwdn => ov7670_pwdn,
      ov7670_vsync => ov7670_vsync,
       ov7670_href => ov7670_href,
       ov7670_pclk => ov7670_pclk,
       ov7670_xclk => ov7670_xclk,
          ov7670_d => ov7670_d,
    
               led => led,
           vga_red => vga_red,
         vga_green => vga_green,
          vga_blue => vga_blue,
         vga_hsync => vga_hsync,
         vga_vsync => vga_vsync,
         anode7seg => anode7seg,
              seg7 => seg7,
       btnc_resend => btnc_resend,
                  
      c_rev_abs_m1 => c_rev_abs_m1,
      c_rev_abs_m2 => c_rev_abs_m2,
      c_rev_abs_m3 => c_rev_abs_m3,
      
      
          s_en_sum => s_en_sum,
    frame_addr_sum => frame_addr_sum,
        test_pulso => test_pulso,
       pxl_sum_aux => pxl_sum_aux,
      addr_max_aux => addr_max_aux,
            
         i_cap_img => i_cap_img,
         frame_pxl => frame_pxl_aux,
           env_pxl => env_pxl,
   frame_addr_uart => frame_addr
  ); 
  
m_posicionamiento : entity work.top_posicionamiento
  Port map(
               clk => clk,
               rst => rst,
        s_e_ajuste => s_e_ajuste_aux,
                       
               dir => i_dir,
            motor1 => i_motor_m1,
          endstop1 => endstop1,
              int1 => int1,
     s_funciona_m1 => s_funciona_m1,
            
            motor2 => i_motor_m2,
          endstop2 => endstop2,
              int2 => int2,
     s_funciona_m2 => s_funciona_m2,
              
     s_funciona_m3 => s_funciona_m3,
            motor3 => i_motor_m3,
          endstop3 => endstop3,
              int3 => int3
  );   
  
m_autoenfoque : entity work.top_autoenfoque
  Port map(
               clk => clk,
               rst => rst,
            en_cap => inic_sum, -- habilita la suma
             s_env_af => s_env_af_aux,
--             s_env => s_env_aux,
--           dis_cap => dis_cap_aux,
--    s_captura => s_captura,
          led_bram => led_bram,
          s_en_sum => s_en_sum, --habilita la lectura de frame de pixles procesados
          addr_pxl => frame_addr_sum, -- direccion memoria donde obtengo el pixel
         frame_pxl => frame_pxl_aux, -- valor leido del buffer
          sum_pxls => pxl_sum_aux, -- suma de pixeles procesados
        test_pulso => test_pulso,
          addr_max => addr_max_aux
  ); 
end Behavioral;
