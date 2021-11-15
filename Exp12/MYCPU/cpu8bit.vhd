LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE work.ALL;
------------------------------------------------------------
-- 00**->AC+=*addr 					
-- 01**->*addr=AC 
-- 02**->AC=*addr
-- 03**->nextPC=addr
-- 04**->PC=addr if AC<0 else PC+=1
------------------------------------------------------------
ENTITY cpu8bit IS
	GENERIC (
		dlen : INTEGER := 8;--数据长度8位
		OpAddr : INTEGER := 16
	);
	PORT (
		-----------------------------------------------------------
		-- 控制电路
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		-----------------------------------------------------------
		-- 仿真显示
		SHOWRAMCLK : OUT STD_LOGIC;
		SHOWWR : OUT STD_LOGIC;
		SHOWAC : OUT STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);
		SHOWRAM : OUT STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);
		SHOWPC : OUT STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);
		SHOWCU : OUT STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);
		opdisp : OUT STD_LOGIC_VECTOR(OpAddr - 1 DOWNTO 0);
		-----------------------------------------------------------
		-- 上板显示
		PCLED1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- PC显示，低位
		PCLED2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- PC显示，高位
		ACLED1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- AC显示，低位
		ACLED2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- AC显示，高位
		RAMLED1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- RAM显示，低位
		RAMLED2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)	-- RAM显示，高位
	);

END ENTITY;
ARCHITECTURE bev OF cpu8bit IS
	------------------------------------------------------------------
	-- 1s时钟，仿真请见simmycpu
	SIGNAL clkcounter : INTEGER RANGE 25000000 DOWNTO 0 := 0;	-- 时钟计数器
	SIGNAL clockc : STD_LOGIC;									-- 真实时钟
	------------------------------------------------------------------
	SIGNAL DECODED_ADDR : STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);	-- 译码的地址
	SIGNAL DECODED_OP : STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);	-- 译码的指令
	SIGNAL RAMreadWrite : STD_LOGIC := '0';						-- 写使能
	SIGNAL ctrlunit : STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0) := (OTHERS => '0');--控制单元
	------------------------------------------------------------------
	SIGNAL opaddrseg : STD_LOGIC_VECTOR(OpAddr - 1 DOWNTO 0);	-- 操作寄存器

	SIGNAL acseg : STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);			-- AC寄存
	SIGNAL pcseg : STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0) := x"00";-- PC寄存
	SIGNAL ramseg : STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);		-- RAM寄存

BEGIN
	PROCESS (clk)												-- 1s时钟
	BEGIN
		IF rising_edge(clk) THEN
			IF clkcounter = 24999999 THEN
				clkcounter <= 0;
				clockc <= NOT clockc;							-- 翻转
			ELSE
				clkcounter <= clkcounter + 1;					-- 计数
			END IF;
		END IF;
	END PROCESS;
	-----------------------------------------------------------------
	-- IPROM
	-- address => pcseg 	给PC取ROM
	-- clock => ctrlunit(0) 控制使能
	-- q => opaddrseg 		输出指令
	rom16bit_inst : rom16bit PORT MAP(
		address => pcseg,
		clock => ctrlunit(0),
		q => opaddrseg
	);
	-----------------------------------------------------------------
	-- IR译码
	-- EN => ctrlunit(7), 	译码使能
	-- opin => opaddrseg,	指令
	-- opout => DECODED_OP,	指令码
	-- adout => DECODED_ADDR指令地址
	IR_inst : IR PORT MAP(
		EN => ctrlunit(7),
		opin => opaddrseg,
		opout => DECODED_OP,
		adout => DECODED_ADDR
	);
	------------------------------------------------------------------
	-- 控制单元
	-- clk => clockc,		一秒时钟
	-- reset => reset,		清零
	-- Opcode => DECODED_OP,操作码
	-- WE => RAMreadWrite,	写使能
	-- outPart => ctrlunit	输出对外控制
	run_inst : CU PORT MAP(
		clk => clockc,
		reset => reset,
		Opcode => DECODED_OP,
		WE => RAMreadWrite,
		outPart => ctrlunit
	);
	------------------------------------------------------------------
	-- IPRAM
	-- address => DECODED_ADDR, 从RAM指定地址获取
	-- clock => ctrlunit(1),	控制
	-- data => acseg,			AC寄存
	-- wren => RAMreadWrite,	CU写使能
	-- q => ramseg				输出取出结果
	ram8bit_inst : ram8bit PORT MAP(
		address => DECODED_ADDR,
		clock => ctrlunit(1),
		data => acseg,
		wren => RAMreadWrite,
		q => ramseg
	);
	------------------------------------------------------------------
	-- ALU
	-- address => DECODED_ADDR, 从RAM指定地址获取
	-- reset => reset			清零
	-- op => DECODED_OP			--操作指令
	-- Acc => acseg,			读入AC
	-- RamVal => ramseg,		读入ram输出
	-- ALUout => acseg			写入AC
	ALU_inst : ALU PORT MAP(
		clk => ctrlunit(2),
		reset => reset,
		op => DECODED_OP,
		Acc => acseg,
		RamVal => ramseg,
		ALUout => acseg
	);
	------------------------------------------------------------------
	-- PC
	-- clk => ctrlunit(3),		控制单元控制PC
	-- reset => reset,			清零
	-- opCode => DECODED_OP,	操作码
	-- AccIn => acseg,			AC判断是否跳转
	-- inaddr => DECODED_ADDR,	进入的地址
	-- outaddr => pcseg			PC输出地址
	PCT_inst : PCT PORT MAP(
		clk => ctrlunit(3),
		reset => reset,
		opCode => DECODED_OP,
		AccIn => acseg,
		inaddr => DECODED_ADDR,
		outaddr => pcseg
	);
	-----------------------------------------------------------------
	-- 数码管输出PC AC RAM
	U0 : digitron_2 PORT MAP(pcseg, PCLED1, PCLED2);
	U1 : digitron_2 PORT MAP(acseg, ACLED1, ACLED2);
	U2 : digitron_2 PORT MAP(ramseg, RAMLED1, RAMLED2);
	-----------------------------------------------------------------
	-- 仿真用
	opdisp <= opaddrseg;
	SHOWPC <= pcseg;
	SHOWCU <= ctrlunit;
	SHOWAC <= acseg;
	SHOWRAM <= ramseg;
	SHOWRAMCLK <= ctrlunit(1);
	SHOWWR <= RAMreadWrite;
END ARCHITECTURE;