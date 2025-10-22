library ieee;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;

-- Procedure to collect 4 x 16-bit samples from out_fp_o into one 64-bit frame
procedure load_result(
  signal clk      : in std_logic;
  signal out_fp_o : in std_logic_vector(15 downto 0);
  variable result : out std_logic_vector(63 downto 0)
) is
    variable temp : std_logic_vector(63 downto 0) := (others => '0');
begin
  for i in 0 to 3 loop
    temp := temp(47 downto 0) & out_fp_o;
    wait until rising_edge(clk);
  end loop;
  result := temp;
end procedure;