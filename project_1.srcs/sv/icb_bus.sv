//===================================================================== 
/// Description: 
// the interface of icb
// Designer : sjl_519021910940@sjtu.edu.cn
// ==================================================================== 

/*
This is only the basic interface, you may change it by your own.
But don't change this signal discription.
*/
interface icb_bus(input logic clk,input logic rst_n);
    //command channel
    logic icb_cmd_valid;
    logic icb_cmd_ready;
    logic [31:0] icb_cmd_addr;
    logic icb_cmd_read;
    logic [63:0] icb_cmd_wdata;
    logic [7:0] icb_cmd_wmask;

    //response channel
    logic icb_rsp_valid;
    logic icb_rsp_ready;
    logic [63:0] icb_rsp_rdata;
    logic icb_rsp_err;

    clocking mst_cb @(posedge clk);
        output icb_cmd_valid, icb_cmd_addr, icb_cmd_read, icb_cmd_wdata, icb_cmd_wmask, icb_rsp_ready;
        input icb_cmd_ready, icb_rsp_valid, icb_rsp_rdata, icb_rsp_err;
    endclocking

    modport slave(input icb_cmd_valid, icb_cmd_addr, icb_cmd_read, icb_cmd_wdata, icb_cmd_wmask, icb_rsp_ready, clk, rst_n,
    output icb_cmd_ready, icb_rsp_valid, icb_rsp_rdata, icb_rsp_err);
    modport master(clocking mst_cb,
    input rst_n);
endinterface:icb_bus //icb    