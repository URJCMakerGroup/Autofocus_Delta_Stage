library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tb is
end uart_tb;

architecture tb of uart_tb is

component uart_top is
  generic (
    gFrecClk      : integer := 100000000;   --100MHz
    gBaud         : integer := 9600         --9600bps
  ); 
  Port (
    rst     : in  std_logic;
    clk     : in  std_logic;
    sw_env    : in  std_logic;
    
    tx_data : out  std_logic
  );
end component;
   --banco de pruebas
  signal rst_tb     : std_logic;
  signal clk_tb     : std_logic;
  signal sw_env_tb  : std_logic;
  signal tx_data_tb : std_logic;
  
begin
  UnidadEnPruebas: uart_top
    Port Map (
    -- puertos componente => senales del banco de pruebas
        clk     => clk_tb,
        rst     => rst_tb,
        sw_env  => sw_env_tb,
        tx_data => tx_data_tb
    );

Reloj: Process
begin
  clk_tb <='1';
  wait for 5ns;
  clk_tb <='0';
  wait for 5ns;
end process;

Estimulos: Process
begin 
     rst_tb <= '0';
  wait for 100 ns;
     rst_tb <= '1';
  wait for 100 ns;
     rst_tb <= '0';
     sw_env_tb <= '0';
  wait for 50 ns;
     sw_env_tb <= '1';
  wait for 50 ns;
     sw_env_tb <= '0';
  wait; 
end process;

end tb;
