library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity vga_disp1 is
	port(
		clk50MHz:in std_logic;
		clk25MHz_out:out std_logic;
		blank_sw:in std_logic;
		blank:out std_logic;
		sync_sw:in std_logic;
		sync:out std_logic;
		sys_rstn:in std_logic;
		vga_hs,vga_vs:out std_logic;
		vga_rgb:out std_logic_vector(23 downto 0));
end vga_disp1;
architecture behav of vga_disp1 is
component vga_pll IS
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
END component;

component vga_driver is
	port(
		vga_clk:in std_logic;
		sys_rstn:in std_logic;
		pixel_data:in std_logic_vector(23 downto 0);
		vga_hs,vga_vs:out std_logic;
		vga_rgb:out std_logic_vector(23 downto 0);
		xpos:out std_logic_vector(9 downto 0);
		ypos:out std_logic_vector(9 downto 0));
end component;
signal clk25MHz:std_logic;
signal clock_locked:std_logic;
signal xpos:std_logic_vector(9 downto 0);
signal ypos:std_logic_vector(9 downto 0);
signal pixel_data:std_logic_vector(23 downto 0);
constant WHITE  :std_logic_vector(23 downto 0):= "111111111111111111111111";     --RGB565 白色
constant BLACK  :std_logic_vector(23 downto 0):= "000000000000000000000000";     --RGB565 黑色
constant RED    :std_logic_vector(23 downto 0):= "111111110000000000000000";     --RGB565 红色
constant GREEN  :std_logic_vector(23 downto 0):= "000000001111111100000000";     --RGB565 绿色
constant BLUE   :std_logic_vector(23 downto 0):= "000000000000000011111111";     --RGB565 蓝色
constant hdisp:integer:=640;
constant vdisp:integer:=480;
begin
	blank<=blank_sw;
	sync<=sync_sw;
	clk25MHz_out<=clk25MHz;
	vga_pll_inst : vga_pll PORT MAP (
			inclk0	 => clk50MHz,
			c0	 => clk25MHz,
			locked	 => clock_locked
		);
	
	v1:vga_driver port map(	vga_clk=>clk25MHz,sys_rstn=>clock_locked,
									pixel_data=>pixel_data,
									vga_hs=>vga_hs,vga_vs=>vga_vs,
									vga_rgb=>vga_rgb,
									xpos=>xpos,ypos=>ypos
									);
	--pixel_data<="000000000000000011111111";
	process(clk25MHz,sys_rstn)
	begin
		if sys_rstn='0' then
			pixel_data<=(others=>'0');
		else
			if clk25MHz'event and clk25MHz='1' then
				if((xpos >= "0000000000") and (xpos <= conv_std_logic_vector(128*1,10))) then
					pixel_data <= WHITE;
				elsif((xpos >= conv_std_logic_vector(128*1,10)) and (xpos < conv_std_logic_vector(128*2,10))) then
					pixel_data <= BLACK;
				elsif((xpos >= conv_std_logic_vector(128*2,10)) and (xpos < conv_std_logic_vector(128*3,10))) then
					pixel_data <= RED;
				elsif((xpos >= conv_std_logic_vector(128*3,10)) and (xpos < conv_std_logic_vector(128*4,10))) then
					pixel_data <= GREEN;
				else
					pixel_data <= BLUE;
				end if;
			end if;
		end if;
	end process;
end behav;