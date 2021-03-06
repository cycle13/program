; $ID: plot_scatter_modis_wrf.ncl V01 06/19/2012 11:51 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_scatter_modis_wrf PLOTS SCATTER PLOT WITH ERROR BAR AND 
;  CORRELATION INFO.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks      (graphic) : WORK STATION                               [---]
;  (2 ) ndim     (integer) : # OF TOTAL DAYS                            [---]
;  (3 ) time      (string) : TIME                                       [---]
;  (3 ) data1      (float) : MODIS OBSERVATION DATA                     [---]
;  (4 ) data2      (float) : SELETED WRFCHEM DATA                       [---]
;  (5 ) data3      (float) : MODIS OBSERVATION DATA STANDARD DEVIATION  [---]
;  (6 ) data4      (float) : SELECTED WRFCHEM DATA STANDARD DEVIATION   [---]
;  (7 ) data5      (float) : MODIS OBSERVATION DATA MONTHLY AVERAGE     [---]
;  (8 ) data6      (float) : SELECTED WRFCHEM DATA MONTHLY AVERAGE      [---]
;  (9 ) tawplot  (graphic) : SCATTER PLOT                               [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/19/2012)
;  (2 ) MODIFIED FROM plot_scatter_modis_viirs.ncl. (06/19/2012)
;******************************************************************************

undef("plot_scatter_modis_wrf")
procedure plot_scatter_modis_wrf \
                       (wks      :graphic,  ndim     :integer,  \ ; INPUT
                        time     :string,                       \ ; INPUT
                        data1    :float,    data2    :float,    \ ; INPUT
                        data3    :float,    data4    :float,    \ ; INPUT
                        data5    :float,    data6    :float,    \ ; INPUT
                        tawplot  :graphic)                        ; OUTPUT

begin
;  SET UP THE POSITION OF THE SCATTER PLOT
   vres                  = True
   vres@vpWidthF         = 0.7
   vres@vpHeightF        = 0.35
   vres@vpXF             = 0.15
   vres@vpYF             = 0.85
   vres@gsnDraw          = False
   vres@gsnFrame         = False
   xmax                  = 1.0
   xmin                  = 0.0
   vres@trXMaxF          = xmax
   vres@trXMinF          = xmin
   ymax                  = 1.0
   ymin                  = 0.0
   vres@trYMaxF          = ymax
   vres@trYMinF          = ymin
   vres@tmXBMajorLengthF       = 0.01
   vres@tmXBMinorLengthF       = 0.005
   vres@tmXBMajorOutwardLengthF= 0.0
   vres@tmXBMinorOutwardLengthF= 0.0
   vres@tmXTMajorLengthF       = 0.01
   vres@tmXTMinorLengthF       = 0.005
   vres@tmXTMajorOutwardLengthF= 0.0 
   vres@tmXTMinorOutwardLengthF= 0.0 
   vres@tmYLMajorLengthF       = 0.01
   vres@tmYLMinorLengthF       = 0.005
   vres@tmYLMajorOutwardLengthF= 0.0
   vres@tmYLMinorOutwardLengthF= 0.0
   vres@tmYRMajorLengthF       = 0.01
   vres@tmYRMinorLengthF       = 0.005 
   vres@tmYRMajorOutwardLengthF= 0.0
   vres@tmYRMinorOutwardLengthF= 0.0

;  SET RESOURCES FOR SCATTER PLOT
   res                   = True
   res                   = vres
   res@xyDashPatterns    = 1
   res@xyMarkLineModes   = (/"Markers"/)
   res@xyMarkers         = 16
   res@xyMarkerSizes     = 6
   res@xyMarkerColors    = "Blue"

;  SET TITLE RESOURCES
   res@tiMainString      = "Aqua VS WRF-Chem  " + time
   res@tiYAxisString     = "Aqua (550 nm)"
   res@tiXAxisString     = "WRF-Chem (550 nm)"
   
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
    data!0    = "WRF-Chem"
    data!1    = "Aqua"
    ecr       = esccr(data1, data2, 0)
    prob      = rtest(ecr, ndim, 0)
    rc        = regline(data1, data2)
    cor       = correlation(data1, data2)
    tdata(0,:)= data2
    tdata(1,:)= rc*(data1-rc@xave) + rc@yave
    tdata(1,0)= rc*(xmin-rc@xave) + rc@yave
    tdata(1,1)= rc*(xmax-rc@xave) + rc@yave
;  CALCULATE RMSE
    ndata1    = onedtond(data1, (/dim, dim/))
    ndata2    = onedtond(data2, (/dim, dim/))
    rmse      = wgt_arearmse(ndata1, ndata2, 1.0, 1.0, 0)

;  SET UP TEXT RESOURCES
    tres               = True
    tres@txFontHeightF = 0.015
    gsn_text_ndc(wks,"y = ", 0.23, 0.82, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rc), 0.27, 0.82, tres)
    gsn_text_ndc(wks,"x + ", 0.32, 0.82, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rc@yave-rc*rc@xave), 0.36, 0.82, tres)
    gsn_text_ndc(wks,"R = ", 0.23, 0.80, tres)
    gsn_text_ndc(wks,sprintf("%5.2f", cor), 0.27, 0.80, tres)
    gsn_text_ndc(wks,"N = ", 0.23, 0.78,tres)
    gsn_text_ndc(wks,sprinti("%4.0i", rc@nptxy), 0.26, 0.78,tres)
    gsn_text_ndc(wks,"RMSE = ", 0.36, 0.78,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", rmse), 0.43, 0.78,tres)
    gsn_text_ndc(wks,"WRF-Chem : ", 0.268, 0.76,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata1), 0.35, 0.76,tres)
    gsn_text_ndc(wks,"~F34~1", 0.38, 0.76,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata1), 0.42, 0.76,tres)
    gsn_text_ndc(wks,"Aqua  : ", 0.27, 0.74,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", avgdata2), 0.35, 0.74,tres)
    gsn_text_ndc(wks,"~F34~1", 0.38, 0.74,tres)
    gsn_text_ndc(wks,sprintf("%5.2f", stddata2), 0.42, 0.74,tres)
   end if
   tawplot = gsn_csm_xy(wks, data1, data2,res)

;  OVERPLOT REGLINE AND DIAGONAL LINE
   xnew  = (/xmin, xmax/)
   ynew  = (/ymin, ymax/)
   rynew = (/tdata(1,0), tdata(1,1)/)
   tynew = (/ynew, rynew/)
;  SET UP RESOURCES OF LINE PLOT
   lres                   = True
   lres                   = vres
   lres@xyDashPatterns    = (/1, 0/)
   lres@xyLineThicknesses = (/1.0, 2.0/)
   lres@xyLineColors      = (/"black", "black"/)
   lplot = gsn_csm_xy(wks, xnew, tynew, lres)

   draw(tawplot)
   draw(lplot)
   frame(wks)
   delete([/vres, res, tres, lres/])

return
end
