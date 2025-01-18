//=====================================================================
// Description:
// This file realize the ICB AGENT, includes data generator, driver and
// monitor.
// Designer : lynnxie@sjtu.edu.cn
// Revision History
// V0 date:2024/11/07 Initial version, lynnxie@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

package icb_agent_pkg;
    import objects_pkg::*;
    
    // Generator: Generate data for driver to transfer
    class icb_generator;

        // BUILD
        //=============================================================
        mailbox #(icb_trans)    gen2drv; // generator need a mailbox to transfer data to driver

        function new(
            mailbox #(icb_trans) gen2drv
        );
            this.gen2drv = gen2drv; // the mailbox will be create in agent
        endfunction //new()

        // FUNC : generate a data for transaction
        // **Optional** The random data generation can be realized here
        //=============================================================
        task automatic data_gen(
            input           read = 1'b1,
            input [7:0]     mask = 8'h00,
            input [63:0]    data = 64'h0000_0000_0000_0000,
            input [31:0]    addr = 32'h2000_0000
        );
            icb_trans   tran_data;
            tran_data = new();
            
            // set tran data according to input
            tran_data.read = read;
            tran_data.mask = mask;
            tran_data.wdata = data;
            tran_data.addr = addr;

            // send the generated data to driver
            this.gen2drv.put(tran_data);
        endtask
    endclass //icb_generator

    // Driver: Converts the received packets to the format of the ICB protocol
    class icb_driver;

        // BUILD
        //=============================================================
        mailbox #(icb_trans)    gen2drv; // receive the data from generator

        function new(
            mailbox #(icb_trans)    gen2drv
        );
            this.gen2drv = gen2drv;
        endfunction //new()
        
        // CONNECT
        //=============================================================
        local virtual icb_bus.master active_channel;

        function void set_intf(
            virtual icb_bus.master icb
        );
            this.active_channel = icb;

            // port initialization to avoid 'x' state in dut
            this.active_channel.mst_cb.icb_cmd_valid <= 1'b0;
            this.active_channel.mst_cb.icb_cmd_read <= 1'b0;
            this.active_channel.mst_cb.icb_cmd_addr <= 32'h0000_0000;
            this.active_channel.mst_cb.icb_cmd_wdata <= 64'h0000_0000_0000_0000;
            this.active_channel.mst_cb.icb_cmd_wmask <= 8'h00;
            this.active_channel.mst_cb.icb_rsp_ready <= 1'b1;
        endfunction

        // FUNC : data transfer
        //=============================================================
        task automatic data_trans();
            icb_trans   get_trans;

            // get the input data and address from mailbox
            this.gen2drv.get(get_trans);

            // setup the transaction
            @(this.active_channel.mst_cb)
            this.active_channel.mst_cb.icb_cmd_valid <= 1'b1;
            this.active_channel.mst_cb.icb_cmd_read <= get_trans.read;
            this.active_channel.mst_cb.icb_cmd_wmask <= get_trans.mask;
            this.active_channel.mst_cb.icb_cmd_wdata <= get_trans.wdata;
            this.active_channel.mst_cb.icb_cmd_addr <= get_trans.addr;
            this.active_channel.mst_cb.icb_rsp_ready <= 1'b1;

            // wait until the handshake finished
            while(!this.active_channel.mst_cb.icb_cmd_ready) begin
                @(this.active_channel.mst_cb);
            end

            // end the transaction
            @(this.active_channel.mst_cb)
            this.active_channel.mst_cb.icb_cmd_valid <= 1'b0;
        endtask //automatic
    endclass //icb_driver

    // **Optional** 
    // Monitor: Collect ICB data and convert it to data package for
    //          scoreboard to compare result.
    class icb_monitor;

        // BUILD
        //=============================================================
        // ...

        // CONNECT
        //=============================================================
        // ...

        // FUNC
        //=============================================================
        // ...
    endclass //icb_monitor

    // Agent: The top class that connects generator, driver and monitor
    class icb_agent;

    // BUILD
    //=============================================================
    mailbox #(icb_trans)    gen2drv;
    mailbox #(icb_trans)    drv2mon;
    icb_generator           icb_generator;
    icb_driver              icb_driver;
    icb_monitor             icb_monitor;
    icb_scoreboard          icb_scoreboard;
    icb_golden_model        icb_golden_model;

    function new();
        this.gen2drv = new();
        this.drv2mon = new();
        this.icb_generator = new(this.gen2drv);
        this.icb_driver = new(this.gen2drv);
        this.icb_monitor = new(this.drv2mon);
        this.icb_scoreboard = new();
        this.icb_golden_model = new();
    endfunction //new()

    // CONNECT
    //=============================================================
    function void set_intf(
        virtual icb_bus icb
    );
        // connect to icb_driver
        this.icb_driver.set_intf(icb);
        this.icb_monitor.set_intf(icb);
    endfunction //automatic

    // FUN : single data tran
    //=============================================================
    task automatic single_tran(
        input           read = 1'b1,
        input [7:0]     mask = 8'h00,
        input [63:0]    data = 64'h0000_0000_0000_0000,
        input [31:0]    addr = 32'h2000_0000
    );
        // generate data
        this.icb_generator.data_gen(read, mask, data, addr);

        // drive data
        this.icb_driver.data_trans();

        // collect data
        this.icb_monitor.collect_data();

        // compare data
        icb_trans actual = new();
        icb_trans expected = this.icb_golden_model.get_expected(actual);
        this.icb_scoreboard.compare_data(actual, expected);
    endtask //automatic
endclass // icb_agent
endpackage


