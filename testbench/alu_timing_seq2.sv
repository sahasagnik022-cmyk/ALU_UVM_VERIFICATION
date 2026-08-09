class alu_timing_seq2 extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_timing_seq2)

  function new(string name = "alu_timing_seq2");
    super.new(name);
  endfunction

  // ------------------------------------------------------------------------
  // Helper Task: Drives purely idle cycles, keeping Addition signals stable
  // ------------------------------------------------------------------------
  task send_idle_cycles(int count);
    repeat(count) begin
      req = alu_seq_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {
        INP_VALID == 2'b00;
        CE        == 1'b1;
        RST       == 1'b0;
        CMD       == 4'b0000; // Hardcoded Addition
        MODE      == 1'b0;    // Hardcoded Arithmetic Mode
        CIN       == 1'b0;
      }) `uvm_fatal("RAND_FAIL", "Idle cycle randomize failed")
      finish_item(req);
    end
  endtask

  // ------------------------------------------------------------------------
  // Main Body
  // ------------------------------------------------------------------------
  task body();
    `uvm_info("SEQ", "Starting ALU Timing Test (Directed Addition)...", UVM_LOW)

    // ========================================================================
    // CASE 32: Simultaneous Input Capture (2'b11)
    // ========================================================================
    `uvm_info("SEQ", "Executing Case 32: Simultaneous Capture", UVM_LOW)
    req = alu_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
      INP_VALID == 2'b11;
      CE        == 1'b1;
      RST       == 1'b0;
      CMD       == 4'b0000; MODE == 1'b0; CIN == 1'b0;
    }) `uvm_fatal("RAND_FAIL", "Case 32 randomize failed")
    finish_item(req);

    send_idle_cycles(5);

    // ========================================================================
    // CASE 33: Delayed Capture -> A then B
    // ========================================================================
    `uvm_info("SEQ", "Executing Case 33: A then B (Delay = 5 cycles)", UVM_LOW)

    // 1. Send OPA only
    req = alu_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
      INP_VALID == 2'b01; CE == 1'b1; RST == 1'b0;
      CMD == 4'b0000; MODE == 1'b0; CIN == 1'b0;
    }) `uvm_fatal("RAND_FAIL", "Case 33 OPA randomize failed")
    finish_item(req);

    // 2. Wait 5 cycles (send_idle_cycles already hardcodes Addition)
    send_idle_cycles(5);

    // 3. Send OPB only
    req = alu_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
      INP_VALID == 2'b10; CE == 1'b1; RST == 1'b0;
      CMD == 4'b0000; MODE == 1'b0; CIN == 1'b0;
    }) `uvm_fatal("RAND_FAIL", "Case 33 OPB randomize failed")
    finish_item(req);

    send_idle_cycles(5);

    // ========================================================================
    // CASE 34: Delayed Capture -> B then A
    // ========================================================================
    `uvm_info("SEQ", "Executing Case 34: B then A (Delay = 10 cycles)", UVM_LOW)

    // 1. Send OPB only
    req = alu_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
      INP_VALID == 2'b10; CE == 1'b1; RST == 1'b0;
      CMD == 4'b0000; MODE == 1'b0; CIN == 1'b0;
    }) `uvm_fatal("RAND_FAIL", "Case 34 OPB randomize failed")
    finish_item(req);

    // 2. Wait 10 cycles
    send_idle_cycles(10);

    // 3. Send OPA only
    req = alu_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
      INP_VALID == 2'b01; CE == 1'b1; RST == 1'b0;
      CMD == 4'b0000; MODE == 1'b0; CIN == 1'b0;
    }) `uvm_fatal("RAND_FAIL", "Case 34 OPA randomize failed")
    finish_item(req);

    send_idle_cycles(5);

    // ========================================================================
    // CASE 35: 16-Clock Timeout Error
    // ========================================================================
    `uvm_info("SEQ", "Executing Case 35: 16-Clock Timeout Error", UVM_LOW)

    // 1. Send first operand (OPA)
    req = alu_seq_item::type_id::create("req");
    start_item(req);
    if (!req.randomize() with {
      INP_VALID == 2'b01; CE == 1'b1; RST == 1'b0;
      CMD == 4'b0000; MODE == 1'b0; CIN == 1'b0;
    }) `uvm_fatal("RAND_FAIL", "Case 35 OPA randomize failed")
    finish_item(req);

    // 2. Wait 18 cycles to deliberately force the hardware timeout flag
    send_idle_cycles(18);

    `uvm_info("SEQ", "ALU Timing Test Sequence Completed successfully!", UVM_LOW)
  endtask
endclass
