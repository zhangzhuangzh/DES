//=====================================================================
// Description:
// This file realize APB Master interfaces and decoder
// Designer : lynnxie@sjtu.edu.cn
// Revision History
// V0 date:2024/10/31 Initial version, lynnxie@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

module apb_master (
    apb_bus.master      apb0,
    apb_bus.master      apb1,
    apb_bus.master      apb2,
    apb_bus.master      apb3,

    // with wfifo
    input  logic        wfifo_empty,
    input  logic [31:0] rdata,
    output logic        ren,

    // with rfifo
    input  logic        rfifo_full,
    
    // with encrypt
    output logic [63:0] wdata,
    output logic        wvalid,

    // with ICB slave
    input  logic        ctrl,
    output logic [2:0]  state
);
// Variable Declaration
//=====================================================================

// Output
//=====================================================================
    assign ren = 1'b0;
    assign wdata = 64'h0000_0000_0000_0000;
    assign wvalid = 1'b0;
    assign state = 3'b000;

// APB Master
//=====================================================================
    apb #(
        .ID(        0               )
    ) i_apb0 (
        .apb(       apb0            )
    );

    apb #(
        .ID(        1               )
    ) i_apb1 (
        .apb(       apb1            )
    );
    
    apb #(
        .ID(        2               )
    ) i_apb2 (
        .apb(       apb2            )
    );

    apb #(
        .ID(        3               )
    ) i_apb3 (
        .apb(       apb3            )
    );
endmodule