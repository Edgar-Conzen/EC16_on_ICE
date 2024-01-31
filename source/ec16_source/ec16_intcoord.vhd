-- *********************************
-- ec16_intflags.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- INTCOORD - instatiates a block of per-int-flags to implement
--            the interrupt states and the prioritization
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_intcoord is
	port (
		clk			: in std_logic;
		imask		: in std_logic_vector (3 downto 0);
		clrint		: in std_logic;
		state_r		: in std_logic;
		int_in		: in std_logic_vector (3 downto 0);
		rti			: in std_logic;
		intinh		: in std_logic;
		itaken		: in std_logic;
		ivsel		: out std_logic_vector (3 downto 0)
	);
end entity;

architecture syn of ec16_intcoord is

	component ec16_intflag is
		port (
			clk			: in std_logic;
			int_in		: in std_logic;
			clrint		: in std_logic;
			state_r		: in std_logic;
			itaken		: in std_logic;
			imask		: in std_logic;
			intinh		: in std_logic;
			inhprioin	: in std_logic;
			inhprioout	: out std_logic;
			rtiprioin	: in std_logic;
			rtiprioout	: out std_logic;
			ivsel		: out std_logic
		);
	end component;
	
	signal inhprio		: std_logic_vector (2 downto 0);
	signal rtiprio		: std_logic_vector (2 downto 0);
	
begin

	gen03 : for i in 0 to 3 generate
		gen0 : if i=0 generate
			intflag : ec16_intflag
			port map(
				clk			=> clk,
				int_in		=> int_in(i),
				clrint		=> clrint,
				state_r		=> state_r,
				itaken		=> itaken,
				imask		=> imask(i),
				intinh		=> intinh,
				inhprioin	=> '0',
				inhprioout	=> inhprio(i),
				rtiprioin	=> rti,
				rtiprioout	=> rtiprio(i),
				ivsel		=> ivsel(i)		
			);
		end generate;
		gen12 :  if i=1 or i=2 generate
			intflag : ec16_intflag
			port map(
				clk			=> clk,
				int_in		=> int_in(i),
				clrint		=> clrint,
				state_r		=> state_r,
				itaken		=> itaken,
				imask		=> imask(i),
				intinh		=> intinh,
				inhprioin	=> inhprio(i-1),
				inhprioout	=> inhprio(i),
				rtiprioin	=> rtiprio(i-1),
				rtiprioout	=> rtiprio(i),
				ivsel		=> ivsel(i)		
			);
		end generate;
		gen3 : if i=3 generate
			intflag : ec16_intflag
			port map(
				clk			=> clk,
				int_in		=> int_in(i),
				clrint		=> clrint,
				state_r		=> state_r,
				itaken		=> itaken,
				imask		=> imask(i),
				intinh		=> intinh,
				inhprioin	=> inhprio(i-1),
				inhprioout	=> open,
				rtiprioin	=> rtiprio(i-1),
				rtiprioout	=> open,
				ivsel		=> ivsel(i)		
			);
		end generate;
	end generate;

	
end architecture;
