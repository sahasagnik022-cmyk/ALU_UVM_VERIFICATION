class alu_seq extends uvm_sequence #(alu_seq_item);
  `uvm_object_utils(alu_seq)
 
  function new(string name="alu_seq");
    super.new(name);
  endfunction

  task body();
    alu_seq_item packet;
   `uvm_info("ALU_SEQ", "Starting Mode 1: Arithmetic & Comparison Sweep (CMD 0-8)", UVM_LOW)
   repeat(500) begin
    for (int i = 0; i <=8; i++) begin
      packet = alu_seq_item::type_id::create("packet");
      start_item(packet);
      if (!packet.randomize() with {
        CMD == i ;
        INP_VALID == 2'b11;
        MODE      == 1'b1;
        CIN       == 1'b1;
        CE        == 1'b1; 
        RST       == 1'b0;
      })
        `uvm_fatal("RAND_FAIL", "Mode 1 Sweep Randomization failed")
      finish_item(packet);
    end
   end 

   `uvm_info("ALU_SEQ", "Starting Mode 0: Logic, Shift & Rotate Sweep (CMD 0-13)", UVM_LOW)
   repeat(500) begin
    for (int i = 0; i <= 13; i++) begin
      packet = alu_seq_item::type_id::create("packet");
      start_item(packet);
      if (!packet.randomize() with {
        CMD == i;
        INP_VALID == 2'b11;
        MODE      == 1'b0;
        CE        == 1'b1;
        RST       == 1'b0;
      })
        `uvm_fatal("RAND_FAIL", "Mode 0 Sweep Randomization failed")
      finish_item(packet);
    end 
   end 

    `uvm_info("ALU_SEQ", "Starting Mode 1: Multi-Cycle Multiplication 1 (CMD 9)", UVM_LOW)
   repeat(100) begin
    for (int i = 0; i < 5; i++) begin
      packet = alu_seq_item::type_id::create("packet");
      start_item(packet);
      if (!packet.randomize() with {
        CMD       == 4'd9;
        INP_VALID == 2'b11;
        MODE      == 1'b1;
        CE        == 1'b1;
        RST       ==1'b0;
      })
        `uvm_fatal("RAND_FAIL", "Multiplication CMD 9 Randomization failed")
      finish_item(packet);
    end
   end

   `uvm_info("ALU_SEQ", "Starting Mode 1: Multi-Cycle Multiplication 2 (CMD 10)", UVM_LOW)
   repeat(100) begin
    for (int i = 0; i < 5; i++) begin
      packet = alu_seq_item::type_id::create("packet");
      start_item(packet);
      if (!packet.randomize() with {
        CMD       == 4'd10;
        INP_VALID == 2'b11;
        MODE      == 1'b1;
        CE        == 1'b1;
        RST       == 1'b0;
      })        
        `uvm_fatal("RAND_FAIL", "Multiplication CMD 10 Randomization failed")
      finish_item(packet);
    end 
   end

    `uvm_info("ALU_SEQ", "Starting Mode 0: Special Rotate Operation (CMD 12)", UVM_LOW)
    repeat(100) begin
    for (int i = 0; i < 5; i++) begin
      packet = alu_seq_item::type_id::create("packet");
      start_item(packet);
      if (!packet.randomize() with {
        OPB inside {16,32,64,128};
        CMD       == 4'd12;
        INP_VALID == 2'b11;
        MODE      == 1'b0;
        CE        == 1'b1;
        RST      ==1'b0;
      })
        `uvm_fatal("RAND_FAIL", "Special Rotate CMD 12 Randomization failed")
      finish_item(packet);
    end
    end
    repeat(100) begin
    for (int i = 0; i < 5; i++) begin
      packet = alu_seq_item::type_id::create("packet");
      start_item(packet);
      if (!packet.randomize() with {
        OPB inside {16,32,64,128};
        CMD       == 4'd13;
        INP_VALID == 2'b11;
        MODE      == 1'b0;
        CE        == 1'b1;
        RST      ==1'b0;
      })
        `uvm_fatal("RAND_FAIL", "Special Rotate CMD 12 Randomization failed")
      finish_item(packet);
    end
    end


    `uvm_info("ALU_SEQ", "All Directed-Random Sweeps Completed Successfully!", UVM_LOW)
  endtask

endclass
