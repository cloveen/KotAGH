`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.04.2019 18:29:30
// Design Name: 
// Module Name: draw_rect_char
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


module draw_rect_char2(
    input [10:0] hcount_in,
    input hsync_in,
    input hblnk_in,
    input [10:0] vcount_in,
    input vsync_in,
    input vblnk_in,
    input [11:0] rgb_in,
    input wire [7:0] char_pixels,
    input wire rst,
    input wire pclk,
    
    output reg [10:0] hcount_out,
    output reg hsync_out,
    output reg hblnk_out,
    output reg [10:0] vcount_out,
    output reg vsync_out,
    output reg vblnk_out,
    output reg [11:0] rgb_out,
    output [7:0] char_xy,
    output [3:0] char_line
    );
    
 
    localparam LETTERS = 12'h4_4_4, BG = 12'he_8_e;
    localparam RECT_X = 650, RECT_Y = 220;
    
      reg [11:0] rgb_nxt, pixel_addr_nxt, x_pos_reg, y_pos_reg;
      reg hsync_delay1, vsync_delay1, hsync_delay2, vsync_delay2;
      reg hblnk_delay1, vblnk_delay1, hblnk_delay2, vblnk_delay2;
      reg [10:0] hcount_delay1, vcount_delay1, hcount_delay2, vcount_delay2;
      reg [11:0] rgb_delay1, rgb_delay2;
      wire [10:0]  hcount_in_rect, vcount_in_rect;
      
      always @*
      begin
      if (vblnk_in || hblnk_in) rgb_nxt = 12'h0_0_0; 
      else 
          begin
             if (vcount_in <= 256 + RECT_Y && vcount_in > RECT_Y && hcount_in <= 128 + RECT_X && hcount_in > RECT_X)
                 begin
                      if (char_pixels[4'b1000-hcount_in_rect[2:0]])
                           rgb_nxt = LETTERS; 
                      else
                          rgb_nxt = BG;
                 end
             else
                  rgb_nxt = rgb_delay2;
          end
      end
      
      
      always @(posedge pclk, posedge rst) 
      begin
          if(rst)
              begin
              hcount_out <= 0;
              vcount_out <= 0;
              vblnk_out <= 0;
              vsync_out <= 0;
              hblnk_out <= 0;
              hsync_out <= 0;
              end
          else
          begin   
          
             hcount_delay1 <= hcount_in;
             hsync_delay1 <= hsync_in;
             hblnk_delay1 <= hblnk_in;
             vcount_delay1 <= vcount_in;
             vsync_delay1 <= vsync_in;
             vblnk_delay1 <= vblnk_in;
             rgb_delay1 <= rgb_in;
             
             hcount_delay2 <= hcount_delay1;
             hsync_delay2 <= hsync_delay1;
             hblnk_delay2 <= hblnk_delay1;
             vcount_delay2 <= vcount_delay1;
             vsync_delay2 <= vsync_delay1;
             vblnk_delay2 <= vblnk_delay1;
             rgb_delay2 <= rgb_delay1;
                
             hcount_out <= hcount_delay2;
             vcount_out <= vcount_delay2;
             vblnk_out <= vblnk_delay2;
             vsync_out <= vsync_delay2;
             hblnk_out <= hblnk_delay2;
             hsync_out <= hsync_delay2;
             
             rgb_out <= rgb_nxt;
             
           end
       end
       
       assign char_xy = {vcount_in_rect[7:4], hcount_in_rect[6:3]};
       assign char_line = vcount_in_rect[3:0];
       
       assign vcount_in_rect = vcount_in -  RECT_Y;
       assign hcount_in_rect = hcount_in -  RECT_X;   
       
endmodule
