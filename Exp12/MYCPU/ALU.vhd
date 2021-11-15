LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY ALU IS
	GENERIC (
		dlen : INTEGER := 8--数据长度8位
	);
	PORT (
		clk : IN STD_LOGIC;								-- 时钟
		reset : IN STD_LOGIC;							-- 清零
		op : IN STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);	-- 指令
		Acc : IN STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0); 	-- 累计器数据
		RamVal : IN STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);-- *addr
		ALUout : OUT STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0)-- ALU输出
	);

END ENTITY;
ARCHITECTURE bev OF ALU IS
	SIGNAL tmpseg : STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0); --输出暂存
BEGIN
	PROCESS (clk, reset)
	BEGIN
		IF reset = '1' THEN
			tmpseg <= x"00";							-- 清零
		ELSIF rising_edge(clk) THEN
			CASE op IS
				WHEN x"00" => tmpseg <= Acc + RamVal; 	-- 相加
				WHEN x"01" => tmpseg <= Acc; 			-- 存储
				WHEN x"02" => tmpseg <= RamVal; 		-- 加载
				WHEN OTHERS =>
					tmpseg <= Acc; 						-- 无效动作
			END CASE;
		END IF;
	END PROCESS;
	ALUout <= tmpseg; 									--输出
END ARCHITECTURE;