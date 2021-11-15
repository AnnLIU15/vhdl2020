library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity AC is
   port(ACclk:in std_logic;
		  rst:in std_logic;
	     InData:in std_logic_vector(7 downto 0);
		  sign:out std_logic;		--累加器输出的符号位
		  OutData:out std_logic_vector(7 downto 0));  
end AC;

architecture behav of AC is
begin

process(ACclk,rst)
begin
	if rst='1' then
		Outdata <= "00000000";
   elsif rising_edge(ACclk) then
		OutData <= InData;
		if(InData(7)='1')then  --判断数值正负
			sign<='1';
		else 
			sign<='0';
		end if;
	end if;
end process;

end behav;