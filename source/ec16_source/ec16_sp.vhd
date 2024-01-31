-- *********************************
-- ec16_sp.vhd
--
-- Rev 1.0.0  for ICY40
-- 19. April 2023 by Edgar Conzen
-- 
-- SP - Stack Pointer
-- 8-bit register with halt, load, post-decrement, pre-increment
--
-- *********************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

	
entity ec16_sp is
	port(
		clk			: in std_logic;
		state_r		: in std_logic;
		spi			: in std_logic_vector (7 downto 0);
		spo			: out std_logic_vector (7 downto 0);
		spf			: in std_logic_vector (1 downto 0)
	);
end entity;

	
architecture syn of ec16_sp is
	
	signal sp		: std_logic_vector (7 downto 0);
	signal sp_inc	: std_logic_vector (7 downto 0);
	signal sp_dec	: std_logic_vector (7 downto 0);

begin

	sp_inc <= std_logic_vector(unsigned(sp)+1);
	sp_dec <= std_logic_vector(unsigned(sp)-1);

	stackpointer : process (clk)
	begin
		if rising_edge(clk) then
			if state_r = '1' then
				sp <= x"ff";
			else
				case spf is
					when "01" => sp <= spi;
					when "10" => sp <= sp_dec;
					when "11" => sp <= sp_inc;
					when others => NULL;
				end case;
			end if;
		end if;
	end process stackpointer;

	stack_out : process (sp, sp_inc, spf)
	begin
		if spf = "11" then
			spo <= sp_inc;
		else
			spo <= sp;
		end if;
	end process stack_out;
	
		
end architecture;