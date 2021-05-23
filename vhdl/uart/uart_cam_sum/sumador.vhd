--Definicion:
--    El código realiza la suma de los píxeles de una ROM al pulsar un btn y lo muestra en el display de 7 segmentos en HEX

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.ov7670_pkg.all;

entity sumador is
    Port ( 
            rst  : in   std_logic;    
            clk  : in   std_logic;    
    -- para obtener el pixel:        
        s_en_sum : out  std_logic;                      -- Señal para controlar el acceso al buffer
       frame_pxl : in STD_LOGIC_VECTOR (8-1 downto 0);  -- Valor del pixel a sumar obtenido del buffer
        addr_pxl : out  std_logic_vector(c_nb_img_pxls-1 downto 0); -- Dirección del buffer de la cual leo el valor de frame_pxl

         sw_sum : in STD_LOGIC;                        -- BTN que habilita el proceso de suma
     --ram    
         wea_sum : out  std_logic;                      -- Señal para escribir en la RAM que almacena la suma
       addra_sum : out  std_logic_vector(7-1 downto 0); -- Dirección de mememoria donde guardo el valor
       dina_sum  : out  std_logic_vector(16-1 downto 0); --cambiar a 16bits------------- Valor de la suma de los frames de la imagen 
    
    -- suma total: 
        sum_pxls : out STD_LOGIC_VECTOR (16-1 downto 0); -- resultado completo de la suma  --25 no 16       
        -- no se utilizan addrb ni doutb
        addrb : out  std_logic_vector(7-1 downto 0);--------------------------cambiar
        doutb : in std_logic_vector(16-1 downto 0)
    );
end sumador;

architecture Behavioral of sumador is
 -- sumador
  signal cuenta : unsigned(25-1 downto 0);
  signal cnt_pxl : unsigned(17-1 downto 0);
  signal cnt_pulso : unsigned(7-1 downto 0);
  signal resultado: STD_LOGIC_VECTOR (25-1 downto 0);
  signal receiving : std_logic;
  constant fin_cuenta_pxl: natural := 76800-1;
  
  signal   rst_sum      : std_logic;
  
  -- detector de pulso
  signal   pb_up_reg   : std_logic;
  signal   pb_up_reg2  : std_logic;
  signal   pulso_up    : std_logic;
  signal   en_sum      : std_logic;
  
begin

    -- cada vez que se activa el proceso de sumar los pixel cuento 1, dirección de memoria donde guardo el resultado
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
    pulso_up <= '1' when (pb_up_reg='1' and pb_up_reg2='0') else '0'; 
    
    -- cada vez que se activa el proceso de sumar los pixel cuento 1, dirección de memoria donde guardo el resultado
    cont_pulso : process(rst, clk)
        begin
            if rst='1' then
                cnt_pulso <= "0000000"; --cambiar por cero y no restar
            elsif clk' event and clk='1' then
                if pulso_up = '1' then 
                   cnt_pulso <= cnt_pulso +1;                 
                end if;
            end if;
    end process;
    addra_sum <= std_logic_vector(cnt_pulso); 
    addrb <= std_logic_vector(cnt_pulso);  
    
    -- mantiene el módulo activo hasta que paso por todos los pixeles      
    bies_T_btn : process(rst, clk)
        begin
            if rst='1' then
                en_sum <='0';
            elsif clk' event and clk='1' then
                if pulso_up = '1' then 
                   en_sum <= not en_sum;
                elsif cnt_pxl = 76800-1 then
                   en_sum <= '0';                   
                end if;
            end if;
    end process;
    s_en_sum <= en_sum;
    
     -- contador de pixeles del frame 
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
          if receiving = '1' then
              if en_sum = '1' and pulso_up = '0' then
                 cuenta  <= cuenta + ("00000000000000000" & unsigned(frame_pxl));
              elsif en_sum = '0' and pulso_up = '1' then 
                 --cuenta <= cuenta; 
                 cuenta <= (others => '0');     
              else  
                 cuenta <= cuenta; 
              end if;
          end if;
      end if;
    end process; 
    resultado <= std_logic_vector(cuenta);
    dina_sum <= std_logic_vector("000" & resultado(24 downto 12));
--sum_pxls <= std_logic_vector(cuenta);   doutb; 
    sum_pxls <= std_logic_vector("000" & resultado(24 downto 12));
    
    -- guarda el resultado en una memoria ram
    write_in_ram : process(rst, clk)
     begin
      if rst='1' then
            wea_sum <= '0';  
      elsif clk' event and clk='1' then
         if cnt_pxl = 16383 then 
            wea_sum <= '1';
         else
            wea_sum <= '0';   
         end if;
      end if;
    end process;
  
    
            
     
end Behavioral;

