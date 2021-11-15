library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity mycpu is
   port(clk:in std_logic;
		  rst:in std_logic;
		  jumpout,RWout: out std_logic;
		  Dataout: out std_logic_vector(7 downto 0);--计算得到的数据输出
		  Instrout: out std_logic_vector(15 downto 0);--当前指令输出
		  Addressout: out std_logic_vector(7 downto 0);--PC地址输出
		  RAMdataout: out std_logic_vector(7 downto 0);--RAM数据输出
		  state:out std_logic_vector(3 downto 0));--CPU当前工作状态
end mycpu;

architecture behav of mycpu is

component CTRL
    port(clk:in std_logic;
		  rst:in std_logic;
	     sign:in std_logic;  --累加器AC的符号位
		  Instr:in std_logic_vector(15 downto 0);  --指令输入
  		  RorW:out std_logic;  --关于AC的读写信号,0读入,1写出
	     Flag:out std_logic_vector(3 downto 0);	--每位充当各部分的时钟	  
		  address:out std_logic_vector(7 downto 0);  --输出数据地址或指令地址
		  jump:out std_logic);  --关于PC的跳转信号,0不跳,1跳转 
end component CTRL;

component PC is
   port(PCclk:in std_logic;
		  rst:in std_logic;
		  jump:in std_logic;
		  Inaddress:in std_logic_vector(7 downto 0);
		  Outaddress:out std_logic_vector(7 downto 0));
end component PC;

component IR is
   port(IRclk:in std_logic;
	     Incode:in std_logic_vector(15 downto 0);
		  Outcode:out std_logic_vector(15 downto 0));
end component IR;

component ALU is
   port(rst:in std_logic;
		  ACdata:in std_logic_vector(7 downto 0);  --AC提供的数据
	     RAMdata:in std_logic_vector(7 downto 0);  --内存中存储的数据
	     Instr:in std_logic_vector(15 downto 0);  --指令
		  Dataout:out std_logic_vector(7 downto 0));  
end component ALU;

component AC is
   port(ACclk: in std_logic;
		  rst:in std_logic;
	     InData:in std_logic_vector(7 downto 0);
		  sign:out std_logic;		--累加器输出的符号位
		  OutData:out std_logic_vector(7 downto 0));  
end component AC;

component code IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END component code;

component DATA IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component DATA;

signal sign,jumpflag,RWflag:std_logic;	--符号、跳转标志、读写标志
signal Tflag:std_logic_vector(3 downto 0); --指令时钟
signal data0,data1,data2:std_logic_vector(7 downto 0);  
				--data0为从RAM中读取的数据，data1为AC锁存的数据，data2为ALU计算得到的数据
signal Instr0,Instr1:std_logic_vector(15 downto 0):=(others=>'0');  --指令
signal add0,add1:std_logic_vector(7 downto 0);	
				--add0为控制模块CTRL从指令中得到的地址，add1为PC得到的指向下一条指令的地址

begin
	codeROM: CODE port map(add1,Tflag(1),Instr0); 
	
	dataRAM1: DATA port map(add0,Tflag(2),data1,RWflag,data0);
	
	U1: CTRL port map (clk,rst,sign,Instr0,RWflag,Tflag,add0,jumpflag);
	
	U2: PC port map (Tflag(0),rst,jumpflag,add0,add1);
	
	U3: IR port map (Tflag(1),Instr0,Instr1);
	
	U4: AC port map (Tflag(3),rst,data2,sign,data1);
	
	U5: ALU port map (rst,data1,data0,Instr0,data2);
	
	jumpout <= jumpflag;
	RWout <= RWflag;
	Instrout <= Instr0;
	Dataout <= data1;
	Addressout <= add1;
	RAMdataout <= data0;
	state <= Tflag;
	
end behav;
	