----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:31:53 04/24/2019 
-- Design Name: 
-- Module Name:    io_reg - Behavioral 
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

entity io_reg is
	port ( clk, reset : in std_logic;
			 write_en : in std_logic;
			 data_in : in std_logic_vector(7 downto 0);
			 data_out : out std_logic_vector(7 downto 0);
			 write_zero : out std_logic );
end io_reg;

architecture Behavioral of io_reg is

begin

	update: process (clk, reset) is
	begin
		write_zero <= '0';
		if (reset = '1') then
			data_out <= (others => '0');
		elsif (rising_edge(clk) and (write_en = '1')) then
			data_out <= data_in;
			if data_in = 0 then
				write_zero <= '1';
			end if;
		end if;
	end process;

end Behavioral;

