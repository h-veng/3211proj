----------------------------------------------------------------------------------
-- Company: UNSW
-- Engineer: Henry Veng z5113239
-- 
-- Create Date:    23:56:26 03/20/2019 
-- Design Name: 
-- Module Name:    cmp16 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- 16 bit comparator
entity cmp16 is
	port ( src_a     : in  std_logic_vector(15 downto 0);
          src_b     : in  std_logic_vector(15 downto 0);
          axorb     : out std_logic_vector(15 downto 0);
          zero      : out std_logic );
end cmp16;

architecture Behavioral of cmp16 is
	signal sig_axorb : std_logic_vector(15 downto 0);
begin
	comparison: for i in 0 to 15 generate
		sig_axorb(i) <= src_a(i) xor src_b(i);
	end generate;
	
	axorb <= sig_axorb;
	
	zero <= not ( sig_axorb(0)
			  or sig_axorb(1)
			  or sig_axorb(2)
			  or sig_axorb(3)
			  or sig_axorb(4)
			  or sig_axorb(5)
			  or sig_axorb(6)
			  or sig_axorb(7)
			  or sig_axorb(8)
			  or sig_axorb(9)
			  or sig_axorb(10)
			  or sig_axorb(11)
			  or sig_axorb(12)
			  or sig_axorb(13)
			  or sig_axorb(14)
			  or sig_axorb(15) );
end Behavioral;

