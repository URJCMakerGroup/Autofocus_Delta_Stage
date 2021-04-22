----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:33:19 12/08/2006 
-- Design Name: 
-- Module Name:    INTERFAZ_PB - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity INTERFAZ_PB is
    Port ( PB_UP : in  STD_LOGIC;
           PB_DOWN : in  STD_LOGIC;
           PB_LEFT : in  STD_LOGIC;
           PB_RIGHT : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           TxOcupado : in  STD_LOGIC;
           Transmite : out  STD_LOGIC;
           Caracter : out  STD_LOGIC_VECTOR (7 downto 0));
end INTERFAZ_PB;

architecture Behavioral of INTERFAZ_PB is

  signal   PB_UP_Reg      : std_logic;
  signal   PB_UP_Reg2     : std_logic;
  signal   PB_DOWN_Reg    : std_logic;
  signal   PB_DOWN_Reg2   : std_logic;
  signal   PB_LEFT_Reg    : std_logic;
  signal   PB_LEFT_Reg2   : std_logic;
  signal   PB_RIGHT_Reg   : std_logic;
  signal   PB_RIGHT_Reg2  : std_logic;
  signal   PulsoUp    : std_logic;
  signal   PulsoDown  : std_logic;
  signal   PulsoLeft  : std_logic;
  signal   PulsRight : std_logic;
  constant PB_ON  : std_logic := '1';
  constant PB_OFF : std_logic := '0';

begin

  RegPB:Process(rst, Clk)
  begin
    if rst = '1' then
      PB_UP_Reg     <= '0';
      PB_UP_Reg2    <= '0';
      PB_DOWN_Reg   <= '0';
      PB_DOWN_Reg2  <= '0';
      PB_LEFT_Reg   <= '0';
      PB_LEFT_Reg2  <= '0';
      PB_RIGHT_Reg  <= '0';
      PB_RIGHT_Reg2 <= '0';
    elsif Clk'event and Clk= '1' then
      PB_UP_Reg     <= PB_UP;
      PB_UP_Reg2    <= PB_UP_Reg;
      PB_DOWN_Reg   <= PB_DOWN;
      PB_DOWN_Reg2  <= PB_DOWN_Reg;
      PB_LEFT_Reg   <= PB_LEFT;
      PB_LEFT_Reg2  <= PB_LEFT_Reg;
      PB_RIGHT_Reg  <= PB_RIGHT;
      PB_RIGHT_Reg2 <= PB_RIGHT_REG;
    end if;
  end process;
      
  PulsoUp <= '1' when (PB_UP_Reg=PB_ON and PB_UP_Reg2=PB_OFF) else
                 '0';
  PulsoDown <= '1' when (PB_DOWN_Reg=PB_ON and PB_DOWN_Reg2=PB_OFF) else
                   '0';
  PulsoLeft <= '1' when (PB_LEFT_Reg=PB_ON and PB_LEFT_Reg2=PB_OFF) else
                   '0';
  PulsRight <= '1' when (PB_RIGHT_Reg=PB_ON and PB_RIGHT_Reg2=PB_OFF) else
                    '0';

  Interfaz:Process(rst, Clk)
  begin
    if rst = '1' then
      Caracter <= (others=>'0');
      Transmite <= '0';
    elsif Clk'event and Clk='1' then
      Transmite <= '0';
      Caracter <= x"00";     -- ascci: Caracter nulo ;
      if TxOcupado = '0' then  -- No esta transmitiendo el transmisor
        if PulsoLeft = '1' then
          Transmite <= '1';
          Caracter <= x"68";   -- ascci: h ; la x es hexadecimal
        elsif PulsoUp = '1' then
          Transmite <= '1';
          Caracter <= x"6F";   -- ascci: o ;
        elsif PulsRight = '1' then
          Transmite <= '1';
          Caracter <= x"6C";   -- ascci: l ;
        elsif PulsoDown = '1' then
          Transmite <= '1';
          Caracter <= x"61";   -- ascci: a ;
        end if;
      end if;
    end if;
  end process;

end Behavioral;

