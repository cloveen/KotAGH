// File: vga_timing.v
// This is the vga timing design for EE178 Lab #4.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps
/*
`define HOR_TOT_TIME 1056 //px
`define HOR_ADDR_TIME 800
`define HOR_FRONT_PORCH 40
         
`define HOR_BLANK_START 800
`define HOR_BLANK_TIME 256
         
`define HOR_SYNC_START 840
`define HOR_SYNC_TIME 128
//---------------------------
`define VER_TOT_TIME  628
`define VER_ADDR_TIME 600
`define VER_FRONT_PORCH 1
         
`define VER_BLANK_START 600
`define VER_BLANK_TIME 28
         
`define VER_SYNC_START 601
`define VER_SYNC_TIME 4
*/
// Declare the module and its ports. This is
// using Verilog-2001 syntax.

module vga_timing (
 input wire pclk,      //pixel clock rate
  output reg [10:0] vcount,
  output reg vsync,        //vertical synchronization signal
  output reg vblnk,        // out of the 'active' screen
  output reg [10:0] hcount,
  output reg hsync,        //horizontal synchronization signal
  output reg hblnk         // out of the 'active' screen
 );

initial hcount = 0;
initial vcount = 0;

always @(posedge pclk)
 begin
    hcount <= hcount + 1;
    if ((799) <= hcount && hcount < (1055))
    begin
        hblnk <= 1'b1;             
        if ((839) <= hcount && hcount < (967))
            hsync <= 1'b1;           
        else
            hsync <= 1'b0;           
    end
    else if (hcount == (1055)) 
    begin      
        hcount <= 0;
        hblnk <= 1'b0;
    end
    
    if (hcount == (1055))        
    begin
        vcount <= vcount + 1;
        if ((599) <= vcount && vcount < (627))
        begin
            vblnk <= 1'b1;             
            if ((600) <= vcount && vcount < (604))
                vsync <= 1'b1;           
            else
                vsync <= 1'b0;          
        end
        else if (vcount == (627))
        begin
            vcount <= 0;
            vblnk <= 1'b0;
        end
    end
 end

endmodule
