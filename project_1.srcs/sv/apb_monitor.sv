class apb_monitor;

    // BUILD
    //=============================================================
    mailbox #(apb_trans) drv2mon;

    function new(mailbox #(apb_trans) drv2mon);
        this.drv2mon = drv2mon;
    endfunction

    // CONNECT
    //=============================================================
    local virtual apb_bus.slave positive_channel;

    function void set_intf(
        virtual apb_bus.slave apb
    );
        this.positive_channel = apb;
    endfunction

    // FUNC
    //=============================================================
    task automatic collect_data();
        apb_trans   get_trans;

        // Collect data from the driver
        forever begin
            this.drv2mon.get(get_trans);
            // Process and store the collected data
            // This can include checking the correctness
            // of the data or passing it to the scoreboard
        end
    endtask
endclass // apb_monitor