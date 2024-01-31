create_clock -name {clk} -period 50 [get_nets clk]
create_clock -name {lsclk} -period 100000 [get_nets lsclk]
set_clock_groups -group [get_clocks clk] -group [get_clocks lsclk] -asynchronous
