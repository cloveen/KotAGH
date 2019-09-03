`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2019 10:57:20
// Design Name: 
// Module Name: draw_rect
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



`define M_DRAW_RECT(NAME_IN, NAME_OUT, X, Y, ROM, RECT_WIDTH, RECT_HEIGHT)    \
    wire [11:0] addr_img_``NAME_OUT;   \
    wire [11:0] rgb_pixel_``NAME_OUT;  \
    ``ROM texture_``NAME_OUT(  \
       .clk(pclk),  \
       .address(addr_img_``NAME_OUT),  // address = {addry[5:0], addrx[5:0]}   \
       .rgb(rgb_pixel_``NAME_OUT)  \
       );   \
        \
    `VGA_BUS_WIRE(``NAME_IN, ``NAME_OUT); \
       \
    draw_rect #(``RECT_WIDTH, ``RECT_HEIGHT) draw_rect_``NAME_OUT(   \
    `VGA_BUS(``NAME_IN, ``NAME_OUT), \
    .xpos(``X),   \
    .ypos(``Y),   \
    .rgb_pixel(rgb_pixel_``NAME_OUT),   \
    .pixel_addr(addr_img_``NAME_OUT)   \
  )



module draw_rect(
    input wire[10:0] hcount_in,
    input wire hsync_in,
    input wire hblnk_in,
    input wire [10:0] vcount_in,
    input wire vsync_in,
    input wire vblnk_in,
    input wire [11:0] rgb_in,
    input wire pclk,
    input wire rst,

    input wire [11:0] rgb_pixel,
    
    output reg [10:0] hcount_out,
    output reg hsync_out,
    output reg hblnk_out,
    output reg [10:0] vcount_out,
    output reg vsync_out,
    output reg vblnk_out,
    input wire [11:0] xpos,
    input wire [11:0] ypos,
    output reg [11:0] rgb_out,
    output reg [11:0] pixel_addr
    );


parameter RECT_WIDTH= 'd64;
parameter RECT_HEIGHT = 'd64;
//localparam RECT_RGB = 12'he_8_d;

reg [10:0] hcount_out_nxt, hcount_out_buff;
reg hsync_out_nxt, hsync_out_buff;
reg hblnk_out_nxt, hblnk_out_buff;
reg [10:0] vcount_out_nxt, vcount_out_buff;
reg vsync_out_nxt, vsync_out_buff;
reg vblnk_out_nxt, vblnk_out_buff;
reg [11:0] rgb_out_nxt, rgb_out_buff, rgb_in_buff;
reg [10:0] addr_x, addr_y;

always @(posedge pclk, posedge rst)
    begin 
      if (rst)
           begin
               hsync_out <= 0;
               vsync_out <= 0;
               hblnk_out <= 0;
               vblnk_out <= 0;
               
               hcount_out <= 0;
               vcount_out <= 0;
               rgb_out <= 0;
               
               hcount_out_buff <= 0;
               hsync_out_buff <= 0;
               hblnk_out_buff <= 0;
               vcount_out_buff <= 0;
               vsync_out_buff <= 0;
               vblnk_out_buff <= 0;
               rgb_out_buff <= 0;
            end
      else 
            begin  
                hcount_out_buff <= hcount_out_nxt;
                hsync_out_buff <= hsync_out_nxt;
                hblnk_out_buff <= hblnk_out_nxt;
                vcount_out_buff <= vcount_out_nxt;
                vsync_out_buff <= vsync_out_nxt;
                vblnk_out_buff <= vblnk_out_nxt;
                rgb_out_buff <= rgb_out_nxt; 
                           
                rgb_out <= rgb_out_buff;
                vcount_out <= vcount_out_buff;
                vsync_out <= vsync_out_buff;
                vblnk_out <= vblnk_out_buff;                
                hcount_out <= hcount_out_buff;
                hsync_out <= hsync_out_buff;
                hblnk_out <= hblnk_out_buff;  
            end   
    end
         
always @* 
    begin
         vcount_out_nxt = vcount_in;
         vsync_out_nxt = vsync_in;
         vblnk_out_nxt = vblnk_in;
         
         hcount_out_nxt = hcount_in;
         hsync_out_nxt = hsync_in;
         hblnk_out_nxt = hblnk_in;
         rgb_in_buff = rgb_in;
         
         if((rgb_pixel != 12'h0FF)&&(vcount_in <= (ypos + RECT_HEIGHT)) && (vcount_in >= ypos) && (hcount_in <= xpos + RECT_WIDTH) && (hcount_in >= xpos ))
            begin
                rgb_out_nxt = rgb_pixel;
            end
         else 
            begin
             rgb_out_nxt = rgb_in_buff;
            end
     end
     
always @(posedge pclk)
     begin
        addr_y <= vcount_in - ypos;
        addr_x <= hcount_in - xpos;
        pixel_addr <= {addr_y[5:0], addr_x[5:0]};
     end

endmodule
