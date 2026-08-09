class alu_env extends uvm_env;
    `uvm_component_utils(alu_env)
    alu_inp_agent in_agnt_h;
    alu_out_agent out_agnt_h;
    alu_scoreboard scb;
    alu_subscriber sub;
 
    function new(string name = "alu_env", uvm_component parent);
        super.new(name,parent);
    endfunction
 
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        in_agnt_h = alu_inp_agent::type_id::create("in_agnt_h",this);
        out_agnt_h = alu_out_agent::type_id::create("out_agnt_h",this);
        scb= alu_scoreboard::type_id::create("scb",this);
        sub=alu_subscriber::type_id::create("sub",this);
    endfunction
 
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        in_agnt_h.mon.in_ap.connect(scb.in_fifo.analysis_export);
        out_agnt_h.mon.out_ap.connect(scb.out_fifo.analysis_export);
        in_agnt_h.mon.in_ap.connect(sub.analysis_export);
    endfunction
 
endclass
