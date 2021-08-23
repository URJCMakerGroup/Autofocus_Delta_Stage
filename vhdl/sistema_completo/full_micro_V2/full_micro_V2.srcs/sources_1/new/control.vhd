----------------------------------------------------------------------------------
-- Engineer: Carlos Sanchez
-- Create Date: 16.01.2021 
-- Module Name: stepper_motor
-- Project Name: TFM
-- Description: 
--        Modulo principal que controla los motores y sus diferentes movimientos según
--         la maquina de estados diseñada


-- Contador de posicion limitado a 16, 4 bits porque no puedo ver mas en el display de 7 seg
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.ov7670_pkg.all;
use work.osc_pkg.all;
use work.pkg_sum.all;

entity control is
  Port ( 
          clk: in std_logic;
          rst: in std_logic;
   s_inic_cam: out std_logic;
       s_uart: in std_logic;
          
        led_e: out std_logic_vector(5 downto 0);  -- indica el estado en el que se encuentra
       
       sw_ref: in std_logic; -- sw que modifica el estado
   sw_enfoque: in std_logic; -- sw que modica el estado
   
   -- mueve todos los motores
    btn_motor_a: in std_logic;
   -- motor 3
    btn_motor3: in std_logic;  -- btn que habilita el movimiento
    endstop_m3: in std_logic;  -- señal endstop
--      led_pos3: out std_logic; -- led que indica si esta en la posicion inferior (si toca o no el endstop)
      s_motor3: out std_logic; -- señal que habilita el movimiento del motor
    lim_sup_m3: out std_logic; -- indica el limite superior
--        led_m3: out std_logic; -- indica si el motor esta en funcionamiento 
 s_funciona_m3: in std_logic;  -- señal que indica si el motor esta en funcionamiento
   -- motor 2:
    btn_motor2: in std_logic;
    endstop_m2: in std_logic;
--      led_pos2: out std_logic;
      s_motor2: out std_logic;
    lim_sup_m2: out std_logic;
--        led_m2: out std_logic;
 s_funciona_m2: in std_logic;
   -- motor 1:
    btn_motor1: in std_logic;
    endstop_m1: in std_logic;
--     led_pos1: out std_logic;
     s_motor1: out std_logic;
    lim_sup_m1: out std_logic;
--        led_m1: out std_logic;
 s_funciona_m1: in std_logic;
      
          dir: in std_logic; -- sw que modifica la dirección de ajuste '0'-ARRIBA  '1'- ABAJO
        s_dir: out std_logic; -- señal que modifica la direccion del motor 
      led_dir: out std_logic; -- indica de forma visual que dirección esta activada
maximo : in STD_LOGIC_VECTOR (bram_addr downto 0);
       
  c_rev_relativo: out std_logic_vector(4-1 downto 0); -- indica la cuenta en el display
  c_rev_abs_m3: out std_logic_vector(4-1 downto 0);   -- indica la cuenta en el display
  c_rev_abs_m2: out std_logic_vector(4-1 downto 0);   -- indica la cuenta en el display
  c_rev_abs_m1: out std_logic_vector(4-1 downto 0)    -- indica la cuenta en el display
    );
end control;

architecture Behavioral of control is

    signal  reg1_m3: std_logic;
    signal  reg2_m3: std_logic;
    signal pulso_m3: std_logic; 
    signal  reg1_p3: std_logic;
    signal  reg2_p3: std_logic;
    signal pulso_p3: std_logic;
    signal cuenta_step_m3: natural range 0 to 2**12-1;
    signal s_fin_step_m3: std_logic; 
    signal c_rev_abs_aux_m3: unsigned( 4-1 downto 0);
    signal s_m3_aux: std_logic;
   -- 
    signal  reg1_m2: std_logic;
    signal  reg2_m2: std_logic;
    signal pulso_m2: std_logic; 
    signal  reg1_p2: std_logic;
    signal  reg2_p2: std_logic;
    signal pulso_p2: std_logic;
    signal cuenta_step_m2: natural range 0 to 2**12-1;
    signal s_fin_step_m2: std_logic; 
    signal c_rev_abs_aux_m2: unsigned( 4-1 downto 0);
    signal s_m2_aux: std_logic;
   --
    signal  reg1_m1: std_logic;
    signal  reg2_m1: std_logic;
    signal pulso_m1: std_logic;
    signal cuenta_step_m1: natural range 0 to 2**12-1;
    signal s_fin_step_m1: std_logic;
    signal c_rev_abs_aux_m1: unsigned( 4-1 downto 0);
    signal  reg1_p1: std_logic;
    signal  reg2_p1: std_logic;
    signal pulso_p1: std_logic;
    signal s_m1_aux: std_logic;
   -- 
    signal  reg1_a: std_logic;
    signal  reg2_a: std_logic;
    signal pulso_a: std_logic;
   --
    signal  dir_aux: std_logic;
    signal  endstop: std_logic;
    constant fin_cuenta_step: natural := 2048;--1536; --1000000
    
    --Defino maquina de estados:
    type sist_posicion is ( inicio, referencia, ajuste, autoenfoque, pos_max, env_img);
    signal estado_actual, estado_siguiente: sist_posicion;
    --
    signal c_enfoq: natural range 0 to 2**12-1;
--    constant fin_c_enfoq: natural := 16;
    signal s_fin_c_enfoq: std_logic;
    --
--    constant pos_maximo: natural := 3;----------será la variable del comparador
    signal s_fin_c_maximo: std_logic;
    signal cuenta_rev_aux: unsigned( 4-1 downto 0);
    signal fin_cnt_rev: std_logic; 
    signal pulso_p: std_logic; 
     
    signal en_all_motor: std_logic;  
    
begin
en_all_motor <= '1' when s_uart = '1' or btn_motor_a = '1' else '0';
-- detector de pulso 
Detector_pulso: process(rst, clk)
    begin
        if rst='1' then
            reg1_m1 <='0';
            reg2_m1 <='0';
            reg1_p1 <='0';
            reg2_p1 <='0';
            
            reg1_m3 <='0';
            reg2_m3 <='0';
            reg1_p3 <='0';
            reg2_p3 <='0';
            
            reg1_m2 <='0';
            reg2_m2 <='0';
            reg1_p2 <='0';
            reg2_p2 <='0';
            
            reg1_a <='0';
            reg2_a <='0';
            
        elsif clk' event and clk='1' then  
        
            reg1_a <= en_all_motor;---
            reg2_a <= reg1_a;
            
            reg1_m3 <= btn_motor3;
            reg2_m3 <= reg1_m3;
            reg1_p3 <= s_fin_step_m3;
            reg2_p3 <= reg1_p3;
            
            reg1_m2 <= btn_motor2;
            reg2_m2 <= reg1_m2;
            reg1_p2 <= s_fin_step_m2;
            reg2_p2 <= reg1_p2;
            
            reg1_m1 <= btn_motor1;
            reg2_m1 <= reg1_m1;
            reg1_p1 <= s_fin_step_m1;
            reg2_p1 <= reg1_p1;
            
        end if;
    end process;--------------------------------------------------------------------------------------------------------------------ajuste = estado_actual
  pulso_m1 <='1' when (reg1_m1 = '1' and reg2_m1 ='0') and estado_actual = ajuste else '0'; -- pulso al pulsar el motor 1
  pulso_m2 <='1' when (reg1_m2 = '1' and reg2_m2 ='0') and estado_actual = ajuste else '0'; -- pulso al pulsar el motor 2
  pulso_m3 <='1' when (reg1_m3 = '1' and reg2_m3 ='0') and estado_actual = ajuste else '0'; -- pulso al pulsar el motor 2
   pulso_a <='1' when (reg1_a = '1' and reg2_a ='0') else '0'; -- pulso al pulsar up - habilita todos los motores
  
  pulso_p1 <='1' when (reg1_p1 = '1' and reg2_p1 ='0') else '0'; -- pulso cuando se completa una revolución del motor 1
  pulso_p2 <='1' when (reg1_p2 = '1' and reg2_p2 ='0') else '0'; -- pulso cuando se completa una revolución del motor 1
  pulso_p3 <='1' when (reg1_p3 = '1' and reg2_p3 ='0') else '0'; -- pulso cuando se completa una revolución del motor 1
  
  pulso_p <= '1' when pulso_p2 = '1' else '0'; --and pulso_p2 = '1' else '0'; -- 
      
-- Guarda el valor del btn para mantener activo el motor 1   
bies_T_btn_m1 : process(rst, clk)
    begin
        if rst='1' then
            s_m1_aux <='0';
        elsif clk' event and clk='1' then
            if pulso_m1 = '1' or pulso_a ='1' then
                s_m1_aux <= not s_m1_aux;
            elsif estado_actual = autoenfoque and s_fin_step_m1 = '1' then
                s_m1_aux <= not s_m1_aux;
            elsif estado_actual = env_img then
                s_m1_aux <= '0';
            else
                s_m1_aux <= s_m1_aux;
            end if;
      end if;
    end process;      
-- led_m1 <= s_m1_aux;
 
 bies_T_btn_m2 : process(rst, clk)
    begin
        if rst='1' then
            s_m2_aux <='0';
        elsif clk' event and clk='1' then
            if pulso_m2 = '1' or pulso_a ='1' then
                s_m2_aux <= not s_m2_aux;
            elsif estado_actual = autoenfoque and s_fin_step_m2 = '1' then
                s_m2_aux <= not s_m2_aux;
            elsif estado_actual = env_img then
                s_m2_aux <= '0';
            else
                s_m2_aux <= s_m2_aux;
            end if;
      end if;
    end process;      
-- led_m2 <= s_m2_aux;
 
 bies_T_btn_m3 : process(rst, clk)
    begin
        if rst='1' then
            s_m3_aux <='0';
        elsif clk' event and clk='1' then
            if pulso_m3 = '1' or pulso_a ='1' then
                s_m3_aux <= not s_m3_aux;
            elsif estado_actual = autoenfoque and s_fin_step_m3 = '1' then
                s_m3_aux <= not s_m3_aux;
            elsif estado_actual = env_img then
                s_m3_aux <= '0';
            else
                s_m3_aux <= s_m3_aux;
            end if;
      end if;
    end process;      
-- led_m3 <= s_m3_aux;
 
-- Señal al realizar una revolución completa del motor 1
cnt_steps_m1: process(rst, clk)
    begin
        if rst='1' then
            cuenta_step_m1 <= 0;
        elsif clk' event and clk='1' then
            if s_funciona_m1 = '1' and estado_actual = autoenfoque then
                 if cuenta_step_m1 = fin_cuenta_step-1 then
                    cuenta_step_m1 <= 0;
                 else
                    cuenta_step_m1 <= cuenta_step_m1 +1;
                end if;
             --   
            elsif s_funciona_m1 = '1' and estado_actual = pos_max then
                 if cuenta_step_m1 = fin_cuenta_step-1 then --cuenta_step_m1
                    cuenta_step_m1 <= 0;
                 else
                    cuenta_step_m1 <= cuenta_step_m1 +1;
                end if;
                --
            elsif s_funciona_m1 = '1' and estado_actual = ajuste then
                 if cuenta_step_m1 = fin_cuenta_step-1 then
                    cuenta_step_m1 <= 0;
                 else
                    cuenta_step_m1 <= cuenta_step_m1 +1;
                end if;
                --
            elsif s_funciona_m1 = '0' and sw_enfoque = '1' and estado_actual = ajuste then
                    cuenta_step_m1 <= 0;
           end if;
      end if;
    end process;   
 s_fin_step_m1 <= '1' when (cuenta_step_m1 = fin_cuenta_step-1) else '0'; --maximo 40
 
cnt_steps_m2: process(rst, clk)
    begin
        if rst='1' then
            cuenta_step_m2 <= 0;
        elsif clk' event and clk='1' then
            if s_funciona_m2 = '1' and estado_actual = autoenfoque then
                 if cuenta_step_m2 = fin_cuenta_step-1 then
                    cuenta_step_m2 <= 0;
                 else
                    cuenta_step_m2 <= cuenta_step_m2 +1;
                end if;
             --   
            elsif s_funciona_m2 = '1' and estado_actual = pos_max then
                 if cuenta_step_m2 = fin_cuenta_step-1 then
                    cuenta_step_m2 <= 0;
                 else
                    cuenta_step_m2 <= cuenta_step_m2 +1;
                end if;
                --
            elsif s_funciona_m2 = '1' and estado_actual = ajuste then
                 if cuenta_step_m2 = fin_cuenta_step-1 then
                    cuenta_step_m2 <= 0;
                 else
                    cuenta_step_m2 <= cuenta_step_m2 +1;
                end if;
                --
            elsif s_funciona_m2 = '0' and sw_enfoque = '1' and estado_actual = ajuste then
                    cuenta_step_m2 <= 0;
                
           end if;
      end if;
    end process;   
 s_fin_step_m2 <= '1' when (cuenta_step_m2 = fin_cuenta_step-1) else '0'; --maximo 40
 
cnt_steps_m3: process(rst, clk)
    begin
        if rst='1' then
            cuenta_step_m3 <= 0;
        elsif clk' event and clk='1' then
            if s_funciona_m3 = '1' and estado_actual = autoenfoque then
                 if cuenta_step_m3 = fin_cuenta_step-1 then
                    cuenta_step_m3 <= 0;
                 else
                    cuenta_step_m3 <= cuenta_step_m3 +1;
                end if;
             --   
            elsif s_funciona_m3 = '1' and estado_actual = pos_max then
                 if cuenta_step_m3 = fin_cuenta_step-1 then
                    cuenta_step_m3 <= 0;
                 else
                    cuenta_step_m3 <= cuenta_step_m3 +1;
                end if;
                --
            elsif s_funciona_m3 = '1' and estado_actual = ajuste then
                 if cuenta_step_m3 = fin_cuenta_step-1 then
                    cuenta_step_m3 <= 0;
                 else
                    cuenta_step_m3 <= cuenta_step_m3 +1;
                end if;
            elsif s_funciona_m3 = '0' and sw_enfoque = '1' and estado_actual = ajuste then
                    cuenta_step_m3 <= 0;
                
           end if;
      end if;
    end process;   
 s_fin_step_m3 <= '1' when (cuenta_step_m3 = fin_cuenta_step-1) else '0'; --maximo 40
    
-- Cuenta de revoluciones a partir de la posicion definida en ajuste
-- MEJORA: si se alcanza el limite en todos  no se incrementa uno
cnt_rev: process(rst, clk)--------------------------------------------------------------------
    begin
        if rst='1' then
            cuenta_rev_aux <= (others => '0');
        elsif clk' event and clk='1' then
            if estado_actual = autoenfoque or  estado_actual = pos_max then
            
               if pulso_p1 = '1'and dir_aux = '0' then-----------------p1 o p
                  cuenta_rev_aux <= cuenta_rev_aux +1;
               elsif pulso_p1 = '1'and dir_aux = '1' then
                  cuenta_rev_aux <= cuenta_rev_aux -1;
               else
                  cuenta_rev_aux <= cuenta_rev_aux;
               end if;
               
            elsif estado_actual = referencia then
                  cuenta_rev_aux <= (others => '0');
            else 
                  cuenta_rev_aux <= cuenta_rev_aux;
          end if;
          
      end if;
    end process;   
 c_rev_relativo <= std_logic_vector(cuenta_rev_aux);
 s_fin_c_enfoq <= '1' when estado_actual = autoenfoque and (cuenta_rev_aux = 9) and pulso_a = '1' else '0'; ----------------------
 s_fin_c_maximo <= '1' when estado_actual = pos_max and (cuenta_rev_aux = unsigned(maximo)) else '0';------------------------------------------------
 
 
-- Cuenta de revoluciones absoluto
 cnt_rev_abs_m1: process(rst, clk)
    begin
        if rst='1' then
            c_rev_abs_aux_m1 <= (others => '0');
            lim_sup_m1 <= '0';
        elsif clk' event and clk='1' then
            if estado_actual = ajuste or  estado_actual = autoenfoque or  estado_actual = pos_max then
                if c_rev_abs_aux_m1 >= 9 and dir_aux ='0' then ----or lim_sup_m2 = '1' limite superior y direccion ascendente, para que si uno llega al maximo el resto se paren tambien, habría que llevar la cuenta relativa al maximo
                    lim_sup_m1 <= '1';
                    c_rev_abs_aux_m1 <= c_rev_abs_aux_m1;
                else
                    lim_sup_m1 <= '0';
                   if pulso_p1 = '1'and dir_aux = '0' then
                      c_rev_abs_aux_m1 <= c_rev_abs_aux_m1 +1;
                   elsif pulso_p1 = '1'and dir_aux = '1' then
                      c_rev_abs_aux_m1 <= c_rev_abs_aux_m1 -1;
                   else
                      c_rev_abs_aux_m1 <= c_rev_abs_aux_m1;
                   end if;
               end if;
            elsif estado_actual = referencia then
                  c_rev_abs_aux_m1 <= (others => '0');
            else 
                  c_rev_abs_aux_m1 <= c_rev_abs_aux_m1;
          end if;
          
      end if;
    end process;  
 c_rev_abs_m1 <= std_logic_vector(c_rev_abs_aux_m1);
 
 cnt_rev_abs_m2: process(rst, clk)
    begin
        if rst='1' then
            c_rev_abs_aux_m2 <= (others => '0');
            lim_sup_m2 <= '0';
        elsif clk' event and clk='1' then
            if estado_actual = ajuste or  estado_actual = autoenfoque or  estado_actual = pos_max then
                if c_rev_abs_aux_m2 >= 9 and dir_aux ='0' then---------------------------
                    lim_sup_m2 <= '1';
                    c_rev_abs_aux_m2 <= c_rev_abs_aux_m2;
                else
                    lim_sup_m2 <= '0';
                   if pulso_p2 = '1'and dir_aux = '0' then
                      c_rev_abs_aux_m2 <= c_rev_abs_aux_m2 +1;
                   elsif pulso_p2 = '1'and dir_aux = '1' then
                      c_rev_abs_aux_m2 <= c_rev_abs_aux_m2 -1;
                   else
                      c_rev_abs_aux_m2 <= c_rev_abs_aux_m2;
                   end if;
               end if;
            elsif estado_actual = referencia then
                  c_rev_abs_aux_m2 <= (others => '0');
            else 
                  c_rev_abs_aux_m2 <= c_rev_abs_aux_m2;
          end if;
          
      end if;
    end process;  
 c_rev_abs_m2 <= std_logic_vector(c_rev_abs_aux_m2);
  
 cnt_rev_abs_m3: process(rst, clk)
    begin
        if rst='1' then
            c_rev_abs_aux_m3 <= (others => '0');
            lim_sup_m3 <= '0';
        elsif clk' event and clk='1' then
            if estado_actual = ajuste or  estado_actual = autoenfoque or  estado_actual = pos_max then
                if c_rev_abs_aux_m3 >= 9 and dir_aux ='0' then -------------------------------------------------------------------------------------
                    lim_sup_m3 <= '1';
                    c_rev_abs_aux_m3 <= c_rev_abs_aux_m3;
                else
                    lim_sup_m3 <= '0';
                   if pulso_p3 = '1'and dir_aux = '0' then
                      c_rev_abs_aux_m3 <= c_rev_abs_aux_m3 +1;
                   elsif pulso_p3 = '1'and dir_aux = '1' then
                      c_rev_abs_aux_m3 <= c_rev_abs_aux_m3 -1;
                   else
                      c_rev_abs_aux_m3 <= c_rev_abs_aux_m3;
                   end if;
               end if;
            elsif estado_actual = referencia then
                  c_rev_abs_aux_m3 <= (others => '0');
            else 
                  c_rev_abs_aux_m3 <= c_rev_abs_aux_m3;
          end if;
          
      end if;
    end process;  
 c_rev_abs_m3 <= std_logic_vector(c_rev_abs_aux_m3);
 
 -- sumatorio de limites superiores que detenga el movimiento
 endstop <= '0' when endstop_m1 = '0' and endstop_m2 = '0' and endstop_m3 = '0' else '1'; -- 
 
-- Maquina estados-------------------------------------------------------
P_cambio_estado: Process (estado_actual, sw_ref, sw_enfoque, s_fin_c_maximo, s_fin_c_enfoq, endstop)
begin
    case estado_actual is 
   ----------------------------------
   -- cambia al pulsar el sw_referencia, que me lleva a la posición del endstop
        when inicio =>  
            if sw_enfoque = '0' and sw_ref = '1' then 
               estado_siguiente <= referencia;     
            else
               estado_siguiente <= inicio;
            end if;
   ----------------------------------- 
    -- parte de la posicion de referencia y controla el numero de revoluciones de cada motor            
           when referencia =>
            if endstop = '0' then --and sw_ref = '0' then -- hacer el sumatorio de endstops
               estado_siguiente <= ajuste; 
            else
               estado_siguiente <= referencia;
            end if;
    -----------------------------------  
     -- parte de la posicion de referencia y controla el numero de revoluciones de cada motor           
          when ajuste => 
            if sw_enfoque = '1' then     
               estado_siguiente <= autoenfoque; 
            else
               estado_siguiente <= ajuste;
            end if;        
    -----------------------------------  
    -- aumento todos un ciclo con cada pulso     
          when autoenfoque =>  
          if  s_fin_c_enfoq = '1' then 
               estado_siguiente <= pos_max; 
          else          
               estado_siguiente <= autoenfoque; 
          end if;          
    -----------------------------------             
          when pos_max =>  -- parte de la posicion de referencia y controla el numero de revoluciones de cada motor
              if s_fin_c_maximo = '1' then
               estado_siguiente <= env_img; 
          else          
               estado_siguiente <= pos_max; 
          end if;         
    -----------------------------------        
          when env_img =>  -- parte de la posicion de referencia y controla el numero de revoluciones de cada motor
              if sw_enfoque = '0' and sw_ref = '0' then
               estado_siguiente <= inicio; 
          else          
               estado_siguiente <= env_img; 
          end if;         
    end case;
end process;

P_comb_salidas: Process (estado_actual, dir, s_m1_aux, s_m2_aux, s_m3_aux)
begin
    led_e <= (others => '0');
       case estado_actual is
         ------------------------------
         when inicio => 
              dir_aux <= dir;
             s_motor1 <= s_m1_aux;
             s_motor2 <= s_m2_aux;
             s_motor3 <= s_m3_aux;
             
                led_e <= "000001";
         ------------------------------             
         when referencia => 
              dir_aux <= '1'; -- arriba
             s_motor1 <= '1'; 
             s_motor2 <= '1';
             s_motor3 <= '1';
             
                led_e <= "000010";
         ------------------------------             
         when ajuste =>
              dir_aux <= dir;
             s_motor1 <= s_m1_aux;
             s_motor2 <= s_m2_aux;
             s_motor3 <= s_m3_aux;
             
                led_e <= "000100";
         ------------------------------             
         when autoenfoque =>
              dir_aux <= '0'; --abajo
             s_motor1 <= s_m1_aux;
             s_motor2 <= s_m2_aux;
             s_motor3 <= s_m3_aux;
             
                led_e <= "001000";
         ------------------------------             
         when pos_max =>
            dir_aux <= '1';
            s_motor1 <= '1'; --s_m1_aux '1'
            s_motor2 <= '1';
            s_motor3 <= '1';
             
             led_e <= "010000";
         ------------------------------         
         when env_img => 
            dir_aux <= '0';
            s_motor1 <= '0'; --s_m1_aux '1'
            s_motor2 <= '0';
            s_motor3 <= '0';
            
             led_e <= "100000";
         ------------------------------  
        end case;
end process;

 s_dir <= dir_aux;
 led_dir <= dir_aux;
-- led_pos1 <= endstop_m1;
-- led_pos2 <= endstop_m2;
-- led_pos3 <= endstop_m3;
 
p_secuencia: Process (rst, clk)
begin
  if rst='1' then
    estado_actual <= inicio;
  elsif clk'event and clk= '1' then
    estado_actual <= estado_siguiente;
  end if;
end process;    


s_inic_cam <= '1' when pulso_p1= '1' and estado_actual = autoenfoque else '0';
end Behavioral;
