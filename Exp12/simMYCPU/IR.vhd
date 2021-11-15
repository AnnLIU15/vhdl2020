library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity IR is

	generic(
	dlen:integer:=8;--数据长度8位
	OpAddr:integer:=16
	);
   port(
	EN:in std_logic;
	opin:in std_logic_vector(OpAddr-1 downto 0);
	opout:out std_logic_vector(dlen-1 downto 0);
	adout:out std_logic_vector(dlen-1 downto 0)
	);
end entity;

architecture bev of IR is
signal opcodeseg:std_logic_vector(OpAddr-1 downto 0):=(others=>'Z');
begin

	
	process(EN,opin)
	begin
		if rising_edge(EN) then
			opcodeseg<=opin;
		end if;
	end process;
	opout<=opcodeseg(OpAddr-1 downto dlen);
	adout<=opcodeseg(dlen-1 downto 0);
end architecture;