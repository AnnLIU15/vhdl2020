LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY PCT IS
	GENERIC (
		dlen : INTEGER := 8--数据长度8位
	);
	PORT (
		clk : IN STD_LOGIC;						-- 时钟
		RESET : IN STD_LOGIC;					-- 重置
		opCode : IN STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);-- 操作符
		AccIn : IN STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);	-- AC数据
		inaddr : IN STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);-- RAM数据
		outaddr : OUT STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0)-- 下一轮地址
	);

END ENTITY;
ARCHITECTURE bev OF PCT IS
	SIGNAL outaddrseg : STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);
BEGIN
	PROCESS (clk, RESET)
	BEGIN
		IF RESET = '1' THEN							-- 清零
			outaddrseg <= X"00";
		ELSIF rising_edge(clk) THEN					-- 操作符译码
			IF opCode = x"03" THEN
				outaddrseg <= inaddr;				-- 跳转
			ELSIF opCode = x"04" THEN
				IF AccIn(dlen - 1) = '1' THEN
					outaddrseg <= inaddr;			--跳转
				ELSE
					outaddrseg <= outaddrseg + '1';
				END IF;
			ELSE
				IF outaddrseg < x"ff" THEN			-- 自增
					outaddrseg <= outaddrseg + '1';
				ELSE
					outaddrseg <= (OTHERS => '0');
				END IF;
			END IF;
		END IF;
	END PROCESS;
	outaddr <= outaddrseg;							-- 从寄存拿
END ARCHITECTURE;