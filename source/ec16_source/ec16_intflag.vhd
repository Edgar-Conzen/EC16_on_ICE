-- *********************************
-- ec16_intflags.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- INTFLAG - interrupt states per int-line
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_intflag is
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
end entity;

architecture syn of ec16_intflag is

	signal red0, red1, red		: std_logic;
	signal irr, iracc, irip		: std_logic;
	
begin

	-- rising edge detection on int_in
	
	p_red0 : process (clk)
	begin
		if rising_edge (clk) then
			red0 <= int_in;
		end if;
	end process;
	
	p_red1 : process (clk)
	begin
		if rising_edge (clk) then
			red1 <= red0;
		end if;
	end process;
	
	red <= red0 and not red1;
	
	
	-- interrupt request register
	
	p_irr : process (clk)
	begin
		if rising_edge(clk) then
			if (clrint or state_r or (itaken and iracc)) = '1' then
				irr <= '0';
			elsif red = '1' then
				irr <= '1';
			end if;
		end if;
	end process;
	
	-- accept int

	iracc <= irr and imask and not (intinh or inhprioin or irip);
	inhprioout <= iracc or intinh or inhprioin or irip;


	-- interrupt in progress register
	
	p_irip : process (clk)
	begin
		if rising_edge (clk) then
			if (rtiprioin or state_r) = '1' then
				irip <= '0';
			elsif (iracc and itaken) = '1' then
				irip <= '1';
			end if;
		end if;
	end process;

	rtiprioout <= rtiprioin and not irip;
	
	
	ivsel <= iracc;
	
end architecture;
