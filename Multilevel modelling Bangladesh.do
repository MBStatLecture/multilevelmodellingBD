**********************************************************************
* Stage A *** Compile parameters/inputs for Level-weights calculations
**********************************************************************
* a_c_h completed clusters by strata
gen a_c_h=.
quietly levelsof v022, local(lstrata)
quietly foreach ls of local lstrata {
tab v021 if v022==`ls', matrow(T)
scalar stemp=rowsof(T)
replace a_c_h=stemp if v022==`ls'
}
* A_h: total number of census clusters by strata
gen A_h = 0

* Assign combined urban (city corporation + other urban) and rural values for each division

* Barisal
replace A_h = 2688 if v022 == 1   // Barisal urban
replace A_h = 14812 if v022 == 2  // Barisal rural

* Chattogram
replace A_h = 12241 if v022 == 3  // Chattogram urban
replace A_h = 40019 if v022 == 4  // Chattogram rural

* Dhaka
replace A_h = 27922 if v022 == 5  // Dhaka urban
replace A_h = 45910 if v022 == 6  // Dhaka rural

* Khulna
replace A_h = 5646 if v022 == 7   // Khulna urban
replace A_h = 27485 if v022 == 8  // Khulna rural

* Mymensingh
replace A_h = 3105 if v022 == 9   // Mymensingh urban
replace A_h = 20403 if v022 == 10 // Mymensingh rural

* Rajshahi
replace A_h = 6599 if v022 == 11  // Rajshahi urban
replace A_h = 34101 if v022 == 12 // Rajshahi rural

* Rangpur
replace A_h = 4273 if v022 == 13  // Rangpur urban
replace A_h = 29388 if v022 == 14 // Rangpur rural

* Sylhet
replace A_h = 2719 if v022 == 15  // Sylhet urban
replace A_h = 16222 if v022 == 16 // Sylhet rural


* M_h: average number of households per cluster by strata
gen M_h = 0

* Assign average number of households per cluster for each division and strata

* Barisal
replace M_h = 108 if v022 == 1   // Barisal urban
replace M_h = 105 if v022 == 2   // Barisal rural

* Chattogram
replace M_h = 115 if v022 == 3   // Chattogram urban
replace M_h = 105 if v022 == 4   // Chattogram rural

* Dhaka
replace M_h = 114 if v022 == 5   // Dhaka urban
replace M_h = 111 if v022 == 6   // Dhaka rural

* Khulna
replace M_h = 118 if v022 == 7   // Khulna urban
replace M_h = 112 if v022 == 8   // Khulna rural

* Mymensingh
replace M_h = 118 if v022 == 9   // Mymensingh urban
replace M_h = 107 if v022 == 10  // Mymensingh rural

* Rajshahi
replace M_h = 117 if v022 == 11  // Rajshahi urban
replace M_h = 109 if v022 == 12  // Rajshahi rural

* Rangpur
replace M_h = 113 if v022 == 13  // Rangpur urban
replace M_h = 113 if v022 == 14  // Rangpur rural

* Sylhet
replace M_h = 102 if v022 == 15  // Sylhet urban
replace M_h = 93 if v022 == 16   // Sylhet rural

* m_c total number of completed households (added from the HR dataset)
gen m_c= 30375
* M total number of households in country
gen M = 32173630
* S_h households selected per stratum
gen S_h = 25

* Steps to approximate Level-1 and Level-2 weights from Household or Individual
**********************************************************************
* Stage B *** Approximate Level-weights ***
**********************************************************************
* Steps to approximate Level-1 and Level-2 weights from Household or Individual Weights
*Step 1. De-normalize the final weight, using approximated normalization factor
*********STEP 7******
**Prepare the country specific DHS household weight.**
gen DHSwt = v005 / 1000000
gen DHSwt2 =  DHSwt * (30078/9487) 

                      ******STAGE 2**
****Approximate level-1 and level-2 weights** 
*********STEP 1******
*De-normalize the final weight, using approximated normalization factor
gen d_HH = DHSwt2 * (M/m_c) 
*********STEP 2******
*Approximate the level-2 weight based on equal split method (α=0.5).
gen f = d_HH / ((A_h/a_c_h) * (M_h/S_h)) 
scalar alpha = 0.5 
gen wt2 = (A_h/a_c_h)*(f^alpha) 
*********STEP 3******
*Approximate the level-1 weight. 
gen wt1 = d_HH/wt2

                      *****STAGE 3**
******Sensitivity analysis*** 
**Calculate level-weights based on the following 8 scenarios of α: 0.05, 0, 0.1, .25, .50, .75, 0.90 and 1.
local alphas 0.05 0 0.1 .25 .50 .75 0.90 1
local i = 1 
foreach dom of local alphas {  
	gen wt2_`i' = (A_h/a_c_h)*(f^`dom') 
	gen wt1_`i' = d_HH/wt2_`i' 
	local ++i 
} 
****************** Stage 4 *** Svyset *** ********
svyset v001, weight(wt2) strata(v022) , singleunit(centered) || _n, weight(wt1) 




