/***********************************************************************
 * A SystemVerilog RTL model of an instruction regisgter
 *
 * An error can be injected into the design by invoking compilation with
 * the option:  +define+FORCE_LOAD_ERROR
 *
 **********************************************************************/
// user-defined types are defined in instr_register_pkg.sv
import instr_register_pkg::*;

module instr_register(tb_ifc.DUT tb_ifc);
  
  timeunit 1ns/1ns;

  instruction_t  iw_reg [0:31];  // an array of instruction_word structures
  result_t result;

  // write to the register
  always@(posedge tb_ifc.clk, negedge tb_ifc.reset_n)   // write into register
    if (!tb_ifc.reset_n) begin
      foreach (iw_reg[i])
        iw_reg[i] = '{opc:ZERO,default:0};  // reset to all zeros
    end
    else if (tb_ifc.load_en) begin
      iw_reg[tb_ifc.write_pointer] = '{tb_ifc.opcode,tb_ifc.operand_a,tb_ifc.operand_b, result};
    end
    
   always@(*) begin
    unique case (tb_ifc.opcode)
	    ZERO : result = 0;
        PASSA: result = tb_ifc.operand_a;
        PASSB: result = tb_ifc.operand_b;
        ADD  : result = tb_ifc.operand_a + tb_ifc.operand_b;
        SUB  : result = tb_ifc.operand_a - tb_ifc.operand_b;
        MULT : result = tb_ifc.operand_b * tb_ifc.operand_b;
        DIV  : result = tb_ifc.operand_a / tb_ifc.operand_b;
        MOD  : result = tb_ifc.operand_a % tb_ifc.operand_b;
        default: result = 0;
      endcase
   
    end

  // read from the register
  assign tb_ifc.instruction_word = iw_reg[tb_ifc.read_pointer];  // continuously read from register

// compile with +define+FORCE_LOAD_ERROR to inject a functional bug for verification to catch
`ifdef FORCE_LOAD_ERROR
initial begin
  force tb_ifc.operand_b = tb_ifc.operand_a; // cause wrong value to be loaded into operand_b
end
`endif

endmodule: instr_register
