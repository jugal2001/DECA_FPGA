library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_chaser is
	port
	(
		MAX10_CLK1_50 : in std_logic;
		LED : out std_logic_vector(7 downto 0);
		SW : in std_logic_vector(1 downto 0)
	);

end led_chaser;

architecture ppl_type of led_chaser is
  
constant c_1hz : natural := 50000000;
constant c_2hz : natural := 25000000;
constant c_5hz : natural := 10000000;
constant c_10hz: natural := 5000000;
signal countvalue : natural := c_1hz;
signal counter : natural range 0 to 50000000;
signal a : std_logic_vector (7 downto 0) := "00000001";

begin
speed_proc : process(SW)
	begin 
		case SW is
		  when "00" => countvalue <= c_1hz;
		  when "01" => countvalue <= c_2hz;
		  when "10" => countvalue <= c_5hz;
		  when "11" => countvalue <= c_10hz;
		end case;
	end process speed_proc;
	
led_proc : process(MAX10_CLK1_50,  countvalue)
		begin
		
		if rising_edge(MAX10_CLK1_50) then 
			
			if counter = countvalue-1 then 
				counter <= 0;
				a(7 downto 0) <= a(6 downto 0) & a(7); 
			else 
			counter <= counter + 1;
			end if;
			
		end if; 
		
		end process led_proc;	
		LED <= not a;
end;
