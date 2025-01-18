
module asyn_fifo#(
	parameter  DSIZE=64,
	parameter  ASIZE=10
)(
    rdata, 
    wfull, 
    rempty, 
    wdata, 
    wen, 
    wclk, 
    wrst_n,
    ren, 
    rclk, 
    rrst_n);
//parameter DSIZE = 16; parameter ASIZE = 10;
output logic  [DSIZE-1:0]   rdata;
output logic                wfull;
output logic                rempty;
input  logic [DSIZE-1:0]    wdata;
input  logic                wen, wclk, wrst_n;
input  logic                ren, rclk, rrst_n;

logic [ASIZE:0]             wptr, rptr, wq2_rptr, rq2_wptr, wq1_rptr,rq1_wptr;
logic [ASIZE:0]             rbin, wbin;
logic [DSIZE-1:0]           mem[0:(1<<ASIZE)-1];
logic [ASIZE-1:0]           waddr, raddr;
logic [ASIZE:0]             rgraynext, rbinnext,wgraynext,wbinnext;
logic                       rempty_val,wfull_val;

//-RAM
assign rdata=mem[raddr];

always_ff @(posedge wclk)begin
    if(wen && !wfull) 
        mem[waddr] <= wdata;
end

//-同步rptr指针
always_ff @(posedge wclk or negedge wrst_n)begin
    if(!wrst_n) 
        {wq2_rptr,wq1_rptr} <= 0;
    else 
        {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};
end

//--同步wptr指针
always_ff @(posedge rclk or negedge rrst_n)begin
    if(!rrst_n) 
        {rq2_wptr,rq1_wptr} <= 0;
    else 
        {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};
end


always_ff @(posedge rclk or negedge rrst_n)begin // GRAYSTYLE2 pointer
    if(!rrst_n) 
        {rbin, rptr} <= 0;
    else 
        {rbin, rptr} <= {rbinnext, rgraynext};
end

// Memory read-address pointer (okay to use binary to address memory)
assign raddr     = rbin[ASIZE-1:0];
assign rbinnext  = rbin + (ren & ~rempty);
assign rgraynext = (rbinnext>>1) ^ rbinnext;

// FIFO empty when the next rptr == synchronized wptr or on reset
assign rempty_val = (rgraynext == rq2_wptr);

always_ff @(posedge rclk or negedge rrst_n)begin
    if(!rrst_n) 
        rempty <= 1'b1;
    else 
        rempty <= rempty_val;
end

//--wfull产生与waddr产生
always_ff @(posedge wclk or negedge wrst_n)begin // GRAYSTYLE2 pointer
    if(!wrst_n) 
        {wbin, wptr} <= 0;
    else 
        {wbin, wptr} <= {wbinnext, wgraynext};
end

// Memory write-address pointer (okay to use binary to address memory)
assign waddr     = wbin[ASIZE-1:0];
assign wbinnext  = wbin + (wen & ~wfull);
assign wgraynext = (wbinnext>>1) ^ wbinnext;
assign wfull_val = (wgraynext=={~wq2_rptr[ASIZE:ASIZE-1], wq2_rptr[ASIZE-2:0]}); //:ASIZE-1]

always_ff @(posedge wclk or negedge wrst_n)begin
    if(!wrst_n) 
        wfull <= 1'b0;
    else 
        wfull <= wfull_val;
end


endmodule