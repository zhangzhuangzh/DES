//===================================================================== 
/// Description: 
// the interface of apb
// Designer : sjl_519021910940@sjtu.edu.cn
// ==================================================================== 

/*
This is only the basic interface, you may change it by your own.
But don't change this signal discription.
*/
interface apb_bus(input logic clk,input logic rst_n);
    logic pwrite;
    logic psel;
    logic [31:0] paddr;
    logic [31:0] pwdata;
    logic penable;

    logic [31:0] prdata;
    logic pready;

    clocking sla_cb @(posedge clk);
        output prdata,pready;
        input pwrite,psel,paddr,pwdata,penable;
    endclocking
    
    modport slave(input rst_n,
    clocking sla_cb);
    modport master(output pwrite,psel,paddr,pwdata,penable,
    input prdata,pready,clk,rst_n);
endinterface:apb_bus //apb    