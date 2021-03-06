// synthesis translate_off
/////////////////////////////////////////////////////////////////////
////
//// Copyright (C) 2022 Accelize
////
//// This is a generated file. Use and modify at your own risk.
/////////////////////////////////////////////////////////////////////

// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps

import drm_activator_0x1003000b00010001_sim_pkg::*;


module top_drm_activator_0x1003000b00010001 (
  // AXI4-Stream Bus clock and reset
  input  wire            drm_aclk,
  input  wire            drm_arstn,
  // AXI4-Stream Bus from DRM Controller
  output wire            drm_to_uip_tready,
  input  wire            drm_to_uip_tvalid,
  input  wire [31:0]     drm_to_uip_tdata,
  input  wire            drm_to_uip_tlast,
  // AXI4-Stream Bus to DRM Controller
  input  wire            uip_to_drm_tready,
  output wire            uip_to_drm_tvalid,
  output wire [31:0]     uip_to_drm_tdata,
  output wire            uip_to_drm_tlast,
  // IP core interface
  input  wire            metering_event,
  output wire [127:0]    activation_code
);

  localparam POR_DURATION = 16;

  reg  [POR_DURATION-1:0] por_shifter = {POR_DURATION{1'b0}};  // init for simulation
  wire                    i_ip_core_arstn;

  wire                    i_drm_to_uip_tready;
  wire                    i_drm_to_uip_tvalid;
  wire [31:0]             i_drm_to_uip_tdata;
  wire                    i_drm_to_uip_tlast;

  wire                    i_uip_to_drm_tready;
  wire                    i_uip_to_drm_tvalid;
  wire [31:0]             i_uip_to_drm_tdata;
  wire                    i_uip_to_drm_tlast;


  //---------------
  // Generate POR
  //---------------

  assign i_ip_core_arstn = por_shifter[POR_DURATION-1];

  always @(posedge drm_aclk) begin
    por_shifter[0]                <= 1'b1;
    por_shifter[POR_DURATION-1:1] <= por_shifter[POR_DURATION-2:0];
  end


  //-------------------------------
  // Map activator to AXI4-Stream
  //-------------------------------

  generate if (drm_activator_0x1003000b00010001_sim_pkg::USE_BFM == 1) begin

    wire       license_file_loaded;
    wire       activation_cycle_done;
    wire [7:0] error_code;
    wire       i_drm_bfm_arstn;
    reg        s_uip_to_drm_tvalid;

    assign i_drm_bfm_arstn = drm_arstn & drm_to_uip_tvalid & &drm_to_uip_tdata & drm_to_uip_tlast;

    always @(posedge drm_aclk) begin
    if (~drm_arstn)
      s_uip_to_drm_tvalid <= 1'b0;
    else
      s_uip_to_drm_tvalid <= 1'b1;
    end

    assign uip_to_drm_tvalid = s_uip_to_drm_tvalid;
    assign uip_to_drm_tdata  = {32{drm_arstn}};
    assign uip_to_drm_tlast  = 1'b1;

    assign drm_to_uip_tready = uip_to_drm_tready;


    DRM_CONTROLLER_BFM #(
      .LICENSE_FILE           (drm_activator_0x1003000b00010001_sim_pkg::DRM_LICENSE_FILE),
      .LICENSE_TIMER          (""),
      .ENABLE_MESSAGE_DISPLAY (drm_activator_0x1003000b00010001_sim_pkg::ENABLE_DRM_MESSAGE)
    ) drm_controller_bfm_inst (
      // DRM clock and reset
      .DRM_ACLK               (drm_aclk),
      .DRM_ARSTN              (i_drm_bfm_arstn),
      // DRM Bus interface
      .SEND_TREADY            (i_drm_to_uip_tready),
      .SEND_TVALID            (i_drm_to_uip_tvalid),
      .SEND_TDATA             (i_drm_to_uip_tdata),
      .SEND_TLAST             (i_drm_to_uip_tlast),
      .RECEIVE_TREADY         (i_uip_to_drm_tready),
      .RECEIVE_TVALID         (i_uip_to_drm_tvalid),
      .RECEIVE_TDATA          (i_uip_to_drm_tdata),
      .RECEIVE_TLAST          (i_uip_to_drm_tlast),
      // BFM status
      .LICENSE_FILE_LOADED    (license_file_loaded),
      .ACTIVATION_CYCLE_DONE  (activation_cycle_done),
      .ERROR_CODE             (error_code)
    );

  end else begin

    assign drm_to_uip_tready   = i_drm_to_uip_tready;
    assign i_drm_to_uip_tvalid = drm_to_uip_tvalid;
    assign i_drm_to_uip_tdata  = drm_to_uip_tdata;
    assign i_drm_to_uip_tlast  = drm_to_uip_tlast;

    assign i_uip_to_drm_tready = uip_to_drm_tready;
    assign uip_to_drm_tvalid   = i_uip_to_drm_tvalid;
    assign uip_to_drm_tdata    = i_uip_to_drm_tdata;
    assign uip_to_drm_tlast    = i_uip_to_drm_tlast;

  end endgenerate


  drm_ip_activator_0x1003000b00010001 drm_ip_activator_0x1003000b00010001_inst (
    .DRM_ACLK              (drm_aclk),
    .DRM_ARSTN             (drm_arstn),
    .SEND_TREADY           (i_uip_to_drm_tready),
    .SEND_TVALID           (i_uip_to_drm_tvalid),
    .SEND_TDATA            (i_uip_to_drm_tdata),
    .SEND_TLAST            (i_uip_to_drm_tlast),
    .RECEIVE_TREADY        (i_drm_to_uip_tready),
    .RECEIVE_TVALID        (i_drm_to_uip_tvalid),
    .RECEIVE_TDATA         (i_drm_to_uip_tdata),
    .RECEIVE_TLAST         (i_drm_to_uip_tlast),
    .IP_CORE_ACLK          (drm_aclk),
    .IP_CORE_ARSTN         (i_ip_core_arstn),
    .DRM_EVENT             (metering_event),
    .DRM_ARST              (1'b0),
    .ACTIVATION_CODE_READY (),
    .DEMO_MODE             (),
    .ACTIVATION_CODE       (activation_code)
  );

endmodule
`default_nettype wire
// synthesis translate_on
