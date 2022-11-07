---------------------------------------------------------------------
----
---- List the parameters used for simulation only.
---- Copyright (C) 2022 Accelize
----
---------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package drm_activator_0x1003001e00010001_sim_pkg is

  -- Enable/Disable the BFM usage.
  -- For synthesis and co-simulation it MUST be set to FALSE
  -- For RTL simulation it MUST be set to TRUE
  constant USE_BFM : boolean  := TRUE;

  -- Specify the path to a valid DRM License XML file used by the Controller BFM
  -- It is used to unlock the DRM Activator.
  constant DRM_LICENSE_FILE : string  := "absolute/path/to/drm_hdk/activator/sim/drm_activator_0x1003001e00010001_license_file.xml";

  -- Enable/disable the DRM messaging system of the Controller BFM
  -- Only supported on questasim/modelsim, otherwise keep it to 0.
  constant ENABLE_MESSAGE : boolean := FALSE;

end package drm_activator_0x1003001e00010001_sim_pkg;
