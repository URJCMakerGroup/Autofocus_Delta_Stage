library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.ov7670_pkg.all;

entity top_uart_tx is
  port (
    rst : in std_logic; 
    clk : in std_logic;
    
    frame_pxl : in std_logic_vector(8-1 downto 0);  
    s_env_af : in std_logic;
          
    env_pxl   : out std_logic;
    s_env_img : in std_logic;
    fin_manda_img : out std_logic;
    
    frame_addr   : out std_logic_vector(c_nb_img_pxls-1 downto 0);
    DatoSerieOut : out std_logic
  );
end top_uart_tx;

architecture struct of top_uart_tx is

   
  signal Transmitiendo : std_logic;
  signal Transmite : std_logic;
  signal DatoTxIn  : std_logic_vector (7 downto 0);  
  
begin 

i_uart_interfaz : entity work.uart_interfaz
  Port map(
               clk => clk,
               rst => rst,
         TxOcupado => Transmitiendo,
         frame_pxl => frame_pxl(8-1 downto 0),
         s_env_img => s_env_img,
     fin_manda_img => fin_manda_img, 
           env_pxl => env_pxl,
         Transmite => Transmite,    
          Caracter => DatoTxIn,
          
          s_env_af => s_env_af,
          
        frame_addr => frame_addr
  ); 
  
i_uart_tx : entity work.uart_tx_nopar
  generic map(
    gFrecClk => 100000000,   --100MHz
    gBaud => 115200       --9600bps 
  )
    Port map(
               clk => clk,
               rst => rst,
         Transmite => Transmite,
          DatoTxIn => DatoTxIn,         
     Transmitiendo => Transmitiendo,
     DatoSerieOut  => DatoSerieOut
 );


end struct;

