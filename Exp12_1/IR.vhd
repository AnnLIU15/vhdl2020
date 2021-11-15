library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity IR is
   port(IRclk:in std_logic;
	     Incode:in std_logic_vector(15 downto 0);
		  Outcode:out std_logic_vector(15 downto 0));
end IR;

architecture behav of IR is
begin

process(IRclk)
begin
   if rising_edge(IRclk) then
	   Outcode<=Incode;
	end if;
end process;

end behav;