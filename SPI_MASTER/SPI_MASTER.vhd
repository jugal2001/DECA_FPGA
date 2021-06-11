library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPI_MASTER is		-- SPI mode 0, bit transmitted at falling clk edge , sampled at rising edge, sclk = 1 when idle
	
	port
	(
		i_reset   : in std_logic;
		i_clock   : in std_logic;
		i_tx_byte : in std_logic_vector(7 downto 0);	
		i_tx_start: in std_logic;
		MISO	  : in std_logic;
		
		o_tx_done : out std_logic;
		o_rx_done : out std_logic;
		o_rx_byte : out std_logic_vector(7 downto 0) := (others => '0');	
		MOSI	  : out std_logic;
		SCLK	  : out std_logic
	);
end SPI_MASTER;

architecture RTL of SPI_MASTER is

constant clks_per_bit : natural   := 50;		--1mhz
signal r_sclk         : std_logic := '1';
signal r_clk_counter  : natural range 0 to clks_per_bit;
signal rx_bit_count   : natural range 0 to 8 := 8;
signal tx_bit_count   : natural range 0 to 8 := 8;
signal r_tx_byte 	  : std_logic_vector(7 downto 0);
signal r_tx_start     : std_logic := '0';
signal old_edge 	  : std_logic := '1';
signal new_edge		  : std_logic := '1';
signal r_sclk_edges   : natural range 0 to 8;
signal r_tx_done	  : std_logic := '0';
signal r_rx_done	  : std_logic := '0';

begin
	clock_gen: process(i_reset, i_clock)
	begin
		if i_reset = '0' then 
			r_sclk <= '1';
			r_clk_counter <= 0;
			r_tx_done <= '0';
		elsif rising_edge(i_clock) then	
				if i_tx_start = '1' then
					r_clk_counter <= 0;
					r_sclk_edges <= 0;
					r_tx_byte <= i_tx_byte;
					r_tx_done <= '0';
				elsif r_sclk_edges < 8 then
					if r_clk_counter = clks_per_bit/2 - 1 then 
						r_sclk <= not r_sclk;
						new_edge <= '0';
						r_clk_counter <= r_clk_counter + 1;
						
					elsif r_clk_counter = clks_per_bit - 1 then  
						r_clk_counter <= 0;
						new_edge <= '1';
						r_sclk <= not r_sclk;
						r_sclk_edges <= r_sclk_edges + 1;			
					else 
						r_clk_counter <= r_clk_counter + 1;
						old_edge <= new_edge;
					end if;	
				else
					old_edge <= '1';
					r_tx_done <= '1';					
				end if;
		end if;
	end process clock_gen;
	
	MOSI_process : process (i_clock, i_reset)
	begin 
		if i_reset = '0' then 
			MOSI <= '0';
		elsif rising_edge(i_clock) then 
				--r_tx_done <= '0';
				if old_edge = '1' and new_edge = '0' then  
					MOSI <= r_tx_byte(tx_bit_count-1);
					tx_bit_count <= tx_bit_count - 1;
					if rx_bit_count = 1 then 					
						tx_bit_count <= 8;
					end if;		
				end if;	
					
		end if;
	
	
	end process MOSI_process;
	
	
	MISO_process : process (i_clock, i_reset)
	begin 
		if i_reset = '0' then 
			r_rx_done <= '0';
			rx_bit_count <= 8;
		elsif rising_edge(i_clock) then 
			r_rx_done <= '0';
				if old_edge = '0' and new_edge = '1' then 
					o_rx_byte(rx_bit_count-1) <= MISO;
					rx_bit_count <= rx_bit_count - 1;
					
					if rx_bit_count = 1 then 
						r_rx_done <= '1';
						rx_bit_count <= 8;
					else 
						r_rx_done <= '0';
					end if;	
				end if;	
		end if;
	end process MISO_process;
	
	SCLK <= r_sclk;
	o_tx_done <= r_tx_done;
	o_rx_done <= r_rx_done;
	
end RTL;