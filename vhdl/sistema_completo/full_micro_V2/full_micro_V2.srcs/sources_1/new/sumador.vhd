----------------------------------------------------------------------------------
-- Engineer: Carlos Sanchez
-- Create Date: 23.05.2021 18:11:59
-- Design Name: Sumador
-- Module Name: comparador - Behavioral
-- Project Name: 
-- Description: 
--  El módulo sumador realiza la suma de los pixeles del buffer y lo guarda en 
-- memoria.
------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.ov7670_pkg.all;
use work.pkg_sum.all;

entity sumador is
    Port ( 
            rst  : in   std_logic;    
            clk  : in   std_logic;  
    -- para obtener el pixel:        
         sw_sum : in std_logic;-- btn que habilita el proceso de suma (captura)
        s_en_sum : out  std_logic;-- Señal para controlar el acceso al buffer
        s_comp : out  std_logic;-- Señal para controlar el acceso al buffer
       frame_pxl : in std_logic_vector (8-1 downto 0);-- Valor del pixel a sumar obtenido del buffer
        addr_pxl : out  std_logic_vector(c_nb_img_pxls-1 downto 0);-- Dirección del buffer de la cual leo el valor de frame_pxl
     --ram    
         wea_sum : out  std_logic;-- Señal para escribir en la RAM que almacena la suma
      test_pulso : out std_logic_vector(bram_addr downto 0);      
       addra_sum : out  std_logic_vector(bram_addr downto 0);-- Dirección de mememoria donde guardo el valor
       dina_sum  : out  std_logic_vector(bram_width downto 0);-- Valor de la suma de los frames de la imagen    
    -- suma total: 
--      maximo : std_logic_vector(bram_addr downto 0);
        sum_pxls : out std_logic_vector (bram_width downto 0);-- resultado completo de la suma  --25 no 16      
        led_bram : out std_logic       
    );
end sumador;

architecture Behavioral of sumador is
 -- sumador
  signal cuenta : unsigned(bram_width downto 0);
  signal cnt_pxl : unsigned(17-1 downto 0);
  signal cnt_pulso : unsigned(bram_addr downto 0);
  signal addr_ram_aux : unsigned(bram_addr downto 0);
  signal resultado: std_logic_vector (bram_width downto 0);
  signal receiving : std_logic;
  signal rst_sum : std_logic;
  signal en_sum : std_logic;
  signal sw_sum_aux : std_logic;
  signal wea_sum_aux : std_logic;
  -- detector de pulso
  signal pb_up_reg : std_logic;
  signal pb_up_reg2 : std_logic;
  signal pulso_sum : std_logic;
  
begin
    -- genera un pulso de la señal
    RegPB:Process(rst, Clk)
    begin
        if rst = '1' then
          pb_up_reg     <= '0';
          pb_up_reg2    <= '0';
        elsif Clk'event and Clk= '1' then
          pb_up_reg     <= sw_sum;
          pb_up_reg2    <= pb_up_reg;     
        end if;
    end process;    
    pulso_sum <= '1' when (pb_up_reg='1' and pb_up_reg2='0') else '0'; 
 
    -- cada vez que se activa el proceso de sumar los pixel cuento 1, dirección de memoria donde guardo el resultado
    cont_pulso : process(rst, clk)
        begin
            if rst='1' then
                cnt_pulso <= (others => '0'); 
            elsif clk' event and clk='1' then
                if pulso_sum = '1' then 
                   cnt_pulso <= cnt_pulso +1;                 
                end if;
            end if;
    end process;

    -- mantiene el módulo activo hasta que paso por todos los pixeles      
    bies_T_btn : process(rst, clk)
        begin
            if rst='1' then
                en_sum <='0';
            elsif clk' event and clk='1' then
                if pulso_sum = '1' then 
                   en_sum <= not en_sum;
                elsif cnt_pxl = c_fin_pxl then -- cuando llego al fin de cuenta de pixeles se desactiva
                   en_sum <= '0'; 
                elsif cnt_pulso > bram_num then -- si llego al final de la bram no se activa
                   en_sum <= '0';
                end if;    
            end if;
    end process;
    s_en_sum <= en_sum;
    
     -- contador de pixeles del frame buffer
    contador_pxl : process(rst, clk)
        begin
            if rst='1' then
                receiving <='0';
                cnt_pxl <= (others => '0');
            elsif clk' event and clk='1' then
                if en_sum = '1' then 
                   receiving <= '1';
                   cnt_pxl  <= cnt_pxl + 1;
                else
                   cnt_pxl <= (others => '0');  
                   receiving <= '0'; 
                end if;
            end if;
    end process;
    addr_pxl <= std_logic_vector(cnt_pxl);
    
    -- sumatorio de todos los pixeles  
    P_memoria: process(rst, clk)
    begin
      if rst = '1' then
         cuenta <= (others => '0');
      elsif clk'event and clk='1' then
          if en_sum = '1' then
              if receiving = '1'  then
                 cuenta  <= cuenta + ("00000000000000000" & unsigned(frame_pxl));
              elsif receiving = '0'  then 
                 cuenta <= (others => '0');   
              end if;  
          else  
             cuenta <= cuenta; 
          end if;
      end if;
    end process; 
    dina_sum <= std_logic_vector(cuenta);
    sum_pxls <= std_logic_vector(cuenta);
    
    -- guarda el resultado en una memoria ram
    write_in_ram : process(rst, clk)
     begin
      if rst='1' then
            wea_sum_aux <= '0';  
      elsif clk' event and clk='1' then
         if cnt_pxl = c_fin_pxl then 
            wea_sum_aux <= '1';
         else
            wea_sum_aux <= '0';   
         end if;
      end if;
    end process;
    wea_sum <= wea_sum_aux;
    s_comp <= wea_sum_aux;
--    dis_cap <= wea_sum_aux;
    
    direccion_bram: process(rst, clk)
     begin
      if rst='1' then
            addr_ram_aux   <= (others => '0');
      elsif clk' event and clk='1' then
         if wea_sum_aux = '1' then 
            addr_ram_aux   <= addr_ram_aux +1;
--         elsif rst_ram = '1' then 
--            addr_rom_aux   <= (others => '0');
         else
            addr_ram_aux   <= addr_ram_aux;
         end if;
      end if;
    end process;
--    maximo   <= std_logic_vector(addr_ram_aux);
    addra_sum   <= std_logic_vector(addr_ram_aux);
    test_pulso <= std_logic_vector(addr_ram_aux);
      
    led_bram <= '1' when (addr_ram_aux > bram_num-1) else '0';
end Behavioral;