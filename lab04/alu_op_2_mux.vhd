----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    05:36:29 04/10/2019 
-- Design Name: 
-- Module Name:    alu_op_1_mux - Behavioral 
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

entity alu_op_2_mux is
    Port ( reg : in  STD_LOGIC_VECTOR (15 downto 0);
			  mem_forward: in STD_LOGIC_VECTOR (15 downto 0);
			  wb_forward: in STD_LOGIC_VECTOR (15 downto 0);
			  output: out STD_LOGIC_VECTOR (15 downto 0);
			  mux_controller: in STD_LOGIC_VECTOR (1 downto 0));
end alu_op_2_mux;

architecture Behavioral of alu_op_2_mux is
begin

	output <= reg when mux_controller = "00" else
				mem_forward when mux_controller = "01" else
				wb_forward when mux_controller = "10" else
				"0000000000000000";

end Behavioral;

