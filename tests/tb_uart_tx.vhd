library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity tb_uart_tx is
    generic (runner_cfg : string);
end entity;

architecture tb of tb_uart_tx is

    constant clk_period : time := 10 ns;
    constant simtime_in_clocks : integer := 6000;

    signal simulator_clk : std_logic := '0';
    signal simulation_counter : integer range 0 to simtime_in_clocks := 0 ;

    --------------------------------------------------
    -- Simulation Signals
    --------------------------------------------------

    signal tx : std_logic;
    signal n_request_tx : std_logic := '1';
    signal tx_data_in : std_logic_vector(7 downto 0) := "10101110";

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
                when 10 => n_request_tx <= '0';
                when 11 => n_request_tx <= '1';

                when 3000 =>
                    n_request_tx <= '0';
                    tx_data_in <= "11101101";
                when 3001 => n_request_tx <= '1';

                when others =>
            end case;
        end if;
    end process;

    uart_tx_inst: entity work.uart_tx
     generic map(
        baud => 500000
    )
     port map(
        clk => simulator_clk,
        reset => '0',
        tx_data_in => tx_data_in,
        n_request_tx => n_request_tx,
        tx => tx
    );

end architecture;
