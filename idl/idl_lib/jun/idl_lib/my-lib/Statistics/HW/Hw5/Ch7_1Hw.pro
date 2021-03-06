PRO Ch7_1Hw

;(a)----------------------------------------------------------------------------------
Temp = [26.1, 24.5, 24.8, 24.5, 24.1, 24.3, 26.4, 24.9, 23.7, 23.5, 24.0, $
24.1, 23.7, 24.3, 26.6, 24.6, 24.8, 24.4, 26.8, 25.2]

Pres = [1009.5, 1010.9, 1010.7, 1011.2, 1011.9, 1011.2, 1009.3, 1011.1, 1012.0, $
1011.4, 1010.9, 1011.5, 1011.0, 1011.2, 1009.9, 1012.5, 1011.1, 1011.8, 1009.3, 1010.6]

;Pres = x, Temp = y

Result = Regress(Pres, Temp, Sigma = sigma, Const = const)

b = Result[*]

Print, "a: ", const, " C"	
Print, "b: ", b, " C/mb"
;as the pressure decreases, the temperature will generally increase.
;i.e. pressure and temperature are inversely proportional.

;(c)----------------------------------------------------------------------------------
meanTemp = Mean(Temp)
meanPres = Mean(Pres)

SizeTemp = Size(Temp)
n = SizeTemp[1]

SST = 0
SSR = 0
FOR i = 0, n-1 do begin
	SST_add = (Temp(i) - meanTemp)^(2.0)
	SST = SST + SST_add
	SSR_add = (Pres(i) - meanPres)^(2.0)
	SSR = SSR + SSR_add
ENDFOR

SSR = SSR*(b^(2.0))
Se = (1.0/(n-2.0)) * (SST - SSR)

sigma_b = SQRT(Se)/SQRT(TOTAL((Pres-meanPres)^(2.0)))

Print, "z = ", (b - 0)/sigma_b

;(d)---------------------------------------------------------------------------------
R = SSR/SST

Print, "R^2 = ", R

;(e)---------------------------------------------------------------------------------
SizePres = Size(Pres)		;Implementing the size function of the array
n = SizePres[1]			;Getting the size of the array

sy2 = Se*(1.0+(1.0/n)+(((1013.0-Mean(Pres))^(2.0))/SSR))
;Print, sy2

zVal = 1.0/SQRT(sy2)
;z table look-up: P = 0.06552

Print, "Problem E: ", 1.0-(2.0*0.06552)

;(f)----------------------------------------------------------------------------------
zVal = 1.0/SQRT(Se)
;z table look-up: P = 0.03754

Print, "Problem F: ", 1.0-(2.0*0.03754)

END
