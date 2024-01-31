library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ripplefifo_package.all;

entity ripple_fifo is
	generic(
		nstages		: positive range 1 to 16 := 6;
		dwidth		: positive range 1 to 32 := 8);
	port(
		reset		: in std_logic;
		clk			: in std_logic;
		din_rdy		: out std_logic;
		wr			: in std_logic;
		din			: in std_logic_vector (dwidth-1 downto 0);
		dout_rdy	: out std_logic;
		rd			: in std_logic;
		dout		: out std_logic_vector (dwidth-1 downto 0));
end entity ripple_fifo;

architecture synth of ripple_fifo is
	
	type databus is array (0 to nstages) of std_logic_vector (dwidth-1 downto 0);
	signal data 		: databus;
	signal full			: std_logic_vector (nstages+1 downto 0);
		
begin
	
	fifo_stage : for i in 1 to nstages generate
		ffsl : ripple_fifo_slice
			generic map(
				dwidth => dwidth)
			port map(
				reset		=> reset,	
				clk			=> clk,	            
				prevfull	=> full(i-1),
				nextfull	=> full(i+1),
				din			=> data(i-1),
				full		=> full(i),
				dout		=> data(i));
	end generate fifo_stage;
	
	
	din_rdy <= not full(1);
	full(0) <= wr;
	data(0) <= din;
	dout_rdy <= full(nstages);
	full(nstages+1) <= not rd;
	dout <= data(nstages);
		

end architecture synth;
	