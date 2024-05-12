package uart_pkg is
    type uart_state_t is (IDLE, START_BIT, DATA, STOP_BIT);
end package;