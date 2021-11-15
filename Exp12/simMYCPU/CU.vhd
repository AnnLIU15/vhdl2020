library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity CU is

	generic(
	dlen:integer:=8--数据长度8位
	);
   port(clk:in std_logic;
		  reset:in std_logic;
		  Opcode:in std_logic_vector(dlen-1 downto 0);
		  WE:out std_logic;
		  outPart:out std_logic_vector(dlen-1 downto 0)
		  
		  
		  );
end entity;


architecture bev of  CU is



signal choosePart:std_logic_vector(dlen-1 downto 0);
-----------------------------------------------------------------------
-- 状态机
type state is (idle,romstate,selectstate,calstate,storestate,loadstate,jumpS,jumpZ,none);
signal currenstate:state:=idle;
signal nextstate:state:=selectstate;
-----------------------------------------------------------------------
signal statecounter:integer range 3 downto 0:=0;
signal nextstatecounter:integer range 3 downto 0:=0;
begin
	changeState:process(clk,reset)
	begin
		if reset='1' then
			currenstate<=idle;
		elsif rising_edge(clk) then 
			currenstate<=nextstate;
			statecounter<=nextstatecounter;
		end if;
	end process;
	stateoperator:process(currenstate)
	begin
		case currenstate is
		-----------------------------------
		-- idle --
		when idle=>
			choosePart<=(others=>'0');
			choosePart(0)<='1';
			nextstate<=selectstate;
			WE<='0';
		when selectstate=>
			choosePart<=(others=>'0');
			choosePart(7)<='1';
			nextstate<=romstate;
			nextstatecounter<=0;
		-----------------------------------
		-- romstate --
		when romstate=>
			choosePart<=(others=>'0');
			
			case Opcode is
			when x"00"=>	
				nextstate<=calstate;

			when x"01"=>	
				nextstate<=storestate;
				WE<='1';

			when x"02"=>	
				nextstate<=loadstate;
			when x"03"=>	
				nextstate<=jumpS;
			when x"04"=>	
				nextstate<=jumpZ;
			when others=>
				nextstate<=none;
			end case;
		-----------------------------------
		-- calstate --
		when calstate=>
			case statecounter is
			when 0=>
			choosePart<=(others=>'0');
			choosePart(1)<='1';						-- 获取RAM,addr值
			WE<='0';
			when 1=>
			choosePart<=(others=>'0');
			WE<='0';
			choosePart(2)<='1';						-- 进入ALU
			when 2=>
			choosePart<=(others=>'0');
			choosePart(3)<='1'; 						-- 打开PC
			nextstate<=idle;
			when others=>
			nextstate<=idle;
			end case;
			nextstatecounter<=statecounter+1;

		-----------------------------------
		-- storestate --		
		when storestate=>
			case statecounter is
			when 0=>
			WE<='1';
			choosePart<=(others=>'0');
			choosePart(1)<='1';						-- 写入RAM,addr
			nextstate<=none;
			when 1=>

			choosePart(1)<='0';
			choosePart(3)<='1'; 						-- 打开PC
			nextstate<=idle;
			when others=>
			nextstate<=idle;
			end case;
			nextstatecounter<=statecounter+1;
		
		-----------------------------------
		-- loadstate --			
		when loadstate=>
			case statecounter is
			when 0=>
			choosePart<=(others=>'0');
			choosePart(1)<='1';						-- 获取RAM,addr值
			WE<='0';
			when 1=>
			choosePart(1)<='0';
			choosePart(2)<='1'; 						-- 进入ALU
			WHEN 2=>
			choosePart(2)<='0';
			choosePart(3)<='1'; 						-- 打开PC
			nextstate<=idle;
			when others=>
			nextstate<=idle;
			end case;
			nextstatecounter<=statecounter+1;

		-----------------------------------
		-- jumpS --			
		when jumpS=>
			case statecounter is
			when 0=>
			choosePart<=(others=>'0');
			choosePart(2)<='1';						-- 进入ALU
			WE<='0';
			when 1=>
			WE<='0';
			choosePart<=(others=>'0');
			choosePart(3)<='1'; 						-- 打开PC
			nextstate<=idle;
			when others=>
			nextstate<=idle;
			end case;
			nextstatecounter<=statecounter+1;
		when jumpZ=>
			case statecounter is
			when 0=>
			choosePart<=(others=>'0');
			choosePart(2)<='1';						-- 进入ALU
			WE<='0';
			when 1=>
			WE<='0';
			choosePart<=(others=>'0');
			choosePart(3)<='1'; 						-- 打开PC
			nextstate<=idle;
			when others=>
			nextstate<=idle;
			end case;
			nextstatecounter<=statecounter+1;
		-----------------------------------
		-- error --	
		when others=>
			nextstate<=idle;
			WE<='0';
			choosePart<=(others=>'0');
			choosePart(3)<='1'; 						-- 打开PC
		end case;
	
	
	end process;
	outcontrol:process(choosePart)
	begin 
		outPart<=choosePart;
	end process;
end architecture;