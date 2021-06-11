library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPI_MASTER_TB is		-- SPI mode 0, bit transmitted at rising clk edge , sampled at falling edge, sclk = 1 when idle
end entity SPI_MASTER_TB;

architecture tb of SPI_MASTER_TB is

signal tb_clock  		: std_logic := '0';
signal r_MOSI 	 		: std_logic;
signal r_MISO 	 		: std_logic;		
signal r_tx_done 		: std_logic;
signal r_tx_byte 	    : std_logic_vector(7 downto 0);
signal r_rx_byte	    : std_logic_vector(7 downto 0);
signal r_tx_start 	    : std_logic;
signal r_sclk 		    : std_logic;


  procedure SendSingleByte (
    data          : in  std_logic_vector(7 downto 0);
    signal o_data : out std_logic_vector(7 downto 0);
    signal o_dv   : out std_logic
	) is
  begin
    wait until rising_edge(tb_clock);
    o_data <= data;
    o_dv   <= '1';
    wait until rising_edge(tb_clock);
    o_dv   <= '0';
    wait until rising_edge(r_tx_done);	
	
  end procedure SendSingleByte;
  
  
begin 
	tb_clock <= not tb_clock after 10 ns;
	
	UUT : entity work.SPI_MASTER
	port map(
		i_reset => '1',
		i_clock => tb_clock,
		MISO	=> r_MOSI,
		MOSI	=> r_MOSI,
		i_tx_byte => r_tx_byte,
		o_rx_byte => r_rx_byte, 
		i_tx_start=> r_tx_start,
		o_tx_done => r_tx_done,
		sclk => r_sclk
		
	);


process is
  begin    
    SendSingleByte(X"A2", r_tx_byte, r_tx_start);
	report "Sent out 0xA2, Received 0x" & to_hstring(unsigned(r_rx_byte));
	--wait for 1000 ns;
	SendSingleByte(X"F2", r_tx_byte, r_tx_start);
	report "Sent out 0xF2, Received 0x" & to_hstring(unsigned(r_rx_byte));
	--wait for 1000 ns;
	SendSingleByte(X"22", r_tx_byte, r_tx_start);
	report "Sent out 0x22, Received 0x" & to_hstring(unsigned(r_rx_byte));
  end process;

end tb;