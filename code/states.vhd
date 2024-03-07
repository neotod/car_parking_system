library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.types.all;
use work.utils.all;

package states is
  procedure idle_state(
    variable wait_password_state_counter : out integer range 0 to 4;
    variable entered_password            : out password_t;
    signal green_led                   : inout std_logic;
    signal red_led                    : inout std_logic;
    signal gate_out                       : out std_logic;
    signal front_sensor                 : in std_logic;
    variable cur_state                   : out states_t
  );

  procedure wait_password_state(
    signal password_in                 : in integer range 0 to 9;
    
    variable wait_password_state_counter : inout integer range 0 to 4;
    variable entered_password            : inout password_t;
    
    variable cur_state                   : out states_t
  );

  procedure right_password_state(
    signal front_sensor                : in std_logic;
    signal back_sensor                 : in std_logic;
    
    signal green_led                   : inout std_logic;
    signal red_led                    : inout std_logic;
    signal gate_out                    : out std_logic;
    variable cur_state                   : out states_t
  );
  
  procedure wrong_password_state(
    variable entered_password             : inout password_t;
    signal green_led                   : inout std_logic;
    signal red_led                    : inout std_logic;
    signal password_in                    : in integer range 0 to 9;
    signal gate_out                       : out std_logic;

    variable cur_state                    : inout states_t
  );

  procedure stop_state(
    variable entered_password            : inout password_t;
    variable cur_state                   : inout states_t;
    signal green_led                   : inout std_logic;
    signal red_led                    : inout std_logic;
    signal password_in                 : in integer range 0 to 9
  );
end package;

package body states is
  procedure idle_state(
    variable wait_password_state_counter : out integer range 0 to 4;
    variable entered_password            : out password_t;
    signal green_led                   : inout std_logic;
    signal red_led                    : inout std_logic;
    signal gate_out                       : out std_logic;
    signal front_sensor                 : in std_logic;
    variable cur_state                   : out states_t
  ) is
  begin
    if (front_sensor'event and front_sensor = '1') then
      cur_state := WAIT_PASSWORD;
    end if;
  
    wait_password_state_counter := 0;
    entered_password := (others => 0);
    
    green_led <= '0';
    red_led <= '0';
    gate_out <= '0';
  end idle_state;

  procedure wait_password_state(
    signal password_in                 : in integer range 0 to 9;
    
    variable  wait_password_state_counter : inout integer range 0 to 4;
    variable entered_password            : inout password_t;
    
    variable cur_state                   : out states_t
  ) is
  begin
    if (wait_password_state_counter < WAIT_PASSWORD_STATE_MAX_COUNTER) then
      entered_password(wait_password_state_counter) := password_in;
      wait_password_state_counter := wait_password_state_counter + 1;

    else
      -- verify password
      if (verify_password(CORRECT_PASSWORD, entered_password)) then -- ? is this kind of condtiion gonna work?
        
        cur_state := RIGHT_PASS;
      else
        cur_state := WRONG_PASS;
      end if;
    end if;
  end wait_password_state;

  procedure right_password_state(
    signal front_sensor                : in std_logic;
    signal back_sensor                 : in std_logic;
    
    signal green_led                   : inout std_logic;
    signal red_led                    : inout std_logic;
    signal gate_out                    : out std_logic;
    variable cur_state                   : out states_t
  ) is
  begin
    gate_out <= '1';

    green_led <= not green_led;
    red_led <= '0';

    if (back_sensor = '1') then
      if (front_sensor = '1') then
        cur_state := STOP;
      else
        cur_state := IDLE;
      end if;
    else
      cur_state := RIGHT_PASS; -- don't change the state
    end if;
  end right_password_state;

  procedure wrong_password_state(
    variable entered_password             : inout password_t;
    signal green_led                   : inout std_logic;
    signal red_led                    : inout std_logic;
    signal password_in                    : in integer range 0 to 9;
    signal gate_out                       : out std_logic;

    variable cur_state                    : inout states_t
  ) is
  begin
    gate_out <= '0';

    green_led <= '0';
    red_led <= not red_led; -- red led blinking

    entered_password := password_left_shift_insert(entered_password, password_in);

    -- verify password
    if (verify_password(CORRECT_PASSWORD, entered_password)) then
      cur_state := RIGHT_PASS;
    else
      cur_state := WRONG_PASS;
    end if;
  end wrong_password_state;

  procedure stop_state(
    variable entered_password            : inout password_t;
    variable cur_state                   : inout states_t;
    signal green_led                   : inout std_logic;
    signal red_led                    : inout std_logic;
    signal password_in                 : in integer range 0 to 9
  ) is
  begin
    green_led <= '0';
    red_led <= not red_led; -- red led blinking

    entered_password := password_left_shift_insert(entered_password, password_in);
  
    -- verify password
    if (verify_password(CORRECT_PASSWORD, entered_password)) then
      cur_state := RIGHT_PASS;
    else
      cur_state := STOP;
    end if;
  end stop_state;

end states;