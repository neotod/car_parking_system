----------------------------------------------------------------------------------
-- File: utilties
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

package utils is
  function verify_password(correct_password: password_t; password: password_t) return boolean;
  function password_left_shift_insert(password: password_t; password_in: integer range 0 to 9) return password_t;

end utils;

package body utils is
  function verify_password(correct_password: password_t; password: password_t)
  return boolean is
  begin
    for i in correct_password'range loop
      if (correct_password(i) /= password(i)) then
        return false;
      end if;
    end loop;
    
    return true;
  end verify_password;

  function password_left_shift_insert(password: password_t; password_in: integer range 0 to 9)
  return password_t is
  variable returning_password: password_t := (others => 0);
  begin
    returning_password(0) := password(1);
    returning_password(1) := password(2);
    returning_password(2) := password(3);
    returning_password(3) := password_in;
    
    return returning_password;
  end password_left_shift_insert;
end utils;