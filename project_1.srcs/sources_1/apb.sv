//=====================================================================
// Description:
// This file realize APB Master
// Designer : lynnxie@sjtu.edu.cn
// Revision History
// V0 date:2024/11/05 Initial version, lynnxie@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

module apb # (
    parameter ID = 0
)(
    apb_bus.master      apb
);
// Variable Declaration
//=====================================================================
    
// APB Master
//=====================================================================
    assign apb.psel = 1'b0;
    assign apb.penable = 1'b0;
    assign apb.pwrite = 1'b0;
    assign apb.pwdata = 32'h0000_0000;
    assign apb.paddr = 32'h0000_0000;
endmodule