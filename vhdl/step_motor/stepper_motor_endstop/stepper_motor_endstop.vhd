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
       
     en_motor: in std_logic; -- activa el movimiento de un único motor
 en_all_motor: in std_logic; -- activa el movimiento de todos los motores
       dir: in std_logic;    -- sw 1: ON - sentido horario / OFF - sentido antihorario 
   endstop: in std_logic;    -- señal del final de carrera
    
       int: out std_logic_vector(3 downto 0); -- salidas para el motor
     led_m: out std_logic; -- se enciende cuando funciona el motor
   led_dir: out std_logic; -- se enciende cuando se activa el sw
   led_rst: out std_logic  -- se enciende cuando se activa el 
 );
end stepper_motor;

--==============================================================================
architecture Behavioral of stepper_motor is
    -- Señales para obtener la señar de 100Hz
    signal cuenta: natural range 0 to 2**20-1;
    constant fin_cuenta: natural := 1000000; --1000000
    signal step: std_logic;  
    
    signal cuenta_step: natural range 0 to 2**20-1;
    constant fin_cuenta_step: natural := 1536; --1000000
    signal fin_cont_step: std_logic;  

    -- Señales máquina de estados
    type estado_motor is ( AB, BC, CD, DA);
    signal estado_actual, estado_siguiente: estado_motor;
    
    -- Señales del detector de pulsación
    signal reg_m1: std_logic;
    signal reg_m2: std_logic;
    signal pulso_m: std_logic;
    signal reg_a1: std_logic;
    signal reg_a2: std_logic;
    signal pulso_a: std_logic;
    signal reg_step1: std_logic;
    signal reg_step2: std_logic;
    signal pulso_step: std_logic;
    
    signal enable_m: std_logic; -- señal que habilita un motor
    signal enable_a: std_logic; -- señal que habilita todos los motores
    signal stop: std_logic; -- detiene el movimiento si la dirección es hacia abajo y toca el  final de carrera
    
-------------------------------------------------------------------------------

begin

Detector_pulso: process(rst, clk)
    begin
        if rst='1' then
            reg_m1 <='0';
            reg_m2 <='0';
            reg_a1 <='0';
            reg_a2 <='0';
            reg_step1 <='0';
            reg_step2 <='0';
        elsif clk' event and clk='1' then
            reg_m1 <= en_motor;
            reg_m2 <= reg_m1;
            reg_a1 <= en_all_motor;
            reg_a2 <= reg_a1;
            reg_step1 <= fin_cont_step;
            reg_step2 <= reg_step1;
        end if;
    end process;
 pulso_m <='1' when (reg_m1 = '1' and reg_m2 ='0') else '0';  
 pulso_a <='1' when (reg_a1 = '1' and reg_a2 ='0') else '0'; 
 pulso_step <='1' when (reg_step1 = '1' and reg_step2 ='0') else '0';
  
bies_T_btn : process(rst, clk, enable_a)
    begin
        if rst='1' then
            enable_m <='0';
        elsif clk' event and clk='1' then
            if pulso_m= '1' then
                enable_m <= not enable_m;
            elsif pulso_step = '1' then
                enable_m <= '0';
            else
                enable_m <= enable_m;
            end if;
        end if;
    end process;     
bies_T_btn2 : process(rst, clk)
    begin
        if rst='1' then 
            enable_a <='0';
        elsif clk' event and clk='1' then
            if pulso_a= '1' then
                enable_a <= not enable_a;
            elsif pulso_step = '1' then
                enable_a <= '0';
            else
                enable_a <= enable_a;
            end if;
        end if;
    end process; 
  
P_contador_100Hz: process(clk,rst)
begin 
    if rst = '1' then
        cuenta <= 0;
    elsif clk'event and clk = '1' then
    if enable_a = '1' or enable_m = '1' then
        if cuenta = fin_cuenta-1 then
           cuenta <= 0;
        else 
           cuenta <= cuenta + 1;
        end if;
     end if;
    end if;
end process;
step <= '1' when (cuenta = fin_cuenta-1) else '0'; 
stop <= '1' when endstop = '1' and dir = '1' else '0';
 
P_contador_step: process(clk,rst)
begin 
    if rst = '1' then
        cuenta_step <= 0;
    elsif clk'event and clk = '1' then
    if step = '1' then
        if cuenta_step = fin_cuenta_step-1 then
           cuenta_step <= 0;
        else 
           cuenta_step <= cuenta_step + 1;
        end if;
     end if;
    end if;
end process;  
fin_cont_step <= '1' when (cuenta_step = fin_cuenta_step-1) else '0'; 

 
P_cambio_estado: Process (estado_actual, stop, dir, step)
begin
    case estado_actual is 
   --------------------------------
        when AB => 
            if step = '1' and stop = '0' then                
                if dir = '1' then  
                   estado_siguiente <= BC;        
                elsif dir = '0' then
                   estado_siguiente <= DA;
                end if;                  
            else 
                estado_siguiente <= AB;
            end if;             
   ---------------------------------             
           when BC => 
            if step = '1' and stop = '0' and (enable_m = '1' or enable_a = '1')then 
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
            if step = '1' and stop = '0' and (enable_m = '1' or enable_a = '1')then 
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
            if step = '1' and stop = '0' and (enable_m = '1' or enable_a = '1')then 
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

-- proceso secuencial que actualiza el estado
P_actualiza_estado: Process (rst, clk)
begin
  if rst='1' then
    estado_actual <= AB;
  elsif clk'event and clk= '1' then
    estado_actual <= estado_siguiente;
  end if;
end process;

-- Proceso combinacional de salidas
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
 led_m <= '1' when enable_m = '1' or enable_a = '1' else '0';
 led_dir <= '1' when dir = '1' else '0';    
 led_rst <= '1' when rst = '1' else '0'; 
end Behavioral;


