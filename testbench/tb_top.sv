`include "uvm_macros.svh"
import uvm_pkg::*;
import alu_pkg::*;
module tb_top();       
  bit CLK;

  alu_if vif(CLK);

  // Instantiate DUV
  alu_design DUV (.OPA(vif.OPA),.OPB(vif.OPB),.CLK(CLK),.RST(vif.RST),.CE(vif.CE),.MODE(vif.MODE),.CIN(vif.CIN),.CMD(vif.CMD),.INP_VALID(vif.INP_VALID),
    .RES (vif.RES),.COUT(vif.COUT),.OFLOW(vif.OFLOW),.G(vif.G),.E(vif.E),.L(vif.L),.ERR(vif.ERR));

  initial begin
    uvm_config_db#(virtual alu_if)::set(null, "*", "vif",vif);
    run_test("alu_test");
  end

  initial begin
    CLK = 1'b0;
    forever #5 CLK = ~CLK;
  end

endmodule
