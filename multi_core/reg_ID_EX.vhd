----------------------------------------------------------------------------------
-- Company: UNSW
-- Engineer: Henry Veng(z5113239), Richie Trang(z5061606), Jack Scott(z5020638) for COMP3211
-- 
-- Create Date:    23:26:50 03/27/2019 
-- Design Name: 
-- Module Name:    reg_id_ex - Behavioral 
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

entity reg_ID_EX is
    port ( clk, reset         : in  std_logic;
           flush              : in  std_logic;
           mem_to_reg_in      : in  std_logic;
           reg_write_in       : in  std_logic;
           branch_in          : in  std_logic;
           mem_write_in       : in  std_logic;
           io_read_in         : in  std_logic;
           output_in          : in  std_logic;
           alu_in             : in  std_logic;
           alu_src_in         : in  std_logic;
           reg_dst_in         : in  std_logic;
           read_data_a_in     : in  std_logic_vector(15 downto 0);
           read_data_b_in     : in  std_logic_vector(15 downto 0);
           imm_in             : in  std_logic_vector(15 downto 0);
           reg_rs_in          : in  std_logic_vector(3 downto 0);
           write_reg_a_in     : in  std_logic_vector(3 downto 0); --if/id Rt
           write_reg_b_in     : in  std_logic_vector(3 downto 0);
           branch_addr_in     : in  std_logic_vector(7 downto 0);
             
           mem_to_reg_out     : out std_logic;
           reg_write_out      : out std_logic;
           branch_out         : out std_logic;
           mem_write_out      : out std_logic;
           io_read_out        : out std_logic;
           output_out         : out std_logic;
           alu_out            : out std_logic;
           alu_src_out        : out std_logic;
           reg_dst_out        : out std_logic;
           read_data_a_out    : out std_logic_vector(15 downto 0);
           read_data_b_out    : out std_logic_vector(15 downto 0);
           imm_out            : out std_logic_vector(15 downto 0);
           reg_rs_out         : out std_logic_vector(3 downto 0);
           write_reg_a_out    : out std_logic_vector(3 downto 0);
           write_reg_b_out    : out std_logic_vector(3 downto 0);
           branch_addr_out    : out std_logic_vector(7 downto 0) );
end reg_ID_EX;

architecture Behavioral of reg_ID_EX is
begin

    update_process: process ( reset, clk ) is
    begin
        if ((reset = '1') or (rising_edge(clk) and flush = '1')) then
            mem_to_reg_out <= '0';
            reg_write_out <= '0';
            branch_out <= '0';
            mem_write_out <= '0';
            io_read_out <= '0';
            output_out <= '0';
            alu_out <= '0';
            alu_src_out <= '0';
            reg_dst_out <= '0';
            read_data_a_out <= (others => '0');
            read_data_b_out <= (others => '0');
            imm_out <= (others => '0');
            reg_rs_out <= (others => '0');
            write_reg_a_out <= (others => '0');
            write_reg_b_out <= (others => '0');
            branch_addr_out <= (others => '0');
        elsif (rising_edge(clk)) then
            mem_to_reg_out <= mem_to_reg_in;
            reg_write_out <= reg_write_in;
            branch_out <= branch_in;
            mem_write_out <= mem_write_in;
            io_read_out <= io_read_in;
            output_out <= output_in;
            alu_out <= alu_in;
            alu_src_out <= alu_src_in;
            reg_dst_out <= reg_dst_in;
            read_data_a_out <= read_data_a_in;
            read_data_b_out <= read_data_b_in;
            imm_out <= imm_in;
            reg_rs_out <= reg_rs_in;
            write_reg_a_out <= write_reg_a_in;
            write_reg_b_out <= write_reg_b_in;
            branch_addr_out <= branch_addr_in;
        end if;
    end process;
    
end Behavioral;

