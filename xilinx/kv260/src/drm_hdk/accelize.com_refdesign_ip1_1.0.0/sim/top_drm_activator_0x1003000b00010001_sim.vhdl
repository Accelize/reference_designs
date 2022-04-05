-- pragma translate_off
---------------------------------------------------------------------
----
---- Copyright (C) 2022 Accelize
----
---- This is a generated file. Use and modify at your own risk.
---------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;

library DRM_0X1003000B00010001_LIBRARY;
use DRM_0X1003000B00010001_LIBRARY.all;

use WORK.drm_activator_0x1003000b00010001_sim_pkg.all;


entity top_drm_activator_0x1003000b00010001 is
port (
  -- AXI4-Stream Bus clock and reset
  drm_aclk              : in  std_logic;
  drm_arstn             : in  std_logic;
  -- AXI4-Stream Bus from DRM Controller
  drm_to_uip_tready     : out std_logic;
  drm_to_uip_tvalid     : in  std_logic;
  drm_to_uip_tdata      : in  std_logic_vector(31 downto 0);
  drm_to_uip_tlast      : in  std_logic;
  -- AXI4-Stream Bus to DRM Controller
  uip_to_drm_tready     : in  std_logic;
  uip_to_drm_tvalid     : out std_logic;
  uip_to_drm_tdata      : out std_logic_vector(31 downto 0);
  uip_to_drm_tlast      : out std_logic;
  -- IP core interface
  metering_event        : in  std_logic;
  activation_code       : out std_logic_vector(127 downto 0)
);
end entity top_drm_activator_0x1003000b00010001;

architecture top_drm_activator_0x1003000b00010001_rtl of top_drm_activator_0x1003000b00010001 is

  constant POR_DURATION      : integer := 16;
  constant GND               : std_logic := '0';

  signal por_shifter         : std_logic_vector(POR_DURATION-1 downto 0) := (others=>'0'); -- init for simulation
  signal i_ip_core_arstn     : std_ulogic;

  signal i_drm_to_uip_tready : std_ulogic;
  signal i_drm_to_uip_tvalid : std_ulogic;
  signal i_drm_to_uip_tdata  : std_logic_vector(31 downto 0);
  signal i_drm_to_uip_tlast  : std_ulogic;

  signal i_uip_to_drm_tready : std_ulogic;
  signal i_uip_to_drm_tvalid : std_ulogic;
  signal i_uip_to_drm_tdata  : std_logic_vector(31 downto 0);
  signal i_uip_to_drm_tlast  : std_ulogic;


  -- For simulation only with USE_BFM = true
  signal license_file_loaded   : std_ulogic;
  signal activation_cycle_done : std_ulogic;
  signal error_code            : std_logic_vector(7 downto 0);
  signal i_drm_bfm_arstn       : std_ulogic;

begin

  -----------------
  -- Generate POR
  -----------------

  i_ip_core_arstn <= por_shifter(POR_DURATION-1);

  por_proc: process (drm_aclk)
  begin
    if rising_edge(drm_aclk) then
      por_shifter(0)                       <= '1';
      por_shifter(POR_DURATION-1 downto 1) <= por_shifter(POR_DURATION-2 downto 0);
    end if;
  end process;


  ---------------------------------
  -- Map activator to AXI4-Stream
  ---------------------------------

  WITH_BFM: if USE_BFM=TRUE generate

    i_drm_bfm_arstn   <= drm_arstn and drm_to_uip_tvalid and and_reduce(drm_to_uip_tdata) and drm_to_uip_tlast;

    process(drm_aclk) begin
      if rising_edge(drm_aclk) then
        if drm_arstn = '0' then
          uip_to_drm_tvalid <= '0';
        else
          uip_to_drm_tvalid <= '1';
        end if;
      end if;
    end process;

    uip_to_drm_tdata  <= (others=>drm_arstn);
    uip_to_drm_tlast <= '1';

    drm_to_uip_tready <= uip_to_drm_tready;


    drm_controller_bfm_inst: entity DRM_0X1003000B00010001_LIBRARY.DRM_CONTROLLER_BFM
      generic map (
        LICENSE_FILE           => DRM_LICENSE_FILE,
        LICENSE_TIMER          => "",
        ENABLE_MESSAGE_DISPLAY => ENABLE_MESSAGE
      )
      port map (
        -- DRM clock and reset
        DRM_ACLK               => drm_aclk,
        DRM_ARSTN              => i_drm_bfm_arstn,
        -- DRM Bus inte  rface
        SEND_TREADY            => i_drm_to_uip_tready,
        SEND_TVALID            => i_drm_to_uip_tvalid,
        SEND_TDATA             => i_drm_to_uip_tdata,
        SEND_TLAST             => i_drm_to_uip_tlast,
        RECEIVE_TREADY         => i_uip_to_drm_tready,
        RECEIVE_TVALID         => i_uip_to_drm_tvalid,
        RECEIVE_TDATA          => i_uip_to_drm_tdata,
        RECEIVE_TLAST          => i_uip_to_drm_tlast,
        -- BFM status
        LICENSE_FILE_LOADED    => license_file_loaded,
        ACTIVATION_CYCLE_DONE  => activation_cycle_done,
        ERROR_CODE             => error_code
      );

  end generate;


  WITHOUT_BFM: if USE_BFM=FALSE generate

    drm_to_uip_tready   <= i_drm_to_uip_tready;
    i_drm_to_uip_tvalid <= drm_to_uip_tvalid;
    i_drm_to_uip_tdata  <= drm_to_uip_tdata;
    i_drm_to_uip_tlast  <= drm_to_uip_tlast;

    i_uip_to_drm_tready <= uip_to_drm_tready;
    uip_to_drm_tvalid   <= i_uip_to_drm_tvalid;
    uip_to_drm_tdata    <= i_uip_to_drm_tdata;
    uip_to_drm_tlast    <= i_uip_to_drm_tlast;

  end generate;


  drm_ip_activator_0x1003000b00010001_inst: entity DRM_0X1003000B00010001_LIBRARY.drm_ip_activator_0x1003000b00010001
  port map (
    DRM_ACLK              => drm_aclk,
    DRM_ARSTN             => drm_arstn,
    SEND_TREADY           => i_uip_to_drm_tready,
    SEND_TVALID           => i_uip_to_drm_tvalid,
    SEND_TDATA            => i_uip_to_drm_tdata,
    SEND_TLAST            => i_uip_to_drm_tlast,
    RECEIVE_TREADY        => i_drm_to_uip_tready,
    RECEIVE_TVALID        => i_drm_to_uip_tvalid,
    RECEIVE_TDATA         => i_drm_to_uip_tdata,
    RECEIVE_TLAST         => i_drm_to_uip_tlast,
    IP_CORE_ACLK          => drm_aclk,
    IP_CORE_ARSTN         => i_ip_core_arstn,
    DRM_EVENT             => metering_event,
    DRM_ARST              => GND,
    ACTIVATION_CODE_READY => open,
    DEMO_MODE             => open,
    ACTIVATION_CODE       => activation_code
  );

end architecture top_drm_activator_0x1003000b00010001_rtl;
-- pragma translate_on
