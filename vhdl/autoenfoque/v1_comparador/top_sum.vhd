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

entity top_sum is
    Port ( 
            rst  : in std_logic;  
            clk  : in std_logic;
            
          sw_cap : in STD_LOGIC;-- BTN que habilita el proceso de captura, suma, compara y mueve motor
           s_env : out STD_LOGIC; --señal que activa la interfaz de la uart para mandar la imagen capturada
         dis_cap : in STD_LOGIC; -- señal que deshabilita la captura de imagen  
       s_captura : out std_logic; -- señal que limita el acceso al buffer para capturar la imagen--
       
       led_bram  : out std_logic; -- led que indica si la memoria esta llena
        s_en_sum : out std_logic;-- Señal para controlar el acceso al buffer
        addr_pxl : out std_logic_vector(c_nb_img_pxls-1 downto 0); -- Direccion del buffer de la cual leo el valor de frame_pxl
       frame_pxl : in STD_LOGIC_VECTOR (8-1 downto 0); -- Valor del pixel a sumar obtenido del buffer
        -- display
        sum_pxls : out STD_LOGIC_VECTOR (bram_width downto 0);-- resultado completo de la suma de pixeles
      test_pulso : out std_logic_vector(bram_addr downto 0); -- muestra en el display el numero de imagenes obtenidas
       addr_max : out STD_LOGIC_VECTOR (bram_addr downto 0) -- muestra la direccion con el valor maximo
    );
end top_sum;

architecture Behavioral of top_sum is
  component captura
    Port (  
            rst  : in std_logic;    
            clk  : in std_logic;
         dis_cap : in STD_LOGIC;
         sw_cap  : in std_logic; 
         s_sum  : out std_logic;   
       s_captura : out std_logic 
  );
  end component;
  
  component sumador
    Port ( 
    -- entradas:
            rst  : in   std_logic;    
            clk  : in   std_logic; 
        led_bram : out std_logic;
--         dis_cap : out STD_LOGIC;
          sw_sum : in STD_LOGIC;-- habilita el proceso de suma
          s_en_sum : out  std_logic;-- Señal para controlar el acceso al buffer 
            s_comp : out  std_logic;
    --            
        addr_pxl : out  std_logic_vector(c_nb_img_pxls-1 downto 0);-- Direccion del buffer de la cual leo el valor de frame_pxl
       frame_pxl : in STD_LOGIC_VECTOR (8-1 downto 0);-- Valor del pixel a sumar obtenido del buffer
     --ram    
         wea_sum : out  std_logic;-- Señal para escribir en la RAM que almacena la suma
       addra_sum : out  std_logic_vector(bram_addr downto 0);-- Direccion de mememoria donde guardo el valor
       dina_sum  : out  std_logic_vector(bram_width downto 0);--cambiar a 16bits------------- Valor de la suma de los frames de la imagen 
    -- 
      test_pulso : out std_logic_vector(bram_addr downto 0);
        sum_pxls : out STD_LOGIC_VECTOR (bram_width downto 0)-- resultado completo de la suma
        );
  end component;
  
  component ram_resultados
   port (
      clk   : in  std_logic;
      wea   : in  std_logic;
      addra : in  std_logic_vector(bram_addr downto 0);
      dina  : in  std_logic_vector(bram_width downto 0);
      addrb : in  std_logic_vector(bram_addr downto 0);
      doutb : out std_logic_vector(bram_width downto 0)
   );
  end component;
  
   component comparador
    Port ( 
       clk : in STD_LOGIC;
       rst : in STD_LOGIC;
       s_comp : in STD_LOGIC;
       s_env : out STD_LOGIC;
       addr_comp : out STD_LOGIC_VECTOR (bram_addr downto 0);
       dato_in : in STD_LOGIC_VECTOR (bram_width downto 0);
       addr_max : out STD_LOGIC_VECTOR (bram_addr downto 0)   
   );
  end component;
  
  signal addr_aux : std_logic_vector (14-1 downto 0);
  signal dout_aux : std_logic_vector (8-1 downto 0);
  signal wea_sum_aux : std_logic;
  signal s_sum_aux : std_logic;
  signal s_comp_aux : std_logic;
--  signal dis_cap : std_logic;
  signal addra_sum_aux : std_logic_vector(bram_addr downto 0);
  signal dina_sum_aux : std_logic_vector(bram_width downto 0);
  signal addr_comp_aux :  std_logic_vector(bram_addr downto 0);
  signal dout_comp_aux : std_logic_vector(bram_width downto 0);
  
begin
  
  captura_img: captura
  Port Map (
    clk     => clk,
    rst     => rst,
    sw_cap  => sw_cap,
    dis_cap => dis_cap,
    s_sum   => s_sum_aux,
    s_captura   => s_captura
  );
  
  sum: sumador
  Port Map (
    rst     => rst,
    clk     => clk,
    led_bram => led_bram,
    sw_sum  => s_sum_aux,
    s_en_sum  => s_en_sum,
    s_comp   => s_comp_aux,
    frame_pxl => frame_pxl,
    addr_pxl    => addr_pxl,
    
    wea_sum   => wea_sum_aux,
    test_pulso => test_pulso,
    addra_sum   => addra_sum_aux,
    dina_sum   => dina_sum_aux,
    sum_pxls => sum_pxls
    );
  
  detect_max: comparador
  Port Map (
    clk => clk,
    rst => rst,
    s_env => s_env,
    s_comp => s_comp_aux,
    addr_comp => addr_comp_aux,
    addr_max => addr_max,
    dato_in  => dout_comp_aux
  );
  
  memo_ram: ram_resultados
  Port Map (
    clk   => clk,
    wea   => wea_sum_aux,
    addra => addra_sum_aux,
    dina  => dina_sum_aux,
    addrb   => addr_comp_aux,
    doutb  => dout_comp_aux
  );
    
    
end Behavioral;