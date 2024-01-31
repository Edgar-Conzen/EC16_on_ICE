library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fart_package.all;

entity tx_fsm is
	generic (clockspeed : integer := 12500000);
	port(
		reset			: in std_logic;
		clk				: in std_logic;
		tx_req			: in std_logic;
		tx_parin		: in std_logic_vector (7 downto 0);
		tx_active		: out std_logic;
		tx_serout		: out std_logic);
end entity tx_fsm;


architecture synth of tx_fsm is
	
	signal tx_active_s		: std_logic;
	signal tx_tick			: std_logic;
	signal tx_shift_cs		: t_shift_state;	-- current shift state
	signal tx_shift_ns		: t_shift_state;	-- next shift state
	signal tx_shift_reg		: std_logic_vector(8 downto 0);
	signal next_tx_out		: std_logic;


begin

		
	-- start / stop logic for transmitter
	-- tx_active_s = '1' enables c_tx_baudtick and thus data transmission
	-- tx_active_s = '0' disables c_tx_baudtick
	-- tx_active falling edge issues a read pulse to c_tx_rfifo
	pr_tx_active : process(reset, clk)
	begin
		if reset='1' then
			tx_active_s <= '0';
		elsif rising_edge(clk) then
			if tx_req='1' then
				tx_active_s <= '1';
			elsif tx_tick='1' and tx_shift_cs = sh_stop then
				tx_active_s <= '0';
			end if;
		end if;
	end process pr_tx_active;
	-- output to c_tx_rfifo
	tx_active <= tx_active_s;

	-- Divide clk and generate a single pulse of length Tbaud_clk at 115200 baud
	c_tx_baudtick : tx_baudtick
	generic map(clockspeed => clockspeed)
	port map(
		clk			=> clk,
		tx_active	=> tx_active_s,
		tx_tick		=> tx_tick);
	

	-- TX-FSM State Registers
	pr_tx_fsm_reg : process(reset, clk, tx_req, tx_tick)
	begin
		if reset='1' then
			tx_shift_cs <= sh_mark;
		elsif tx_req='1' or tx_tick='1' then
			if rising_edge(clk) then
				tx_shift_cs <= tx_shift_ns;
			end if;
		end if;
	end process pr_tx_fsm_reg;
	
	
	-- TX-FSM Next State Logic
	pr_tx_fsm_nsl : process(tx_shift_cs)
	begin
		case tx_shift_cs is
			when sh_mark	=> tx_shift_ns <= sh_start;
			when sh_start	=> tx_shift_ns <= sh_d0;
			when sh_d0		=> tx_shift_ns <= sh_d1;
			when sh_d1		=> tx_shift_ns <= sh_d2;
			when sh_d2		=> tx_shift_ns <= sh_d3;
			when sh_d3		=> tx_shift_ns <= sh_d4;
			when sh_d4		=> tx_shift_ns <= sh_d5;
			when sh_d5		=> tx_shift_ns <= sh_d6;
			when sh_d6		=> tx_shift_ns <= sh_d7;
			when sh_d7		=> tx_shift_ns <= sh_stop;	
			when sh_stop	=> tx_shift_ns <= sh_mark;
			when others		=> tx_shift_ns <= sh_mark;
		end case;
	end process pr_tx_fsm_nsl;


	-- TX Shift register
	pr_tx_shift_reg : process(reset, clk)
	begin
		if reset='1' then
			tx_shift_reg <= "111111111";
		elsif rising_edge(clk) then
			if tx_req='1' then
				tx_shift_reg(0) <= '0';
				tx_shift_reg(8 downto 1) <= tx_parin;
			elsif tx_tick='1' then
				for i in 0 to 7 loop
					tx_shift_reg(i) <= tx_shift_reg(i+1);
				end loop;
				tx_shift_reg(8) <= '1';
			end if;
		end if;
	end process pr_tx_shift_reg;

	tx_serout <= tx_shift_reg(0);	



end architecture synth;