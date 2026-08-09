class alu_test extends uvm_test;
    `uvm_component_utils(alu_test)

    alu_env    env;
    alu_config cfg;
    alu_seq    seq;
    alu_timing_seq seq_t;
    alu_timing_seq2 seq_t2;

    // Constructor
    function new(string name="alu_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction
    //build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = alu_env::type_id::create("env", this);
        cfg = alu_config::type_id::create("cfg");
        if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", cfg.vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not found in uvm_config_db!")
        end 
        cfg.input_agent_is_active  = UVM_ACTIVE;
        cfg.output_agent_is_active = UVM_PASSIVE;
        uvm_config_db#(alu_config)::set(this, "*", "cfg", cfg);
    endfunction
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    // run phase
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this); // Pass handle of current component
        seq = alu_seq::type_id::create("seq");
        seq_t=alu_timing_seq::type_id::create("seq_t");
        seq_t2=alu_timing_seq2::type_id::create("seq_t2");
        `uvm_info("ALU_TEST", "Starting Directed-Random Opcode Sweep Sequence...", UVM_LOW)
        seq.start(env.in_agnt_h.seqr);
        seq_t.start(env.in_agnt_h.seqr);
        seq_t2.start(env.in_agnt_h.seqr);
        #30;
        `uvm_info("ALU_TEST", "Opcode Sweep Finished Successfully!", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
