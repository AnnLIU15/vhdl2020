LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY LED IS
    PORT (
        CLK : IN STD_LOGIC;
        CLK1 : IN STD_LOGIC;
        A : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        SEGCODE : OUT STD_LOGIC_VECTOR(27 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE BEV OF LED IS
    SIGNAL FLAG : STD_LOGIC;
BEGIN
    PROCESS (CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF (A = "000" OR A = "001" OR A = "010") THEN
                FLAG <= '1';                                    -- 是否满足解码要求
            ELSE
                FLAG <= '0';
            END IF;
        END IF;
    END PROCESS;
    PROCESS (CLK1, FLAG)
    BEGIN
        IF RISING_EDGE(CLK1) THEN
            IF FLAG = '1' THEN
                SEGCODE <= "0001001000011010001111000000";      -- HELO
            ELSE
                SEGCODE <= (OTHERS => '1');                     -- 空格
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;