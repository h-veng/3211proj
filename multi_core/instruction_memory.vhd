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
-- Modifications by Henry Veng(z5113239), Richie Trang(z5061606), Jack Scott(z5020638) for COMP3211
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(7 downto 0);
           insn_out : out std_logic_vector(19 downto 0) );
end instruction_memory;

architecture behavioral of instruction_memory is

type mem_array is array(0 to 255) of std_logic_vector(255 downto 0);
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
--         bne   rt, rs, addr
--        # pc <- addr when rt != rs
--        # format:  | opcode = 4 |  rs  |  rt  |  addr high  |  addr low |
--
--     iord  rt
--        # rt <- io_data
--        # format:  | opcode = 2 |  0   |  rt  | 0 | 0 |


            -- Pattern test program

            -- Registers used
                -- $1 = 1
                -- $2 = IO stream (pattern or input stream)
                -- $3 = pattern counter
                -- $4 = offset
                -- $5 = pattern_char
                -- $6 = result
                -- 0x40 = start of pattern
                -- 0x80 = start of prefix table
                -- $7 = j in prefix table initialisation
                -- $8 = pattern[j]
                -- $9 = 0xffff = -1


            var_insn_mem(0)  := X"10100"; --ld $1, addr(1)
            var_insn_mem(1)  := X"10901"; --ld $9, addr(-1)
            var_insn_mem(2)  := X"80020"; --add $2, $0, $0
            var_insn_mem(3)  := X"80030"; --add $3, $0, $0
            var_insn_mem(4)  := X"20200"; --iord $2
            
            --loop1
            var_insn_mem(5)  := X"33240"; --store $2, $3[0x40]
            var_insn_mem(6)  := X"81330"; --add $3, $3, $1
            var_insn_mem(7)  := X"20200"; --iord $2
            var_insn_mem(8)  := X"42005"; --bne $2, $0, loop
            
            var_insn_mem(9)  := X"80040"; --add $4, $0, $0
            var_insn_mem(10) := X"34080"; --store $0, $4[0x80]
            var_insn_mem(11) := X"84140"; --add $4, $4, $1
            var_insn_mem(12) := X"80070"; --add $7, $0, $0
            var_insn_mem(13) := X"4011D"; --bne $0, $1, loop_p_check
            
            --loop_p_table
            var_insn_mem(14) := X"40116"; --bne $0, $1, special_check
                --loop_special
            var_insn_mem(15) := X"87970"; --add $7, $7, $9
            var_insn_mem(16) := X"17780"; --ld $7, $7[0x80]
            var_insn_mem(17) := X"40116"; --bne $0, $1, special_check
                    --special_check_2
            var_insn_mem(18) := X"14540"; --ld $5, $4[0x40]
            var_insn_mem(19) := X"17840"; --ld $8, $7[0x40]
            var_insn_mem(20) := X"4580F"; --bne $5, $8, loop_special
            var_insn_mem(21) := X"40117"; --bne $0, $1, equal_check
                    --special_check
            var_insn_mem(22) := X"47012"; --bne $7, $0, special_check_2
                --equal_check
            var_insn_mem(23) := X"14540"; --ld $5, $4[0x40]
            var_insn_mem(24) := X"17840"; --ld $8, $7[0x40]
            var_insn_mem(25) := X"4581B"; --bne $5, $8, common
            var_insn_mem(26) := X"87170"; --add $7, $7, $1
                --common
            var_insn_mem(27) := X"34780"; --store $7, $4[80]
            var_insn_mem(28) := X"84140"; --add $4, $4, $1
                --loop_p_check
            var_insn_mem(29) := X"4430E"; --bne $4, $3, loop_p_table
            
            
            var_insn_mem(30) := X"80040"; --add $4, $0, $0
            var_insn_mem(31) := X"80060"; --add $6, $0, $0
            var_insn_mem(32) := X"20200"; --iord $2
            var_insn_mem(33) := X"42023"; --bne $2, $0, loop2
            var_insn_mem(34) := X"4013C"; --bne $0, $1, exit
            
            --loop2
            var_insn_mem(35) := X"14540"; --ld $5, $4[0x40]
            var_insn_mem(36) := X"42527"; --bne $2, $5, else
            var_insn_mem(37) := X"84140"; --add $4, $4, $1
            var_insn_mem(38) := X"40133"; --bne $0, $1, check
                --else
            var_insn_mem(39) := X"4012E"; --bne $0, $1, special2_check
                    --loop2_special
            var_insn_mem(40) := X"84940"; --add $4, $4, $9
            var_insn_mem(41) := X"14480"; --ld $4, $4[0x80]
            var_insn_mem(42) := X"4012E"; --bne $0, $1, special2_check
                        --special2_check_2
            var_insn_mem(43) := X"14540"; --ld $5, $4[0x40]
            var_insn_mem(44) := X"45228"; --bne $5, $2, loop2_special
            var_insn_mem(45) := X"4012F"; --bne $0, $1, equal_check_2
                        --special2_check
            var_insn_mem(46) := X"4402B"; --bne $4, $0, special2_check_2
                    --equal_check_2
            var_insn_mem(47) := X"14540"; --ld $5, $4[0x40]
            var_insn_mem(48) := X"45237"; --bne $5, $2, next_char
            var_insn_mem(49) := X"84140"; --add $4, $4, $1
            var_insn_mem(50) := X"40137"; --bne $0, $1, next_char
                --check
            var_insn_mem(51) := X"44337"; --bne $4, $3, next_char
            var_insn_mem(52) := X"86160"; --add $6, $6, $1
            var_insn_mem(53) := X"66000"; --out $6
            var_insn_mem(54) := X"80040"; --add $4, $0, $0
                --next_char
            var_insn_mem(55) := X"00000"; --noop
            var_insn_mem(56) := X"00000"; --noop
            var_insn_mem(57) := X"00000"; --noop
            var_insn_mem(58) := X"20200"; --iord $2
            var_insn_mem(59) := X"42023"; --bne $2, $0, loop2
            
            --exit
            var_insn_mem(60) := X"00000";
            var_insn_mem(61) := X"00000";
            var_insn_mem(62) := X"00000";
            var_insn_mem(63) := X"00000";
            var_insn_mem(64) := X"00000";
            var_insn_mem(65) := X"00000";
            var_insn_mem(66) := X"00000";
            var_insn_mem(67) := X"00000";
            var_insn_mem(68) := X"00000";
            var_insn_mem(69) := X"00000";                
            var_insn_mem(70) := X"00000";      
            var_insn_mem(71) := X"00000"; 
            var_insn_mem(72) := X"00000";       
            var_insn_mem(73) := X"00000";
            var_insn_mem(74) := X"00000";
            var_insn_mem(75) := X"00000";
            var_insn_mem(76) := X"00000";
            var_insn_mem(77) := X"00000";
            var_insn_mem(78) := X"00000";
            var_insn_mem(79) := X"00000";
            var_insn_mem(80) := X"00000";      
            var_insn_mem(81) := X"00000"; 
            var_insn_mem(82) := X"00000";       
            var_insn_mem(83) := X"00000";
            var_insn_mem(84) := X"00000";
            var_insn_mem(85) := X"00000";
            var_insn_mem(86) := X"00000";
            var_insn_mem(87) := X"00000";
            var_insn_mem(88) := X"00000";
            var_insn_mem(89) := X"00000";
            var_insn_mem(90) := X"00000";      
            var_insn_mem(91) := X"00000"; 
            var_insn_mem(92) := X"00000";       
            var_insn_mem(93) := X"00000";
            var_insn_mem(94) := X"00000";
            var_insn_mem(95) := X"00000";
            var_insn_mem(96) := X"00000";
            var_insn_mem(97) := X"00000";
            var_insn_mem(98) := X"00000";
            var_insn_mem(99) := X"00000";                
            var_insn_mem(100)  := X"00000";      
            var_insn_mem(100)  := X"00000";      
            var_insn_mem(101)  := X"00000"; 
            var_insn_mem(102)  := X"00000";       
            var_insn_mem(103)  := X"00000";
            var_insn_mem(104)  := X"00000";
            var_insn_mem(105)  := X"00000";
            var_insn_mem(106)  := X"00000";
            var_insn_mem(107)  := X"00000";
            var_insn_mem(108)  := X"00000";
            var_insn_mem(109)  := X"00000"; 
            var_insn_mem(110)  := X"00000";      
            var_insn_mem(111)  := X"00000"; 
            var_insn_mem(112)  := X"00000";       
            var_insn_mem(113)  := X"00000";
            var_insn_mem(114)  := X"00000";
            var_insn_mem(115)  := X"00000";
            var_insn_mem(116)  := X"00000";
            var_insn_mem(117)  := X"00000";
            var_insn_mem(118)  := X"00000";
            var_insn_mem(119)  := X"00000";
            var_insn_mem(120)  := X"00000";      
            var_insn_mem(121)  := X"00000"; 
            var_insn_mem(122)  := X"00000";       
            var_insn_mem(123)  := X"00000";
            var_insn_mem(124)  := X"00000";
            var_insn_mem(125)  := X"00000";
            var_insn_mem(126)  := X"00000";
            var_insn_mem(127)  := X"00000";
            var_insn_mem(128)  := X"00000";
            var_insn_mem(129)  := X"00000";
            var_insn_mem(130)  := X"00000";      
            var_insn_mem(131)  := X"00000"; 
            var_insn_mem(132)  := X"00000";       
            var_insn_mem(133)  := X"00000";
            var_insn_mem(134)  := X"00000";
            var_insn_mem(135)  := X"00000";
            var_insn_mem(136)  := X"00000";
            var_insn_mem(137)  := X"00000";
            var_insn_mem(138)  := X"00000";
            var_insn_mem(139)  := X"00000";
            var_insn_mem(140)  := X"00000";      
            var_insn_mem(141)  := X"00000"; 
            var_insn_mem(142)  := X"00000";       
            var_insn_mem(143)  := X"00000";
            var_insn_mem(144)  := X"00000";
            var_insn_mem(145)  := X"00000";
            var_insn_mem(146)  := X"00000";
            var_insn_mem(147)  := X"00000";
            var_insn_mem(148)  := X"00000";
            var_insn_mem(149)  := X"00000";
            var_insn_mem(150)  := X"00000";      
            var_insn_mem(151)  := X"00000"; 
            var_insn_mem(152)  := X"00000";       
            var_insn_mem(153)  := X"00000";
            var_insn_mem(154)  := X"00000";
            var_insn_mem(155)  := X"00000";
            var_insn_mem(156)  := X"00000";
            var_insn_mem(157)  := X"00000";
            var_insn_mem(158)  := X"00000";
            var_insn_mem(159)  := X"00000";                
            var_insn_mem(160)  := X"00000";      
            var_insn_mem(161)  := X"00000"; 
            var_insn_mem(162)  := X"00000";       
            var_insn_mem(163)  := X"00000";
            var_insn_mem(164)  := X"00000";
            var_insn_mem(165)  := X"00000";
            var_insn_mem(166)  := X"00000";
            var_insn_mem(167)  := X"00000";
            var_insn_mem(168)  := X"00000";
            var_insn_mem(169)  := X"00000";                
            var_insn_mem(170)  := X"00000";      
            var_insn_mem(171)  := X"00000"; 
            var_insn_mem(172)  := X"00000";       
            var_insn_mem(173)  := X"00000";
            var_insn_mem(174)  := X"00000";
            var_insn_mem(175)  := X"00000";
            var_insn_mem(176)  := X"00000";
            var_insn_mem(177)  := X"00000";
            var_insn_mem(178)  := X"00000";
            var_insn_mem(179)  := X"00000";
            var_insn_mem(180)  := X"00000";      
            var_insn_mem(181)  := X"00000"; 
            var_insn_mem(182)  := X"00000";       
            var_insn_mem(183)  := X"00000";
            var_insn_mem(184)  := X"00000";
            var_insn_mem(185)  := X"00000";
            var_insn_mem(186)  := X"00000";
            var_insn_mem(187)  := X"00000";
            var_insn_mem(188)  := X"00000";
            var_insn_mem(189)  := X"00000";
            var_insn_mem(190)  := X"00000";      
            var_insn_mem(191)  := X"00000"; 
            var_insn_mem(192)  := X"00000";       
            var_insn_mem(193)  := X"00000";
            var_insn_mem(194)  := X"00000";
            var_insn_mem(195)  := X"00000";
            var_insn_mem(196)  := X"00000";
            var_insn_mem(197)  := X"00000";
            var_insn_mem(198)  := X"00000";
            var_insn_mem(199)  := X"00000";                
            var_insn_mem(200)  := X"00000";   
            var_insn_mem(201)  := X"00000"; 
            var_insn_mem(202)  := X"00000";       
            var_insn_mem(203)  := X"00000";
            var_insn_mem(204)  := X"00000";
            var_insn_mem(205)  := X"00000";
            var_insn_mem(206)  := X"00000";
            var_insn_mem(207)  := X"00000";
            var_insn_mem(208)  := X"00000";
            var_insn_mem(209)  := X"00000"; 
            var_insn_mem(210)  := X"00000";      
            var_insn_mem(211)  := X"00000"; 
            var_insn_mem(212)  := X"00000";       
            var_insn_mem(213)  := X"00000";
            var_insn_mem(214)  := X"00000";
            var_insn_mem(215)  := X"00000";
            var_insn_mem(216)  := X"00000";
            var_insn_mem(217)  := X"00000";
            var_insn_mem(218)  := X"00000";
            var_insn_mem(219)  := X"00000";
            var_insn_mem(220)  := X"00000";      
            var_insn_mem(221)  := X"00000"; 
            var_insn_mem(222)  := X"00000";       
            var_insn_mem(223)  := X"00000";
            var_insn_mem(224)  := X"00000";
            var_insn_mem(225)  := X"00000";
            var_insn_mem(226)  := X"00000";
            var_insn_mem(227)  := X"00000";
            var_insn_mem(228)  := X"00000";
            var_insn_mem(229)  := X"00000";
            var_insn_mem(230)  := X"00000";      
            var_insn_mem(231)  := X"00000"; 
            var_insn_mem(232)  := X"00000";       
            var_insn_mem(233)  := X"00000";
            var_insn_mem(234)  := X"00000";
            var_insn_mem(235)  := X"00000";
            var_insn_mem(236)  := X"00000";
            var_insn_mem(237)  := X"00000";
            var_insn_mem(238)  := X"00000";
            var_insn_mem(239)  := X"00000";
            var_insn_mem(240)  := X"00000";      
            var_insn_mem(241)  := X"00000"; 
            var_insn_mem(242)  := X"00000";       
            var_insn_mem(243)  := X"00000";
            var_insn_mem(244)  := X"00000";
            var_insn_mem(245)  := X"00000";
            var_insn_mem(246)  := X"00000";
            var_insn_mem(247)  := X"00000";
            var_insn_mem(248)  := X"00000";
            var_insn_mem(249)  := X"00000";
            var_insn_mem(250)  := X"00000";      
            var_insn_mem(251)  := X"00000"; 
            var_insn_mem(252)  := X"00000";       
            var_insn_mem(253)  := X"00000";
            var_insn_mem(254)  := X"00000";
            var_insn_mem(255)  := X"00000";                

        else
            -- read instructions on the rising clock edge
            var_addr := conv_integer(addr_in);
            insn_out <= var_insn_mem(var_addr);
        end if;

        -- the following are probe signals (for simulation purpose)
        sig_insn_mem <= var_insn_mem;

    end process;
  
end behavioral;
