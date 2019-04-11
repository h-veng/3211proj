----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:44:44 04/10/2019 
-- Design Name: 
-- Module Name:    hazard_detection_unit - Behavioral 
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

entity hazard_detection_unit is
	port ( counter_signal_in : in std_logic;
			 mem_read : in std_logic; --mem_to_reg_ex
			 id_reg_rs : in std_logic_vector(3 downto 0);
			 id_reg_rt : in std_logic_vector(3 downto 0);
			 ex_reg_rt : in std_logic_vector(3 downto 0);
			 insn_op_code: in std_logic_vector(3 downto 0);
			 counter_signal_out : out std_logic;
			 pc_write : out std_logic;
			 if_id_write : out std_logic;
			 id_ex_ctrl_flush : out std_logic );
end hazard_detection_unit;

architecture Behavioral of hazard_detection_unit is

begin
	process ( mem_read, id_reg_rs, id_reg_rt, ex_reg_rt, insn_op_code, counter_signal_in ) is
	begin
		pc_write <= '1';
		if_id_write <= '1';
		id_ex_ctrl_flush <= '0';
		if ( mem_read = '1' ) then
			if ((id_reg_rs = ex_reg_rt) or (id_reg_rt = ex_reg_rt)) then
				pc_write <= '0';
				if_id_write <= '0';
				id_ex_ctrl_flush <= '1';
			end if;
		end if;
		if (insn_op_code = "0100") then
			counter_signal_out <= '1';
			if (counter_signal_in = '0') then
				pc_write <= '0';
				if_id_write <= '0';
				id_ex_ctrl_flush <= '1';
			end if;
		end if;
		if (counter_signal_in'event and counter_signal_in = '1') then
			counter_signal_out <= '0';
		end if;
	end process;

end Behavioral;

