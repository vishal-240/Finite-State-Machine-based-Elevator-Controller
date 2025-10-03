LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY elevcon IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        floor_sensor : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- 00: floor 0, 01: floor 1, 10: floor 2
        call_button : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        inside_button : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        motor : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- 00: stop, 10: up, 01: down
        dooropen : OUT STD_LOGIC
    );
END elevcon;

ARCHITECTURE beh OF elevcon IS
    TYPE state_type IS (IDLE_0, IDLE_1, IDLE_2, MOVING_UP, MOVING_DOWN, DOOR_OPEN_0, DOOR_OPEN_1, DOOR_OPEN_2);
    SIGNAL current_state, next_state : state_type := IDLE_0;
    SIGNAL door_timer : INTEGER := 0;
	 SIGNAL Requests : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
    PROCESS (clk, reset)
    BEGIN
		  
        IF reset = '1' THEN
            current_state <= IDLE_0;
            Requests <= (OTHERS => '0');
            door_timer <= 0;
        ELSIF rising_edge(clk) THEN
            current_state <= next_state;
            -- Update Requests based on button presses
            FOR i IN 0 TO 2 LOOP
                IF call_button(i) = '1' OR inside_button(i) = '1' THEN
                    Requests(i) <= '1';
                END IF;
            END LOOP;
            
            CASE current_state IS
                WHEN IDLE_0 =>
                    IF Requests(0) = '1' THEN
                        next_state <= DOOR_OPEN_0;
                        door_timer <= door_timer + 1;
                        motor <= "00";
                        dooropen <= '1';
                        Requests(0) <= '0'; --clear request after door opens
                    ELSIF Requests(1) = '1' THEN
                        next_state <= MOVING_UP;
                        motor <= "10";
                        dooropen <= '0';
                    ELSIF Requests(2) = '1' THEN
                        next_state <= MOVING_UP;
                        motor <= "10";
                        dooropen <= '0';
                    ELSE
                        next_state <= IDLE_0;
                        motor <= "00";
                        dooropen <= '0';
                    END IF;
                WHEN IDLE_1 =>
                    IF Requests(1) = '1' THEN
                        next_state <= DOOR_OPEN_1;
                        door_timer <= door_timer + 1;
                        motor <= "00";
                        dooropen <= '1';
                        Requests(1) <= '0';
                    ELSIF Requests(2) = '1' THEN --top priority to go up
                        next_state <= MOVING_UP;
                        motor <= "10";
                        dooropen <= '0';
                    ELSIF Requests(0) = '1' THEN
                        next_state <= MOVING_DOWN;
                        motor <= "01";
                        dooropen <= '0';
                    ELSE
                        next_state <= IDLE_1;
                        motor <= "00";
                        dooropen <= '0';
                    END IF;
                WHEN IDLE_2 =>
                    IF Requests(2) = '1' THEN
                        next_state <= DOOR_OPEN_2;
                        door_timer <= door_timer + 1;
                        motor <= "00";
                        dooropen <= '1';
                        Requests(2) <= '0';
                    ELSIF (Requests(1) = '1' OR Requests(0) = '1') THEN
                        next_state <= MOVING_DOWN;
                        motor <= "01";
                        dooropen <= '0';
                    ELSE
                        next_state <= IDLE_2;
                        motor <= "00";
                        dooropen <= '0';
                    END IF;
                WHEN MOVING_UP =>
                    IF (floor_sensor = "00" AND Requests(0) = '1') THEN
                        next_state <= DOOR_OPEN_0;
                        door_timer <= door_timer + 1;
                        motor <= "00";
                        dooropen <= '1';
                        Requests(0) <= '0';
                    ELSIF (floor_sensor = "00" AND Requests(0) = '0' AND (Requests(2) = '1' OR Requests(1) = '1')) THEN
                        next_state <= MOVING_UP;
                        motor <= "10";
                        dooropen <= '0';
                    ELSIF (floor_sensor = "01" AND Requests(1) = '1') THEN
                        next_state <= DOOR_OPEN_1;
                        door_timer <= door_timer + 1;
                        motor <= "00";
                        dooropen <= '1';
                        Requests(1) <= '0';
                    ELSIF (floor_sensor = "10" AND Requests(2) = '1') THEN
                        next_state <= DOOR_OPEN_2;
                        door_timer <= door_timer + 1;
                        motor <= "00";
                        dooropen <= '1';
                        Requests(2) <= '0';
                    ELSIF (floor_sensor = "01" AND Requests(1) = '0' AND Requests(2) = '1') THEN
                        next_state <= MOVING_UP;
                        motor <= "10";
                        dooropen <= '0';
                    ELSIF (floor_sensor = "10" AND Requests(2) = '0' AND (Requests(1) = '1' OR Requests(0) = '1')) THEN
                        next_state <= MOVING_DOWN;
                        motor <= "01";
                        dooropen <= '0';
                    ELSIF (floor_sensor = "01" AND Requests(2) = '0' AND Requests(1) = '0' AND Requests(0) = '1') THEN
                        next_state <= MOVING_DOWN;
                        motor <= "01";
                        dooropen <= '0';
                    ELSE
                        CASE floor_sensor IS
                            WHEN "00" =>
                                next_state <= IDLE_0;
                                motor <= "00";
                                dooropen <= '0';
                            WHEN "01" =>
                                next_state <= IDLE_1;
                                motor <= "00";
                                dooropen <= '0';
                            WHEN "10" =>
                                next_state <= IDLE_2;
                                motor <= "00";
                                dooropen <= '0';
                            WHEN OTHERS =>
                                NULL;
                        END CASE;
                    END IF;
                WHEN MOVING_DOWN =>
                    IF (floor_sensor = "10" AND Requests(2) = '1') THEN
                        next_state <= DOOR_OPEN_2;
                        door_timer <= door_timer + 1;
                        motor <= "00";
                        dooropen <= '1';
                        Requests(2) <= '0';
                    ELSIF (floor_sensor = "10" AND Requests(2) = '0' AND (Requests(0) = '1' OR Requests(1) = '1')) THEN
                        next_state <= MOVING_DOWN;
                        motor <= "01";
                        dooropen <= '0';
                    ELSIF (floor_sensor = "01" AND Requests(1) = '1') THEN
                        next_state <= DOOR_OPEN_1;
                        door_timer <= door_timer + 1;
                        motor <= "00";
                        dooropen <= '1';
                        Requests(1) <= '0';
                    ELSIF (floor_sensor = "00" AND Requests(0) = '1') THEN
                        next_state <= DOOR_OPEN_0;
                        door_timer <= door_timer + 1;
                        motor <= "00";
                        dooropen <= '1';
                        Requests(0) <= '0';
                    ELSIF (floor_sensor = "01" AND Requests(1) = '0' AND Requests(0) = '1') THEN
                        next_state <= MOVING_DOWN;
                        motor <= "01";
                        dooropen <= '0';
                    ELSIF (floor_sensor = "00" AND Requests(0) = '0' AND (Requests(1) = '1' OR Requests(2) = '1')) THEN
                        next_state <= MOVING_UP;
                        motor <= "10";
                        dooropen <= '0';
                    ELSIF (floor_sensor = "01" AND Requests(0) = '0' AND Requests(1) = '0' AND Requests(2) = '1') THEN
                        next_state <= MOVING_UP;
                        motor <= "10";
                        dooropen <= '0';
                    ELSE
                        CASE floor_sensor IS
                            WHEN "00" =>
                                next_state <= IDLE_0;
                                motor <= "00";
                                dooropen <= '0';
                            WHEN "01" =>
                                next_state <= IDLE_1;
                                motor <= "00";
                                dooropen <= '0';
                            WHEN "10" =>
                                next_state <= IDLE_2;
                                motor <= "00";
                                dooropen <= '0';
                            WHEN OTHERS =>
                                NULL;
                        END CASE;
                    END IF;
                WHEN DOOR_OPEN_0 =>
                    IF door_timer < 5 THEN
                        next_state <= DOOR_OPEN_0;
                        door_timer <= door_timer + 1;
                        motor <= "00";
                        dooropen <= '1';
                    ELSE
                        door_timer <= 0;
                        IF Requests(0) = '1' THEN
                            next_state <= DOOR_OPEN_0;
                            motor <= "00";
                            dooropen <= '1';
                            Requests(0) <= '0';
                        ELSIF Requests(1) = '1' THEN
                            next_state <= MOVING_UP;
                            motor <= "10";
                            dooropen <= '0';
                        ELSIF Requests(2) = '1' THEN
                            next_state <= MOVING_UP;
                            motor <= "10";
                            dooropen <= '0';
                        ELSE
                            next_state <= IDLE_0;
                            motor <= "00";
                            dooropen <= '0';
                        END IF;
                    END IF;
                WHEN DOOR_OPEN_1 =>
                    IF door_timer < 5 THEN
                        next_state <= DOOR_OPEN_1;
                        door_timer <= door_timer + 1;
                        motor <= "00";
                        dooropen <= '1';
                    ELSE
                        door_timer <= 0;
                        IF Requests(1) = '1' THEN
                            next_state <= DOOR_OPEN_1;
                            motor <= "00";
                            dooropen <= '1';
                            Requests(1) <= '0';
                        ELSIF Requests(2) = '1' THEN --top priority to go up
                            next_state <= MOVING_UP;
                            motor <= "10";
                            dooropen <= '0';
                        ELSIF Requests(0) = '1' THEN
                            next_state <= MOVING_DOWN;
                            motor <= "01";
                            dooropen <= '0';
                        ELSE
                            next_state <= IDLE_1;
                            motor <= "00";
                            dooropen <= '0';
                        END IF;
                    END IF;
                WHEN DOOR_OPEN_2 =>
                    IF door_timer < 5 THEN
                        next_state <= DOOR_OPEN_2;
                        door_timer <= door_timer + 1;
                        motor <= "00";
                        dooropen <= '1';
                    ELSE
                        door_timer <= 0;
                        IF Requests(2) = '1' THEN
                            next_state <= DOOR_OPEN_2;
                            motor <= "00";
                            dooropen <= '1';
                            Requests(2) <= '0';
                        ELSIF (Requests(1) = '1' OR Requests(0) = '1') THEN
                            next_state <= MOVING_DOWN;
                            motor <= "01";
                            dooropen <= '0';
                        ELSE
                            next_state <= IDLE_2;
                            motor <= "00";
                            dooropen <= '0';
                        END IF;
                    END IF;
                WHEN OTHERS =>
                    NULL;
            END CASE;
        END IF;
    END PROCESS;
END beh;