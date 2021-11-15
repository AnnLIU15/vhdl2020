library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity vga_pic_move is
	port(
		sys_clk:in std_logic;
		sys_rst_n:in std_logic;
		vga_clk_out:out std_logic;
		vga_blank_n:out std_logic;
		vga_sync_n:out std_logic;
		vga_hs:out std_logic;
		vga_vs:out std_logic;
		vga_rgb:out std_logic_vector(23 downto 0));
end vga_pic_move;

architecture behav of vga_pic_move is
component vga_pll is
	port(
		inclk0		: in STD_LOGIC  := '0';
		c0				: out STD_LOGIC ;
		locked		: out STD_LOGIC 
	);
end component;

component rom_pic is
	port(
		address	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		rden		: IN STD_LOGIC  := '1';
		q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
end component;

component freq_divider is
	generic(
		COUNT_MAX:natural);
	port(
		clk_in	:in std_logic;
		clk_out	:out std_logic);
end component;

component vga_driver is
	port(
		vga_clk:in std_logic;
		sys_rstn:in std_logic;
		pixel_data:in std_logic_vector(23 downto 0);
		vga_hs,vga_vs:out std_logic;
		vga_rgb:out std_logic_vector(23 downto 0);
		xpos:out std_logic_vector(9 downto 0);
		ypos:out std_logic_vector(9 downto 0)
	);
end component;
signal clk25MHz:std_logic;
signal move_clk:std_logic;
signal vga_vs_sig:std_logic;
signal frame_rst:std_logic;
signal clock_locked:std_logic;
signal xpos:std_logic_vector(9 downto 0);
signal ypos:std_logic_vector(9 downto 0);
signal pixel_data:std_logic_vector(23 downto 0);
signal address:std_logic_vector(15 downto 0);
signal readen:std_logic;
signal data_valid:std_logic;
signal pic_data:std_logic_vector(15 downto 0);
signal pic_data_extend:std_logic_vector(23 downto 0);
constant total_pix:integer:=60000;
signal POS_X:integer  := 0;
signal POS_Y:integer  := 0;
constant MAX_POS_X:integer  := 340;
constant MAX_POS_Y:integer  := 280;
constant PIC_WIDTH:integer  := 300;
constant PIC_HEIGHT:integer  := 200;
type STATES is (goright,godown,goleft,goup);
signal current_state,next_state:STATES;
begin

	vga_pll_inst : vga_pll port map (
			inclk0	=> sys_clk,
			c0	 		=> clk25MHz,
			locked	=> clock_locked
		);
	vga_driver_inst : vga_driver port map (
			vga_clk		=>clk25MHz,
			sys_rstn		=>clock_locked,
			pixel_data	=>pixel_data,
			vga_hs		=>vga_hs,
			vga_vs		=>vga_vs_sig,
			vga_rgb		=>vga_rgb,
			xpos			=>xpos,
			ypos			=>ypos
			);
	rom_pic_inst : rom_pic port map (
			address	=> address,
			clock	 	=> clk25MHz,
			rden	 	=> readen,
			q	 	 	=> pic_data
		);
	freq_divider_inst:freq_divider generic map(
			COUNT_MAX=>250000
		) port map (
			clk_in	=>sys_clk,
			clk_out	=>move_clk
		);
	process(clk25MHz,sys_rst_n)
	begin
		if sys_rst_n='0' then
			data_valid<='0';
		else
			if clk25MHz'event and clk25MHz='1' then
				data_valid<=readen;
			end if;
		end if;
	end process;
	
	process(clk25MHz,frame_rst,data_valid)
	begin
		if frame_rst='0' then
			address<=(others=>'0');
		elsif data_valid='1' then
			if clk25MHz'event and clk25MHz='1' then
				if address<total_pix-1 then
					address<=address+1;
				else
					address<=(others=>'0');
				end if;
			end if;
		end if;
	end process;
	
--	process(move_clk,sys_rst_n)
--	begin
--		if sys_rst_n='0' then
--			POS_X<=0;
--			POS_Y<=0;
--		else
--			if move_clk'event and move_clk='1' then
--				if POS_X<MAX_POS_X AND POS_Y<MAX_POS_Y then
--					POS_X<=POS_X+1;
--					POS_Y<=POS_Y+1;
--				else
--					POS_X<=0;
--					POS_Y<=0;
--				end if;
--			end if;
--		end if;
--	end process;
	
	process(move_clk,next_state,sys_rst_n)
	begin
		if sys_rst_n='0' then
			current_state<=goright;
		else
			current_state<=next_state;
		end if;
	end process;
	
	process(current_state,POS_X,POS_Y)
	begin
		case current_state is
			when goright=>
				if POS_X<MAX_POS_X-1 then
					next_state<=goright;
				else
					next_state<=godown;
				end if;
			when godown=>
				if POS_Y<MAX_POS_Y-1 then
					next_state<=godown;
				else
					next_state<=goleft;
				end if;
			when goleft=>
				if POS_X>1 then
					next_state<=goleft;
				else
					next_state<=goup;
				end if;
			when goup=>
				if POS_Y>1 then
					next_state<=goup;
				else
					next_state<=goright;
				end if;
			when others=>null;
		end case;
	end process;

	process(move_clk,sys_rst_n,current_state,POS_X)
	begin
		if sys_rst_n='0' then
			POS_X<=0;
		else
			if move_clk'event and move_clk='1' then
				if current_state=goright then
					POS_X<=POS_X+1;
				elsif current_state=godown then
					POS_X<=MAX_POS_X-1;
				elsif current_state=goleft then
					POS_X<=POS_X-1;
				elsif current_state=goup then
					POS_X<=0;
				end if;
			end if;
		end if;
	end process;
	
	process(move_clk,sys_rst_n,current_state,POS_Y)
	begin
		if sys_rst_n='0' then
			POS_Y<=0;
		else
			if move_clk'event and move_clk='1' then
				if current_state=goright then
					POS_Y<=0;
				elsif current_state=godown then
					POS_Y<=POS_Y+1;
				elsif current_state=goleft then
					POS_Y<=MAX_POS_Y-1;
				elsif current_state=goup then
					POS_Y<=POS_Y-1;
				end if;
			end if;
		end if;
	end process;
	
	vga_vs<=vga_vs_sig;
	frame_rst<=vga_vs_sig and sys_rst_n;
	vga_clk_out <=clk25MHz;
	vga_blank_n <= '1';
	vga_sync_n <= '0';
	pic_data_extend<=(pic_data(15 downto 11)&"000"&pic_data(10 downto 5)&"00"&pic_data(4 downto 0)&"000");
	pixel_data<=pic_data_extend when data_valid='1' else "000000000000000000000000";
	readen<='1' when 	(xpos >= POS_X) and 
							(xpos < 	POS_X + PIC_WIDTH) and
							(ypos >= POS_Y) and
							(ypos < 	POS_Y + PIC_HEIGHT) else '0';
end behav;