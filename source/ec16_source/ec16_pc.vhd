-- *********************************
-- ec16_pc.vhd
--
-- Rev 1.0.0  for ICY40
-- 19. April 2023 by Edgar Conzen
-- 
-- PC - Program Counter
-- 16-bit register with reset, increment, halt, branch and jump
--
-- *********************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


	
entity ec16_pc is
	port(
		clk			: in std_logic;
		rst			: in std_logic;
		pci			: in std_logic_vector (15 downto 0);
		pco			: out std_logic_vector (15 downto 0);
		pcf			: in std_logic_vector (1 downto 0)
	);
end entity;


architecture syn of ec16_pc is
	
	signal pc		: std_logic_vector (15 downto 0);
	signal incr		: std_logic;
	signal sign_ext	: std_logic_vector (15 downto 0);
	signal pc_calc	: std_logic_vector (15 downto 0);

begin

	incr <= '1' when pcf = "00" else '0';

	sign_ext <= pci(7) & pci(7) & pci(7) & pci(7) & pci(7) & pci(7) & pci(7) & pci(7) & pci(7 downto 0);

	p_pc_calc : process (pc, sign_ext, incr)
	begin
		if incr = '1' then
			pc_calc <= std_logic_vector(unsigned(pc)+1);
		else	
			pc_calc <= std_logic_vector(unsigned(pc) + unsigned(sign_ext));
		end if;
	end process;
	
	
	p_pc : process (clk, rst)
	begin
		if rst = '1' then
			pc <= (others => '0');
		elsif rising_edge(clk) then
			case pcf is
				when "00" => pc <= pc_calc; -- increment
				when "01" => NULL; -- halt
				when "10" => pc <= pc_calc; -- branch
				when others => pc <= pci; -- jmp
			end case;
		end if;
	end process p_pc;
	
	pco <= pc;
		
end architecture;