---------------------------------------------------------------------------
-- instruction_memory.vhd - Implementation of A Single-Port, 16 x 16-bit
--                          Instruction Memory.
-- 
-- Notes: refer to headers in single_cycle_core.vhd for the supported ISA.
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
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
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(3 downto 0);
           insn_out : out std_logic_vector(15 downto 0) );
end instruction_memory;

architecture behavioral of instruction_memory is

type mem_array is array(0 to 15) of std_logic_vector(15 downto 0);
signal sig_insn_mem : mem_array;

begin
    mem_process: process ( clk,
                           addr_in ) is
  
    variable var_insn_mem : mem_array;
    variable var_addr     : integer;
  
    begin
        if (reset = '1') then
          
            
--     noop      
--        # no operation or to signal end of program
--        # format:  | opcode = 0 |  0   |  0   |  0  |  0  |
--
--     load  rt, rs, offset     
--        # load data at memory location (rs + offset) into rt
--        # format:  | opcode = 1 |  rs  |  rt  | offset high | offset low |
--
--     store rt, rs, offset
--        # store data rt into memory location (rs + offset)
--        # format:  | opcode = 3 |  rs  |  rt  | offset high | offset low |
--
--     add   rd, rs, rt
--        # rd <- rs + rt
--        # format:  | opcode = 8 |  rs  |  rt  |   rd   |  0  |
--		
--		 bne   rt, rs, addr
--        # pc <- addr when rt != rs
--        # format:  | opcode = 4 |  rs  |  rt  |  addr high  |  addr low |


            -- Pattern test program

            -- Registers used
                -- $1 = 1
                -- $2 = IO stream (pattern or input stream)
                -- $3 = pattern counter
                -- $4 = offset
                -- $5 = pattern_char
                -- $6 = result

            -- Data memory setup
                -- data(0) :1 as default
                -- data(1-3) :these 3 words used to store the pattern, will be 64 words when we expand

			var_insn_mem(0)  := X"10100";    --put 1 in $1 (load $1 with constant 1 from data memory)
            var_insn_mem(1)  := X"80020";    --put 0 into $2 (add $0 and $0 and store result in $2)
            var_insn_mem(2)  := X"80030";    --put 0 into $3 (add $0 and $0 and store result in $3)
            --var_insn_mem(3)  := X"0000";    --do an IO read
            var_insn_mem(3)  := X"13201";	-- this is a faux IO read (load datamem at location $3 + offset 1 into register $2)     //remove when IOread is added

            --loop 1: Get the pattern from stream
            -- var_insn_mem(4)  := X"33201";    --store the value from $2 in data mem (store val of $2 at mem location $3 offset by 1) 
            var_insn_mem(4)  := X"33205";    --store the value from $2 in data mem (store val of $2 at mem location $3 offset by 5)         //remove when IOread is added 
            var_insn_mem(5)  := X"81330";    --increment pattern counter (add register $0 and $1 and store in $3)
            --var_insn_mem(6)  := X"0000";    --do an IO read
            var_insn_mem(6)  := X"13201";	-- this is a faux IO read (load datamem at location $3 + offset 1 into register $2)         //remove when IOread is added
            var_insn_mem(7)  := X"42004";    --if input is not EOF character then loop (bne $2, $0, loop 1)
            
            var_insn_mem(8)  := X"80040";    --put 0 into $4 (add $0 and $0 and store result in $4)
            var_insn_mem(9)  := X"80060";    --put 0 into $6 (add $0 and $0 and store result in $6)
            --var_insn_mem(10) := X"0000";  --do an IO read
            var_insn_mem(10) := X"13201";    --this is a faux IO read (load datamem at location $3 + offset 1 into register $2)         //remove when IOread is added
            var_insn_mem(11) := X"4200D";    --if input stream is not empty then jump to loop 2 (bne $2, $0, loop2)
            var_insn_mem(12) := X"40117";    --if was empty then jump to exit. (bne $0, $1, exit)                                               

            --loop 2
            var_insn_mem(13) := X"14501";    --load next pattern value (ld $5, $4[1])
            var_insn_mem(14) := X"42511";    --if the input does not match pattern then jump to else (bne $2, $5, else)
            var_insn_mem(15) := X"81440";    --if it is a match then increment offset (add $4, $4, $1)
            var_insn_mem(16)  := X"40112";   --if we are here then it was a match, jump to check (bne $0, $1, check)
            
            --else: The case of non-matching pattern
            var_insn_mem(17)  := X"80040";   --zero the offset (add $4, $0, $0	) 
            
            --check: Where we see if the whole pattern was matched
            var_insn_mem(18)  := X"44315";   --if offset is not equal to pattern length then jump to next_char (bne $4, $3, next_char)
            var_insn_mem(19)  := X"81660";   --if it IS equal then increment result counter (add $6, $6, $1)
            var_insn_mem(20)  := X"80040";   --zero the offset register (add $4, $0, $0)

            --next_char: Ready for next char in stream
            var_insn_mem(21)  := X"00000";    --do an IOread
            var_insn_mem(22)  := X"4200D";    --if new input is not null then jump to loop2 (bne $2, $0, loop2)
            
            
            --exit: Situation where next input is null i.e. stream finished

            var_insn_mem(23)  := X"00000";
            var_insn_mem(24)  := X"00000";
            var_insn_mem(25)  := X"00000";
            var_insn_mem(26)  := X"00000";
            var_insn_mem(27)  := X"00000";
            var_insn_mem(28)  := X"00000";
            var_insn_mem(29)  := X"00000";
            var_insn_mem(30)  := X"00000";
            var_insn_mem(31)  := X"00000";
            var_insn_mem(32)  := X"00000";
            var_insn_mem(33)  := X"00000";
            var_insn_mem(34)  := X"00000";
            var_insn_mem(35)  := X"00000";
            var_insn_mem(36)  := X"00000";
            var_insn_mem(37)  := X"00000";
            var_insn_mem(38)  := X"00000";
            var_insn_mem(39)  := X"00000";
            var_insn_mem(40)  := X"00000";
            var_insn_mem(41)  := X"00000";
            var_insn_mem(42)  := X"00000";
            var_insn_mem(43)  := X"00000";
            var_insn_mem(44)  := X"00000";
            var_insn_mem(45)  := X"00000";
            var_insn_mem(46)  := X"00000";
            var_insn_mem(47)  := X"00000";
            var_insn_mem(48)  := X"00000";
            var_insn_mem(49)  := X"00000";
            var_insn_mem(50)  := X"00000";
            var_insn_mem(51)  := X"00000";
            var_insn_mem(52)  := X"00000";
            var_insn_mem(53)  := X"00000";
            var_insn_mem(54)  := X"00000";
            var_insn_mem(55)  := X"00000";
            var_insn_mem(56)  := X"00000";
            var_insn_mem(57)  := X"00000";
            var_insn_mem(58)  := X"00000";
            var_insn_mem(59)  := X"00000";
            var_insn_mem(60)  := X"00000";
            var_insn_mem(61)  := X"00000";
            var_insn_mem(62)  := X"00000";
            var_insn_mem(63)  := X"00000";

		  
		  
		  
            -- bne test program
				--	 insn_0 : load  $3, $0, 0   - load data 0($0) into $3
            --  insn_1 : load  $2, $0, 1   - load data 1($0) into $2
				--  insn_2 : add   $1, $1, $2  - $1 <- $1 + $2
				--  insn_3 : bne   $1, $3, 2   - if $1 != $3, jump to 2
				--  insn_4 : store $1, $0, 2   - store data $1 into 2($0)
				--  insn_5 - insn_15: noop		 - end
				
			--var_insn_mem(0)  := X"1030";
            --var_insn_mem(1)  := X"1021";
            --var_insn_mem(2)  := X"8121";
            --var_insn_mem(3)  := X"4312";
            --var_insn_mem(4)  := X"3012";
            --var_insn_mem(5)  := X"0000";
            --var_insn_mem(6)  := X"0000";
            --var_insn_mem(7)  := X"0000";
            --var_insn_mem(8)  := X"0000";
            --var_insn_mem(9)  := X"0000";
            --var_insn_mem(10) := X"0000";
            --var_insn_mem(11) := X"0000";
            --var_insn_mem(12) := X"0000";
            --var_insn_mem(13) := X"0000";
            --var_insn_mem(14) := X"0000";
            --var_insn_mem(15) := X"0000";
				
				-- initial values of the instruction memory :
            --  insn_0 : load  $1, $0, 0   - load data 0($0) into $1
            --  insn_1 : load  $2, $0, 1   - load data 1($0) into $2
            --  insn_2 : add   $3, $0, $1  - $3 <- $0 + $1
            --  insn_3 : add   $4, $1, $2  - $4 <- $1 + $2
            --  insn_4 : store $3, $0, 2   - store data $3 into 2($0)
            --  insn_5 : store $4, $0, 3   - store data $4 into 3($0)
            --  insn_6 - insn_15 : noop    - end of program
				
		


--            var_insn_mem(0)  := X"1010";
--            var_insn_mem(1)  := X"8013";
--            var_insn_mem(2)  := X"1032";
--            var_insn_mem(3)  := X"1043";
--            var_insn_mem(4)  := X"1054";
--            var_insn_mem(5)  := X"1065";
--            var_insn_mem(6)  := X"8013";
--            var_insn_mem(7)  := X"8124";
--            var_insn_mem(8)  := X"0000";

--	add $2, $5, $3
	--add $4, $2, $3
	--add $3, $2, $4
	
--            var_insn_mem(0)  := X"1011";
--            var_insn_mem(1)  := X"1022";
--            var_insn_mem(2)  := X"1033";
--            var_insn_mem(3)  := X"1044";
--            var_insn_mem(4)  := X"1055";
--            var_insn_mem(5)  := X"8352";
--            --var_insn_mem(6)  := X"8234";
--            --var_insn_mem(7)  := X"8243";
--				var_insn_mem(8)  := X"0000";
--            var_insn_mem(9)  := X"0000";
--            var_insn_mem(10) := X"0000";
--            var_insn_mem(11) := X"0000";
--            var_insn_mem(12) := X"0000";
--            var_insn_mem(13) := X"0000";
--            var_insn_mem(14) := X"0000";
--            var_insn_mem(15) := X"0000";
--				
--				var_insn_mem(6)  := X"8232"; -- add $2, $2, $3
--            var_insn_mem(7)  := X"8223"; -- add $4, $3, $2 to test multiple dependency

        else
            -- read instructions on the rising clock edge
            var_addr := conv_integer(addr_in);
            insn_out <= var_insn_mem(var_addr);
        end if;

        -- the following are probe signals (for simulation purpose)
        sig_insn_mem <= var_insn_mem;

    end process;
  
end behavioral;
