LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE work.all;
ENTITY IRR IS
  PORT (
    clk : IN STD_LOGIC;					-- 50MHz系统时钟
    IRin : IN STD_LOGIC;				-- IR接收端口
    reset : IN STD_LOGIC;				-- Reset端
    --输出端
    ------------------------------------------------------
    -- 用户码
    D0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  
    D1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    D2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    D3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    ------------------------------------------------------
    -- 操作码
    D4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  
    D5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    D6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    D7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE RTL OF IRR IS
  TYPE IRstate IS (IDLE, Guidance, loadData);
	-- 3个状态 空闲->接收到引导->读入数据
  SIGNAL CurrentState, NextState : IRstate := IDLE;
  CONSTANT IdleHighDuration : INTEGER := 262143; 	-- 空闲时刻
																	-- 5.24ms / 20ns = 262143
  CONSTANT GuideLowDuration : INTEGER := 230000; 	-- 引导码&低电平
																	-- 4.6ms / 20ns = 230000
  CONSTANT GuideHighDuration : INTEGER := 210000; 	-- 引导码&高电平
																	-- 4.2ms / 20ns = 210000
  CONSTANT DataHighDuration : INTEGER := 41500; 	-- 收到的信号判断为1
																	-- 0.83ms / 20ns = 41500
  CONSTANT BitDuration : INTEGER := 20000; 			-- 比特时间，抽样时间
																	-- 0.4ms / 20ns = 20000
  SIGNAL IdleC, StateC, DataC : INTEGER := 0; 		-- 计数器
  SIGNAL IdleFlag, StateFlag, DataFlag : STD_LOGIC := '0'; -- 标志器和计数器
  SIGNAL BitC : INTEGER := 0; 							-- 已经接收的bits数
  SIGNAL DataRXFinish : STD_LOGIC := '0'; 			-- 接收的数据是否准备就绪，可以输出
  SIGNAL RXdata, RXdataReg, OutputData : STD_LOGIC_VECTOR(31 DOWNTO 0); -- 数据建立和寄存器
BEGIN
  sync : PROCESS (clk)
  BEGIN
    IF (rising_edge(clk)) THEN
      IF (reset = '1') THEN 								-- 同步清零
        IdleC <= 0; 											-- 空闲时刻counter=0
        IdleFlag <= '0';
        StateC <= 0; 										-- 状态0
        StateFlag <= '0';
        DataC <= 0; 											-- 数据计算器
        DataFlag <= '0';
        BitC <= 0; 											-- bit计数器
        CurrentState <= IDLE; 							-- 默认空闲
        RXdata <= (OTHERS => '0'); 						-- 数据
        DataRXFinish <= '0'; 								-- 不能接收与输出
        OutputData <= (OTHERS => '0'); 				-- 
      ELSE
        CurrentState <= NextState; 						-- 进入下一段状态
        IF (CurrentState = IDLE AND IRin = '0') THEN--可以开始引导
          IdleFlag <= '1';									-- 开始低电平引导
        ELSE
          IdleFlag <= '0';
        END IF;
        IF (IdleFlag = '1') THEN 						-- 不断累计，直到足够规定发送的时间转进高电平检测
          IdleC <= IdleC + 1;								-- 如果低电平引导不够，则继续等待
        ELSE
          IdleC <= 0;										-- 中断，从头检测
        END IF;
        IF (CurrentState = Guidance AND IRin = '1') THEN-- 此时检测高电平
          StateFlag <= '1'; 								-- 开始高电平引导
        ELSE
          StateFlag <= '0';
        END IF;
        IF (StateFlag = '1') THEN 						-- 开始计算，累计1的个数
          StateC <= StateC + 1;
        ELSE
          StateC <= 0;									  	-- 中断，从头检测
        END IF;
        IF (CurrentState = loadData AND IRin = '1') THEN -- 引导完毕开始读数
          DataFlag <= '1'; 								-- 如果读入的是高电平
        ELSE
          DataFlag <= '0';
        END IF;
        IF (DataFlag = '1') THEN 						-- 开始计算个数
          DataC <= DataC + 1; 							-- 计算个数
        ELSE
          DataC <= 0;
        END IF;
        IF (CurrentState = loadData) THEN 			--如果大于抽样判决持续时间，判断为一个bit
          IF (DataC = BitDuration) THEN
            BitC <= BitC + 1;
          END IF;
          IF (DataC >= DataHighDuration) THEN 		-- 如果满足高电平判决条件，判断为数据1
            RXdata(BitC - 1) <= '1';
          END IF;
        ELSE
          BitC <= 0; 										-- 初始化
          RXdata <= (OTHERS => '0');
        END IF;
        IF (BitC = 32) THEN 								-- 32位RX数据读完
          IF (RXdata(31 DOWNTO 24) = NOT RXdata(23 DOWNTO 16)) THEN--操作码
            RXdataReg <= RXdata; 						-- 读入reg
            DataRXFinish <= '1'; 						-- 全部读完
          ELSE
            DataRXFinish <= '0'; 						--	准备发送
          END IF;
        ELSE
          DataRXFinish <= '0';
        END IF;
        IF (DataRXFinish = '1') THEN 					-- 给到输出端
          OutputData <= RXdataReg;
        END IF;
      END IF;
    END IF;
  END PROCESS;
  comb : PROCESS (CurrentState, IdleC, StateC, DataC, BitC)
  BEGIN
    CASE CurrentState IS
      WHEN IDLE =>
        IF (IdleC > GuideLowDuration) THEN
          NextState <= Guidance; 					-- 超过一开始的低电平持续时间，满足条件后转为检测高电平
        ELSE
			NextState <= IDLE;							-- 不满足继续检测
        END IF;
      WHEN Guidance =>
        IF (StateC > GuideHighDuration) THEN		-- 引导结束加载数据
          NextState <= loadData;
        ELSE
          NextState <= Guidance;						-- 引导失败从头再来
        END IF;
      WHEN loadData =>
        IF (DataC >= IdleHighDuration OR BitC >= 33) THEN-- 加载完
          NextState <= IDLE;							-- 继续等待
        ELSE
          NextState <= loadData;						-- 继续加载
        END IF;
      WHEN OTHERS =>
        NextState <= IDLE;								-- 未知状态清空
    END CASE;
  END PROCESS;
  ---------------------------
  -- RX数据显示，七段译码管
  U0 : digitron_2 PORT MAP(OutputData(7 DOWNTO 0), D0, D1);    -- 用户码
  U1 : digitron_2 PORT MAP(OutputData(15 DOWNTO 8), D2, D3);   -- 用户码反码
  U2 : digitron_2 PORT MAP(OutputData(23 DOWNTO 16), D4, D5);  -- 操作码
  U3 : digitron_2 PORT MAP(OutputData(31 DOWNTO 24), D6, D7);  -- 操作码反码
END ARCHITECTURE;