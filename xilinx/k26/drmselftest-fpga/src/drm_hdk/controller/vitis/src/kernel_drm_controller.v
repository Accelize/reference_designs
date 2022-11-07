/////////////////////////////////////////////////////////////////////
////
//// Copyright (C) 2022 Accelize
////
//// This is a generated file. Use and modify at your own risk.
/////////////////////////////////////////////////////////////////////

// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps


module kernel_drm_controller #(
  parameter integer  C_S_AXI_CONTROL_DATA_WIDTH  = 32,
  parameter integer  C_S_AXI_CONTROL_ADDR_WIDTH  = 16,
  parameter integer  C_DATA_WIDTH                = 32
)(
  // AXI4-Stream Clock and Reset
  input  wire                                    ap_clk,
  input  wire                                    ap_rst_n,
  // AXI4-Stream Bus to/from User IP0
  input  wire                                    drm_to_uip0_tready,
  output wire                                    drm_to_uip0_tvalid,
  output wire [C_DATA_WIDTH-1:0]                 drm_to_uip0_tdata,
  output wire                                    drm_to_uip0_tlast,
  output wire                                    uip0_to_drm_tready,
  input  wire                                    uip0_to_drm_tvalid,
  input  wire [C_DATA_WIDTH-1:0]                 uip0_to_drm_tdata,
  input  wire                                    uip0_to_drm_tlast,
  // AXI4-Lite Register Access
  input  wire                                    s_axi_control_awvalid,
  output wire                                    s_axi_control_awready,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_awaddr,
  input  wire                                    s_axi_control_wvalid,
  output wire                                    s_axi_control_wready,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_wdata,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_wstrb,
  output wire                                    s_axi_control_bvalid,
  input  wire                                    s_axi_control_bready,
  output wire [2-1:0]                            s_axi_control_bresp,
  input  wire                                    s_axi_control_arvalid,
  output wire                                    s_axi_control_arready,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_araddr,
  output wire                                    s_axi_control_rvalid,
  input  wire                                    s_axi_control_rready,
  output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_rdata,
  output wire [2-1:0]                            s_axi_control_rresp
);

  wire [2:0] s_axi_control_awprot;
  wire [2:0] s_axi_control_arprot;

  assign s_axi_control_awprot = 3'b0;
  assign s_axi_control_arprot = 3'b0;


  //-----------------
  // DRM Controller
  //-----------------
  // A DRM must be instanciated and must be connected at least to one activator block (that will be inside the loopback example).

  top_drm_controller top_drm_controller_inst (
    // AXI4-Stream Clock and Reset
    .drm_aclk             ( ap_clk                ),
    .drm_arstn            ( ap_rst_n              ),
    // AXI4-Stream Bus to/from User IP0
    .drm_to_uip0_tready   ( drm_to_uip0_tready    ),
    .drm_to_uip0_tvalid   ( drm_to_uip0_tvalid    ),
    .drm_to_uip0_tdata    ( drm_to_uip0_tdata     ),
    .drm_to_uip0_tlast    ( drm_to_uip0_tlast     ),
    .uip0_to_drm_tready   ( uip0_to_drm_tready    ),
    .uip0_to_drm_tvalid   ( uip0_to_drm_tvalid    ),
    .uip0_to_drm_tdata    ( uip0_to_drm_tdata     ),
    .uip0_to_drm_tlast    ( uip0_to_drm_tlast     ),
    // AXI4-Lite Register Access
    .s_axi_awready        ( s_axi_control_awready ),
    .s_axi_awvalid        ( s_axi_control_awvalid ),
    .s_axi_awaddr         ( s_axi_control_awaddr  ),
    .s_axi_awprot         ( s_axi_control_awprot  ),
    .s_axi_wready         ( s_axi_control_wready  ),
    .s_axi_wvalid         ( s_axi_control_wvalid  ),
    .s_axi_wdata          ( s_axi_control_wdata   ),
    .s_axi_wstrb          ( s_axi_control_wstrb   ),
    .s_axi_bready         ( s_axi_control_bready  ),
    .s_axi_bvalid         ( s_axi_control_bvalid  ),
    .s_axi_bresp          ( s_axi_control_bresp   ),
    .s_axi_arready        ( s_axi_control_arready ),
    .s_axi_arvalid        ( s_axi_control_arvalid ),
    .s_axi_araddr         ( s_axi_control_araddr  ),
    .s_axi_arprot         ( s_axi_control_arprot  ),
    .s_axi_rready         ( s_axi_control_rready  ),
    .s_axi_rvalid         ( s_axi_control_rvalid  ),
    .s_axi_rdata          ( s_axi_control_rdata   ),
    .s_axi_rresp          ( s_axi_control_rresp   ),
    // Chip DNA
    .chip_dna_valid       (                       ),
    .chip_dna             (                       )
  );


endmodule
`default_nettype wire
