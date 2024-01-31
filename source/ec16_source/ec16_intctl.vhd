-- *********************************
-- ec16_intctl.vhd
--
-- Rev 1.0.0  for ICY40
-- 28. April 2023 by Edgar Conzen
-- 
-- INTCTL - interrupt controller Top
--
-- *********************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
	
entity ec16_intctl is
	port (
		clk			: in std_logic;
		opc			: in std_logic_vector (15 downto 8);
		ci			: in std_logic;
		state_r		: in std_logic;
		state_0		: in std_logic;
		state_1		: in std_logic;
		state_2		: in std_logic;
		branch		: in std_logic;
		inte		: in std_logic;
		im			: in std_logic;
		imi			: in std_logic_vector (3 downto 0);
		int_in		: in std_logic_vector (3 downto 0);
		rti			: in std_logic;
		iv			: out std_logic_vector (7 downto 0);
		int			: out std_logic;
		imx			: out std_logic;
		vs			: out std_logic
	);
end entity;

architecture syn of ec16_intctl is

	signal lic1, lic2, lic3, lic4, lic5	: std_logic;
	signal lastinstrcycle				: std_logic;
	signal ivsel						: std_logic_vector (3 downto 0);
	signal ivselff						: std_logic_vector (3 downto 0);
	signal itaken						: std_logic;
	signal imask						: std_logic_vector (3 downto 0);
	signal intinh_1					: std_logic;
	signal intinh						: std_logic;
	signal is0, is1, is2				: std_logic;
	signal pri_enc						: std_logic_vector (2 downto 0);
	
	component ec16_intcoord is
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
	end component;
	
begin

	lic1 <= '1' when (opc(15 downto 14) & state_0) = "001"  else '0';
	lic2 <= '1' when (opc(15 downto 14) & state_1) = "011"  else '0';
	lic3 <= '1' when (opc(15 downto 14) & state_2) = "101"  else '0';
	lic4 <= '1' when (opc(15 downto 14) & branch) = "110"  else '0';
	lic5 <= '1' when (opc(15 downto 14) & branch & state_1) = "1111"  else '0';
	lastinstrcycle <= lic1 or lic2 or lic3 or lic4 or lic5;
	
	itaken <= (ivsel(3) or ivsel(2) or ivsel(1) or ivsel(0)) and inte and lastinstrcycle;
	
	p_is0 : process (clk)
	begin
		if rising_edge (clk) then
			is0 <= itaken;
		end if;
	end process;

	p_is1 : process (clk)
	begin
		if rising_edge (clk) then
			is1 <= is0;
		end if;
	end process;
	
	p_is2 : process (clk)
	begin
		if rising_edge (clk) then
			is2 <= is1;
		end if;
	end process;

	int <= itaken or is0;
	imx <= is0 or is1;
	vs <= is1;
	

	p_inh_int_1 : process (clk)
	begin
		if rising_edge(clk) then
			if state_r = '1' then
				intinh_1 <= '0';
			elsif rti='1' then
				intinh_1 <= '1';
			elsif lastinstrcycle = '1' then
				intinh_1 <= '0';
			end if;
		end if;
	end process;


	intinh <= is0 or is1 or is2 or intinh_1;

	p_imask : process (clk)
	begin
		if rising_edge(clk) then
			if state_r = '1' then
				imask <= (others => '0');
			elsif im = '1' then
				imask <= imi;
			end if;
		end if;
	end process;
	

	p_ivselff : process (clk)
	begin
		if rising_edge (clk) then
			if itaken = '1' then
				ivselff <= ivsel;
			end if;
		end if;
	end process;
	
	
	p_pri_enc : process (ivselff)
	begin
		if (ivselff(0) = '1') then
			pri_enc <= "001";
		elsif (ivselff(1) = '1') then
			pri_enc <= "010";
		elsif (ivselff(2) = '1') then
			pri_enc <= "011";
		elsif (ivselff(3) = '1') then
			pri_enc <= "100";
		else 
			pri_enc <= "000";
		end if;
	end process;
	
	
	iv <= "00" & pri_enc & "000";
	
	
	c_intcoord : ec16_intcoord
	port map (
		clk			=> clk,
		imask	    => imask,
		clrint	    => ci,
		state_r	    => state_r,
		int_in	    => int_in,
		rti		    => rti,
		intinh	    => intinh,
		itaken	    => itaken,
		ivsel	    => ivsel		
	);
	
end architecture;
