LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY RAM IS
    PORT (
        CLK : IN STD_LOGIC;                         -- 时钟
        WE : IN STD_LOGIC;                          -- 写信号
        RE : IN STD_LOGIC;                          -- 读信号
        Indata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);   -- 写入data
        highPos : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- 七段译码管高位
        lowPos : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- 七段译码管低位
        addR : IN STD_LOGIC_VECTOR(4 DOWNTO 0)      -- 选的地址
    );
END ENTITY;

ARCHITECTURE bev OF RAM IS
    TYPE RAMMEMORY IS ARRAY(31 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL MYRAM : RAMMEMORY;                       -- 建立一个寄存器，当作ram，查表模式

    TYPE HexNum IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(6 DOWNTO 0);
                                                    -- 16进制的七段译码管显示
    CONSTANT SEG7 : HexNum := ("1000000", "1111001", "0100100", "0110000", "0011001", "0010010", "0000010", "1111000", "0000000", "0010000", "0001000", "0000011", "1000110", "0100001", "0000110", "0001110");
    -- 十六种显示
BEGIN
    PROCESS (CLK)
    BEGIN
        IF rising_edge(CLK) THEN                                        -- 时钟上升沿触发
            IF (WE = '1' AND RE = '1') THEN                             -- 读写同时，读写入信号
                MYRAM(CONV_INTEGER(addR)) <= Indata;                    -- 写入
                highPos <= SEG7(CONV_INTEGER(Indata(7 DOWNTO 4)));      -- 读写入信号输出到七段译码管
                lowPos <= SEG7(CONV_INTEGER(Indata(3 DOWNTO 0)));       
            ELSIF WE = '1' THEN
                MYRAM(CONV_INTEGER(addR)) <= Indata;                    -- 写入
            ELSIF RE = '1' THEN
                highPos <= SEG7(CONV_INTEGER(MYRAM(CONV_INTEGER(addR))(7 DOWNTO 4)));   -- 读入
                lowPos <= SEG7(CONV_INTEGER(MYRAM(CONV_INTEGER(addR))(3 DOWNTO 0)));
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;