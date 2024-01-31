-- *********************************
-- ec16_mc.vhd
--
-- Rev 1.0.0  for ICY40
-- 27. April 2023 by Edgar Conzen
-- 
-- MC - MicroCode (top)
-- collects the components that implement the micro code bits
--
-- *********************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

	
entity ec16_mc is
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
end entity;
	
architecture syn of ec16_mc is

	component ec16_dec_pi is
		port (
			pi			: out std_logic;
			opc			: in std_logic_vector (15 downto 8);
			state_0		: in std_logic;
			state_1		: in std_logic;
			branch		: in std_logic
		);
	end component;
	
	component ec16_dec_pf is
		port (
			pf			: out std_logic_vector (1 downto 0);
			opc			: in std_logic_vector (15 downto 8);
			state_0		: in std_logic;
			state_1		: in std_logic;
			branch		: in std_logic;
			int			: in std_logic
		);
	end component;
	
	component ec16_dec_ea is
		port (
			ea			: out std_logic;
			opc			: in std_logic_vector (15 downto 8);
			state_1		: in std_logic
		);
	end component;
	
	component ec16_dec_ew is
		port (
			ew			: out std_logic;
			opc			: in std_logic_vector (15 downto 8);
			state_1		: in std_logic
		);
	end component;
	
	component ec16_dec_er is
		port (
			er			: out std_logic;
			opc			: in std_logic_vector (15 downto 8);
			state_r		: in std_logic;
			state_0		: in std_logic;
			state_1		: in std_logic;
			state_2		: in std_logic;
			branch		: in std_logic;
			int			: in std_logic
		);
	end component;
	
	component ec16_dec_oe is
		port (
			oe			: out std_logic;
			opc			: in std_logic_vector (15 downto 8);
			state_0		: in std_logic;
			branch		: in std_logic
		);
	end component;
	
	component ec16_dec_spf is
		port (
			spf			: out std_logic_vector (1 downto 0);
			opc			: in std_logic_vector (15 downto 8);
			state_0		: in std_logic;
			state_1		: in std_logic
		);
	end component;
	
	component ec16_dec_id is
		port (
			id			: out std_logic_vector (1 downto 0);
			opc			: in std_logic_vector (15 downto 8);
			state_1		: in std_logic
		);
	end component;
	
	component ec16_dec_ia is
		port (
			ia			: out std_logic_vector (1 downto 0);
			opc			: in std_logic_vector (15 downto 8);
			state_0		: in std_logic;
			state_1		: in std_logic
		);
	end component;
	
	component ec16_dec_iw is
		port (
			iw			: out std_logic;
			opc			: in std_logic_vector (15 downto 8);
			state_1		: in std_logic
		);
	end component;
	
	component ec16_dec_ir is
		port (
			ir			: out std_logic;
			opc			: in std_logic_vector (15 downto 8);
			state_0		: in std_logic;
			state_1		: in std_logic
		);
	end component;
	
	component ec16_dec_ai is
		port (
			ai			: out std_logic_vector (1 downto 0);
			opc			: in std_logic_vector (15 downto 8);
			state_1		: in std_logic;
			state_2		: in std_logic
		);
	end component;
	
	component ec16_dec_ae is
		port (
			ae			: out std_logic;
			opc			: in std_logic_vector (15 downto 8);
			state_1		: in std_logic;
			state_2		: in std_logic
		);
	end component;
	
	component ec16_dec_si is
		port (
			si			: out std_logic;
			opc			: in std_logic_vector (15 downto 8)
		);
	end component;
	
	component ec16_dec_se is
		port (
			se			: out std_logic;
			opc			: in std_logic_vector (15 downto 8);
			state_1		: in std_logic
		);
	end component;
	
	component ec16_dec_ce is
		port (
			ce			: out std_logic;
			opc			: in std_logic_vector (15 downto 8)
		);
	end component;
	
	component ec16_dec_cd is
		port (
			cd			: out std_logic;
			opc			: in std_logic_vector (15 downto 8)
		);
	end component;
	
	component ec16_dec_iee is
		port (
			iee			: out std_logic;
			opc			: in std_logic_vector (15 downto 8)
		);
	end component;
	
	component ec16_dec_ied is
		port (
			ied			: out std_logic;
			opc			: in std_logic_vector (15 downto 8)
		);
	end component;
	
	component ec16_dec_ci is
		port (
			ci			: out std_logic;
			opc			: in std_logic_vector (15 downto 8)
		);
	end component;
	
	component ec16_dec_im is
		port (
			im			: out std_logic;
			opc			: in std_logic_vector (15 downto 8)
		);
	end component;
	
	component ec16_dec_rti is
		port (
			rti			: out std_logic;
			opc			: in std_logic_vector (15 downto 8);
			state_2		: in std_logic
		);
	end component;
	
	component ec16_dec_afn is
		port (
			afn			: out std_logic_vector (3 downto 0);
			opc			: in std_logic_vector (15 downto 8)
		);
	end component;
	
begin

	inst_dec_pi : ec16_dec_pi
	port map(
		pi			=> pi,
		opc			=> opc,
		state_0		=> state_0,
		state_1		=> state_1,
		branch		=> branch	
	);
		

	inst_dec_pf : ec16_dec_pf
	port map(
		pf			=> pf,
		opc			=> opc,
		state_0		=> state_0,
		state_1		=> state_1,
		branch		=> branch,
		int			=> int
	);


	inst_dec_ea : ec16_dec_ea
	port map(
		ea			=> ea,
		opc			=> opc,
		state_1		=> state_1
	);


	inst_dec_ew : ec16_dec_ew
	port map(
		ew			=> ew,
		opc			=> opc,
		state_1		=> state_1
	);


	inst_dec_er : ec16_dec_er
	port map(
		er			=> er,
		opc			=> opc,
		state_r		=> state_r,
		state_0		=> state_0,
		state_1		=> state_1,
		state_2		=> state_2,
		branch		=> branch,
		int			=> int
	);


	inst_dec_oe : ec16_dec_oe
	port map(
		oe			=> oe,
		opc			=> opc,
		state_0		=> state_0,
		branch		=> branch
	);


	inst_dec_spf : ec16_dec_spf
	port map(
		spf			=> spf,
		opc			=> opc,
		state_0		=> state_0,
		state_1		=> state_1
	);


	inst_dec_id : ec16_dec_id
	port map(
		id			=> id,
		opc			=> opc,
		state_1		=> state_1
	);


	inst_dec_ia : ec16_dec_ia
	port map(
		ia			=> ia,
		opc			=> opc,
		state_0		=> state_0,
		state_1		=> state_1
	);


	inst_dec_iw : ec16_dec_iw
	port map(
		iw			=> iw,
		opc			=> opc,
		state_1		=> state_1
	);


	inst_dec_ir : ec16_dec_ir
	port map(
		ir			=> ir,
		opc			=> opc,
		state_0		=> state_0,
		state_1		=> state_1
	);


	inst_dec_ai : ec16_dec_ai
	port map(
		ai			=> ai,
		opc			=> opc,
		state_1		=> state_1,
		state_2		=> state_2
	);


	inst_dec_ae : ec16_dec_ae
	port map(
		ae			=> ae,
		opc			=> opc,
		state_1		=> state_1,
		state_2		=> state_2
	);


	inst_dec_si : ec16_dec_si
	port map(
		si			=> si,
		opc			=> opc
	);


	inst_dec_se : ec16_dec_se
	port map(
		se			=> se,
		opc			=> opc,
		state_1		=> state_1
	);


	inst_dec_ce : ec16_dec_ce
	port map(
		ce			=> ce,
		opc			=> opc
	);


	inst_dec_cd : ec16_dec_cd
	port map(
		cd			=> cd,
		opc			=> opc
	);


	inst_dec_iee : ec16_dec_iee
	port map(
		iee			=> iee,
		opc			=> opc
	);


	inst_dec_ied : ec16_dec_ied
	port map(
		ied			=> ied,
		opc			=> opc
	);


	inst_dec_ci : ec16_dec_ci
	port map(
		ci			=> ci,
		opc			=> opc
	);


	inst_dec_im : ec16_dec_im
	port map(
		im			=> im,
		opc			=> opc
	);
	
	inst_dec_rti : ec16_dec_rti
	port map(
		rti			=> rti,
		opc			=> opc,
		state_2		=> state_2
	);


	inst_dec_afn : ec16_dec_afn
	port map(
		afn			=> afn,
		opc			=> opc
	);

	
end architecture;
