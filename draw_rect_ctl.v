`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.03.2019 19:15:10
// Design Name: 
// Module Name: draw_rect_ctl
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


module draw_rect_ctl(
    input clk,
    input rst,
    input on,
    input [11:0] mouse_xpos,
    input [11:0] mouse_ypos,
    output reg [11:0] xpos,
    output reg [11:0] ypos, 
    output reg finish
    );
    
     localparam
        
        MAX_HEIGTH = 'd600,
        IMG_HEIGTH = 'd64,
        rewrite = 'd0,
        falling = 'd1,
            
        timer_rst = 'd0,
        timer_count = 'd1,
        timer_stop = 'd2,
        
        TIMER_MAX = 'd100000,        
        gravity = 'd01;
    
    reg [20:0] time_ctr = 0;
    reg [20:0] time_ctr_next = 0;
    
    reg [20:0]time_ctr_ms = 0;
    reg [20:0] time_ctr_ms_nxt = 0;
    
    reg [1:0] state = rewrite;
    reg [1:0] state_nxt = 0;
    reg [1:0] timer_state = timer_rst;
    reg [1:0] timer_state_nxt = 0;
    
    
    reg [11:0] xpos_nxt = 0;
    reg [11:0] ypos_nxt = 0;
    
    reg [11:0] xpos_start = 0;
    reg [11:0] ypos_start = 0;
    reg [11:0] cat = 0;
    
    reg fall_finish = 0;
    reg fall_finish_nxt = 0;
 

             
     always @*
     begin          
         if((on == 1)&&(fall_finish == 0)) 
          begin        
             if(state == rewrite) 
                 begin 
                    state_nxt = falling;
                    xpos_start = mouse_xpos;
                    ypos_start = mouse_ypos; 
                 end 
             else 
                 begin
                     state_nxt = state;
                     xpos_start = xpos_start; 
                     ypos_start = ypos_start;             
                 end            
         end  
         else if(fall_finish == 0)  
             begin
                 state_nxt = rewrite;
                 xpos_start = 0;
                 ypos_start = 0; 
             
             end
         else if((fall_finish == 1)&&(on == 1))  
                 begin
                     state_nxt = rewrite;
                     xpos_start =0;
                     ypos_start = 0; 
                 
                 end
         else begin 
             state_nxt = state;
             xpos_start = xpos_start;
             ypos_start = ypos_start;
         end
   
   end      
     
 
 always @*
     begin    
         case(timer_state)            
           timer_count: 
                 begin
                     time_ctr_next = (time_ctr == TIMER_MAX) ? 0 : time_ctr +1;            
                     time_ctr_ms_nxt = (time_ctr_next == TIMER_MAX ) ? time_ctr_ms+2 : time_ctr_ms; 
                 end            
             timer_rst:
                  begin 
                      time_ctr_next = 0;
                      time_ctr_ms_nxt = 0;
                 end            
             timer_stop: 
                 begin
                     time_ctr_next = time_ctr;
                     time_ctr_ms_nxt = time_ctr_ms;
                 end             
         endcase
     end 
     
     always @* 
         begin       
          case ( state )            
             rewrite : 
                 begin
                     timer_state_nxt = timer_rst;
                     fall_finish_nxt = 0;
                    ypos_nxt = mouse_ypos;
                    xpos_nxt = mouse_xpos;
                 end         
             falling: 
                 begin                            
                     timer_state_nxt = timer_count;                               
                     if(ypos == MAX_HEIGTH - IMG_HEIGTH)
                          begin
                             xpos_nxt = xpos_start;
                             ypos_nxt = MAX_HEIGTH - IMG_HEIGTH;
                             timer_state_nxt = timer_rst;
                             fall_finish_nxt = 1; 
                         end
                     else 
                         begin                      
                             ypos_nxt = ypos_start + gravity * time_ctr_ms*time_ctr_ms /10000;
                             xpos_nxt = xpos_start;
                             timer_state_nxt = timer_count;
                             fall_finish_nxt = 0;                            
                         end               
                  end                               
          endcase                    
     end
     
     always @(posedge clk, posedge rst) begin
       if(rst)
            begin
            xpos <= mouse_xpos;
            ypos <= mouse_ypos;                   
            end
       else
           begin
           xpos <= xpos_nxt;
           ypos <= ypos_nxt;         
           state <= state_nxt;
           timer_state <= timer_state_nxt;
           time_ctr <= time_ctr_next;       
           time_ctr_ms <= time_ctr_ms_nxt;   
           fall_finish <= fall_finish_nxt;  
           finish <= fall_finish;
           end   

     end    
endmodule
