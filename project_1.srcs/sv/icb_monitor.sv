class icb_monitor;

    // BUILD
    //=============================================================
    mailbox #(icb_trans) drv2mon;

    function new(mailbox #(icb_trans) drv2mon);
        this.drv2mon = drv2mon;
    endfunction

    // CONNECT
    //=============================================================
    local virtual icb_bus.master active_channel;

    function void set_intf(
        virtual icb_bus.master icb
    );
        this.active_channel = icb;
    endfunction

    // FUNC
    //=============================================================
    task automatic collect_data();
        icb_trans   get_trans;

        // Collect data from the driver
        forever begin
            this.drv2mon.get(get_trans);
            // Process and store the collected data
            // This can include checking the correctness
            // of the data or passing it to the scoreboard
        end
    endtask
endclass // icb_monitor