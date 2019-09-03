// File: vga_example.v
// This is the top level design for EE178 Lab #4.

// The `timescale directive specifies what the
// simulation time units are (1 ns here) and what
// the simulator time step should be (1 ps here).

`timescale 1 ns / 1 ps

// Declare the module and its ports. This is
// using Verilog-2001 syntax.



`define VGA_BUS_WIRE(NAME_IN, NAME_OUT) \
    wire [10:0] vcount_out_``NAME_OUT, hcount_out_``NAME_OUT;   \
    wire vblnk_out_``NAME_OUT, hblnk_out_``NAME_OUT, vsync_out_``NAME_OUT, hsync_out_``NAME_OUT;   \
    wire [11:0] rgb_out_``NAME_OUT   
    
`define VGA_BUS(NAME_IN, NAME_OUT) \
    .pclk(pclk),   \
	.rst(rst),   \
    .vcount_in(vcount_out_``NAME_IN),   \
    .vsync_in(vsync_out_``NAME_IN),   \
    .vblnk_in(vblnk_out_``NAME_IN),   \
    .hcount_in(hcount_out_``NAME_IN),   \
    .hsync_in(hsync_out_``NAME_IN),   \
    .hblnk_in(hblnk_out_``NAME_IN),   \
    .rgb_in(rgb_out_``NAME_IN),   \
    .vcount_out(vcount_out_``NAME_OUT),   \
    .vsync_out(vsync_out_``NAME_OUT),   \
    .vblnk_out(vblnk_out_``NAME_OUT),   \
    .hcount_out(hcount_out_``NAME_OUT),   \
    .hsync_out(hsync_out_``NAME_OUT),   \
    .hblnk_out(hblnk_out_``NAME_OUT),   \
    .rgb_out(rgb_out_``NAME_OUT)
     
    



module vga_example (
  inout ps2_clk,
  inout ps2_data,
  input wire clk,
  input wire rst,
  	
  output wire[3:0] an,
  output wire[6:0] seg,
  output reg vs,
  output reg hs,
  output reg [3:0] r,
  output reg [3:0] g,
  output reg [3:0] b,
  output wire pclk_mirror,
  output wire [15:0] led
  );
  

localparam START = 2'b01;
localparam PLAY = 2'b11;
localparam END = 2'b10;


reg [1:0 ]state = START, state_nxt = START;

  wire mclk;  //mouse clock
  wire locked; 
  wire pclk, clkFreqHz, clk50Hz;


 //////////////////////////////////////CLK////////////////////////////////////////////////////////////////////    
  clk_wiz_0   my_clk_wiz_0 (
    .clk(clk),
    .clk40MHz(pclk),
    .clk100MHz(mclk), 
    .reset(rst),
    .locked(locked)
  );
  
 ODDR pclk_oddr (
    .Q(pclk_mirror),
    .C(pclk),
    .CE(1'b1),
    .D1(1'b1),
    .D2(1'b0),
    .R(1'b0),
    .S(1'b0)
  );

 //////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 wire [10:0] vcount, hcount, hcount_out, vcount_out, hcount_out_r, vcount_out_r, hcount_out_a, vcount_out_a, hcount_out_ch, vcount_out_ch, hcount_out_ch2, vcount_out_ch2;
  wire vsync, hsync, vsync_out, hsync_out, vsync_out_r, hsync_out_r, vsync_out_a, hsync_out_a, vsync_out_ch, hsync_out_ch, vsync_out_ch2, hsync_out_ch2  ;
  wire vblnk, hblnk, vblnk_out, hblnk_out, vblnk_out_r, hblnk_out_r, vblnk_out_a, hblnk_out_a, vblnk_out_ch, hblnk_out_ch, vblnk_out_ch2, hblnk_out_ch2;
  wire [11:0] rgb_out, rgb_out_r, rgb_out_a, rgb_out_m, rgb_out_ch, rgb_out_ch2;
  wire [11:0] xpos, ypos, xpos_ctl, ypos_ctl;
  reg [11:0] x_buff, y_buff;
  wire [11:0] rgb_pixel, pixel_addr, rgb_pixel2, pixel_addr2, rgb_pixel3, pixel_addr3;
  reg  [11:0] xpos_cat = 600;
  reg [11:0] score = 0, score_nxt;
  wire tx_full, rx_empty;
  wire [3:0] dp_in;
  wire fin, enable;
  reg point;
  wire [7:0] char_pixels, char_xy, char_pixels2, char_xy2;
  wire [10:0] char_addr, char_addr2;
  wire [6:0] char_code, char_code2;
  wire [3:0] char_line, char_line2; 
  wire [15:0] result_bcd;
  reg [31:0]result_string;
  wire result_done;
 
 assign enable = 1;
  //////////////////////////////////////////////////////////////////////////////////////////////////////////
   
  vga_timing my_timing (
    .vcount(vcount),
    .vsync(vsync),
    .vblnk(vblnk),
    .hcount(hcount),
    .hsync(hsync),
    .hblnk(hblnk),
    .pclk(pclk)
  );
  
 ///////////////////////////////////////////////T£O///////////////////////////////////////////////////////////  
draw_backgroundd my_draw_backgroundd(
  .pclk(pclk),
  .rst(rst),
  .vcount_in(vcount),
  .vsync_in(vsync),        
  .vblnk_in(vblnk),        
  .hcount_in(hcount),
  .hsync_in(hsync),        
  .hblnk_in(hblnk),
  
  .hblnk_out(hblnk_out),
  .vcount_out(vcount_out),  
  .hcount_out(hcount_out),
  .vblnk_out(vblnk_out),
  
  .hsync_out(hsync_out),
  .vsync_out(vsync_out),
  .rgb_out(rgb_out)
  );

 //////////////////////////////////////PUDELKO////////////////////////////////////////////////////////////////////  
draw_rect my_draw_rect(
  .pclk(pclk),
  .rst(rst),
  .vcount_in(vcount_out),
  .vsync_in(vsync_out),        
  .vblnk_in(vblnk_out),        
  .hcount_in(hcount_out),
  .hsync_in(hsync_out),        
  .hblnk_in(hblnk_out),
  .rgb_in(rgb_out),
  .xpos(x_buff),
  .ypos(600-70), 
  .rgb_pixel(rgb_pixel), 
  
  .hblnk_out(hblnk_out_r),
  .vcount_out(vcount_out_r),  
  .hcount_out(hcount_out_r),
  .vblnk_out(vblnk_out_r),
  
  .hsync_out(hsync_out_r),
  .vsync_out(vsync_out_r),
  .rgb_out(rgb_out_r),
  .pixel_addr(pixel_addr)
  );
  
      image_rom my_image_rom (
       .clk(pclk),
       .rgb(rgb_pixel),  
       .address(pixel_addr+3)  
    );
    
   //////////////////////////////STANY////////////////////////////////////////////////////////////////////////////
        reg[11:0] test_rect_pos = 200, test_rect_pos_nxt;
        
     `M_DRAW_RECT(r, test, test_rect_pos, 300, image_rom, 1, 1);

 ///////////////////////////////////////NAPIS///////////////////////////////////////////////////////////////////
     
   draw_rect_char my_rect_char (
    .hcount_in(hcount_out_test),
    .hsync_in(hsync_out_test),
    .hblnk_in(hblnk_out_test),
    .vcount_in(vcount_out_test),
    .vsync_in(vsync_out_test),
    .vblnk_in(vblnk_out_test),
    .rst(rst),
    .pclk(pclk),
    .rgb_in(rgb_out_test),
    .char_pixels(char_pixels),
    
    .hcount_out(hcount_out_ch),
    .hsync_out(hsync_out_ch),
    .hblnk_out(hblnk_out_ch),
    .vcount_out(vcount_out_ch),
    .vsync_out(vsync_out_ch),
    .vblnk_out(vblnk_out_ch),
    .rgb_out(rgb_out_ch),
    .char_xy(char_xy),
    .char_line(char_line)
//       .char_addr(char_addr)
   );
   
   
 font_rom my_font_rom (
    .clk(pclk),
    .addr({char_code, char_line}),            // {char_code[6:0], char_line[3:0]}
    .char_line_pixels(char_pixels)  // pixels of the character line
   );
  
 char_16x16 my_char_16x16(
    .char_xy(char_xy),
    .state_in(state),
    .char_code(char_code)
 );    
 ///////////////////////////////////////NAPIS2///////////////////////////////////////////////////////////////////
    
   draw_rect_char2 my_rect_char2 (
    .hcount_in(hcount_out_ch),
    .hsync_in(hsync_out_ch),
    .hblnk_in(hblnk_out_ch),
    .vcount_in(vcount_out_ch),
    .vsync_in(vsync_out_ch),
    .vblnk_in(vblnk_out_ch),
    .rst(rst),
    .pclk(pclk),
    .rgb_in(rgb_out_ch),
    .char_pixels(char_pixels2), //
    
    .hcount_out(hcount_out_ch2),
    .hsync_out(hsync_out_ch2),
    .hblnk_out(hblnk_out_ch2),
    .vcount_out(vcount_out_ch2),
    .vsync_out(vsync_out_ch2),
    .vblnk_out(vblnk_out_ch2),
    .rgb_out(rgb_out_ch2),
    .char_xy(char_xy2),
    .char_line(char_line2)
//       .char_addr(char_addr)
   );
   
   
 font_rom my_font_rom_2 (
    .clk(pclk),
    .addr({char_code2, char_line2}),            // {char_code[6:0], char_line[3:0]}
    .char_line_pixels(char_pixels2)  // pixels of the character line
   );
  
 char_16x16_2 my_char_16x16_2(
    .char_xy(char_xy2),
    .string(result_string),
    .char_code(char_code2)
 );    

 ///////////////////////////////////////KOT///////////////////////////////////////////////////////////////////
  draw_cat my_draw_cat(
    .pclk(pclk),
    .rst(rst),
    .xpos(xpos_ctl),
    .ypos(ypos_ctl), 
    .vcount_in(vcount_out_ch2),
    .vsync_in(vsync_out_ch2),        
    .vblnk_in(vblnk_out_ch2),        
    .hcount_in(hcount_out_ch2),
    .hsync_in(hsync_out_ch2),        
    .hblnk_in(hblnk_out_ch2),
    .rgb_in(rgb_out_ch2),
    .rgb_pixel(rgb_pixel2), 
    
    .hblnk_out(hblnk_out_a),
    .vcount_out(vcount_out_a),  
    .hcount_out(hcount_out_a),
    .vblnk_out(vblnk_out_a),
    
    .hsync_out(hsync_out_a),
    .vsync_out(vsync_out_a),
    .rgb_out(rgb_out_a),
    .pixel_addr(pixel_addr2)
    );

        cat_image my_cat_image (
       .clk(pclk),
       .rgb(rgb_pixel2),  
       .address(pixel_addr2)  
    );

     draw_rect_ctl my_draw_rect_ctl(
       .clk(pclk),
       .rst(rst),
       .on(state==PLAY),
       .mouse_xpos(xpos_cat),
       .mouse_ypos(0),
       .xpos(xpos_ctl),
       .ypos(ypos_ctl),
       .finish(fin)
     );  


 ////////////////////////////////////////////////////////////////////////////////////////////////////////// 
 
 wire mouseLeft;
 wire mouseRight;
    
MouseCtl my_MouseCtl(
        .clk(mclk), // in
        .rst(rst),  // in
        .value(12'b0),
        .setx(1'b0),
        .sety(1'b0),
        .setmax_x(1'b0),
        .setmax_y(1'b0), 
        .ps2_clk(ps2_clk), // inout
        .ps2_data(ps2_data), // inout
        .xpos(xpos), // out
        .ypos(ypos),  // out
        .zpos(),
        .left(mouseLeft),
        .middle(),
        .right(mouseRight),
        .new_event()
  ); 

 ////////////////////////////////////////////////////////////////////////////////////////////////////////// 
    
  clk_divider_2 
  #(
      .Freq(400)
  )
  u_clk_divider_2
      (
          .clk100MHz(mclk), //input clock 100 MHz
          .rst (rst),            //async reset active high
          .clk_div (clkFreqHz)
      );
   
     clk_divider_2 
      #(
          .Freq(50)
      )
      u_clk_divider_3
          (
              .clk100MHz(mclk), //input clock 100 MHz
              .rst (rst),            //async reset active high
              .clk_div (clk50Hz)
          );   


 /////////////////////LICZNIK///////////////////////////////////////////////////////////////////////////////////// 
 
// binary to BCD converting

    wire [3:0]  bcd0;        // LSB
    wire [3:0]  bcd1;
    wire [3:0]  bcd2;  
    wire [3:0]  bcd3;        // MSB
    reg  [15:0] counter_bin = 0;
    
    bin2bcd u_bin2bcd
    (
        .bin (counter_bin),
        .bcd0(bcd0),
        .bcd1(bcd1),
        .bcd2(bcd2),
        .bcd3(bcd3)
    );

//------------------------------------------------------------------------------
// control module for 7-segment display

    sseg_x4 u_sseg_x4
    (
        .clk (clkFreqHz), //posedge active clock
        .rst (rst),      //async reset active HIGH
        .bcd0 (bcd0),    //bcd inputs
        .bcd1 (bcd1),
        .bcd2 (bcd2),
        .bcd3 (bcd3),
        .sseg_ca(seg),
        .sseg_an(an)
    );
    
//////////////////////////////WYNIK//////////////////////////////////////////////////////////////////////////// 



Binary_to_BCD my_binary_result(
    .i_Clock(pclk),
    .i_Binary(score),
    .i_Start(enable),
    
    .o_DV(result_done),
    .o_BCD(result_bcd)
);

 //////////////////////////////////////////KOT2//////////////////////////////////////////////////////////////// 
      
always @(posedge pclk)
    begin
    if((fin)&& (xpos_cat <= 400))
       xpos_cat =  xpos_cat + 247;
    else if ((fin)&& (xpos_cat > 400))
       xpos_cat = xpos_cat - 154;
   else if ((fin)&& (xpos_cat > 800))
                 xpos_cat = 154;
    else
        xpos_cat = xpos_cat;
    end 

//////////////////////////////////////////////////////////////////////////////////////////////////////////
 
always @(posedge pclk)
begin
if(rst)
    begin
    end   
if(result_done)
    begin
    result_string[31:24] <= result_bcd[15:12] + "0";
    result_string[23:16] <= result_bcd[11:8] + "0";
    result_string[15:8] <= result_bcd[7:4] + "0";
    result_string[7:0] <= result_bcd[3:0] + "0";
    end

  x_buff <= xpos;
  y_buff <= ypos;
  vs <= vsync_out_a;
  hs <= hsync_out_a;
  {r,g,b} <= rgb_out_a;
  counter_bin <= score;
end

//////////////////////////////////////////////////////////////////////////////////////////////////////////

reg collision=1, collision_nxt=1;
reg [11:0] worek_wysokosc = 600-70;
wire [11:0] worek_x, worek_y, kot_x, kot_y;
assign worek_x = x_buff;
assign worek_y = worek_wysokosc;
assign kot_x = xpos_ctl;
assign kot_y = ypos_ctl;

reg [11:0] fall_cnt=0, fall_cnt_nxt=0;

always @(*) begin 
    
    if (kot_y+64/*kot_dol*/ > 600-70+64*(1-1/8)  /*mysz_gora*/) begin 
        if( (worek_x <= kot_x+48) && (worek_x >= kot_x) 
        || ( worek_x+48 >= kot_x ) && (worek_x <= kot_x))
            collision_nxt = 1;
         else 
            collision_nxt = 0;
    end else 
        collision_nxt =1;

    
    case(state)
        START: 
        begin
            score_nxt = 0;
            fall_cnt_nxt = 0;
            if(mouseLeft)  begin
                state_nxt = PLAY;
                test_rect_pos_nxt = 20;
           end else begin
                state_nxt = START;
                test_rect_pos_nxt = 200;
            end
        end 
        PLAY:
        begin
            fall_cnt_nxt = fall_cnt +1;
            score_nxt = collision? score + 1 : score;
            if(!collision && fin && kot_y > 500) begin 
                state_nxt = END;
                test_rect_pos_nxt = 500;
            end else begin
                state_nxt = PLAY;
                test_rect_pos_nxt = 20;
            end
        end
        END: 
        begin
            fall_cnt_nxt = 0;
            score_nxt = score;
            if(mouseRight) begin
                state_nxt = START;
                test_rect_pos_nxt = 200;
            end else begin
                 state_nxt = END;
                 test_rect_pos_nxt = 500;
             end   
         end
         default:
             state_nxt = state;
                    
    endcase
end


always @(posedge pclk) begin
    collision <= collision_nxt;
    test_rect_pos <= test_rect_pos_nxt;
    state <= state_nxt;
    
    if(fin || (state == START || state == END) ) begin 
        score <= score_nxt;
        fall_cnt <= fall_cnt_nxt;
    end
end


assign led[15:14] = state;
assign led[8:0] = fall_cnt[8:0];

endmodule
