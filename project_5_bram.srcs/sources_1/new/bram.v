`timescale 1ns / 1ps

module my_bram#(
    parameter integer BRAM_ADDR_WIDTH=15,
    parameter INIT_FILE = "intput.txt",
    parameter OUT_FILE = "output.txt"
    )
    
    (
    input wire[BRAM_ADDR_WIDTH-1:0] BRAM_ADDR,
    input wire BRAM_CLK,
    input wire [31:0] BRAM_WRDATA,
    output reg [31:0] BRAM_RDDATA,
    input wire BRAM_EN,
    input wire BRAM_RST,
    input wire [3:0] BRAM_WE,
    input wire done
    );
    
    reg[31:0] mem[0:8191] ;
    wire [BRAM_ADDR_WIDTH-3:0] addr = BRAM_ADDR[BRAM_ADDR_WIDTH-1:2];
    reg[31:0] dout;
    
    initial begin
        if(INIT_FILE != "") $readmemh(INIT_FILE, mem);
        wait(done) $writememh(OUT_FILE, mem);
    end
    
    integer r_count = 0;
    integer w_count = 0;
    integer i = 0;
    
    always @(addr or posedge BRAM_EN or BRAM_WE) begin
        if(BRAM_WE == 0) r_count = 0;
        else w_count = 0;
    end
    
    always @(posedge BRAM_CLK) begin
        if(BRAM_WE == 0) r_count = r_count + 1;
        else w_count = w_count + 1;
    end
    
    always @(posedge BRAM_CLK) begin        
        if(!BRAM_RST) begin
            if(BRAM_EN) begin
                if(BRAM_WE != 4'b0 && w_count == 1) begin
                    for(i =0; i < 4; i = i+1) begin
                        if(BRAM_WE[i]) mem[addr][8*i +:8] <= BRAM_WRDATA[8*i +: 8];
                    end
                end
                if(r_count == 2 && BRAM_WE == 4'b0) begin
                    BRAM_RDDATA <= mem[addr];
                end
            end
        end else begin
            BRAM_RDDATA <= 0;
            r_count <= 0;
            w_count <= 0;
        end 
    end
    
endmodule