library ieee;
use ieee.std_logic_1164.all;

-- detects pattern "110" entered via switch 1. switch 0 acts as clock signal

entity fsm_pattern is
	port
	(
		LED : out std_logic_vector(0 to 2);
		SW : in std_logic_vector(0 to 1)
	);

end fsm_pattern;

architecture rtl of fsm_pattern is
	type state_type is (s_idle , s_1 , s_2 , s_3);
	signal PS,NS : state_type;
	signal output : std_logic := '0';
	begin
	seq_proc: process (NS,SW(0))
		begin
			if rising_edge(SW(0)) then 
				PS <= NS;
			end if;
		end process seq_proc;
			  
	comb_proc: process(PS,SW(1))
	begin
		case PS is 
			when s_idle => 
				output <= '0';
				if SW(1) = '1' then 
					NS <= s_1;
				else NS <= s_idle;
				end if;
			when s_1 =>
				output <= '0';
				if SW(1) = '1' then 
					NS <= s_2;
				else NS <= s_idle;
				end if;
			when s_2 =>
				output <= '0';
				if SW(1) = '0' then 
					NS <= s_3;
				else NS <= s_2;
				end if;
			when s_3 =>
				output <= '1';
				if SW(1) = '1' then 
					NS <= s_1;
				else NS <= s_idle;
				end if;
		end case;		
	end process comb_proc;
	
	LED(0) <= not output;
	LED(1) <= not SW(1);
	LED(2) <= not SW(0);
	
end rtl;
