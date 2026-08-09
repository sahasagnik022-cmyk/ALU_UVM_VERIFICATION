class alu_seq_item extends uvm_sequence_item;
  `uvm_object_utils(alu_seq_item)

  // Randomizable Input Control & Data Signals
  rand bit [7:0] OPA;
  rand bit [7:0] OPB;
  rand bit [1:0] INP_VALID;
  rand bit [3:0] CMD;
  rand bit       MODE;
  rand bit       CIN;
  rand bit       CE;
  rand bit       RST;

  // Non-Randomized ALU Outputs (16-bit RES to support multiplication!)
  logic [15:0] RES;
  logic        ERR;
  logic        OFLOW;
  logic        COUT;
  logic        G;
  logic        E;
  logic        L;
  int unsigned wait_cycles=0;

  // 1. Fixed Constraints (8-bit max is 255 / 8'hFF)
  constraint c_ce        { CE dist { 1'b1 := 90, 1'b0 := 10 }; }
  constraint c_opa       { OPA inside {[0:255]}; }
  constraint c_opb       { OPB inside {[0:255]}; }
  constraint c_inp_valid { INP_VALID dist { 2'b00 := 5, 2'b01 := 5, 2'b10 := 5, 2'b11 := 500 }; }
  constraint c_mode      { MODE dist { 1'b1 := 50, 1'b0 := 50 }; }
  constraint c_cmd       { 
    if (MODE == 1'b1) 
      CMD <= 4'd10; 
    else 
      CMD <= 4'd13; 
  }
  constraint c_cin       { CIN dist { 1'b1 := 50, 1'b0 := 50 }; }

  function new(string name="alu_seq_item");
    super.new(name);
  endfunction

  // 2. Clean do_copy using "other_item"
/*  virtual function void do_copy(uvm_object rhs);
    alu_seq_item other_item;
    if (!$cast(other_item, rhs)) begin
      `uvm_fatal("do_copy", "Cast of rhs to alu_seq_item failed")
    end
    super.do_copy(rhs);
    
    this.OPA       = other_item.OPA;
    this.OPB       = other_item.OPB;
    this.INP_VALID = other_item.INP_VALID;
    this.CMD       = other_item.CMD;
    this.MODE      = other_item.MODE;
    this.CIN       = other_item.CIN;
    this.CE        = other_item.CE;
    this.RES       = other_item.RES;
    this.ERR       = other_item.ERR;
    this.OFLOW     = other_item.OFLOW;
    this.COUT      = other_item.COUT;
    this.G         = other_item.G;
    this.E         = other_item.E;
    this.L         = other_item.L;
  endfunction

  // 3. Clean do_compare using "other_item" and "===" for 'z safety
  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    alu_seq_item other_item;
    if (!$cast(other_item, rhs)) begin
      `uvm_fatal("do_compare", "Cast of rhs to alu_seq_item failed")
      return 0;
    end 
    return (
      super.do_compare(rhs, comparer) &&
      (this.RES   === other_item.RES)   &&
      (this.ERR   === other_item.ERR)   &&
      (this.OFLOW === other_item.OFLOW) &&
      (this.COUT  === other_item.COUT)  &&
      (this.G     === other_item.G)     &&
      (this.L     === other_item.L)     &&
      (this.E     === other_item.E)
    );
  endfunction

  // 4. Clean do_print with 16-bit RESULT
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field("CE",        this.CE,        1,  UVM_DEC);
    printer.print_field("OPA",       this.OPA,       8,  UVM_DEC);
    printer.print_field("OPB",       this.OPB,       8,  UVM_DEC);
    printer.print_field("INP_VALID", this.INP_VALID, 2,  UVM_DEC);
    printer.print_field("CMD",       this.CMD,       4,  UVM_DEC);
    printer.print_field("MODE",      this.MODE,      1,  UVM_DEC);
    printer.print_field("CIN",       this.CIN,       1,  UVM_DEC);
    printer.print_field("RESULT",    this.RES,       16, UVM_HEX); // 16 bits in HEX for clean debugging
    printer.print_field("ERR",       this.ERR,       1,  UVM_DEC);
    printer.print_field("OFLOW",     this.OFLOW,     1,  UVM_DEC);
    printer.print_field("COUT",      this.COUT,      1,  UVM_DEC);
    printer.print_field("GREATER",   this.G,         1,  UVM_DEC);
    printer.print_field("EQUAL",     this.E,         1,  UVM_DEC);
    printer.print_field("LESSER",    this.L,         1,  UVM_DEC);
  endfunction
*/
endclass
