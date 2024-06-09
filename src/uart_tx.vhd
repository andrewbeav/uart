library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.uart_pkg.uart_state_t;

entity uart_tx is
    generic (
        clk_freq_in : integer := 100000000;
        baud        : integer := 50000;
        data_length : integer := 8
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;
        
        tx_data_in : in std_logic_vector(data_length-1 downto 0);
        n_request_tx : in std_logic;
        tx_sent : out boolean := false;

        tx : out std_logic := '1'
    );
end entity;

architecture rtl of uart_tx is

    signal current_state : uart_state_t := IDLE;

    constant clk_cycles_per_bit : integer := clk_freq_in/baud;
    signal bit_counter : integer range 0 to clk_cycles_per_bit := 0;
    signal data_index : integer range 0 to data_length-1 := 0;

begin
    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                tx <= '1';
            else
                case current_state is
                    when IDLE =>
                        tx <= '1';
                        if n_request_tx = '0' then
                            current_state <= START_BIT;
                            tx_sent <= false;
                        end if;

                    when START_BIT =>
                        tx <= '0';
                        if bit_counter >= clk_cycles_per_bit-1 then
                            current_state <= DATA;
                            bit_counter <= 0;
                        else
                            bit_counter <= bit_counter + 1;
                        end if;

                    when DATA =>
                        tx <= tx_data_in(data_index);
                        if bit_counter >= clk_cycles_per_bit-1 then
                            bit_counter <= 0;
                            if data_index >= data_length-1 then
                                current_state <= STOP_BIT;
                                data_index <= 0;
                            else
                                data_index <= data_index + 1;
                            end if;
                        else
                            bit_counter <= bit_counter + 1;
                        end if;

                    when STOP_BIT =>
                        tx <= '1';
                        if bit_counter >= clk_cycles_per_bit-1 then
                            bit_counter <= 0;
                            current_state <= IDLE;
                            tx_sent <= true;
                        else
                            bit_counter <= bit_counter + 1;
                        end if;

                    when others => current_state <= IDLE;
                end case;
            end if;
        end if;
    end process;
end architecture;