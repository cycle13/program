PRO AugustPrecip
;Programed by Samantha Strong-Henninger and Collin Holmquist

;Reading the number of lines in the file.
lines = FILE_LINES('AugPrecip.txt')

;Arrays declared.
Year = FltArr(lines)
Precip = FltArr(lines)

;Reading in the file
OPENR, iunit, 'AugPrecip.txt', /GET_LUN

For i = 0, lines-1 DO BEGIN
	READF, iunit, Y, P
	;Seperate the columns of data.
   	Year[i] = Y
	Precip[i] = P
ENDFOR

;----------------------------------------------------------------------------------------
ResultPrecip = Sort(Precip)		;Sorting the values
SortPrecip = Precip[Sort(Precip)]	;Putting the sorted values into an array

;Compute the quantiles. We can round up and down by using ceiling and floor functions
q025 = ((lines-1)*0.25)+1
quantile25 = (SortPrecip[Ceil(q025-1)] + SortPrecip[Floor(q025-1)])/2.

q075 = ((lines-1)*0.75)+1
quantile75 = (SortPrecip[Ceil(q075-1)] + SortPrecip[Floor(q075-1)])/2.

;Computing IQR
IQR = quantile75 - quantile25

c = 2.6
h = (c * IQR)/(lines^(0.33333))

;----------------------------------------------------------------------------------------
;Normal Distribution
x = (FindGen(170)/10) - 5

meanPrecip = mean(Precip)
stdPrecip = stddev(Precip)

;PDF for the Gaussian Distribution
f = (1/(stdPrecip*(2*!pi)^(0.5)))*(2.71828^((-(x-meanPrecip)^2.0)/(2*stdPrecip^2.0)))

;setting plot device to ps
SET_PLOT, 'PS'

;Here is the filename for the graph
DEVICE, Filename ="Normal.ps"

Plot, x, f, xstyle =1, title = "Normal Distribution for August Precpitation", $
	xtitle = "Precipitation (mm)", ytitle = "Number of Months"

;Closing device
DEVICE, /CLOSE

;----------------------------------------------------------------------------------------
;Gamma Distribution
xGamma = FindGen(120)/10

alpha = (meanPrecip^(2.0))/(stdPrecip^(2.0))
beta = (stdPrecip^(2.0))/meanPrecip
gamma = 1.454				;gamma of alpha
zeta_2011 = 6.89/beta

fGamma = (((xGamma/beta)^(alpha-1.0))*(EXP(-xGamma/beta)))/(beta*gamma)

Print, "Gamma: Alpha = ", alpha, "   Beta = ", beta
Print, "Zeta for 2011 = ", zeta_2011

;----------------------------------------------------------------------------------------
;setting plot device to ps
SET_PLOT, 'PS'

;Here is the filename for the graph
DEVICE, Filename ="Histogram.ps"

Plot, Histogram(Precip, binsize = h), Psym = 10, $
	xstyle = 1, $
	xrange = [0,11], title = "Histogram for August Precipitation", $
	xtitle = "Precipitation (mm)", ytitle = "Number of Months"
AXIS, YAXIS = 1, yrange = [0,0.25], ytitle = "Probability",$
    ystyle = 1, /save
OPlot, xGamma, fGamma

Print, fGamma[6.9]

;Closing device
DEVICE, /CLOSE

END
