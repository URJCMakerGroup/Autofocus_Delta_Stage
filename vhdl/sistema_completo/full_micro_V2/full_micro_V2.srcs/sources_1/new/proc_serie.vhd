library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity proc_serie is
  port (
    rst        : in  std_logic;
    clk        : in  std_logic;
    dat_ready  : in  std_logic;
    uart_data  : in  std_logic_vector(8-1 downto 0);
    
    fin_manda_img  : in  std_logic;
    s_cap_img  : out  std_logic;
    s_manda_img  : out  std_logic
  );
end proc_serie;

architecture behav of proc_serie is
       
    --Defino maquina de estados:
    type estados_micro is ( inicio, i_imagen, i_captura, i_manda );--i_mover1b, i_mover2b,
    --Se?ales de los procesos
    signal estado_actual, estado_siguiente: estados_micro;
--    
    signal uart_data_aux   : std_logic_vector(8-1 downto 0);
    signal instruccion   : std_logic_vector(8-1 downto 0);
  
    signal  reg1_cap: std_logic;
    signal  reg2_cap: std_logic;
    signal  pulso_cap: std_logic;
  
    signal  s_aux: std_logic;
    signal  s_cap_rx: std_logic;

begin


P_cambio_estado: Process (estado_actual, dat_ready, uart_data, instruccion, fin_manda_img )
begin
    case estado_actual is 
   ----------------------------------
        when inicio => 
            if instruccion(7)='0' then
                estado_siguiente <= i_imagen;
            else 
                estado_siguiente <= inicio;
            end if;
   -----------------------------------             
           when i_imagen => 
            if instruccion(1 downto 0)="01" then           
               estado_siguiente <= i_manda;        
            elsif instruccion(1 downto 0)="10" then   
               estado_siguiente <= i_captura;
            else
                estado_siguiente <= i_imagen;
            end if; 
    -----------------------------------           
           when i_manda => 
            if fin_manda_img = '1' then 
                estado_siguiente <= inicio;
            else
                estado_siguiente <= i_manda;
            end if;        
    -----------------------------------           
           when i_captura => 
            if instruccion(1 downto 0)="00" then
                estado_siguiente <= inicio;
            else
                estado_siguiente <= i_captura;
            end if;     
    -----------------------------------   
    end case;
end process;

p_secuencia: Process (rst, clk)
begin
  if rst='1' then
    estado_actual <= inicio;
  elsif clk'event and clk= '1' then
    estado_actual <= estado_siguiente;

  end if;
  
end process;

P_comb_salidas: Process (estado_actual)
-- Los dos primeros bits corresponden a la primera bobina del motor
-- y los dos siguientes a la segunda.
begin
    s_cap_img <= '0';
   s_manda_img <= '0';
    
       case estado_actual is
         ------------------------------
         when inicio => 
            s_cap_img <= '0';
            s_manda_img <= '0';
         ------------------------------             
         when i_imagen => 
            s_cap_img <= '0';
            s_manda_img <= '0';
         ------------------------------             
         when i_manda =>
            s_cap_img <= '1';
            s_manda_img <= '1';
         -------------------------------             
         when i_captura=> 
            s_cap_img <= '1';
            s_manda_img <= '0';
         ------------------------------- 
        end case;
end process;

----aqui comienza todo
  p_instrucciones: process(rst, clk)
  begin
    if rst = '1' then
      instruccion <= (others => '0');
    elsif clk'event and clk='1' then
      if dat_ready = '1' then
        instruccion <= uart_data;
      end if;
    end if;
  end process;

      
end behav;


