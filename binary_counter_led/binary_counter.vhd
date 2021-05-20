library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--BINARY COUNTER DISPLAYED ON LEDS(7 TO 0) , FREQUENCY WILL DEPEND ON SWITCHES SW(1 TO 0)

entity counter is
	port
	(		
		MAX10_CLK1_50 : in std_logic;
		LED : out std_logic_vector(0 to 7);
		SW : in std_logic_vector(0 to 1)
	);
end counter;

architecture rtl of counter is
	signal cnt : unsigned(30 downto 0):= (others =>'0');
begin
	process (MAX10_CLK1_50) is
		begin	
			if rising_edge(MAX10_CLK1_50) then 
				
				if cnt(30 downto 23) = "11111111" then
					cnt <= (others => '0');
						
				else 
					cnt <= cnt + 1;
			end if;
			end if;
		end process;
	
	proc2: process(SW)
	begin
	case SW is
		  when "00" => LED <= not std_logic_vector(cnt(30 downto 23));
		  when "01" => LED <= not std_logic_vector(cnt(29 downto 22));
		  when "10" => LED <= not std_logic_vector(cnt(28 downto 21));
		  when "11" => LED <= not std_logic_vector(cnt(27 downto 20));
	end case;
	end process proc2;
end rtl;
