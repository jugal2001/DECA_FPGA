library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library altera;
use altera.altera_syn_attributes.all;

entity UART_RX is
	port
	(
		LED 			: out std_logic_vector(7 downto 0);
		GPIO0_D 		: in std_logic;
		MAX10_CLK1_50   : in std_logic

	);
end UART_RX;

architecture RTL of UART_RX is


constant clks_per_bit : natural   := 434;		--100K BAUD
type state_type is (idle, start, data, stop);
signal state 		: state_type := idle;
signal r_counter 	: natural range 0 to clks_per_bit-1;
signal i_bit_index  : natural range 0 to 8;
signal r_rx_buf 	: std_logic_vector(7 downto 0) := (others => '0');
signal r_rx_byte 	: std_logic_vector(7 downto 0) := (others => '1');

signal r_sync_ff   : std_logic := '0';
signal r_RX_Data   : std_logic := '0';

begin

CDC_SYNC : process(MAX10_CLK1_50)
begin
	if rising_edge(MAX10_CLK1_50) then 
		r_sync_ff <= GPIO0_D;
		r_RX_Data <= r_sync_ff;
	end if;
end process CDC_SYNC;

RX_STATE_MACHINE : process(MAX10_CLK1_50)
begin
	if rising_edge(MAX10_CLK1_50) then 
		case state is 
			when idle =>
				r_counter <= 0;
				i_bit_index <= 0;
				
				if r_RX_Data = '0' then
					state <= start;
				else 
					state <= idle;
				end if;
				
			when start =>
				if r_counter = (clks_per_bit/2)-1 then 
					if r_RX_Data = '0' then 
						state <= data;
						r_counter <= 0;
					else 
						state <= idle;						
					end if;
				else 
					r_counter <= r_counter + 1;
					state <= start;
				end if;
				
			when data =>
				if r_counter = clks_per_bit - 1 then 
					r_rx_buf(i_bit_index) <= r_RX_Data;
					r_counter <= 0;
					if i_bit_index = 7 then 
						i_bit_index <= 0;
						state <= stop;
					else
						i_bit_index <= i_bit_index + 1;
						state <= data;
					end if;	
				else
					r_counter <= r_counter + 1;
					state <= data;
				end if;
				
			when stop =>
				if r_counter = clks_per_bit-1 then 
					if r_RX_Data = '1' then 
						r_rx_byte <= r_rx_buf;
						state <= idle;
					else 
						r_rx_byte <= (others =>'1');
						state <= idle;
					end if;	
				else 
					r_counter <= r_counter + 1;
					state <= stop;
				end if;
			when others =>
				state <= idle;
		end case;
	end if;
end process;

LED <= not r_rx_byte;

end RTL;
