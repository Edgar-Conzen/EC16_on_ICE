-- *********************************
-- ICY40_TOP.VHD
--
-- Template for ICY40 projects
--
-- Rev 2.0.0 
-- 31. December 2023 by Edgar Conzen
-- 
--
--   !!  I M P O R T A N T !!
--
-- 1. use it together with ICY40.PDC
--    as Post-Synthesis Constraint File
-- 2. In Strategy1 (right click, edit):
--    On the left under Synthesize Design 
--    select LSE then on the right
--        FSM Encoding Style = BINARY
--        VHDL 2008 = Yes
--
-- *********************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ice40up;
use ice40up.components.all;

use work.icy40_lib.all;

	
entity icy40 is
	port(
		CLK_IN			: in std_logic; -- input from 25 MHz quartz oscillator
		
		BTN				: in std_logic_vector(4 downto 0); -- 5 push buttons, not pressed = '0', pressed = '1'
		LED				: out std_logic_vector(4 downto 0); -- 5 leds, '0' = off, '1' = on

		SW_DISP_CLK		: out std_logic; -- clock signal for shift registers of DIP-Switch and 7-Segment-Display
		DISP_DATA		: out std_logic; -- data to shift register of 7-Segment-Display
		DISP_STB		: out std_logic; -- strobe to shift register of 7-Segment-Display
		SW_DATA			: in std_logic; -- data from shift register of DIP-Switch
		SW_STB_N		: out std_logic; --strobe to shift register of DIP-Switch

		-- PMOD			: in std_logic_vector(7 downto 0) -- 8 I/Os for extension with PMOD modules
		
		-- RGB_RD			: out std_logic; -- open collector output to red diode of tricolor led
		-- RGB_GN			: out std_logic; -- open collector output to green diode of tricolor led
		-- RGB_BL			: out std_logic; -- open collector output to blue diode of tricolor led

		-- Watch out! To use the flash set jumpers to flash mode and Port A of FT4232 to BitBang INPUT
		-- FPGA_SCK			: out std_logic; -- to flash
		-- FPGA_DO			: out std_logic; -- to flash
		-- FPGA_DI			: in std_logic; -- from flash
		-- FPGA_SS			: out std_logic; -- to flash

		-- Watch out! Port B of FT4232 has to be in the correct mode (MPSSE)
		-- DBG_SCK			: in std_logic; -- from channel B of FT4232
		-- DBG_DO			: in std_logic; -- from channel B of FT4232
		-- DBG_DI			: out std_logic; -- to channel B of FT4232
		-- DBG_CS			: in std_logic; -- to channel B of FT4232

		-- Watch out! Port C of FT4232 has to be in the correct mode (UART)
		FTDI_TXD			: in std_logic; -- from channel C of FT4232
		FTDI_RXD			: out std_logic -- to channel C of FT4232
		-- FTDI_RTS			: in std_logic; -- from channel C of FT4232
		-- FTDI_CTS			: out std_logic; -- to channel C of FT4232
	);
end entity;

	

architecture syn of icy40 is

	-- global signals
	signal clk 			: std_logic := '0';	-- use this signal to distribute HSOSC (48/24/12/6MHZ)
	signal lsclk		: std_logic;	-- use this signal to distribute LSOSC (10KHz)
	signal reset		: std_logic;	-- combined reset (ext and power up)
	
	-- microprocessor
	signal addr, din, dout	: std_logic_vector(15 downto 0);
	signal re, we 			: std_logic;

	-- ec16_decode
	signal sel				: std_logic_vector(4 downto 0);

	-- boot rom
	signal br_dout			: std_logic_vector(15 downto 0);
	signal br_wr, br_rd		: std_logic;

	-- SPRAM
	signal spr_dout			: std_logic_vector(15 downto 0);

	-- 7-Segment Display and DIP-Switches
	signal digit_out 		: std_logic_vector(15 downto 0);
	signal dp_out 			: std_logic_vector(3 downto 0);
	signal switches_in		: std_logic_vector(7 downto 0);
	
	-- LED output port
	signal ledport			: std_logic_vector(4 downto 0);

	-- FART
	signal fart_dout		: std_logic_vector (7 downto 0);



	-- ******************************************************
	--               declaration of components
	-- ******************************************************

	component pll_25_20 is
		port(
			ref_clk_i: in std_logic;
			rst_n_i: in std_logic;
			outcore_o: out std_logic;
			outglobal_o: out std_logic
		);
	end component;


	-- microprocessor
	component ec16 is
		port(
			clk			: in std_logic;
			rst			: in std_logic;
			addr		: out std_logic_vector (15 downto 0);
			dout		: out std_logic_vector (15 downto 0);
			din			: in std_logic_vector (15 downto 0);
			re			: out std_logic;
			we			: out std_logic;
			irq			: in std_logic_vector (3 downto 0)
		);
	end component;

	component ec16_decode is
		port(
			clk			: in std_logic;
			re			: in std_logic;
			addr		: in std_logic_vector (2 downto 0);
			sel			: out std_logic_vector (4 downto 0);
			din_0		: in std_logic_vector (15 downto 0);
			din_1		: in std_logic_vector (15 downto 0);
			din_2		: in std_logic_vector (15 downto 0);
			din_3		: in std_logic_vector (15 downto 0);
			din_4		: in std_logic_vector (15 downto 0);
			dout		: out std_logic_vector (15 downto 0)
		);
	end component;


	component icy40_led is
		port(
			clk				: in std_logic;
			sel				: in std_logic;
			we				: in std_logic;
			din				: in std_logic_vector(4 downto 0);
			ledport			: out std_logic_vector(4 downto 0)
		);
	end component;


	-- fixed asynchronous receiver transmitter
	component fart is
			generic(clockspeed : integer := 12500000);
			port(
			reset			: in std_logic;
			clk				: in std_logic;
			sel				: in std_logic;
			addr 			: in std_logic;
			re				: in std_logic;
			we				: in std_logic;
			din 			: in std_logic_vector (7 downto 0);
			dout			: out std_logic_vector (7 downto 0);
			rxd				: in std_logic;
			txd				: out std_logic;
			rx_avail		: out std_logic;
			tx_free			: out std_logic
			);
	end component fart;


begin
	
	-- ******************************************************
	--     clock selection (observe the maximum frequency!)
	-- ******************************************************

	-- 20MHz main clock for CPU and core components derived from  25MHZ osc.
	pll20: pll_25_20 port map(
		ref_clk_i	=> CLK_IN,
		rst_n_i=> '1',
		outcore_o=> open,
		outglobal_o=> clk
	);


	-- 10KHz clock for 7-Segment and DIP-Switch state machine
	ls_clk : icy40_lsosc
	port map (
		lsclk => lsclk  -- 10KHz
	);

	-- ******************************************************
	--       registers and instatiation of components
	-- ******************************************************

	-- power-up and external reset (BTN4) combined
	reset_generator : icy40_reset
	port map (
		clk_i	=> clk,
		reset_i => BTN(4),
		reset_o	=> reset
	);


	-- microprocessor
	up : ec16
	port map(
		clk			=> clk,
		rst			=> reset,
		addr		=> addr,
		dout		=> dout,
		din			=> din,
		re			=> re,
		we			=> we,
		irq			=> BTN(3 downto 0)
	);


	-- ******************************************************
	-- memory map (base addresses)
	--   0x0000 (r/w) : EBR boot rom
	--   0x2000 (r)   : Buttons 3..0 (BTN4 is used as reset)
	--   		(w)   : LEDs 4..0
	--   0x4000 (w)   : 7-Segment digits 15..0 (hex)
	--   		(r)   : DIP-switches 7..0
	--   0x4001 (w)   : 7-Segment decimal points 3..0
	--   0x6000 (r)   : FART receive data
	--   		(w)   : FART send data
	--   0x6001 (r)   : FART status 1..0 (tx_free, rx_avail)
	--   0x8000 (r/w) : SPRAM
	-- ******************************************************

	-- address decoder and CPU data-in multiplexer with registered select
	glue : ec16_decode
	port map(
		clk			=> clk,
		re			=> re,
		addr		=> addr(15 downto 13),
		sel			=> sel,
		din_0		=> br_dout,
		din_1		=> x"000" & BTN(3 downto 0),
		din_2		=> x"00" & switches_in,
		din_3		=> x"00" & fart_dout,
		din_4		=> spr_dout,
		dout		=> din
	);


	-- Boot rom
	br_wr <= sel(0) and we;
	br_rd <= sel(0) and re;
	
	-- Boot rom, initialized EBR
	bootram : icy40_ebr_i
	generic map(
		addr_width	=> 9,
		data_width	=> 16,
		--init_file	=> "..\asm\main.mem"  -- \impl_1\..\asm\main.mem
		init_file	=> "..\..\..\source\ecmon\ecmon.mem"  -- \impl_1\..\asm\main.mem
	)
	port map(
		wen		=> br_wr,
		wclk	=> clk,
		waddr	=> addr(8 downto 0),
		din		=> dout,
		ren		=> br_rd,
		rclk	=> clk,
		raddr	=> addr(8 downto 0),
		dout	=> br_dout
	);


	-- Output register for LED0..4 (0x2000)
	led_port : icy40_led
	port map(
		clk			=> clk,
		sel			=> sel(1),
		we			=> we,
		din			=> dout(4 downto 0),
		ledport		=> LED
	);


	-- state machine to handle the DIP-switches and the 7-segment display (0x4000)
	sw_disp : icy40_dipsw_7segm
	port map(
		-- inward interface to FPGA logic
		clk				=> clk,
		lsclk			=> lsclk,
		sel				=> sel(2),
		addr			=> addr(0),
		we				=> we,
		din				=> dout,
		switches		=> switches_in,
		-- off chip interface to shift registers (Display and Switches)
		sw_disp_clk		=> sw_disp_clk,
		disp_data		=> disp_data,
		disp_stb		=> disp_stb,
		sw_data			=> sw_data,
		sw_stb_n		=> sw_stb_n
	);


	-- Fixed Asynchronous Receiver Transmitter (0x6000, 115200 Baud, 8N1) 
	icy40_fart : fart
	generic map(clockspeed => 20000000) -- freq of clk in Hz
	port map(
		reset		=> reset,
		clk		    => clk,
		sel		    => sel(3),
		addr 	    => addr(0),
		re		    => re,
		we		    => we,
		din 	    => dout(7 downto 0),
		dout	    => fart_dout,
		rxd		    => FTDI_TXD,
		txd		    => FTDI_RXD,
		rx_avail    => open, -- for interrupt
		tx_free	    => open  -- for interrupt
	);


	-- SRAM 16K x 16, uninitialized (0x8000)
	spram : icy40_sp16k16
		port map(
			clk		=> clk,
			cs		=> sel(4),
			wen		=> we,
			addr	=> addr(13 downto 0),
			din		=> dout,
			dout	=> spr_dout
		);



end architecture;