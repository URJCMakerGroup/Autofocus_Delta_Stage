----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:30:48 12/08/2006 
-- Design Name: 
-- Module Name:    TOP_UART_TX - Estructural 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.std_logic_1164.ALL;
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP_UART_TX is
  generic (
    gFrecClk      : integer := 100000000;   --100MHz
    gBaud         : integer := 9600         --9600bps
  ); 
  Port (
    pb_up     : in  std_logic;
    pb_down   : in  std_logic;
    pb_left   : in  std_logic;
    pb_right  : in  std_logic;
    rst       : in  std_logic;
    clk       : in  std_logic;
    tx_data   : out  std_logic
  );
end TOP_UART_TX;

architecture Estructural of TOP_UART_TX is

  component UART_TX
  generic (
    gFrecClk      : integer := 100000000;   --100MHz
    gBaud         : integer := 921600         --9600bps
  ); 
    Port(
      rst           : in std_logic;
      Clk           : in std_logic;
      Transmite     : in std_logic;
      DatoTxIn      : in std_logic_vector(7 downto 0);          
      Transmitiendo : out std_logic;
      DatoSerieOut  : out std_logic
    );
  end component;

  component INTERFAZ_PB
    Port (
      rst           : in  std_logic;
      Clk           : in  std_logic;
      PB_UP         : in  std_logic;
      PB_DOWN       : in  std_logic;
      PB_LEFT       : in  std_logic;
      PB_RIGHT      : in  std_logic;
      TxOcupado     : in  std_logic;
      Transmite     : out  std_logic;
      Caracter      : out  std_logic_vector (7 downto 0)
    );
  end component;

  signal Transmitiendo   : std_logic;
  signal Transmite       : std_logic;
  signal DatoTxIn        : std_logic_vector (7 downto 0);

begin

  TX: UART_TX
  Generic Map (
    gFrecClk      => gFrecClk,
    gBaud         => gBaud
  )
  Port Map (
    rst           => rst,
    Clk           => Clk,
    Transmite     => Transmite,
    DatoTxIn      => DatoTxIn,
    Transmitiendo => Transmitiendo,
    DatoSerieOut  => TX_DATA
  );
 
  INTERFAZ: INTERFAZ_PB
  Port Map (
    rst         => rst,
    Clk         => Clk,
    PB_UP       => PB_UP,
    PB_DOWN     => PB_DOWN,
    PB_LEFT     => PB_LEFT,
    PB_RIGHT    => PB_RIGHT,
    TxOcupado   => Transmitiendo,
    Transmite   => Transmite,
    Caracter    => DatoTxIn
  );
    
end Estructural;

