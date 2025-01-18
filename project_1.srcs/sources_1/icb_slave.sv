`timescale 1ns/1ps

module icb_slave (
    icb_bus.slave           icb,

    // with wfifo
    input  logic            wfifo_full,
    input  logic            wfifo_empty,

    // with rfifo
    input  logic            rfifo_full,
    input  logic            rfifo_empty,
    input  logic [63:0]     rdata,
    output logic            ren,

    // with encrypt/decrypt
    output logic [63:0]     key,
    output logic [63:0]     wdata,
    output logic            wvalid,

    // with APB master
    input  logic [2:0]      apb_state, //0: IDLE; 1: READ_SETUP; 2: READ_ACCESS; 5: WRITE_SETUP; 6: WRITE_ACCESS
    output logic            ctrl
);

// Variable Declaration
//=====================================================================
    logic [63:0]            register_file [0:15]; // Example register file
    logic                   icb_cmd_ready_ff;
    logic                   ren_ff;
    logic [63:0]            key_ff;
    logic [63:0]            wdata_ff;
    logic                   wvalid_ff;

// FSM
//=====================================================================
    typedef enum logic [2:0] {
        IDLE,
        READ_SETUP,
        READ_ACCESS,
        WRITE_SETUP,
        WRITE_ACCESS
    } state_t;

    state_t state, next_state;

// State Transition
    always_ff @(posedge icb.clk, negedge icb.rst_n) begin
        if (!icb.rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

// Next State Logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (icb.icb_cmd_valid && !icb_cmd_ready_ff)
                    next_state = (apb_state == 1 || apb_state == 2) ? READ_SETUP : 
                                 (apb_state == 5 || apb_state == 6) ? WRITE_SETUP : IDLE;
            end
            READ_SETUP: begin
                next_state = READ_ACCESS;
            end
            READ_ACCESS: begin
                next_state = IDLE;
            end
            WRITE_SETUP: begin
                next_state = WRITE_ACCESS;
            end
            WRITE_ACCESS: begin
                next_state = IDLE;
            end
        endcase
    end

// ICB Slave
//=====================================================================
    assign icb.icb_rsp_err = 1'b0;
    assign icb.icb_rsp_valid = (state == READ_ACCESS || state == WRITE_ACCESS);
    assign icb.icb_rsp_rdata = (state == READ_ACCESS) ? register_file[icb.icb_cmd_addr[3:0]] : 64'h0000_0000_0000_0000;

    always_ff @(posedge icb.clk, negedge icb.rst_n) begin
        if (!icb.rst_n)
            icb_cmd_ready_ff <= 1'b0;
        else if (icb.icb_cmd_valid)
            icb_cmd_ready_ff <= 1'b1;
        else
            icb_cmd_ready_ff <= 1'b0;
    end

    assign icb.icb_cmd_ready = icb_cmd_ready_ff;

// Output
//=====================================================================
    always_ff @(posedge icb.clk, negedge icb.rst_n) begin
        if (!icb.rst_n) begin
            ren_ff <= 1'b0;
            key_ff <= 64'h0000_0000_0000_0000;
            wdata_ff <= 64'h0000_0000_0000_0000;
            wvalid_ff <= 1'b0;
        end else begin
            case (state)
                READ_SETUP: begin
                    ren_ff <= 1'b1;
                end
                READ_ACCESS: begin
                    ren_ff <= 1'b0;
                end
                WRITE_SETUP: begin
                    wdata_ff <= icb.icb_cmd_wdata;
                    wvalid_ff <= 1'b1;
                end
                WRITE_ACCESS: begin
                    wvalid_ff <= 1'b0;
                end
                default: begin
                    ren_ff <= 1'b0;
                    wvalid_ff <= 1'b0;
                end
            endcase
        end
    end

    assign ren = ren_ff;
    assign key = key_ff;
    assign wdata = wdata_ff;
    assign wvalid = wvalid_ff;
    assign ctrl = (state != IDLE);

endmodule