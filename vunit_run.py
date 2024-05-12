from vunit import VUnit

# Create VUnit instance by parsing command line arguments
vu = VUnit.from_argv()

# Optionally add VUnit's builtin HDL utilities for checking, logging, communication...
# See http://vunit.github.io/hdl_libraries.html.
vu.add_vhdl_builtins()
# or
# vu.add_verilog_builtins()

uart = vu.add_library("uart")
uart.add_source_files("src/uart_pkg.vhd")
uart.add_source_files("src/uart_rx.vhd")
uart.add_source_files("tests/tb_uart_rx.vhd")
uart.add_source_files("src/uart_tx.vhd")
uart.add_source_files("tests/tb_uart_tx.vhd")

# Run vunit function
vu.main()