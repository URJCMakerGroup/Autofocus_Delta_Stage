library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.UTIL_PKG.ALL;

entity uart_rx is
  generic (
    G_FREQ_CLK  : integer := 10**8;  -- clock frequency
    G_BAUD      : integer := 9600    -- baud
  );
  port (
    rst        : in  std_logic;
    clk        : in  std_logic;
    uart_rx    : in  std_logic;
    receiving  : out  std_logic;
    dat_ready  : out  std_logic;
    dat_o      : out  std_logic_vector(8-1 downto 0)
  );
end uart_rx;

architecture behav of uart_rx is

  type uart_states is (E_IDLE, E_INIT_BIT, E_DATA_BITS, E_END_BIT);
  signal e_act, e_nxt : uart_states; -- actual state, next state

  -- end of the counter of the frequency divider
  constant C_DIV_END : natural := G_FREQ_CLK/G_BAUD-1;
  constant C_HALFDIV_END: natural := C_DIV_END/2;
  
  signal baud_pulse : std_logic;
  signal halfbaud_pulse : std_logic;
  signal rxdata_rg : std_logic;
  signal en_divfrq: std_logic;
  signal shift: std_logic;
  
  constant NB_DIVFRQ : natural := log2i(C_DIV_END-1)+1;
  signal divfrq : unsigned (NB_DIVFRQ-1 downto 0); -- frequency divider counter
  signal bit_cnt : unsigned (2 downto 0); -- count up to 7
  signal tmp_dat  : std_logic_vector (7 downto 0);  -- temporal data
  signal end_data_bits : std_logic;

begin

  p_seq_fsm: process(rst, clk)
  begin
    if rst = '1' then
      e_act <= E_IDLE;
    elsif clk'event and clk='1' then
      e_act <= e_nxt;
    end if;
  end process;


  p_comb_fsm: process (e_act, uart_rx, baud_pulse, halfbaud_pulse,
                       end_data_bits, rxdata_rg)
  begin
    e_nxt <= e_act;
    shift <= '0';
    en_divfrq <= '1';
    dat_ready <= '0';
    receiving <= '1';
    case e_act is
      when E_IDLE =>
        en_divfrq <= '0';
        receiving <= '0';
        if rxdata_rg = '0' then
           e_nxt <= E_INIT_BIT;
           en_divfrq <= '1';
           receiving <= '1';
        end if;
      when E_INIT_BIT =>
        if baud_pulse = '1' then
          e_nxt <= E_DATA_BITS;
         end if;
      when E_DATA_BITS =>
        if halfbaud_pulse = '1' then
          shift <= '1';
        end if;
        if end_data_bits = '1' then
          e_nxt <= E_END_BIT;
          dat_ready <= '1';
        end if;
       when E_END_BIT =>
          -- some times next sending is too fast, we dont wait until the end
        if halfbaud_pulse = '1' then
          e_nxt <= E_IDLE;
          en_divfrq <= '0';
        end if;
    end case;
  end process;
  
  p_divfrq: Process (rst, clk)
  begin
    if rst = '1' then
      divfrq <= (others => '0');
    elsif clk'event and clk='1' then
      if en_divfrq = '0' then -- counter disabled
        divfrq <= (others =>'0');
      else
        if baud_pulse = '1' then -- end of the count
          divfrq <= (others =>'0');
        else
          divfrq <= divfrq + 1;
        end if;
      end if;
    end if;
  end process;

  baud_pulse     <= '1'when divfrq = C_DIV_END-1 else '0';
  halfbaud_pulse <= '1'when divfrq = C_HALFDIV_END-1 else '0';

  p_reginput : Process (rst, clk)
  begin
    if rst = '1' then
      rxdata_rg <= '1';
    elsif clk'event and clk = '1' then
      rxdata_rg <= uart_rx;
    end if;
  end process;
  
  p_bitcount: Process (rst, clk)
  begin
    if rst = '1' then
      bit_cnt <= (others =>'0');
    elsif clk'event and clk='1' then
      if e_act = E_DATA_BITS then
        if end_data_bits = '1' then
          bit_cnt <= (others => '0');
        elsif baud_pulse = '1' then
          bit_cnt <= bit_cnt + 1;
        end if;
      else
        bit_cnt <= (others =>'0');
      end if;
    end if;
  end process;
  end_data_bits <= '1' when bit_cnt=7 and baud_pulse = '1' else '0';
  
  P_Despl: Process (rst, clk)
  begin
    if rst = '1' then
      tmp_dat <= (others => '0');
    elsif clk'event and clk = '1' then
      if shift = '1' then
        tmp_dat <= rxdata_rg & tmp_dat(7 downto 1);
      end if;
    end if;
  end process;

  -- only valid when dat_ready = '1'
  dat_o <= tmp_dat;

end behav;

