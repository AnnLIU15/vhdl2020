LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY IR IS

	GENERIC (
		dlen : INTEGER := 8;		-- 数据长度8位
		OpAddr : INTEGER := 16		-- 地址长度16
	);
	PORT (
		EN : IN STD_LOGIC;			-- 使能
		opin : IN STD_LOGIC_VECTOR(OpAddr - 1 DOWNTO 0);-- 进入的指令
		opout : OUT STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0);-- 输出的操作符
		adout : OUT STD_LOGIC_VECTOR(dlen - 1 DOWNTO 0)	-- 输出的地址符
	);
END ENTITY;

ARCHITECTURE bev OF IR IS
	SIGNAL opcodeseg : STD_LOGIC_VECTOR(OpAddr - 1 DOWNTO 0) := (OTHERS => 'Z');
	-- 操作暂存
	BEGIN
	PROCESS (EN, opin)
	BEGIN
		IF rising_edge(EN) THEN --使能时候译码
			opcodeseg <= opin;
		END IF;
	END PROCESS;
	opout <= opcodeseg(OpAddr - 1 DOWNTO dlen);	-- 操作符输出
	adout <= opcodeseg(dlen - 1 DOWNTO 0);		-- 地址输出
END ARCHITECTURE;