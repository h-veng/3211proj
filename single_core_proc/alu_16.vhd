----------------------------------------------------------------------------------
-- Company: UNSW
-- Engineer: Henry Veng z5113239
-- 
-- Create Date:    23:53:39 03/20/2019 
-- Design Name: 
-- Module Name:    alu_16 - Mixed 
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

-- rudimentary single cycle processor alu for this reduced isa of lab3
-- 2 functions: comparison and addition
entity alu_16 is
	port ( src_a     : in  std_logic_vector(15 downto 0);
          src_b     : in  std_logic_vector(15 downto 0);
			 io_data   : in  std_logic_vector(7 downto 0);
			 io_read   : in  std_logic;
			 alu		  : in  std_logic;
          result    : out std_logic_vector(15 downto 0);
          carry_out : out std_logic;
			 zero		  : out std_logic );
end alu_16;

architecture Structural of alu_16 is
	component cmp16 is
		port ( src_a     : in  std_logic_vector(15 downto 0);
				 src_b     : in  std_logic_vector(15 downto 0);
				 axorb     : out std_logic_vector(15 downto 0);
				 zero      : out std_logic );
	end component;
	component adder_16b is
		 port ( src_a     : in  std_logic_vector(15 downto 0);
				  src_b     : in  std_logic_vector(15 downto 0);
				  sum       : out std_logic_vector(15 downto 0);
				  carry_out : out std_logic );
	end component;
	signal result_cmp, result_add : std_logic_vector(15 downto 0);
begin
	compare: cmp16 port map (src_a, src_b, result_cmp, zero);
	add: adder_16b port map (src_a, src_b, result_add, carry_out);
	result <= (x"00" & io_data) when io_read = '1' else
				 result_cmp when alu = '1' else
				 result_add;
end Structural;

