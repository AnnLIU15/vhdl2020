library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
entity keybord is		--键盘码获取部分，形成一个串行数据
port(
	  CLK: in std_logic;
	  RST: in std_logic;	--sw0复位
	  KBD_CLK: in std_logic;	--键盘时钟信号
	  KBD_DATA: in std_logic;	--键盘串行数据输入
	  scan_ready: out std_logic;	--扫描完成标志
	  scan_code: out std_logic_vector(7 downto 0)	--由键盘串行数据输入得到的扫描码
	  );
end entity keybord;

architecture behav of keybord is

signal flag,clk1: std_logic;	--flag为键盘时钟上升沿标志，clk1为二分频时钟
signal t1,t2: std_logic:='0';	--用于检测键盘时钟的上升沿
signal tmp_code: std_logic_vector(7 downto 0);
signal st: integer range 0 to 11; --扫描码为11比特,第12个状态表示未有输入

begin
	process(clk)	--二分频
	begin
		if rising_edge(clk) then
			clk1<= not clk1;
		end if;
	end process;
	
	process(rst,clk1,KBD_CLK)		--检测KBD_CLK的上升沿，flag为1则为上升沿
	begin
		if rst='1' then
			flag<='0';t1<='0';t2<='0';
		elsif rising_edge(clk1) then
			t1<=KBD_CLK;t2<=t1;
		end if;
		flag<= t1 and (not t2);
	end process;
		
	process(rst,clk1,KBD_DATA,flag)		--状态机每到kbd_clk上升沿切换状态并输出键盘数据到串行信号中
	begin
		if rst='1' then 
			st<=0;scan_ready<='0';
			tmp_code<="00000000";
		elsif rising_edge(clk1) then
			case st is
			when 0 => st<=1;
			when 1 => if flag='1' then 
						 st<=2;tmp_code(0)<=KBD_DATA;		--每经过一个比特的串行数据就经过一个状态，且该数据存到tem_code中
						 else st<=1;end if;
			when 2 => if flag='1' then 
						 st<=3;tmp_code(1)<=KBD_DATA;
						 else st<=2;end if;
			when 3 => if flag='1' then 
						 st<=4;tmp_code(2)<=KBD_DATA;
						 else st<=3;end if;
			when 4 => if flag='1' then 
						 st<=5;tmp_code(3)<=KBD_DATA;
						 else st<=4;end if;
			when 5 => if flag='1' then 
						 st<=6;tmp_code(4)<=KBD_DATA;
						 else st<=5;end if;
			when 6 => if flag='1' then 
						 st<=7;tmp_code(5)<=KBD_DATA;
						 else st<=6;end if;
			when 7 => if flag='1' then 
						 st<=8;tmp_code(6)<=KBD_DATA;
						 else st<=7;end if;
			when 8 => if flag='1' then 
						 st<=9;tmp_code(7)<=KBD_DATA;
						 else st<=8;end if;
			when 9 => if flag='1' then 
						 st<=10;
						 else st<=9;end if;
			when 10 => if flag='1' then 
						 st<=11;scan_ready<='1';	--到终止码，扫描完成标志置1
						 else st<=10;end if;
			when 11 => if flag='1' then 
						 st<=0;scan_ready<='0';	--空闲状态，等待下一个KBD_CLK到来进入下一个循环
						 else st<=11;end if;
			when others => st<=11;scan_ready<='0';
			end case;
		end if;
	end process;
	scan_code<=tmp_code;
end architecture behav;	

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;			
entity DEC_7SEG is		--译码部分，将键盘数据转换为的串行码输出到两位数码管
port(
	  Datain: in std_logic_vector(3 downto 0);
	  Dataout: out std_logic_vector(6 downto 0)
	  );
end entity DEC_7SEG;

architecture bahav1 of DEC_7SEG is

signal tmp: std_logic_vector(6 downto 0);

begin
	process(Datain)
	begin
		case Datain is
		when "0000" => tmp<="1000000";
		when "0001" => tmp<="1111001";
		when "0010" => tmp<="0100100";
		when "0011" => tmp<="0110000";	
		when "0100" => tmp<="0011001";
		when "0101" => tmp<="0010010";	
		when "0110" => tmp<="0000010";
		when "0111" => tmp<="1111000";
		when "1000" => tmp<="0000000";
		when "1001" => tmp<="0010000";	
		when "1010" => tmp<="0001000";
		when "1011" => tmp<="0000011";
		when "1100" => tmp<="1000110";
		when "1101" => tmp<="0100001";
		when "1110" => tmp<="0000110";
		when "1111" => tmp<="0001110";
		when others => tmp<="1111111";
		end case;
	end process;
	Dataout<=tmp;
end architecture bahav1;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
entity PS2 is		--将上述两元件组合成为PS2
port(
	  CLK: in std_logic;
	  RST: in std_logic;
	  KBD_CLK: in std_logic;
	  KBD_DATA: in std_logic;
	  scan_ready: out std_logic;	  
	  MSD_SEG: out std_logic_vector(6 downto 0);
	  LSD_SEG: out std_logic_vector(6 downto 0)
	  );
end entity PS2;

architecture behav2 of PS2 is

	component keybord 
	port(
	  CLK: in std_logic;
	  RST: in std_logic;
	  KBD_CLK: in std_logic;
	  KBD_DATA: in std_logic;
	  scan_ready: out std_logic;
	  scan_code: out std_logic_vector(7 downto 0)
	  );
	end component;
	
	component DEC_7SEG 
	port(
	  Datain: in std_logic_vector(3 downto 0);
	  Dataout: out std_logic_vector(6 downto 0)
	  );
	end component;
	
	signal tmp_code: std_logic_vector(7 downto 0);

begin
	U1: keybord port map(CLK,RST,KBD_CLK,KBD_DATA,scan_ready,tmp_code);
	U2: DEC_7SEG port map(tmp_code(7 downto 4),MSD_SEG);
	U3: DEC_7SEG port map(tmp_code(3 downto 0),LSD_SEG);	--连接方式见书中p149图6.40
end architecture behav2;
	
		  
	
