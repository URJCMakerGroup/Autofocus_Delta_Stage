
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_top is
    generic (
      gFrecClk      : integer := 100000000;   --100MHz
      gBaud         : integer := 9600         --9600bps
    );
    port ( 
      rst     : in  std_logic;
      clk     : in  std_logic;
      sw_env  : in  std_logic;
      tx_data : out std_logic
    );
end uart_top;


architecture struct of uart_top is
  component uart_tx
  generic (
    gFrecClk      : integer := 100000000;   --100MHz
    gBaud         : integer := 9600       --9600bps --115200
  ); 
    Port(
      rst           : in std_logic;
      clk           : in std_logic;
      Transmite     : in std_logic;
      DatoTxIn      : in std_logic_vector(8-1 downto 0);          
      Transmitiendo : out std_logic;
      DatoSerieOut  : out std_logic
    );
  end component;

  component uart_interfaz
    Port (
      rst           : in  std_logic;
      clk           : in  std_logic;
      TxOcupado     : in  std_logic;
      frame_pxl     : in  std_logic_vector(8-1 downto 0);
      
      sw_env        : in  std_logic;
      Transmite     : out  std_logic;
      Caracter      : out  std_logic_vector(8-1 downto 0);
      frame_addr    : out std_logic_vector(14-1 downto 0)
    );
  end component;

  component rom8b_128_lenna is
  port (
      clk  : in  std_logic;   -- reloj
      addr : in  std_logic_vector(14-1 downto 0);
      dout : out std_logic_vector(8-1 downto 0) 
  );
 end component;
 
   signal Transmite     : std_logic;
   signal pxl_out      : std_logic_vector(8-1 downto 0);
   signal frame_addr    : std_logic_vector(14-1 downto 0);
   signal frame_pxl     : std_logic_vector(8-1 downto 0);
   signal Transmitiendo : std_logic;
 
 
begin

  
  tx: uart_tx
  Generic Map (
    gFrecClk      => gFrecClk,
    gBaud         => gBaud
  )
  Port Map (
    rst           => rst,
    Clk           => Clk,
    Transmite     => Transmite,
    DatoTxIn      => pxl_out,
    Transmitiendo => Transmitiendo,
    DatoSerieOut  => tx_data
  );
 
  interfaz: uart_interfaz
  Port Map (
    rst         => rst,
    clk         => clk,
    TxOcupado   => Transmitiendo,
    frame_pxl   => frame_pxl,
    sw_env      => sw_env, 
    Transmite   => Transmite,
    Caracter    => pxl_out,
    frame_addr  => frame_addr
  );
  
  img_lenna: rom8b_128_lenna
  Port Map (
    clk  => clk,
    addr => frame_addr,
    dout => frame_pxl
  );
  
end struct;

