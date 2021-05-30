----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.05.2021 18:11:59
-- Design Name: 
-- Module Name: comparador - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pkg_sum.all;

entity comparador is
    Port ( 
        clk : in std_logic;
        rst : in std_logic;
        s_comp : in std_logic; --inicia el modulo para comparar
        dato_in : in std_logic_vector (bram_width downto 0); --resultado de la suma leido de la bram
        s_env : out std_logic; --señal que activa la interfaz de la uart para mandar la imagen capturada
        addr_comp : out std_logic_vector (bram_addr downto 0); --direccion de memoria de donde quiero obtener el resultado
        addr_max : out std_logic_vector (bram_addr downto 0) -- posición de la memoria con el valor máximo
      );
end comparador;

architecture Behavioral of comparador is
  -- detector de pulso
  signal   pb_up_reg   : std_logic;
  signal   pb_up_reg2  : std_logic;
  signal   pulso_up    : std_logic;
  --
  signal   en_comp    : std_logic;
  signal cnt_addr : unsigned(bram_addr downto 0); -- contador de pixeles
  signal pos : unsigned(bram_addr downto 0);
  signal fin_cnt_memo: std_logic;
  signal pos_max : unsigned(bram_addr downto 0);
  signal dato_max : std_logic_vector(bram_width downto 0);

begin

   -- detector de pulso de btn
    RegPB:Process(rst, Clk)
    begin
    if rst = '1' then
      pb_up_reg     <= '0';
      pb_up_reg2    <= '0';
    elsif Clk'event and Clk= '1' then
      pb_up_reg     <= s_comp;
      pb_up_reg2    <= pb_up_reg;     
    end if;
    end process;    
    pulso_up <= '1' when (pb_up_reg='1' and pb_up_reg2='0') else '0'; 
    
   -- mantiene el módulo activo hasta que paso por todos los pixeles
    bies_T_btn : process(rst, clk)
        begin
            if rst='1' then
                en_comp <='0';
            elsif clk' event and clk='1' then
                if pulso_up = '1' then 
                   en_comp <= not en_comp;
                elsif fin_cnt_memo = '1' then -- cnt_addr = bram_addr-1 then -- posiciones que comparo
                   en_comp <= '0';                   
                end if;
            end if;
    end process;
     fin_cnt_memo <= '1' when pos = bram_num-1 else '0';

  -- 
    contador_pxl : process(rst, clk)
        begin
            if rst='1' then
                cnt_addr <= (others => '0');
            elsif clk' event and clk='1' then
                if en_comp = '1' then 
                   cnt_addr  <= cnt_addr + 1;
                else
                   cnt_addr <= (others => '0');  
                end if;
            end if;
    end process;
    
   addr_comp <= std_logic_vector(cnt_addr) when (cnt_addr < bram_num-1)  else "0100"; 
   --NOTA: si sobrepaso las direcciones de la bram mantengo el valor, va un ciclo por detras del dato que comparo
   -- por lo tanto si tengo 9 en memoria, llega hasta 10 y daba error
   
   pos <= cnt_addr when (cnt_addr = 0) else (cnt_addr-1);
        
    -- sumatorio de todos los pixeles
    P_memoria: process(rst, clk)
    begin
      if rst = '1' then
         pos_max <= (others => '0');
         dato_max <= (others => '0');
      elsif clk'event and clk='1' then
       if en_comp = '1' then 
          if dato_max < dato_in  then
             dato_max <= dato_in;
             pos_max <= pos;
          else
             dato_max <= dato_max;
             pos_max <= pos_max;
          end if;
        end if;
      end if;
    end process; 
    
    addr_max <= std_logic_vector(pos_max);
    s_env <= s_comp;
    
end Behavioral;