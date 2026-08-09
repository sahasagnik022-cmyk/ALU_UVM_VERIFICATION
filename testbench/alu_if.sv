interface alu_if(input bit clk);

  // All CAPS matching exactly with RTL and 16-bit RES:
  logic [7:0]  OPA;
  logic [7:0]  OPB;
  logic [1:0]  INP_VALID;
  logic [3:0]  CMD;
  logic [15:0] RES;
  logic RST, MODE, CE, CIN, ERR, OFLOW, COUT, G, E, L;

  clocking inp_dr_cb @(posedge clk);
    default input #1 output #1;
    output OPA, OPB, INP_VALID, CMD, MODE, CIN, CE, RST;
  endclocking
  clocking inp_mon_cb @(posedge clk);
    default input #1step output #0;
    input OPA, OPB, INP_VALID, CMD, MODE, CIN, CE, RST;
  endclocking
  clocking out_mon_cb @(posedge clk);
    default input #1step output #0;
    input OPA, OPB, INP_VALID, CMD, MODE, CIN, CE, RST;
    input ERR, RES, OFLOW, COUT, G, E, L;
  endclocking 

  modport INP_DRV(clocking inp_dr_cb);
  modport INP_MON(clocking inp_mon_cb);
  modport OUT_MON(clocking out_mon_cb);

endinterface
