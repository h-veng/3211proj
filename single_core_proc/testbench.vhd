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
          io_next : out std_logic );
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
    signal sig_io_next    : std_logic;
    signal sig_write_zero : std_logic;
    
    --file input
    signal sig_pattern       : std_logic_vector(7 downto 0);
    signal sig_stream        : std_logic_vector(7 downto 0) := x"FF";
    signal sig_end_stream    : std_logic_vector(7 downto 0) := x"00";
    signal sig_io_reg_input  : std_logic_vector(7 downto 0);
    signal sig_io_reg_output : std_logic_vector(7 downto 0);
    signal sig_curr_stream   : std_logic_vector(1 downto 0);
    
    file pattern : text;
    file stream  : text;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
   uut: pipelined_core PORT MAP (
          reset   => reset,
          clk     => clk,
          io_data => sig_io_reg_output,
          io_next => sig_io_next
        );
    
    io: io_reg PORT MAP (
           clk        => clk,
           reset      => reset,
           write_en   => sig_io_next,
           data_in    => sig_io_reg_input,
           data_out   => sig_io_reg_output,
           write_zero => sig_write_zero
         );
    
    -- IO stream selection process
    stream_switch : process (sig_write_zero, reset)
    begin
        if (reset = '1') then
            sig_curr_stream <= "00";
        elsif (sig_write_zero'event and sig_write_zero = '1') then
            if (sig_curr_stream = 0) then
                file_close(pattern);
                sig_curr_stream <= "01";
            elsif (sig_curr_stream = 1) then
                file_close(stream);
                sig_curr_stream <= "10";
            end if;
        end if;
    end process;
    sig_io_reg_input <= sig_pattern when sig_curr_stream = 0 else
                              sig_stream when sig_curr_stream = 1 else
                              sig_end_stream;
    
    -- file process
    file_update : process (reset, sig_io_next, clk)
        variable line_p: line;
        variable line_s: line;
        variable char_p: character;
        variable char_s: character;
    begin
        if rising_edge(reset) then
            -- open files
            file_open(pattern, "pattern.txt", read_mode);
            file_open(stream, "stream.txt", read_mode);
            -- read the first line
            readline(pattern, line_p);
            readline(stream, line_s);
            -- read the first character of pattern
            if (line_p'length > 0) then
                read(line_p, char_p);
                sig_pattern <= conv_std_logic_vector(character'pos(char_p), 8);
            else
                sig_pattern <= x"00";
            end if;
            -- read the first character of stream
            if (line_s'length > 0) then
                read(line_s, char_s);
                sig_stream <= conv_std_logic_vector(character'pos(char_s), 8);
            else
                sig_stream <= x"00";
            end if;
        elsif (rising_edge(clk) and sig_io_next = '1') then
            if (sig_curr_stream = 0) then
                if (line_p'length > 0) then
                    read(line_p, char_p);
                    sig_pattern <= conv_std_logic_vector(character'pos(char_p), 8);
                else
                    sig_pattern <= x"00";
                end if;
            elsif (sig_curr_stream = 1) then
                if (line_s'length > 0) then
                    read(line_s, char_s);
                    sig_stream <= conv_std_logic_vector(character'pos(char_s), 8);
                else
                    sig_stream <= x"00";
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
