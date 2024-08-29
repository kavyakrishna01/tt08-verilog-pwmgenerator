/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_pwmgenerator (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_in = 8'b0;
  assign uio_out = 8'b0;
  assign uio_oe  = 8'b0;
  assign  ui_in [7:2] = 0;
  assign uo_out [7:1] = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, rst_n, 1'b0};
pwmgenerator m1
 (
     .clk(clk), // 100MHz clock input 
     .increase_duty(ui_in[0]), // input to increase 10% duty cycle 
     .decrease_duty(ui_in[1]), // input to decrease 10% duty cycle 
     .PWM_OUT(uo_out[0]) // 10MHz PWM output signal 
    );


endmodule
