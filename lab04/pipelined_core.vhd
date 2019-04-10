---------------------------------------------------------------------------
-- pipelined_core.vhd - A Single-Cycle Processor Implementation
--
-- Notes : 
--
-- See exercise book for the block diagram of this pipelined
-- processor core.
--
-- Instruction Set Architecture (ISA) for the single-cycle-core:
--   Each instruction is 16-bit wide, with four 4-bit fields.
--
--     noop      
--        # no operation or to signal end of program
--        # format:  | opcode = 0 |  0   |  0   |   0    | 
--
--     load  rt, rs, offset     
--        # load data at memory location (rs + offset) into rt
--        # format:  | opcode = 1 |  rs  |  rt  | offset |
--
--     store rt, rs, offset
--        # store data rt into memory location (rs + offset)
--        # format:  | opcode = 3 |  rs  |  rt  | offset |
--
--     add   rd, rs, rt
--        # rd <- rs + rt
--        # format:  | opcode = 8 |  rs  |  rt  |   rd   |
--		
--		 bne   rt, rs, addr
--        # pc <- addr when rt != rs
--        # format:  | opcode = 4 |  rs  |  rt  |  addr  |
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
-- 
-- Modified from Lih Wen Koh's Single Cycle Core by Henry Veng (z5113239)
--
-- The pipelined processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
-- LUH handling by Henry Veng 10/04/19
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Modifications by Henry Veng
-- refer to design in exercise book
entity pipelined_core is
    port ( reset  : in  std_logic;
           clk    : in  std_logic );
end pipelined_core;

architecture structural of pipelined_core is

component program_counter is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(3 downto 0);
           addr_out : out std_logic_vector(3 downto 0) );
end component;

component instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(3 downto 0);
           insn_out : out std_logic_vector(15 downto 0) );
end component;

component sign_extend_4to16 is
    port ( data_in  : in  std_logic_vector(3 downto 0);
           data_out : out std_logic_vector(15 downto 0) );
end component;

component mux_2to1_4b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(3 downto 0);
           data_b     : in  std_logic_vector(3 downto 0);
           data_out   : out std_logic_vector(3 downto 0) );
end component;

component mux_2to1_16b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(15 downto 0);
           data_b     : in  std_logic_vector(15 downto 0);
           data_out   : out std_logic_vector(15 downto 0) );
end component;

-- Modification
component control_unit is
    port ( opcode     : in  std_logic_vector(3 downto 0);
           reg_dst    : out std_logic;
           reg_write  : out std_logic;
           alu_src    : out std_logic;
			  alu			 : out std_logic;
			  branch		 : out std_logic;
           mem_write  : out std_logic;
           mem_to_reg : out std_logic );
end component;
-- end modification

component register_file is
    port ( reset           : in  std_logic;
           clk             : in  std_logic;
           read_register_a : in  std_logic_vector(3 downto 0);
           read_register_b : in  std_logic_vector(3 downto 0);
           write_enable    : in  std_logic;
           write_register  : in  std_logic_vector(3 downto 0);
           write_data      : in  std_logic_vector(15 downto 0);
           read_data_a     : out std_logic_vector(15 downto 0);
           read_data_b     : out std_logic_vector(15 downto 0) );
end component;

component adder_4b is
    port ( src_a     : in  std_logic_vector(3 downto 0);
           src_b     : in  std_logic_vector(3 downto 0);
           sum       : out std_logic_vector(3 downto 0);
           carry_out : out std_logic );
end component;

-- Modification
component alu_16 is
	port ( src_a     : in  std_logic_vector(15 downto 0);
          src_b     : in  std_logic_vector(15 downto 0);
			 alu		  : in  std_logic;
          result    : out std_logic_vector(15 downto 0);
          carry_out : out std_logic;
			 zero		  : out std_logic );
end component;
-- end modification

component data_memory is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           write_data   : in  std_logic_vector(15 downto 0);
           addr_in      : in  std_logic_vector(3 downto 0);
           data_out     : out std_logic_vector(15 downto 0) );
end component;

-- pipeline mods
component reg_IF_ID is
	port ( clk, reset : in  std_logic;
			 instr_in   : in  std_logic_vector (15 downto 0);
			 instr_out  : out std_logic_vector (15 downto 0) );
end component;

component reg_ID_EX is
	port ( clk, reset  		: in  std_logic;
			 mem_to_reg_in 	: in	std_logic;
			 reg_write_in 		: in  std_logic;
			 branch_in			: in  std_logic;
			 mem_write_in 		: in  std_logic;
			 alu_in				: in  std_logic;
			 alu_src_in			: in  std_logic;
			 reg_dst_in			: in  std_logic;
			 read_data_a_in	: in  std_logic_vector(15 downto 0);
			 read_data_b_in   : in  std_logic_vector(15 downto 0);
			 imm_in				: in  std_logic_vector(15 downto 0);
			 write_reg_a_in	: in  std_logic_vector(3 downto 0);
			 write_reg_b_in	: in  std_logic_vector(3 downto 0);
			 branch_addr_in	: in  std_logic_vector(3 downto 0);
			 
			 mem_to_reg_out 	: out	std_logic;
			 reg_write_out 	: out std_logic;
			 branch_out			: out std_logic;
			 mem_write_out 	: out std_logic;
			 alu_out				: out std_logic;
			 alu_src_out		: out std_logic;
			 reg_dst_out		: out std_logic;
			 read_data_a_out	: out std_logic_vector(15 downto 0);
			 read_data_b_out  : out std_logic_vector(15 downto 0);
			 imm_out				: out std_logic_vector(15 downto 0);
			 write_reg_a_out	: out std_logic_vector(3 downto 0);
			 write_reg_b_out	: out std_logic_vector(3 downto 0);
			 branch_addr_out	: out  std_logic_vector(3 downto 0) );
end component;

component reg_EX_MEM is
	port ( clk, reset  		: in  std_logic;
			 mem_to_reg_in 	: in	std_logic;
			 reg_write_in 		: in  std_logic;
			 branch_in			: in  std_logic;
			 mem_write_in 		: in  std_logic;
			 zero_in				: in  std_logic;
			 alu_result_in    : in  std_logic_vector(15 downto 0);
			 read_data_b_in   : in  std_logic_vector(15 downto 0);
			 write_reg_in	: in  std_logic_vector(3 downto 0);
			 branch_addr_in	: in  std_logic_vector(3 downto 0);
			 
			 mem_to_reg_out 	: out	std_logic;
			 reg_write_out 	: out std_logic;
			 branch_out			: out std_logic;
			 mem_write_out 	: out std_logic;
			 zero_out			: out std_logic;
			 alu_result_out    : out  std_logic_vector(15 downto 0);
			 read_data_b_out  : out std_logic_vector(15 downto 0);
			 write_reg_out	: out std_logic_vector(3 downto 0);
			 branch_addr_out	: out  std_logic_vector(3 downto 0) );
end component;

component reg_MEM_WB is
	port ( clk, reset  		: in  std_logic;
			 mem_to_reg_in 	: in	std_logic;
			 reg_write_in 		: in  std_logic;
			 mem_data_in		: in  std_logic_vector(15 downto 0);
			 alu_result_in    : in  std_logic_vector(15 downto 0);
			 write_reg_in		: in  std_logic_vector(3 downto 0);
			 
			 mem_to_reg_out 	: out	std_logic;
			 reg_write_out 	: out std_logic;
			 mem_data_out		: out std_logic_vector(15 downto 0);
			 alu_result_out	: out  std_logic_vector(15 downto 0);
			 write_reg_out		: out std_logic_vector(3 downto 0) );
end component;
-- end mods

signal sig_next_pc              : std_logic_vector(3 downto 0);
signal sig_curr_pc              : std_logic_vector(3 downto 0);
signal sig_one_4b               : std_logic_vector(3 downto 0);
signal sig_pc_carry_out         : std_logic;
--signal sig_insn                 : std_logic_vector(15 downto 0);
--signal sig_sign_extended_offset : std_logic_vector(15 downto 0);
--signal sig_reg_dst              : std_logic;
--signal sig_reg_write            : std_logic;
--signal sig_alu_src              : std_logic;
--signal sig_mem_write            : std_logic;
--signal sig_mem_to_reg           : std_logic;
--signal sig_write_register       : std_logic_vector(3 downto 0);
signal sig_write_data           : std_logic_vector(15 downto 0);
--signal sig_read_data_a          : std_logic_vector(15 downto 0);
--signal sig_read_data_b          : std_logic_vector(15 downto 0);
signal sig_alu_src_b            : std_logic_vector(15 downto 0);
--signal sig_alu_result           : std_logic_vector(15 downto 0); 
signal sig_alu_carry_out        : std_logic;
--signal sig_data_mem_out         : std_logic_vector(15 downto 0);
-- modifications
--signal sig_zero					  : std_logic;
--signal sig_alu						  : std_logic;
--signal sig_branch					  : std_logic;
signal sig_branch_sel			  : std_logic;
signal sig_next_instr			  : std_logic_vector(3 downto 0);

-- modifications pipeline
signal sig_insn_if              : std_logic_vector(15 downto 0);

signal sig_insn_id				  : std_logic_vector(15 downto 0);
signal sig_mem_to_reg_id		  : std_logic;
signal sig_reg_write_id			  : std_logic;
signal sig_branch_id				  : std_logic;
signal sig_mem_write_id			  : std_logic;
signal sig_alu_id					  : std_logic;
signal sig_alu_src_id			  : std_logic;
signal sig_reg_dst_id			  : std_logic;
signal sig_read_data_a_id		  : std_logic_vector(15 downto 0);
signal sig_read_data_b_id		  : std_logic_vector(15 downto 0);
signal sig_sign_extended_offset_id : std_logic_vector(15 downto 0);

signal sig_mem_to_reg_ex		  : std_logic;
signal sig_reg_write_ex			  : std_logic;
signal sig_branch_ex				  : std_logic;
signal sig_mem_write_ex			  : std_logic;
signal sig_alu_ex					  : std_logic;
signal sig_alu_src_ex			  : std_logic;
signal sig_reg_dst_ex			  : std_logic;
signal sig_read_data_a_ex		  : std_logic_vector(15 downto 0);
signal sig_read_data_b_ex		  : std_logic_vector(15 downto 0);
signal sig_sign_extended_offset_ex : std_logic_vector(15 downto 0);
signal sig_write_reg_a_ex		  : std_logic_vector(3 downto 0);
signal sig_write_reg_b_ex		  : std_logic_vector(3 downto 0);
signal sig_write_register_ex    : std_logic_vector(3 downto 0);
signal sig_alu_result_ex        : std_logic_vector(15 downto 0);
signal sig_zero_ex				  : std_logic;
signal sig_branch_addr_ex		  : std_logic_vector(3 downto 0);

signal sig_mem_to_reg_mem		  : std_logic;
signal sig_reg_write_mem		  : std_logic;
signal sig_branch_mem			  : std_logic;
signal sig_mem_write_mem		  : std_logic;
signal sig_zero_mem				  : std_logic;
signal sig_read_data_b_mem		  : std_logic_vector(15 downto 0);
signal sig_write_register_mem   : std_logic_vector(3 downto 0);
signal sig_alu_result_mem       : std_logic_vector(15 downto 0);
signal sig_data_mem_out_mem     : std_logic_vector(15 downto 0);
signal sig_branch_addr_mem		  : std_logic_vector(3 downto 0);

signal sig_mem_to_reg_wb		  : std_logic;
signal sig_reg_write_wb		  	  : std_logic;
signal sig_data_mem_out_wb      : std_logic_vector(15 downto 0);
signal sig_alu_result_wb        : std_logic_vector(15 downto 0);
signal sig_write_register_wb    : std_logic_vector(3 downto 0);

begin

    sig_one_4b <= "0001";

    pc : program_counter
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_next_pc,
               addr_out => sig_curr_pc ); 
	 
    next_pc : mux_2to1_4b
	 port map ( mux_select => sig_branch_sel,
					data_a     => sig_next_instr,
					data_b     => sig_branch_addr_mem,
					data_out   => sig_next_pc );
	 
	 adder_pc : adder_4b 
    port map ( src_a     => sig_curr_pc, 
               src_b     => sig_one_4b,
               sum       => sig_next_instr,   
               carry_out => sig_pc_carry_out );
	 -- end modification
    
    insn_mem : instruction_memory 
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_curr_pc,
               insn_out => sig_insn_if );

    -- pipeline register if/id
	 pipe_reg_if_id : reg_IF_ID
	 port map ( reset     => reset,
					clk       => clk,
					instr_in  => sig_insn_if,
					instr_out => sig_insn_id );
	 
	 -- modified if/id
    sign_extend : sign_extend_4to16 
    port map ( data_in  => sig_insn_id(3 downto 0),
               data_out => sig_sign_extended_offset_id );

	 -- modified if/id/ex/wb
	 reg_file : register_file 
    port map ( reset           => reset, 
               clk             => clk,
               read_register_a => sig_insn_id(11 downto 8),
               read_register_b => sig_insn_id(7 downto 4),
               write_enable    => sig_reg_write_wb,
               write_register  => sig_write_register_wb,
               write_data      => sig_write_data,
               read_data_a     => sig_read_data_a_id,
               read_data_b     => sig_read_data_b_id );
	 
	 -- modified if/id/ex
	 -- Modification
    ctrl_unit : control_unit 
    port map ( opcode     => sig_insn_id(15 downto 12),
               reg_dst    => sig_reg_dst_id,
               reg_write  => sig_reg_write_id,
               alu_src    => sig_alu_src_id,
					alu		  => sig_alu_id,
					branch	  => sig_branch_id,
               mem_write  => sig_mem_write_id,
               mem_to_reg => sig_mem_to_reg_id );
	 -- end modification

	 -- pipeline register id/ex
	 pipe_reg_id_ex : reg_ID_EX
	 port map ( clk				 => clk,
					reset  	       => reset,
					mem_to_reg_in 	 => sig_mem_to_reg_id,
					reg_write_in 	 => sig_reg_write_id,
					branch_in		 => sig_branch_id,
					mem_write_in 	 => sig_mem_write_id,
					alu_in			 => sig_alu_id,
					alu_src_in		 => sig_alu_src_id,
					reg_dst_in		 => sig_reg_dst_id,
					read_data_a_in	 => sig_read_data_a_id,
					read_data_b_in  => sig_read_data_b_id,
					imm_in			 => sig_sign_extended_offset_id,
					write_reg_a_in	 => sig_insn_id(7 downto 4),
					write_reg_b_in	 => sig_insn_id(3 downto 0),
					branch_addr_in	 => sig_insn_id(3 downto 0),
					
					mem_to_reg_out  => sig_mem_to_reg_ex,
					reg_write_out 	 => sig_reg_write_ex,
					branch_out		 => sig_branch_ex,
					mem_write_out 	 => sig_mem_write_ex,
					alu_out			 => sig_alu_ex,
					alu_src_out		 => sig_alu_src_ex,
					reg_dst_out		 => sig_reg_dst_ex,
					read_data_a_out => sig_read_data_a_ex,
					read_data_b_out => sig_read_data_b_ex,
					imm_out			 => sig_sign_extended_offset_ex,
					write_reg_a_out => sig_write_reg_a_ex,
					write_reg_b_out => sig_write_reg_b_ex,
					branch_addr_out => sig_branch_addr_ex );
	 
	 -- modified ex
    mux_reg_dst : mux_2to1_4b 
    port map ( mux_select => sig_reg_dst_ex,
               data_a     => sig_write_reg_a_ex,
               data_b     => sig_write_reg_b_ex,
               data_out   => sig_write_register_ex );
    
	 -- modified ex
    mux_alu_src : mux_2to1_16b 
    port map ( mux_select => sig_alu_src_ex,
               data_a     => sig_read_data_b_ex,
               data_b     => sig_sign_extended_offset_ex,
               data_out   => sig_alu_src_b );
	 
	 -- modified ex
	 -- Modificaiton
    alu : alu_16 
    port map ( src_a     => sig_read_data_a_ex,
               src_b     => sig_alu_src_b,
					alu		 => sig_alu_ex,
               result    => sig_alu_result_ex,
               carry_out => sig_alu_carry_out,
					zero 		 => sig_zero_ex );
	 -- end modification
	 
	 -- pipeline register ex/mem
	 pipe_reg_ex_mem : reg_EX_MEM
	 port map ( clk				 => clk,
					reset				 => reset,
					mem_to_reg_in 	 => sig_mem_to_reg_ex,
					reg_write_in 	 => sig_reg_write_ex,
					branch_in		 => sig_branch_ex,
					mem_write_in 	 => sig_mem_write_ex,
					zero_in			 => sig_zero_ex,
					alu_result_in	 => sig_alu_result_ex,
					read_data_b_in  => sig_read_data_b_ex,
					write_reg_in	 => sig_write_register_ex,
					branch_addr_in	 => sig_branch_addr_ex,
			 
					mem_to_reg_out  => sig_mem_to_reg_mem,
					reg_write_out 	 => sig_reg_write_mem,
					branch_out		 => sig_branch_mem,
					mem_write_out 	 => sig_mem_write_mem,
					zero_out			 => sig_zero_mem,
					alu_result_out  => sig_alu_result_mem,
					read_data_b_out => sig_read_data_b_mem,
					write_reg_out 	 => sig_write_register_mem,
					branch_addr_out => sig_branch_addr_mem );
	 
	 -- modification mem
	 -- Modification
	 sig_branch_sel <= (not sig_zero_mem) and sig_branch_mem;
	 
	 -- modification mem
    data_mem : data_memory 
    port map ( reset        => reset,
               clk          => clk,
               write_enable => sig_mem_write_mem,
               write_data   => sig_read_data_b_mem,
               addr_in      => sig_alu_result_mem(3 downto 0),
               data_out     => sig_data_mem_out_mem );
    
	 -- pipeline register mem/wb
	 pipe_reg_mem_wb : reg_MEM_WB
	 port map ( clk			   => clk,
					reset  		   => reset,
					mem_to_reg_in 	=> sig_mem_to_reg_mem,
					reg_write_in 	=> sig_reg_write_mem,
					mem_data_in		=> sig_data_mem_out_mem,
					alu_result_in  => sig_alu_result_mem,
					write_reg_in	=> sig_write_register_mem,
			 
					mem_to_reg_out => sig_mem_to_reg_wb,
					reg_write_out 	=> sig_reg_write_wb,
					mem_data_out	=> sig_data_mem_out_wb,
					alu_result_out	=> sig_alu_result_wb,
					write_reg_out	=> sig_write_register_wb);
	 
    mux_mem_to_reg : mux_2to1_16b 
    port map ( mux_select => sig_mem_to_reg_wb,
               data_a     => sig_alu_result_wb,
               data_b     => sig_data_mem_out_wb,
               data_out   => sig_write_data );

end structural;
