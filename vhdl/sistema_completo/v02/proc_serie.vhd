library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity proc_serie is
  port (
    rst        : in  std_logic;
    clk        : in  std_logic;
    dat_ready  : in  std_logic;
    uart_data  : in  std_logic_vector(8-1 downto 0);
    
    led_estado : out std_logic_vector(3-1 downto 0);
    s_e_ajuste  : in  std_logic;
    --instrucciones
    i_motor_m1    : out  std_logic;
    i_motor_m2    : out  std_logic;
    i_motor_m3    : out  std_logic;
   
    s_funciona_m1 : in  std_logic;
    s_funciona_m2 : in  std_logic;
    s_funciona_m3 : in  std_logic;
    
    c_rev_abs_m1  : out std_logic_vector(4-1 downto 0); 
    c_rev_abs_m2  : out std_logic_vector(4-1 downto 0); 
    c_rev_abs_m3  : out std_logic_vector(4-1 downto 0); 
    
    i_dir         : out  std_logic;
    pos_maximo    : in std_logic_vector(4-1 downto 0);  
    
    aux_sobel_h   : out std_logic;
    
    ram_reseteada : in std_logic;
    s_reset_ram   : out std_logic;
    
    fin_manda_img : in  std_logic;
    i_cap_img     : out  std_logic;
    inic_sum      : out  std_logic;
    i_manda_img   : out  std_logic
  );
end proc_serie;
architecture behav of proc_serie is
    --Defino maquina de estados:
    type estados_micro is (inicio, i_captura, i_manda, home, ajuste, autoenfoque, maximo, final, reset_ram );
    --Se?ales de los procesos
    signal estado_actual, estado_siguiente: estados_micro;
    
    signal uart_data_aux : std_logic_vector(8-1 downto 0);
    signal instruccion   : std_logic_vector(8-1 downto 0);
  
    signal i_dir_aux : std_logic;
    signal pulso_dir : std_logic;
   
    signal i_motor_m1_aux : std_logic;
    signal pulso_m1 : std_logic;
    signal s_fin_step_m1 : std_logic;
    
    signal i_motor_m2_aux : std_logic;
    signal pulso_m2 : std_logic;
    signal s_fin_step_m2 : std_logic;
    
    signal i_motor_m3_aux : std_logic;
    signal pulso_m3 : std_logic;
    signal s_fin_step_m3 : std_logic;
    
    
    signal i_motor_a_aux : std_logic;
    signal pulso_a : std_logic;
    
    signal pulso_sobel : std_logic;
    signal i_sobel : std_logic;
    
    signal s_aux    : std_logic;
    signal s_cap_rx : std_logic;

    signal cuenta_step_m1: natural range 0 to 2**12-1;
    signal cuenta_step_m2: natural range 0 to 2**12-1;
    signal cuenta_step_m3: natural range 0 to 2**12-1;
    
    constant fin_cuenta_step: natural := 2048;
    
    signal c_rev_abs_aux_m1: unsigned( 4-1 downto 0);
    signal c_rev_abs_aux_m2: unsigned( 4-1 downto 0);
    signal c_rev_abs_aux_m3: unsigned( 4-1 downto 0);
    signal lim_sup_m1 : std_logic;
    
    
    signal i_cap_img_aux : std_logic;
    signal pulso_autoenfoque : std_logic;
    signal inic_sum_aux : std_logic;
    signal reg1_af : std_logic;
    signal reg2_af : std_logic;
    signal pulso_af : std_logic;
    
    signal reg1_m : std_logic;
    signal reg2_m : std_logic;
    signal pulso_1 : std_logic;
    
    signal reg1_m2 : std_logic;
    signal reg2_m2 : std_logic;
    signal pulso_2 : std_logic;
    
    signal reg1_m3 : std_logic;
    signal reg2_m3 : std_logic;
    signal pulso_3 : std_logic;
    
    signal s_fin_cont_af : std_logic;
    signal cuenta_af: unsigned( 4-1 downto 0);
    
    signal s_fin_c_maximo : std_logic;
    
begin


P_cambio_estado: Process (estado_actual, dat_ready, uart_data, fin_manda_img, s_e_ajuste, instruccion, s_fin_cont_af, s_fin_c_maximo, ram_reseteada)
begin         
   estado_siguiente <= inicio; 
    case estado_actual is 
   -- porque va un ciclo de reloj por detras la instruccion
        when inicio => 
            if dat_ready='1' then 
                if uart_data="00000100" then           
                   estado_siguiente <= i_manda;        
                elsif uart_data="00000010" then   
                   estado_siguiente <= i_captura;     
                elsif uart_data="00000011" then   
                   estado_siguiente <= home;
                else 
                    estado_siguiente <= inicio;
                end if; 
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
            if instruccion="00000001" then
                estado_siguiente <= inicio;
            elsif instruccion="00000100" then
                estado_siguiente <= i_manda;
            else
                estado_siguiente <= i_captura;
            end if;     
   ----------------------------------
        when home => 
            if instruccion="00000001" then           
               estado_siguiente <= inicio;  
            elsif s_e_ajuste = '1' then           
               estado_siguiente <= ajuste;  
            else 
                estado_siguiente <= home;
            end if; 
    -----------------------------------       
        when ajuste => 
            if instruccion="00000001" then           
               estado_siguiente <= inicio; 
            elsif instruccion="00000101" then           
               estado_siguiente <= autoenfoque;   
            else 
                estado_siguiente <= ajuste;
            end if; 
    -----------------------------------        
        when autoenfoque => 
            if instruccion="00000001" then           
               estado_siguiente <= inicio; 
            elsif s_fin_cont_af = '1' then           
               estado_siguiente <= maximo;   
            else 
                estado_siguiente <= autoenfoque;
            end if; 
    -----------------------------------       
        when maximo => 
            if  s_fin_c_maximo = '1' then           
               estado_siguiente <= final;         
            else 
                estado_siguiente <= maximo;
            end if; 
    -----------------------------------
        when final  => 
            if fin_manda_img = '1' then 
                estado_siguiente <= reset_ram;
            else
                estado_siguiente <= final;
            end if;   
    -----------------------------------
        when reset_ram  => 
            if ram_reseteada = '1' then 
                estado_siguiente <= inicio;
            else
                estado_siguiente <= reset_ram;
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

lee_instrucciones: process(rst, clk)
 begin
  if rst = '1' then
     instruccion <= (others => '0');
  elsif clk'event and clk='1' then
  if dat_ready = '1' then
    instruccion <= uart_data;
  end if;
 end if;
end process;

P_comb_salidas: Process (estado_actual)
-- Los dos primeros bits corresponden a la primera bobina del motor
-- y los dos siguientes a la segunda.
begin
   i_manda_img <= '0';
   led_estado <= (others=>'0');
    
       case estado_actual is
         ------------------------------
         when inicio => 
            i_manda_img <= '0';
            led_estado(0) <= '0';
            led_estado(1) <= '0';
            led_estado(2) <= '0';
            s_reset_ram   <= '0';
         ------------------------------            
         when i_manda =>
            i_manda_img <= '1';
            led_estado(0) <= '1';
            led_estado(1) <= '0';
            led_estado(2) <= '0';
            s_reset_ram   <= '0';
         -------------------------------             
         when i_captura=> 
            i_manda_img <= '0';
            led_estado(0) <= '0';
            led_estado(1) <= '1';
            led_estado(2) <= '0';
            s_reset_ram   <= '0';
         ------------------------------- 
         when home => 
            i_manda_img <= '0';
            led_estado(0) <= '1';
            led_estado(1) <= '1';
            led_estado(2) <= '0';
            s_reset_ram   <= '0';
         ------------------------------  
         when ajuste => 
            i_manda_img <= '0';
            led_estado(0) <= '0';
            led_estado(1) <= '0';
            led_estado(2) <= '1';
            s_reset_ram   <= '0';
         ------------------------------  
         when autoenfoque => 
            i_manda_img <= '0';
            led_estado(0) <= '1';
            led_estado(1) <= '0';
            led_estado(2) <= '1';
            s_reset_ram   <= '0';
         ------------------------------
         when maximo => 
            i_manda_img <= '0';
            led_estado(0) <= '0';
            led_estado(1) <= '1';
            led_estado(2) <= '1';
            s_reset_ram   <= '0';
         ------------------------------ 
         when final => 
            i_manda_img <= '1';
            led_estado(0) <= '1';
            led_estado(1) <= '1';
            led_estado(2) <= '1';
            s_reset_ram   <= '0';
         ------------------------------ 
         when reset_ram => 
            i_manda_img <= '0';
            led_estado(0) <= '1';
            led_estado(1) <= '0';
            led_estado(2) <= '1';
            s_reset_ram   <= '1';
         ------------------------------    
        end case;
end process;

proc_instruc: process(rst, estado_actual, uart_data, dat_ready, instruccion)
    begin
        pulso_dir <= '0';
        pulso_m1  <= '0';
        pulso_m2  <= '0';
        pulso_m3  <= '0';
        pulso_a   <= '0';
        pulso_sobel <= '0';
        if rst='1' then
           pulso_dir <= '0';
           pulso_m1  <= '0';
           pulso_m2  <= '0';
           pulso_m3  <= '0';
           pulso_a   <= '0';
           pulso_sobel <= '0';
        elsif (estado_actual = inicio or estado_actual = ajuste) and dat_ready = '1' then
            case instruccion is
               when "10000000" => --direccion
                    pulso_m1  <= '0';
                    pulso_m2  <= '0';
                    pulso_m3  <= '0';
                    pulso_a   <= '0';
                    pulso_dir <= '1';
                    pulso_sobel <= '0';
                when "11000000" =>  --movimiento todos los motores
                    pulso_dir <= '0';
                    pulso_m1  <= '0';
                    pulso_m2  <= '0';
                    pulso_m3  <= '0';
                    pulso_a   <= '0';
                    pulso_sobel <= '1';
                when "10000001" => --movimiento motor1
                    pulso_dir <= '0';
                    pulso_m1  <= '1';
                    pulso_m2  <= '0';
                    pulso_m3  <= '0';
                    pulso_a   <= '0';
                    pulso_sobel <= '0';
                when "10000010" =>  --movimiento motor2
                    pulso_dir <= '0';
                    pulso_m1  <= '0';
                    pulso_m2  <= '1';
                    pulso_m3  <= '0';
                    pulso_a   <= '0';
                    pulso_sobel <= '0';
                when "10000011" =>  --movimiento motor3
                    pulso_dir <= '0';
                    pulso_m1  <= '0';
                    pulso_m2  <= '0';
                    pulso_m3  <= '1';
                    pulso_a   <= '0';
                    pulso_sobel <= '0';
                when "10000100" =>  --movimiento todos los motores
                    pulso_dir <= '0';
                    pulso_m1  <= '0';
                    pulso_m2  <= '0';
                    pulso_m3  <= '0';
                    pulso_a   <= '1';
                    pulso_sobel <= '0';
                when others =>
                    pulso_dir <= '0';
                    pulso_m1  <= '0';
                    pulso_m2  <= '0';
                    pulso_m3  <= '0';
                    pulso_a   <= '0';
                    pulso_sobel <= '0';
                end case;
        end if;
end process;

------------------------------------------------------------------
proc_autoenfoque: process(rst, estado_actual, uart_data, dat_ready, instruccion, pulso_autoenfoque)
    begin
         pulso_autoenfoque <= '0';
        if rst='1' then
           pulso_autoenfoque <= '0';
        elsif (estado_actual = autoenfoque) and dat_ready = '1' then
            case instruccion is
               when "10000101" =>
                    pulso_autoenfoque  <= '1';
                when others =>
                    pulso_autoenfoque <= '0';
                end case;
        end if;
end process;

 --fin_manda_img se queda a 1 una vez llega al fin
Detec_pulso_autofocus: process(rst, clk)
    begin
        if rst='1' then
            reg1_af <='0';
            reg2_af <='0';
            reg1_m <='0';
            reg2_m <='0';
            reg1_m2 <='0';
            reg2_m2 <='0';
            reg1_m3 <='0';
            reg2_m3 <='0';
        elsif clk' event and clk='1' then  
            reg1_af <= fin_manda_img;---
            reg2_af <= reg1_af; 
            reg1_m <= s_fin_step_m1;---
            reg2_m <= reg1_m;
            reg1_m2 <= s_fin_step_m2;---
            reg2_m2 <= reg1_m2;
            reg1_m3 <= s_fin_step_m3;---
            reg2_m3 <= reg1_m3;
        end if;
    end process;
  pulso_af <='1' when (reg1_af = '1' and reg2_af ='0') and estado_actual = autoenfoque else '0'; 
  pulso_1 <='1' when (reg1_m = '1' and reg2_m ='0')  else '0';
  pulso_2 <='1' when (reg1_m2 = '1' and reg2_m2 ='0')  else '0';
  pulso_3 <='1' when (reg1_m3 = '1' and reg2_m3 ='0')  else '0';
 
 
biest_autoenfoque : process(rst, clk)
    begin
        if rst='1' then
            i_cap_img_aux <='0';
            inic_sum_aux <='0';
        elsif clk' event and clk='1' then
            if estado_actual = i_captura then
                i_cap_img_aux <='1';
                inic_sum_aux <='0';
                
            elsif estado_actual = i_manda then
                i_cap_img_aux <='1';
                inic_sum_aux <='0';
               
            elsif estado_actual = autoenfoque then
            
               if pulso_autoenfoque = '1' then
                  i_cap_img_aux <= not i_cap_img_aux;
                  inic_sum_aux <='1';
               elsif pulso_af = '1' or s_fin_step_m1= '1' then
               --elsif pulso_af = '1' then
                  i_cap_img_aux <= not i_cap_img_aux;
                  inic_sum_aux <='0';
               else
                  i_cap_img_aux <= i_cap_img_aux;
                  inic_sum_aux <='0';
               end if;
            
            else
                i_cap_img_aux <= '0';
                inic_sum_aux <='0';
            end if;
      end if;
    end process;  
 i_cap_img <= i_cap_img_aux; 
inic_sum <= '1' when (pulso_1 = '1' and estado_actual = autoenfoque) else inic_sum_aux;
------------------------------------------------------------------
     
biest_direccion : process(rst, clk)
    begin
        if rst='1' then
            i_dir_aux <='0';
        elsif clk' event and clk='1' then
        
            if estado_actual = inicio then
               if pulso_dir = '1' then
                  i_dir_aux <= not i_dir_aux;
               else
                  i_dir_aux <= i_dir_aux;
               end if;
               
            elsif estado_actual = home then 
                  i_dir_aux <= '1';
            
            elsif estado_actual = ajuste then
               if pulso_dir = '1' or s_e_ajuste = '1' then
                  i_dir_aux <= not i_dir_aux;
               else
                  i_dir_aux <= i_dir_aux;
               end if;
               
            elsif estado_actual = autoenfoque then ----
                  i_dir_aux <= '0';
               
            elsif estado_actual = maximo then -- dir descendente
                  i_dir_aux <= '1';
                  
            else
                  i_dir_aux <= i_dir_aux;
            end if;
      end if;
    end process;  
 i_dir <= i_dir_aux;
------------------------------------------------------------------
     
biest_sobel : process(rst, clk)
    begin
        if rst='1' then
            i_sobel <='0';
        elsif clk' event and clk='1' then
        
            if estado_actual = inicio then
               if pulso_sobel = '1' then
                  i_sobel <= not i_sobel;
               else
                  i_sobel <= i_sobel;
               end if;
               
            elsif estado_actual = home then 
                  i_sobel <= '1';
            elsif estado_actual = ajuste then
                  i_sobel <= '1';
            elsif estado_actual = autoenfoque then 
                  i_sobel <= '1';
            elsif estado_actual = maximo then 
                  i_sobel <= '0';
            elsif estado_actual = final then
                  i_sobel <= '0';
            else
                  i_sobel <= i_sobel;
            end if;
      end if;
    end process;  
 aux_sobel_h <= i_sobel;
------------------------------------------------------------------
 
 mov_motor1:process(rst, clk)
 -- proceso que habilita el motor 1 en función del estado y las diferentes señales
    begin
        if rst = '1' then
          i_motor_m1_aux <= '0';
        elsif clk'event and clk='1' then
        
          if estado_actual = inicio then
             if pulso_m1 = '1' or pulso_a = '1' then
                i_motor_m1_aux <= not i_motor_m1_aux;
             else
                i_motor_m1_aux <= i_motor_m1_aux;
             end if;
             
          elsif estado_actual = home then
             if s_e_ajuste = '1' then   
                i_motor_m1_aux <= '0';
             else
                i_motor_m1_aux <= '1';
             end if;
             
          elsif estado_actual = maximo then
             if  s_fin_c_maximo = '1' then   
                i_motor_m1_aux <= '0';
             else
                i_motor_m1_aux <= '1';
             end if;
                
          elsif estado_actual = ajuste then
             if pulso_m1 = '1' or pulso_a = '1' or s_fin_step_m1 = '1' then
                i_motor_m1_aux <= not i_motor_m1_aux;
             else
                i_motor_m1_aux <= i_motor_m1_aux;
             end if;
                
            elsif estado_actual = autoenfoque then
             if  pulso_af = '1' or s_fin_step_m1 = '1' then
                 i_motor_m1_aux <= not i_motor_m1_aux;
             else
                 i_motor_m1_aux <= i_motor_m1_aux;
             end if;
             
          else
                i_motor_m1_aux <= '0';
          end if;
        end if;
  end process;
  i_motor_m1 <= i_motor_m1_aux;
  
 cnt_steps_m1: process(rst, clk)
 -- proceso para determinar cuando se realiza una revolución 
    begin 
        if rst='1' then
            cuenta_step_m1 <= 0;
        elsif clk' event and clk='1' then
            if s_funciona_m1 = '1' and (estado_actual = ajuste or estado_actual = autoenfoque or estado_actual = maximo) then
               
                 if cuenta_step_m1 = fin_cuenta_step-1 then
                    cuenta_step_m1 <= 0;
                 else
                    cuenta_step_m1 <= cuenta_step_m1 +1;
                end if;
                
           end if;
      end if;
    end process; 
 s_fin_step_m1 <= '1' when (cuenta_step_m1 = fin_cuenta_step-1) else '0'; 
 

cnt_rev_relativo_m1: process(rst, clk)
    begin
        if rst='1' then
            cuenta_af <= (others => '0');
        elsif clk' event and clk='1' then
        
            if estado_actual = autoenfoque then
               if pulso_af = '1' then
                  cuenta_af <= cuenta_af +1;
               else
                  cuenta_af <= cuenta_af;
               end if;
            
            elsif estado_actual = maximo then
               if pulso_1 = '1' then 
                  cuenta_af <= cuenta_af -1;
               else
                  cuenta_af <= cuenta_af;
               end if;
               
            elsif estado_actual = ajuste then
                  cuenta_af <= (others => '0');
            else 
                  cuenta_af <= cuenta_af;
          end if;
      end if;
    end process;   
 s_fin_cont_af <= '1' when estado_actual = autoenfoque and (cuenta_af = 3) else '0';   
 s_fin_c_maximo <= '1' when estado_actual = maximo and (cuenta_af = unsigned(pos_maximo)+1) else '0';      
 
-- Cuenta de revoluciones absoluto
cnt_rev_abs_m1: process(rst, clk)
    begin
        if rst='1' then
            c_rev_abs_aux_m1 <= (others => '0');
        elsif clk' event and clk='1' then
            if (estado_actual = ajuste or estado_actual = autoenfoque or estado_actual = maximo or estado_actual = inicio) then 
            
                if i_dir_aux = '0' and pulso_1 = '1' then   
                       c_rev_abs_aux_m1 <= c_rev_abs_aux_m1 + 1; 
                elsif i_dir_aux = '1' and pulso_1 = '1' then
                       c_rev_abs_aux_m1 <= c_rev_abs_aux_m1 - 1;
                end if;

            elsif estado_actual = inicio then
                  c_rev_abs_aux_m1 <= (others => '0');
                  
            else 
                  c_rev_abs_aux_m1 <= c_rev_abs_aux_m1;
            end if;
          
        end if;
    end process;  
 c_rev_abs_m1 <= std_logic_vector(c_rev_abs_aux_m1);  
   
---------------------      
        
 mov_motor2:process(rst, clk)
    begin
        if rst = '1' then
          i_motor_m2_aux <= '0';
        elsif clk'event and clk='1' then
        
          if estado_actual = inicio then
             if pulso_m2 = '1' or pulso_a = '1' then
                i_motor_m2_aux <= not i_motor_m2_aux;
             else
                i_motor_m2_aux <= i_motor_m2_aux;
             end if;
             
          elsif estado_actual = home then
             if s_e_ajuste = '1' then   
                i_motor_m2_aux <= '0';
             else
                i_motor_m2_aux <= '1';
             end if;
             
          elsif estado_actual = maximo then
             if  s_fin_c_maximo = '1' then   
                i_motor_m2_aux <= '0';
             else
                i_motor_m2_aux <= '1';
             end if;
             
          elsif estado_actual = ajuste then
             if pulso_m2 = '1' or pulso_a = '1' or s_fin_step_m2 = '1' then
                i_motor_m2_aux <= not i_motor_m2_aux;
             else
                i_motor_m2_aux <= i_motor_m2_aux;
             end if;
                
            elsif estado_actual = autoenfoque then
             if  pulso_af = '1' or s_fin_step_m2 = '1' then
                 i_motor_m2_aux <= not i_motor_m2_aux;
             else
                 i_motor_m2_aux <= i_motor_m2_aux;
             end if;
                
          else
                i_motor_m2_aux <= '0';
          end if;
        end if;
  end process;
  i_motor_m2 <= i_motor_m2_aux;
 
 cnt_steps_m2: process(rst, clk)
    begin 
        if rst='1' then
            cuenta_step_m2 <= 0;
        elsif clk' event and clk='1' then
            if s_funciona_m2 = '1' and (estado_actual = ajuste or estado_actual = autoenfoque or estado_actual = maximo)  then
                
                 if cuenta_step_m2 = fin_cuenta_step-1 then
                    cuenta_step_m2 <= 0;
                 else
                    cuenta_step_m2 <= cuenta_step_m2 +1;
                end if;
                
           end if;
      end if;
    end process; 
 s_fin_step_m2 <= '1' when (cuenta_step_m2 = fin_cuenta_step-1) else '0'; 
   
cnt_rev_abs_m2: process(rst, clk)
    begin
        if rst='1' then
            c_rev_abs_aux_m2 <= (others => '0');
        elsif clk' event and clk='1' then
            if (estado_actual = ajuste or estado_actual = autoenfoque or estado_actual = maximo or estado_actual = inicio) then 
                if i_dir_aux = '0' and pulso_2 = '1' then
                       c_rev_abs_aux_m2 <= c_rev_abs_aux_m2 + 1;
                elsif i_dir_aux = '1' and pulso_2 = '1' then
                       c_rev_abs_aux_m2 <= c_rev_abs_aux_m2 - 1;
                end if;

            elsif estado_actual = inicio then
                  c_rev_abs_aux_m2 <= (others => '0');
                  
            else 
                  c_rev_abs_aux_m2 <= c_rev_abs_aux_m2;
            end if;
          
        end if;
    end process;  
 c_rev_abs_m2 <= std_logic_vector(c_rev_abs_aux_m2);    
   
---------------------   
   
 mov_motor3:process(rst, clk)
    begin
        if rst = '1' then
          i_motor_m3_aux <= '0';
        elsif clk'event and clk='1' then
        
          if estado_actual = inicio then
             if pulso_m3 = '1' or pulso_a = '1' then
                i_motor_m3_aux <= not i_motor_m3_aux;
             else
                i_motor_m3_aux <= i_motor_m3_aux;
             end if;
             
          elsif estado_actual = home then
             if s_e_ajuste = '1' then   
                i_motor_m3_aux <= '0';
             else
                i_motor_m3_aux <= '1';
             end if;
                             
          elsif estado_actual = maximo then
             if  s_fin_c_maximo = '1' then   
                i_motor_m3_aux <= '0';
             else
                i_motor_m3_aux <= '1';
             end if;

          elsif estado_actual = ajuste then
             if pulso_m3 = '1' or pulso_a = '1' or s_fin_step_m3 = '1' then
                i_motor_m3_aux <= not i_motor_m3_aux;
             else
                i_motor_m3_aux <= i_motor_m3_aux;
             end if;
                --M1¿?¿?
            elsif estado_actual = autoenfoque then
             if  pulso_af = '1' or s_fin_step_m3 = '1' then
                 i_motor_m3_aux <= not i_motor_m3_aux;
             else
                 i_motor_m3_aux <= i_motor_m3_aux;
             end if;
                
          else
                i_motor_m3_aux <= '0';
          end if;
        end if;
  end process;
  i_motor_m3 <= i_motor_m3_aux;
  
 cnt_steps_m3: process(rst, clk)
    begin 
        if rst='1' then
            cuenta_step_m3 <= 0;
        elsif clk' event and clk='1' then
            if s_funciona_m3 = '1' and (estado_actual = ajuste or estado_actual = autoenfoque or estado_actual = maximo) then
               
                 if cuenta_step_m3 = fin_cuenta_step-1 then
                    cuenta_step_m3 <= 0;
                 else
                    cuenta_step_m3 <= cuenta_step_m3 +1;
                end if;
                
           end if;
      end if;
    end process; 
 s_fin_step_m3 <= '1' when (cuenta_step_m3 = fin_cuenta_step-1) else '0'; 
  
cnt_rev_abs_m3: process(rst, clk)
    begin
        if rst='1' then
            c_rev_abs_aux_m3 <= (others => '0');
        elsif clk' event and clk='1' then
            if (estado_actual = ajuste or estado_actual = autoenfoque or estado_actual = maximo or estado_actual = inicio) then
                
                if i_dir_aux = '0' and pulso_3 = '1' then
                       c_rev_abs_aux_m3 <= c_rev_abs_aux_m3 + 1;
                elsif i_dir_aux = '1' and pulso_3 = '1'  then
                       c_rev_abs_aux_m3 <= c_rev_abs_aux_m3 - 1;
                end if;

            elsif estado_actual = home then
                  c_rev_abs_aux_m3 <= (others => '0');
                  
            else 
                  c_rev_abs_aux_m3 <= c_rev_abs_aux_m3;
            end if;
          
        end if;
    end process;  
 c_rev_abs_m3 <= std_logic_vector(c_rev_abs_aux_m3);  
 
 
 
end behav;
