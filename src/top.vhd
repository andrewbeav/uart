library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity top is
    port (
        clk   : in std_logic;
        reset : in std_logic;
        
        uart_rx : in std_logic;
        uart_tx : out std_logic;

        rx_data_ready_out : out std_logic := '0'
    );
end entity;

architecture rtl of top is
    signal data_rx : std_logic_vector(7 downto 0) := (others => '0'); 
    signal data_tx : std_logic_vector(7 downto 0) := (others => '0'); 
    signal rx_data_ready : std_logic := '0';
    signal previous_rx_data_ready : std_logic := '0';

    signal n_request_tx : std_logic := '1';
    signal reset_n_request_tx : boolean := false;
begin

    request_tx_after_rx: process (clk)
    begin
        if rising_edge(clk) then

            if rx_data_ready = '1' and previous_rx_data_ready = '0' then
                n_request_tx <= '0';
                reset_n_request_tx <= true;
            end if;

            if reset_n_request_tx then
                n_request_tx <= '1';
                reset_n_request_tx <= false;
            end if;

            previous_rx_data_ready <= rx_data_ready;
        end if;
    end process;

    rx_data_ready_out <= rx_data_ready;
    data_tx <= std_logic_vector(unsigned(data_rx) + 1);

    uart_rx_inst: entity work.uart_rx
    port map(
        clk => clk,
        reset => reset,
        rx => uart_rx,
        rx_data_out => data_rx,
        rx_data_ready => rx_data_ready
    );

    uart_tx_inst: entity work.uart_tx
    port map(
        clk => clk,
        reset => reset,
        tx_data_in => data_tx,
        n_request_tx => n_request_tx,
        tx => uart_tx
    );

end architecture;