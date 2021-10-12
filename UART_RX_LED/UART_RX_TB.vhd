library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library altera;
use altera.altera_syn_attributes.all;

entity UART_RX_TB is
end entity UART_RX_TB;


architecture tb of UART_RX_TB is 
signal tb_clock  		: std_logic := '0';
signal tx_line			: std_logic := '1';
constant c_BIT_PERIOD : time := 10000 ns;

procedure UART_WRITE_BYTE (
    tx_data       	: in  std_logic_vector(7 downto 0);
    signal o_serial : out std_logic) is
  begin
 
    -- Send Start Bit
    o_serial <= '0';
    wait for c_BIT_PERIOD;
 
    -- Send Data Byte
    for ii in 0 to 7 loop
      o_serial <= tx_data(ii);
      wait for c_BIT_PERIOD;
    end loop;  -- ii
 
    -- Send Stop Bit
    o_serial <= '1';
    wait for c_BIT_PERIOD;
  end UART_WRITE_BYTE;

begin 
	tb_clock <= not tb_clock after 10 ns;
	
	UUT : entity work.UART_RX
	port map(
	GPIO0_D => tx_line,
	MAX10_CLK1_50 => tb_clock
	);
	
	
process is
	begin
		wait for 50000 ns;
		wait until rising_edge(tb_clock);
		UART_WRITE_BYTE(X"05", tx_line);
		report "SENT 0x05";
		UART_WRITE_BYTE(X"50", tx_line);
		report "SENT 0x50";
		wait for 50000 ns;
	end process;

end tb;
