`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.03.2019 17:56:47
// Design Name: 
// Module Name: draw_backgroundd
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


module draw_backgroundd(
    input wire pclk,
    input wire rst,
    input [10:0] vcount_in,
    input [10:0] hcount_in,
    input hsync_in,
    input hblnk_in,
    input vsync_in,
    input vblnk_in,
            
    output reg [10:0] vcount_out,
    output reg vsync_out,       
    output reg vblnk_out,       
    output reg [10:0] hcount_out,
    output reg hsync_out,        
    output reg hblnk_out,
    
    output reg [11:0] rgb_out 
);

reg [11:0] rgb_out_nxt;


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
            end
      else 
            begin   
                hcount_out <= hcount_in;
                hsync_out <= hsync_in;
                hblnk_out <= hblnk_in;
                
                vcount_out <= vcount_in;
                vblnk_out <= vblnk_in;
                vsync_out <= vsync_in;
                
                rgb_out <= rgb_out_nxt;
            end   
    end


always @*
    begin
        if (vblnk_in || hblnk_in) rgb_out_nxt = 12'h0_0_0; 
        else
        begin
          // Active display, top edge, make a yellow line.
          if (vcount_in == 0) rgb_out_nxt = 12'hf_f_0;
          // Active display, bottom edge, make a red line.
          else if (vcount_in == 599) rgb_out_nxt = 12'hf_0_0;
          // Active display, left edge, make a green line.
          else if (hcount_in == 0) rgb_out_nxt = 12'h0_f_0;
          // Active display, right edge, make a blue line.
          else if (hcount_in == 799) rgb_out_nxt = 12'h0_0_f;
          // Active display, interior, fill with gray.
          //I
        //  else if (hcount_in >= 200 && hcount_in  <=205 && vcount_in >49 && vcount_in <161) rgb_out_nxt = 12'h5_8_f;
        //  else if (hcount_in >= 175 && hcount_in  <=230 && vcount_in >160 && vcount_in <165) rgb_out_nxt = 12'h5_8_f;
        //  else if (hcount_in >= 175 && hcount_in  <=230 && vcount_in >45 && vcount_in <50) rgb_out_nxt = 12'h5_8_f;
          //J
        //  else if (hcount_in>=90 && hcount_in<=95 && vcount_in <=145 && vcount_in >=45) rgb_out_nxt = 12'h5_8_f;
        //  else if ((((hcount_in-75)*(hcount_in-75) + (vcount_in-140)*(vcount_in-140) <= 421) && ((hcount_in-75)*(hcount_in-75) + (vcount_in-140)*(vcount_in-140) >= 225)) && vcount_in>=145) rgb_out_nxt = 12'h5_8_f;
          else rgb_out_nxt = 12'hE_8_E;    
        end
    end


endmodule
