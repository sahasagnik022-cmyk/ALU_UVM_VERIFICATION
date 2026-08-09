class alu_driver extends uvm_driver #(alu_seq_item);
  `uvm_component_utils(alu_driver)
  virtual alu_if.INP_DRV vif;
  alu_config cfg;

  function new(string name="alu_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(alu_config)::get(this, "", "cfg", cfg))
      `uvm_fatal(get_type_name(), "Input_Driver Failed to get alu_config")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vif = cfg.vif;
  endfunction

  task run_phase(uvm_phase phase);
    @(vif.inp_dr_cb);
    vif.inp_dr_cb.RST   <= 1'b1;
    vif.inp_dr_cb.CE    <= 1'b0;
    vif.inp_dr_cb.INP_VALID <= 2'b00;
    vif.inp_dr_cb.OPA   <= '0;
    vif.inp_dr_cb.OPB   <= '0;
    vif.inp_dr_cb.MODE  <= 1'b0;
    vif.inp_dr_cb.CMD   <= '0;
    vif.inp_dr_cb.CIN   <= 1'b0;
    @(vif.inp_dr_cb);
    vif.inp_dr_cb.RST   <= 1'b0; 
    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask

  task drive(alu_seq_item data2duv);
    `uvm_info("[DRV]", $sformatf("Driving item: OPA=%0d,OPB=%0d,CMD=%0d,MODE=%0d,CIN=%0d,INV=%0d", data2duv.OPA,data2duv.OPB,data2duv.CMD,data2duv.MODE,data2duv.CIN,data2duv.INP_VALID), UVM_LOW)
    
    @(vif.inp_dr_cb);
    vif.inp_dr_cb.CE        <= data2duv.CE;
    vif.inp_dr_cb.INP_VALID <= data2duv.INP_VALID;
    vif.inp_dr_cb.OPA       <= data2duv.OPA;
    vif.inp_dr_cb.OPB       <= data2duv.OPB;
    vif.inp_dr_cb.MODE      <= data2duv.MODE;
    vif.inp_dr_cb.CMD       <= data2duv.CMD;
    vif.inp_dr_cb.CIN       <= data2duv.CIN; 
  endtask

endclass
