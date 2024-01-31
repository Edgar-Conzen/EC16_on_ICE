library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package icy40_lib is

-- ###########################################################################
-- icy40_reset - reset_o = '0' until after the third rising edge of clk_i 
-- ###########################################################################

	component icy40_reset is
		port (
			clk_i	: in std_logic;
			reset_i : in std_logic;
			reset_o	: out std_logic);
	end component;


-- #############################################
-- icy40_lsosc - instatiate Low Speed Oscillator
-- #############################################

	
	component icy40_lsosc is
		port (lsclk : out std_logic);
	end component;


-- ####################################################
-- icy40_ebr_i - initialized pseudo-dual-port block ram
-- ####################################################
	
	component icy40_ebr_i is
		generic (
			addr_width	: natural := 9;
			data_width	: natural := 16;
			init_file	: string := "..\..\..\source\ecmon\ecmon.mem"
		);
		port (
			wen		: in std_logic;
			wclk	: in std_logic;
			waddr	: in std_logic_vector (addr_width-1 downto 0);
			din		: in std_logic_vector (data_width-1 downto 0);
			ren		: in std_logic;
			rclk	: in std_logic;
			raddr	: in std_logic_vector (addr_width-1 downto 0);
			dout	: out std_logic_vector (data_width-1 downto 0)
		);
	end component;
	
	
-- ############################################
-- icy40_sp16k16 - SPRAM 16Kx16 single-port ram
-- ############################################

	component icy40_sp16k16 is
		port (
			clk		: in std_logic;
			cs		: in std_logic;
			wen		: in std_logic;
			addr	: in std_logic_vector (13 downto 0);
			din		: in std_logic_vector (15 downto 0);
			dout	: out std_logic_vector (15 downto 0)
		);
	end component;


-- ########################################################################
-- icy40_dipsw_7segm - machine to handle 7-segment display and DIP-switches
-- ########################################################################

	component icy40_dipsw_7segm is
		port(
			-- interface to FPGA logic
			clk				: in std_logic;
			lsclk			: in std_logic;
			sel				: in std_logic;
			addr			: in std_logic;
			we				: in std_logic;
			din				: in std_logic_vector(15 downto 0);
			switches		: out std_logic_vector(7 downto 0);
			
			-- interface to shift registers (Display and Switches)
			sw_disp_clk		: out std_logic; -- clock signal for shift registers of DIP-Switch and 7-Segment-Display
			disp_data		: out std_logic; -- data to shift register of 7-Segment-Display
			disp_stb		: out std_logic; -- strobe to shift register of 7-Segment-Display
			sw_data			: in std_logic; -- data from shift register of DIP-Switch
			sw_stb_n		: out std_logic --strobe to shift register of DIP-Switch
		);
	end component;


end icy40_lib;


-- ********************************************************************************************
-- ********************************************************************************************
--       Implementation        Implementation        Implementation        Implementation      
-- ********************************************************************************************
-- ********************************************************************************************



-- ###########################################################################
-- icy40_init_reset - reset_o = '0' until after the third rising edge of clk_i 
-- ###########################################################################

-- After FPGA-config reset_o stays '0' until first posedge of clk_i

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity icy40_reset is
	port (
		clk_i	: in std_logic;
		reset_i : in std_logic;
		reset_o	: out std_logic);
end entity;

architecture synth of icy40_reset is
	signal res : std_logic_vector(3 downto 0) := "0000"; -- must be initialized to zero !
	attribute syn_keep: boolean;
	attribute syn_keep of res: signal is true;
begin

generate_reset : process (clk_i)
	begin
		if reset_i = '1' then
			res <= "0000";
		elsif rising_edge (clk_i) then
			res(0) <= '1';
			res(1) <= res(0);
			res(2) <= res(1);
			res(3) <= res(2);
		end if;
	end process;
	
	reset_o <= not res(3);
	
end architecture;


-- #############################################
-- icy40_lsosc - instatiate Low Speed Oscillator
-- #############################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ice40up;
use ice40up.components.all;

entity icy40_lsosc is
	port (lsclk : out std_logic);
end entity;

architecture synth of icy40_lsosc is
begin
	lclk : LSOSC
	port map (CLKLFPU => '1', CLKLFEN => '1', CLKLF => lsclk);
end architecture;


-- ####################################################
-- icy40_ebr_i - initialized pseudo-dual-port block ram
-- ####################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity icy40_ebr_i is
	generic (
		addr_width	: natural := 9;
		data_width	: natural := 16;
		init_file	: string := "..\..\..\source\ecmon\ecmon.mem"
	);
	port (
		wen		: in std_logic;
		wclk	: in std_logic;
		waddr	: in std_logic_vector (addr_width-1 downto 0);
		din		: in std_logic_vector (data_width-1 downto 0);
		ren		: in std_logic;
		rclk	: in std_logic;
		raddr	: in std_logic_vector (addr_width-1 downto 0);
		dout	: out std_logic_vector (data_width-1 downto 0)
	);
end entity;

architecture synth of icy40_ebr_i is

	type ram_type is array (0 to (2**addr_width)-1) of std_logic_vector(data_width-1 downto 0);

	impure function init_ram return ram_type is
		file text_file : text open read_mode is init_file;
		variable text_line : line;
		variable ram_content : ram_type;
	begin
		for i in 0 to (2**addr_width)-1 loop
		  readline(text_file, text_line);
		  hread(text_line, ram_content(i));
		end loop;
		return ram_content;
	end function;
	
	signal ram : ram_type := init_ram;
	
begin
	
	readram : process (rclk)
	begin
		if rising_edge (rclk) then
			if ren = '1' then
				dout <= ram(to_integer(unsigned(raddr)));
			end if;
		end if;
	end process;

	writeram : process (wclk)
	begin
		if rising_edge (wclk) and wen = '1' then
			ram(to_integer(unsigned(waddr))) <= din;
		end if;
	end process;

end architecture;	


-- ############################################
-- icy40_sp16k16 - SPRAM 16Kx16 single-port ram
-- ############################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library ice40up;
use ice40up.components.all;

entity icy40_sp16k16 is
	port (
		clk		: in std_logic;
		cs		: in std_logic;
		wen		: in std_logic;
		addr	: in std_logic_vector (13 downto 0);
		din		: in std_logic_vector (15 downto 0);
		dout	: out std_logic_vector (15 downto 0)
	);
end entity;

architecture synth of icy40_sp16k16 is

begin

	spram1 : SP256K
	port map (
		AD       => addr,
		DI       => din,
		MASKWE   => "1111",
		WE       => wen,
		CS       => cs,
		CK       => clk,
		STDBY    => '0',
		SLEEP    => '0',
		PWROFF_N => '1',
		DO       => dout
	);

end architecture;


-- ########################################################################
-- icy40_dipsw_7segm - machine to handle 7-segment display and DIP-switches
-- ########################################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity icy40_dipsw_7segm is
	port(
		-- interface to FPGA logic
		clk				: in std_logic;
		lsclk			: in std_logic;
		sel				: in std_logic;
		addr			: in std_logic;
		we				: in std_logic;
		din				: in std_logic_vector(15 downto 0);
		switches		: out std_logic_vector(7 downto 0);
		
		-- interface to shift registers (Display and Switches)
		sw_disp_clk		: out std_logic; -- clock signal for shift registers of DIP-Switch and 7-Segment-Display
		disp_data		: out std_logic; -- data to shift register of 7-Segment-Display
		disp_stb		: out std_logic; -- strobe to shift register of 7-Segment-Display
		sw_data			: in std_logic; -- data from shift register of DIP-Switch
		sw_stb_n		: out std_logic --strobe to shift register of DIP-Switch
	);
end entity;

	
architecture syn of icy40_dipsw_7segm is

	-- input registers
	signal digit_data		: std_logic_vector(15 downto 0);
	signal digit_dp			: std_logic_vector(3 downto 0);


	-- buffer all outputs with signals for debug purposes
	signal s_switches		: std_logic_vector (7 downto 0);
	signal s_sw_disp_clk	: std_logic;
	signal s_disp_data		: std_logic;
	signal s_disp_stb		: std_logic;
	signal s_sw_stb_n		: std_logic;

	-- internally used signals
	signal cnt12		: integer range 0 to 11 := 0;
	signal cnt4			: integer range 0 to 3 := 0;
	signal sreg12		: std_logic_vector (11 downto 0);
	signal sreg8		: std_logic_vector (7 downto 0);
	signal dig_1hot		: std_logic_vector (3 downto 0);
	signal digitval		: std_logic_vector (3 downto 0);
	signal digithex		: std_logic_vector (6 downto 0);
	signal digitdp		: std_logic;
	
begin

	-- register for digit_data
	digout : process (clk)
	begin
		if rising_edge(clk) then
			if sel='1' and we='1' and addr='0' then
				digit_data <= din;
			end if;
		end if;
	end process;

	-- register for digit_dp
	dpout : process (clk)
	begin
		if rising_edge(clk) then
			if sel='1' and we='1' and addr='1' then
				digit_dp <= din (3 downto 0);
			end if;
		end if;
	end process;


	-- output all buffered signals
	switches		<= s_switches;
	sw_disp_clk		<= s_sw_disp_clk;
	disp_data		<= s_disp_data;
	disp_stb		<= s_disp_stb;
	sw_stb_n		<= s_sw_stb_n;

	-- if possible use the lsosc (10kHz internal low speed oscillator)
	-- for both, this entity and the external shift registers 
	s_sw_disp_clk	<= lsclk;
	

	-- rolling upcounter 0..11 for the twelve shifting states (8 segments/switches + 4 digit drivers)
	p_cnt12 : process (lsclk)
	begin
		if rising_edge (lsclk) then
			if cnt12 = 11 then
				cnt12 <= 0;
			else
				cnt12 <= cnt12 +1;
			end if;
		end if;
	end process p_cnt12;
	
	-- rolling upcounter for the four digit drivers, increments at cnt12=11 
	p_cnt4 : process (lsclk, cnt12)
	begin
		if rising_edge (lsclk) and (cnt12 = 11) then
			if cnt4 = 3 then
				cnt4 <= 0;
			else
				cnt4 <= cnt4 +1;
			end if;
		end if;
	end process p_cnt4;
	
	-- translate cnt4 from binary to 1hot encoding
	p_cnt4_to_1hot : process (cnt4)
	begin
		case cnt4 is
			when 0 => dig_1hot <= "0001"; 
			when 1 => dig_1hot <= "0010"; 
			when 2 => dig_1hot <= "0100"; 
			when others => dig_1hot <= "1000"; 
		end case;
	end process p_cnt4_to_1hot;

	-- digit_data (15 downto 0) contains the four digit values 
	-- digit_dp (3 downto 0) contains the four decimal points 
	-- according to cnt4 they are muxed to signal digitval resp. digitdp
	p_digitval : process (digit_data, digit_dp, cnt4)
	begin
		case cnt4 is
			when 0 => 
				digitval <= digit_data(3 downto 0);
				digitdp <= digit_dp(0);
			when 1 => 
				digitval <= digit_data(7 downto 4);
				digitdp <= digit_dp(1);
			when 2 => 
				digitval <= digit_data(11 downto 8);
				digitdp <= digit_dp(2);
			when others => 
				digitval <= digit_data(15 downto 12);
				digitdp <= digit_dp(3);
		end case;
	end process p_digitval;
	
	-- the current digit value is converted from binary to hex for 7-segment
	p_b2hd : process (digitval)
	begin
		case digitval is
			when "0000" => digithex <= "0111111";
			when "0001" => digithex <= "0000110";
			when "0010" => digithex <= "1011011";
			when "0011" => digithex <= "1001111";
			when "0100" => digithex <= "1100110";
			when "0101" => digithex <= "1101101";
			when "0110" => digithex <= "1111101";
			when "0111" => digithex <= "0000111";
			when "1000" => digithex <= "1111111";
			when "1001" => digithex <= "1101111";
			when "1010" => digithex <= "1110111";
			when "1011" => digithex <= "1111100";
			when "1100" => digithex <= "0111001";
			when "1101" => digithex <= "1011110";
			when "1110" => digithex <= "1111001";
			when "1111" => digithex <= "1110001";
			when others => digithex <= "0000000";
		end case;
	end process p_b2hd;
	
	-- at cnt12=0 the 12 bit shift reg sreg12 is loaded with the 
	-- current (according to cnt3) dig_1hot, digithex and digitdp values
	p_sreg12 : process (lsclk)
	begin
		if falling_edge (lsclk) then
			if cnt12 = 0 then  -- load parallel
				sreg12 (11 downto 8) <= dig_1hot;
				sreg12 (7) <= digitdp;
				sreg12 (6 downto 0) <= digithex;
			else  -- shift
				sreg12 <= sreg12(10 downto 0) & '0';
			end if;
		end if;
	end process p_sreg12;
	
	-- since all segments and digit drivers are active low, disp_data must be inverted
	s_disp_data <= not sreg12(11);


	-- disp_stb : the rising edge transfers the 74595's shift registers to the output registers
	p_strobes : process (lsclk)
	begin
		if falling_edge (lsclk) then
			if cnt12 = 0 then
				s_disp_stb <= '1';
			else
				s_disp_stb <= '0';
			end if;
		end if;
	end process p_strobes;

	-- sw_stb_n : a low level transfers the 74165's parallel inputs to the output shift register
	-- It is exactly the negation of disp_stb
	s_sw_stb_n <= not s_disp_stb;



	-- sreg8 is an 8 bit shift reg that continuously receives the 74165's data via sw_data
	-- at cnt12 = 0 the 74165 is parallel loaded with the DIP-Switch values
	-- at cnt12 = 0..7 the data is read into sreg8 
	-- at cnt12 = 8 the data is transferred to register s_switches
	-- the bits read during cnt12 = 8..11 are invalid and ignored
	p_sreg8 : process (lsclk)
	begin
		if falling_edge (lsclk) then
			sreg8 <= sreg8(6 downto 0) & sw_data;
		end if;
	end process p_sreg8;
	
	-- transfer shift reg to parallel output switches
	p_switches : process (lsclk)
	begin
		if rising_edge (lsclk) then
			if cnt12 = 8 then 
				s_switches <= sreg8;
			end if;
		end if;
	end process p_switches;

end architecture;

