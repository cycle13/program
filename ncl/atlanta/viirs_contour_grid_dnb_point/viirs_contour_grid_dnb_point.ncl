;  $ID: viirs_contour_grid_dnb_point.ncl V01 02/18/2014 23:14 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_contour_grid_dnb_point READS VIIRS PIXEL DATA AND GRID IT 
;  INTO DIFFERENT GRID BOX SIZE IN DEGREE, PLOTS IT AS CONTOUR AND ADD A 
;  POINT ON IT.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/31/2013)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/process_day_viirs.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/read_viirs_rad_1day.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/select_viirs_point_hourly_pixel.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/pixel_to_grid_degree_1day.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/plot_viirs_contour_rad_point.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_viirs_contour_grid_dnb_point_v01")
   gsn_define_colormap(wks,"gsdtol")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.
   logic_leap = "leap"
   nfactor    = 100000000

;  SET DIRECTORY AND FILE NAME FOR VIIRS RADIANCE
   dir        = "/Volumes/TOSHIBA_3B/iproject/atlanta/viirs/night/"
   gflist     = "GDNBO_list_jun"
   vflist     = "SVDNB_list_jun"
   gfname     = asciiread(dir + gflist, -1, "string")
   vfname     = asciiread(dir + vflist, -1, "string")
   ngfname    = dimsizes(gfname)
   nvfname    = dimsizes(vfname)

;  SET UP LIMITED REGION FOR ATLANTA
   minlat     = 25.0
   maxlat     = 40.0
   minlon     =-100.0
   maxlon     =-70.0
;  GRID INTERVAL
   lat_interval = 1.0
   lon_interval = 1.0

;  ATLANTA INFO
   nsite      = 1
   site_lat   = new((/nsite/), float, bv2)
   site_lon   = new((/nsite/), float, bv2)
   site_lat   =  33.745
   site_lon   = -84.390
;  CALCULATE GRID SIZE DEPENDING ON GRID INTERVAL AND REGION LIMIT
   nlat       = floattoint((maxlat-minlat)/lat_interval) + 1
   nlon       = floattoint((maxlon-minlon)/lon_interval) + 1

;  DECLARE VARIABLES FOR SUBROUTINE process_day_viirs
   tmpnday    = 182
   nday       = new(1, integer, bv1)
   startinx   = new(tmpnday, integer, bv1)
   endinx     = new(tmpnday, integer, bv1)
   year       = new(tmpnday, integer, bv1)
   mon        = new(tmpnday, integer, bv1)
   date       = new(tmpnday, integer, bv1)
   times      = new(tmpnday, integer, bv1)
   timee      = new(tmpnday, integer, bv1)
   dayname    = new(tmpnday, string,  bv0)
   daynum     = new(tmpnday, integer, bv1)

;  CALL SUBROUTINE process_day_viirs.ncl TO READ OUT INFO FROM VIIRS FILE NAME
   process_day_viirs(dir, gflist, logic_leap,          \
                     nday, startinx, endinx, year, mon,\
                     date, times, timee, dayname, daynum)

;  DECLARE VARIABLES FOR SUBROUTINE read_viirs_rad_1day.ncl
   mnp        = 768
   mnl        = 4064
   mfactor    = 5
   tmnp       = mnp*mfactor
   date_title = new((/1/), string, bv0)
   mlat       = new((/tmnp, mnl/), float, bv2)
   mlon       = new((/tmnp, mnl/), float, bv2)
   mrad       = new((/tmnp, mnl/), float, bv2)
   mrad_qf    = new((/tmnp, mnl/), integer, bv1)
   msza       = new((/tmnp, mnl/), float, bv2)
   msaa       = new((/tmnp, mnl/), float, bv2)
   mmp        = new((/tmnp, mnl/), float, bv2)
   mlza       = new((/tmnp, mnl/), float, bv2)
   mlaa       = new((/tmnp, mnl/), float, bv2)

;  DECLARE VARIABLES FOR SUBROUTINE pixel_to_grid_degree_1day.ncl
   grid_lat   = new((/nlat, nlon/), float, bv2)
   grid_lon   = new((/nlat, nlon/), float, bv2)
   grid_rad   = new((/nlat, nlon/), float, bv2)

;  ATLANTA INFO
   nsite         = 1
   site_lat      = new((/nsite/), float, bv2)
   site_lon      = new((/nsite/), float, bv2)
   select_rad    = new((/nsite/), float, bv2)
   select_radstd = new((/nsite/), float, bv2)
   select_pm     = new((/nsite/), float, bv2)
   select_pmstd  = new((/nsite/), float, bv2)
   select_sza    = new((/nsite/), float, bv2)
   select_mp     = new((/nsite/), float, bv2)
   select_lza    = new((/nsite/), float, bv2)
   site_lat      =  33.745
   site_lon      = -84.390
   select_rad    = 0
   select_radstd = 0
   select_pm     = 0
   select_pmstd  = 0
   select_sza    = 0
   select_mp     = 0
   select_lza    = 0

;  DO DAY LOOP
   mrad     = 0.0
   grid_rad = 0.0
   do iday = 0, 15;nday-1

    system("date") 
    date_display = year(iday) + "-" + mon(iday) + "-" + date(iday)
    print("DATE : " + date_display)

;  CALL SUBROUTINE read_viirs_rad_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  RADIANCE QUALITY FLAG, AND RADIANCE FOR ONE DAY.
    read_viirs_rad_1day \
   (dir, bv0, iday, startinx, endinx, gfname, vfname, \
    date_title, mlat, mlon, mrad_qf, mrad, msza, msaa, mmp, mlza, mlaa)
    mrad = mrad*nfactor

    do isite = 0, nsite-1

;  CALL SUBROUTINE select_viirs_point_hourly_pixel.ncl TO SELECT AND CALCULATE VIIRS DATA 
;  AND SITE OBSERVED DATA
       select_viirs_point_hourly_pixel \
      (iday, bv2, site_lat(isite), site_lon(isite), mlat, mlon, mrad, msza, mmp, mlza, \
       select_rad(isite), select_radstd(isite), select_sza(isite), select_mp(isite), select_lza(isite))

    end do

;  CALL SUBROUTINE pixel_to_grid_degree_1day.ncl TO GRID RADIANCE DATA
    pixel_to_grid_degree_1day \
    (lat_interval, lon_interval, minlat, maxlat, minlon, maxlon, \
     nlat, nlon, mlat, mlon, mrad_qf, mrad, grid_lat, grid_lon, grid_rad)

    grid_rad@lat2d = grid_lat
    grid_rad@lon2d = grid_lon

;  CALL SUBROUTINE plot_viirs_contour_rad_point.ncl TO PLOT RADIANCE CONTOUR
    plot_viirs_contour_rad_point  \
    (wks, date_title, nsite, minlat, maxlat, minlon, maxlon, site_lat, site_lon, \
     avg(select_sza), avg(select_mp), avg(select_lza), grid_rad)

    delete([/date_display/])
   end do

end