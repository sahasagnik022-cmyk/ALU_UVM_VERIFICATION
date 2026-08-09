class alu_subscriber extends uvm_subscriber #(alu_seq_item);
  `uvm_component_utils(alu_subscriber)
  alu_seq_item tx;
  covergroup cg;
    cp_mode: coverpoint tx.MODE{
      bins m[]={0,1};
    }
    cp_opa: coverpoint tx.OPA {
      bins low  = {[0:85]};
      bins med  = {[86:170]};
      bins high = {[171:255]};
    }
    cp_opb: coverpoint tx.OPB {
      bins low  = {[0:85]};
      bins med  = {[86:170]};
      bins high = {[171:255]};
    }
    cp_inp_valid: coverpoint tx.INP_VALID {
      bins inp_valid[] = {[0:3]};
    }

    cp_cin: coverpoint tx.CIN {
      bins cin[] = {0,1};
    }

    cp_ce: coverpoint tx.CE {
      bins ce[] = {0,1};
    }
    cp_cmd_arith: coverpoint tx.CMD iff (tx.MODE == 1'b1) {
      bins cmd[] = {[0:10]};
    }
    cp_cmd_logic: coverpoint tx.CMD iff (tx.MODE == 1'b0) {
      bins cmd[] = {[0:13]};
    }
    cp_cmd_all: coverpoint tx.CMD {
        bins cmd[] = {[0:13]};
    }
    cross_mode_cmd_arith:cross cp_mode,cp_cmd_all{
        ignore_bins ia= binsof(cp_mode) intersect {1} && binsof(cp_cmd_all)intersect{[11:13]};
    }

    cross_cmd_arith_inp_valid: cross cp_cmd_arith,cp_inp_valid{
        ignore_bins n= binsof(cp_cmd_arith) intersect {[1:10]};
    }
    cross_cmd_logic_inp_valid: cross cp_cmd_logic,cp_inp_valid{
        ignore_bins n=binsof(cp_cmd_logic) intersect {[1:13]};
    }

  endgroup
  function new(string name = "alu_subscriber", uvm_component parent);
    super.new(name, parent);
    cg = new();
  endfunction

  function void write(alu_seq_item t);
    tx=t;
    cg.sample();
  endfunction

endclass
