class icb_golden_model;

    // BUILD
    //=============================================================
    function new();
    endfunction

    // FUNC
    //=============================================================
    function icb_trans get_expected(icb_trans input_trans);
        icb_trans expected_trans = new();
        // Model the expected behavior here
        expected_trans.wdata = input_trans.wdata; // Example
        return expected_trans;
    endfunction
endclass // icb_golden_model