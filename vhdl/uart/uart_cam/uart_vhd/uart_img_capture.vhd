----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.04.2021 11:19:54
-- Design Name: 
-- Module Name: uart_img_capture - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.ov7670_pkg.all;


entity uart_img_capture is
  Port ( 
    rst      : in   std_logic;    -- FPGA reset
    clk      : in   std_logic;    -- FPGA clock
 btn_save    : in   std_logic;    -- FPGA clock
    
    proc_we  : in  std_logic;    -- write enable
    proc_pxl : in  std_logic_vector(c_nb_buf_gray-1 downto 0);--processed pixel
    proc_addr: in  std_logic_vector(c_nb_img_pxls-1 downto 0); --address
    
    proc_we_img  : in  std_logic;    -- write enable
    proc_pxl_img : in  std_logic_vector(c_nb_buf_gray-1 downto 0);--processed pixel
    proc_addr_img: in  std_logic_vector(c_nb_img_pxls-1 downto 0) --address
  
  );
end uart_img_capture;

architecture Behavioral of uart_img_capture is
  signal cnt_pxl     : unsigned(c_nb_img_pxls-1 downto 0);
  signal pxl_in_num  : unsigned(c_nb_img_pxls-1 downto 0);
begin

  -- memory address count
  P_mem_cnt: process(rst, clk)
  begin
    if rst = '1' then
      cnt_pxl       <= (others => '0');
      pxl_in_num    <= (others => '0');
      btn_save     <= '0'; 
    elsif clk'event and clk='1' then
      btn_save     <= '1'; -- starts receiving one clock cycle later
      -- data from original memory received one clock cycle later
      pxl_in_num <= cnt_pxl;
      if end_pxl_cnt = '1' then
        cnt_pxl  <= (others => '0');
      else
        cnt_pxl  <= cnt_pxl + 1;
      end if;
    end if;
  end process;

  end_pxl_cnt <= '1' when cnt_pxl = c_img_pxls-1 else '0';
  orig_addr   <= std_logic_vector(cnt_pxl);

end Behavioral;
