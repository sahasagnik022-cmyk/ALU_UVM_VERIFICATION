class alu_out_monitor extends uvm_monitor;
    `uvm_component_utils(alu_out_monitor);
    virtual alu_if vif;
    alu_seq_item rd_data;
    alu_config cfg;
    uvm_analysis_port#(alu_seq_item) out_ap;

    function new(string name ="alu_output_monitor", uvm_component parent);
        super.new(name,parent);
        out_ap = new("out_ap",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(alu_config)::get(this,"","cfg",cfg))
            `uvm_fatal(get_type_name(),"vif isn't set for output monitor");
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            rd_data =alu_seq_item::type_id::create("rd_data");
            collect();
            `uvm_info(get_type_name(),$sformatf("output monitor \n%s",rd_data.sprint()),UVM_HIGH)
        end
    endtask

    virtual task collect();
        repeat(1)@(vif.out_mon_cb);
        rd_data.CE = vif.out_mon_cb.CE;
        rd_data.OPA = vif.out_mon_cb.OPA;
        rd_data.OPB = vif.out_mon_cb.OPB;
        rd_data.MODE = vif.out_mon_cb.MODE;
        rd_data.CIN = vif.out_mon_cb.CIN;
        rd_data.CMD = vif.out_mon_cb.CMD;
        rd_data.INP_VALID = vif.out_mon_cb.INP_VALID;
        rd_data.RES = vif.out_mon_cb.RES;
        rd_data.COUT = vif.out_mon_cb.COUT;
        rd_data.OFLOW = vif.out_mon_cb.OFLOW;
        rd_data.G = vif.out_mon_cb.G;
        rd_data.E = vif.out_mon_cb.E;
        rd_data.L = vif.out_mon_cb.L;
        rd_data.ERR = vif.out_mon_cb.ERR;
        out_ap.write(rd_data);
    endtask
endclass

