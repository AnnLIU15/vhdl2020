rom_pic_inst : rom_pic PORT MAP (
		address	 => address_sig,
		clock	 => clock_sig,
		rden	 => rden_sig,
		q	 => q_sig
	);
