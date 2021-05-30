----------------------------------------------------------------------------------
-- Engineer: Carlos Sánchez Cortés
-- https://github.com/sanchezco/TFM_Autofocus_Delta_Stage
-- Create Date: 18.03.2021 
-- Module Name: disp7_seg
-- Description: 
-- Description: 
--        Display de 7segmentos, se puede optimizar ya que el pto apenas se usa
--        (puedo reducirlo un bit)
--==============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity disp_7seg is
    Port ( 
           clk : in  STD_LOGIC;
           rst: in  STD_LOGIC;
           dir: in  STD_LOGIC;
           
           seg : out  STD_LOGIC_VECTOR (7 downto 0);
           an : out  STD_LOGIC_VECTOR (7 downto 0)
    );
           
end disp_7seg;

architecture Behavioral of disp_7seg is  
    constant cimilis: natural:= 100000;
    signal mili: natural range 0 to 2**17-1;
    signal s1mili: std_logic;
    signal cuenta4ms: unsigned (3 downto 0);
    signal s1decimas: std_logic;   
    signal dir0: std_logic_vector (7 downto 0);
    signal dir1: std_logic_vector (7 downto 0);

begin

  P_mili: process (rst,clk)
  begin
      if rst = '1' then
          mili <= 0;
      elsif clk'event and clk = '1' then
          if mili = cimilis-1 then
              mili <= 0;
          else
              mili <= mili + 1;
          end if;
      end if;
 end process;
 
 s1mili <= '1' when mili = cimilis-1 else '0';
 
  p_cuenta4ms: process (rst, clk)
  begin
     if rst = '1' then
         cuenta4ms <= (others => '0');
     elsif clk' event and clk = '1' then 
         if s1mili = '1' then
             if cuenta4ms = 6 then 
                 cuenta4ms <= (others => '0');
             else
                 cuenta4ms <= cuenta4ms +1 ;
             end if;
         end if;
    end if;
  end process;
  
an <= "11111110" when cuenta4ms="000" else
      "11111101" when cuenta4ms="001" else
      "11111011" when cuenta4ms="010" else
      "11110111" when cuenta4ms="011" else
      "11101111" when cuenta4ms="100" else
      "11011111" when cuenta4ms="101" else
      "10111111" when cuenta4ms="110" else
      "01111111";--when cuenta4ms= "111";
    
dir0 <= "00001100" when dir = '0' else
        "00100011";
dir1 <= "11000001" when dir = '0' else
        "10100001";
           
          
seg(7 downto 0) <=  dir0 when cuenta4ms= "000" else 
                    dir1 when cuenta4ms= "001" else 
                    "11111111" when cuenta4ms= "010" else 
                    "11111111" when cuenta4ms= "011" else 
                    "11111111" when cuenta4ms= "100" else 
                    "11111111" when cuenta4ms= "101" else 
                    "11111111" when cuenta4ms= "110" else 
                    "11111111";-- when cuenta4ms= "111";     
end Behavioral;
