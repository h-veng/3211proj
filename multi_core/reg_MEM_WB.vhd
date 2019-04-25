----------------------------------------------------------------------------------
-- Company: UNSW
-- Engineer: Henry Veng(z5113239), Richie Trang(z5061606), Jack Scott(z5020638) for COMP3211
-- 
-- Create Date:    23:26:50 03/27/2019 
-- Design Name: 
-- Module Name:    reg_mem_wb - Behavioral 
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

entity reg_MEM_WB is
    port ( clk, reset       : in  std_logic;
           output_in        : in  std_logic;
           mem_to_reg_in    : in  std_logic;
           reg_write_in     : in  std_logic;
           mem_data_in      : in  std_logic_vector(15 downto 0);
           alu_result_in    : in  std_logic_vector(15 downto 0);
           write_reg_in     : in  std_logic_vector(3 downto 0);
             
           output_out       : out std_logic;
           mem_to_reg_out   : out std_logic;
           reg_write_out    : out std_logic;
           mem_data_out     : out std_logic_vector(15 downto 0);
           alu_result_out   : out std_logic_vector(15 downto 0);
           write_reg_out    : out std_logic_vector(3 downto 0) );
end reg_MEM_WB;

architecture Behavioral of reg_MEM_WB is
begin

    update_process: process ( reset, clk ) is
    begin
        if (reset = '1') then
            output_out <= '0';
            mem_to_reg_out <= '0';
            reg_write_out <= '0';
            mem_data_out <= (others => '0');
            alu_result_out <= (others => '0');
            write_reg_out <= (others => '0');
        elsif (rising_edge(clk)) then
            output_out <= output_in;
            mem_to_reg_out <= mem_to_reg_in;
            reg_write_out <= reg_write_in;
            mem_data_out <= mem_data_in;
            alu_result_out <= alu_result_in;
            write_reg_out <= write_reg_in;
        end if;
    end process;
    
end Behavioral;
