class alu_inp_agent extends uvm_agent;
  `uvm_component_utils(alu_inp_agent)
  alu_driver drv;
  alu_inp_monitor mon;
  uvm_sequencer #(alu_seq_item) seqr;
  
  alu_config cfg;
  function new(string name="alu_inp_agent", uvm_component parent);
    super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db#(alu_config)::get(this, "", "cfg", cfg))
      `uvm_fatal(get_type_name(), "Input Agent Failed to get alu_config")

    mon= alu_inp_monitor::type_id::create("mon", this);
    if (cfg.input_agent_is_active == UVM_ACTIVE) begin
      drv = alu_driver::type_id::create("drv", this);
      seqr= uvm_sequencer #(alu_seq_item)::type_id::create("seqr", this);
    end
  endfunction
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.input_agent_is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass
