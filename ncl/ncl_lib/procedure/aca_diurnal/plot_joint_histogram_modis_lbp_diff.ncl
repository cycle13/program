;  $ID plot_joint_histogram_modis_lbp_diff.ncl V01 05/19/2015 10:12 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_joint_histogram_modis_lbp_diff PLOTS 2-D 
;  HISTOGRAM WITH UNEQUAL BINS FOR X AND Y AXISES. THIS PROGRAM IS REFERRED 
;  FROM raster_6.ncl FROM NCL WEBSITE 
;  (http://www.ncl.ucar.edu/Applications/Scripts/raster_6.ncl)
;   - Generating dummy data which have irregular X and Y coordinates
;   - Drawing raster contours 
;   - Forcing full-sized raster cells at the X,Y axis boundaries
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY NCL WEBSITE. MODIFIED BY BRUCE. (05/19/2015)
;******************************************************************************

undef("plot_joint_histogram_modis_lbp_diff")
procedure plot_joint_histogram_modis_lbp_diff         \
          (wks          :graphic,                     \ ;INPUT
           xbnd         :float,     ybnd      :float, \ ;INPUT
           data         :float,     lbp       :float, \ ;INPUT
           times        :string)  ;INPUT

begin
  nxbnd = dimsizes(xbnd)                              ; # of x bin boundaries   
  nybnd = dimsizes(ybnd)                              ; # of y bin boundaries 

  nx    = nxbnd
  ny    = nybnd

;=================================================;
; PLOT
;=================================================;

  res                      = True          ; plot mods desired
  res@gsnMaximize          = True          ; Maximize plot in frame.
  res@gsnSpreadColors      = True
  res@gsnDraw              = False
  res@gsnFrame             = False


  res@cnFillOn             = True          ; Turn on contour fill
  res@cnFillMode           = "RasterFill"  ; Turn on raster fill
  res@cnLinesOn            = False         ; Turn off contour lines
  res@cnLineLabelsOn       = False         ; turns off contour line labels

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = -1
  res@cnMaxLevelValF       =  1
  res@cnLevelSpacingF      =  0.05

  res@trYReverse           = True           ; reverses y-axis 

  res@lbLabelBarOn         = True
  res@lbOrientation        = "vertical"     ; vertical label bar
  res@lbLabelStride        = 4
  res@lbLabelFontThicknessF= 0.3
  res@lbBoxLinesOn         = False
  res@lbTitleString        = "%"
  res@lbTitlePosition      = "Right"

  res@trXMinF              = -0.5           ; extend x and y axes 
  res@trXMaxF              =  nx-0.5
  res@trYMinF              = -0.5
  res@trYMaxF              =  ny-0.5

  res@tmXBMode             = "Explicit"                ; explicit labels
  res@tmXBValues           = fspan(res@trXMinF,res@trXMaxF, nxbnd) 
  res@tmXBLabels           = xbnd           
  res@sfXArray             = res@tmXBValues    

  res@tmYLMode             = "Explicit"                ; explicit labels
  res@tmYLValues           = fspan(res@trYMinF,res@trYMaxF, nybnd) 
  res@tmYLLabels           = ybnd          
  res@sfYArray             = res@tmYLValues

  res@tiXAxisString        = "COT"        ; x-axis title
  res@tiYAxisString        = "CTP [hPa]"  ; y-axis title

  res@tiMainString         = times + " cot_ctp_hist" + " Cloud w ACA - Cloud w/o ACA "
  plot = gsn_csm_contour(wks,data,res)       ; contour the variable

; SET UP A SWITCH FOR PLOTTING lbp OR NOT
  switch                   = True

  if (switch) then
; OVER PLOT lbp FOR 6 AEROSOL TYPES
  dashpatterns             = (/0, 1, 2, 3, 4, 5/)
  linecolors               = (/"Blue", "Yellow", "Red", "Green", "Brown", "Black"/)
  linelabel                = (/"clean marine", "dust", "polluted continental", \
                               "clean continental", "polluted dust", "smoke"/)
  dum                      = new(dimsizes(lbp), graphic)

  eres                     = True
  do i = 0, dimsizes(lbp)-1
     eres@gsLineDashPattern   = dashpatterns(i)
     eres@gsLineColor         = linecolors(i)
     eres@gsLineThicknessF    = 10
     eres@gsLineLabelString   = linelabel(i)
     eres@gsLineLabelFontColor= linecolors(i)

; CALCULATE THE RATIO BETWEEN TICK MARK AND TICK VALUE
     index = ind(ybnd .ge. lbp(i))
     if (.not.all(ismissing(index))) then
        ratio = (lbp(i)-ybnd(index(0)-1))/(ybnd(index(0))-ybnd(index(0)-1))
        length= ratio*(res@tmYLValues(index(0))-res@tmYLValues(index(0)-1))
        nlbp  = res@tmYLValues(index(0)-1) + length
;  NO PLOT FOR "polluted continental" AND "clean continental"
        if (i .ne. 2 .and. i .ne. 3) then
           dum(i) = gsn_add_polyline(wks, plot, (/res@trXMinF, res@trXMaxF/), \
                                                (/nlbp, nlbp/), eres)
        end if
     end if
     delete([/index/])
  end do
  end if
  draw(plot)
  frame(wks)

return
end
