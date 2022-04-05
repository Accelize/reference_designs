///////////////////////////////////////////////////////////////////////////////
// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////

// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps

// Top level of the kernel. Do not modify module name, parameters or ports.
module krnl_adder_stage_rtl #(
  parameter integer  C_S_AXI_CONTROL_DATA_WIDTH = 32,
  parameter integer  C_S_AXI_CONTROL_ADDR_WIDTH = 12,
  parameter integer  C_DATA_WIDTH               = 32
)
(
  // System signals
  input  wire                                    ap_clk,
  input  wire                                    ap_rst_n,
  // AXI4-Stream (slave) interface p0
  input  wire [C_DATA_WIDTH-1:0]                 p0_tdata,
  input  wire                                    p0_tvalid,
  output wire                                    p0_tready,
  // AXI4-Stream (master) interface p1
  output wire [C_DATA_WIDTH-1:0]                 p1_tdata,
  output wire                                    p1_tvalid,
  input  wire                                    p1_tready,
  // AXI4-Stream (slave) interface drm_to_uip
  output wire                                    drm_to_uip_tready    ,
  input  wire                                    drm_to_uip_tvalid    ,
  input  wire [31:0]                             drm_to_uip_tdata     ,
  input  wire                                    drm_to_uip_tlast,
  // AXI4-Stream (master) interface uip_to_drm
  input  wire                                    uip_to_drm_tready    ,
  output wire                                    uip_to_drm_tvalid    ,
  output wire [31:0]                             uip_to_drm_tdata     ,
  output wire                                    uip_to_drm_tlast,
  // AXI4-Lite slave interface
  input  wire                                    s_axi_control_awvalid,
  output wire                                    s_axi_control_awready,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_awaddr,
  input  wire                                    s_axi_control_wvalid,
  output wire                                    s_axi_control_wready,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_wdata,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_wstrb,
  input  wire                                    s_axi_control_arvalid,
  output wire                                    s_axi_control_arready,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_araddr,
  output wire                                    s_axi_control_rvalid,
  input  wire                                    s_axi_control_rready,
  output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_rdata,
  output wire [1:0]                              s_axi_control_rresp,
  output wire                                    s_axi_control_bvalid,
  input  wire                                    s_axi_control_bready,
  output wire [1:0]                              s_axi_control_bresp,
  output wire                                    interrupt
);

krnl_adder_stage_rtl_int #(
  .C_S_AXI_CONTROL_DATA_WIDTH ( C_S_AXI_CONTROL_DATA_WIDTH ),
  .C_S_AXI_CONTROL_ADDR_WIDTH ( C_S_AXI_CONTROL_ADDR_WIDTH ),
  .C_DATA_WIDTH               ( C_DATA_WIDTH )
)
inst_krnl_adder_stage_rtl_int (
  .ap_clk                 ( ap_clk ),
  .ap_rst_n               ( ap_rst_n ),
  .p0_TDATA               ( p0_tdata ),
  .p0_TVALID              ( p0_tvalid ),
  .p0_TREADY              ( p0_tready ),
  .p1_TDATA               ( p1_tdata ),
  .p1_TVALID              ( p1_tvalid ),
  .p1_TREADY              ( p1_tready ),
  .s_axi_control_AWVALID  ( s_axi_control_awvalid ),
  .s_axi_control_AWREADY  ( s_axi_control_awready ),
  .s_axi_control_AWADDR   ( s_axi_control_awaddr ),
  .s_axi_control_WVALID   ( s_axi_control_wvalid ),
  .s_axi_control_WREADY   ( s_axi_control_wready ),
  .s_axi_control_WDATA    ( s_axi_control_wdata ),
  .s_axi_control_WSTRB    ( s_axi_control_wstrb ),
  .s_axi_control_ARVALID  ( s_axi_control_arvalid ),
  .s_axi_control_ARREADY  ( s_axi_control_arready ),
  .s_axi_control_ARADDR   ( s_axi_control_araddr ),
  .s_axi_control_RVALID   ( s_axi_control_rvalid ),
  .s_axi_control_RREADY   ( s_axi_control_rready ),
  .s_axi_control_RDATA    ( s_axi_control_rdata ),
  .s_axi_control_RRESP    ( s_axi_control_rresp ),
  .s_axi_control_BVALID   ( s_axi_control_bvalid ),
  .s_axi_control_BREADY   ( s_axi_control_bready ),
  .s_axi_control_BRESP    ( s_axi_control_bresp ),
  .interrupt              ( interrupt ),
  // AXI4-Stream Bus from DRM Controller
  .drm_to_uip_TREADY      ( drm_to_uip_tready ),
  .drm_to_uip_TVALID      ( drm_to_uip_tvalid ),
  .drm_to_uip_TDATA       ( drm_to_uip_tdata ),
  .drm_to_uip_TLAST       ( drm_to_uip_tlast ),
  // AXI4-Stream Bus to DRM Controller
  .uip_to_drm_TREADY      ( uip_to_drm_tready ),
  .uip_to_drm_TVALID      ( uip_to_drm_tvalid ),
  .uip_to_drm_TDATA       ( uip_to_drm_tdata ),
  .uip_to_drm_TLAST       ( uip_to_drm_tlast )
);

endmodule : krnl_adder_stage_rtl

`default_nettype wire
