----------------------------------------------------------------------------------
-- Engineer: Carlos Sanchez
-- Create Date: 16.01.2021 
-- Module Name: stepper_motor
-- Project Name: TFM
-- Description: 
--        Control simple del motor paso a paso.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--------------------------------------------------------------------------------
entity stepper_motor is
 Port ( 
         clk: in  std_logic;
         rst: in  std_logic; 
      enable: in  std_logic; -- señal que habilita el movimiento del motor, del modulo de control
         dir: in  std_logic; -- modifica la dirección del motor, señal del modulo de control
     endstop: in  std_logic; -- indica si se ha alacanzado el limite inferior de movimiento
  s_funciona: out std_logic; -- indica si el motor esta funcionando
         int: out std_logic_vector(3 downto 0)
 );
end stepper_motor;
--------------------------------------------------------------------------------
architecture Behavioral of stepper_motor is
    -- Señales para obtener la señar de 100Hz
    signal cuenta: natural range 0 to 2**20-1;
    constant fin_cuenta: natural := 1000000;--1000000; -- frecuencia recomendada datasheet833000
    signal step: std_logic;  
    signal stop: std_logic;   
    signal movimiento: std_logic;   
    signal funciona: std_logic; 
    --Maquina de estados motor:
    type estado_motor is ( AB, BC, CD, DA);
    signal estado_actual, estado_siguiente: estado_motor;
--------------------------------------------------------------------------------

begin
   P_contador_100Hz: process(clk,rst)
    begin 
        if rst = '1' then
            cuenta <= 0;
        elsif clk'event and clk = '1' then
        if enable = '1' then
            if cuenta = fin_cuenta-1 then
               cuenta <= 0;
            else 
               cuenta <= cuenta + 1;
            end if;
          end if;
        end if;
 end process;
   
 step <= '1' when (cuenta = fin_cuenta-1) and enable = '1' else '0'; 
 stop <= '1' when endstop = '0' and dir = '1' else '0';
 funciona <= '1' when step ='1' and stop='0' else '0';
 
 s_funciona <= funciona; -- activa el contador de revoluciones en el módulo control
 movimiento <= '1' when funciona = '1' else '0';-- activa el funcionamiento del motor
 
P_cambio_estado: Process (estado_actual, funciona, dir, movimiento)
begin
    case estado_actual is 
   ----------------------------------
        when AB => 
            if movimiento = '1' then 
                if dir = '1' then  
                   estado_siguiente <= BC;        
                elsif dir = '0' then
                   estado_siguiente <= DA;
                end if;  
            else -- step = '0'
                estado_siguiente <= AB;
            end if;
             
   -----------------------------------             
           when BC => 
            if movimiento = '1' then 
                if dir = '1' then         
                   estado_siguiente <= CD;        
                elsif dir = '0' then   
                   estado_siguiente <= AB;
                end if;
            else
                estado_siguiente <= BC;
            end if;
    -----------------------------------             
          when CD => 
            if movimiento = '1' then 
                if dir = '1' then         
                   estado_siguiente <= DA;        
                elsif dir = '0' then     
                   estado_siguiente <= BC;
                end if;
            else
                estado_siguiente <= CD;
            end if;   
    -----------------------------------             
          when DA => 
            if movimiento = '1' then 
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

p_secuencia: Process (rst, clk)
begin
  if rst='1' then
    estado_actual <= AB;
  elsif clk'event and clk= '1' then
    estado_actual <= estado_siguiente;
  end if;
end process;

-- los dos primeros bits empezando por la izquierda corresponden a una bobina, y los dos siguientes a la otra
P_comb_salidas: Process (estado_actual)
begin
    int   <= (others=>'0');
       case estado_actual is
         ------------------------------
         when AB => 
           int   <= ("1010");
         ------------------------------             
         when BC => 
           int   <= ("1001");
         ------------------------------             
         when CD =>
           int   <= ("0101");
         -------------------------------             
         when DA=> 
           int   <= ("0110");
        end case;
end process;

end Behavioral;

