-- *********************************
-- ec16_top.vhd
--
-- Rev 1.0.0  for ICY40
-- 16. April 2023 by Edgar Conzen
-- 
-- *********************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

	
entity ec16 is
	port(
		clk			: in std_logic;
		rst			: in std_logic;
		addr		: out std_logic_vector (15 downto 0);
		dout		: out std_logic_vector (15 downto 0);
		din			: in std_logic_vector (15 downto 0);
		re			: out std_logic;
		we			: out std_logic;
		irq			: in std_logic_vector (3 downto 0)
		-- debug
		--dbg_state_r		: out std_logic;
		--dbg_state_0		: out std_logic;
		--dbg_state_1		: out std_logic;
		--dbg_state_2		: out std_logic		
	);
end entity;

	
architecture syn of ec16 is

	signal ai			: std_logic_vector (1 downto 0);
	signal ae			: std_logic;
	signal accu			: std_logic_vector (15 downto 0);

	signal si			: std_logic;
	signal se, ce, cd	: std_logic;
	signal iee, ied		: std_logic;
	signal status_in	: std_logic_vector (4 downto 0);
	signal flags		: std_logic_vector (4 downto 0);
	signal afn			: std_logic_vector (3 downto 0);
	signal alu_result	: std_logic_vector (15 downto 0);
	signal alu_status	: std_logic_vector (3 downto 0);

	signal spf			: std_logic_vector (1 downto 0);
	signal sp			: std_logic_vector (7 downto 0);
	
	signal id, ia		: std_logic_vector (1 downto 0);
	signal iw, ir		: std_logic;
	signal intmem_di	: std_logic_vector (15 downto 0);
	signal intmem_ai	: std_logic_vector (7 downto 0);
	signal intmem		: std_logic_vector (15 downto 0);

	signal pi			: std_logic;
	signal pf			: std_logic_vector (1 downto 0);
	signal pci, pco		: std_logic_vector (15 downto 0);

	signal ea, ew, er	: std_logic;
	signal extmem_ai	: std_logic_vector (15 downto 0);
	signal extmem_do	: std_logic_vector (15 downto 0);

	signal vs			: std_logic;
	signal iv			: std_logic_vector (7 downto 0);
	signal cvi			: std_logic_vector (15 downto 0);

	signal imx			: std_logic;
	signal extmem		: std_logic_vector (15 downto 0);

	signal oe			: std_logic;
	signal opcc			: std_logic_vector (15 downto 0);

	signal state_r		: std_logic;
	signal state_0		: std_logic;
	signal state_1		: std_logic;
	signal state_2		: std_logic;
	signal branch		: std_logic;
	signal opc15_8		: std_logic_vector (7 downto 0);
	signal int			: std_logic;
	signal rti			: std_logic;
	signal ci			: std_logic;
	signal im			: std_logic;

	component ec16_sf is
		port(
			clk			: in std_logic;
			rst			: in std_logic;
			se			: in std_logic;
			ce			: in std_logic;
			cd			: in std_logic;
			iee			: in std_logic;
			ied			: in std_logic;
			sfi			: in std_logic_vector (4 downto 0);
			sfo			: out std_logic_vector (4 downto 0)
		);
	end component;

	component ec16_alu is
		port(
			fn			: in std_logic_vector (3 downto 0);
			a_in		: in std_logic_vector (15 downto 0);
			b_in		: in std_logic_vector (15 downto 0);
			res_out		: out std_logic_vector (15 downto 0);
			c_in		: in std_logic;
			c_out		: out std_logic;
			over		: out std_logic;
			neg			: out std_logic;
			zero		: out std_logic
	);
	end component;

	component ec16_sp is
		port(
			clk			: in std_logic;
			state_r		: in std_logic;
			spi			: in std_logic_vector (7 downto 0);
			spo			: out std_logic_vector (7 downto 0);
			spf			: in std_logic_vector (1 downto 0)
		);
	end component;

	component ec16_intmem is
		port(
			clk			: in std_logic;
			addr		: in std_logic_vector (7 downto 0);
			din			: in std_logic_vector (15 downto 0);
			dout		: out std_logic_vector (15 downto 0);
			re			: in std_logic;
			we			: in std_logic
		);
	end component;

	component ec16_pc is
	port(
		clk			: in std_logic;
		rst			: in std_logic;
		pci			: in std_logic_vector (15 downto 0);
		pco			: out std_logic_vector (15 downto 0);
		pcf			: in std_logic_vector (1 downto 0)
	);
	end component;

	component ec16_intinj is
	port (
		iv		: in std_logic_vector (7 downto 0);
		vs		: in std_logic;
		cvi		: out std_logic_vector (15 downto 0)
	);
	end component;

	component ec16_sc is
		port(
			clk			: in std_logic;
			rst			: in std_logic;
			flags		: in std_logic_vector (4 downto 0);
			opc			: in std_logic_vector (15 downto 8);
			state_r		: out std_logic;
			state_0		: out std_logic;
			state_1		: out std_logic;
			state_2		: out std_logic;
			branch		: out std_logic
		);
	end component;

	component ec16_mc is
		port(
			-- common inputs
			opc			: in std_logic_vector (15 downto 8);
			state_r		: in std_logic;
			state_0		: in std_logic;
			state_1		: in std_logic;
			state_2		: in std_logic;
			branch		: in std_logic;
			int			: in std_logic;
			-- program counter
			pi			: out std_logic;
			pf			: out std_logic_vector (1 downto 0);
			-- external (program / data) memory
			ea			: out std_logic;
			ew			: out std_logic;
			er			: out std_logic;
			-- opcode copy enable
			oe			: out std_logic;
			-- stack pointer function 
			spf			: out std_logic_vector (1 downto 0);
			-- controls for internal memory
			id			: out std_logic_vector (1 downto 0);
			ia			: out std_logic_vector (1 downto 0);
			iw			: out std_logic;
			ir			: out std_logic;
			-- controls for accumulator
			ai			: out std_logic_vector (1 downto 0);
			ae			: out std_logic;
			-- controls for status register / interrupt enable
			si			: out std_logic;
			se			: out std_logic;
			ce			: out std_logic;
			cd			: out std_logic;
			iee			: out std_logic;
			ied			: out std_logic;
			-- clear pending int / set interrupt enable mask
			ci			: out std_logic;
			im			: out std_logic;
			-- return from interrupt
			rti			: out std_logic;
			-- ALU function 
			afn			: out std_logic_vector (3 downto 0)
	);
	end component;

	component ec16_intctl is
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
	end component;

begin

	-- Debug
	--dbg_state_r <= state_r;
	--dbg_state_0 <= state_0;
	--dbg_state_1 <= state_1;
	--dbg_state_2 <= state_2;

	-- accu
	p_accu : process (clk)
	begin
		if rising_edge (clk) then
			if ae = '1' then
				case ai is
					when "00" => accu <= alu_result;
					when "01" => accu <= sp & "000" & flags;
					when "10" => accu <= extmem;
					when others => accu <= intmem;
				end case;
			end if;
		end if;
	end process;
	
	-- status register
	status_in <= (flags(4) & alu_status) when si='0'  else accu(4 downto 0);
	
	status : ec16_sf
	port map (
		clk		=> clk,
		rst	    => rst,
		se	    => se,
		ce	    => ce,
		cd	    => cd,
		iee	    => iee,
		ied	    => ied,
		sfi	    => status_in,
		sfo	    => flags
	);
	
	
	-- ALU
	alu :  ec16_alu
	port map (
		fn			=> afn,
		a_in		=> accu,
		b_in		=> intmem,
		res_out		=> alu_result,
		c_in		=> flags(0),
		c_out		=> alu_status(0),
		over		=> alu_status(1),
		neg			=> alu_status(2),
		zero		=> alu_status(3)
	);


	-- sp (stack pointer)
	stackpointer : ec16_sp
	port map(
		clk			=> clk,
		state_r		=> state_r,
		spi			=> accu(7 downto 0),
		spo			=> sp,
		spf			=> spf 
	);


	-- intmem
	intmem_di <= 	accu when id = "00" else
					extmem when id = "01" else
					pco when id = "10" else
					alu_result;
					
	intmem_ai <= 	opcc(7 downto 0) when ia = "00" else
					extmem(7 downto 0) when ia = "01" else
					sp when ia = "10" else
					intmem(7 downto 0);
	
	intmemory : ec16_intmem
	port map(
		clk			=> clk,
		addr		=> intmem_ai,
		din			=> intmem_di,
		dout		=> intmem,
		re			=> ir,
		we			=> iw
	);
	
	
	-- pc (program counter)
	pci <=	intmem when pi = '0'  else extmem;
	
	pc : ec16_pc
	port map(
		clk		=> clk,
		rst		=> rst,
		pci		=> pci,
		pco		=> pco,
		pcf		=> pf
	);

	
	-- external memory bus
	extmem_ai <=	pco when ea = '0'  else intmem;
	
	addr		<= extmem_ai;
	dout		<= accu;
	extmem_do	<= din;
	re			<= er;
	we			<= ew;
	
	
	-- intinj (interrupt injection)
	intinj : ec16_intinj
	port map(
		iv		=> iv,
		vs		=> vs,
		cvi		=> cvi
	);


	-- extmem (data from external memory or interrupt injection)
	extmem <= extmem_do when imx = '0'  else cvi;


	-- opcc (opcode copy for state_1 and state_2)
	p_opcc : process (clk)
	begin
		if rising_edge(clk) then
			if oe = '1' then
				opcc <= extmem;
			end if;			
		end if;
	end process;
	
	
	-- sc (state counter)
	opc15_8 <=	extmem(15 downto 8) when state_0 = '1'  else opcc(15 downto 8);
	
	sc : ec16_sc
	port map(
		clk			=> clk,
		rst			=> rst,
		flags		=> flags,
		opc			=> opc15_8,
		state_r		=> state_r,
		state_0		=> state_0,
		state_1		=> state_1,
		state_2		=> state_2,
		branch		=> branch
	);

	
	-- mc (micro code)
	mc : component ec16_mc
	port map(
		-- common inputs
		opc			=> opc15_8,
		state_r		=> state_r,
		state_0		=> state_0,
		state_1		=> state_1,
		state_2		=> state_2,
		branch		=> branch,
		int			=> int,
		-- program counter
		pi			=> pi,
		pf			=> pf,
		-- external (program / data) memory
		ea			=> ea,
		ew			=> ew,
		er			=> er,
		-- opcode copy enable
		oe			=> oe,
		-- stack pointer function 
		spf			=> spf,
		-- controls for internal memory
		id			=> id,
		ia			=> ia,
		iw			=> iw,
		ir			=> ir,
		-- controls for accumulator
		ai			=> ai,
		ae			=> ae,
		-- controls for status register / interrupt enable
		si			=> si,
		se			=> se,
		ce			=> ce,
		cd			=> cd,
		iee			=> iee,
		ied			=> ied,
		-- clear pending int / set interrupt enable mask
		ci			=> ci,
		im			=> im,
		-- return from interrupt
		rti			=> rti,
		-- ALU function 
		afn			=> afn
	);

	
	-- intctl
	intctl : ec16_intctl
	port map(
		clk			=> clk,
		opc			=> opc15_8,
		ci			=> ci,
		state_r		=> state_r,
		state_0		=> state_0,
		state_1		=> state_1,
		state_2		=> state_2,
		branch		=> branch,
		inte		=> flags(4),
		im			=> im,
		imi			=> accu(3 downto 0),
		int_in		=> irq,
		rti			=> rti,
		iv			=> iv,
		int			=> int,
		imx			=> imx,
		vs			=> vs 
	);
	
	
	
end architecture;