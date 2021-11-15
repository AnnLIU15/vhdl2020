LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY myclock IS
    PORT (
        clk : 											IN STD_LOGIC;		-- FPGA时钟
		  set_ala : 									IN STD_LOGIC;		-- 设置闹钟
        adjust : 										IN STD_LOGIC;		-- 校时
        select_position : 							IN STD_LOGIC;		-- 选择分秒位置，然后配合adjust校正时间
        confirm : 									IN STD_LOGIC;		-- 确认设置
        EN : 											IN STD_LOGIC;		-- 时钟是否开始运行
		  ala_open : 									OUT STD_LOGIC;		-- 闹钟是否被激活
        min_decade_disp : 	OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- 分钟10位
        min_unit_disp : 	OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- 分钟个位
        sec_decade_disp : 	OUT STD_LOGIC_VECTOR(6 DOWNTO 0);	-- 秒钟十位
        sec_unit_disp : 	OUT STD_LOGIC_VECTOR(6 DOWNTO 0)		-- 秒钟个位
		  );
END ENTITY;
ARCHITECTURE bev OF myclock IS
    TYPE num2disp IS ARRAY (0 TO 9) OF STD_LOGIC_VECTOR(6 DOWNTO 0);
    CONSTANT seg7 : num2disp := ("1000000", "1111001", "0100100", "0110000", "0011001", "0010010", "0000010", "1111000", "0000000", "0010000");
	 SIGNAL alaopenseg:STD_LOGIC;					-- 闹钟开启的寄存器
    SIGNAL min_10 : INTEGER RANGE 0 TO 5;		-- 分钟十位寄存器
    SIGNAL min_1 : INTEGER RANGE 0 TO 9;		-- 分钟个位寄存器
    SIGNAL sec_10 : INTEGER RANGE 0 TO 5;		-- 秒钟十位寄存器
    SIGNAL sec_1 : INTEGER RANGE 0 TO 9;		-- 秒钟个位寄存器
    SIGNAL amin10 : INTEGER RANGE 0 TO 5;		-- 闹钟分钟十位寄存器
    SIGNAL amin1 : INTEGER RANGE 0 TO 9;		-- 闹钟分钟个位寄存器
    SIGNAL asec10 : INTEGER RANGE 0 TO 5;		-- 闹钟秒钟十位寄存器
    SIGNAL asec1 : INTEGER RANGE 0 TO 9;		-- 闹钟秒钟个位寄存器
    SIGNAL clkcounter : STD_LOGIC_VECTOR(1 DOWNTO 0);	
															-- 将50MHz转为1s的计数器
    SIGNAL ala_on : STD_LOGIC;					-- 闹钟开启标志，是否已经设置闹钟
    SIGNAL CLOCK : STD_LOGIC;						-- 1s跳变时钟
    SIGNAL selectPosBlink : STD_LOGIC; 		-- 选位闪烁
    SIGNAL clockMode : STD_LOGIC_VECTOR(1 DOWNTO 0);
															-- "00" 显示时间
															-- "01" 调整时间
															-- "10" 设置闹钟时间
															-- "11" 停止显示
    SIGNAL selectedPos : STD_LOGIC_VECTOR(1 DOWNTO 0);
	 -- 选择位置
    SIGNAL adjStab : STD_LOGIC_VECTOR(9 DOWNTO 0);
	 -- 调整数字的时候防抖稳定
    SIGNAL selModeStab : STD_LOGIC_VECTOR(9 DOWNTO 0);
	 -- 调整模式的时候防抖稳定
    SIGNAL alaStab : STD_LOGIC_VECTOR(9 DOWNTO 0);
	 -- 设置闹钟的时候防抖稳定
    SIGNAL confirmStab : STD_LOGIC_VECTOR(9 DOWNTO 0);
	 -- 确认设置的时候防抖稳定
BEGIN
    time1s : PROCESS (clk, clockMode, EN)
	 -- 50Mhz->1Hz时钟
	 -- 选位时候闪烁
    BEGIN
        IF EN = '1' THEN																		-- 时钟使能
            IF clockMode = "11" THEN														-- 暂停
                CLOCK <= '0';
                clkcounter <= (OTHERS => '0');											-- 清零
            ELSIF rising_edge(clk) THEN													-- 正常转换
                IF clkcounter = "11" THEN													-- 仿真
                    CLOCK <= '1';
                    clkcounter <= (OTHERS => '0');
                ELSE
                    CLOCK <= '0'; 															-- 1s跳转依次
                    clkcounter <= clkcounter + "01";									-- 跳转用的计数器--00000000000000000000000001
                END IF;
                IF clkcounter < "01" THEN 												-- 有0.25秒不显示，闪烁提示使用位置
                    selectPosBlink <= '1';
                ELSE
                    selectPosBlink <= '0';
                END IF;
            END IF;
        ELSE
            clkcounter <= (OTHERS => '0'); 							-- 时钟未开始
            CLOCK <= '0';	 												-- 1s时钟始终为0
            selectPosBlink <= '0'; 										-- 不闪烁
        END IF;
    END PROCESS;
	 alaon : PROCESS (clk, confirm, min_10, min_1, sec_10, sec_1, amin10, amin1, asec10, asec1, clockMode, ala_on)
			-- 判断是否时间到了闹钟的设置时间
    BEGIN
        IF EN = '1' THEN
            IF rising_edge(clk) THEN
                IF ala_on = '1' AND clockMode(1) = '0' AND min_10 = amin10 AND min_1 = amin1 AND sec_10 = asec10 AND sec_1 = asec1 THEN
                    alaopenseg <= '1';						-- 都满足闪烁
                ELSIF confirm = '1' THEN
                    alaopenseg <= '0';
                END IF;
            END IF;
        ELSE
            alaopenseg <= '0';
        END IF;
    END PROCESS;
	 ala_open<=alaopenseg;										-- 输出
	 PROCESS (clk, select_position, set_ala, confirm, clockMode, selectedPos)
	 -- 改变数位、模式
    BEGIN
        IF EN = '1' THEN
            IF rising_edge(clk) THEN
                IF select_position = '1' THEN								-- 模式选择防抖结束
                    IF clockMode = "00" OR clockMode = "11" THEN	-- 调整模式
                        clockMode <= "01";
                    ELSIF clockMode = "01" THEN							-- 改时间
                        IF selectedPos = "11" THEN
                            selectedPos <= "00";
                        ELSE
                            selectedPos <= selectedPos + "01";
                        END IF;
                    ELSE
                        IF selectedPos = "11" THEN
                            selectedPos <= "00";
                            ala_on <= '0';
                        ELSIF ala_on = '0' THEN
                            ala_on <= '1';
                        ELSE
                            selectedPos <= selectedPos + "01";
                        END IF;
                    END IF;
                ELSIF set_ala = '1' THEN							-- 闹钟的防抖
                    IF clockMode = "00" THEN
                        clockMode <= "10";
                    END IF;
                ELSIF confirm = '1' THEN						-- 确认的防抖
                    IF alaopenseg = '0' THEN
                        IF clockMode = "01" THEN
                            clockMode <= "11";
                            selectedPos <= "00";
                        ELSIF clockMode = "10" THEN
                            clockMode <= "00";
                            selectedPos <= "00";
                        ELSIF clockMode = "11" THEN
                            clockMode <= "00";
                        END IF;
                    END IF;
                END IF;
            END IF;
        ELSE
            ala_on <= '0';
            selectedPos <= "00";
            clockMode <= "00";
        END IF;
    END PROCESS;
    dispnum : PROCESS (min_10, min_1, sec_10, sec_1, amin10, amin1, asec10, asec1, ala_on, selectPosBlink, clockMode, selectedPos)
			-- 显示端，时间运行与调整的显示
    BEGIN
        IF EN = '1' THEN
            IF clockMode = "00" OR clockMode = "11" THEN	-- 当停止或者运行的时候显示 显示时间(与调整时间对应)
                min_decade_disp <= seg7(min_10);			-- 分10
                min_unit_disp <= seg7(min_1);				-- 分1
                sec_decade_disp <= seg7(sec_10);			-- 秒10
                sec_unit_disp <= seg7(sec_1);				-- 秒1
            ELSIF clockMode = "01" THEN						-- 设置时间
                CASE selectedPos IS
                    WHEN "00" =>									-- 设置秒1
                        min_decade_disp <= seg7(min_10);
                        min_unit_disp <= seg7(min_1);
                        sec_decade_disp <= seg7(sec_10);
                        IF selectPosBlink = '1' THEN --亮屏
                            sec_unit_disp <= seg7(sec_1);
                        ELSE
                            sec_unit_disp <= "1111111";
                        END IF;
                    WHEN "01" =>									-- 设置秒10
                        min_decade_disp <= seg7(min_10);
                        min_unit_disp <= seg7(min_1);
                        sec_unit_disp <= seg7(sec_1);
                        IF selectPosBlink = '1' THEN
                            sec_decade_disp <= seg7(sec_10);
                        ELSE
                            sec_decade_disp <= "1111111";
                        END IF;
                    WHEN "10" =>									-- 设置分1
                        min_decade_disp <= seg7(min_10);
                        sec_decade_disp <= seg7(sec_10);
                        sec_unit_disp <= seg7(sec_1);
                        IF selectPosBlink = '1' THEN
                            min_unit_disp <= seg7(min_1);
                        ELSE
                            min_unit_disp <= "1111111";
                        END IF;
                    WHEN OTHERS =>								-- 设置分10
                        min_unit_disp <= seg7(min_1);
                        sec_decade_disp <= seg7(sec_10);
                        sec_unit_disp <= seg7(sec_1);
                        IF selectPosBlink = '1' THEN
                            min_decade_disp <= seg7(min_10);
                        ELSE
                            min_decade_disp <= "1111111";
                        END IF;
                END CASE;
            ELSE
                IF clockMode = "10" THEN
                    IF ala_on = '0' THEN								-- 闹钟初始显示00
                        min_decade_disp <= "1111111";
                        min_unit_disp <= "1000000";
                        sec_decade_disp <= "0001110";
                        sec_unit_disp <= "0001110";
                    ELSE
                        CASE selectedPos IS
                            WHEN "00" =>								-- 设置闹钟秒1
                                min_decade_disp <= seg7(amin10);
                                min_unit_disp <= seg7(amin1);
                                sec_decade_disp <= seg7(asec10);
                                IF selectPosBlink = '1' THEN
                                    sec_unit_disp <= seg7(asec1);
                                ELSE
                                    sec_unit_disp <= "1111111";
                                END IF;
                            WHEN "01" =>								-- 设置闹钟秒10
                                min_decade_disp <= seg7(amin10);
                                min_unit_disp <= seg7(amin1);
                                sec_unit_disp <= seg7(asec1);
                                IF selectPosBlink = '1' THEN
                                    sec_decade_disp <= seg7(asec10);
                                ELSE
                                    sec_decade_disp <= "1111111";
                                END IF;
                            WHEN "10" =>								-- 设置闹钟分1
                                min_decade_disp <= seg7(amin10);
                                sec_decade_disp <= seg7(asec10);
                                sec_unit_disp <= seg7(asec1);
                                IF selectPosBlink = '1' THEN
                                    min_unit_disp <= seg7(amin1);
                                ELSE
                                    min_unit_disp <= "1111111";
                                END IF;
                            WHEN OTHERS =>							-- 设置闹钟分10
                                min_unit_disp <= seg7(amin1);
                                sec_decade_disp <= seg7(asec10);
                                sec_unit_disp <= seg7(asec1);
                                IF selectPosBlink = '1' THEN
                                    min_decade_disp <= seg7(amin10);
                                ELSE
                                    min_decade_disp <= "1111111";
                                END IF;
                        END CASE;
                    END IF;
                END IF;
            END IF;
        ELSE
            min_decade_disp <= "1111111";
            min_unit_disp <= "1111111";
            sec_decade_disp <= "1111111";
            sec_unit_disp <= "1111111";
        END IF;
    END PROCESS;
	 setala : PROCESS (clk, adjust, clockMode, selectedPos)
	 -- 设置闹钟
    BEGIN
        IF EN = '1' THEN
            IF rising_edge(clk) THEN
                IF clockMode = "10" THEN						-- 闹钟模式
                    IF adjust = '1' THEN						-- 防抖结束
                        CASE selectedPos IS					-- 调整
                            WHEN "00" =>
                                IF asec1 = 9 THEN
                                    asec1 <= 0;
                                ELSE
                                    asec1 <= asec1 + 1;
                                END IF;
                            WHEN "01" =>
                                IF asec10 = 5 THEN
                                    asec10 <= 0;
                                ELSE
                                    asec10 <= asec10 + 1;
                                END IF;
                            WHEN "10" =>
                                IF amin1 = 9 THEN
                                    amin1 <= 0;
                                ELSE
                                    amin1 <= amin1 + 1;
                                END IF;
                            WHEN OTHERS =>
                                IF amin10 = 5 THEN
                                    amin10 <= 0;
                                ELSE
                                    amin10 <= amin10 + 1;
                                END IF;
                        END CASE;
                    END IF;
                END IF;
            END IF;
        ELSE
            amin10 <= 0;
            amin1 <= 0;
            asec10 <= 0;
            asec1 <= 0;
        END IF;
    END PROCESS;
    runtime : PROCESS (clk, CLOCK, EN, adjStab(9), selectedPos, clockMode)
	 -- 运行
    BEGIN
        IF EN = '1' THEN
            IF rising_edge(clk) THEN
                IF clockMode = "01" THEN					-- 调整
                    IF adjStab(9) = '1' THEN
                        CASE selectedPos IS				-- 每一位改，没有进位
                            WHEN "00" =>
                                IF sec_1 = 9 THEN		-- 修改秒0~9
                                    sec_1 <= 0;
                                ELSE
                                    sec_1 <= sec_1 + 1;-- 正常
                                END IF;
                            WHEN "01" =>
                                IF sec_10 = 5 THEN		-- 修改秒0x~5x
                                    sec_10 <= 0;
                                ELSE
                                    sec_10 <= sec_10 + 1;
                                END IF;
                            WHEN "10" =>
                                IF min_1 = 9 THEN		-- 修改分0~9
                                    min_1 <= 0;
                                ELSE
                                    min_1 <= min_1 + 1;
                                END IF;
                            WHEN OTHERS =>				-- 修改分0x~5x
                                IF min_10 = 5 THEN
                                    min_10 <= 0;
                                ELSE
                                    min_10 <= min_10 + 1;
                                END IF;
                        END CASE;
                    END IF;
                ELSIF CLOCK = '1' THEN						-- 如果没有调整，那么我们的时钟正常运行
                    IF sec_1 = 9 THEN						-- 秒个位进位
                        sec_1 <= 0;						
                        IF sec_10 = 5 THEN				-- 秒十位进位
                            sec_10 <= 0;
                            IF min_1 = 9 THEN			-- 分个位进位
                                min_1 <= 0;
                                IF min_10 = 5 THEN		-- 分十位进位
                                    min_10 <= 0;
                                ELSE
                                    min_10 <= min_10 + 1;
                                END IF;
                            ELSE
                                min_1 <= min_1 + 1;
                            END IF;
                        ELSE
                            sec_10 <= sec_10 + 1;
                        END IF;
                    ELSE
                        sec_1 <= sec_1 + 1;
                    END IF;
                END IF;
            END IF;
        ELSE
            min_10 <= 0;
            min_1 <= 0;
            sec_10 <= 0;
            sec_1 <= 0;
        END IF;
    END PROCESS;
END ARCHITECTURE;