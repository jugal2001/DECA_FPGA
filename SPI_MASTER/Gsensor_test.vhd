library ieee;
use ieee.std_logic_1164.all;
library altera;
use altera.altera_syn_attributes.all;

entity SPI_DRIVER is
	port
	(
		MAX10_CLK1_50 : in std_logic;
		G_SENSOR_CS_n : out std_logic;
		G_SENSOR_SCLK : out std_logic;
		G_SENSOR_SDO : out std_logic;
		G_SENSOR_SDI : in std_logic;
		LED : out std_logic_vector(1 downto 0);
		SW : in std_logic_vector(0 to 1)
	);

end SPI_DRIVER;

architecture RTL of SPI_DRIVER is 
signal r_cs 	  : std_logic := '1';
signal tx_byte 	  : std_logic_vector(7 downto 0);
signal rx_byte 	  : std_logic_vector(7 downto 0);
--SIGNAL MAX10_CLK1_50 : std_logic := '1';
signal r_tx_start     : std_logic := '0';
signal r_tx_done	  : std_logic := '0';
signal r_rx_done	  : std_logic := '0';
type state_type is (IDLE , RUN , TX, RX, STOP );
signal state : state_type := IDLE;
signal r_LED : std_logic_vector(1 downto 0) := "11";
signal byte	 : std_logic_vector(15 downto 0) := "0010000001011111";
signal delay : natural range 0 to 20000000;

begin 

SPI_MASTER: entity work.SPI_MASTER 
	port map(
	i_tx_byte  => tx_byte,
	i_tx_start => r_tx_start,
	o_tx_done  => r_tx_done,
	o_rx_done  => r_rx_done,
	o_rx_byte  => rx_byte,
	i_reset    => SW(0),
	i_clock	   => MAX10_CLK1_50,
	
	MOSI => G_SENSOR_SDO,
	MISO => G_SENSOR_SDI,
	SCLK => G_SENSOR_SCLK
	);
	
spi_fsm: process (MAX10_CLK1_50)
	begin 
	--MAX10_CLK1_50 <= not MAX10_CLK1_50 after 10 ns;
		if rising_edge(MAX10_CLK1_50) then
			case state is
				when IDLE =>
					r_LED(1) <= '1';
					--if SW(1) = '1' then
						state <= RUN;
						tx_byte <= byte(15 downto 8);
						r_cs <= '0';
						r_tx_start <= '1';
					--else 
						--state <= IDLE;
					--end if;
					
				when RUN =>
					
					if r_rx_done = '1' then 
					state <= RX;
					r_tx_start <= '1';
					tx_byte <= byte(7 downto 0);
					else 
					state <= RUN;
					r_tx_start <= '0';
					end if;
				when RX =>
					r_tx_start <= '0';
					if r_rx_done = '1' then 
					state <= STOP;
					else 
					state <= RX;
					end if;
				when STOP => 
					r_cs <= '1';
					byte <= "1010100100000000";
					
					if rx_byte(7) = '0' then 
						r_LED(0) <= '0';
					else
						r_LED(0) <= '1';
					end if;
					r_LED(1) <= '1';
					
					if delay = 10000 then
						delay <= 0;
						state <= IDLE;
					else
						delay <= delay + 1;
						state <= STOP;
					end if;
					
					
				when others =>
				state <= idle;
			end case;	
			
		end if;

	end process spi_fsm;
G_SENSOR_CS_n <= r_cs;	
LED <= r_LED;
end RTL;
