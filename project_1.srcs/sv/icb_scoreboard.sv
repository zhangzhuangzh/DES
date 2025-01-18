class icb_scoreboard;

    // BUILD
    //=============================================================
    function new();
    endfunction

    // FUNC
    //=============================================================
    task automatic compare_data(icb_trans actual, icb_trans expected);
        if (actual.wdata !== expected.wdata) begin
            $display("Mismatch! Actual: %h, Expected: %h", actual.wdata, expected.wdata);
        end else begin
            $display("Match! Data: %h", actual.wdata);
        end
    endtask
endclass // icb_scoreboard