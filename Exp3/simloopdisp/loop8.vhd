LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY loop8 IS
    PORT (
        clk : IN STD_LOGIC;
        clk1 : IN STD_LOGIC;
        seg0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 循环显示8位
        seg1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        seg2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        seg3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        seg4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        seg5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        seg6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE bev OF loop8 IS
    SIGNAL counter : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL clk1s : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
    SIGNAL s1 : STD_LOGIC := '0';
    CONSTANT w0 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1000000"; --数字0~f
    CONSTANT w1 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111001";
    CONSTANT w2 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0100100";
    CONSTANT w3 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0110000";
    CONSTANT w4 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0011001";
    CONSTANT w5 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0010010";
    CONSTANT w6 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000010";
    CONSTANT w7 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111000";
    CONSTANT w8 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
    CONSTANT w9 : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0010000";
    CONSTANT wa : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0001000";
    CONSTANT wb : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000011";
    CONSTANT wc : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1000110";
    CONSTANT wd : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0100001";
    CONSTANT we : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000110";
    CONSTANT wf : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0001110";
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF clk1s = "11" THEN
                clk1s <= (OTHERS => '0');
                s1 <= NOT s1;
            ELSE
                clk1s <= clk1s + 1;
            END IF;
        END IF;

    END PROCESS;
    PROCESS (s1)
    BEGIN
        IF rising_edge(s1) THEN
            IF counter = "1111" THEN
                counter <= "0000";
            ELSE
                counter <= counter + 1;
            END IF;
        END IF;

    END PROCESS;
    PROCESS (clk1, counter)
    BEGIN
        IF rising_edge(clk1) THEN
            CASE counter IS
                WHEN "0000" => -- 状态1，循环0~f
                    seg0 <= w0;
                    seg1 <= w1;
                    seg2 <= w2;
                    seg3 <= w3;
                    seg4 <= w4;
                    seg5 <= w5;
                    seg6 <= w6;
                    seg7 <= w7;

                WHEN "0001" =>
                    seg0 <= w1;
                    seg1 <= w2;
                    seg2 <= w3;
                    seg3 <= w4;
                    seg4 <= w5;
                    seg5 <= w6;
                    seg6 <= w7;
                    seg7 <= w8;
                WHEN "0010" =>
                    seg0 <= w2;
                    seg1 <= w3;
                    seg2 <= w4;
                    seg3 <= w5;
                    seg4 <= w6;
                    seg5 <= w7;
                    seg6 <= w8;
                    seg7 <= w9;
                WHEN "0011" =>
                    seg0 <= w3;
                    seg1 <= w4;
                    seg2 <= w5;
                    seg3 <= w6;
                    seg4 <= w7;
                    seg5 <= w8;
                    seg6 <= w9;
                    seg7 <= wa;
                WHEN "0100" =>
                    seg0 <= w4;
                    seg1 <= w5;
                    seg2 <= w6;
                    seg3 <= w7;
                    seg4 <= w8;
                    seg5 <= w9;
                    seg6 <= wa;
                    seg7 <= wb;
                WHEN "0101" =>
                    seg0 <= w5;
                    seg1 <= w6;
                    seg2 <= w7;
                    seg3 <= w8;
                    seg4 <= w9;
                    seg5 <= wa;
                    seg6 <= wb;
                    seg7 <= wc;
                WHEN "0110" =>
                    seg0 <= w6;
                    seg1 <= w7;
                    seg2 <= w8;
                    seg3 <= w9;
                    seg4 <= wa;
                    seg5 <= wb;
                    seg6 <= wc;
                    seg7 <= wd;
                WHEN "0111" =>
                    seg0 <= w7;
                    seg1 <= w8;
                    seg2 <= w9;
                    seg3 <= wa;
                    seg4 <= wb;
                    seg5 <= wc;
                    seg6 <= wd;
                    seg7 <= we;
                WHEN "1000" =>
                    seg0 <= w8;
                    seg1 <= w9;
                    seg2 <= wa;
                    seg3 <= wb;
                    seg4 <= wc;
                    seg5 <= wd;
                    seg6 <= we;
                    seg7 <= wf;
                WHEN "1001" =>
                    seg0 <= w9;
                    seg1 <= wa;
                    seg2 <= wb;
                    seg3 <= wc;
                    seg4 <= wd;
                    seg5 <= we;
                    seg6 <= wf;
                    seg7 <= w0;
                WHEN "1010" =>
                    seg0 <= wa;
                    seg1 <= wb;
                    seg2 <= wc;
                    seg3 <= wd;
                    seg4 <= we;
                    seg5 <= wf;
                    seg6 <= w0;
                    seg7 <= w1;
                WHEN "1011" =>
                    seg0 <= wb;
                    seg1 <= wc;
                    seg2 <= wd;
                    seg3 <= we;
                    seg4 <= wf;
                    seg5 <= w0;
                    seg6 <= w1;
                    seg7 <= w2;
                WHEN "1100" =>
                    seg0 <= wc;
                    seg1 <= wd;
                    seg2 <= we;
                    seg3 <= wf;
                    seg4 <= w0;
                    seg5 <= w1;
                    seg6 <= w2;
                    seg7 <= w3;
                WHEN "1101" =>
                    seg0 <= wd;
                    seg1 <= we;
                    seg2 <= wf;
                    seg3 <= w0;
                    seg4 <= w1;
                    seg5 <= w2;
                    seg6 <= w3;
                    seg7 <= w4;
                WHEN "1110" =>
                    seg0 <= we;
                    seg1 <= wf;
                    seg2 <= w0;
                    seg3 <= w1;
                    seg4 <= w2;
                    seg5 <= w3;
                    seg6 <= w4;
                    seg7 <= w5;
                WHEN "1111" =>
                    seg0 <= wf;
                    seg1 <= w0;
                    seg2 <= w1;
                    seg3 <= w2;
                    seg4 <= w3;
                    seg5 <= w4;
                    seg6 <= w5;
                    seg7 <= w6;
                WHEN OTHERS =>
                    seg0 <= (OTHERS => '1');
                    seg1 <= (OTHERS => '1');
                    seg2 <= (OTHERS => '1');
                    seg3 <= (OTHERS => '1');
                    seg4 <= (OTHERS => '1');
                    seg5 <= (OTHERS => '1');
                    seg6 <= (OTHERS => '1');
                    seg7 <= (OTHERS => '1');
            END CASE;
        END IF;

    END PROCESS;
END ARCHITECTURE;