library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity car_parking_system_tb is
end car_parking_system_tb;

architecture test_bench of car_parking_system_tb is

    component car_parking_system is
    port (
        front_sensor : in std_logic;
        back_sensor : in std_logic;
    
        green_led : inout std_logic;
        red_led : inout  std_logic;
    
        password_in : in integer range 0 to 9; -- can be BCD numbers
        gate_out : out std_logic; -- gate_out = '0' => gate_close , gate_out = '1' => gate_open
        clk : in std_logic;
        rst : in std_logic
    );
    end component;
    
    signal front_sensor : std_logic := '0';
    signal back_sensor : std_logic := '0';

    signal green_led : std_logic := '0';
    signal red_led : std_logic := '0';

    signal password_in : integer range 0 to 9 := 0; -- can be BCD numbers
    signal gate_out : std_logic := '0'; -- gate_out = '0' => gate_close , gate_out = '1' => gate_open
    
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    constant CLK_PERIOD : time := 100 ns;
    signal finished : std_logic := '0';

begin
    dut: car_parking_system 
    port map (
        front_sensor => front_sensor,
        back_sensor => back_sensor,
    
        green_led => green_led,
        red_led => red_led,
    
        password_in => password_in,
        gate_out => gate_out,
        
        clk => clk,
        rst => rst
    );


    clk_process: process
    begin 
        while (finished = '0') loop
            clk <= '1';
            wait for CLK_PERIOD / 2;

            clk <= '0';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    stimulus: process
    begin
        wait for CLK_PERIOD;

        -- case_1: IDLE --(front_sensor = 1)--> WAIT_PASSWORD --password_wrong--> WRONG_PASS --password_wrong--> WRONG_PASS
        front_sensor <= '1';
        wait for CLK_PERIOD;
        password_in <= 0, 1 after CLK_PERIOD, 3 after 2*CLK_PERIOD, 4 after 3*CLK_PERIOD;
        wait for 6*CLK_PERIOD;
        password_in <= 0, 1 after CLK_PERIOD, 5 after 2*CLK_PERIOD, 3 after 3*CLK_PERIOD, 7 after 4*CLK_PERIOD;
        wait for 6*CLK_PERIOD;

        -- case_2: IDLE --(front_sensor = 1)--> WAIT_PASSWORD --password_wrong--> WRONG_PASS --password_correct--> RIGHT_PASS
        password_in <= 1, 2 after CLK_PERIOD, 3 after 2*CLK_PERIOD, 4 after 3*CLK_PERIOD;
        wait for 6*CLK_PERIOD;

        -- case_3: IDLE --(front_sensor = 1)--> WAIT_PASSWORD --password_correct--> RIGHT_PASS --(back_sensor = 0)--> RIGHT_PASS
        password_in <= 1, 2 after CLK_PERIOD, 3 after 2*CLK_PERIOD, 4 after 3*CLK_PERIOD;
        wait for 6*CLK_PERIOD;

        -- case_4: RIGHT_PASS --(back_sensor = 1 and front_sensor = 1)--> STOP
        front_sensor <= '1';
        back_sensor <= '1';
        wait for 6*CLK_PERIOD;

        -- case_5: STOP --wrong_password--> STOP
        front_sensor <= '0';
        back_sensor <= '0';
        password_in <= 0, 5 after CLK_PERIOD, 3 after 2*CLK_PERIOD, 7 after 3*CLK_PERIOD;
        wait for 6*CLK_PERIOD;

        -- case_6: STOP --correct_password--> RIGHT_PASS
        password_in <= 1, 2 after CLK_PERIOD, 3 after 2*CLK_PERIOD, 4 after 3*CLK_PERIOD;
        wait for 6*CLK_PERIOD;

        -- case_7: RIGHT_PASS --(back_sensor = 1 and front_sensor = 0)--> IDLE
        front_sensor <= '0';
        back_sensor <= '1';
        wait for 6*CLK_PERIOD;

        back_sensor <= '0';
        wait for CLK_PERIOD;

        -- case_8: IDLE --(front_sensor = 1)--> WAIT_PASSWORD --password_correct--> RIGHT_PASS --(back_sensor = 1 and front_sensor = 0)--> IDLE
        front_sensor <= '1';
        wait for CLK_PERIOD;

        password_in <= 1, 2 after CLK_PERIOD, 3 after 2*CLK_PERIOD, 4 after 3*CLK_PERIOD;
        wait for 10*CLK_PERIOD;

        front_sensor <= '0';
        back_sensor <= '1'; -- going to IDLE
        wait for CLK_PERIOD;

        
        -- case_9: IDLE --(front_sensor = 1)--> WAIT_PASSWORD --password_correct--> RIGHT_PASS --(rst = 1)--> RIGHT_PASS
        front_sensor <= '1';
        back_sensor <= '0';
        
        password_in <= 1, 2 after CLK_PERIOD, 3 after 2*CLK_PERIOD, 4 after 3*CLK_PERIOD;
        wait for 10*CLK_PERIOD;

        rst <= '1';
        wait for 3*CLK_PERIOD;

        -- case_10: RIGHT_PASS --(rst = 0)--> IDLE
        rst <= '0';
        wait for 3*CLK_PERIOD;

        wait for 50 * CLK_PERIOD;
        finished <= '1';
        wait;
    end process;
end test_bench;
