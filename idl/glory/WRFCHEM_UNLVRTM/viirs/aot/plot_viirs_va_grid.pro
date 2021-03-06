; $ID: plot_viirs_va.pro V01 04/15/2012 23:54 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_viirs_va READS AND PLOTS NPP VIIRS AOT DATA.
;  FILENAME :
;  VAOOO_npp_d20120401_t0000292_e0001534_b02208_c20120401123139183153_noaa_ops.h5
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/15/2012)
;  (2 ) AEROSOL OPTICAL DEPTH FACTORS AND ANGSTROM EXPONENT FACTORS:
;       A 32-BIT FLOATING POINT ARRAY CONSISTING OF TWO ELEMENTS:
;       THE FIRST IS THE SCALE VALUE; THE SECOND IS THE OFFSET VALUE.
;       (BRUCE. 04/28/2012)
;******************************************************************************

;  LOAD PROCEDURES AND FUNCTIONS
@/home/bruce/program/idl/idl_lib/process_day_va_npp.pro
@/home/bruce/program/idl/idl_lib/read_viirs_h5_sds.pro
@/home/bruce/program/idl/idl_lib/color_imagemap.pro
@/home/bruce/program/idl/idl_lib/pixel_to_grid.pro
@/home/bruce/program/idl/idl_lib/plot_single_gradule_mod04_myct.pro

;  SET UP NPP VIIRS DATA DIRECTORY AND FILE NAMES LIST
   dir   = '/home/bruce/sshfs/pfw/data/satellite/NPP/texas/'
   flist = 'va_list'
   glist = 'gaero_list'
;  LOAD COLOR TABLE
   MYCT, 33, ncolors = 102, range = [0.0, 1]

;  CALL SUBROUTINE process_day_ivaot_npp TO READ FILE NAMES INFO FROM FILE LIST
   process_day_va_npp, dir + flist, Nday, AllFileName, StartInx, EndInx, $
                          YEAR=year, Mon=mon, Date=Date, TimeS = TimeS,  $
                          TimeE = TimeE, Dayname, DAYNUM
   process_day_va_npp, dir + glist, gNday, gAllFileName, gStartInx, gEndInx, $
                          YEAR=gyear, Mon=gmon, Date=gDate, TimeS = gTimeS,  $
                          TimeE = gTimeE, gDayname, gDAYNUM

   PRINT, 'Nday : ', Nday
   PRINT, 'AllFileName : ', AllFileName
   PRINT, 'StartInx : ', StartInx
   PRINT, 'EndInx : ', EndInx
   PRINT, 'TimeS : ', TimeS
   PRINT, 'TimeE : ', TimeE
   PRINT, 'Dayname : ', Dayname
   PRINT, 'DAYNUM : ', DAYNUM

;  DEFINE THE GRID NUMBER IN EACH GRANULE
   np     = 96L
   nl     = 400L
   minaod = 0.0
   maxaod = 2.0
   bv3    = 0.0
;  DEFINE NEW GRID SIZE
   minpixel= 1
   new_grid= 0.2

;  SET UP STUDY REGION
;           TEXAS    ; WA     ; SAHEL   GLOBAL
   maxlat = 40.0     ; 45.0   ; 35.0     90.0
   minlat = 25.0     ; 30.0   ;-10.0    -90.0
   maxlon =-90.0     ;-110.0  ; 45.0    180.0
   minlon =-110.0    ;-130.0  ;-25.0   -180.0 
   region = [minlat, minlon, maxlat, maxlon]
;  GRID SIZE 
   gridsize_lat = CEIL((maxlat-minlat)/new_grid)
   gridsize_lon = CEIL((maxlon-minlon)/new_grid)
;  DEFINE 1-DIMENSIONAL ARRAY FOR LATITUDE, LONGITUDE, AND 
;  MEAN OF AOD
   grid_lat = FLTARR(gridsize_lat) 
   grid_lon = FLTARR(gridsize_lon)
   meanaod  = FLTARR(gridsize_lon,gridsize_lat)
;  ASSIGN VALUE TO GRIDED LATITUDE AND LONGITUDE
   FOR k = 0, gridsize_lat-1 DO BEGIN
    grid_lat(k) = minlat + new_grid*k
   ENDFOR 
   FOR l = 0, gridsize_lon-1 DO BEGIN
    grid_lon(l) = minlon + new_grid*l
   ENDFOR


;  DO LOOP OF # OF FILE NAMES
   FOR i = 0, Nday-1 DO BEGIN
    n  = endinx(i) - startinx(i) + 1
;  DEFINE THE TOTAL DIMENSION SIZE OF ALL THE GRANULES
   tnp = np
   tnl = nl*(n+1)

;  EXTRACT DATE FROM FILE NAME
    date = STRARR(n)
    FOR nc = 0, n-1 DO BEGIN
     date(nc) = STRMID(Allfilename(startinx(i)), 0, 19)
    ENDFOR
    PRINT, 'NOW WORKING ON : ', date(0)
;  OPEN A NEW FILE TO WRITE GRIDED LATITUDE, LONGITUDE, AND 
;  MEAN OF AOD
    file = date(0) + '_grid.txt'
    OPENW, lun, file, /get_lun
    filename  = Allfilename(startinx(i):endinx(i))
    gfilename = gAllfilename(startinx(i):endinx(i))
    zcount = 0
;  DO LOOP OF FILES IN ONE DAY TO READ LATITUDE, LONGITUDE, AND 
;  MEAN OF AOD INTO ONE 1-DIMENSIONAL ARRAY
    lat   = FLTARR(tnp, tnl)
    lon   = FLTARR(tnp, tnl)
    aod   = FLTARR(tnp, tnl)
    FOR j = 0L, n-1 DO BEGIN
;  CALL SUBROUTINE read_viirs_h5_sds.pro TO READ VARIABLES FROM NPP DATA
     slat = '/All_Data/VIIRS-Aeros-EDR-GEO_All/Latitude'
     rlat = read_viirs_h5_sds(dir + gfilename(j), slat)
     slon = '/All_Data/VIIRS-Aeros-EDR-GEO_All/Longitude'
     rlon = read_viirs_h5_sds(dir + gfilename(j), slon)
     sfac = '/All_Data/VIIRS-Aeros-EDR_All/AerosolOpticalDepthFactors'
     rfac = read_viirs_h5_sds(dir + filename(j), sfac)
     saod = '/All_Data/VIIRS-Aeros-EDR_All/AerosolOpticalDepth_at_550nm'
     raod = read_viirs_h5_sds(dir + filename(j), saod)
     index1 = WHERE(rlat LT -90.0, nindex1)
     IF (nindex1 GT 0) THEN BEGIN
      rlat(index1) = 0.0
      raod(index1) = 0.0
     ENDIF
     index2 = WHERE(rlon LT -180.0, nindex2)
     IF (nindex2 GT 0) THEN BEGIN
      rlon(index2) = 0.0
      raod(index2) = 0.0
     ENDIF
     index3 = WHERE(raod EQ max(raod), nindex3)
     IF (nindex3 GT 0) THEN BEGIN
      raod(index3) = bv3
     ENDIF
     lat(0:(np-1), (nl*j):(nl*(j+1)-1))   = rlat
     lon(0:(np-1), (nl*j):(nl*(j+1)-1))   = rlon
     aod(0:(np-1), (nl*j):(nl*(j+1)-1))   = raod*rfac(0) + rfac(1)
    ENDFOR

;  CALL SUBROUTINE pixel_to_grid.pro TO INTERPOLATE AOD INTO 
;  GRID BOX
   pixel_to_grid, grid_lat, grid_lon, gridsize_lon, gridsize_lat, $
                  lat, lon, tnp, tnl, minpixel, aod, meanaod
;  PLOT THE AOD GRID ONTO MAP
    SET_PLOT, 'ps'
    DEVICE, filename = 'plot_viirs_' +                            $
            STRMID(AllFileName(StartInx(i)), 0, 19) + '_grid.ps', $
            xsize = 7., ysize=10, xoffset = 0.5, yoffset = 0.5,   $
            /inches, /color, bits=8
    title = 'AOD(VIIRS VA 550nm) ' +                   $
            STRMID(AllFileName(StartInx(i)), 11, 17) + $
            STRMID(AllFileName(EndInx(i)), 28, 9)
;  LOAD COLOR TABLE
    TVMAP, meanaod, /grid, LIMIT=[minlat, minlon, maxlat, maxlon],             $
           /ISOTROPIC, sample = 4, title = title, /cbar,DIVISIONS = 6,         $
           maxdata = maxaod, mindata = minaod, CBMIN = minaod, CBMAX = maxaod, $
           /COUNTRIES, /COAST, /USA, MIN_VALID = minaod

    DEVICE, /close
    FREE_LUN, lun
   ENDFOR

END
