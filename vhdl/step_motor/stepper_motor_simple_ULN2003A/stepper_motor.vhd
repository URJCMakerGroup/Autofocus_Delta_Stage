----------------------------------------------------------------------------------
-- Engineer: Carlos Sanchez
-- Create Date: 16.01.2021 
-- Module Name: stepper_motor
-- Project Name: TFM
-- Description: 
--        Control simple del motor paso a paso.
--        EL sw0 habilita el movimiento del motor.
--        El sw1 controla el sentido de la la dirección.
--==============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;-- para poder utilizar signed y unsigned;

--==============================================================================
entity stepper_motor is
 Port ( 
       clk: in std_logic;
       rst: in std_logic; -- sw 15
    enable: in std_logic; -- sw 0
      sw_1: in std_logic; -- sw 1: ON - sentido horario; OFF - sentido antihorario
    
       int: out std_logic_vector(3 downto 0);
       led: out std_logic;
       led1: out std_logic;
       led2: out std_logic
 );
end stepper_motor;

--==============================================================================
architecture Behavioral of stepper_motor is
    -- Señales para obtener la señar de 100Hz
    signal cuenta: natural range 0 to 2**20-1;
    constant fin_cuenta: natural := 1000000;
    signal step: std_logic;  
    
    --Defino maquina de estados
    type estado_motor is ( AB, BC, CD, DA);
    --Señales de los procesos
    signal estado_actual, estado_siguiente: estado_motor;
    
    constant sw_on : std_logic := '1';
    constant sw_off : std_logic := '0';
    
--==============================================================================

begin

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
 led  <= '1' when enable = '1' else '0';
 led1 <= '1' when sw_1 = '1' else '0';    
 led2 <= '1' when rst = '1' else '0'; 
 
P_cambio_estado: Process (estado_actual, enable, sw_1, step)
begin
    case estado_actual is 
   ----------------------------------
        when AB => 
            if step = '1' and enable = '1' then 
                
                if sw_1 = '1' then  
                   estado_siguiente <= BC;        
                elsif sw_1 = '0' then
                   estado_siguiente <= DA;
                end if;   
                
            else -- step = '0'
                estado_siguiente <= AB;
            end if;
             
   -----------------------------------             
           when BC => 
            if step = '1' and enable = '1' then 
                if sw_1 = '1' then         
                   estado_siguiente <= CD;        
                elsif sw_1 = '0' then   
                   estado_siguiente <= AB;
                end if;
            else
                estado_siguiente <= BC;
            end if;
    -----------------------------------             
          when CD => 
            if step = '1' and enable = '1' then 
                if sw_1 = '1' then         
                   estado_siguiente <= DA;        
                elsif sw_1 = '0' then     
                   estado_siguiente <= BC;
                end if;
            else
                estado_siguiente <= CD;
            end if;   
    -----------------------------------             
          when DA => 
            if step = '1' and enable = '1' then 
                if sw_1 = '1' then        
                   estado_siguiente <= AB;        
                elsif sw_1 = '0' then      
                   estado_siguiente <= CD;
                end if;
            else 
                estado_siguiente <= DA;
            end if;  
    end case;
end process;


p_secuencia: Process (rst, clk)
begin
  if rst='1' then
    estado_actual <= AB;
  elsif clk'event and clk= '1' then
    estado_actual <= estado_siguiente;
  end if;
end process;

--------PROCESO COMINACIONAL DE SALIDAS.--------
P_comb_salidas: Process (estado_actual)
begin
    int   <= (others=>'0');
       case estado_actual is
         --------------s001------------
         when AB => 
           int   <= ("1100");
         --------------s010------------             
         when BC => 
           int   <= ("0110");
         --------------s011------------             
         when CD =>
           int   <= ("0011");
         --------------s11-------------             
         when DA=> 
           int   <= ("1001");
        end case;
end process;

end Behavioral;

