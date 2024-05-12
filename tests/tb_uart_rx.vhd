library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_uart_rx is
    generic (runner_cfg : string);
end entity;

architecture tb of tb_uart_rx is

    constant clk_period : time := 10 ns;
    constant simtime_in_clocks : integer := 2000;

    signal simulator_clk : std_logic := '0';
    signal simulation_counter : integer range 0 to simtime_in_clocks := 0 ;

    --------------------------------------------------
    -- Simulation Signals
    --------------------------------------------------

    signal rx : std_logic := '1';
    signal rx_data_ready : std_logic;
    signal rx_data_out : std_logic_vector(7 downto 0);

begin

    main : process
    begin
        set_stop_level(failure);

        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clk_period;
        test_runner_cleanup(runner); -- Simulation ends here
    end process;

    simulator_clk <= not simulator_clk after clk_period / 2;

    process (simulator_clk)
    begin
        if rising_edge(simulator_clk) then
            simulation_counter <= simulation_counter + 1;

            case simulation_counter is
                when 10 => rx <= '0';
                when 210 => rx <= '1';
                when 410 => rx <= '0';
                when 610 => rx <= '0';
                when 810 => rx <= '1';
                when 1010 => rx <= '1';
                when 1210 => rx <= '0';
                when 1410 => rx <= '1';
                when 1610 => rx <= '1';
                when 1810 => rx <= '1';
                    
            
                when others =>
            end case;
        end if;
    end process;

    uart_rx_inst: entity work.uart_rx
    generic map(
        baud => 500000
    )
    port map(
        clk => simulator_clk,
        reset => '0',
        rx => rx,
        rx_data_out => rx_data_out,
        rx_data_ready => rx_data_ready
    );

end architecture;
