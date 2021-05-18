library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--main_counter WILL KEEP INCREASING DUTY CYCLE EVERY ms 
--pwm_proc will let pwm_cnt coount to max_count, and toggle output according to duty_count

entity DECA is
  
  port (
    i_clock      : in  std_logic;
    o_led  		  : out std_logic
    );
end DECA;
 
architecture rtl of DECA is
 
  constant max_count  	: natural := 25000;
  signal duty_count   	: natural range 0 to max_count := 0 ;
  signal main_cnt 	 	: natural range 0 to 100000;
  signal pwm_CNT    	 	: natural range 0 to max_count;
  signal led   		 	: std_logic := '1';
  signal downcount_flag : std_logic := '0';
 			
begin
  pwm_process : process (i_clock) is
  begin
    if rising_edge(i_clock) then
	 
		if pwm_CNT = max_count-1 then
			led <= '1';
			pwm_CNT <= 0;
			
		elsif pwm_CNT = duty_count then
         led <= '0';
			pwm_CNT <= pwm_CNT + 1;
						
      else
        pwm_CNT <= pwm_CNT + 1;
		
		end if;
		
     end if;
  end process pwm_process;
  
  main_counter : process (i_clock) is
  begin
		if rising_edge(i_clock) then
			
			if main_cnt = 100000-1 then
				main_cnt <= 0;
				
				if downcount_flag = '0' then
				duty_count <= duty_count + 25;
			
				else
				duty_count <= duty_count - 25;
				
				end if;
			else
				main_cnt <= main_cnt + 1;
				
			end if;
		
			if duty_count = 25000 then
				downcount_flag <= '1';
			elsif duty_count = 0 then
				downcount_flag <= '0';
						
			end if;
		
		
		end if;
		
  
  
  
  end process main_counter;
	 
  o_led <= led; 
end rtl;
