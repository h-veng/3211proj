----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:37:40 04/10/2019 
-- Design Name: 
-- Module Name:    forwarding_unit - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity forwarding_unit is
    Port ( ex_mem_regWrite : in  STD_LOGIC;
			  ex_mem_rd			: in	STD_LOGIC_VECTOR(3 downto 0);
			  id_ex_rs			: in	STD_LOGIC_VECTOR(3 downto 0);
			  id_ex_rt			: in	STD_LOGIC_VECTOR(3 downto 0);
			  mem_wb_regWrite : in  STD_LOGIC;
			  mem_wb_rd			: in	STD_LOGIC_VECTOR(3 downto 0);
			  alu_op_1_mux		: out STD_LOGIC_vector(1 downto 0);
			  alu_op_2_mux			: out STD_LOGIC_VECTOR(1 downto 0));
end forwarding_unit;

architecture Behavioral of forwarding_unit is


begin

	
	process(ex_mem_regWrite, ex_mem_rd, mem_wb_regWrite, mem_wb_rd, id_ex_rs, id_ex_rt) IS
	BEGIN
		-- Data Forwarded from Mem Stage
		if (ex_mem_regWrite = '1') and (ex_mem_rd /= "0000") and(ex_mem_rd = id_ex_rs) then
			alu_op_1_mux <= "01";
		elsif (mem_wb_regWrite = '1') and (mem_wb_rd /= "0000") and(mem_wb_rd = id_ex_rs) then
			alu_op_1_mux <= "10";
		else
			alu_op_1_mux <= "00";
		end if;
		
		if (ex_mem_regWrite = '1') and (ex_mem_rd /= "0000") and(ex_mem_rd = id_ex_rt) then
			alu_op_2_mux <= "01";
		elsif (mem_wb_regWrite = '1') and (mem_wb_rd /= "0000") and(mem_wb_rd = id_ex_rt) then
			alu_op_2_mux <= "10";
		else
			alu_op_2_mux <= "00";
		end if;
		
	end process;

end Behavioral;

