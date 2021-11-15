library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity CTRL is
   port(clk:in std_logic;
		  rst:in std_logic;		  
	     sign:in std_logic;  --累加器AC的符号位
		  Instr:in std_logic_vector(15 downto 0);  --拿到指令
  		  RorW:out std_logic;  --关于AC的读写信号,0读入,1写出
	     Flag:out std_logic_vector(3 downto 0);	--每位充当各部分的时钟	  
		  address:out std_logic_vector(7 downto 0);  --给出数据地址或指令地址
		  jump:out std_logic);  --关于PC的跳转信号,0不跳,1跳转
end CTRL;

architecture behav of CTRL is

signal status:std_logic_vector(1 downto 0):="00";	--获取下个指令地址、取指令、获取数据、指令译码执行四个状态

begin

process(clk,status,rst)  --状态转换
begin
   if rising_edge(clk)then
		if rst='1' then
			status <= "00";
	   elsif(status="11")then
			status <= "00";
		else
			status <= status+1;
		end if;
	end if;
end process;

process(rst,status)	--各状态对应的时钟标志
begin
	if rst='1' then
		Flag <= "0000";
	else
		case status is
		when "00" => Flag<="0001";
		when "01" => Flag<="0010";
		when "10" => Flag<="0100";
		when "11" => Flag<="1000";
		when others => Flag<="0000";
		end case;
	end if;
end process;

process(Instr,rst)  --更新地址、读写信号、跳转信号
begin
	if rst='1' then
	RorW <= 'Z';jump <= '0';	--复位状态时分别置为'z'和'0'
	else
	case Instr(15 downto 8) is
	when "00000000" => 	--ADD
		RorW <= '0';		--AC<=AC+adress中的值 读
		jump <= '0';
		address <= Instr(7 downto 0);
	when "00000001" => 	--STORE
		RorW <= '1';		--adress中的值<=AC 写
		jump <= '0';
		address <= Instr(7 downto 0);
	when "00000010" => 	--LOAD
		RorW <= '0';		--AC<=address中的值 读
		jump <= '0';
		address <= Instr(7 downto 0);
	when "00000011" => 	--JUMP
		RorW <= 'Z';		--AC不读不写
		jump <= '1';
		address <= Instr(7 downto 0);	
	when "00000100" => 	--JNEG
		RorW <= 'Z';		--AC不读不写
		if (sign='1')then	--AC<0,跳转,PC<=address
			jump <= '1';
			address <= Instr(7 downto 0);
		else
			jump <= '0';
		end if;
	when others => 
		RorW <= 'Z';		--AC不读不写
		jump <= '0';
	end case;
	end if;
end process;

end behav;