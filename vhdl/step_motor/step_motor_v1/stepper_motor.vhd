----------------------------------------------------------------------------------
-- Engineer: Carlos Sanchez
-- Create Date: 14.03.2021 
-- Module Name: stepper_motor - Behavioral
-- Project Name: TFM
-- Description: 
--        Control del motor paso a paso con un final de carrera normalmente cerrado.
--        El sw0 cambia el sentido.
--==============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;-- para poder utilizar signed y unsigned;

--==============================================================================
entity stepper_motor is
 Port ( 
       clk: in std_logic;
       rst: in std_logic; -- sw 15
     motor: in std_logic;
     all_m: in std_logic;
       dir: in std_logic; -- sw 1: ON - sentido horario
                          --      OFF - sentido antihorario 
   endstop: in std_logic;
    
       int: out std_logic_vector(3 downto 0); -- salidas para el motor
     led_m: out std_logic;
   led_dir: out std_logic;
   led_rst: out std_logic
 );
end stepper_motor;

--==============================================================================
architecture Behavioral of stepper_motor is
    -- Señales para obtener la señar de 100Hz
    signal cuenta: natural range 0 to 2**20-1;
    constant fin_cuenta: natural := 1000000; --1000000
    signal step: std_logic;  

    -----------ESTADOS --------------------------
    type estado_motor is ( AB, BC, CD, DA);
    --Señales de los procesos
    signal estado_actual, estado_siguiente: estado_motor;
    
    constant sw_on : std_logic := '1'; -- señales activas a nivel alto
    constant sw_off : std_logic := '0';
    
    --enable btn:
    signal reg_m1: std_logic;
    signal reg_m2: std_logic;
    signal pulso_m1: std_logic;
    signal s_m1: std_logic;
    signal enable_m1: std_logic;
    
    signal reg_a1: std_logic;
    signal reg_a2: std_logic;
    signal pulso_a: std_logic;
    signal s_a: std_logic;
    signal enable_a: std_logic;
    
    signal stop: std_logic;
    
--==============================================================================

begin

Detector_pulso: process(rst, clk)
    begin
        if rst='1' then
             reg_m1 <='0';
             reg_m2 <='0';
             reg_a1 <='0';
             reg_a2 <='0';
        elsif clk' event and clk='1' then
            reg_m1 <= motor;
            reg_m2 <= reg_m1;
            reg_a1 <= all_m;
            reg_a2 <= reg_a1;
        end if;
    end process;
    pulso_m1 <='1' when (reg_m1 = '1' and reg_m2 ='0') else '0';  
     pulso_a <='1' when (reg_a1 = '1' and reg_a2 ='0') else '0';
  
bies_T_btn1 : process(rst, clk, enable_a)
    begin
        if rst='1'  or enable_a = '1' then --cambio
            s_m1 <='0';
        elsif clk' event and clk='1' then
            if pulso_m1= '1' then
                s_m1 <= not s_m1;
            end if;
        end if;
    end process; 
    enable_m1 <= s_m1;
    
 bies_T_btn2 : process(rst, clk)
    begin
        if rst='1' then 
            s_a <='0';
        elsif clk' event and clk='1' then
            if pulso_a= '1' then
                s_a <= not s_a;
            end if;
        end if;
    end process; 
    enable_a <= s_a; 
  
 P_contador_100Hz: process(clk,rst)
    begin 
        if rst = '1' then
            cuenta <= 0;
        elsif clk'event and clk = '1' then
            if cuenta = fin_cuenta-1 then
               cuenta <= 0;
            else 
               cuenta <= cuenta + 1;
            end if;
        end if;
 end process;
   
 step <= '1' when (cuenta = fin_cuenta-1) else '0'; 
 led_m <= '1' when enable_m1 = '1' or enable_a = '1' else '0';
 led_dir <= '1' when dir = '1' else '0';    
 led_rst <= '1' when rst = '1' else '0'; 
 
 stop <= '1' when endstop = '1' and dir = '1' else '0';
 
P_cambio_estado: Process (estado_actual, enable_m1, enable_a, stop, dir, step)
begin
    case estado_actual is 
   --------------------------------
        when AB => 
            if step = '1' and stop = '0' and (enable_m1 = '1' or enable_a = '1')then 
                
                if dir = '1' then  
                   estado_siguiente <= BC;        
                elsif dir = '0' then
                   estado_siguiente <= DA;
                end if;   
                
            else -- step = '0'
                estado_siguiente <= AB;
            end if;
             
   ---------------------------------             
           when BC => 
            if step = '1' and stop = '0' and (enable_m1 = '1' or enable_a = '1')then 
                if dir = '1' then         
                   estado_siguiente <= CD;        
                elsif dir = '0' then   
                   estado_siguiente <= AB;
                end if;
            else
                estado_siguiente <= BC;
            end if;
    ---------------------------------             
          when CD => 
            if step = '1' and stop = '0' and (enable_m1 = '1' or enable_a = '1')then 
                if dir = '1' then         
                   estado_siguiente <= DA;        
                elsif dir = '0' then     
                   estado_siguiente <= BC;
                end if;
            else
                estado_siguiente <= CD;
            end if;   
    ---------------------------------             
          when DA => 
            if step = '1' and stop = '0' and (enable_m1 = '1' or enable_a = '1')then 
                if dir = '1' then        
                   estado_siguiente <= AB;        
                elsif dir = '0' then      
                   estado_siguiente <= CD;
                end if;
            else 
                estado_siguiente <= DA;
            end if;  
    end case;
end process;

----------PROCESO--------------
---Biestable D: proceso secuencia que actualiza el estado cada cilco de reloj y lo guarda en un biesteble.
p_secuencia: Process (rst, clk)
begin
  if rst='1' then
    estado_actual <= AB;
  elsif clk'event and clk= '1' then
    estado_actual <= estado_siguiente;
  end if;
end process;

--------PROCESO COMINACIONAL DE SALIDAS.--------
--proporciaona las salidas 
P_comb_salidas: Process (estado_actual)
begin
    int   <= (others=>'0');
       case estado_actual is
         --------------------------
         when AB => 
           int   <= ("1100");
         --------------------------             
         when BC => 
           int   <= ("0110");
         --------------------------             
         when CD =>
           int   <= ("0011");
         ---------------------------             
         when DA=> 
           int   <= ("1001");
        end case;
end process;

end Behavioral;

