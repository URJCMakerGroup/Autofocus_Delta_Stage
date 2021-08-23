library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_uart_rx is
  port (
    rst : in std_logic;
    clk : in std_logic;
    
    uart_rx    : in std_logic;
    led_estado : out std_logic_vector(3-1 downto 0);
    s_e_ajuste : in  std_logic;
   
    s_funciona_m1 : in  std_logic;
    s_funciona_m2 : in  std_logic;
    s_funciona_m3 : in  std_logic;
    
    i_motor_m1 : out  std_logic;
    i_motor_m2 : out  std_logic;
    i_motor_m3 : out  std_logic;
    i_dir      : out  std_logic;
--    i_sobel       : out  std_logic_vector(2-1 downto 0);
    
    c_rev_abs_m1  : out std_logic_vector(4-1 downto 0); 
    c_rev_abs_m2  : out std_logic_vector(4-1 downto 0); 
    c_rev_abs_m3  : out std_logic_vector(4-1 downto 0);
    
    
      pos_maximo  : in std_logic_vector(4-1 downto 0);  
    
    s_env_af      : in std_logic;
    fin_manda_img : in std_logic;
    i_cap_img     : out std_logic;
    inic_sum      : out std_logic;
    i_manda_img   : out std_logic
  );
end top_uart_rx;

architecture struct of top_uart_rx is

  signal uart_receiving : std_logic;
  signal uart_dat_ready : std_logic;
  signal uart_data      : std_logic_vector(8-1 downto 0);

begin

  i_uart_rx : entity work.uart_rx
    generic map (
      G_FREQ_CLK => 10**8,
      G_BAUD => 115200
    )
    port map (
               clk => clk,
               rst => rst,
           uart_rx => uart_rx,
         receiving => uart_receiving,
         dat_ready => uart_dat_ready,
             dat_o => uart_data
    );

  i_proc_serie: entity work.proc_serie
    port map (
               clk => clk,
               rst => rst,
         dat_ready => uart_dat_ready,
         uart_data => uart_data,
        led_estado => led_estado,
        s_e_ajuste => s_e_ajuste,
        
     s_funciona_m1 => s_funciona_m1,
     s_funciona_m2 => s_funciona_m2,
     s_funciona_m3 => s_funciona_m3,
     
        i_motor_m1 => i_motor_m1,
        i_motor_m2 => i_motor_m2,
        i_motor_m3 => i_motor_m3,
--           i_sobel => i_sobel,
             i_dir => i_dir,
      pos_maximo => pos_maximo,
             
      c_rev_abs_m1 => c_rev_abs_m1,
      c_rev_abs_m2 => c_rev_abs_m2,
      c_rev_abs_m3 => c_rev_abs_m3,
             
     fin_manda_img => fin_manda_img,
         i_cap_img => i_cap_img,
          inic_sum => inic_sum,
       i_manda_img => i_manda_img
    );

end struct;

