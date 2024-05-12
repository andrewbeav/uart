library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.uart_pkg.uart_state_t;

entity uart_rx is
    generic (
        clk_freq_in : integer := 100000000;
        baud        : integer := 50000;
        data_length : integer := 8
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;
        
        rx : in std_logic;

        rx_data_out : out std_logic_vector(data_length - 1 downto 0) := (others => '0') ;
        rx_data_ready : out std_logic := '0'
    );
end entity;

architecture rtl of uart_rx is

    constant clk_cycles_per_bit : integer := clk_freq_in/baud;
    signal bit_counter : integer range 0 to clk_cycles_per_bit := 0;
    signal data_bits_counter : integer range 0 to data_length-1 := 0;
    
    signal current_state : uart_state_t := IDLE;

begin

    uart_rx_process : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state <= IDLE;
                rx_data_out <= (others => '0') ;
                rx_data_ready <= '0';
                bit_counter <= 0;
            else
                case current_state is
                    when IDLE =>
                        if rx = '0' then
                            current_state <= START_BIT;
                        end if;
                    
                    when START_BIT =>
                        rx_data_ready <= '0';
                        if bit_counter >= clk_cycles_per_bit/2 then
                            bit_counter <= 0;
                            current_state <= DATA;
                        else
                            bit_counter <= bit_counter + 1;
                        end if;

                    when DATA =>

                        if bit_counter = clk_cycles_per_bit-1 then
                            bit_counter <= 0;
                            rx_data_out(data_bits_counter) <= rx;

                            if data_bits_counter >= data_length-1 then
                                current_state <= STOP_BIT;
                                data_bits_counter <= 0;
                            else
                                data_bits_counter <= data_bits_counter + 1;
                            end if;
                        else 
                            bit_counter <= bit_counter + 1;
                        end if;

                    when STOP_BIT =>

                        if bit_counter >= clk_cycles_per_bit-1 then
                            current_state <= IDLE;
                            rx_data_ready <= '1';
                            bit_counter <= 0;
                        else
                            bit_counter <= bit_counter + 1;
                        end if;
                
                    when others =>
                        current_state <= IDLE;
                end case;
            end if; -- reset = '1'
        end if; -- rising_edge(clk)
    end process; -- uart_rx_process

end architecture;