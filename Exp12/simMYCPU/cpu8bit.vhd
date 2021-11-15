library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.all;


entity cpu8bit is
	generic(
	dlen:integer:=8;--数据长度8位
	OpAddr:integer:=16
	);
	port(
	clk:in std_logic;
	reset:in std_logic;
	SHOWRAMCLK:out std_logic;
	SHOWWR:out std_logic;
	SHOWAC:out std_logic_vector(dlen-1 downto 0);
	SHOWRAM:out std_logic_vector(dlen-1 downto 0);
	SHOWPC:out std_logic_vector(dlen-1 downto 0);
	SHOWCU:out std_logic_vector(dlen-1 downto 0);
	opdisp:out std_logic_vector(OpAddr-1 downto 0)
	);

end entity;


architecture bev of cpu8bit is
------------------------------------------------------------------
--
SIGNAL DECODED_ADDR:std_logic_vector(dlen-1 downto 0);
SIGNAL DECODED_OP:std_logic_vector(dlen-1 downto 0);
signal RAMreadWrite:std_logic:='0';
signal ctrlunit:std_logic_vector(dlen-1 downto 0):=(others=>'0');
------------------------------------------------------------------
signal opaddrseg:std_logic_vector(OpAddr-1 downto 0);

signal acseg:std_logic_vector(dlen-1 downto 0);
signal pcseg:std_logic_vector(dlen-1 downto 0):=x"00";
signal ramseg:std_logic_vector(dlen-1 downto 0);

begin
rom16bit_inst : rom16bit PORT MAP (
		address	 => pcseg,
		clock	 => ctrlunit(0),
		q	 => opaddrseg
	);
IR_inst: IR PORT MAP(
	EN=> ctrlunit(7),
	opin=>opaddrseg,
	opout=>DECODED_OP,
	adout=>DECODED_ADDR
);	
	
run_inst:CU PORT MAP (
		clk=> clk,
		reset=> reset,
		Opcode=>DECODED_OP,
		WE=>RAMreadWrite,
		outPart=>ctrlunit
	);
ram8bit_inst:ram8bit PORT MAP	(
		address=>DECODED_ADDR,
		clock=>ctrlunit(1),
		data=>acseg,
		wren=>RAMreadWrite,
		q=>ramseg
	);
ALU_inst :ALU PORT MAP(
	clk=>ctrlunit(2),
	reset=>reset,
	op=>DECODED_OP,
	Acc=>acseg,
	RamVal=>ramseg,
	ALUout=>acseg
);	
	
PCT_inst:PCT PORT MAP (
		clk=> ctrlunit(3),
		reset=> reset,
		opCode=>DECODED_OP,
		AccIn=>acseg,
		inaddr=>DECODED_ADDR,
		outaddr=>pcseg
	);

	opdisp<=opaddrseg;
	SHOWPC<=pcseg;
	SHOWCU<=ctrlunit;
	SHOWAC<=acseg;
	SHOWRAM<=ramseg;
	SHOWRAMCLK<=ctrlunit(1);
	SHOWWR<=RAMreadWrite;
end architecture;