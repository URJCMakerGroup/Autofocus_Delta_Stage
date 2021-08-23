----------------------------------------------------------------------------------
-- Engineer: Carlos Sanchez
-- Create Date: 23.05.2021 18:11:59
-- Design Name: Sumador
-- Module Name: comparador - Behavioral
-- Project Name: 
-- Description: 
--  constantes para el modulos sumador
------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package pkg_sum is
    --imagen de 320x240, 76800 píxeles en total
    constant c_fin_pxl: integer := 76800-1;
    
    -- constantes de la memoria bram que almacena los resultados del sumador
    constant bram_num: natural:= 16; -- numero de direcciones de memoria (ej 10: de 0 a 9)
    constant bram_width: natural := 25-1; -- ancho de palabra
    constant bram_addr: natural := 4-1;  -- direcciones de memoria

end pkg_sum;
