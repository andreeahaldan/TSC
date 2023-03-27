/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/
// user-defined types are defined in instr_register_pkg.sv
 import instr_register_pkg::*;

module instr_register_test(tb_ifc.TEST tb_ifc, output logic reset_n, input logic clk);
   
  

  timeunit 1ns/1ns;

  int seed = 77777; // seed ul este procedura prin care se initializeaza secventa random
  parameter NO_OF_TRANS = 20;
  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    tb_ifc.write_pointer  = 5'h00;         // initialize write pointer
    tb_ifc.read_pointer   = 5'h1F;         // initialize read pointer
    tb_ifc.load_en        = 1'b0;          // initialize load control line
           reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;            // hold in reset for 2 clock cycles
           reset_n       <= 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    //@(posedge tb_ifc.tb_ifc.clk) load_en = 1'b1;  // enable writing to register
    repeat (NO_OF_TRANS) begin
      @(posedge clk) begin
         randomize_transaction; 
         tb_ifc.load_en = 1'b1;
      end
      @(negedge clk) print_transaction;
    end
    @(posedge clk) tb_ifc.load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i < NO_OF_TRANS; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      //@(posedge tb_ifc.clk) read_pointer = i;
	  @(posedge clk) tb_ifc.read_pointer = $unsigned($random)%32;
      @(negedge clk) print_results;
    end

    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    tb_ifc.operand_a     <= $random(seed)%16;                 // between -15 and 15
    tb_ifc.operand_b     <= $unsigned($random)%16;            // between 0 and 15
    tb_ifc.opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    tb_ifc.write_pointer <= $unsigned($random)%32;
	//write_pointer <= temp++;
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", tb_ifc.write_pointer);
    $display("  opcode = %0d (%s)", tb_ifc.opcode, tb_ifc.opcode.name);
    $display("  operand_a = %0d",   tb_ifc.operand_a);
    $display("  operand_b = %0d\n", tb_ifc.operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", tb_ifc.read_pointer);
    $display("  opcode = %0d (%s)", tb_ifc.instruction_word.opc, tb_ifc.instruction_word.opc.name);
    $display("  operand_a = %0d",   tb_ifc.instruction_word.op_a);
    $display("  operand_b = %0d", tb_ifc.instruction_word.op_b);
	  $display("  result = %0d\n", tb_ifc.instruction_word.result);
  endfunction: print_results

endmodule: instr_register_test
