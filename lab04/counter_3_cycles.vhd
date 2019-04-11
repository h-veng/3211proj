----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:34:01 04/11/2019 
-- Design Name: 
-- Module Name:    counter_3_cycles - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter_3_cycles is
	port ( clk : in std_logic;
			 reset : in std_logic;
			 start : in std_logic;
			 finished : out std_logic );
end counter_3_cycles;

architecture Behavioral of counter_3_cycles is

signal counter : std_logic_vector(1 downto 0);

begin

	process (clk, reset, start) is
	begin
		if reset = '1' then
			counter <= "00";
			finished <= '1';
		elsif start'event and start = '1' then
			counter <= "11";
			finished <= '0';
		elsif rising_edge(clk) then
			if counter > "00" then
				counter <= counter - "01";
				finished <= '0';
			else
				finished <= '1';
			end if;
		end if;
	end process;

end Behavioral;

