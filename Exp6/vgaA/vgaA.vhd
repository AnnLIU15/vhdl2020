LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
------------------------------------------------------------------
-- 640x480 显示器
ENTITY VgaA IS
	PORT (
		clk : IN STD_LOGIC;								-- 时钟
		dispMode : IN STD_LOGIC;						-- 模式
		reset : IN STD_LOGIC;							-- 重置
		Hs : OUT STD_LOGIC;								-- vgahs 行同步信号
		Vs : OUT STD_LOGIC;								-- vgavs 列同步信号
		RGB24 : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);		-- 数值输出
		vgaClk : OUT STD_LOGIC;
		vgaBlankin : IN STD_LOGIC;						-- 控制blank
		vgaBlank : OUT STD_LOGIC;
		vgaSyncin : IN STD_LOGIC;						-- 控制sync
		vgaSync : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE bev OF VgaA IS
	SIGNAL modecounter : INTEGER RANGE 2 DOWNTO 0 := 0;	-- 模式选择
	-------------------------------------------------------------------
	-- 行时序
	CONSTANT Ta : INTEGER := 96;						-- 同步脉冲
	CONSTANT Tb : INTEGER := 48;						-- 显示后延
	CONSTANT Tc : INTEGER := 640;						-- 显示时序段
	CONSTANT Td : INTEGER := 16;						-- 显示前沿
	CONSTANT Te : INTEGER := 800;						-- 总长
	-------------------------------------------------------------------
	-- 场时序
	CONSTANT To1 : INTEGER := 2;						-- 同步脉冲
	CONSTANT Tp : INTEGER := 33;						-- 显示后延
	CONSTANT Tq : INTEGER := 480;						-- 显示时序段
	CONSTANT Tr : INTEGER := 10;						-- 显示前沿
	CONSTANT Ts : INTEGER := 525;						-- 总长
	-------------------------------------------------------------------
	-- Hs Vs暂存
	SIGNAL Hs1 : INTEGER RANGE 799 DOWNTO 0;
	SIGNAL Vs1 : INTEGER RANGE 524 DOWNTO 0;
	SIGNAL clk25 : STD_LOGIC;
	COMPONENT clk50_2_25
		PORT (
			inclk : IN STD_LOGIC;
			outclk : OUT STD_LOGIC
		);
	END COMPONENT;
BEGIN
	u1 : clk50_2_25 PORT MAP(clk, clk25);	-- 获取25Mhz
	vgaClk <= clk25;						-- vga时钟25.175Mhz
	vgaBlank <= vgaBlankin;					-- 
	vgaSync <= vgaSyncin;					-- 同步
	PROCESS (dispMode)
	BEGIN
		IF rising_edge(dispMode) THEN		-- 时钟开关上升沿作为按键，防抖
			IF modecounter = 2 THEN
				modecounter <= 0;
			ELSE
				modecounter <= modecounter + 1;
			END IF;
		END IF;
	END PROCESS;
	PROCESS (clk25, reset)					-- 控制电路
	BEGIN
		IF reset = '1' THEN					-- 行同步信号列同步信号清空
			Hs1 <= 0;
			Vs1 <= 0;
		ELSIF rising_edge(clk25) THEN		-- 累加计算，准备输出行同步信号与列同步信号
			IF Hs1 < Te - 1 THEN
				Hs1 <= Hs1 + 1;
			ELSE
				Hs1 <= 0;
			END IF;
			IF Hs1 = Te - 1 THEN
				IF Vs1 < Ts - 1 THEN
					Vs1 <= Vs1 + 1;
				ELSE
					Vs1 <= 0;
				END IF;
			ELSE
				Vs1 <= Vs1;
			END IF;
		END IF;

	END PROCESS;
	PROCESS (Hs1, Vs1, modecounter)
		VARIABLE gx, gy : STD_LOGIC_VECTOR(23 DOWNTO 0);
	BEGIN
		IF reset = '1' THEN					-- 清零
			Hs <= '1';
			Vs <= '1';
		ELSE								-- 输出
			IF Hs1 < Ta THEN				
				Hs <= '0';
			ELSE
				Hs <= '1';
			END IF;
			IF Vs1 < To1 THEN				
				Vs <= '0';
			ELSE
				Vs <= '1';
			END IF;
		END IF;
		IF Hs1 < Ta + 49 + Tc/3 THEN		-- 行分布
			gx := "000000000000000011111111";
		ELSIF Hs1 < Ta + 49 + Tc/3 * 2 THEN
			gx := "111111110000000000000000";
		ELSE
			gx := "000000001111111100000000";
		END IF;
		IF Vs1 < To1 + Tp + Tq/3 THEN		-- 列分布
			gy := "111111110000000000000000";
		ELSIF Vs1 < To1 + Tp + Tq/3 * 2 THEN
			gy := "000000001111111100000000";
		ELSE
			gy := "000000000000000011111111";
		END IF;
		CASE modecounter IS
			WHEN 0 =>
				RGB24 <= gx;				-- 行输出
			WHEN 1 =>
				RGB24 <= gy;				-- 列输出
			WHEN OTHERS =>
				RGB24 <= gx XOR gy;			-- 网格输出
		END CASE;

	END PROCESS;
END ARCHITECTURE;