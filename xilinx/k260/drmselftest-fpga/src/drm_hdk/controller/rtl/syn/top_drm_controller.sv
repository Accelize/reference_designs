/////////////////////////////////////////////////////////////////////
////
//// Copyright (C) 2022 Accelize
////
//// This is a generated file. Use and modify at your own risk.
/////////////////////////////////////////////////////////////////////

// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps


module top_drm_controller
(
  // AXI4-Stream Clock and Reset
  input  wire                      drm_aclk           ,
  input  wire                      drm_arstn          ,
  // AXI4-Stream Bus to/from User IP0
  input  wire                      drm_to_uip0_tready ,
  output wire                      drm_to_uip0_tvalid ,
  output wire [32-1:0]             drm_to_uip0_tdata  ,
  output wire                      drm_to_uip0_tlast  ,
  output wire                      uip0_to_drm_tready ,
  input  wire                      uip0_to_drm_tvalid ,
  input  wire [32-1:0]             uip0_to_drm_tdata  ,
  input  wire                      uip0_to_drm_tlast  ,
  // AXI4-Lite Register Access
  output wire                      s_axi_awready      ,
  input  wire                      s_axi_awvalid      ,
  input  wire [16-1:0]             s_axi_awaddr       ,
  input  wire [3-1 :0]             s_axi_awprot       ,
  output wire                      s_axi_wready       ,
  input  wire                      s_axi_wvalid       ,
  input  wire [32-1:0]             s_axi_wdata        ,
  input  wire [32/8-1:0]           s_axi_wstrb        ,
  input  wire                      s_axi_bready       ,
  output wire                      s_axi_bvalid       ,
  output wire [2-1:0]              s_axi_bresp        ,
  output wire                      s_axi_arready      ,
  input  wire                      s_axi_arvalid      ,
  input  wire [16-1:0]             s_axi_araddr       ,
  input  wire [3-1 :0]             s_axi_arprot       ,
  input  wire                      s_axi_rready       ,
  output wire                      s_axi_rvalid       ,
  output wire [32-1:0]             s_axi_rdata        ,
  output wire [2-1:0]              s_axi_rresp        ,
  // Chip DNA
  output wire                      chip_dna_valid     ,
  output wire [96-1:0]             chip_dna
);

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////

localparam REG_VERSION = 32'h01000000;

localparam
    WRIDLE  = 2'd0,
    WRDATA  = 2'd1,
    WRRESP  = 2'd2,
    WRRESET = 2'd3,
    RDIDLE  = 2'd0,
    RDDATA  = 2'd1,
    RDRESET = 2'd2;

localparam READ_WRITE_MAILBOX_SIZE = 16;
localparam READ_ONLY_MAILBOX_SIZE  = 69;
localparam READ_ONLY_MAILBOX_DATA  = 2208'h7865227B2261727463227B3A3A2270734D6F532266222C225F616770696D61663A22796C6E6172225F6D6F642C2264696770662265765F61726F646E78223A226E696C69222C22786E64676C6C75665F65765F6C6F697372223A226E2E302E3722302E306361222C617669744E726F7465626D75313A22727564222C6C636C61663A226B65736C6170222C7D75646F72695F74637B3A226462696C227972617272223A22656466656E6769736E222C2222656D617264223A61315F6D76697463726F746176222C226F646E65223A227265636361657A696C6D6F632E222C7D225F676B7073726576226E6F692E31223A2B372E3265643232226236367264222C6F735F6D617774663A226572657572740000007D;

localparam REG_CMD_STA            = 0;
localparam REG_STREAM             = REG_CMD_STA + 1;
localparam REG_MAILBOX_SIZE       = REG_STREAM + 1;
localparam REG_READ_ONLY_MAILBOX  = REG_MAILBOX_SIZE + 1;
localparam REG_READ_WRITE_MAILBOX = REG_READ_ONLY_MAILBOX + READ_ONLY_MAILBOX_SIZE;
localparam NUM_REG                = REG_READ_WRITE_MAILBOX + READ_WRITE_MAILBOX_SIZE;

localparam ADDR_BITS = $clog2(NUM_REG*4)+1;

localparam WRITE_QUERY = 4'h1,
           READ_QUERY  = 4'h2;

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////

reg  [31:0]             mailbox [0:NUM_REG-1];

reg  [1:0]              wstate = WRRESET;
reg  [ADDR_BITS-3:0]    waddr;

reg  [1:0]              rstate = RDRESET;
reg  [ADDR_BITS-3:0]    raddr;

reg                     i_s_axi_awready;
reg                     i_s_axi_wready;
reg                     i_s_axi_bvalid;

reg                     i_s_axi_arready;
reg                     i_s_axi_rvalid;
reg [31:0]              i_s_axi_rdata;

reg                     i_drm_to_uip0_tvalid;
reg  [31:0]             i_drm_to_uip0_tdata;
reg                     i_drm_to_uip0_tlast;

reg                     i_uip0_to_drm_tready;

reg [7:0]               wr_counter;

reg [7:0]               activator_index;

integer i;


///////////////////////////////////////////////////////////////////////////////
// Instantiation and descriptions
///////////////////////////////////////////////////////////////////////////////

assign chip_dna_valid = 1'b0;
assign chip_dna       = 96'h0;


//------------------------AXI write fsm------------------

assign drm_to_uip0_tvalid = i_drm_to_uip0_tvalid;
assign drm_to_uip0_tdata  = i_drm_to_uip0_tdata;
assign drm_to_uip0_tlast  = i_drm_to_uip0_tlast;

assign s_axi_awready = i_s_axi_awready;
assign s_axi_wready  = i_s_axi_wready;
assign s_axi_bvalid  = i_s_axi_bvalid;
assign s_axi_bresp   = 2'b00;  // OKAY


// write FSM
always @(posedge drm_aclk) begin
  if (~drm_arstn) begin
    i_s_axi_awready      <= 1'b0;
    i_s_axi_wready       <= 1'b0;
    i_s_axi_bvalid       <= 1'b0;
    i_drm_to_uip0_tvalid <= 1'b0;
    i_drm_to_uip0_tdata  <= 32'h0;
    i_drm_to_uip0_tlast  <= 1'b0;
    waddr                <= {ADDR_BITS{1'b0}};
    wstate               <= WRRESET;
    wr_counter           <= 8'h0;
    activator_index      <= 8'h0;
    mailbox[REG_CMD_STA] <= 32'h0;
    mailbox[REG_STREAM]  <= 32'h0;
    mailbox[REG_MAILBOX_SIZE] <= (READ_ONLY_MAILBOX_SIZE << 16) + READ_WRITE_MAILBOX_SIZE;
    for(i = 0; i < READ_ONLY_MAILBOX_SIZE; i = i + 1) begin
        mailbox[REG_READ_ONLY_MAILBOX + i] <= READ_ONLY_MAILBOX_DATA[(READ_ONLY_MAILBOX_SIZE-1-i)*32 +: 32];
    end

  end else begin
    case (wstate)
        WRIDLE: begin
            i_drm_to_uip0_tvalid <= 1'b0;
            i_s_axi_awready <= 1'b1;
            i_s_axi_wready  <= 1'b0;
            if (s_axi_awvalid && i_s_axi_awready) begin
                i_s_axi_awready <= 1'b0;
                i_s_axi_wready  <= 1'b1;
                waddr           <= s_axi_awaddr[ADDR_BITS-1:2];
                wstate          <= WRDATA;
            end
        end
        WRDATA: begin
            if (s_axi_wvalid && i_s_axi_wready) begin
                if (waddr == REG_CMD_STA) begin
                    wr_counter     <= 8'h0;
                    i_s_axi_bvalid <= 1'b1;
                end else if (waddr == REG_STREAM) begin
                    if (|wr_counter == 1'b0) begin
                        activator_index <= s_axi_wdata[7:0];
                        if (s_axi_wdata[31:28] == WRITE_QUERY) begin
                            wr_counter <= s_axi_wdata[23:16];
                        end
                    end else begin
                        wr_counter <= wr_counter - 1'b1;
                    end
                    i_drm_to_uip0_tvalid <= 1'b1;
                    i_drm_to_uip0_tdata  <= s_axi_wdata[31:0];
                    i_drm_to_uip0_tlast  <= ~(|wr_counter[7:1]);
                end else if (waddr >= REG_READ_WRITE_MAILBOX) begin
                    mailbox[waddr] <= s_axi_wdata;
                    i_s_axi_bvalid <= 1'b1;
                end
                i_s_axi_wready <= 1'b0;
                wstate <= WRRESP;
            end
        end
        WRRESP: begin
            if (waddr == REG_STREAM && drm_to_uip0_tready) begin
                i_drm_to_uip0_tvalid    <= 1'b0;
                i_s_axi_bvalid <= 1'b1;
            end
            if (s_axi_bready && i_s_axi_bvalid) begin
                i_s_axi_bvalid <= 1'b0;
                wstate <= WRIDLE;
            end
        end
        default: begin
            wstate = WRIDLE;
        end
    endcase
  end
end


//------------------------AXI read fsm-------------------

assign uip0_to_drm_tready = i_uip0_to_drm_tready;

assign s_axi_arready = i_s_axi_arready;
assign s_axi_rresp   = 2'b00;  // OKAY
assign s_axi_rvalid  = i_s_axi_rvalid;
assign s_axi_rdata   = i_s_axi_rdata;

// read FSM
always @(posedge drm_aclk) begin
  if (~drm_arstn) begin
    i_s_axi_arready      <= 1'b0;
    i_s_axi_rvalid       <= 1'b0;
    i_uip0_to_drm_tready <= 1'b0;
    raddr                <= {ADDR_BITS{1'b0}};
    i_s_axi_rdata        <= 32'b0;
    rstate               <= RDRESET;
  end else begin
    case (rstate)
        RDIDLE: begin
            i_s_axi_arready      <= 1'b1;
            i_s_axi_rvalid       <= 1'b0;
            i_uip0_to_drm_tready <= 1'b0;
            if (s_axi_arvalid && i_s_axi_arready) begin
                i_s_axi_arready <= 1'b0;
                raddr           <= s_axi_araddr[ADDR_BITS-1:2];
                rstate          <= RDDATA;
            end
        end
        RDDATA: begin
            if (raddr == REG_STREAM) begin
                if (~i_s_axi_rvalid) begin
                    i_uip0_to_drm_tready <= 1'b1;
                end
                if (uip0_to_drm_tvalid && i_uip0_to_drm_tready) begin
                    i_uip0_to_drm_tready    <= 1'b0;
                    i_s_axi_rvalid <= 1'b1;
                    i_s_axi_rdata  <= uip0_to_drm_tdata;
                end
            end else begin
                i_s_axi_rvalid <= 1'b1;
                if (raddr == REG_CMD_STA) begin
                    i_s_axi_rdata  <= REG_VERSION;
                end else begin
                    i_s_axi_rdata  <= mailbox[raddr];
                end
            end
            if (s_axi_rready && i_s_axi_rvalid) begin
                i_s_axi_rvalid <= 1'b0;
                rstate <= RDIDLE;
            end
        end
        default: begin
            rstate <= RDIDLE;
        end
    endcase
  end
end

endmodule
`default_nettype wire
