--------------------------------------------------------------------------------
-- Company: UNSW
-- Engineers: Henry Veng(z5113239), Richie Trang (z5061606), Jack Scott(z5020638)
--
-- Create Date:   13:53:12 03/28/2019
-- Design Name:   
-- Module Name:   Z:/cs3211/lab04/pipelined_core/testbench.vhd
-- Project Name:  pipelined_core
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: pipelined_core
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;
USE ieee.std_logic_arith.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testbench IS
END testbench;
 
ARCHITECTURE behavior OF testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pipelined_core
    PORT( reset   : IN  std_logic;
          clk     : IN  std_logic;
          io_data : IN  std_logic_vector(7 downto 0);
          io_next : out std_logic;
          output  : out std_logic_vector(15 downto 0)); --think of it as a print
    END COMPONENT;

    COMPONENT io_reg
    PORT( clk, reset : in  std_logic;
          write_en   : in  std_logic;
          data_in    : in  std_logic_vector(7 downto 0);
          data_out   : out std_logic_vector(7 downto 0);
          write_zero : out std_logic );
    END COMPONENT;

   --Inputs
   signal reset : std_logic := '0';
   signal clk   : std_logic := '0';

   -- Clock period definitions
   constant clk_period : time := 10 ns;
    
    --io_reg signals
    signal sig_io_next_1    : std_logic;
    signal sig_write_zero_1 : std_logic;
    signal sig_io_next_2    : std_logic;
    signal sig_write_zero_2 : std_logic;
    
    --file input
    signal sig_pattern_1      : std_logic_vector(7 downto 0);
    signal sig_pattern_2      : std_logic_vector(7 downto 0);
    signal sig_stream_1       : std_logic_vector(7 downto 0);
    signal sig_stream_2       : std_logic_vector(7 downto 0);
    signal sig_end_stream     : std_logic_vector(7 downto 0) := x"00";
    signal sig_io_reg_input_1 : std_logic_vector(7 downto 0);
    signal sig_io_reg_output_1: std_logic_vector(7 downto 0);
    signal sig_io_reg_input_2 : std_logic_vector(7 downto 0);
    signal sig_io_reg_output_2: std_logic_vector(7 downto 0);
    signal sig_curr_stream_1  : std_logic_vector(1 downto 0);
    signal sig_curr_stream_2  : std_logic_vector(1 downto 0);
    
    file pattern_1 : text;
    file pattern_2 : text;
    file stream_1  : text;
    file stream_2  : text;
 
    --output signals
    signal sig_out_1 : std_logic_vector(15 downto 0);
    signal sig_out_2 : std_logic_vector(15 downto 0);
    signal sig_out_g : std_logic_vector(15 downto 0);
BEGIN
    sig_out_g <= sig_out_1 + sig_out_2;
    
    core_1: pipelined_core PORT MAP (
          reset   => reset,
          clk     => clk,
          io_data => sig_io_reg_output_1,
          io_next => sig_io_next_1,
          output  => sig_out_1
        );
    
    core_2: pipelined_core PORT MAP (
          reset   => reset,
          clk     => clk,
          io_data => sig_io_reg_output_2,
          io_next => sig_io_next_2,
          output  => sig_out_2
        );
    
    io_1: io_reg PORT MAP (
           clk        => clk,
           reset      => reset,
           write_en   => sig_io_next_1,
           data_in    => sig_io_reg_input_1,
           data_out   => sig_io_reg_output_1,
           write_zero => sig_write_zero_1
         );
    
    io_2: io_reg PORT MAP (
           clk        => clk,
           reset      => reset,
           write_en   => sig_io_next_2,
           data_in    => sig_io_reg_input_2,
           data_out   => sig_io_reg_output_2,
           write_zero => sig_write_zero_2
         );

    -- IO stream selection process
    stream_switch1 : process (sig_write_zero_1, reset)
    begin
        if (reset = '1') then
            sig_curr_stream_1 <= "00";
        else
            if (sig_write_zero_1'event and sig_write_zero_1 = '1') then
                if (sig_curr_stream_1 = 0) then
                    file_close(pattern_1);
                    sig_curr_stream_1 <= "01";
                elsif (sig_curr_stream_1 = 1) then
                    file_close(stream_1);
                    sig_curr_stream_1 <= "10";
                end if;
            end if;
        end if;
    end process;
    stream_switch2 : process (sig_write_zero_2, reset)
    begin
        if (reset = '1') then
            sig_curr_stream_2 <= "00";
        else
            if (sig_write_zero_2'event and sig_write_zero_2 = '1') then
                if (sig_curr_stream_2 = 0) then
                    file_close(pattern_2);
                    sig_curr_stream_2 <= "01";
                elsif (sig_curr_stream_2 = 1) then
                    file_close(stream_2);
                    sig_curr_stream_2 <= "10";
                end if;
            end if;
        end if;
    end process;
    sig_io_reg_input_1 <= sig_pattern_1 when sig_curr_stream_1 = 0 else
                              sig_stream_1 when sig_curr_stream_1 = 1 else
                              sig_end_stream;
    sig_io_reg_input_2 <= sig_pattern_2 when sig_curr_stream_2 = 0 else
                              sig_stream_2 when sig_curr_stream_2 = 1 else
                              sig_end_stream;
    
    -- file process
    file_update1 : process (reset, sig_io_next_1, clk)
        variable line_p1: line;
        variable line_s1: line;
        variable char_p1: character;
        variable char_s1: character;
    begin
        if rising_edge(reset) then
            -- open files
            file_open(pattern_1, "pattern.txt", read_mode);
            file_open(stream_1, "stream1.txt", read_mode);
            -- read the first line
            readline(pattern_1, line_p1);
            readline(stream_1, line_s1);
            -- read the first character of pattern
            if (line_p1'length > 0) then
                read(line_p1, char_p1);
                sig_pattern_1 <= conv_std_logic_vector(character'pos(char_p1), 8);
            else
                sig_pattern_1 <= x"00";
            end if;
            -- read the first character of stream
            if (line_s1'length > 0) then
                read(line_s1, char_s1);
                sig_stream_1 <= conv_std_logic_vector(character'pos(char_s1), 8);
            else
                sig_stream_1 <= x"00";
            end if;
        elsif (rising_edge(clk)) then
            if (sig_io_next_1 = '1') then
                if (sig_curr_stream_1 = 0) then
                    if (line_p1'length > 0) then
                        read(line_p1, char_p1);
                        sig_pattern_1 <= conv_std_logic_vector(character'pos(char_p1), 8);
                    else
                        sig_pattern_1 <= x"00";
                    end if;
                elsif (sig_curr_stream_1 = 1) then
                    if (line_s1'length > 0) then
                        read(line_s1, char_s1);
                        sig_stream_1 <= conv_std_logic_vector(character'pos(char_s1), 8);
                    else
                        sig_stream_1 <= x"00";
                    end if;
                end if;
            end if;
        end if;
    end process;
    file_update2 : process (reset, sig_io_next_2, clk)
        variable line_p2: line;
        variable line_s2: line;
        variable char_p2: character;
        variable char_s2: character;
    begin
        if rising_edge(reset) then
            -- open files
            file_open(pattern_2, "pattern.txt", read_mode);
            file_open(stream_2, "stream2.txt", read_mode);
            -- read the first line
            readline(pattern_2, line_p2);
            readline(stream_2, line_s2);
            -- read the first character of pattern
            if (line_p2'length > 0) then
                read(line_p2, char_p2);
                sig_pattern_2 <= conv_std_logic_vector(character'pos(char_p2), 8);
            else
                sig_pattern_2 <= x"00";
            end if;
            -- read the first character of stream
            if (line_s2'length > 0) then
                read(line_s2, char_s2);
                sig_stream_2 <= conv_std_logic_vector(character'pos(char_s2), 8);
            else
                sig_stream_2 <= x"00";
            end if;
        elsif (rising_edge(clk)) then
            if (sig_io_next_2 = '1') then
                if (sig_curr_stream_2 = 0) then
                    if (line_p2'length > 0) then
                        read(line_p2, char_p2);
                        sig_pattern_2 <= conv_std_logic_vector(character'pos(char_p2), 8);
                    else
                        sig_pattern_2 <= x"00";
                    end if;
                elsif (sig_curr_stream_2 = 1) then
                    if (line_s2'length > 0) then
                        read(line_s2, char_s2);
                        sig_stream_2 <= conv_std_logic_vector(character'pos(char_s2), 8);
                    else
                        sig_stream_2 <= x"00";
                    end if;
                end if;
            end if;
        end if;
    end process;

   -- Clock process definitions
   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin        
      -- hold reset state for 100 ns.
      wait for 100 ns;    
        reset <= '1';
        wait for 10 ns;
        reset <= '0';
      wait for clk_period*10000;

   end process;

END;
