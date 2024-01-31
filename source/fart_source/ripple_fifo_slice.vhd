library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ripple_fifo_slice is
	generic(
		dwidth : positive range 1 to 32 := 1);
	port(
		reset		: in std_logic;
		clk			: in std_logic;
		prevfull	: in std_logic;
		nextfull	: in std_logic;
		din			: in std_logic_vector (dwidth-1 downto 0);
		full		: out std_logic;
		dout		: out std_logic_vector (dwidth-1 downto 0));
end entity ripple_fifo_slice;


architecture synth of ripple_fifo_slice is	
	signal fullflag 	: std_logic;
	signal data			: std_logic_vector (dwidth-1 downto 0); 
	
begin

	-- handling of the fullflag
	pr_fullflag : process (reset, clk)
	begin
		if reset='1' then
			fullflag <= '0';
		elsif rising_edge(clk) then 
			if prevfull='1' and fullflag='0' then
				fullflag <= '1';
			elsif fullflag='1' and nextfull='0' then
				fullflag <= '0';
			end if;
		end if;
	end process pr_fullflag;
	
	-- output fullflag constantly
	full <= fullflag;
	

	-- handling of the data memory
	pr_data : process (clk)
	begin
		if prevfull='1' and fullflag='0' then
			if rising_edge(clk) then
				data <= din;
			end if;
		end if;
	end process pr_data;

	-- output data constantly
	dout <= data;

end architecture synth;