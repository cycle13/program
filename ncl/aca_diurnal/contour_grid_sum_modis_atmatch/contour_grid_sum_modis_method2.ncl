;  $ID: contour_grid_sum_modis_method2.ncl V01 06/01/2015 15:01 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_grid_sum_modis_method2 READS GRIDDED GLOBAL ACA DATA GENERATED 
;  FROM DR. ZHIBO ZHANG, PLOTS MODIS CLOUD FRACTION OR ACA FREQUENCY AS 
;  CONTOUR WITH RASTERFILL.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/18/2015)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_aca_grid_file.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_region_aca_clear_cloud.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_landmask.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plot_contour_grid_sum_modis_method2_cf_cloud_aqua_v05")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DATA DIRECTORY
   wdir       = "/home/vy57456/zzbatmos_common/Exchange/For_Zhifeng/ACA_Data/"
   filelist   = "Global_list_2007_2014"
   wname      = asciiread(wdir+filelist, -1, "string")
   nwname     = dimsizes(wname)

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.

;  SET UP LIMITED REGION
   minlat     =-30.0
   maxlat     = 10.0
   minlon     =-20.0
   maxlon     = 20.0
;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)
;  SWITCH FOR BACKGROUND MAP
   switch_pg  = True

;  SET UP THE START TIME AND END TIME
   start_year = 2007
   end_year   = 2014
   start_month= 6
   end_month  = 8
   start_day  = 1

;  SET UP SEASONAL STRING: -DJF, -MMA, JJA, SON
   sstring    = "JJA"
;  RESTRICTION FOR FILE
;  FOR DAY TIME, don = "d"; FOR NIGHT TIME, don = "n"
   don        = "d"
;  FOR ADJUST just = "_adjust"; FOR NOADJUST just = "oadjust"
   just       = "_adjust"

;  SWITCH FOR SELECTED REGION
   switch_select_region = True
;  SWITHC FOR LAND AND SEA MASK
   switch_landsea_mask  = True

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily    = False
   logic_plot_monthly  = False
   logic_plot_seasonal = False
   logic_plot_yearly   = True

;  DEFINE THE GLOBAL GRID ARRAY TO HOLD ALL THE DAILY DATA
   nlat       = 180
   nlon       = 360

;  PREDEFINE THE TOTAL SELECTED SAMPLES IN THE STUDY REGION
;  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;  CAUTION: VARIOUS VARIABLE DEPENDING ON THE STUDY REGION SIZE
;  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   ndim_index = 200

;  SELECTED FILE NAME
   sfilename  = new(1, string)

;  DO YEAR LOOP
   MODIS_cf_yearly = new((/nlat, nlon/),   float, bv2)
   MODIS_cf_yearly = 0
   iyear_loop = 0
   do iyear = start_year, end_year
      MODIS_cf_seasonal = new((/nlat, nlon/),   float, bv2)
      MODIS_cf_seasonal = 0
;  DO MONTH LOOP
      imonth_loop = 0
      do imonth = start_month, end_month
;  CALCULATE # OF DAYS IN THIS MONTH
         lon_year = days_in_month(iyear, imonth)
         MODIS_cf_monthly  = new((/nlat, nlon/),   float, bv2)
         MODIS_cf_monthly  = 0
;  DO DAY LOOP
         iday_loop = 0
         do iday = start_day, lon_year
;  FOR EVERY ITERATION, ASSUME THE FILE NAME EXISTES
            logic_filename = True
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            stime   = siyear + "-" + simonth + "-" + siday
            print("Now Processing : " + stime)
            MODIS_cf_daily      = new((/nlat, nlon/),   float, bv2)
            MODIS_cf_daily      = 0

;  READ THE FILE DEPENDING ON THE YEAR, MONTH, DAY, AND DAYTIME AND NIGHTTIME
;  CALL SUBROUTINE select_aca_grid_file.ncl TO GET FILE NAME
            select_aca_grid_file \
            (wname, iyear, imonth, iday, don, just, sfilename, logic_filename)

            if (.not.logic_filename) then
               continue
            end if
;  CLEAR ALL THE VARIABLES BEFORE USING THEM
            if (iday   .gt. 1           .or. \
                imonth .gt. start_month .or. \
                iyear  .gt. start_year) then
               delete([/lat, lon,                                         \
                        sampled_grids_lat_index, sampled_grids_lon_index, \
                        CALIOP_cloud_count, CALIOP_ACA_count,             \
                        Terra_cf_total_mean/])
            end if

;  READ VARIABLES FROM GRID FILE
            a                       = addfile(wdir + sfilename + ".nc", "r")
            lat                     = a->lat_grids
            lon                     = a->lon_grids
            sampled_grids_lat_index = a->sampled_grids_lat_index
            sampled_grids_lon_index = a->sampled_grids_lon_index
            CALIOP_cloud_count      = a->CALIOP_cloud_count
            CALIOP_ACA_count        = a->CALIOP_ACA_count
            Terra_cf_total_mean     = a->Aqua_cf_total_mean
            Terra_cf_total_mean     = where(Terra_cf_total_mean .lt. 0.0, 0.0, Terra_cf_total_mean)

;  @@@@@@@@@@@@@@@@@@@@@@SWITCH FOR REGION SELECTION@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   if (switch_select_region) then
;  ======================WITH SELECTING THE REGION======================================
;  DEFINE OUTPUT ARRARY FOR SUBROUTINE region_aca_clear.ncl
            index               = new((/ndim_index/), integer, bv1)
            index_region        = new((/ndim_index/), integer, bv1)
            index_aca           = new((/ndim_index/), integer, bv1)
            index_clear         = new((/ndim_index/), integer, bv1)
            index_cloud         = new((/ndim_index/), integer, bv1)
            index_cloud_only    = new((/ndim_index/), integer, bv1)

;  CALL SUBROUTINE select_region_aca_clear_cloud.ncl TO SELECT DATA IN THE STUDY REGION AND 
;  JUDGE WHETHER THE GRID IS ACA, CLEAR, CLOUD, AND CLOUD ONLY
            select_region_aca_clear_cloud                      \
            (minlat, maxlat, minlon, maxlon, lat, lon,         \
             sampled_grids_lat_index, sampled_grids_lon_index, \
             CALIOP_cloud_count, CALIOP_ACA_count,             \
             index_region, index_aca, index_clear, index_cloud, index_cloud_only)

             index = index_cloud
;  DEFINE THE ACTUAL SIZE OF index
            if (all(ismissing(index))) then
               continue
            else
               dim_index_real  = ind(.not.ismissing(index))
               ndim_index_real = dimsizes(dim_index_real)
               if (all(ismissing(dim_index_real))) then
                  delete([/dim_index_real/])
                  continue
               end if
            end if

;  SUM MONTHLY, SEASONAL, AND YEARLY TOTAL
            do iindex = 0, ndim_index_real-1
              MODIS_cf_daily(sampled_grids_lat_index(index(iindex)),      \
                             sampled_grids_lon_index(index(iindex))) =    \
                             (/Terra_cf_total_mean(index(iindex))/)
              MODIS_cf_monthly(sampled_grids_lat_index(index(iindex)),    \
                               sampled_grids_lon_index(index(iindex))) =  \
              MODIS_cf_monthly(sampled_grids_lat_index(index(iindex)),    \
                               sampled_grids_lon_index(index(iindex))) +  \
                               (/Terra_cf_total_mean(index(iindex))/)
              MODIS_cf_seasonal(sampled_grids_lat_index(index(iindex)),   \
                                sampled_grids_lon_index(index(iindex))) = \
              MODIS_cf_seasonal(sampled_grids_lat_index(index(iindex)),   \
                                sampled_grids_lon_index(index(iindex))) + \
                                (/Terra_cf_total_mean(index(iindex))/)
              MODIS_cf_yearly(sampled_grids_lat_index(index(iindex)),     \
                              sampled_grids_lon_index(index(iindex))) =   \
              MODIS_cf_yearly(sampled_grids_lat_index(index(iindex)),     \
                              sampled_grids_lon_index(index(iindex))) +   \
                              (/Terra_cf_total_mean(index(iindex))/)
            end do
         else
;  ======================WITHOUT SELECTING THE REGION=================================
;  SUM MONTHLY TOTAL
            nsample = dimsizes(sampled_grids_lat_index)
            do isample = 0, nsample-1
              MODIS_cf_daily(sampled_grids_lat_index(isample),      \
                             sampled_grids_lon_index(isample)) =    \
                             (/Terra_cf_total_mean(isample)/)
              MODIS_cf_monthly(sampled_grids_lat_index(isample),    \
                               sampled_grids_lon_index(isample)) =  \
              MODIS_cf_monthly(sampled_grids_lat_index(isample),    \
                               sampled_grids_lon_index(isample)) +  \
                               (/Terra_cf_total_mean(isample)/)
              MODIS_cf_seasonal(sampled_grids_lat_index(isample),   \
                                sampled_grids_lon_index(isample)) = \
              MODIS_cf_seasonal(sampled_grids_lat_index(isample),   \
                                sampled_grids_lon_index(isample)) + \
                                (/Terra_cf_total_mean(isample)/)
              MODIS_cf_yearly(sampled_grids_lat_index(isample),     \
                              sampled_grids_lon_index(isample)) =   \
              MODIS_cf_yearly(sampled_grids_lat_index(isample),     \
                              sampled_grids_lon_index(isample)) +   \
                              (/Terra_cf_total_mean(isample)/)
           end do
        end if

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        if (logic_plot_daily) then
;  CALL SUBROUTINE plot_contour_grid_landmask.ncl TO PLOT DAILY IMAGE WITH BACKGROUND MAP ON IT
           plot_contour_grid_landmask \
           (wks, minlat, maxlat, minlon, maxlon,    \
           lat, lon, MODIS_cf_daily, stime)
        if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
           polygon_map \
           (wks, minlat, maxlat, minlon, maxlon, \
           lat_pg, lon_pg)
        end if
        end if
           iday_loop   = iday_loop   + 1
           imonth_loop = imonth_loop + 1
           iyear_loop  = iyear_loop  + 1
           delete([/dim_index_real/])
        end do ; iday

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT MONTHLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         if (logic_plot_monthly) then
            smonthly         = siyear + "-" + simonth
            MODIS_cf_monthly = MODIS_cf_monthly/iday_loop
;  CALL SUBROUTINE plot_contour_grid_landmask.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
            plot_contour_grid_landmask \
            (wks, minlat, maxlat, minlon, maxlon,    \
            lat, lon, MODIS_cf_monthly, smonthly)
         if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
            polygon_map \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat_pg, lon_pg)
         end if
         end if
      end do ; imonth

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT SEASONAL IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      if (logic_plot_seasonal) then
         sseasonal         = siyear + " " + sstring
         MODIS_cf_seasonal = MODIS_cf_seasonal/imonth_loop
;  CALL SUBROUTINE plot_contour_grid_landmask.ncl TO PLOT SEASONAL IMAGE WITH BACKGROUND MAP ON IT
            plot_contour_grid_landmask \
            (wks, minlat, maxlat, minlon, maxlon,    \
            lat, lon, MODIS_cf_seasonal, sseasonal)
         if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
            polygon_map \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat_pg, lon_pg)
         end if
         end if
   end do ; iyear

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT YEARLY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
   if (logic_plot_yearly) then
      syearly         = sprinti("%0.4i", start_year) + "-" + \
                        sprinti("%0.4i", end_year)   + " " + sstring
      MODIS_cf_yearly = MODIS_cf_yearly/iyear_loop
;  CALL SUBROUTINE plot_contour_grid_landmask.ncl TO PLOT YEARLY IMAGE WITH BACKGROUND MAP ON IT
         plot_contour_grid_landmask \
         (wks, minlat, maxlat, minlon, maxlon,    \
         lat, lon, MODIS_cf_yearly, syearly)
      if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
         polygon_map \
         (wks, minlat, maxlat, minlon, maxlon, \
         lat_pg, lon_pg)
      end if
   end if
end
