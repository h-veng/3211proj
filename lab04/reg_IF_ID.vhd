----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:12:20 03/27/2019 
-- Design Name: 
-- Module Name:    reg_IF-ID - Behavioral 
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

entity reg_IF_ID is
	port ( clk, reset : in  std_logic;
			 instr_in   : in  std_logic_vector (15 downto 0);
			 instr_out  : out std_logic_vector (15 downto 0) );
end reg_IF_ID;

architecture Behavioral of reg_IF_ID is
begin
	
	update_process: process ( reset, clk ) is
	begin
		if (reset = '1') then
			instr_out <= (others => '0'); 
		elsif (rising_edge(clk)) then
			instr_out <= instr_in; 
		end if;
	end process;

end Behavioral;

