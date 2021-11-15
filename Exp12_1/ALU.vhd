library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity ALU is
   port(rst:in std_logic;
		  ACdata:in std_logic_vector(7 downto 0);  --AC提供的数据
	     RAMdata:in std_logic_vector(7 downto 0);  --内存中存储的数据
	     Instr:in std_logic_vector(15 downto 0);  --指令
		  Dataout:out std_logic_vector(7 downto 0));  
end ALU;

architecture behav of ALU is

signal tmpinstr:std_logic_vector(15 downto 0);

begin

process(ACdata,RAMdata,Instr,rst)
begin
	if rst ='1' then
		Dataout <= "00000000";
	elsif(Instr(15 downto 8)="00000000")then  --ADD
		Dataout <= ACdata + RAMdata;
	elsif(Instr(15 downto 8)="00000001")then  --STORE
		Dataout<=ACdata;
	elsif(Instr(15 downto 8)="00000010")then  --LOAD
		Dataout <= RAMdata;
	else
		Dataout<=ACdata;
	end if;
end process;

end behav;