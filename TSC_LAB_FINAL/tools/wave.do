onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top/tb_ifc/clk
add wave -noupdate /top/tb_ifc/test_clk
add wave -noupdate /top/tb_ifc/reset_n
add wave -noupdate /top/tb_ifc/load_en
add wave -noupdate /top/tb_ifc/operand_a
add wave -noupdate /top/tb_ifc/operand_b
add wave -noupdate /top/tb_ifc/opcode
add wave -noupdate -radix unsigned /top/tb_ifc/write_pointer
add wave -noupdate -radix unsigned /top/tb_ifc/read_pointer
add wave -noupdate /top/tb_ifc/instruction_word
add wave -noupdate /top/test/result
add wave -noupdate /top/dut/result
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {115290 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {500 ns}
