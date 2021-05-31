----------------------------------------------------------------------------------
-- Engineer: Carlos Sanchez
-- Create Date: 23.05.2021 18:11:59
-- Design Name: Sumador
-- Module Name: comparador - Behavioral
-- Project Name: 
-- Description: 
--  Genera la señal para mantener bloqueada la ram del buffer y mantener la imagen e
-- inicia el proceso para sumar, comparar, enviar la imagen, y mover el motor
------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity captura is
  Port ( 
          sw_cap : in std_logic;  -- inicia el módulo
         dis_cap : in std_logic;  -- detiene el módulo
           s_sum : out std_logic; -- señal que habilita el sumador
       s_captura : out std_logic; -- señal que limita el acceso al buffer para capturar la imagen
       
             rst : in std_logic;    
             clk : in std_logic
  );
end captura;

architecture Behavioral of captura is
 -- detector de pulso
  signal pb_up_reg : std_logic;
  signal pb_up_reg2 : std_logic;
  signal pulso_cap : std_logic;
  signal cap_reg : std_logic;
  signal cap_reg2 : std_logic;
  signal pulso_dis_cap : std_logic;
  signal en_captura : std_logic;
  
begin
    -- detector de pulso de btn
    RegPB:Process(rst, Clk)
    begin
        if rst = '1' then
          pb_up_reg  <= '0';
          pb_up_reg2 <= '0';
          cap_reg    <= '0';
          cap_reg2 <= '0';
        elsif Clk'event and Clk= '1' then
          pb_up_reg <= sw_cap;
          pb_up_reg2  <= pb_up_reg;   
          cap_reg   <= dis_cap;
          cap_reg2  <= cap_reg;     
        end if;
    end process;    
    pulso_cap <= '1' when (pb_up_reg='1' and pb_up_reg2='0') else '0'; 
    pulso_dis_cap <= '1' when (cap_reg='1' and cap_reg2='0') else '0'; 
    
    bies_T_btn : process(rst, clk)
        begin
        if rst='1' then
            en_captura <='0';
        elsif clk' event and clk='1' then
            if pulso_cap = '1' then 
                 en_captura <= '1';
            elsif pulso_dis_cap = '1' then 
                    en_captura <= '0';
            else
                 en_captura <= en_captura;
--               en_captura <= not en_captura;
--            elsif cnt_pulso > bram_sum_num then
--               en_captura <= '0';
            end if;
        end if;
    end process;
    s_captura <= en_captura;
    s_sum <= en_captura;
    
end Behavioral;
