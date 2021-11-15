library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity vga_driver is
	port(
		vga_clk:in std_logic;
		sys_rstn:in std_logic;
		pixel_data:in std_logic_vector(23 downto 0);
		vga_hs,vga_vs:out std_logic;
		vga_rgb:out std_logic_vector(23 downto 0);
		xpos:out std_logic_vector(9 downto 0);
		ypos:out std_logic_vector(9 downto 0));
end vga_driver;

architecture behav of vga_driver is
constant hsync:integer:=96;
constant hback:integer:=48;
constant hdisp:integer:=640;
constant hfront:integer:=15;
constant htotal:integer:=800;

constant vsync:integer:=2;
constant vback:integer:=33;
constant vdisp:integer:=480;
constant vfront:integer:=10;
constant vtotal:integer:=525;
signal cnt_h:std_logic_vector(9 downto 0);
signal cnt_v:std_logic_vector(9 downto 0);
signal vga_en:std_logic;
signal data_req:std_logic;
begin
	vga_hs<='0' when cnt_h<=conv_std_logic_vector(hsync-1,10) else '1';
	vga_vs<='0' when cnt_v<=conv_std_logic_vector(vsync-1,10) else '1';
	vga_en<='1' when	(cnt_h>=conv_std_logic_vector(hsync+hback,10)) and 
							(cnt_h<conv_std_logic_vector(hsync+hback+hdisp,10)) and 
							(cnt_v>=conv_std_logic_vector(vsync+vback,10)) and 
							(cnt_v<conv_std_logic_vector(vsync+vback+vdisp,10)) 
							else '0';
	data_req<='1' when	(cnt_h>=conv_std_logic_vector(hsync+hback-1,10)) and 
								(cnt_h<conv_std_logic_vector(hsync+hback+hdisp-1,10)) and 
								(cnt_v>=conv_std_logic_vector(vsync+vback,10)) and 
								(cnt_v<conv_std_logic_vector(vsync+vback+vdisp,10)) 
								else '0';
	vga_rgb<=pixel_data when vga_en='1' else "000000000000000000000000";
	
	xpos<=(cnt_h-conv_std_logic_vector(hsync+hback-1,10)) when data_req='1' else "0000000000";
	ypos<=(cnt_v-conv_std_logic_vector(vsync+vback-1,10)) when data_req='1' else "0000000000";
	process(vga_clk,sys_rstn)
	begin
		if sys_rstn='0' then
			cnt_h<=(others=>'0');
		else
			if vga_clk'event and vga_clk='1' then
				if cnt_h<conv_std_logic_vector(htotal-1,10) then
					cnt_h<=cnt_h+1;
				else
					cnt_h<=(others=>'0');
				end if;
			end if;
		end if;
	end process;
	
	process(vga_clk,sys_rstn)
	begin
		if sys_rstn='0' then
			cnt_v<=(others=>'0');
		else
			if vga_clk'event and vga_clk='1' then
				if cnt_h=conv_std_logic_vector(htotal-1,10) then
					if cnt_v<conv_std_logic_vector(vtotal-1,10) then
						cnt_v<=cnt_v+1;
					else
						cnt_v<=(others=>'0');
					end if;
				end if;
			end if;
		end if;
	end process;
end behav;