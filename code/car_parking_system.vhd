----------------------------------------------------------------------------------
-- student: Hossein (neotod) soltani
-- student number: 98242080
-- 
-- Project Name: Car Parking System
-- File: car parking system main
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.types.all;
use work.states.all;


entity car_parking_system is
  port (
    front_sensor : in std_logic;
    back_sensor : in std_logic;

    green_led : inout std_logic;
    red_led : inout std_logic;

    password_in : in integer range 0 to 9; -- can be BCD numbers
    gate_out : out std_logic; -- gate_out = '0' => gate_close , gate_out = '1' => gate_open
    
    clk : in std_logic;
    rst : in std_logic
    
  );
end car_parking_system;

architecture behav of car_parking_system is
  shared variable cur_state : states_t := IDLE;
  signal prev_state : states_t := IDLE;

begin
  process (clk, rst)
  begin
    if (rst'event and rst = '0') then
      prev_state <= IDLE;
    elsif (rising_edge(clk)) then
      prev_state <= cur_state;
    end if;
  end process;

  main_proc: process (prev_state, green_led, red_led, password_in, front_sensor, back_sensor)
    variable wait_password_state_counter : integer range 0 to 4 := 0;
    variable entered_password : password_t := (others => 0);
    
  begin
      case prev_state is
        when IDLE => 
          idle_state(wait_password_state_counter, entered_password, green_led, red_led, gate_out, front_sensor, cur_state);
    
        when WAIT_PASSWORD => 
          wait_password_state(password_in, wait_password_state_counter, entered_password, cur_state);
    
        when RIGHT_PASS =>
          right_password_state(front_sensor, back_sensor, green_led, red_led, gate_out, cur_state);
    
        when WRONG_PASS => 
          wrong_password_state(entered_password, green_led, red_led, password_in, gate_out, cur_state);
    
        when STOP =>
          stop_state(entered_password, cur_state, green_led, red_led, password_in);
    
       end case;
  end process;
end behav;
