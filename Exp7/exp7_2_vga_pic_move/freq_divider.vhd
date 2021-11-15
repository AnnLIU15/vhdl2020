library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity freq_divider is
	generic(
		COUNT_MAX:natural);
	port(
		clk_in:in std_logic;
		clk_out:out std_logic);
end freq_divider;

architecture behav of freq_divider is
signal count:integer range 0 to COUNT_MAX-1;
signal toggle:std_logic;
begin
	process(clk_in)
	begin
		if clk_in'event and clk_in='1' then
			if count=COUNT_MAX-1 then
				count<=0;
				toggle<='1' and not toggle;
			else
				count<=count+1;
			end if;
		end if;
	end process;
	clk_out<=toggle;
end behav;