library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ripplefifo_package is

-- ripple_fifo
	component ripple_fifo is
		generic(
			nstages		: positive range 1 to 16 := 1;
			dwidth		: positive range 1 to 32 := 1);
		port(
			reset		: in std_logic;
			clk			: in std_logic;
			din_rdy		: out std_logic;
			wr			: in std_logic;
			din			: in std_logic_vector (dwidth-1 downto 0);
			dout_rdy	: out std_logic;
			rd			: in std_logic;
			dout		: out std_logic_vector (dwidth-1 downto 0));
	end component ripple_fifo;

	
-- uses ripple_fifo_slice
	component ripple_fifo_slice is
		generic(
			dwidth : positive range 1 to 32 := 8);
		port(
			reset		: in std_logic;
			clk			: in std_logic;
			prevfull	: in std_logic;
			nextfull	: in std_logic;
			din			: in std_logic_vector (dwidth-1 downto 0);
			full		: out std_logic;
			dout		: out std_logic_vector (dwidth-1 downto 0));
	end component ripple_fifo_slice;
	

end package ripplefifo_package;