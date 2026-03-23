# coremark_waves.do
add wave sim:/testbench/dut/ieu/dp/*
add wave sim:/testbench/dut/ieu/WriteByteEn
add wave sim:/testbench/dut/ieu/dp/rf/*
add wave sim:/testbench/dut/ifu/*
add wave sim:/testbench/dut/ieu/dp/rf/rf

run -all
view wave
