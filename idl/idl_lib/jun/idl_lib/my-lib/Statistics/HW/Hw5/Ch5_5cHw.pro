PRO Ch5_5cHw

Precip = [4.17, 5.61, 3.88, 1.55, 2.30, 5.58, 5.58, 5.14, 4.52, $
1.53, 4.24, 1.18, 3.17, 4.72, 2.17, 2.17, 3.94, 0.95, 1.48, $
5.68, 4.25, 3.66, 2.12, 1.24, 3.64, 8.44, 5.20, 2.33, 2.18, 3.43]

ResultPrecip = Sort(Precip)		;Sorting the values
SortPrecip = Precip[Sort(Precip)]	;Putting the sorted values into an array

RankArray = Ranks(SortPrecip)

Print, SortPrecip
Print, "-------------------------"
Print, RankArray

corr = Correlate(SortPrecip, RankArray)

Print, corr

END
