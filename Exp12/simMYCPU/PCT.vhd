library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



entity PCT is
	generic(
	dlen:integer:=8--数据长度8位
	);
	port(
	clk:in std_logic;
	RESET:IN STD_LOGIC;
	opCode:in std_logic_vector(dlen-1 downto 0);
	AccIn:in std_logic_vector(dlen-1 downto 0);
	inaddr:in std_logic_vector(dlen-1 downto 0);
	outaddr:out std_logic_vector(dlen-1 downto 0)
	);

end entity;


architecture bev of PCT is
signal outaddrseg:std_logic_vector(dlen-1 downto 0);
begin
	process(clk,RESET)
	begin
		IF RESET='1' THEN
			outaddrseg<=X"00";
		ELSIF rising_edge(clk) then
			if opCode=x"03" THEN 
				outaddrseg<=inaddr;
			ELSIF opCode=x"04" THEN
				IF AccIn(dlen-1)='1' then
					outaddrseg<=inaddr;
				ELSE
					outaddrseg<=outaddrseg+'1';
				END IF;
			ELSE
				if outaddrseg<x"ff" then
					outaddrseg<=outaddrseg+'1';
				else
					outaddrseg<=(others=>'0');
				END IF;
			end if;
		end if;
	end process;
	outaddr<=outaddrseg;
end architecture;