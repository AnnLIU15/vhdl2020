LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
-- 课本实验源码
ENTITY SIM IS
	PORT (
		clk : IN STD_LOGIC;							-- 时钟一
		clock : IN STD_LOGIC;						-- 时钟二
		SW1 : IN STD_LOGIC;							-- 使能开关
		an1 : IN STD_LOGIC;							-- 按键切换模式
		word2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- 段码中的数字信号
		word1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- 段码中的数字信号
		word0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- 段码中的数字信号
		Q : OUT STD_LOGIC_VECTOR(10 DOWNTO 0));	-- 彩灯信号
END ENTITY;

ARCHITECTURE bev OF SIM IS
	SIGNAL mode : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";	--模式
	SIGNAL flag : STD_LOGIC;
	SIGNAL ancounter : STD_LOGIC;
	SIGNAL mode_disp : STD_LOGIC_VECTOR(6 DOWNTO 0);
	SIGNAL QQ:STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL clk_slow : STD_LOGIC;
	SIGNAL mode_before : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN
	Q<=QQ;
	PROCESS (SW1, clk)
		VARIABLE clk_counter : STD_LOGIC_VECTOR(1 DOWNTO 0);
	BEGIN
		IF SW1 = '1' THEN									-- 允许进行
			IF rising_edge(clk) THEN
				IF clk_counter = "11" THEN
					clk_counter := "00";-- 
					clk_slow <= '1';
				ELSE
					clk_counter := clk_counter + "01";
					clk_slow <= '0';
				END IF;
			END IF;
		ELSE
			clk_counter := "00";
		END IF;
	END PROCESS;

	PROCESS (clk, clk_slow, SW1, an1, QQ)
	BEGIN
		IF SW1 = '1' THEN
			IF rising_edge(clk_slow) THEN
				IF mode_before = mode THEN
					IF mode = "0000" THEN					-- 复位
						QQ <= (OTHERS => '0');
					ELSIF mode = "0001" THEN				-- 从左到右移位亮灯
						IF QQ = "00000000000" THEN
							QQ(10) <= '1';
						ELSE		
							QQ <= '0' & QQ(10 DOWNTO 1);
						END IF;
					ELSIF mode = "0010" THEN				-- 从右到左移位亮灯
						IF QQ = "00000000000" THEN
							QQ(0) <= '1';
						ELSE
							QQ <= QQ(9 DOWNTO 0) & '0';
						END IF;
					ELSIF mode = "0011" THEN				-- 中间向两边亮
						IF QQ = "00000000000" THEN
							QQ(5) <= '1';
						ELSE
							QQ(10 DOWNTO 5) <= QQ(9 DOWNTO 5) & '0';
							QQ(5 DOWNTO 0) <= '0' & QQ(5 DOWNTO 1);
						END IF;
					ELSIF mode = "0100" THEN				-- 从两边到中间移位亮
						IF QQ = "00000000000" THEN
							QQ(10) <= '1';
							QQ(0) <= '1';
						ELSE
							QQ(10 DOWNTO 5) <= '0' & QQ(10 DOWNTO 6);
							QQ(4 DOWNTO 0) <= QQ(3 DOWNTO 0) & '0';
						END IF;
					ELSIF mode = "0101" THEN				-- 从左到右依次亮，从右到左依次灭
						IF flag = '0' THEN
							QQ <= '1' & QQ(10 DOWNTO 1);
						ELSE
							QQ <= QQ(9 DOWNTO 0) & '0';
						END IF;
					ELSIF mode = "0110" THEN				-- 从中间向两边依次亮，反向依次灭
						IF flag = '0' THEN
							QQ(10 DOWNTO 5) <= QQ(9 DOWNTO 5) & '1';
							QQ(5 DOWNTO 0) <= '1' & QQ(5 DOWNTO 1);
						ELSE
							QQ(10 DOWNTO 5) <= '0' & QQ(10 DOWNTO 6);
							QQ(5 DOWNTO 0) <= QQ(4 DOWNTO 0) & '0';
						END IF;
					ELSIF mode = "0111" THEN				-- 从两边向中间依次亮，反向依次灭
						IF flag = '0' THEN
							QQ(10 DOWNTO 5) <= '1' & QQ(10 DOWNTO 6);
							QQ(5 DOWNTO 0) <= QQ(4 DOWNTO 0) & '1';
						ELSE
							QQ(10 DOWNTO 5) <= QQ(9 DOWNTO 5) & '0';
							QQ(5 DOWNTO 0) <= '0' & QQ(5 DOWNTO 1);
						END IF;
					ELSIF mode = "1000" THEN				--彩灯全部亮
						IF flag = '0' THEN
							QQ <= (OTHERS => '1');
						ELSE
							QQ <= (OTHERS => '0');
						END IF;
					ELSE
						QQ <= (OTHERS => '0');
					END IF;
				ELSE
					mode_before <= mode;
					QQ <= (OTHERS => '0');
				END IF;
			END IF;

			IF rising_edge(clk) THEN
				IF QQ = "00000000000" THEN					-- 彩灯标志位
					flag <= '0';
				ELSIF QQ = "11111111111" THEN
					flag <= '1';
				ELSE
					NULL;
				END IF;
			END IF;
		ELSE
			QQ <= (OTHERS => '0');
		END IF;
	END PROCESS;

	PROCESS (SW1, mode, mode_disp)							--显示控制进程
	BEGIN
		IF SW1 = '1' THEN
			IF mode = "0000" THEN
				word0 <= "0101111";							-- 七段译码管c
				word1 <= "1000111";							-- l
				word2 <= "1000110";							-- r
			ELSE
				word0 <= mode_disp;							-- 模式选择
				word1 <= "0001110";							-- L
				word2 <= "1000111";							-- F
			END IF;
			CASE mode IS
				WHEN "0001" => mode_disp <= "1111001";		-- 1到8
				WHEN "0010" => mode_disp <= "0100100";		
				WHEN "0011" => mode_disp <= "0110000";
				WHEN "0100" => mode_disp <= "0011001";
				WHEN "0101" => mode_disp <= "0010010";
				WHEN "0110" => mode_disp <= "0000010";
				WHEN "0111" => mode_disp <= "1111000";
				WHEN "1000" => mode_disp <= "0000000";
				WHEN OTHERS => mode_disp <= "1111111";
			END CASE;
		ELSE
			word0 <= "0001110";								-- f
			word1 <= "0001110";								-- f
			word2 <= "1000000";								-- o
		END IF;
	END PROCESS;

	PROCESS (clock, an1)
	BEGIN
		IF an1 = '1' THEN									-- 键盘防抖,仿真
			IF rising_edge(clock) THEN
				IF ancounter='0' THEN					-- ancounter足够大才算，防止抖动
					ancounter <='1';
				ELSE 
					ancounter <='1';
				END IF;
			END IF;
		ELSE
			ancounter <= '0';
		END IF;
	END PROCESS;

	PROCESS (ancounter, SW1)
	BEGIN
		IF SW1 = '1' THEN
			IF rising_edge(ancounter) THEN				-- 抖动
				IF mode = "1000" THEN						-- 转换模式
					mode <= "0000";
				ELSE
					mode <= mode + 1;
				END IF;
			ELSE
				NULL;
			END IF;
		ELSE
			mode <= "0000";
		END IF;
	END PROCESS;
END ARCHITECTURE;