----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.05.2021 09:19:43
-- Design Name: 
-- Module Name: ram_sum - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_sum is
   port (
      clk   : in  std_logic;
      wea   : in  std_logic;
      addra : in  std_logic_vector(7-1 downto 0);
      dina  : in  std_logic_vector(16-1 downto 0);
      
      addrb : in  std_logic_vector(7-1 downto 0);
      doutb : out std_logic_vector(16-1 downto 0)
   );
end ram_sum;

architecture behav of ram_sum is

  type ram_type is array (natural range<>) of std_logic_vector(16-1 downto 0);
  signal ram    : ram_type (0 to 100-1); 
  signal addra_us : unsigned (7-1 downto 0);-------cambiar guardo 100 resultados
  signal addrb_us : unsigned (7-1 downto 0);

begin

  -- For synthesis
  addra_us <= unsigned(addra); 
--  addrb_us <= unsigned(addrb); --------------
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
      doutb <= ram(to_integer(addrb_us));----------------
    end if;
  end process;

end behav;