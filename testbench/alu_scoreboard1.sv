class alu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(alu_scoreboard)
    uvm_tlm_analysis_fifo #(alu_seq_item)in_fifo;
    uvm_tlm_analysis_fifo #(alu_seq_item)out_fifo;

    alu_seq_item in_xn;
    alu_seq_item out_xn;
    alu_seq_item exp_item[int];
    alu_seq_item exp_xn;
    int in_count,out_count;
    int match_count=0;
    int mismatch_count=0;
    bit op1_p=0;
    bit op2_p=0;
    bit[7:0] l_oprd1, l_oprd2;
    bit[3:0] l_cmd;
    bit l_mode, l_cin, l_ce;
    bit sch_en;
    int timeout=0;
    int wait_cycles=0;
    bit is_timeout=0;
    function new(string name = "alu_scoreboard",uvm_component parent);
        super.new(name,parent);
        in_fifo = new("in_fifo",this);
        out_fifo = new("out_fifo",this);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            in_fifo.get(in_xn);
            in_count++;

            ref_model(in_xn);
            `uvm_info("REFERENCE MODEL",$sformatf("REFERENCE MODEL \n%s",in_xn.sprint()),UVM_HIGH)
            if (sch_en) begin
              if (is_timeout)
                exp_item[in_count] = in_xn;
              else if (in_xn.MODE == 1'b1 && in_xn.CMD inside {9,10})
                exp_item[in_count + 3] = in_xn;
              else
                exp_item[in_count + 2] = in_xn;
            end
            out_fifo.get(out_xn);
            out_count++;

            if(exp_item.exists(out_count))begin
                exp_xn = exp_item[out_count];
                check_data(out_xn);
            end
            else
                `uvm_info("get_type_name",$sformatf("the index mentioned is empty"),UVM_NONE)

            `uvm_info("CHECK DATA",$sformatf("CHECK DATA \n%s",out_xn.sprint()),UVM_HIGH)
        end
    endtask

    task check_data(alu_seq_item t);
        string debug_report;
        bit    match = 1'b1;

    if (t.RES !== exp_xn.RES) begin
        `uvm_error("CHECK_DATA", $sformatf("RES MISMATCH! Expected: 0x%0h | Actual: 0x%0h", exp_xn.RES, t.RES))
        match = 1'b0;
    end

    if (t.COUT !== exp_xn.COUT) begin
      `uvm_error("CHECK_DATA", $sformatf("COUT MISMATCH! Expected: %0b | Actual: %0b", exp_xn.COUT, t.COUT))
      match = 1'b0;
    end

    if (t.OFLOW !== exp_xn.OFLOW) begin
      `uvm_error("CHECK_DATA", $sformatf("OFLOW MISMATCH! Expected: %0b | Actual: %0b", exp_xn.OFLOW, t.OFLOW))
      match = 1'b0;
    end

    if (t.G !== exp_xn.G) begin
      `uvm_error("CHECK_DATA", $sformatf("G MISMATCH! Expected: %0b | Actual: %0b", exp_xn.G, t.G))
      match = 1'b0;
    end

    if (t.E !== exp_xn.E) begin
      `uvm_error("CHECK_DATA", $sformatf("E MISMATCH! Expected: %0b | Actual: %0b", exp_xn.E, t.E))
      match = 1'b0;
    end

    if (t.L !== exp_xn.L) begin
      `uvm_error("CHECK_DATA", $sformatf("L MISMATCH! Expected: %0b | Actual: %0b", exp_xn.L, t.L))
      match = 1'b0;
    end

    if (t.ERR !== exp_xn.ERR) begin
      `uvm_error("CHECK_DATA", $sformatf("ERR MISMATCH! Expected: %0b | Actual: %0b", exp_xn.ERR, t.ERR))
      match = 1'b0;
    end
    debug_report = "\n+-------------------------------------------------------------------------+\n";
    debug_report = {debug_report, $sformatf("| INPUTS   | OPA=0x%0h | OPB=0x%0h | CMD=4'b%0b (%0d) | MODE=%0b | CIN=%0b\n",
                    exp_xn.OPA, exp_xn.OPB, exp_xn.CMD, exp_xn.CMD, exp_xn.MODE, exp_xn.CIN)};
    debug_report = {debug_report, "+----------+-----------+-----------+--------------------+----------+--------+\n"};
    debug_report = {debug_report, $sformatf("| EXPECTED | RES=0x%-4h | COUT=%0b | OFLOW=%0b | ERR=%0b | G=%0b | L=%0b | E=%0b   |\n",
                    exp_xn.RES, exp_xn.COUT, exp_xn.OFLOW, exp_xn.ERR, exp_xn.G, exp_xn.L, exp_xn.E)};
    debug_report = {debug_report, $sformatf("| ACTUAL   | RES=0x%-4h | COUT=%0b | OFLOW=%0b | ERR=%0b | G=%0b | L=%0b | E=%0b   |\n",
                    t.RES, t.COUT, t.OFLOW, t.ERR, t.G, t.L, t.E)};
    debug_report = {debug_report, "+-------------------------------------------------------------------------+"};
    if (match) begin
      `uvm_info("CHECK_DATA", $sformatf("ALU Transaction PASSED!%s", debug_report), UVM_LOW)
        match_count++;
    end else begin
      `uvm_error("CHECK_DATA", $sformatf("ALU Transaction FAILED! See table below for comparison:%s", debug_report))
        mismatch_count++;
    end
  endtask

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB_REPORT", "========================================", UVM_LOW)
    `uvm_info("SCB_REPORT", $sformatf("TOTAL MATCHES   : %0d", match_count), UVM_LOW)
    `uvm_info("SCB_REPORT", $sformatf("TOTAL MISMATCHES: %0d", mismatch_count), UVM_LOW)
    `uvm_info("SCB_REPORT", "========================================", UVM_LOW)
  endfunction

  virtual task ref_model(alu_seq_item t);
    bit [7:0] oprd1, oprd2;
    bit [3:0] CMD_tmp;
    bit [7:0] AU_out_tmp1, AU_out_tmp2, OPA_1, OPB_1;
    bit start;

    sch_en = 1'b0;
    is_timeout = 1'b0;
    start = 1'b0;
    if (t.RST) begin
      op1_p = 1'b0;
      op2_p = 1'b0;
      wait_cycles = 0;
    end
    else if (t.INP_VALID == 2'b11) begin
      op1_p = 1'b0;
      op2_p = 1'b0;
      wait_cycles = 0;
      oprd1 = t.OPA;
      oprd2 = t.OPB;
      CMD_tmp = t.CMD;
      start = 1'b1;
    end
    else if (t.INP_VALID == 2'b01) begin // Only OPA Valid
      if (op2_p) begin
        op1_p = 1'b0;
        op2_p = 1'b0;
        wait_cycles = 0;

        oprd1   = t.OPA;
        oprd2   = l_oprd2;
        CMD_tmp = l_cmd;
        t.MODE  = l_mode;
        t.CIN   = l_cin;
        t.CE    = l_ce;
        start = 1'b1;
      end else begin
        l_oprd1 = t.OPA;
        l_cmd   = t.CMD;
        l_mode  = t.MODE;
        l_cin   = t.CIN;
        l_ce    = t.CE;
        op1_p = 1'b1;
        wait_cycles = 0;
      end
    end
    else if (t.INP_VALID == 2'b10) begin // Only OPB Valid
      if (op1_p) begin
        op1_p = 1'b0;
        op2_p = 1'b0;
        wait_cycles = 0;

        oprd1   = l_oprd1;
        oprd2   = t.OPB;
        CMD_tmp = l_cmd;
        t.MODE  = l_mode;
        t.CIN   = l_cin;
        t.CE    = l_ce;
        start = 1'b1;
      end else begin
        l_oprd2 = t.OPB;
        l_cmd   = t.CMD;
        l_mode  = t.MODE;
        l_cin   = t.CIN;
        l_ce    = t.CE;

        op2_p = 1'b1;
        wait_cycles = 0;
      end
    end
    else begin // INP_VALID == 2'b00 (Idle Cycle)
      if (op1_p || op2_p) begin
        wait_cycles++;
        if (wait_cycles == 16) begin
          op1_p = 1'b0;
          op2_p = 1'b0;
          wait_cycles = 0;

          is_timeout = 1'b1;
          sch_en = 1'b1;     // Schedule the error packet!
          t.RES   = 16'b0;
          t.COUT  = 1'b0;
          t.OFLOW = 1'b0;
          t.G     = 1'b0;
          t.E     = 1'b0;
          t.L     = 1'b0;
          t.ERR   = 1'b1;
        end
      end
    end

    if (start && t.CE) begin
      sch_en = 1'b1;
      t.RES   = 16'b0;
      t.COUT  = 1'b0;
      t.OFLOW = 1'b0;
      t.G     = 1'b0;
      t.E     = 1'b0;
      t.L     = 1'b0;
      t.ERR   = 1'b0;

      if (t.MODE) begin
        case (CMD_tmp)
          4'b0000: begin
            t.RES  = oprd1 + oprd2;
            t.COUT = t.RES[8] ? 1 : 0;
          end
          4'b0001: begin
            t.OFLOW = (oprd1 < oprd2) ? 1 : 0;
            t.RES   = oprd1 - oprd2;
          end
          4'b0010: begin
            t.RES  = oprd1 + oprd2 + t.CIN;
            t.COUT = t.RES[8] ? 1 : 0;
          end
          4'b0011: begin
            t.OFLOW = (oprd1 < oprd2) ? 1 : 0;
            t.RES   = oprd1 - oprd2 - t.CIN;
          end
          4'b0100: t.RES = oprd1 + 1;
          4'b0101: t.RES = oprd1 - 1;
          4'b0110: t.RES = oprd2 + 1;
          4'b0111: t.RES = oprd2 - 1;
          4'b1000: begin
            t.RES = 16'b0;
            if (oprd1 == oprd2) begin
              t.E = 1'b1; t.G = 1'b0; t.L = 1'b0;
            end else if (oprd1 > oprd2) begin
              t.E = 1'b0; t.G = 1'b1; t.L = 1'b0;
            end else begin
              t.E = 1'b0; t.G = 1'b0; t.L = 1'b1;
            end
          end
          4'b1001: begin
            AU_out_tmp1 = oprd1 + 1;
            AU_out_tmp2 = oprd2 + 1;
            t.RES = AU_out_tmp1 * AU_out_tmp2;
          end
          4'b1010: begin
            AU_out_tmp1 = oprd1 << 1;
            AU_out_tmp2 = oprd2;
            t.RES = AU_out_tmp1 * AU_out_tmp2;
          end
          default: begin
            t.RES   = 16'b0;
            t.COUT  = 1'b0;
            t.OFLOW = 1'b0;
            t.G     = 1'b0;
            t.E     = 1'b0;
            t.L     = 1'b0;
            t.ERR   = 1'b0;
          end
        endcase
      end
      else begin
        case (CMD_tmp)
          4'b0000: t.RES = {1'b0, oprd1 & oprd2};
          4'b0001: t.RES = {1'b0, ~(oprd1 & oprd2)};
          4'b0010: t.RES = {1'b0, oprd1 | oprd2};
          4'b0011: t.RES = {1'b0, ~(oprd1 | oprd2)};
          4'b0100: t.RES = {1'b0, oprd1 ^ oprd2};
          4'b0101: t.RES = {1'b0, ~(oprd1 ^ oprd2)};
          4'b0110: t.RES = {1'b0, ~oprd1};
          4'b0111: t.RES = {1'b0, ~oprd2};
          4'b1000: t.RES = {1'b0, oprd1 >> 1};
          4'b1001: t.RES = {1'b0, oprd1 << 1};
          4'b1010: t.RES = {1'b0, oprd2 >> 1};
          4'b1011: t.RES = {1'b0, oprd2 << 1};
          4'b1100: begin
            if (oprd2[0]) OPA_1 = {oprd1[6:0], oprd1[7]};
            else          OPA_1 = oprd1;

            if (oprd2[1]) OPB_1 = {OPA_1[5:0], OPA_1[7:6]};
            else          OPB_1 = OPA_1;

            if (oprd2[2]) t.RES = {OPB_1[3:0], OPB_1[7:4]};
            else          t.RES = OPB_1;

            if (oprd2[4] | oprd2[5] | oprd2[6] | oprd2[7])
              t.ERR = 1'b1;
          end
          4'b1101: begin
            if (oprd2[0]) OPA_1 = {oprd1[0], oprd1[7:1]};
            else          OPA_1 = oprd1;

            if (oprd2[1]) OPB_1 = {OPA_1[1:0], OPA_1[7:2]};
            else          OPB_1 = OPA_1;

            if (oprd2[2]) t.RES = {OPB_1[3:0], OPB_1[7:4]};
            else          t.RES = OPB_1;

            if (oprd2[4] | oprd2[5] | oprd2[6] | oprd2[7])
              t.ERR = 1'b1;
          end
          default: begin
            t.RES   = 16'b0;
            t.COUT  = 1'b0;
            t.OFLOW = 1'b0;
            t.G     = 1'b0;
            t.E     = 1'b0;
            t.L     = 1'b0;
            t.ERR   = 1'b0;
          end
        endcase
      end
    end
  endtask
endclass
