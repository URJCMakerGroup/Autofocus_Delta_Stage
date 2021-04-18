library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use ieee.numeric_std.all;

library work;
use work.ov7670_pkg.all;

--sw13_regs[0]
entity uart_interfaz is
    Port ( 
           rst       : in  std_logic;
           clk       : in  std_logic;
           TxOcupado : in  std_logic;
           frame_pxl : in  std_logic_vector(8-1 downto 0);
--           enable    : in std_logic;
           sw_env    : in  std_logic;
           
           led_img   : out  std_logic; 
           Transmite : out  std_logic;        
           Caracter  : out  std_logic_vector(8-1 downto 0);
           frame_addr: out  std_logic_vector(c_nb_img_pxls-1 downto 0)
           ); 
           
end uart_interfaz;

architecture Behavioral of uart_interfaz is

  signal   pb_up_reg     : std_logic;
  signal   pb_up_reg2    : std_logic;
  signal   pulso_up      : std_logic;
  
  signal   en_uart       : std_logic;
  
  signal   cuenta_pxl    : natural range 0 to 2**17-1;
  constant fin_cuenta_pxl: natural := 76800; --76800; --360x240----------------
  signal   fin_cont_pxl  : std_logic;  
  
  signal   aux_transmite : std_logic;
  signal   addr          : std_logic_vector(c_nb_img_pxls-1 downto 0);
  
begin

Transmite <= aux_transmite;
frame_addr <= addr;

RegPB:Process(rst, Clk)
begin
    if rst = '1' then
      pb_up_reg     <= '0';
      pb_up_reg2    <= '0';
    elsif Clk'event and Clk= '1' then
      pb_up_reg     <= sw_env;
      pb_up_reg2    <= pb_up_reg;     
    end if;
end process;    
pulso_up <= '1' when (pb_up_reg='1' and pb_up_reg2='0') else '0'; 

bies_T_btn : process(rst, clk)
    begin
        if rst='1' then
            en_uart <='0';
        elsif clk' event and clk='1' then
            if pulso_up = '1' then 
               en_uart <= not en_uart;
            elsif addr = fin_cuenta_pxl then     --           
               en_uart <= '0';                   --
            end if;
        end if;
end process;     

  
Interfaz:Process(rst, Clk)
  begin
    if rst = '1' then
      aux_transmite <= '0';
      Caracter <= (others=>'0');
      addr <= (others=>'0'); 
      
    elsif Clk'event and Clk='1' then
      aux_transmite <= '0';
      Caracter <= (others=>'0');   
        
      if TxOcupado = '0' then 
        if  en_uart = '1' then
            if  addr <= fin_cuenta_pxl then
                aux_transmite <= '1';
                Caracter <= frame_pxl; 
          
                if aux_transmite = '1' then --and fin_cont_pxl = '0' then 
                   addr <= addr + 1;       
                else
                   addr <= addr;
                end if; 
   
            else
                aux_transmite <= '0';
                Caracter <= (others=>'0');
            end if;
            
        else
            addr <= (others=>'0');         
        end if;  
              
      end if;
    end if;
  end process;
   
Transmite <= aux_transmite;
frame_addr <= addr;
led_img <= '1' when addr = fin_cuenta_pxl else '0';
 
end Behavioral;
