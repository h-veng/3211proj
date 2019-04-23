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
           addr_in      : in  std_logic_vector(3 downto 0);
           data_out     : out std_logic_vector(15 downto 0) );
end data_memory;

architecture behavioral of data_memory is

type mem_array is array(0 to 15) of std_logic_vector(15 downto 0);
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
            -- Initial data memory values for pattern test program
            var_data_mem(0)  := X"0001";
                --begin hardcoded pattern
            var_data_mem(1)  := X"0061";    --letter a
            var_data_mem(2)  := X"0062";    --letter b
            var_data_mem(3)  := X"0063";
                --end hardcoded pattern
            var_data_mem(4)  := X"0000";
            var_data_mem(5)  := X"0000";
            var_data_mem(6)  := X"0000";    --out of order, no match
            var_data_mem(7)  := X"0000";
            var_data_mem(8)  := X"0000";
            var_data_mem(9)  := X"0000";    --match
            var_data_mem(10) := X"0000";
            var_data_mem(11) := X"0000";
            var_data_mem(12) := X"0000";    --gap between the characters, no match
            var_data_mem(13) := X"0000";
            var_data_mem(14) := X"0000";
            var_data_mem(15) := X"0000";
				
				
                --begin hardcoded input stream
--            var_data_mem(4)  := X"0012";
--            var_data_mem(5)  := X"0023";
--            var_data_mem(6)  := X"0062";    --out of order, no match
--            var_data_mem(7)  := X"0061";
--            var_data_mem(8)  := X"0003";
--            var_data_mem(9)  := X"0061";    --match
--            var_data_mem(10) := X"0062";
--            var_data_mem(11) := X"0019";
--            var_data_mem(12) := X"0061";    --gap between the characters, no match
--            var_data_mem(13) := X"0004";
--            var_data_mem(14) := X"0062";
--            var_data_mem(15) := X"0000";
                --end hardcoded input stream



            -- initial values of the data memory for other test programs
--            var_data_mem(0)  := X"000A";
--            var_data_mem(1)  := X"0001";
--            var_data_mem(2)  := X"0002";
--            var_data_mem(3)  := X"0003";
--            var_data_mem(4)  := X"0004";
--            var_data_mem(5)  := X"0005";
--            var_data_mem(6)  := X"0006";
--            var_data_mem(7)  := X"0007";
--            var_data_mem(8)  := X"0008";
--            var_data_mem(9)  := X"0009";
--            var_data_mem(10) := X"0000";
--            var_data_mem(11) := X"0000";
--            var_data_mem(12) := X"0000";
--            var_data_mem(13) := X"0000";
--            var_data_mem(14) := X"0000";
--            var_data_mem(15) := X"0000";

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
