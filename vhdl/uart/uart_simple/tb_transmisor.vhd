
--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:37:30 12/06/2006
-- Design Name:   UART_TX
-- Module Name:   C:/user/felipe/xu/curso0607/practicas/transmisor_practicas/tb_transmisor.vhd
-- Project Name:  transmisor_practicas
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: UART_TX
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY tb_transmisor_vhd IS
  generic (
    gFrecClk      : integer := 100000000;   --100MHz
    gBaud         : integer := 9600         --9600bps
  ); 
END tb_transmisor_vhd;

ARCHITECTURE behavior OF tb_transmisor_vhd IS 

  constant cPeriodoClk       : time := ((10**9)/gFrecClk) * 1 ns;
  constant cMitadPeriodoClk  : time := cPeriodoClk/2;
  constant cFinCuenta        : natural := gFrecClk/gBaud -1;
  constant cPeriodoBaud      : time := cFinCuenta * cPeriodoClk;
  constant cMitadPeriodoBaud : time := cPeriodoBaud/2;


  function a_texto (arg : natural) return string is
  begin
    case arg is
      when 0 => return "0";
      when 1 => return "1";
      when 2 => return "2";
      when 3 => return "3";
      when 4 => return "4";
      when 5 => return "5";
      when 6 => return "6";
      when 7 => return "7";
      when others => return "?";
    end case;
  end;

  -- Component Declaration for the Unit Under Test (UUT)
  COMPONENT UART_TX
  generic (
    gFrecClk      : integer := 100000000;   --100MHz
    gBaud         : integer := 9600         --9600bps
  ); 
  PORT(
    rst : IN std_logic;
    Clk : IN std_logic;
    Transmite : IN std_logic;
    DatoTxIn : IN std_logic_vector(7 downto 0);          
    Transmitiendo : OUT std_logic;
    DatoSerieOut : OUT std_logic
    );
  END COMPONENT;

  --Inputs
  SIGNAL rt :  std_logic := '0';
  SIGNAL Clk :  std_logic := '0';
  SIGNAL Transmite :  std_logic := '0';
  SIGNAL DatoTxIn :  std_logic_vector(7 downto 0) := (others=>'0');

  --Outputs
  SIGNAL Transmitiendo :  std_logic;
  SIGNAL DatoSerieOut :  std_logic;

  signal FinSimulacion : std_logic := '0';
  signal FinEnvio : std_logic := '0';

  type vector_datos is array (natural range <>) of std_logic_vector(7 downto 0);
  constant DatosTest : vector_datos := ("10001101","01010101","11001010", "00101101");
  signal numenvio : natural := 0;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: UART_TX
  generic map (
    gFrecClk => gFrecClk,
    gBaud    => gBaud
  )
  PORT MAP(
    rst => rst,
    Clk => Clk,
    Transmite => Transmite,
    DatoTxIn => DatoTxIn,
    Transmitiendo => Transmitiendo,
    DatoSerieOut => DatoSerieOut
  );

  PClk:Process
  begin
    Clk <= '1';
    wait for 5 ns; -- 100 MHz: 5ns + 5ns
    Clk <= '0';
    wait for 5 ns;
    if FinSimulacion = '1' then
      wait;        -- se para la generacion de reloj
    end if;
  end process;

  PReset:Process
  begin
    rst <= '1'; 
    wait for 7 ns; -- reset asincrono
    rst <= '0';
    wait for 15 ns;
    rst <= '1';
    wait;           -- Fin
  end process;

  Estimulos : PROCESS
  BEGIN
    Transmite <= '0';
    DatoTxIn <= (others => '0');   -- Es lo mismo que todo a cero
    wait for 100 ns;
    wait until Clk'event and Clk='1';
    --- PRIMER ENVIO (envio 0)
    Transmite <= '1';                  
    DatoTxIn <= DatosTest(0);
    wait until Clk'event and Clk='1';  -- Quitamos para el siguiente flanco
    Transmite <= '0';
    DatoTxIn <= (others => '0');
    wait until Transmitiendo = '0';    -- Esperamos a que deje de transmitir
    -- SEGUNDO ENVIO (envio 1)
    Transmite <= '1';
    DatoTxIn <= DatosTest(1);
    wait until Clk'event and Clk='1';  -- Quitamos para el siguiente flanco
    Transmite <= '1';
    DatoTxIn <= (others => '0');       -- A ver que pasa si dejamos transmite=1
                                       -- Y cambiamos el dato
    wait for 100 ns;
    Transmite <= '0';
    DatoTxIn <= (others => '0');
    wait until Transmitiendo = '0';    -- Esperamos a que deje de transmitir
    DatoTxIn <= NOT DatosTest(1);      -- Ponemos otro dato, pero transmite=0
    Transmite <= '0';
    wait until Clk'event and Clk='1';   -- Esperamos a que deje de transmitir
    -- TERCER ENVIO (envio 2)
    Transmite <= '1';
    DatoTxIn <= DatosTest(2);
    wait until Clk'event and Clk='1';  -- Esperamos a que deje de transmitir
    Transmite <= '0';
    DatoTxIn <= NOT DatosTest(2);      -- Ponemos otro numero
    wait for 100 ns;
    Transmite <= '1';                  -- Ponemos otro transmite
    DatoTxIn <= NOT DatosTest(2);      -- que no lo deberia transmitir
    wait for 100 ns;
    Transmite <= '0';
    DatoTxIn <= (others => '0');   -- Es lo mismo que todo a cero
    wait for 30 ns;
    ---------------- CUARTO ENVIO (envio 3) -----------------------------------
    wait until Transmitiendo = '0';    -- Esperamos a que deje de transmitir
    wait for cMitadPeriodoBaud;      -- 
    wait for cMitadPeriodoBaud/2;      -- 
    Transmite <= '1';
    DatoTxIn <= DatosTest(3);
    wait until Clk'event and Clk='1';  -- Esperamos a que deje de transmitir
    Transmite <= '0';
    DatoTxIn <= (others => '0');
    FinEnvio <= '1';
    wait;                          -- Fin
  END PROCESS;

  Receptor : PROCESS         -- Este proceso se encarga de recibir
    variable  numbit : natural;
  BEGIN                       -- Y comprobar que lo recibido es correcto
    -- Esperamos al comienzo del envio
    wait until DatoSerieOut'event and DatoSerieOut = '0';
    -- empieza a enviar, nos situamos a la mitad del ciclo
    -- para evitar errores. Como cada dato se envia durante unos 104us
    -- (9600Hz), esperamos 52us
    wait for cMitadPeriodoBaud;
    -- Ahora debemos estar a la mitad del bit de inicio
    -- Por tanto DatoSerieOut debe seguir siendo = 0
    -- lo comprobamos con ASSERT
    assert DatoSerieOut = '0'  -- Si no se cumple da el aviso
      report "Fallo en el bit de inicio del primer envio"
      severity ERROR;  -- niveles de severidad: NOTE,WARNING,ERROR,FAILURE
    numbit := 0;
    for i in 0 to 7 loop
      wait for cPeriodoBaud;
      assert DatoSerieOut = DatosTest(numenvio)(numbit)
        report "Fallo en el bit " & a_texto(numbit) & "del primer envio"
        severity ERROR;  -- niveles de severidad: NOTE,WARNING,ERROR,FAILURE
      numbit := numbit+1;
    end loop;
    wait for cPeriodoBaud; -- bit de fin
      assert DatoSerieOut = '1' 
        report "Fallo en el bit de fin"
        severity ERROR;
    numenvio <= numenvio + 1;
    if FinEnvio = '1' then  -- si ya no hay mas envios paramos la simulacion
      wait for cPeriodoBaud; 
      FinSimulacion <= '1';
      wait;
    end if;
  end process;


END;
