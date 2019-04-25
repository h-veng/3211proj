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
--     iord rt
--        # rt <- io_data
--        # format:  | opcode = 2 |  0   |  rt  |   0    |
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
           clk    : in  std_logic;
			  io_data: in  std_logic_vector(7 downto 0);
			  io_next: out std_logic );
end pipelined_core;

architecture structural of pipelined_core is

component program_counter is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
			  pc_write : in  std_logic;
           addr_in  : in  std_logic_vector(7 downto 0);
           addr_out : out std_logic_vector(7 downto 0) );
end component;

component instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(7 downto 0);
           insn_out : out std_logic_vector(19 downto 0) );
end component;

component sign_extend_4to16 is
    port ( data_in  : in  std_logic_vector(7 downto 0);
           data_out : out std_logic_vector(15 downto 0) );
end component;

component mux_2to1_4b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(3 downto 0);
           data_b     : in  std_logic_vector(3 downto 0);
           data_out   : out std_logic_vector(3 downto 0) );
end component;

component mux_2to1_8b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(7 downto 0);
           data_b     : in  std_logic_vector(7 downto 0);
           data_out   : out std_logic_vector(7 downto 0) );
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
			  ctrl_flush : in  std_logic;
			  io_read    : out std_logic;
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
    port ( src_a     : in  std_logic_vector(7 downto 0);
           src_b     : in  std_logic_vector(7 downto 0);
           sum       : out std_logic_vector(7 downto 0);
           carry_out : out std_logic );
end component;

-- Modification
component alu_16 is
	port ( src_a     : in  std_logic_vector(15 downto 0);
          src_b     : in  std_logic_vector(15 downto 0);
			 io_data	  : in  std_logic_vector(7 downto 0);
			 io_read	  : in  std_logic;
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
           addr_in      : in  std_logic_vector(7 downto 0);			--modified for 8 bit
           data_out     : out std_logic_vector(15 downto 0) );
end component;

-- pipeline mods
component reg_IF_ID is
	port ( clk, reset : in  std_logic;
			 write_en	: in  std_logic;
			 flush		: in  std_logic;
			 instr_in   : in  std_logic_vector (19 downto 0);
			 instr_out  : out std_logic_vector (19 downto 0) );
end component;

component reg_ID_EX is
	port ( clk, reset  		: in  std_logic;
			 flush				: in  std_logic;
			 mem_to_reg_in 	: in	std_logic;
			 reg_write_in 		: in  std_logic;
			 branch_in			: in  std_logic;
			 mem_write_in 		: in  std_logic;
			 io_read_in       : in  std_logic;
			 alu_in				: in  std_logic;
			 alu_src_in			: in  std_logic;
			 reg_dst_in			: in  std_logic;
			 read_data_a_in	: in  std_logic_vector(15 downto 0);
			 read_data_b_in   : in  std_logic_vector(15 downto 0);
			 imm_in				: in  std_logic_vector(15 downto 0);
			 reg_rs_in			: in 	std_logic_vector(3 downto 0);
			 write_reg_a_in	: in  std_logic_vector(3 downto 0);
			 write_reg_b_in	: in  std_logic_vector(3 downto 0);
			 branch_addr_in	: in  std_logic_vector(7 downto 0);
			 
			 mem_to_reg_out 	: out	std_logic;
			 reg_write_out 	: out std_logic;
			 branch_out			: out std_logic;
			 mem_write_out 	: out std_logic;
			 io_read_out      : out std_logic;
			 alu_out				: out std_logic;
			 alu_src_out		: out std_logic;
			 reg_dst_out		: out std_logic;
			 read_data_a_out	: out std_logic_vector(15 downto 0);
			 read_data_b_out  : out std_logic_vector(15 downto 0);
			 imm_out				: out std_logic_vector(15 downto 0);
			 reg_rs_out			: out	std_logic_vector(3 downto 0);
			 write_reg_a_out	: out std_logic_vector(3 downto 0);
			 write_reg_b_out	: out std_logic_vector(3 downto 0);
			 branch_addr_out	: out  std_logic_vector(7 downto 0) );
end component;

component reg_EX_MEM is
	port ( clk, reset  		: in  std_logic;
			 flush				: in  std_logic;
			 mem_to_reg_in 	: in	std_logic;
			 reg_write_in 		: in  std_logic;
			 branch_in			: in  std_logic;
			 mem_write_in 		: in  std_logic;
			 zero_in				: in  std_logic;
			 alu_result_in    : in  std_logic_vector(15 downto 0);
			 read_data_b_in   : in  std_logic_vector(15 downto 0);
			 write_reg_in	: in  std_logic_vector(3 downto 0);
			 branch_addr_in	: in  std_logic_vector(7 downto 0);
			 
			 mem_to_reg_out 	: out	std_logic;
			 reg_write_out 	: out std_logic;
			 branch_out			: out std_logic;
			 mem_write_out 	: out std_logic;
			 zero_out			: out std_logic;
			 alu_result_out    : out  std_logic_vector(15 downto 0);
			 read_data_b_out  : out std_logic_vector(15 downto 0);
			 write_reg_out	: out std_logic_vector(3 downto 0);
			 branch_addr_out	: out  std_logic_vector(7 downto 0) );
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

component hazard_detection_unit is
	port ( mem_read : in std_logic; --mem_to_reg_ex
			 id_reg_rs : in std_logic_vector(3 downto 0);
			 id_reg_rt : in std_logic_vector(3 downto 0);
			 ex_reg_rt : in std_logic_vector(3 downto 0);
			 pc_write : out std_logic;
			 if_id_write : out std_logic;
			 id_ex_ctrl_flush : out std_logic );
end component;

-- Forwarding Unit Mods
component forwarding_unit is
    Port ( ex_mem_regWrite : in  STD_LOGIC;
			  ex_mem_rd			: in	STD_LOGIC_VECTOR(3 downto 0);
			  id_ex_rs			: in	STD_LOGIC_VECTOR(3 downto 0);
			  id_ex_rt			: in	STD_LOGIC_VECTOR(3 downto 0);
			  mem_wb_regWrite : in  STD_LOGIC;
			  mem_wb_rd			: in	STD_LOGIC_VECTOR(3 downto 0);
			  alu_op_1_mux		: out STD_LOGIC_vector(1 downto 0);
			  alu_op_2_mux			: out STD_LOGIC_VECTOR(1 downto 0));
end component;


component alu_op_1_mux is
    Port ( reg : in  STD_LOGIC_VECTOR (15 downto 0);
			  mem_forward: in STD_LOGIC_VECTOR (15 downto 0);
			  wb_forward: in STD_LOGIC_VECTOR (15 downto 0);
			  output: out STD_LOGIC_VECTOR (15 downto 0);
			  mux_controller: in STD_LOGIC_VECTOR (1 downto 0));
end component;


component alu_op_2_mux is
    Port ( reg : in  STD_LOGIC_VECTOR (15 downto 0);
			  mem_forward: in STD_LOGIC_VECTOR (15 downto 0);
			  wb_forward: in STD_LOGIC_VECTOR (15 downto 0);
			  output: out STD_LOGIC_VECTOR (15 downto 0);
			  mux_controller: in STD_LOGIC_VECTOR (1 downto 0));
end component;

component branch_prediction_unit is
	port ( insn_op_code : in std_logic_vector(3 downto 0);
			 imm_in : in std_logic_vector(7 downto 0);
			 next_addr_in : in std_logic_vector(7 downto 0);
			 imm_out : out std_logic_vector(7 downto 0);
			 next_addr_out : out std_logic_vector(7 downto 0) );
end component;

-- end mods

signal sig_next_pc              : std_logic_vector(7 downto 0);
signal sig_curr_pc              : std_logic_vector(7 downto 0);
signal sig_one_8b               : std_logic_vector(7 downto 0);
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
signal sig_next_instr			  : std_logic_vector(7 downto 0);

-- modifications pipeline
signal sig_insn_if              : std_logic_vector(19 downto 0);
signal sig_insn_if_final		  : std_logic_vector(19 downto 0);

signal sig_insn_id				  : std_logic_vector(19 downto 0);
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
signal sig_io_read_id			  : std_logic;

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
signal sig_reg_rs_ex				  : std_logic_vector(3 downto 0);
signal sig_write_reg_a_ex		  : std_logic_vector(3 downto 0); -- also reg rt
signal sig_write_reg_b_ex		  : std_logic_vector(3 downto 0);
signal sig_write_register_ex    : std_logic_vector(3 downto 0);
signal sig_alu_result_ex        : std_logic_vector(15 downto 0);
signal sig_zero_ex				  : std_logic;
signal sig_branch_addr_ex		  : std_logic_vector(7 downto 0);
signal sig_io_read_ex			  : std_logic;

signal sig_mem_to_reg_mem		  : std_logic;
signal sig_reg_write_mem		  : std_logic;
signal sig_branch_mem			  : std_logic;
signal sig_mem_write_mem		  : std_logic;
signal sig_zero_mem				  : std_logic;
signal sig_read_data_b_mem		  : std_logic_vector(15 downto 0);
signal sig_write_register_mem   : std_logic_vector(3 downto 0);
signal sig_alu_result_mem       : std_logic_vector(15 downto 0);
signal sig_data_mem_out_mem     : std_logic_vector(15 downto 0);
signal sig_branch_addr_mem		  : std_logic_vector(7 downto 0);

signal sig_mem_to_reg_wb		  : std_logic;
signal sig_reg_write_wb		  	  : std_logic;
signal sig_data_mem_out_wb      : std_logic_vector(15 downto 0);
signal sig_alu_result_wb        : std_logic_vector(15 downto 0);
signal sig_write_register_wb    : std_logic_vector(3 downto 0);

-- signals for hazard detection unit
signal sig_pc_write				  : std_logic;
signal sig_if_id_write			  : std_logic;
signal sig_ctrl_flush			  : std_logic;

--modifications forwarding table
signal sig_alu_mux1_sel_ex	:std_logic_vector(1 downto 0);
signal sig_alu_mux2_sel_ex	:std_logic_vector(1 downto 0);
signal sig_alu_mux1_result_ex: std_logic_vector(15 downto 0);
signal sig_alu_mux2_result_ex: std_logic_vector(15 downto 0);

-- signals for branch prediction
signal sig_pred_instr			  : std_logic_vector(7 downto 0);
signal sig_branch_imm			  : std_logic_vector(7 downto 0);

begin

    sig_one_8b <= "00000001";

    pc : program_counter
    port map ( reset    => reset,
               clk      => clk,
					pc_write => sig_pc_write,
               addr_in  => sig_next_pc,
               addr_out => sig_curr_pc ); 
	 
    next_pc : mux_2to1_8b
	 port map ( mux_select => sig_branch_sel,
					data_a     => sig_pred_instr,
					data_b     => sig_branch_addr_mem,
					data_out   => sig_next_pc );
	 
	 adder_pc : adder_4b 
    port map ( src_a     => sig_curr_pc, 
               src_b     => sig_one_8b,
               sum       => sig_next_instr,   
               carry_out => sig_pc_carry_out );
	 -- end modification
    
    insn_mem : instruction_memory 
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_curr_pc,
               insn_out => sig_insn_if );
	 
	 sig_insn_if_final <= sig_insn_if(19 downto 8) & sig_branch_imm;
	 
    -- pipeline register if/id
	 pipe_reg_if_id : reg_IF_ID
	 port map ( reset     => reset,
					clk       => clk,
					write_en  => sig_if_id_write,
					flush		 => sig_branch_sel,
					instr_in  => sig_insn_if_final,
					instr_out => sig_insn_id );
	 
	 -- modified if/id
    sign_extend : sign_extend_4to16 
    port map ( data_in  => sig_insn_id(7 downto 0),
               data_out => sig_sign_extended_offset_id );

	 -- modified if/id/ex/wb
	 reg_file : register_file 
    port map ( reset           => reset, --good
               clk             => clk,	-- good
               read_register_a => sig_insn_id(15 downto 12), --good
               read_register_b => sig_insn_id(11 downto 8), -- good
               write_enable    => sig_reg_write_wb,
               write_register  => sig_write_register_wb,
               write_data      => sig_write_data,
               read_data_a     => sig_read_data_a_id,
               read_data_b     => sig_read_data_b_id );
	 
	 -- modified if/id/ex
	 -- Modification
    ctrl_unit : control_unit 
    port map ( opcode     => sig_insn_id(19 downto 16),
					ctrl_flush => sig_ctrl_flush,
					io_read    => sig_io_read_id,
               reg_dst    => sig_reg_dst_id,
               reg_write  => sig_reg_write_id,
               alu_src    => sig_alu_src_id,
					alu		  => sig_alu_id,
					branch	  => sig_branch_id,
               mem_write  => sig_mem_write_id,
               mem_to_reg => sig_mem_to_reg_id );
	 io_next <= sig_io_read_id;
	 -- end modification

	 -- pipeline register id/ex
	 pipe_reg_id_ex : reg_ID_EX
	 port map ( clk				 => clk,
					reset  	       => reset,
					flush				 => sig_branch_sel,
					mem_to_reg_in 	 => sig_mem_to_reg_id,
					reg_write_in 	 => sig_reg_write_id,
					branch_in		 => sig_branch_id,
					mem_write_in 	 => sig_mem_write_id,
					io_read_in		 => sig_io_read_id,
					alu_in			 => sig_alu_id,
					alu_src_in		 => sig_alu_src_id,
					reg_dst_in		 => sig_reg_dst_id,
					read_data_a_in	 => sig_read_data_a_id,
					read_data_b_in  => sig_read_data_b_id,
					imm_in			 => sig_sign_extended_offset_id,
					reg_rs_in		 => sig_insn_id(15 downto 12),
					write_reg_a_in	 => sig_insn_id(11 downto 8),
					write_reg_b_in	 => sig_insn_id(7 downto 4),
					branch_addr_in	 => sig_insn_id(7 downto 0),
					
					mem_to_reg_out  => sig_mem_to_reg_ex,
					reg_write_out 	 => sig_reg_write_ex,
					branch_out		 => sig_branch_ex,
					mem_write_out 	 => sig_mem_write_ex,
					io_read_out		 => sig_io_read_ex,
					alu_out			 => sig_alu_ex,
					alu_src_out		 => sig_alu_src_ex,
					reg_dst_out		 => sig_reg_dst_ex,
					read_data_a_out => sig_read_data_a_ex,
					read_data_b_out => sig_read_data_b_ex,
					imm_out			 => sig_sign_extended_offset_ex,
					reg_rs_out		 => sig_reg_rs_ex,
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
               data_a     => sig_alu_mux2_result_ex,
               data_b     => sig_sign_extended_offset_ex,
               data_out   => sig_alu_src_b );

   -- sig_alu_mux2_result_ex
	 -- modified ex
	 -- Modificaiton
    alu : alu_16 
    port map ( src_a     => sig_alu_mux1_result_ex,
               src_b     => sig_alu_src_b,
					io_data   => io_data,
					io_read   => sig_io_read_ex,
					alu		 => sig_alu_ex,
               result    => sig_alu_result_ex,
               carry_out => sig_alu_carry_out,
					zero 		 => sig_zero_ex );
	 -- end modification
	 
	 -- pipeline register ex/mem
	 pipe_reg_ex_mem : reg_EX_MEM
	 port map ( clk				 => clk,
					reset				 => reset,
					flush				 => sig_branch_sel,
					mem_to_reg_in 	 => sig_mem_to_reg_ex,
					reg_write_in 	 => sig_reg_write_ex,
					branch_in		 => sig_branch_ex,
					mem_write_in 	 => sig_mem_write_ex,
					zero_in			 => sig_zero_ex,
					alu_result_in	 => sig_alu_result_ex,
					read_data_b_in  => sig_alu_mux2_result_ex,
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
	 sig_branch_sel <= sig_zero_mem and sig_branch_mem;
	 
	 -- modification mem
    data_mem : data_memory 
    port map ( reset        => reset,
               clk          => clk,
               write_enable => sig_mem_write_mem,
               write_data   => sig_read_data_b_mem,
               addr_in      => sig_alu_result_mem(7 downto 0),			--modified for 8 bit
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
    
	 -- hazard detection unit for LUH: stall
	 hazard_unit : hazard_detection_unit
	 port map ( mem_read => sig_mem_to_reg_ex,
					id_reg_rs => sig_insn_id(15 downto 12),
					id_reg_rt => sig_insn_id(11 downto 8),
					ex_reg_rt => sig_write_reg_a_ex,
					pc_write => sig_pc_write,
					if_id_write => sig_if_id_write,
			      id_ex_ctrl_flush => sig_ctrl_flush );
					
	-- modifications for forwarding unit
	forward_unit: forwarding_unit
	port map (ex_mem_regWrite => sig_reg_write_mem,
				ex_mem_rd => sig_write_register_mem,
				id_ex_rs => sig_reg_rs_ex,
				id_ex_rt => sig_write_reg_a_ex,
				mem_wb_regWrite => sig_reg_write_wb,
				mem_wb_rd => sig_write_register_wb,
				alu_op_1_mux => sig_alu_mux1_sel_ex,
				alu_op_2_mux => sig_alu_mux2_sel_ex);
				
	alu_op1_mux: alu_op_1_mux
	port map (reg => sig_read_data_a_ex,
				 mem_forward => sig_alu_result_mem,
				 wb_forward => sig_write_data,
				 output => sig_alu_mux1_result_ex,
				 mux_controller => sig_alu_mux1_sel_ex);
		
	alu_op2_mux: alu_op_2_mux
	port map (reg => sig_read_data_b_ex,
				 mem_forward => sig_alu_result_mem,
				 wb_forward => sig_write_data,
				 output => sig_alu_mux2_result_ex,
				 mux_controller => sig_alu_mux2_sel_ex);

	branch_predictor: branch_prediction_unit
	port map ( insn_op_code => sig_insn_if(19 downto 16),
				  imm_in => sig_insn_if(7 downto 0),
				  next_addr_in => sig_next_instr,
				  imm_out => sig_branch_imm,
				  next_addr_out => sig_pred_instr );

end structural;
