LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fsm2 IS
	PORT (
		clk : IN STD_LOGIC;
		w : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		dispstate:out std_logic_vector(3 downto 0);
		z : OUT STD_LOGIC
		);
END ENTITY;
ARCHITECTURE bev OF fsm2 IS
-- 三段式状态机
	TYPE state IS (s0, s1, s2, s3,s4,s5,s6);
	SIGNAL current_state, next_state : state:=s0;
	signal wseg : STD_LOGIC;
	signal outz:STD_LOGIC:='0';
BEGIN
	PROCESS (clk, rst)						-- 更新状态
	BEGIN
		IF rst = '1' THEN
			current_state <= s0;
			wseg<='X';
		ELSIF rising_edge(clk) THEN
			current_state <= next_state;
			wseg<=w;
		END IF;
	END PROCESS;

	PROCESS (rst,current_state)					-- 下一个状态的检测
	BEGIN
		if rst='0' then
		CASE current_state IS
			WHEN s0 =>						-- 1
					outz <= '0';
					if wseg='1' then
					next_state <= s1;
					else
					next_state <=s4;
					end if;
			WHEN s1 =>						-- 2
				outz <= '0';
				IF wseg = '0' THEN
					next_state <= s2;
				ELSE
					next_state <= s4;
				END IF;	
			WHEN s2 =>						-- 3
				outz <= '0';
				IF wseg = '0' THEN
					next_state <= s3;
				ELSE
					next_state <= s4;
					end if;
			WHEN s3 =>						-- 4满足条件输出
				IF wseg = '0' THEN
					next_state <= s0;
					outz <= '1';
				ELSE
					next_state <= s4;
					outz <= '0';
				end if;
			WHEN s4 =>						-- 2
				outz <= '0';
				IF wseg = '1' THEN
					next_state <= s5;
				ELSE
					next_state <= s1;
				END IF;	
			WHEN s5 =>						-- 3
				outz <= '0';
				IF wseg = '1' THEN
					next_state <= s6;
				ELSE
					next_state <= s1;
					end if;
			WHEN s6 =>						-- 4满足条件输出
				IF wseg = '1' THEN
					next_state <= s0;
					outz <= '1';
				ELSE
					next_state <= s1;
					outz <= '0';
				end if;			
			WHEN OTHERS =>
				next_state <= s0;
				outz <= '0';
		END CASE;
	end if;
	END PROCESS;
	process(next_state)
	begin
		case next_state is
		when s0=>dispstate<=x"0";
		when s1=>dispstate<=x"1";
		when s2=>dispstate<=x"2";
		when s3=>dispstate<=x"3";
		when s4=>dispstate<=x"4";
		when s5=>dispstate<=x"5";
		when s6=>dispstate<=x"6";
		end case;
	end process;
	process(outz)
	begin 
	z<=outz;
	end process;
END ARCHITECTURE;