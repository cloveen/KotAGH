`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.07.2019 15:05:26
// Design Name: 
// Module Name: draw_cat
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


module draw_cat(
    input wire[10:0] hcount_in,
    input wire hsync_in,
    input wire hblnk_in,
    input wire [10:0] vcount_in,
    input wire vsync_in,
    input wire vblnk_in,
    input wire [11:0] rgb_in,
    input wire pclk,
    input wire rst,
    input wire [11:0] xpos,
    input wire [11:0] ypos,
    input wire [11:0] rgb_pixel,
    
    output reg [10:0] hcount_out,
    output reg hsync_out,
    output reg hblnk_out,
    output reg [10:0] vcount_out,
    output reg vsync_out,
    output reg vblnk_out,
    output reg [11:0] rgb_out,
    output reg [11:0] pixel_addr
    );


localparam WIDTH= 'd64;
localparam HEIGTH = 'd64;


reg [11:0] rgb_nxt, pixel_addr_nxt;
reg [11:0] x_pos_reg, y_pos_reg;
reg hsync_buff, vsync_buff, hsync_buff2, vsync_buff2;
reg hblnk_buff, vblnk_buff, hblnk_buff2, vblnk_buff2;
reg [10:0] hcount_buff, vcount_buff, hcount_buff2, vcount_buff2;
reg [11:0] rgb_buff, rgb_buff2;

always @*
begin
    if ( (hcount_in >= x_pos_reg) && (hcount_in < (x_pos_reg+WIDTH)) && (vcount_in >= y_pos_reg)&&(vcount_in < (y_pos_reg +HEIGTH)))
    begin
        pixel_addr_nxt[11:6] = vcount_in - y_pos_reg;
        pixel_addr_nxt[5:0] = hcount_in - x_pos_reg; 
    end
    else 
    pixel_addr_nxt = pixel_addr;
        
    rgb_nxt = ((rgb_pixel != 12'h0FF)&&(hcount_buff2>= x_pos_reg) && (hcount_buff2 < (x_pos_reg+WIDTH)) && (vcount_buff2 >= y_pos_reg)&&(vcount_buff2 < (y_pos_reg +HEIGTH))  ) ? rgb_pixel : rgb_buff2;   
end
/*
always @*
begin
    if((rgb_pixel != 12'h0FF)&&(hcount_buff2>= x_pos_reg) && (hcount_buff2 < (x_pos_reg+WIDTH)) && (vcount_buff2 >= y_pos_reg)&&(vcount_buff2 < (y_pos_reg +HEIGTH))  )
     rgb_nxt = rgb_pixel;
    else
     rgb_nxt = rgb_buff; 
end
*/

always @(posedge pclk) 
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
   x_pos_reg <= xpos;
   y_pos_reg <= ypos; 

   hcount_buff <= hcount_in;
   hsync_buff <= hsync_in;
   hblnk_buff <= hblnk_in;
   vcount_buff <= vcount_in;
   vsync_buff <= vsync_in;
   vblnk_buff <= vblnk_in;
   rgb_buff <= rgb_in;
   
   hcount_buff2 <= hcount_buff;
   hsync_buff2 <= hsync_buff;
   hblnk_buff2 <= hblnk_buff;
   vcount_buff2 <= vcount_buff;
   vsync_buff2 <= vsync_buff;
   vblnk_buff2 <= vblnk_buff;
   rgb_buff2 <= rgb_buff;
      
   hcount_out <= hcount_buff2;
   vcount_out <= vcount_buff2;
   vblnk_out <= vblnk_buff2;
   vsync_out <= vsync_buff2;
   hblnk_out <= hblnk_buff2;
   hsync_out <= hsync_buff2;
   
   rgb_out <= rgb_nxt;
   pixel_addr <= pixel_addr_nxt;
 end 
end

endmodule

