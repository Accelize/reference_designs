/////////////////////////////////////////////////////////////////////
////
//// Copyright (C) 2022 Accelize
////
//// This is a CDC with handshake supporting pulse or level
/////////////////////////////////////////////////////////////////////

// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps

module cdc_pulse
#(
  parameter NUM_CDC_STAGE = 2
)(
  // Source domain
  input  wire  src_aclk,
  input  wire  src_arstn,
  input  wire  src_bit,
  output wire  src_ready,
  // Destination domain
  input  wire  dst_aclk,
  input  wire  dst_arstn,
  output reg   dst_bit
);

  (* ASYNC_REG = "TRUE" *) reg  [NUM_CDC_STAGE-1:0]  dst_arstn_fs;

  reg                                                src_req;
  (* ASYNC_REG = "TRUE" *) reg  [NUM_CDC_STAGE-1:0]  dst_req;

  reg                                                dst_ack;
  (* ASYNC_REG = "TRUE" *) reg  [NUM_CDC_STAGE-1:0]  src_ack;


  assign src_ready = ~src_bit & ~src_req;

  // CDC from destionation to source
  always@(posedge src_aclk) begin
    if (~src_arstn) begin
      dst_arstn_fs <= {NUM_CDC_STAGE{1'b0}};
      src_ack   <= {NUM_CDC_STAGE{1'b0}};
    end else begin
      dst_arstn_fs[0]                 <= dst_arstn;
      dst_arstn_fs[NUM_CDC_STAGE-1:1] <= dst_arstn_fs[NUM_CDC_STAGE-2:0];
      src_ack[0]                   <= dst_ack;
      src_ack[NUM_CDC_STAGE-1:1]   <= src_ack[NUM_CDC_STAGE-2:0];
    end
  end

  // Capture pulse on src domain
  always@(posedge src_aclk) begin
    if (~src_arstn || ~&dst_arstn_fs) begin
      src_req <= 1'b0;
    end else begin
      if (src_bit) begin
          src_req <= 1'b1;
      end else if (src_req && &src_ack) begin
        src_req <= 1'b0;
      end
    end
  end

  // CDC from source to destionation
  always@(posedge dst_aclk) begin
    if (~dst_arstn) begin
      dst_req <= {NUM_CDC_STAGE{1'b0}};
    end else begin
      dst_req[0]                 <= src_req;
      dst_req[NUM_CDC_STAGE-1:1] <= dst_req[NUM_CDC_STAGE-2:0];
    end
  end

  // Generate pulse on dest domain
  always@(posedge dst_aclk) begin
    if (~dst_arstn) begin
      dst_ack <= 1'b0;
      dst_bit <= 1'b0;
    end else begin
      dst_bit <= 1'b0;
      if (dst_req[NUM_CDC_STAGE-1] && ~dst_ack) begin
        dst_bit <= 1'b1;
        dst_ack <= 1'b1;
      end
      if (dst_ack && ~|dst_req) begin
        dst_ack <= 1'b0;
      end
    end
  end

endmodule



// src req and dst ready are 1 clock cycle pulses
module cdc_bus
#(
  parameter NUM_CDC_STAGE = 2,
  parameter BUS_WIDTH = 32
)(
  // Source domain
  input  wire                 src_aclk,
  input  wire                 src_arstn,
  input  wire [BUS_WIDTH-1:0] src_bus,
  input  wire                 src_valid,
  output wire                 src_ready,
  // Destination domain
  input  wire                 dst_aclk,
  input  wire                 dst_arstn,
  output reg  [BUS_WIDTH-1:0] dst_bus,
  output reg                  dst_valid
);

  wire                                          src_valid_rdy;
  reg                                           dst_req;
  reg                                           dst_req_d;

  reg                                           dst_ack;
  wire                                          dst_ack_rdy;
  reg                                           src_ack;
  (* ASYNC_REG = "TRUE" *) reg [BUS_WIDTH-1:0]  src_bus_d;

  reg                                           i_crossing;


  assign src_ready = ~src_valid & ~i_crossing;

  // CDC for src_valid
  cdc_pulse #(.NUM_CDC_STAGE(NUM_CDC_STAGE)) cdc_src_valid_inst (
  .src_aclk(src_aclk), .src_arstn(src_arstn), .src_bit(src_valid), .src_ready(src_valid_rdy),
  .dst_aclk(dst_aclk), .dst_arstn(dst_arstn), .dst_bit(dst_req));

  // CDC for dst_ack
  cdc_pulse #(.NUM_CDC_STAGE(NUM_CDC_STAGE)) cdc_dst_ack_inst (
  .src_aclk(dst_aclk), .src_arstn(dst_arstn), .src_bit(dst_ack), .src_ready(dst_ack_rdy),
  .dst_aclk(src_aclk), .dst_arstn(src_arstn), .dst_bit(src_ack));


  // Trigger CDC start
  always@(posedge src_aclk) begin
    if (~src_arstn) begin
      src_bus_d  <= {BUS_WIDTH{1'b0}};
      i_crossing <= 1'b0;
    end else begin
      if (src_valid) begin
          i_crossing <= 1'b1;
          src_bus_d <= src_bus;
      end
      if (src_ack) begin
        i_crossing <= 1'b0;
      end
    end
  end

  // CDC for src_bus
  always@(posedge dst_aclk) begin
    if (~dst_arstn) begin
      dst_valid <= 1'b0;
      dst_bus   <= {BUS_WIDTH{1'b0}};
      dst_ack   <= 1'b0;
      dst_req_d <= 1'b0;
    end else begin
      dst_ack <= 1'b0;
      dst_valid <= 1'b0;
      if (dst_req) begin
        dst_req_d <= 1'b1;
        dst_valid <= 1'b1;
        dst_bus   <= src_bus_d;
      end
      if (dst_req_d && dst_ack_rdy) begin
        dst_ack   <= 1'b1;
        dst_req_d <= 1'b0;
      end
    end
  end

endmodule
`default_nettype wire
