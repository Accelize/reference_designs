---------------------------------------------------------------------
----
---- DRM_IP_ACTIVATOR_0x1003001E00010001
---- vhdl component declaration example
---- AUTOGENERATED FILE - DO NOT EDIT
---- DRM SCRIPT VERSION 2.2.0
---- DRM HDK VERSION 7.0.0.0
---- DRM VERSION 7.0.0
---- COPYRIGHT (C) ALGODONE
----
---------------------------------------------------------------------

component DRM_IP_ACTIVATOR_0x1003001E00010001 is
   port (
    -- drm bus clock and reset
    DRM_ACLK                   : in  std_logic;
    DRM_ARSTN                  : in  std_logic;
    -- ip core clock and reset
    IP_CORE_ACLK               : in  std_logic;
    IP_CORE_ARSTN              : in  std_logic;
    -- axi-4 stream interface
    RECEIVE_TREADY  : out  std_logic;
    RECEIVE_TDATA   : in  std_logic_vector(31 downto 0);
    RECEIVE_TVALID  : in  std_logic;
    RECEIVE_TLAST   : in  std_logic;
    SEND_TREADY     : in  std_logic;
    SEND_TDATA      : out std_logic_vector(31 downto 0);
    SEND_TVALID     : out  std_logic;
    SEND_TLAST      : out  std_logic;
    -- ip core interface
    DRM_EVENT                   : in  std_logic;
    DRM_ARST                    : in  std_logic;
    ACTIVATION_CODE_READY       : out std_logic;
    DEMO_MODE                   : out std_logic;
    ACTIVATION_CODE             : out std_logic_vector(127 downto 0)      
  );
end component DRM_IP_ACTIVATOR_0x1003001E00010001;

---------------------------------------------------------------------
----
---- DRM_IP_ACTIVATOR_0x1003001E00010001
---- vhdl component instantiation example
---- AUTOGENERATED FILE - DO NOT EDIT
---- DRM SCRIPT VERSION 2.2.0
---- DRM HDK VERSION 7.0.0.0
---- DRM VERSION 7.0.0
---- COPYRIGHT (C) ALGODONE
----
---------------------------------------------------------------------

DRM_IP_ACTIVATOR_0x1003001E00010001_INST : DRM_IP_ACTIVATOR_0x1003001E00010001
  port map (
    DRM_ACLK        => DRM_ACLK,
    DRM_ARSTN       => DRM_ARSTN,
    -- ip core clock and reset
    IP_CORE_ACLK    => IP_CORE_ACLK,
    IP_CORE_ARSTN   => IP_CORE_ARSTN,
    RECEIVE_TREADY  => RECEIVE_TREADY,
    RECEIVE_TDATA   => RECEIVE_TDATA,
    RECEIVE_TVALID  => RECEIVE_TVALID,
    RECEIVE_TLAST   => RECEIVE_TLAST,
    SEND_TREADY     => SEND_TREADY,
    SEND_TDATA      => SEND_TDATA,
    SEND_TVALID     => SEND_TVALID,
    SEND_TLAST      => SEND_TLAST,
    -- ip core interface
    DRM_EVENT              => DRM_EVENT,
    DRM_ARST               => DRM_ARST,
    ACTIVATION_CODE_READY  => ACTIVATION_CODE_READY,
    DEMO_MODE              => DEMO_MODE,
    ACTIVATION_CODE        => ACTIVATION_CODE   
  );