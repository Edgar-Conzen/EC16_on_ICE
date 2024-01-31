-- ****************************************
-- ec16_ext_mngt.vhd
--
-- glue logic (address decoder, data muxer)
-- to attach ram, I/O etc. to the EC16 CPU
--
-- ****************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- ******************************************************
-- memory map (base addresses)
--
--	sel_0 =>	0x0000 .. 0x1FFF 
--					(r/w) EBR boot rom (512 words, mirrored)
--	sel_1 =>	0x2000 .. 0x3FFF
--					(r) Buttons 3..0 (BTN4 is used as reset)
--					(w) LEDs 4..0
--	sel_2 =>	0x4000 .. 0x5FFF
--					(r) DIP-switches
--					(w) 7-Segment digits & decimal points
--	sel_3 =>	0x6000 .. 0x7FFF
--					(r/w) FART Rx/Tx
--					(r)   FART status
--	sel_4 =>	0x8000 .. 0xBFFF--					(r/w) SPRAM (16kWords)
-- ******************************************************

	
entity ec16_decode is
	port(		clk			: in std_logic;
		re			: in std_logic;
		addr		: in std_logic_vector (15 downto 13);
		sel			: out std_logic_vector (4 downto 0);
		din_0		: in std_logic_vector (15 downto 0);
		din_1		: in std_logic_vector (15 downto 0);
		din_2		: in std_logic_vector (15 downto 0);
		din_3		: in std_logic_vector (15 downto 0);
		din_4		: in std_logic_vector (15 downto 0);
		dout		: out std_logic_vector (15 downto 0)
	);
end entity;

	

architecture syn of ec16_decode is

	signal reg_sel		: std_logic_vector (4 downto 0);
	signal s_sel		: std_logic_vector (4 downto 0);

begin
	
	-- address decoder
	s_sel(0) <= '1' when addr(15 downto 13) = "000"  else '0';
	s_sel(1) <= '1' when addr(15 downto 13) = "001"  else '0';
	s_sel(2) <= '1' when addr(15 downto 13) = "010"  else '0';
	s_sel(3) <= '1' when addr(15 downto 13) = "011"  else '0';
	s_sel(4) <= '1' when addr(15 downto 14) = "10"  else '0';
	
	sel <= s_sel;
	
	-- register the decoder outputs at each read cycle
	save_selects : process (clk)
	begin
		if rising_edge(clk) then
			if re='1' then
				reg_sel <= s_sel;
			end if;
		end if;
	end process;
	
	-- use the registered decoder outputs as select for the CPUs din multiplexer
	mux : process(all)
	begin
		case reg_sel is
			when "00001" => dout <= din_0;
			when "00010" => dout <= din_1;
			when "00100" => dout <= din_2;
			when "01000" => dout <= din_3;
			when "10000" => dout <= din_4;
			when others => dout <= x"0000";
		end case;	end process;	

end architecture;