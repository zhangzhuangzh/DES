//=====================================================================
// Description:
// The interface of ICB
// Designer: sjl_519021910940@sjtu.edu.cn
// Revision History
// V0 date: 2024/10/23  Initial version sjl_519021910940@sjtu.edu.cn
// V1 date: 2024/10/28  Add clocking blocks lynnxie@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

/*
This is only the basic interface, you may change it by your own.
But don't change this signal discription.
*/
interface icb_bus(
    input logic clk,
    input logic rst_n
);
// Signal Definitions
// =======================================
    // command channel
    logic           icb_cmd_valid;
    logic           icb_cmd_ready;
    logic [31:0]    icb_cmd_addr;
    logic           icb_cmd_read;
    logic [63:0]    icb_cmd_wdata;
    logic [7:0]     icb_cmd_wmask;

    // response channel
    logic           icb_rsp_valid;
    logic           icb_rsp_ready;
    logic [63:0]    icb_rsp_rdata;
    logic           icb_rsp_err;

// added by xl
// Clocking blocks
// =======================================
    clocking mst_cb @(posedge clk);
        default input #0.25 output #0.25;
        input  icb_cmd_ready;
        output icb_cmd_valid;
        output icb_cmd_addr;
        output icb_cmd_read;
        output icb_cmd_wdata;
        output icb_cmd_wmask;

        output icb_rsp_ready;
        input  icb_rsp_valid;
        input  icb_rsp_rdata;
        input  icb_rsp_err;
    endclocking

// Mod ports
// =======================================
    modport slave (
        input  clk,
        input  rst_n,

        output icb_cmd_ready,
        input  icb_cmd_valid,
        input  icb_cmd_addr,
        input  icb_cmd_read,
        input  icb_cmd_wdata,
        input  icb_cmd_wmask,

        input  icb_rsp_ready,
        output icb_rsp_valid,
        output icb_rsp_rdata,
        output icb_rsp_err
    );

    modport master (
        input    clk,
        input    rst_n,

        input    icb_cmd_ready,

        clocking mst_cb
    );
    
    modport others (
        input    clk,
        input    rst_n,
        
        input  icb_cmd_ready,
        input  icb_cmd_valid,
        input  icb_cmd_addr,
        input  icb_cmd_read,
        input  icb_cmd_wdata,
        input  icb_cmd_wmask,

        input  icb_rsp_ready,
        input  icb_rsp_valid,
        input  icb_rsp_rdata,
        input  icb_rsp_err
    );
endinterface //icb_bus