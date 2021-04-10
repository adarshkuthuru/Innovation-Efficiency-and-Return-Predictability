clear
set matsize 5000


//Enter data
cd "C:\Users\30935\Desktop\Adarsh" 
insheet using final.csv

global controls "roa_1 d_apc"


//Regressions with regress
quietly regress roa1 var1a var2 var3 var4a var5a, cluster(portfolio)
quietly eststo Model1

quietly regress roa1 pat_rdc $controls, cluster(permno)
quietly eststo Model2


//Outout results
cd "C:\Users\30935\Desktop\Adarsh"
esttab using result1.csv, replace compress t ar2 nogaps nostar b(%8.3f) ///
order(_cons var1a var2 var3 var4a var5a) coeflabels(_cons Intercept)


//Regression with time-fixed effect
eststo clear

quietly xi: areg roa pat_rdc, cluster(permno) a(fyear)
quietly eststo Model1

quietly xi: areg roa pat_rdc $controls, cluster(permno) a(fyear)
quietly eststo Model2

//Outout results
cd "F:\Google Drive\Innovation Project\Data Innovation Measures\Results"
esttab using result2.csv, replace compress p ar2 nogaps nostar b(%8.3f) ///
order(_cons pat_rdc roa_1 d_apc) coeflabels(_cons Intercept pat_rdc PAT_RDC roa_1 LagROA d_apc D_APC)



//Regressions with time and firm fixed effect
eststo clear

//One way
*quietly xi: areg roa pat_rdc i.permno, cluster(permno) a(fyear)
*quietly eststo Model1

//Another way
quietly xi: areg roa pat_rdc i.fyear, cluster(permno) a(permno)
quietly eststo Model1

quietly xi: areg roa pat_rdc $controls i.fyear, cluster(permno) a(permno)
quietly eststo Model2

//Outout results
cd "F:\Google Drive\Innovation Project\Data Innovation Measures\Results"
esttab using result3.csv, replace compress p ar2 nogaps nostar b(%8.3f) drop(_I*) ///
order(_cons pat_rdc roa_1 d_apc) coeflabels(_cons Intercept pat_rdc PAT_RDC roa_1 LagROA d_apc D_APC)


//Check out reghdfe

//Fama-Macbeth regressions
eststo clear
drop _I*


//Identify panel and time variables
tsset gvkey fyear

//Fama-Macbeth with Newey-West corrected standard errors
quietly xtfmb roa pat_rdc, lag(2)
quietly eststo Model1

quietly xtfmb roa pat_rdc $controls, lag(2)
quietly eststo Model2

//Outout results
cd "F:\Google Drive\Innovation Project\Data Innovation Measures\Results"
esttab using FamaMacBeth.csv, replace compress t ar2 nogaps nostar b(%8.3f) ///
order(_cons pat_rdc roa_1 d_apc) coeflabels(_cons Intercept pat_rdc PAT_RDC roa_1 LagROA d_apc D_APC)







