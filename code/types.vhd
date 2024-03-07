----------------------------------------------------------------------------------
-- File: types
----------------------------------------------------------------------------------

package types is
  type password_t is array (0 to 3) of integer range 0 to 9; -- this will store the entered password/PIN
  type states_t is (
    IDLE, WAIT_PASSWORD, RIGHT_PASS, WRONG_PASS, STOP
  );
  
  constant WAIT_PASSWORD_STATE_MAX_COUNTER : integer range 0 to 4 := 4; -- wait 4 cylces -> user must enter a number at each cycle ==> we have 4 digits password/PIN
  constant CORRECT_PASSWORD: password_t := (1, 2, 3, 4);
end types;