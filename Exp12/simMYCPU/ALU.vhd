library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;



entity ALU is
	generic(
	dlen:integer:=8--数据长度8位
	);
	port(
	clk:in std_logic;
	reset:in std_logic;
	op:in std_logic_vector(dlen-1 downto 0);
	Acc:in std_logic_vector(dlen-1 downto 0);			--累计器数据
	RamVal:in std_logic_vector(dlen-1 downto 0);			--*addr
	ALUout:out std_logic_vector(dlen-1 downto 0)
	);

end entity;


architecture bev of ALU is
signal tmpseg:std_logic_vector(dlen-1 downto 0);
begin
	process(clk,reset)
	begin
		if reset='1' then
			tmpseg<=x"00";
		elsif rising_edge(clk) then
		case op is
		when x"00"=>tmpseg<=Acc+RamVal;					-- 相加
		when x"01"=>tmpseg<=Acc;							-- 存储
		when x"02"=>tmpseg<=RamVal;						-- 加载
		when others=>
			tmpseg<=Acc;							-- 无效动作
		end case;
		end if;
	end process;
	ALUout<=tmpseg;								--输出
end architecture;