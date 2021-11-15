LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- 一段式有限状态机
ENTITY fsm1 IS
	PORT (
		clk : IN STD_LOGIC; -- 时钟 
		w : IN STD_LOGIC; -- 输入
		rst : IN STD_LOGIC; -- 清零
		z : OUT STD_LOGIC); -- 输出
END ENTITY;
ARCHITECTURE bev OF fsm1 IS
	TYPE state IS (s0, s1, s2, s3); -- 状态
	SIGNAL current_state : state; -- 单状态
	SIGNAL wordtmp : STD_LOGIC;
BEGIN
	PROCESS (clk, rst)
	BEGIN
		IF rst = '1' THEN
			current_state <= s0;
		ELSIF rising_edge(clk) THEN
			CASE current_state IS 		-- 判断连续的1/0个数
										-- 如果多于4个，当8个时候再显示z=1，以此类推
				WHEN s0 =>
					z <= '0';
					wordtmp <= w;
					current_state <= s1;
				WHEN s1 =>				-- 2
					z <= '0';
					IF w = wordtmp THEN
						current_state <= s2;
					ELSE
						current_state <= s1;
						wordtmp <= w;
					END IF;
				WHEN s2 =>				-- 3
					z <= '0';
					IF w = wordtmp THEN
						current_state <= s3;
					ELSE
						current_state <= s1;
						wordtmp <= w;
					END IF;
				WHEN s3 =>				-- 4输出
					IF w = wordtmp THEN
						current_state <= s0;
						z <= '1';
					ELSE
						current_state <= s1;
						z <= '0';
						wordtmp <= w;
					END IF;
				WHEN OTHERS =>
					current_state <= s1;
					z <= '0';
					wordtmp <= w;
			END CASE;
		END IF;
	END PROCESS;

END ARCHITECTURE;