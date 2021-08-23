----------------------------------------------------------------------------------
-- Engineer: Carlos Sanchez
-- Create Date: 23.05.2021 18:11:59
-- Design Name: Sumador
-- Module Name: comparador - Behavioral
-- Project Name: 
-- Description: 
--  memoria ram de doble puerto donde se guardan los resultados de la suma
------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pkg_sum.all;

entity ram_result is
   port (
      clk   : in  std_logic;
      -- señales del sumador
      wea   : in  std_logic;
      addra : in  std_logic_vector(bram_addr downto 0);
      dina  : in  std_logic_vector(bram_width downto 0);
      -- señales del comparador
      addrb : in  std_logic_vector(bram_addr downto 0);
      doutb : out std_logic_vector(bram_width downto 0)
   );
end ram_result;

architecture behav of ram_result is

  type ram_type is array (natural range<>) of std_logic_vector(bram_width downto 0);
  signal ram    : ram_type (0 to bram_num-1); 
  signal addra_us : unsigned (bram_addr downto 0);
  signal addrb_us : unsigned (bram_addr downto 0);

begin

  -- For synthesis
  addra_us <= unsigned(addra); 
  addrb_us <= unsigned(addrb); --------------
  -- For simulation
--  addra_us <= unsigned(addra) when unsigned(addra) < c_img_pxls else 
--              (others => '0') ; 
--  addrb_us <= unsigned(addrb) when unsigned(addrb) < c_img_pxls else 
--              (others => '0') ; 

  P_porta: process(clk)
  begin
    if clk'event and clk='1' then
      if wea = '1' then
        ram(to_integer(addra_us)) <= dina;
      end if;
      doutb <= ram(to_integer(addrb_us));
    end if;
  end process;

end behav;