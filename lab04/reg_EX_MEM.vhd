----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:26:50 03/27/2019 
-- Design Name: 
-- Module Name:    reg_ex_mem - Behavioral 
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

entity reg_EX_MEM is
	port ( clk, reset  		: in  std_logic;
			 mem_to_reg_in 	: in	std_logic;
			 reg_write_in 		: in  std_logic;
			 branch_in			: in  std_logic;
			 mem_write_in 		: in  std_logic;
			 zero_in				: in  std_logic;
			 alu_result_in    : in  std_logic_vector(15 downto 0);
			 read_data_b_in   : in  std_logic_vector(15 downto 0);
			 write_reg_in	: in  std_logic_vector(3 downto 0);
			 branch_addr_in	: in  std_logic_vector(3 downto 0);
			 
			 mem_to_reg_out 	: out	std_logic;
			 reg_write_out 	: out std_logic;
			 branch_out			: out std_logic;
			 mem_write_out 	: out std_logic;
			 zero_out			: out std_logic;
			 alu_result_out    : out  std_logic_vector(15 downto 0);
			 read_data_b_out  : out std_logic_vector(15 downto 0);
			 write_reg_out	: out std_logic_vector(3 downto 0);
			 branch_addr_out	: out  std_logic_vector(3 downto 0) );
end reg_EX_MEM;

architecture Behavioral of reg_EX_MEM is
begin

	update_process: process ( reset, clk ) is
	begin
		if (reset = '1') then
			mem_to_reg_out <= '0';
			reg_write_out <= '0';
			branch_out <= '0';
			mem_write_out <= '0';
			zero_out <= '0';
			alu_result_out <= (others => '0');
			read_data_b_out <= (others => '0');
			write_reg_out <= (others => '0');
		elsif (rising_edge(clk)) then
			mem_to_reg_out <= mem_to_reg_in;
			reg_write_out <= reg_write_in;
			branch_out <= branch_in;
			mem_write_out <= mem_write_in;
			zero_out <= zero_in;
			alu_result_out <= alu_result_in;
			read_data_b_out <= read_data_b_in;
			write_reg_out <= write_reg_in;
		end if;
	end process;
	
end Behavioral;
