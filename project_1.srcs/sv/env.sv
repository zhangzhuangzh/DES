//=====================================================================
// Description:
// This file build the environment for the whole test environment
// Designer : lynnxie@sjtu.edu.cn
// Revision History
// V0 date:2024/11/11 Initial version, lynnxie@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

// ATTENTION: mailbox only records handler, therefore, scoreboard and read/write should be parallel, 
//            or some address/data will be miss, especially for continuous read.

package env;
    
    import icb_agent_pkg::*;
    import apb_agent_pkg::*;
    import objects_pkg::*;

    class env_ctrl;

        // FUNC : grab data
        //=============================================================
        // the new function is to build the class object's subordinates
        class rand_a;
            rand bit one_bit;
            rand bit [7:0] eight_bit;
            rand bit [31:0] addr;
            rand bit [63:0] sixty_four_bit;
            randc bit [5:0] apb_sel_low;
            randc bit [5:0] apb_sel_high;
            rand bit [31:0] data0;
            rand bit [31:0] data1;
            rand bit [31:0] data2;
            rand bit [31:0] data3;

            constraint a_c {
            apb_sel_low  == 6'b100100 || 6'b100111 || 6'b100001 || 6'b101101;
            apb_sel_high == 6'b010101 || 6'b010110 || 6'b010000 || 6'b011100;
            sixty_four_bit [7:2]   == apb_sel_low ;
            sixty_four_bit [39:34] == apb_sel_high;
            addr%4==0;
            if(one_bit)
                addr != 32'h2000_0010;
            else
                addr == 32'h2000_0010;
            addr >= 32'h2000_0000;
            addr < 32'h2000_0020;}
        endclass

        // first declare subordinates
        // add the apb agents
        icb_agent       icb_agent;
        apb_agent       apb_agent0;
        apb_agent       apb_agent1;
        apb_agent       apb_agent2;
        apb_agent       apb_agent3;

        // new them
        function new();
            this.icb_agent = new();
            this.apb_agent0 = new();
            this.apb_agent1 = new();
            this.apb_agent2 = new();
            this.apb_agent3 = new();
        endfunction //new()

        // CONNECT
        //=============================================================
        // the set_interface function is to connect the interface to itself
        // and then also connect to its subordinates
        // (only if used)
        function void set_intf(
            virtual icb_bus     icb,
            virtual apb_bus     apb0,
            virtual apb_bus     apb1,
            virtual apb_bus     apb2,
            virtual apb_bus     apb3
        );
            // connect to agent
            this.icb_agent.set_intf(icb);
            this.apb_agent0.set_intf(apb0);
            this.apb_agent1.set_intf(apb1);
            this.apb_agent2.set_intf(apb2);
            this.apb_agent3.set_intf(apb3);
        endfunction

        // RUN
        //=============================================================
        // manage your work here : 
        // (1) receive the command from the testbench
        // (2) call its subordinates to work
        task run(string state);
            localparam  CTRL_ADDR = 32'h2000_0000;
            localparam  STAT_ADDR = 32'h2000_0008;
            localparam  WDATA_ADDR = 32'h2000_0010;
            localparam  RDATA_ADDR = 32'h2000_0018;
            localparam  KEY_ADDR = 32'h2000_0020;
            rand_a a;
            a = new();

            case (state)
                "ICB Write": begin
                    $display("=============================================================");
                    $display("[TB- ENV ] Start work : ICB Write !");

                    $display("[TB- ENV ] Write KEY register.");
                    this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0000, KEY_ADDR);

                    $display("[TB- ENV ] Write CTRL register.");
                    this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0001, CTRL_ADDR);
                    
                    $display("[TB- ENV ] Write WDATA register for fifo depth.");
                    this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0000, CTRL_ADDR);
                    for (int i = 0; i < 2048; i = i + 1) begin
                        this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0001, WDATA_ADDR);
                    end

                    $display("[TB- ENV ] Write random address.");
                    for (int i = 0; i < 16; i = i + 1) begin
                        void'(a.randomize());
                        this.icb_agent.single_tran(1'b0, a.eight_bit, a.sixty_four_bit, a.addr);
                    end
                end

                "ICB Read": begin
                    $display("=============================================================");
                    $display("[TB- ENV ] Start work : ICB Read !");

                    $display("[TB- ENV ] Read KEY register.");
                    this.icb_agent.single_tran(1'b1, 8'h00, 64'h0000_0000_0000_0000, KEY_ADDR);

                    $display("[TB- ENV ] Read CTRL register.");
                    this.icb_agent.single_tran(1'b1, 8'h00, 64'h0000_0000_0000_0001, CTRL_ADDR);

                    $display("[TB- ENV ] Read STAT register.");
                    this.icb_agent.single_tran(1'b1, 8'h00, 64'h0000_0000_0000_0001, STAT_ADDR);
                    
                    $display("[TB- ENV ] Read RDATA register for fifo depth.");
                    this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0000, CTRL_ADDR);
                    for (int i = 0; i < 2048; i = i + 1) begin
                        this.icb_agent.single_tran(1'b1, 8'h00, 64'h0000_0000_0000_0001, RDATA_ADDR);
                    end

                    $display("[TB- ENV ] Read random address.");
                    for (int i = 0; i < 16; i = i + 1) begin
                        void'(a.randomize());
                        this.icb_agent.single_tran(1'b1, a.eight_bit, a.sixty_four_bit, a.addr);
                    end
                end

                "Data Flow Exam": begin
                    $display("=============================================================");
                    $display("[TB- ENV ] Start work : Data Flow Exam !");

                    $display("[TB- ENV ] Write KEY register.");
                    this.icb_agent.single_tran(1'b0, 8'h00, 64'h7090_2a51_100c_1396, KEY_ADDR);
                    this.apb_agent0.single_tran(32'h0000_0000);
                    this.apb_agent1.single_tran(32'h0000_0000);
                    this.apb_agent2.single_tran(32'h0000_0000);
                    this.apb_agent3.single_tran(32'h0000_0000);

                    $display("[TB- ENV ] Write CONTROL register.");
                    this.icb_agent.single_tran(1'b0, 8'h00, 64'hffff_ffff_ffff_ffff, CTRL_ADDR);
                    this.apb_agent0.single_tran(32'h0000_0000);
                    this.apb_agent1.single_tran(32'h0000_0000);
                    this.apb_agent2.single_tran(32'h0000_0000);
                    this.apb_agent3.single_tran(32'h0000_0000);

                    for (int i = 0; i < 16; i = i + 1) begin
                        void'(a.randomize());
                        this.icb_agent.single_tran(a.one_bit, a.eight_bit, a.sixty_four_bit, a.addr);
                        this.apb_agent0.single_tran(a.data0);
                        this.apb_agent1.single_tran(a.data1);
                        this.apb_agent2.single_tran(a.data2);
                        this.apb_agent3.single_tran(a.data3);
                    end
                end
                "Time_Run": begin
                    $display("[TB- ENV ] start work : Time_Run !");
                    #99999;
                    $display("[TB- ENV ] =========================================================================================");
                    $display("[TB- ENV ]  _|_|_|_|_|   _|_|_|   _|      _|   _|_|_|_|         _|_|     _|    _|   _|_|_|_|_|  ");
                    $display("[TB- ENV ]      _|         _|     _|_|  _|_|   _|             _|    _|   _|    _|       _|      ");
                    $display("[TB- ENV ]      _|         _|     _|  _|  _|   _|_|_|         _|    _|   _|    _|       _|      ");
                    $display("[TB- ENV ]      _|         _|     _|      _|   _|             _|    _|   _|    _|       _|      ");
                    $display("[TB- ENV ]      _|       _|_|_|   _|      _|   _|_|_|_|         _|_|       _|_|         _|      ");
                    $display("[TB- ENV ] =========================================================================================");
                end
                default: begin
                end
            endcase
        endtask
    endclass //env_ctrl
endpackage