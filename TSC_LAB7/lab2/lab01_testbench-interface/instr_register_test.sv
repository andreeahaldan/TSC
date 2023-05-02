/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/
// user-defined types are defined in instr_register_pkg.sv
 import instr_register_pkg::*;

module instr_register_test(tb_ifc.TEST tb_ifc);
   
  timeunit 1ns/1ns;

  parameter SEED = 77777; // seed ul este procedura prin care se initializeaza secventa random
  parameter NO_OF_TRANS = 20;
  parameter TYPE_OF_TRANSACTION  = 2;
  parameter TEST_NAME = "N/A";

  int wrong = 0;
  result_t result;
  
  covergroup calc @(posedge tb_ifc.test_clk);
    c1: coverpoint tb_ifc.operand_a     { 
                                         bins value = {[-15:15]};
                                        }
    c2: coverpoint tb_ifc.operand_b     { 
                                         bins value = {[0:15]};
                                        }
    c3: coverpoint tb_ifc.opcode        {
                                         bins value = {[0:7]};
                                        }   
    c4: coverpoint tb_ifc.write_pointer {
                                         bins value = {[0:31]};
                                        }
    c5: coverpoint tb_ifc.read_pointer  {
                                         bins value = {[0:31]};
                                        }
  endgroup

  calc calc_instance = new();

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");

    $display("\nReseting the instruction register...");
    tb_ifc.write_pointer  = 5'h00;          // initialize write pointer
    tb_ifc.read_pointer   = 5'h1F;          // initialize read pointer
    tb_ifc.load_en        = 1'b0;           // initialize load control line
    tb_ifc.reset_n       <= 1'b0;           // assert reset_n (active low)
    repeat (2) @(posedge tb_ifc.test_clk) ; // hold in reset for 2 clock cycles
    tb_ifc.reset_n       <= 1'b1;           // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    //@(posedge tb_ifc.tb_ifc.clk) load_en = 1'b1;  // enable writing to register
    repeat (NO_OF_TRANS) begin
      @(posedge tb_ifc.test_clk) begin
         randomize_transaction; 
         tb_ifc.load_en = 1'b1;
      end
      @(negedge tb_ifc.test_clk) print_transaction;
    end
    @(posedge tb_ifc.test_clk) tb_ifc.load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i < NO_OF_TRANS; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      if(TYPE_OF_TRANSACTION == 0 || TYPE_OF_TRANSACTION == 2 )
         @(posedge tb_ifc.test_clk) tb_ifc.read_pointer = i;
      else
      if(TYPE_OF_TRANSACTION == 1 || TYPE_OF_TRANSACTION == 3 )
	        @(posedge tb_ifc.test_clk) tb_ifc.read_pointer = $unsigned($random)%32;
      @(negedge tb_ifc.test_clk) print_results;
    end

    @(posedge tb_ifc.test_clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $display("\nRunned test %s", TEST_NAME);
    if (wrong == 0)
      $display("Result: test passed");
    else
      $display("Result: test failed");
    $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //calc_instance.sample();
    static int temp = 0;
    tb_ifc.operand_a     <= $random(SEED)%16;                 // between -15 and 15
    tb_ifc.operand_b     <= $unsigned(SEED)%16;               // between 0 and 15
    tb_ifc.opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    if(TYPE_OF_TRANSACTION == 0 || TYPE_OF_TRANSACTION == 1 )
       tb_ifc.write_pointer <= temp++;
    else 
    if(TYPE_OF_TRANSACTION == 2 || TYPE_OF_TRANSACTION == 3 )
       tb_ifc.write_pointer <= $unsigned($random)%32;
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
  
  function void check_result;
    result = 'x;
    unique case (tb_ifc.instruction_word.opc)
      ZERO: result = 0;
      PASSA: result = tb_ifc.instruction_word.op_a; 
      PASSB: result = tb_ifc.instruction_word.op_b;
      ADD: result = tb_ifc.instruction_word.op_a + tb_ifc.instruction_word.op_b;
      SUB: result = tb_ifc.instruction_word.op_a - tb_ifc.instruction_word.op_b;
      MULT: result = tb_ifc.instruction_word.op_a * tb_ifc.instruction_word.op_b;
      DIV: result = tb_ifc.instruction_word.op_a / tb_ifc.instruction_word.op_b;
      MOD: result = tb_ifc.instruction_word.op_a % tb_ifc.instruction_word.op_b;
    endcase

    if (tb_ifc.instruction_word.result != result)
      wrong++;
  endfunction: check_result
         
endmodule: instr_register_test
