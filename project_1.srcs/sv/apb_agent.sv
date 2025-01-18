//=====================================================================
// Description:
// This file realize the APB AGENT, includes data generator, driver and
// monitor.
// Designer : lynnxie@sjtu.edu.cn
// Revision History
// V0 date:2024/11/11 Initial version, lynnxie@sjtu.edu.cn
//=====================================================================


`timescale 1ns/1ps

package apb_agent_pkg;
    import objects_pkg::*;

    // Generator: Generate data for driver to transfer
    class apb_generator;
        // BUILD
        //=============================================================
        mailbox #(apb_trans)    gen2drv; // generator need a mailbox to transfer data to driver

        function new(
            mailbox #(apb_trans) gen2drv
        );
            this.gen2drv = gen2drv; // the mailbox will be create in agent
        endfunction //new()

        // FUNC
        //=============================================================
        // **Optional** The random data generation can be realized here
        //=============================================================
        task automatic data_gen(
            input [31:0]    rdata = 32'h2000_0000
        );
            apb_trans   tran_data;
            tran_data = new();
            
            // set tran data according to input
            tran_data.rdata = rdata;

            // send the generated data to driver
            this.gen2drv.put(tran_data);
        endtask
    endclass //apb_generator

    // Driver: Converts the received packets to the format of the APB protocol
    class apb_driver;

        // BUILD
        //=============================================================
        mailbox #(apb_trans)    gen2drv; // receive the data from generator

        function new(
            mailbox #(apb_trans)    gen2drv
        );
            this.gen2drv = gen2drv;
        endfunction //new()
        
        // CONNECT
        //=============================================================
        local virtual apb_bus.slave positive_channel;

        function void set_intf(
            virtual apb_bus.slave apb
        );
            this.positive_channel = apb;

            // port initialization to avoid 'x' state in dut
            this.positive_channel.sla_cb.prdata <= 32'h0000_0000;
            this.positive_channel.sla_cb.pready <= 1'b1;
        endfunction

        // FUNC
        //=============================================================
        task automatic data_trans();
            apb_trans   get_trans;

            // setup the transaction
            @(this.positive_channel.sla_cb)
            this.positive_channel.sla_cb.pready <= 1'b1;
            if (!this.positive_channel.sla_cb.pwrite && this.positive_channel.sla_cb.psel && !this.positive_channel.sla_cb.penable) begin
                this.gen2drv.peek(get_trans);
                this.positive_channel.sla_cb.prdata <= get_trans.rdata;
                this.gen2drv.get(get_trans);
            end
            else begin
                this.positive_channel.sla_cb.prdata <= 32'h0000_0000;
            end

        endtask //automatic
    endclass //apb_driver

    // **Optional** 
    // Monitor: Collect APB data and convert it to data package for
    //          scoreboard to compare result.
    class apb_monitor;

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
    class apb_agent;

    // BUILD
    //=============================================================
    mailbox #(apb_trans)    gen2drv;
    mailbox #(apb_trans)    drv2mon;
    apb_generator           apb_generator;
    apb_driver              apb_driver;
    apb_monitor             apb_monitor;
    apb_scoreboard          apb_scoreboard;
    apb_golden_model        apb_golden_model;

    function new();
        this.gen2drv = new();
        this.drv2mon = new();
        this.apb_generator = new(this.gen2drv);
        this.apb_driver = new(this.gen2drv);
        this.apb_monitor = new(this.drv2mon);
        this.apb_scoreboard = new();
        this.apb_golden_model = new();
    endfunction //new()

    // CONNECT
    //=============================================================
    function void set_intf(
        virtual apb_bus apb
    );
        // connect to apb_driver
        this.apb_driver.set_intf(apb);
        this.apb_monitor.set_intf(apb);
    endfunction //automatic

    // FUN : single data tran
    //=============================================================
    task automatic single_tran(
        input [31:0]    rdata = 32'h2000_0000
    );
        // generate data
        this.apb_generator.data_gen(rdata);

        // drive data
        this.apb_driver.data_trans();

        // collect data
        this.apb_monitor.collect_data();

        // compare data
        apb_trans actual = new();
        apb_trans expected = this.apb_golden_model.get_expected(actual);
        this.apb_scoreboard.compare_data(actual, expected);
    endtask //automatic
endclass // apb_agent
endpackage
