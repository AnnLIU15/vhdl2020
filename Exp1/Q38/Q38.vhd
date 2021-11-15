LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY Q38 IS
	PORT (
		A : IN STD_LOGIC_VECTOR(2 DOWNTO 0); 	-- A输入端口
		G1, G2A, G2B : IN STD_LOGIC; 			-- G1,G2A,G2B控制端口			
		Y : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) 	-- 输出端口Y
	);
END ENTITY;
ARCHITECTURE QQQ OF Q38 IS
BEGIN
	P1 : PROCESS (A, G1, G2A, G2B)
	BEGIN
		IF (G1 = '1' AND G2A = '0' AND G2B = '0') THEN
			CASE A IS
				WHEN "000" => Y <= "11111110";	-- 位置0
				WHEN "001" => Y <= "11111101";	-- 位置1
				WHEN "010" => Y <= "11111011";	-- 位置2
				WHEN "011" => Y <= "11110111";	-- 位置3
				WHEN "100" => Y <= "11101111";	-- 位置4
				WHEN "101" => Y <= "11011111";	-- 位置5
				WHEN "110" => Y <= "10111111";	-- 位置6
				WHEN "111" => Y <= "01111111";	-- 位置7
				WHEN OTHERS => Y <= "XXXXXXXX";
			END CASE;
		ELSE
			Y <= "11111111";
		END IF;
	END PROCESS;
END ARCHITECTURE;