; $ID: wrf_contour_h_wind_tp_tiff.ncl V01 08/29/2012 23:22 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_h_wind_tp_tiff PLOTS THE CROSS SECTION OF WRFCHEM 
;  OUTPUT AND WIND ALONG TWO POINTS ON THE MAP.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/29/2012)
;******************************************************************************

;  LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/usr/local/vapor/vapor-2.1.0/share/examples/NCL/wrf2geotiff.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/tiff_wrf_contour_vector_h.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/tiff_wrf_contour_vector_h_monthly.ncl"

begin

;  SET UP THE PLOT PLATFORM
;  type = "x11"
;  type = "pdf"
   type = "ps"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_contour_h_wind_tp_sahel_sn_v01")
   wrf2gtiff = wrf2geotiff_open(wks)
;  wrf2geotiff_disableGeoTags(wrf2gtiff)
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  ASSIGNMENT CONSTANT AND ABBRAVIATION
   bv1       = -9999. 
   bv2       = -9999
   nfv       = "No_FillValue"
   str       = "string"
   kmtom     = 1000.

;  READ WRFCHEM OUTPUT NC FILE
;  THIS NEEDS TO HAVE A ".nc" APPENDED
   dirn      = "/home/bruce/sshfs/tw/model/wrfchem33_2/WRFV3/test/em_real/wrfout_sahel_fb/"
   filelistn = "2008_wrfout_d01"
   namen     = asciiread(dirn+filelistn, -1, str)
   nfnamen   = dimsizes(namen)
   daten     = new((/nfnamen/), string, nfv)
   timen     = new((/nfnamen/), string, nfv)

;  READ OUT DATE AND TIME OF WRFCHEM INTO AN ARRARY
   do i = 0, nfnamen-1
    daten(i) = str_get_cols(namen(i), 11, 20)
    timen(i) = str_get_cols(namen(i), 22, 23)
   end do
   yyyymm    = str_get_cols(namen(0), 11, 17)

;  DEFINE THE HEIGHT LEVELS
;  MINIMUM HEIGHT, MAXIMUM HEIGHT, INTERVAL
   minh      = 0.
   maxh      = 15.
   deltah    = 0.06
   inth      = 251
   height    = fspan(minh, maxh, inth)

;  SPECIFY DIRECTION AND SELECTED POINT
;  FOR SAHEL CASE, THE SELECTED POINTS LISTED BELOW
;  sn : 30, 55, 70
;  we : 20, 30, 45
   wesn      = "sn"
   np        = 55
   npts      = 6

;  GET THE DIMENSION OF VARIABLES
   a         = addfile(dirn+namen(0) + ".nc", "r")
   variable  = wrf_user_getvar(a, "PM2_5_DRY", 0)
   ndim      = dimsizes(variable)
   nleveln   = ndim(0)
   nlatn     = ndim(1)
   nlonn     = ndim(2)

;  DEFINE NEW ARRAYS FOR PLOT
   pm25h_monthly = new((/inth, nlatn, nlonn/), float)
   pth_monthly   = new((/inth, nlatn, nlonn/), float)
   plot1     = new(1, graphic)
   plot2     = new(1, graphic)

;  DO THE FILE LOOP TO READ VARIABLES
   pm25h_monthly = 0.0
   pth_monthly   = 0.0
   icount        = 0
   do i = 0, 0;nfnamen-1
    print("NOW WORKING ON : " + daten(i) + "_" + timen(i))
    fn       = addfile(dirn+namen(i) + ".nc", "r")
    pm25n    = wrf_user_getvar(fn, "PM2_5_DRY", 0)
    ptn      = wrf_user_getvar(fn, "T", 0)
    zn       = wrf_user_getvar(fn, "z", 0)
    uwind    = wrf_user_getvar(fn, "U", 0)
    vwind    = wrf_user_getvar(fn, "V", 0)
    wwind    = wrf_user_getvar(fn, "W", 0)
    latn     = wrf_user_getvar(fn, "XLAT", 0)
    lonn     = wrf_user_getvar(fn, "XLONG", 0)
    dimpm25n    = dimsizes(pm25n)
    nleveln     = dimpm25n(0)
    nlatn       = dimpm25n(1)
    nlonn       = dimpm25n(2)

;  DEFINE A NEW ARRAY FOR VERTICAL VARAIBLE
    pm25h      = new((/inth, nlatn,nlonn/),float, bv1)
    pth        = new((/inth, nlatn,nlonn/),float, bv1)

;  INTERPOLATE THE VARAIBLE TO THE VERTICAL PROFILE
    do ih = 0, inth-1 
     pm25h(ih,:,:)  = wrf_user_intrp3d(pm25n, zn, "h", height(ih)*kmtom, 0., False)
     pth(ih,:,:)    = wrf_user_intrp3d(ptn, zn, "h", height(ih)*kmtom, 0., False)
    end do
    pm25h_monthly = pm25h_monthly + pm25h
    pth_monthly   = pth_monthly + pth
    icount        = icount + 1

    if (wesn .eq. "sn") then
     ; CALL SUBROUTINE tiff_wrf_contour_vector_h.ncl TO PLOT WRF CROSS SECTION
     tiff_wrf_contour_vector_h \
     (wks, wrf2gtiff, fn, height, maxh, minh, nlatn, npts, latn(:, np), lonn(:, np), \
      daten(i), timen(i), pm25h(:, :, np), pth(:, :, np), plot1, plot2)
    else if (wesn .eq. "we") then
     ; CALL SUBROUTINE tiff_wrf_contour_vector_h.ncl TO PLOT WRF CROSS SECTION
     tiff_wrf_contour_vector_h \
     (wks, wrf2gtiff, fn, height, maxh, minh, nlonn, npts, latn(np, :), lonn(np, :), \
      daten(i), timen(i), pm25h(:, np, :), pth(:, np, :), plot1, plot2)
    end if
    end if

   end do

   plot1     = new(1, graphic)
   plot2     = new(1, graphic)

   pm25h_monthly = pm25h_monthly/icount
   pth_monthly   = pth_monthly/icount
   if (wesn .eq. "sn") then
    ; CALL SUBROUTINE tiff_wrf_contour_vector_h_monthly.ncl TO PLOT WRF CROSS SECTION
    tiff_wrf_contour_vector_h_monthly \
    (wks, wrf2gtiff, fn, height, maxh, minh, nlatn, npts, latn(:, np), lonn(:, np), \
     yyyymm, pm25h_monthly(:, :, np), pth_monthly(:, :, np), plot1, plot2)
   else if (wesn .eq. "we") then
    ; CALL SUBROUTINE tiff_wrf_contour_vector_h_monthly.ncl TO PLOT WRF CROSS SECTION
    tiff_wrf_contour_vector_h_monthly \
    (wks, wrf2gtiff, fn, height, maxh, minh, nlonn, npts, latn(np, :), lonn(np, :), \
     yyyymm, pm25h_monthly(:, np, :), pth_monthly(:, np, :), plot1, plot2)
   end if
   end if

end
