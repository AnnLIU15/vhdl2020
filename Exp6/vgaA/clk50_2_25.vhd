LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY clk50_2_25 IS
	PORT (
		inclk : IN STD_LOGIC;	-- 分频前
		outclk : OUT STD_LOGIC	-- 分频后
	);
END ENTITY;

ARCHITECTURE bev OF clk50_2_25 IS
	SIGNAL outclktemp : STD_LOGIC;
BEGIN
	PROCESS (inclk)
	BEGIN
		IF rising_edge(inclk) THEN
			outclktemp <= NOT outclktemp;	-- 分频
		END IF;
	END PROCESS;
	PROCESS (outclktemp)
	BEGIN
		outclk <= outclktemp;				-- 分频寄存
	END PROCESS;
END ARCHITECTURE;