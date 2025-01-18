class apb_golden_model;

    // BUILD
    //=============================================================
    function new();
    endfunction

    // FUNC
    //=============================================================
    function apb_trans get_expected(apb_trans input_trans);
        apb_trans expected_trans = new();
        // Model the expected behavior here
        expected_trans.rdata = input_trans.rdata; // Example
        return expected_trans;
    endfunction
endclass // apb_golden_model