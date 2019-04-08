`timescale 1ns / 1ps

module bramTB();
    
    parameter integer BRAM_ADDR_WIDTH = 15;
    reg[BRAM_ADDR_WIDTH-1:0] BRAM_ADDR = 0;
    reg clk = 1;
    wire[31:0] r2w_brams; 
    reg[31:0] first_in = 0;
    wire[31:0] second_out; 
    reg first_en = 0, second_en = 0 ;
    reg first_rst = 0, second_rst = 0 ;
    reg[3:0] first_we = 4'b0000;
    reg[3:0] second_we = 4'b1111;
    reg done = 0;
    
    integer counter = 0;
    integer i = 0;
    
    my_bram#(BRAM_ADDR_WIDTH,"input.txt","") BRAM_First(
        .BRAM_ADDR(BRAM_ADDR), .BRAM_CLK(clk), .BRAM_WRDATA(first_in), .BRAM_RDDATA(r2w_brams),
        .BRAM_EN(first_en), .BRAM_RST(first_rst), .BRAM_WE(first_we), .done(done)
    );

    my_bram#(BRAM_ADDR_WIDTH,"","output.txt") BRAM_Second(
        .BRAM_ADDR(BRAM_ADDR), .BRAM_CLK(clk), .BRAM_WRDATA(r2w_brams), .BRAM_RDDATA(second_out),
        .BRAM_EN(second_en), .BRAM_RST(second_rst), .BRAM_WE(second_we), .done(done)
    );    
    
    initial begin
        @(posedge clk)
            first_en = 1;
            second_en = 1;
        for(i = 0 ; i < 2**(BRAM_ADDR_WIDTH-2) ; i = i + 1) begin
            counter = 0 ;
            BRAM_ADDR = 4 * i ;
            wait(counter == 2) second_we = 4'b1111;
            wait(counter == 3) second_we = 4'b0000;
            wait(counter == 6) ;
        end
            #1 done = 1;
            second_en = 1 ;
            second_we = 4'b0000;
            for(i = 0 ; i < 2**(BRAM_ADDR_WIDTH-2) ; i = i + 1) begin
                counter = 0 ;
                BRAM_ADDR = 4 * i ;
                wait(counter == 2);
            end
    end
    
    always #5 clk = ~clk;
    
    always @(posedge clk) begin
        counter = counter + 1;
    end
    
endmodule