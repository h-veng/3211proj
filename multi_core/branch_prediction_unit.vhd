----------------------------------------------------------------------------------
-- Company: UNSW
-- Engineer: Henry Veng(z5113239), Richie Trang(z5061606), Jack Scott(z5020638)
-- 
-- Create Date:    14:23:47 04/21/2019 
-- Design Name: 
-- Module Name:    branch_prediction_unit - Behavioral 
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

entity branch_prediction_unit is
    port ( insn_op_code  : in  std_logic_vector(3 downto 0);
           imm_in        : in  std_logic_vector(7 downto 0);
           next_addr_in  : in  std_logic_vector(7 downto 0);
           imm_out       : out std_logic_vector(7 downto 0);
           next_addr_out : out std_logic_vector(7 downto 0) );
end branch_prediction_unit;

architecture Behavioral of branch_prediction_unit is

    constant OP_BNE   : std_logic_vector(3 downto 0) := "0100";

begin

    imm_out <= next_addr_in when (insn_op_code = OP_BNE) else
               imm_in;

    next_addr_out <= imm_in when (insn_op_code = OP_BNE) else
                     next_addr_in;

end Behavioral;

