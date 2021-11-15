library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity PC is
   port(PCclk:in std_logic;	--PC时钟
		  rst:in std_logic;		--复位
		  jump:in std_logic;		--跳转信号
		  Inaddress:in std_logic_vector(7 downto 0);
		  Outaddress:out std_logic_vector(7 downto 0));
end PC;

architecture behav of PC is

signal tmpaddress:std_logic_vector(7 downto 0):="00000000";

begin

process(PCclk,rst)
begin
	if rst='1' then
	tmpaddress<="00001000";				--复位时将地址置于一个特殊位置
												--便于复位状态结束时重新指向地址0
	elsif rising_edge(PCclk) then
		if tmpaddress = "00001000" then
			tmpaddress<="00000000";
		else
			if(jump='1')then		
				tmpaddress<=Inaddress;		--跳转
			else
				tmpaddress<=tmpaddress+1;	--地址加一指向下一个位置
			end if;
		end if;
	end if;
end process;

Outaddress<=tmpaddress;

end behav;