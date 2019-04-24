---------------------------------------------------------------------------
-- data_memory.vhd - Implementation of A Single-Port, 16 x 16-bit Data
--                   Memory.
-- 
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

entity data_memory is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           write_data   : in  std_logic_vector(15 downto 0);
           addr_in      : in  std_logic_vector(7 downto 0);     --modified for 8 bit
           data_out     : out std_logic_vector(15 downto 0) );
end data_memory;

architecture behavioral of data_memory is

type mem_array is array(0 to 255) of std_logic_vector(15 downto 0);
signal sig_data_mem : mem_array;

begin
    mem_process: process ( clk,
                           write_enable,
                           write_data,
                           addr_in ) is
  
    variable var_data_mem : mem_array;
    variable var_addr     : integer;
  
    begin
        var_addr := conv_integer(addr_in);
        
        if (reset = '1') then
            -- initial values of the data memory : reset to zero 
            
            var_data_mem(0)  := X"0000";
            var_data_mem(1)  := X"0001";
            var_data_mem(2)  := X"0002";
            var_data_mem(3)  := X"0003";    
            var_data_mem(4)  := X"0004";
            var_data_mem(5)  := X"0000";
            var_data_mem(6)  := X"0000";
            var_data_mem(7)  := X"0000";
            var_data_mem(8)  := X"0000";
            var_data_mem(9)  := X"0000";
            var_data_mem(10)  := X"0000";
            var_data_mem(11)  := X"0000";
            var_data_mem(12)  := X"0000";
            var_data_mem(13)  := X"0000";
            var_data_mem(14)  := X"0000";
            var_data_mem(15)  := X"A000";
            var_data_mem(16)  := X"0000";
            var_data_mem(17)  := X"0000";
            var_data_mem(18)  := X"0000";
            var_data_mem(19)  := X"0000";
            var_data_mem(20)  := X"0000";
            var_data_mem(21)  := X"0000";
            var_data_mem(22)  := X"0000";
            var_data_mem(23)  := X"0000";
            var_data_mem(24)  := X"0000";
            var_data_mem(25)  := X"0000";
            var_data_mem(26)  := X"0000";
            var_data_mem(27)  := X"0000";
            var_data_mem(28)  := X"0000";
            var_data_mem(29)  := X"0000";
            var_data_mem(30)  := X"B000";
            var_data_mem(31)  := X"0000";
            var_data_mem(32)  := X"0000";
            var_data_mem(33)  := X"0000";
            var_data_mem(34)  := X"0000";
            var_data_mem(35)  := X"0000";
            var_data_mem(36)  := X"0000";
            var_data_mem(37)  := X"0000";
            var_data_mem(38)  := X"0000";
            var_data_mem(39)  := X"0000";
            var_data_mem(40)  := X"0000";
            var_data_mem(41)  := X"0000";
            var_data_mem(42)  := X"0000";
            var_data_mem(43)  := X"0000";
            var_data_mem(44)  := X"0000";
            var_data_mem(45)  := X"0000";
            var_data_mem(46)  := X"0000";
            var_data_mem(47)  := X"0000";
            var_data_mem(48)  := X"0000";
            var_data_mem(49)  := X"0000";
            var_data_mem(50)  := X"0000";
            var_data_mem(51)  := X"0000";
            var_data_mem(52)  := X"0000";
            var_data_mem(53)  := X"0000";
            var_data_mem(54)  := X"0000";
            var_data_mem(55)  := X"0000";
            var_data_mem(56)  := X"0000";
            var_data_mem(57)  := X"0000";
            var_data_mem(58)  := X"0000";
            var_data_mem(59)  := X"0000";
            var_data_mem(60)  := X"0000";
            var_data_mem(61)  := X"0000";
            var_data_mem(62)  := X"0000";
            var_data_mem(63)  := X"0000";
            var_data_mem(64)  := X"0000";
            -- End pattern
            var_data_mem(65)  := X"0000";
            var_data_mem(66)  := X"0000";
            var_data_mem(67)  := X"0000";
            var_data_mem(68)  := X"0000";
            var_data_mem(69)  := X"0000";
            var_data_mem(70)  := X"0000";
            var_data_mem(71)  := X"0000";
            var_data_mem(72)  := X"0000";
            var_data_mem(73)  := X"0000";
            var_data_mem(74)  := X"0000";
            var_data_mem(75)  := X"0000";
            var_data_mem(76)  := X"0000";
            var_data_mem(77)  := X"0000";
            var_data_mem(78)  := X"0000";
            var_data_mem(79)  := X"0000";
            var_data_mem(80)  := X"0000";
            var_data_mem(81)  := X"0000";
            var_data_mem(82)  := X"0000";
            var_data_mem(83)  := X"0000";
            var_data_mem(84)  := X"0000";
            var_data_mem(85)  := X"0000";
            var_data_mem(86)  := X"0000";
            var_data_mem(87)  := X"0000";
            var_data_mem(88)  := X"0000";
            var_data_mem(89)  := X"0000";
            var_data_mem(90)  := X"0000";
            var_data_mem(91)  := X"0000";
            var_data_mem(92)  := X"0000";
            var_data_mem(93)  := X"0000";
            var_data_mem(94)  := X"0000";
            var_data_mem(95)  := X"0000";
            var_data_mem(96)  := X"0000";
            var_data_mem(97)  := X"0000";
            var_data_mem(98)  := X"0000";
            var_data_mem(99)  := X"0000";
            var_data_mem(100)  := X"0000";
            var_data_mem(101)  := X"0000";
            var_data_mem(102)  := X"0000";
            var_data_mem(103)  := X"0000";
            var_data_mem(104)  := X"0000";
            var_data_mem(105)  := X"0000";
            var_data_mem(106)  := X"0000";
            var_data_mem(107)  := X"0000";
            var_data_mem(108)  := X"0000";
            var_data_mem(109)  := X"0000";
            var_data_mem(110)  := X"0000";
            var_data_mem(111)  := X"0000";
            var_data_mem(112)  := X"0000";
            var_data_mem(113)  := X"0000";
            var_data_mem(114)  := X"0000";
            var_data_mem(115)  := X"0000";
            var_data_mem(116)  := X"0000";
            var_data_mem(117)  := X"0000";
            var_data_mem(118)  := X"0000";
            var_data_mem(119)  := X"0000";
            var_data_mem(120)  := X"0000";
            var_data_mem(121)  := X"0000";
            var_data_mem(122)  := X"0000";
            var_data_mem(123)  := X"0000";
            var_data_mem(124)  := X"0000";
            var_data_mem(125)  := X"D000";
            var_data_mem(126)  := X"0000";
            var_data_mem(127)  := X"0000";
            var_data_mem(128)  := X"0000";
            var_data_mem(129)  := X"0000";
            var_data_mem(130)  := X"0000";
            var_data_mem(131)  := X"0000";
            var_data_mem(132)  := X"0000";
            var_data_mem(133)  := X"0000";
            var_data_mem(134)  := X"0000";
            var_data_mem(135)  := X"0000";
            var_data_mem(136)  := X"0000";
            var_data_mem(137)  := X"0000";
            var_data_mem(138)  := X"0000";
            var_data_mem(139)  := X"0000";
            var_data_mem(140)  := X"0000";
            var_data_mem(141)  := X"0000";
            var_data_mem(142)  := X"0000";
            var_data_mem(143)  := X"0000";
            var_data_mem(144)  := X"0000";
            var_data_mem(145)  := X"0000";
            var_data_mem(146)  := X"0000";
            var_data_mem(147)  := X"0000";
            var_data_mem(148)  := X"0000";
            var_data_mem(149)  := X"0000";
            var_data_mem(150)  := X"0000";
            var_data_mem(151)  := X"0000";
            var_data_mem(152)  := X"0000";
            var_data_mem(153)  := X"0000";
            var_data_mem(154)  := X"0000";
            var_data_mem(155)  := X"0000";
            var_data_mem(156)  := X"0000";
            var_data_mem(157)  := X"0000";
            var_data_mem(158)  := X"0000";
            var_data_mem(159)  := X"0000";
            var_data_mem(160)  := X"0000";
            var_data_mem(161)  := X"0000";
            var_data_mem(162)  := X"0000";
            var_data_mem(163)  := X"0000";
            var_data_mem(164)  := X"0000";
            var_data_mem(165)  := X"0000";
            var_data_mem(166)  := X"0000";
            var_data_mem(167)  := X"0000";
            var_data_mem(168)  := X"0000";
            var_data_mem(169)  := X"0000";
            var_data_mem(170)  := X"0000";
            var_data_mem(171)  := X"0000";
            var_data_mem(172)  := X"0000";
            var_data_mem(173)  := X"0000";
            var_data_mem(174)  := X"0000";
            var_data_mem(175)  := X"0000";
            var_data_mem(176)  := X"0000";
            var_data_mem(177)  := X"0000";
            var_data_mem(178)  := X"0000";
            var_data_mem(179)  := X"0000";
            var_data_mem(180)  := X"0000";
            var_data_mem(181)  := X"0000";
            var_data_mem(182)  := X"0000";
            var_data_mem(183)  := X"0000";
            var_data_mem(184)  := X"0000";
            var_data_mem(185)  := X"0000";
            var_data_mem(186)  := X"0000";
            var_data_mem(187)  := X"0000";
            var_data_mem(188)  := X"0000";
            var_data_mem(189)  := X"0000";
            var_data_mem(190)  := X"0000";
            var_data_mem(191)  := X"0000";
            var_data_mem(192)  := X"0000";
            var_data_mem(193)  := X"0000";
            var_data_mem(194)  := X"0000";
            var_data_mem(195)  := X"0000";
            var_data_mem(196)  := X"0000";
            var_data_mem(197)  := X"0000";
            var_data_mem(198)  := X"0000";
            var_data_mem(199)  := X"0000";
            var_data_mem(200)  := X"0000";
            var_data_mem(201)  := X"0000";
            var_data_mem(202)  := X"0000";
            var_data_mem(203)  := X"0000";
            var_data_mem(204)  := X"0000";
            var_data_mem(205)  := X"0000";
            var_data_mem(206)  := X"0000";
            var_data_mem(207)  := X"0000";
            var_data_mem(208)  := X"0000";
            var_data_mem(209)  := X"0000";
            var_data_mem(210)  := X"0000";
            var_data_mem(211)  := X"0000";
            var_data_mem(212)  := X"0000";
            var_data_mem(213)  := X"0000";
            var_data_mem(214)  := X"0000";
            var_data_mem(215)  := X"0000";
            var_data_mem(216)  := X"0000";
            var_data_mem(217)  := X"0000";
            var_data_mem(218)  := X"0000";
            var_data_mem(219)  := X"0000";
            var_data_mem(220)  := X"0000";
            var_data_mem(221)  := X"0000";
            var_data_mem(222)  := X"0000";
            var_data_mem(223)  := X"0000";
            var_data_mem(224)  := X"0000";
            var_data_mem(225)  := X"0000";
            var_data_mem(226)  := X"0000";
            var_data_mem(227)  := X"0000";
            var_data_mem(228)  := X"0000";
            var_data_mem(229)  := X"0000";
            var_data_mem(230)  := X"0000";
            var_data_mem(231)  := X"0000";
            var_data_mem(232)  := X"0000";
            var_data_mem(233)  := X"0000";
            var_data_mem(234)  := X"0000";
            var_data_mem(235)  := X"0000";
            var_data_mem(236)  := X"0000";
            var_data_mem(237)  := X"0000";
            var_data_mem(238)  := X"0000";
            var_data_mem(239)  := X"0000";
            var_data_mem(240)  := X"0000";
            var_data_mem(241)  := X"0000";
            var_data_mem(242)  := X"0000";
            var_data_mem(243)  := X"0000";
            var_data_mem(244)  := X"0000";
            var_data_mem(245)  := X"0000";
            var_data_mem(246)  := X"0000";
            var_data_mem(247)  := X"0000";
            var_data_mem(248)  := X"0000";
            var_data_mem(249)  := X"0000";
            var_data_mem(250)  := X"0000";
            var_data_mem(251)  := X"0000";
            var_data_mem(252)  := X"0000";
            var_data_mem(253)  := X"0000";
            var_data_mem(254)  := X"0000";
            var_data_mem(255)  := X"0000";

        elsif (falling_edge(clk) and write_enable = '1') then
            -- memory writes on the falling clock edge
            var_data_mem(var_addr) := write_data;
        end if;
       
        -- continuous read of the memory location given by var_addr 
        data_out <= var_data_mem(var_addr);
 
        -- the following are probe signals (for simulation purpose) 
        sig_data_mem <= var_data_mem;

    end process;
  
end behavioral;
