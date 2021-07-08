library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_leds is
  port (
    rst        : in  std_logic;
    clk        : in  std_logic;
    dat_ready  : in  std_logic;
    uart_data  : in  std_logic_vector(8-1 downto 0);
    leds       : out std_logic_vector(8-1 downto 0)
  );
end uart_leds;

architecture behav of uart_leds is

begin

  p_leds: process(rst, clk)
  begin
    if rst = '1' then
      leds <= (others => '0');
    elsif clk'event and clk='1' then
      if dat_ready = '1' then
        leds <= uart_data;
      end if;
    end if;
  end process;

end behav;

