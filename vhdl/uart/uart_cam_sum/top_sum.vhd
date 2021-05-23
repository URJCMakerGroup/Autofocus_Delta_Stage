----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.05.2021 20:36:57
-- Design Name: 
-- Module Name: top_sum - Behavioral
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
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

library work;
use work.ov7670_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_sum is
    Port ( 
            rst  : in std_logic;  
            clk  : in std_logic;
          sw_sum : in STD_LOGIC;-- BTN que habilita el proceso de suma
        s_en_sum : out std_logic;-- Se?al para controlar el acceso al buffer
  
       frame_pxl : in STD_LOGIC_VECTOR (8-1 downto 0); -- Valor del pixel a sumar obtenido del buffer
        addr_pxl : out std_logic_vector(c_nb_img_pxls-1 downto 0); -- Direcci?n del buffer de la cual leo el valor de frame_pxl
        sum_pxls : out STD_LOGIC_VECTOR (16-1 downto 0)-- resultado completo de la suma
    );
end top_sum;

architecture Behavioral of top_sum is
  component sumador
    Port ( 
    -- entradas:
            rst  : in   std_logic;    
            clk  : in   std_logic;    
       frame_pxl : in STD_LOGIC_VECTOR (8-1 downto 0);-- Valor del pixel a sumar obtenido del buffer
          sw_sum : in STD_LOGIC;-- BTN que habilita el proceso de suma
    -- salidas:
          s_en_sum : out  std_logic;-- Se?al para controlar el acceso al buffer
          --ram    
         wea_sum : out  std_logic;-- Se?al para escribir en la RAM que almacena la suma
       addra_sum : out  std_logic_vector(7-1 downto 0);-- Direcci?n de mememoria donde guardo el valor
       dina_sum  : out  std_logic_vector(16-1 downto 0);--cambiar a 16bits------------- Valor de la suma de los frames de la imagen 
    
        addr_pxl : out  std_logic_vector(c_nb_img_pxls-1 downto 0);-- Direcci?n del buffer de la cual leo el valor de frame_pxl
        sum_pxls : out STD_LOGIC_VECTOR (16-1 downto 0);-- resultado completo de la suma
        
        addrb : out  std_logic_vector(7-1 downto 0);--------------------------cambiar
        doutb : in std_logic_vector(16-1 downto 0)
    );
  end component;
  
  component ram_sum
   port (
      clk   : in  std_logic;
      wea   : in  std_logic;
      addra : in  std_logic_vector(7-1 downto 0);
      dina  : in  std_logic_vector(16-1 downto 0);
      addrb : in  std_logic_vector(7-1 downto 0);
      doutb : out std_logic_vector(16-1 downto 0)
   );
  end component;
  
  signal addr_aux : std_logic_vector (14-1 downto 0);
  signal dout_aux : std_logic_vector (8-1 downto 0);
  signal wea_sum_aux : std_logic;
  signal addra_sum_aux : std_logic_vector(7-1 downto 0);
  signal dina_sum_aux : std_logic_vector(16-1 downto 0);
  
  signal addrb_sum_aux : std_logic_vector(7-1 downto 0);
  signal doutb_sum_aux : std_logic_vector(16-1 downto 0);
  
begin

  sum: sumador
  Port Map (
    rst     => rst,
    clk     => clk,
    frame_pxl => frame_pxl,
    sw_sum  => sw_sum,
    s_en_sum  => s_en_sum,
        
    wea_sum   => wea_sum_aux,
    addra_sum   => addra_sum_aux,
    dina_sum   => dina_sum_aux,

    addr_pxl    => addr_pxl,
    sum_pxls => sum_pxls,
    
    addrb => addrb_sum_aux,
    doutb => doutb_sum_aux
  );
  
  memo_ram: ram_sum
  Port Map (
    clk   => clk,
    wea   => wea_sum_aux,
    addra => addra_sum_aux,
    dina  => dina_sum_aux,
    addrb   => addrb_sum_aux,
    doutb  => doutb_sum_aux
  );
    
end Behavioral;