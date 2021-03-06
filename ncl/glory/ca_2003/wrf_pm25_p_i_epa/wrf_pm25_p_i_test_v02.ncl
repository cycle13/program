;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   Interpolating to specified pressure levels

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


;
; This procedure adds markers to a plot, making sure that each
; set is returned to a unique variable name, and that this
; variable is retained even outside this procedure call.
;
procedure add_markers(wks,plot,x,y,color,type)
local pmres, str
begin
  pmres = True
  pmres@gsMarkerColor = color
  pmres@gsMarkerIndex = type

  str = unique_string("polymarker")  ; "unique_string" will return a unique
                                     ; string every time it is called from
                                     ;  within a single NCL session.
;
; You can then use this unique string as an attribute variable name
; that gets attached to the plot variable. This ensures that this
; value will live for the duration of the script.
;
  plot@$str$ = gsn_add_polymarker(wks, plot, x, y, pmres)
end

begin
;
; The WRF ARW input file.
; This needs to have a ".nc" appended, so just do it.
  a = addfile("/mnt/sdd/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-08_00:00:00_1200sepanf.nc","w")


  res   = True
  gsres = True
  mpres = True
  pltres= True

;-----------------------EPA SITES-------------------------------------
; READ DATA INTO A BIG 1D STRING ARRAY
  fname ="/mnt/sdc/data/epa/epa_data/PM25_DATA/PM25_Simplified_Data/Simple_New_RD_501_88502_2008-0.txt"
  fname1="/mnt/sdc/data/epa/epa_data/PM25_DATA/PM25_Simplified_Data/Simple_new_site_monitor.txt"
  data=asciiread(fname,-1,"string")
  data1=asciiread(fname1,-1,"string")
; COUNT THE NUMBER OF FIELDS, JUST TO SHOW IT CAN BE DONE
  nfields=str_fields_count(data(1)," ")
  print("number of fields = "+nfields)
  nfields1=str_fields_count(data1(1)," ")
  print("number of fields1 = "+nfields1)

; SKIP THE FIRST ROW OF "DATA" BECAUSE IT'S JUST A HEADER LINE
; USE A SPACE(" ") AS A DELIMETER IN STR_GET_FIELD. THE FIRST FIELD
; IS FIELD=1 (UNLIKE STR_GET_COLS, IN WHICH THE FIRST COLUMN IS COLUMN=0)
  state  =stringtoint(str_get_field(data(1::),1," "))
  county =stringtoint(str_get_field(data(1::),2," "))
  site   =stringtoint(str_get_field(data(1::),3," "))
  yr     =stringtoint(str_get_field(data(1::),4," "))
  mn     =stringtoint(str_get_field(data(1::),5," "))
  dd     =stringtoint(str_get_field(data(1::),6," "))
  time   =stringtoint(str_get_field(data(1::),7," "))
  epapm25=stringtofloat(str_get_field(data(1::),8," "))

  astate =stringtoint(str_get_field(data1(1::),2," "))
  acounty=stringtoint(str_get_field(data1(1::),3," "))
  asite  =stringtoint(str_get_field(data1(1::),4," "))
  lat    =stringtofloat(str_get_field(data1(1::),5," "))
  lon    =stringtofloat(str_get_field(data1(1::),6," "))

;-----------------------PLOT WRFCHEM OUTPUT------------------------------
; We generate plots, but what kind do we prefer?
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks = gsn_open_wks(type,"plt_wrf_pm25_p_i_2008-05-08_nf_epa")
                                         ; for continents.
;   
  res@mpLimitMode      = "Corners"
  res@mpLeftCornerLatF    = 10.
  res@mpLeftCornerLonF    = -115.
  res@mpRightCornerLatF    = 45.
  res@mpRightCornerLonF    = -65.


  res@tiMainString = "REAL TIME - WRF/CHEM"

  res@mpGeophysicalLineColor      = "Black"
  res@mpNationalLineColor         = "Black"
  res@mpUSStateLineColor          = "Black"
  res@mpGridLineColor             = "Black"
  res@mpLimbLineColor             = "Black"
  res@mpPerimLineColor            = "Black"
  res@mpGeophysicalLineThicknessF = 2.0
  res@mpGridLineThicknessF        = 2.0
  res@mpLimbLineThicknessF        = 2.0
  res@mpNationalLineThicknessF    = 2.0
  res@mpUSStateLineThicknessF     = 2.0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do it = 0,0;ntimes-1,3             ; TIME LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need

    wrflat = wrf_user_getvar(a,"XLAT",it); XLAT
    wrflon = wrf_user_getvar(a,"XLONG",it); XLONG
    pm25= wrf_user_getvar(a,"PM2_5_DRY",it); PM2.5
    ;pm25!1="lat"
    ;pm25!2="lon"
    ;pm25&lat@units="degrees_north"
    ;pm25&lon@units="degrees_east"
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    print("Working on time: " + times(it) )
    yyr=stringtoint(str_get_cols(times(it),0,3))
    mmn=stringtoint(str_get_cols(times(it),5,6))
    ddd=stringtoint(str_get_cols(times(it),8,9))
    ttime=stringtoint(str_get_cols(times(it),11,12)+"00")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ;map=gsn_csm_map(wks,res)

      ; Plotting options for PM2.5
        res@cnLevelSelectionMode= "ExplicitLevels"
        res@cnLevels            = (/2,4,6,8,10,12,14,16,18,20/)
        levels = res@cnLevels
        dimlevels=dimsizes(levels)
        nlevel = (levels(dimlevels-1)-levels(0))/(levels(1)-levels(0))+1
        inlevel=toint(nlevel)
        interval=toint(199/nlevel)
        colors = ispan(0,199,interval)
        print(colors)
        res@cnFillColors          = colors
        res@gsnMaximize           = True
        res@cnLinesOn             = False
        res@cnFillOn              = True
        res@cnFillDrawOrder       = "PreDraw"
        res@mpGridAndLimbDrawOrder= "PreDraw"
        res@mpGridAndLimbOn       = True
        res@mpPerimOn             = True
        res@mpGridLatSpacingF     = 5.0
        res@mpGridLonSpacingF     = 10.0
        res@mpGridLineThicknessF  = 0.5
        res@mpGridLineDashPattern = 2
        res@mpOutlineBoundarySets = "GeophysicalAndUSStates"
        contourpm25 = gsn_contour_map(wks,pm25(0,:,:),res)


      ; SELECT EPA  SITE DATA
      ; FIND THE INDEX THAT MATCHES THE SPECIFIED TIME
        location=ind(mn.eq.mmn.and.dd.eq.ddd.and.time.eq.ttime)

      ; PM25 DATA AT THE SPECIFIED TIME
        ppm=epapm25(location)
        sstate=state(location)
        ccounty=county(location)
        ssite=site(location)
        count=dimsizes(ppm)
        llat=new((/count/),float,-999)
        llon=new((/count/),float,-999)
        llat@_FillValue=-999
        llon@_FillValue=-999
        index=0
        do i=0,count-1
        index=ind(astate.eq.sstate(i) .and. \
                  acounty.eq.ccounty(i) .and. \
                  asite.eq.ssite(i))
        if(index.eq.0)then
        print("No Match Found") 
        end if

        if(index.gt.0)then
        llat(i)=lat(index(0))
        llon(i)=lon(index(0))
        end if

        tpmcolor=toint((ppm(i)-min(ppm))/(max(ppm)-min(ppm))*200)
        do j=0,nlevel-1
        if(tpmcolor.eq.colors(j))then
         pmcolor=colors(j)
        end if
        if(j.gt.0.and.tpmcolor.gt.colors(j).and.tpmcolor.lt.colors(j+1))then
         pmcolor=colors(j)
        end if
        if(tpmcolor.eq.colors(inlevel-1))then
         pmcolor=colors(nlevels-1)
        end if
        end do
        gsres@gsMarkerColor=pmcolor
        gsres@gsMarkerIndex = 16          ; Use filled dots for markers.
        gsres@gsMarkerThicknessF=1
        gsres@tfPolyDrawOrder="PostDraw"
        ;scatter_epapm25=gsn_add_polymarker(wks,map,llon(i),llat(i),gsres)
        add_markers(wks,contourpm25,llon(i),llat(i),pmcolor,16)
        end do   ; END OF I LOOP

        delete(location)
        delete(ppm)
        delete(sstate)
        delete(ccounty)
        delete(ssite)
        delete(llat)
        delete(llon)
        draw(contourpm25)
        frame(wks)    ; Advance the frame.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  end do        ; END OF TIME LOOP

end

