class alu_out_agent extends uvm_agent;
  `uvm_component_utils(alu_out_agent)
  alu_out_monitor mon;
  alu_config cfg;
  function new(string name="alu_out_agent", uvm_component parent);
    super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(alu_config)::get(this, "", "cfg", cfg))
      `uvm_fatal(get_type_name(), "Output Agent Failed to get alu_config")
    mon = alu_out_monitor::type_id::create("mon", this);
  endfunction
endclass
