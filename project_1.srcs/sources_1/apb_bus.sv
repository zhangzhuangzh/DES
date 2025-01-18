//=====================================================================
// Description:
// The interface of APB
// Designer: sjl_519021910940@sjtu.edu.cn
// Revision History
// V0 date: 2024/10/23  Initial version sjl_519021910940@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

/*
This is only the basic interface, you may change it by your own.
But don't change this signal discription.
*/
interface apb_bus(
    input logic clk,
    input logic rst_n
);
// Signal Definitions
// =======================================
    logic           pready;
    logic           psel;
    logic           penable;
    logic           pwrite;
    logic [31:0]    paddr;
    logic [31:0]    pwdata;
    logic [31:0]    prdata;

// Mod ports
// =======================================
    modport slave (
        input    clk,
        input    rst_n,

        output   pready,
        input    psel,
        input    penable,
        input    pwrite,
        input    paddr,
        input    pwdata,
        output   prdata
    );

    modport master (
        input  clk,
        input  rst_n,

        input  pready,
        output psel,
        output penable,
        output pwrite,
        output paddr,
        output pwdata,
        input  prdata
    );
endinterface //apb_bus