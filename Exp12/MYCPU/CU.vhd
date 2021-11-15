LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY CU IS

	GENERIC (
		dlen : INTEGER := 8--数据长度8位
	);
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		Opcode : IN STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);
		WE : OUT STD_LOGIC;
		outPart : OUT STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0)
	);
END ENTITY;
ARCHITECTURE bev OF CU IS

	SIGNAL choosePart : STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);
	-----------------------------------------------------------------------
	-- 状态机
	TYPE state IS (idle, romstate, selectstate, calstate, storestate, loadstate, jumpS, jumpZ, none);
	SIGNAL currenstate : state := idle;
	SIGNAL nextstate : state := selectstate;
	-----------------------------------------------------------------------
	SIGNAL statecounter : INTEGER RANGE 3 DOWNTO 0 := 0;
	SIGNAL nextstatecounter : INTEGER RANGE 3 DOWNTO 0 := 0;
BEGIN
	changeState : PROCESS (clk, reset)
	BEGIN
		IF reset = '1' THEN
			currenstate <= idle;
		ELSIF rising_edge(clk) THEN
			currenstate <= nextstate;
			statecounter <= nextstatecounter;
		END IF;
	END PROCESS;
	stateoperator : PROCESS (currenstate)
	BEGIN
		CASE currenstate IS
				-----------------------------------
				-- idle --
			WHEN idle =>
				choosePart <= (OTHERS => '0');
				choosePart(0) <= '1';				-- 打开ROM
				nextstate <= selectstate;
				WE <= '0';
			WHEN selectstate =>
				choosePart <= (OTHERS => '0');
				choosePart(7) <= '1';				-- 打开IR
				nextstate <= romstate;
				nextstatecounter <= 0;
				-----------------------------------
				-- romstate --
			WHEN romstate =>
				choosePart <= (OTHERS => '0');

				CASE Opcode IS
					WHEN x"00" =>
						nextstate <= calstate;		-- 计算
					WHEN x"01" =>
						nextstate <= storestate;	-- 写数据
						WE <= '1';
					WHEN x"02" =>
						nextstate <= loadstate;		-- 加载
					WHEN x"03" =>
						nextstate <= jumpS;			-- 无条件跳转
					WHEN x"04" =>
						nextstate <= jumpZ;			-- AC小于0跳转
					WHEN OTHERS =>
						nextstate <= none;			-- 未知或暂时状态
				END CASE;
				-----------------------------------
				-- calstate --
			WHEN calstate =>
				CASE statecounter IS
					WHEN 0 =>
						choosePart <= (OTHERS => '0');
						choosePart(1) <= '1'; 		-- 获取RAM,addr值
						WE <= '0';
					WHEN 1 =>
						choosePart <= (OTHERS => '0');
						WE <= '0';
						choosePart(2) <= '1'; 		-- 进入ALU
					WHEN 2 =>
						choosePart <= (OTHERS => '0');
						choosePart(3) <= '1'; 		-- 打开PC
						nextstate <= idle;
					WHEN OTHERS =>
						nextstate <= idle;
				END CASE;
				nextstatecounter <= statecounter + 1;-- 下一轮

				-----------------------------------
				-- storestate --		
			WHEN storestate =>
				CASE statecounter IS
					WHEN 0 =>
						WE <= '1';
						choosePart <= (OTHERS => '0');
						choosePart(1) <= '1'; 			-- 写入RAM,addr
						nextstate <= none;
					WHEN 1 =>

						choosePart(1) <= '0';
						choosePart(3) <= '1'; 			-- 打开PC
						nextstate <= idle;
					WHEN OTHERS =>
						nextstate <= idle;
				END CASE;
				nextstatecounter <= statecounter + 1;	-- 下一轮

				-----------------------------------
				-- loadstate --			
			WHEN loadstate =>
				CASE statecounter IS
					WHEN 0 =>
						choosePart <= (OTHERS => '0');
						choosePart(1) <= '1'; 		-- 获取RAM,addr值
						WE <= '0';
					WHEN 1 =>
						choosePart(1) <= '0';
						choosePart(2) <= '1'; 		-- 进入ALU
					WHEN 2 =>
						choosePart(2) <= '0';
						choosePart(3) <= '1'; 		-- 打开PC
						nextstate <= idle;
					WHEN OTHERS =>
						nextstate <= idle;
				END CASE;
				nextstatecounter <= statecounter + 1;-- 下一轮

				-----------------------------------
				-- jumpS --			
			WHEN jumpS =>
				CASE statecounter IS
					WHEN 0 =>
						choosePart <= (OTHERS => '0');
						choosePart(2) <= '1'; 		-- 进入ALU
						WE <= '0';
					WHEN 1 =>
						WE <= '0';
						choosePart <= (OTHERS => '0');
						choosePart(3) <= '1';	 	-- 打开PC
						nextstate <= idle;
					WHEN OTHERS =>
						nextstate <= idle;
				END CASE;
				nextstatecounter <= statecounter + 1;-- 下一轮
			WHEN jumpZ =>
				CASE statecounter IS
					WHEN 0 =>
						choosePart <= (OTHERS => '0');
						choosePart(2) <= '1'; 		-- 进入ALU
						WE <= '0';
					WHEN 1 =>
						WE <= '0';
						choosePart <= (OTHERS => '0');
						choosePart(3) <= '1'; 		-- 打开PC
						nextstate <= idle;
					WHEN OTHERS =>
						nextstate <= idle;
				END CASE;
				nextstatecounter <= statecounter + 1;-- 下一轮
				-----------------------------------
				-- error --	
			WHEN OTHERS =>
				nextstate <= idle;
				WE <= '0';
				choosePart <= (OTHERS => '0');
				choosePart(3) <= '1'; 				-- 打开PC
		END CASE;
	END PROCESS;
	outcontrol : PROCESS (choosePart)
	BEGIN
		outPart <= choosePart;						--暂存输出
	END PROCESS;
END ARCHITECTURE;