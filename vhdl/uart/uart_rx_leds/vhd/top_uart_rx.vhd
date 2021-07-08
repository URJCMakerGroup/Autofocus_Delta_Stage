library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_uart_rx is
  port (
    rst        : in  std_logic;
    clk        : in  std_logic;
    uart_rx    : in  std_logic;
    led       : out std_logic_vector(8-1 downto 0)
  );
end top_uart_rx;

architecture struct of top_uart_rx is

  signal uart_receiving : std_logic;
  signal uart_dat_ready : std_logic;
  signal uart_data      : std_logic_vector(8-1 downto 0);

begin

  i_uart_rx : entity work.uart_rx
    generic map (
      G_FREQ_CLK  => 10**8,
      G_BAUD => 115200
    )
    port map (
      rst       => rst,
      clk       => clk,
      uart_rx   => uart_rx,
      receiving => uart_receiving,
      dat_ready => uart_dat_ready,
      dat_o     => uart_data
    );

  i_leds: entity work.uart_leds
    port map (
      rst       => rst,
      clk       => clk,
      dat_ready => uart_dat_ready,
      uart_data => uart_data,
      leds      => led
    );

end struct;

