`timescale 1ns/1ps

module dut_top (
    // input bus
    icb_bus.slave  icb_bus,

    // output bus
    apb_bus.master apb_bus_0,
    apb_bus.master apb_bus_1,
    apb_bus.master apb_bus_2,
    apb_bus.master apb_bus_3
);

    logic           wfifo_full;
    logic           wfifo_wen;
    logic [63:0]    wfifo_wdata;
    logic           wfifo_empty;
    logic           wfifo_ren;
    logic [31:0]    wfifo_rdata;
    
    logic           rfifo_full;
    logic           rfifo_wen;
    logic [63:0]    rfifo_wdata;
    logic           rfifo_empty;
    logic           rfifo_ren;
    logic [63:0]    rfifo_rdata;

    // Internal signals for encryption and decryption modules
    logic [63:0]    encrypt_data_internal;
    logic           encrypt_valid_internal;

    logic [63:0]    decrypt_data_internal;
    logic           decrypt_valid_internal;

    logic           ctrl;
    logic [63:0]    key;
    logic [2:0]     apb_state;

    // 将内部信号连接到顶层信号
    logic [63:0]    icb_decrypt_data;
    logic           icb_decrypt_valid;
    logic [63:0]    apb_encrypt_data;
    logic           apb_encrypt_valid;
    logic encrypt_data;
    logic encrypt_valid;
    logic decrypt_data;
    logic decrypt_valid;

    assign encrypt_data = apb_encrypt_data;
    assign encrypt_valid = apb_encrypt_valid;
    assign decrypt_data = icb_decrypt_data;
    assign decrypt_valid = icb_decrypt_valid;

    // icb module
    icb_slave i_icb_slave(
        .icb(           icb_bus         ),
    
        .wfifo_full(    wfifo_full      ),
        .wfifo_empty(   wfifo_empty     ),

        .rfifo_full(    rfifo_full      ),
        .rfifo_empty(   rfifo_empty     ),
        .rdata(         rfifo_rdata     ),
        .ren(           rfifo_ren       ),

        .key(           key             ),
        .wdata(         icb_decrypt_data), // 使用内部信号
        .wvalid(        icb_decrypt_valid), // 使用内部信号

        .apb_state(     apb_state       ),
        .ctrl(          ctrl            )
    );

    // apb module
    apb_master i_apb_master (
        .apb0(          apb_bus_0       ),
        .apb1(          apb_bus_1       ),
        .apb2(          apb_bus_2       ),
        .apb3(          apb_bus_3       ),

        .wfifo_empty(   wfifo_empty     ),
        .rdata(         wfifo_rdata     ),
        .ren(           wfifo_ren       ),

        .rfifo_full(    rfifo_full      ),

        .wdata(         apb_encrypt_data), // 使用内部信号
        .wvalid(        apb_encrypt_valid), // 使用内部信号

        .ctrl(          ctrl            ),
        .state(         apb_state       )
    );

    // encrypt module
    AES_Encrypt i_encrypt (
        .in(rfifo_rdata),  // 从读FIFO读取数据
        .key(key),      // 使用顶层模块的密钥
        .out(encrypt_data_internal) // 使用内部信号
    );

    // decrypt module
    AES_Decrypt i_decrypt (
        .in(rfifo_rdata),  // 从读FIFO读取数据
        .key(key),      // 使用顶层模块的密钥
        .out(decrypt_data_internal) // 使用内部信号
    );

    asyn_fifo #(
        .DSIZE              ( 64                ),
        .ASIZE              ( 10                )
    ) RFIFO (
        .wclk               ( apb_bus_0.clk     ),
        .wrst_n             ( icb_bus.rst_n     ),
        .wen                ( rfifo_wen         ),
        .wdata              ( rfifo_wdata       ),
        .wfull              ( rfifo_full        ),

        .rclk               ( icb_bus.clk       ),
        .rrst_n             ( icb_bus.rst_n     ),
        .ren                ( rfifo_ren         ),
        .rdata              ( rfifo_rdata       ),
        .rempty             ( rfifo_empty       )
    );

endmodule