*ssc install xtfmb
*ssc install outreg2
*ssc install estout

cd "E:\Local Disk F\Industry Innovation Networks\Innovation2\Moonshots paper"

/*import delimited "E:\Local Disk F\Industry Innovation Networks\Innovation2\Moonshots paper\Finaldata.csv", clear
save adarsh_data, replace */

set more off
use adarsh_data, clear
duplicates drop fyear permno, force
xtset permno fyear  


***********************************************************
                      Table-3
**********************************************************;


gen var14_1=log(var14)
gen pat1=log(1+npat)
gen citation1=log(1+citation)


eststo clear

/*RDP regressions */

quietly xi: areg rdp var8 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model1

quietly xi: areg rdp var8 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model2

quietly xi: areg rdp var9 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model3

quietly xi: areg rdp var9 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model4

/*CAPXP regressions */

quietly xi: areg capxp var8 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model5

quietly xi: areg capxp var8 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model6

quietly xi: areg capxp var9 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model7

quietly xi: areg capxp var9 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model8


/*Pat regressions */

quietly xi: areg pat1 var8 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model9

quietly xi: areg pat1 var8 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model10

quietly xi: areg pat1 var9 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model11

quietly xi: areg pat1 var9 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model12

/*citation regressions */

quietly xi: areg citation1 var8 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model13

quietly xi: areg citation1 var8 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model14

quietly xi: areg citation1 var9 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model15

quietly xi: areg citation1 var9 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model16



esttab using table3.csv, replace compress t ar2 nogaps b(%8.3f) drop(_I*) 
order(_cons var8 var10 var12 var13 var14_1 var15) coeflabels(_cons Intercept)


***********************************************************
                      Table-4
**********************************************************;


gen Novelty1=novelty*100
gen Originality1=avg_originality*100
gen generality1=avg_generality*100

eststo clear

/*Novelty regressions */

quietly xi: areg Novelty1 var8 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model1

quietly xi: areg Novelty1 var8 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model2

quietly xi: areg Novelty1 var9 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model3

quietly xi: areg Novelty1 var9 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model4

/*Originality regressions */

quietly xi: areg Originality1 var8 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model5

quietly xi: areg Originality1 var8 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model6

quietly xi: areg Originality1 var9 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model7

quietly xi: areg Originality1 var9 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model8


/*Generality regressions */

quietly xi: areg generality1 var8 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model9

quietly xi: areg generality1 var8 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model10

quietly xi: areg generality1 var9 var10 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model11

quietly xi: areg generality1 var9 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model12


esttab using table4.csv, replace compress t ar2 nogaps b(%8.3f) drop(_I*) 
order(_cons var8 var10 var12 var13 var14_1 var15) coeflabels(_cons Intercept var8 VP var9 MFFlow var10 BP var11 GS var12 CF var13 Leverage var14_1 log(1+Age) var15 Size)



***********************************************************
                      Table-5
**********************************************************;


eststo clear

/*RD regressions */

quietly xi: areg rdp qflow1 ei gs cfp leverage var14_1 at_1 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model1

quietly xi: areg capxp qflow1 ei gs cfp leverage var14_1 at_1 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model2

quietly xi: areg ei qflow1 gs roa_t dcr leverage var14_1 at_1 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model3

esttab using table5.csv, replace compress t ar2 nogaps b(%8.3f) drop(_I*) 
order(_cons qflow1 ei gs cfp leverage var14_1 at_1) coeflabels(_cons Intercept )



***********************************************************
                      Table-6
**********************************************************;

eststo clear

gen var8_1=var8*lowvp
gen var9_1=var9*lowflow 

quietly xi: areg rdp var8 var8_1 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model1

quietly xi: areg rdp var9 var9_1 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model2

quietly xi: areg capxp var8 var8_1 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model3

quietly xi: areg capxp var9 var9_1 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model4

quietly xi: areg pat1 var8 var8_1 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model5

quietly xi: areg pat1 var9 var9_1 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model6

quietly xi: areg citation1 var8 var8_1 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model7

quietly xi: areg citation1 var9 var9_1 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model8

quietly xi: areg Novelty1 var8 var8_1 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model9

quietly xi: areg Novelty1 var9 var9_1 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model10

quietly xi: areg Originality1 var8 var8_1 var11 var12 var13 var14_1 var15, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model11

quietly xi: areg Originality1 var9 var9_1 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model12

quietly xi: areg generality1 var8 var8_1 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model13

quietly xi: areg generality1 var9 var9_1 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model14

esttab using table6.csv, replace compress t ar2 nogaps b(%8.3f) drop(_I*) 
order(_cons qflow1 ei gs cfp leverage var14_1 at_1) coeflabels(_cons Intercept )




***********************************************************
                      Table-7
**********************************************************;

eststo clear

gen var8_2=var8*highgs
gen var8_3=var8*highturn
gen var9_2=var9*highgs
gen var9_3=var9*highturn

quietly xi: areg rdp var8 var8_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model1

quietly xi: areg rdp var9 var9_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model2

quietly xi: areg rdp var8 var8_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model3

quietly xi: areg rdp var9 var9_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model4

quietly xi: areg capxp var8 var8_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model5

quietly xi: areg capxp var9 var9_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model6

quietly xi: areg capxp var8 var8_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model7

quietly xi: areg capxp var9 var9_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model8

quietly xi: areg pat1 var8 var8_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model9

quietly xi: areg pat1 var9 var9_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model10

quietly xi: areg pat1 var8 var8_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model11

quietly xi: areg pat1 var9 var9_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model12

quietly xi: areg citation1 var8 var8_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model13

quietly xi: areg citation1 var9 var9_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model14

quietly xi: areg citation1 var8 var8_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model15

quietly xi: areg citation1 var9 var9_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model16


esttab using table7.csv, replace compress t ar2 nogaps b(%8.3f) drop(_I*) 
order(_cons qflow1 ei gs cfp leverage var14_1 at_1) coeflabels(_cons Intercept )


***********************************************************
                      Table-8
**********************************************************;

eststo clear

quietly xi: areg Novelty1 var8 var8_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model1

quietly xi: areg Novelty1 var9 var9_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model2

quietly xi: areg Novelty1 var8 var8_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model3

quietly xi: areg Novelty1 var9 var9_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model4

quietly xi: areg Originality1 var8 var8_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model5

quietly xi: areg Originality1 var9 var9_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model6

quietly xi: areg Originality1 var8 var8_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 3*/
quietly eststo Model7

quietly xi: areg Originality1 var9 var9_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 4*/
quietly eststo Model8

quietly xi: areg generality1 var8 var8_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model9

quietly xi: areg generality1 var9 var9_2 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model10

quietly xi: areg generality1 var8 var8_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 1*/
quietly eststo Model11

quietly xi: areg generality1 var9 var9_3 var11 var12 var13 var14_1 var15 i.fyear, cluster(permno) a(twodigit) /* Model 2*/
quietly eststo Model12

esttab using table8.csv, replace compress t ar2 nogaps b(%8.3f) drop(_I*) 
order(_cons qflow1 ei gs cfp leverage var14_1 at_1) coeflabels(_cons Intercept )


