class apb_scoreboard;

    // BUILD
    //=============================================================
    function new();
    endfunction

    // FUNC
    //=============================================================
    task automatic compare_data(apb_trans actual, apb_trans expected);
        if (actual.rdata !== expected.rdata) begin
            $display("Mismatch! Actual: %h, Expected: %h", actual.rdata, expected.rdata);
        end else begin
            $display("Match! Data: %h", actual.rdata);
        end
    endtask
endclass // apb_scoreboard