LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_elevcon IS
END tb_elevcon;

ARCHITECTURE sim OF tb_elevcon IS
    -- DUT component
    COMPONENT elevcon
        PORT(
            clk          : IN  STD_LOGIC;
            reset        : IN  STD_LOGIC;
            call_button  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            inside_button: IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            floor_sensor : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            motor        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            dooropen     : OUT STD_LOGIC
        );
    END COMPONENT;

    -- test signals
    SIGNAL clk          : STD_LOGIC := '0';
    SIGNAL reset        : STD_LOGIC := '0';
    SIGNAL call_button  : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL inside_button: STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL floor_sensor : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL motor        : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL dooropen     : STD_LOGIC;

BEGIN
    -- DUT instantiation
    DUT: elevcon
        PORT MAP (
            clk          => clk,
            reset        => reset,
            call_button  => call_button,
            inside_button=> inside_button,
            floor_sensor => floor_sensor,
            motor        => motor,
            dooropen     => dooropen
        );

    -- clock generation
    clk <= NOT clk AFTER 10 ns;

    -- stimulus
    stim_proc: PROCESS
    BEGIN
        -- reset sequence
        reset <= '1';
        WAIT FOR 25 ns;
        reset <= '0';

        -- Test 1: Call from floor 2 while elevator is at floor 0
        WAIT FOR 30 ns;
        call_button(2) <= '1';
        WAIT FOR 20 ns;
        call_button(2) <= '0';

        -- Simulate floor sensor moving up
        WAIT FOR 80 ns;
        floor_sensor <= "01";  -- elevator reaches floor 1
        WAIT FOR 80 ns;
        floor_sensor <= "10";  -- elevator reaches floor 2

        -- Test 2: Inside request to go to floor 0
        WAIT FOR 30 ns;
        inside_button(0) <= '1';
        WAIT FOR 20 ns;
        inside_button(0) <= '0';

        -- Simulate floor sensor moving down
        WAIT FOR 80 ns;
        floor_sensor <= "01";  -- back to floor 1
        WAIT FOR 80 ns;
        floor_sensor <= "00";  -- back to floor 0

        -- End sim
        WAIT FOR 200 ns;
        ASSERT FALSE REPORT "Simulation finished" SEVERITY FAILURE;
    END PROCESS;

END sim;
