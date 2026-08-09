class alu_inp_monitor extends uvm_monitor;
    `uvm_component_utils(alu_inp_monitor)

    virtual alu_if vif;
    alu_seq_item drv2mon;
    alu_config cfg;
    uvm_analysis_port#(alu_seq_item) in_ap;

    function new(string name = "alu_inp_monitor", uvm_component parent);
        super.new(name,parent);
        in_ap = new("in_ap",this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(alu_config)::get(this,"","cfg",cfg))
            `uvm_fatal(get_type_name(),"vif isn't set for input monitor")
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif = cfg.vif;
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            drv2mon = alu_seq_item::type_id::create("drv2mon");
            collect();
            `uvm_info(get_type_name(),$sformatf("input monitor \n%s",drv2mon.sprint()),UVM_HIGH)
        end
    endtask

    virtual task collect();
        repeat(1)@(vif.inp_mon_cb);
        drv2mon.CE = vif.inp_mon_cb.CE;
        drv2mon.OPA = vif.inp_mon_cb.OPA;
        drv2mon.OPB = vif.inp_mon_cb.OPB;
        drv2mon.MODE = vif.inp_mon_cb.MODE;
        drv2mon.CIN = vif.inp_mon_cb.CIN;
        drv2mon.CMD = vif.inp_mon_cb.CMD;
        drv2mon.INP_VALID = vif.inp_mon_cb.INP_VALID;
        in_ap.write(drv2mon);
    endtask
endclass
