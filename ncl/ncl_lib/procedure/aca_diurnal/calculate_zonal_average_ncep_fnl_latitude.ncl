;  $ID: calculate_zonal_average_ncep_fnl_latitude.ncl V01 08/09/2015 20:18 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_zonal_average_ncep_fnl_latitude.ncl CALCULATES THE ZONAL 
;  AVERAGE OF SELECTED VARIABLES FROM NCEP FNL FILE. THE AVERAGED ZONE SIZE CAN 
;  BE FLEXIBLE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) lat2         (1-D):REGRID LATITUDE SIZE                           [DEG]
;  (2 ) ilat    (a scalar):INDEX OF lat2                                  [   ]
;  (3 ) minlon  (a scalar):MINIMUM LONGITUDE OF THE STUDY REGION          [DEG]
;  (4 ) maxlon  (a scalar):MAXIMUM LONGITUDE OF THE STUDY REGION          [DEG]
;  (5 ) lat          (1-D):NCEP FNL LATITUDE                              [DEG]
;  (6 ) lon          (1-D):NCEP FNL LONGITUDE                             [DEG]
;  (7 ) hgt          (3-D):NCEP FNL GEOPOTENTIAL HEIGHT                   [gpm]
;  (8 ) tmpc         (3-D):NCEP FNL TEMPERATURE                           [C  ]
;  (9 ) tdc          (3-D):NCEP FNL DEW POINT TEMPERATURE                 [C  ]
;  (10) u            (3-D):NCEP FNL U-WIND COMPONENT                      [m/s]
;  (11) v            (3-D):NCEP FNL V-WIND COMPONENT                      [m/s]
;  (12) vvel         (3-D):NCEP FNL VERTICAL VELOCITY (PRESSURE)         [Pa/s]
;  (13) wspd         (3-D):NCEP FNL WIND SPEED                            [m/s]
;  (14) wdir         (3-D):NCEP FNL WIND DIRECTION                        [DEG]
;  (15) hgt_hour     (2-D):SELECTED NCEP FNL GEOPOTENTIAL HEIGHT          [gpm]
;  (16) tmpc_hour    (2-D):SELECTED NCEP FNL TEMPERATURE                  [C  ]
;  (17) tdc_hour     (2-D):SELECTED NCEP FNL DEW POINT TEMPERATURE        [C  ]
;  (18) u_hour       (2-D):SELECTED NCEP FNL U-WIND COMPONENT             [m/s]
;  (19) v_hour       (2-D):SELECTED NCEP FNL V-WIND COMPONENT             [m/s]
;  (16) vvel_hour    (2-D):SELECTED NCEP FNL VERTICAL VELOCITY (PRESSURE)[Pa/s]
;  (17) wspd_hour    (2-D):SELECTED NCEP FNL WIND SPEED                   [m/s]
;  (18) wdir_hour    (2-D):SELECTED NCEP FNL WIND DIRECTION               [DEG]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/09/2015)
;******************************************************************************
undef("calculate_zonal_average_ncep_fnl_latitude")
procedure calculate_zonal_average_ncep_fnl_latitude \
          (lat2         :numeric, ilat         :integer,\;INPUT
           minlon       :numeric, maxlon       :numeric,\;INPUT
           lat          :float,   lon          :float,  \;INPUT
           hgt          :float,   tmpc         :float,  \;INPUT
           tdc          :float,   u            :float,  \;INPUT
           v            :float,   vvel         :float,  \;INPUT
           wspd         :float,   wdir         :float,  \;INPUT
           hgt_hour     :float,   tmpc_hour    :float,  \;OUTPUT
           tdc_hour     :float,   u_hour       :float,  \;OUTPUT
           v_hour       :float,   vvel_hour    :float,  \;OUTPUT
           wspd_hour    :float,   wdir_hour    :float)   ;OUTPUT

begin

;  SELECT THE INDICES OF LATITUDE WITH SELECTED GRID
   index_lat = ind(lat .gt. lat2(ilat) .and. \
                   lat .le. lat2(ilat+1))

   if (.not.all(ismissing(index_lat))) then
      hgt_hour  = dim_avg_n(hgt (:, index_lat, :), 1)
      tmpc_hour = dim_avg_n(tmpc(:, index_lat, :), 1)
      tdc_hour  = dim_avg_n(tdc (:, index_lat, :), 1)
      u_hour    = dim_avg_n(u   (:, index_lat, :), 1)
      v_hour    = dim_avg_n(v   (:, index_lat, :), 1)
      vvel_hour = dim_avg_n(vvel(:, index_lat, :), 1)
      wspd_hour = dim_avg_n(wspd(:, index_lat, :), 1)
      wdir_hour = dim_avg_n(wdir(:, index_lat, :), 1)
   end if

return
end
