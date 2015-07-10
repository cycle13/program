; $ID: plot_trend_hourly2_pm.ncl V01 01/13/2012 10:02 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_trend_hourly2_pm IS USED TO PLOT THE SIMILAR TREND LINE 
;  BETWEEN TWO ONE-DIMENSIONAL ARRAY, ALSO WITH SPECIFIED X AXIS TICK MARKS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                             [---]
;  (2 ) sitename   (string)  : OBS SITE NAME                            [---]
;  (3 ) data1      (float)   : OBS OBSERVATION DATA                     [---]
;  (4 ) data2      (float)   : SELETED WRFCHEM DATA DEPENDING ON FMF    [---]
;  (5 ) nday       (integer) : TOTAL # OF FMF OBSERVATION DAYS          [---]
;  (6 ) bv1        (integer) : MISSING VALUE FOR INTEGER                [---]
;  (7 ) bv2        (float)   : MISSING VALUE FOR FLOAT                  [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/13/2012)
;  (2 ) SPECIFY FOR DAILY TREND LINE PLOT. (02/20/2012)
;  (3 ) ADD TO PLOT MONTHLY AVERAGE LINE. (03/11/2012)
;  (4 ) MODIFIED FROM plot_trend_daily2.ncl. (06/09/2012)
;  (5 ) MODIFIED FROM plot_trend_daily2_aod.ncl. (11/08/2012)
;******************************************************************************

undef("plot_trend_hourly2_pm")
procedure plot_trend_hourly2_pm \
         (wks    :graphic, sitename:string,  \ ; INPUT
          data1  :float,   data2   :float,   \ ; INPUT
          nhour  :integer,                   \ ; INPUT
          mpplot :graphic)                     ; INPUT

begin

;  SET UP THE POSITION OF THE CONTOUR PLOT
   res                         = True
   res@vpWidthF                = 0.7
   res@vpHeightF               = 0.35
   res@vpXF                    = 0.15
   res@vpYF                    = 0.85
   res@gsnDraw                 = False
   res@gsnFrame                = False

;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   resr                        = True
   resr                        = res
   resr@xyMarkLineMode         = "MarkLines"
   resr@xyMarkers              = 16
   resr@xyMarkerSizes          = 5
   resr@xyMarkerThicknessF     = 2.0
   resr@xyMarkerColors         = "Blue"
   resr@xyLineColor            = "Blue"
;  SET X AXIS LABELS
   x                           = ispan(1,nhour,1)
   xtick                       = (/"01", "03", "05", "07", "09", \
                                   "11", "13", "15", "17", "19", \
                                   "21", "23", "25", "27", "29", "31"/)
   resr@tmXBMode               = "Explicit"
   resr@tmXBValues             = x(0:nhour-1:2*24)
   resr@tmXBLabels             = xtick
   resr@tmXBMajorLengthF       = 0.01
   resr@tmXBMinorLengthF       = 0.005
   resr@tmXBMajorOutwardLengthF= 0.0
   resr@tmXBMinorOutwardLengthF= 0.0
   resr@tmXBMinorValues        = ispan(2,nhour,2*24)
   resr@tmXTMajorLengthF       = 0.01
   resr@tmXTMinorLengthF       = 0.005
   resr@tmXTMajorOutwardLengthF= 0.0
   resr@tmXTMinorOutwardLengthF= 0.0
   resr@tmXTMinorValues        = ispan(2, nhour,2*24)
   resr@tmYLMajorLengthF       = 0.01
   resr@tmYLMinorLengthF       = 0.005
   resr@tmYLMajorOutwardLengthF= 0.0
   resr@tmYLMinorOutwardLengthF= 0.0
   resr@tmYRMajorLengthF       = 0.01
   resr@tmYRMinorLengthF       = 0.005
   resr@tmYRMajorOutwardLengthF= 0.0
   resr@tmYRMinorOutwardLengthF= 0.0

;  SET LEGEND
   resr@pmLegendDisplayMode    = "Always"
   resr@pmLegendSide           = "Top"
   resr@pmLegendParallelPosF   = 0.24
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.50 TO -0.45)
   resr@pmLegendOrthogonalPosF =-0.45
   resr@pmLegendWidthF         = 0.12
   resr@pmLegendHeightF        = 0.12
   resr@lgLabelFontHeightF     = 0.015
   resr@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resr@xyExplicitLegendLabels = (/" WRFChem PM2.5"/)
   resr@trYMaxF                = 50.0
   resr@trYMinF                = 0.0
   resr@tiXAxisString          = "Date in Aug 2012"
   resr@tiYAxisString          = "PM2.5"
   resr@tiMainString           = "OBS vs WRF-Chem (Aug 2012)  Hourly " + sitename

;  SET RIGHT Y AXIS LABEL
   resl                        = True
   resl                        = res
   resl@xyMarkLineMode         = "MarkLines"
   resl@xyMarkers              = 7
   resl@xyMarkerSizes          = 5
   resl@xyMarkerThicknessF     = 2.0
   resl@xyMarkerColors         = "Red"
   resl@xyLineColor            = "Red"
;  SET X AXIS LABELS
   resl@tmXBMode               = "Explicit"
   resl@tmXBValues             = x(0:nhour-1:2*24)
   resl@tmXBLabels             = xtick
   resl@tmXBMajorLengthF       = 0.01
   resl@tmXBMinorLengthF       = 0.005
   resl@tmXBMajorOutwardLengthF= 0.0
   resl@tmXBMinorOutwardLengthF= 0.0
   resl@tmXBMinorValues        = ispan(2,nhour,2*24)
   resl@tmXTMajorLengthF       = 0.01
   resl@tmXTMinorLengthF       = 0.005
   resl@tmXTMajorOutwardLengthF= 0.0
   resl@tmXTMinorOutwardLengthF= 0.0
   resl@tmXTMinorValues        = ispan(2,nhour,2*24)
   resl@tmYLMajorLengthF       = 0.01
   resl@tmYLMinorLengthF       = 0.005
   resl@tmYLMajorOutwardLengthF= 0.0
   resl@tmYLMinorOutwardLengthF= 0.0
   resl@tmYRMajorLengthF       = 0.01
   resl@tmYRMinorLengthF       = 0.005
   resl@tmYRMajorOutwardLengthF= 0.0
   resl@tmYRMinorOutwardLengthF= 0.0

;  SET LEGEND
   resl@pmLegendDisplayMode    = "Always"
   resl@pmLegendSide           = "Top"
   resl@pmLegendParallelPosF   = 0.23
;  NOTE: MOVE UP(pmLegendOrthogonalPosF IS BIGGER 
;        i.e. -0.38 TO -0.35)
   resl@pmLegendOrthogonalPosF =-0.38
   resl@pmLegendWidthF         = 0.12
   resl@pmLegendHeightF        = 0.12
   resl@lgLabelFontHeightF     = 0.015
   resl@lgPerimOn              = False
;  LABELS FOR THE LEGEND
   resl@xyExplicitLegendLabels = (/"OBS PM2.5"/)
   resl@trYMaxF                = 50.0
   resl@trYMinF                = 0.0
   resl@tiXAxisString          = "Date in Aug 2012"
   resl@tiYAxisString          = "PM2.5"

   tawplot   = gsn_csm_xy2(wks, x, data1, data2, resl, resr)

   data5     = avg(data1)
   data6     = avg(data2)
   nrl = resl@trYMaxF/resr@trYMaxF
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres1                       = True
   eres1@gsLineColor           = "Red"
   eres1@gsLineThicknessF      = 2.0
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres2                       = True
   eres2@gsLineColor           = "blue"
   eres2@gsLineThicknessF      = 2.0
;  OVER PLOT MONTHLY AVERAGE
   eres1@gsLineDashPattern = 2
   eres2@gsLineDashPattern = 2
   if (.not.all(ismissing(data5))) then
    gsn_polyline(wks, tawplot, (/x(0), x(nhour-1)/), \
                               (/data5, data5/), eres1)
   end if
   if (.not.all(ismissing(data6))) then
    gsn_polyline(wks, tawplot, (/x(0), x(nhour-1)/), \
                               (/data6, data6/)*nrl, eres2)
   end if

;  CALCULATE CORRELATION
;  DEFINE LOCAL ARRAY
   if (.not.all(ismissing(data1)) .and. \
       .not.all(ismissing(data2))) then
    dim       = dimsizes(data2)
    data      = new((/2, dim/), float)
    tdata     = new((/2, dim/), float)
    data(0,:) = data1
    data(1,:) = data2
    avgdata1  = avg(data1)
    avgdata2  = avg(data2)
    stddata1  = dim_stddev_n(data1, 0)
    stddata2  = dim_stddev_n(data2, 0)
    data!0    = "OBS"
    data!1    = "WRF-Chem"
    ecr       = esccr(data1,data2,0)
    prob      = rtest(ecr,nhour,0)
    rc        = regline(data1,data2)
    cor       = correlation(data1, data2)
    tdata(0,:)= data2
    tdata(1,:)= rc*(data1-rc@xave) + rc@yave
;  CALCULATE RMSE
    ndata1    = onedtond(data1, (/dim, dim/))
    ndata2    = onedtond(data2, (/dim, dim/))
    rmse      = wgt_arearmse(ndata1, ndata2, 1.0, 1.0, 0)

;  SET UP TEXT RESOURCES
    tres               = True
    tres@txFontHeightF = 0.015
    gsn_text_ndc(wks,"y = ", 0.23, 0.77, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rc), 0.27, 0.77, tres)
    gsn_text_ndc(wks,"x + ", 0.32, 0.77, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rc@yave-rc*rc@xave), 0.36, 0.77, tres)
    gsn_text_ndc(wks,"R = ", 0.23, 0.75, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", cor), 0.27, 0.75, tres)
    gsn_text_ndc(wks,"N = ", 0.23, 0.73,tres)
    gsn_text_ndc(wks,sprinti("%4.0i", rc@nptxy), 0.26, 0.73,tres)
    gsn_text_ndc(wks,"RMSE = ", 0.36, 0.73,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rmse), 0.43, 0.73,tres)
    gsn_text_ndc(wks,"OBS  : ", 0.268, 0.71,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata1), 0.35, 0.71,tres)
    gsn_text_ndc(wks,"~F34~1", 0.38, 0.71,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata1), 0.42, 0.71,tres)
    gsn_text_ndc(wks,"WRF-Chem: ", 0.27, 0.69,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata2), 0.35, 0.69,tres)
    gsn_text_ndc(wks,"~F34~1", 0.38, 0.69,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata2), 0.42, 0.69,tres)
   end if
   draw(mpplot)
   draw(tawplot)
   overlay(mpplot, tawplot)
   frame(wks)
   delete([/resl, resr, eres1, eres2/])
return
end