LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
USE WORK.ALL;
ENTITY LPMRAM IS
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
ARCHITECTURE bev OF LPMRAM IS
   SIGNAL OUTDATA : STD_LOGIC_VECTOR(7 DOWNTO 0):=X"00"; -- ram输出
   TYPE HexNum IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR(6 DOWNTO 0);
                                                    -- 16进制的七段译码管显示
   CONSTANT SEG7 : HexNum := ("1000000", "1111001", "0100100", "0110000", "0011001", "0010010", "0000010", "1111000", "0000000", "0010000", "0001000", "0000011", "1000110", "0100001", "0000110", "0001110");
BEGIN

RAM8_inst : RAM8 PORT MAP (
		address	 => addR, 
		clock	 => CLK,	-- 时钟上升沿触发
		data	 => Indata,
		rden	 => RE,
		wren	 => WE,
		q	 => OUTDATA
	);
	highPos <= SEG7(CONV_INTEGER(OUTDATA(7 DOWNTO 4)));
	lowPos <= SEG7(CONV_INTEGER(OUTDATA(3 DOWNTO 0)));
END ARCHITECTURE;