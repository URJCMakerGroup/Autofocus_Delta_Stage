----------------------------------------------------------------------------------
-- Engineer: Carlos Sanchez
-- Create Date: 23.05.2021 18:11:59
-- Design Name: Sumador
-- Module Name: comparador - Behavioral
-- Project Name: 
-- Description: 
--  El módulo TOP_SUM suma todos los pixeles del buffer y realiza la comparación de 
-- los mismos indicando la direccion del buffer con mayor valor.
------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.ov7670_pkg.all;
use work.pkg_sum.all;

entity top_autoenfoque is
    Port ( 
            rst  : in std_logic;  
            clk  : in std_logic;
            
          en_cap : in STD_LOGIC;-- BTN que habilita el proceso de captura, suma, compara y mueve motor
        s_env_af : out STD_LOGIC;-- BTN que habilita el proceso de captura, suma, compara y mueve motor
       
        led_bram : out std_logic; -- led que indica si la memoria esta llena
        s_en_sum : out std_logic;-- Señal para controlar el acceso al buffer
        addr_pxl : out std_logic_vector(c_nb_img_pxls-1 downto 0); -- Direccion del buffer de la cual leo el valor de frame_pxl
       frame_pxl : in STD_LOGIC_VECTOR (8-1 downto 0); -- Valor del pixel a sumar obtenido del buffer
        
    ram_reseteada : out std_logic;
    s_reset_ram   : in std_logic;
        
        -- display
        sum_pxls : out STD_LOGIC_VECTOR (bram_width downto 0);-- resultado completo de la suma de pixeles
      test_pulso : out std_logic_vector(bram_addr downto 0); -- muestra en el display el numero de imagenes obtenidas
       addr_max : out STD_LOGIC_VECTOR (bram_addr downto 0) -- muestra la direccion con el valor maximo
    );
end top_autoenfoque;

architecture struc of top_autoenfoque is

  signal addr_aux : std_logic_vector (14-1 downto 0);
  signal dout_aux : std_logic_vector (8-1 downto 0);
  signal wea_sum_aux : std_logic;
  signal s_sum_aux : std_logic;
  signal inic_comp_aux : std_logic;
--  signal dis_cap : std_logic;
  signal addra_sum_aux : std_logic_vector(bram_addr downto 0);
  signal dina_sum_aux : std_logic_vector(bram_width downto 0);
  signal addr_comp_aux :  std_logic_vector(bram_addr downto 0);
  signal dout_comp_aux : std_logic_vector(bram_width downto 0);
  
begin
      
sum: entity work.sumador_pxl
  Port Map (
               clk => clk,
               rst => rst,
          led_bram => led_bram,
          inic_sum => en_cap,
          s_en_sum => s_en_sum,
         inic_comp => inic_comp_aux,
         frame_pxl => frame_pxl,
          addr_pxl => addr_pxl,
           
     ram_reseteada => ram_reseteada,
       s_reset_ram => s_reset_ram,
           
           wea_sum => wea_sum_aux,
        test_pulso => test_pulso,
         addra_sum => addra_sum_aux,
          dina_sum => dina_sum_aux,
          sum_pxls => sum_pxls
  );
  
ram_resultados : entity work.ram_result
  Port Map (
               clk => clk,
               wea => wea_sum_aux,
             addra => addra_sum_aux,
              dina => dina_sum_aux,
             addrb => addr_comp_aux,
             doutb => dout_comp_aux
  );

    
comp_resultados: entity work.comparador_sum
  Port Map (
               clk => clk,
               rst => rst,
             s_env_af => s_env_af,
         inic_comp => inic_comp_aux,
         addr_comp => addr_comp_aux,
          addr_max => addr_max,
           dato_in => dout_comp_aux
  );
end struc;