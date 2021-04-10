*ssc install xtfmb
*ssc install outreg2
*ssc install estout

cd "E:\Local Disk F\Industry Innovation Networks\Innovation2\Innovation efficiency paper"


/*import delimited "F:\Local Disk F\Industry Innovation Networks\Innovation2\Innovation efficiency paper\Final_dataset.csv", clear
save adarsh_data, replace */


set more off
use adarsh_data, clear
duplicates drop fyear gvkey, force
xtset gvkey fyear 

preserve
gen dummy = roa1*100
drop roa1
rename dummy roa1

gen dummy = cf_tplus1*100
drop cf_tplus1
rename dummy cf_tplus1

xtfmb roa1 var1a var2 var3 var4a var5a ind* , lag(2) /* Model 1*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat 

xtfmb roa1 var1a var2 var3 var4a var5a var6 var7 var8 var9 ind* , lag(2) /* Model 2*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  

xtfmb cf_tplus1 var1a var2 var3 var4b var5b ind* , lag(2) /* Model 3*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb cf_tplus1 var1a var2 var3 var4b var5b var6 var7 var8 var9 ind* , lag(2) /* Model 4*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1b var2 var3 var4a var5a ind* , lag(2)  /* Model 5*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1b var2 var3 var4a var5a var6 var7 var8 var9 ind* , lag(2)  /* Model 6*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  


xtfmb cf_tplus1 var1b var2 var3 var4b var5b ind* , lag(2)  /* Model 7*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb cf_tplus1 var1b var2 var3 var4b var5b var6 var7 var8 var9 ind* , lag(2)  /* Model 8*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1c var2 var3 var4a var5a ind* , lag(2)  /* Model 9*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1c var2 var3 var4a var5a var6 var7 var8 var9 ind* , lag(2)  /* Model 10*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  


xtfmb cf_tplus1 var1c var2 var3 var4b var5b ind* , lag(2)  /* Model 11*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb cf_tplus1 var1c var2 var3 var4b var5b var6 var7 var8 var9 ind* , lag(2)  /* Model 12*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1d var2 var3 var4a var5a ind* , lag(2)  /* Model 13*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1d var2 var3 var4a var5a var6 var7 var8 var9 ind* , lag(2)  /* Model 14*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  


xtfmb cf_tplus1 var1d var2 var3 var4b var5b ind* , lag(2)  /* Model 15*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb cf_tplus1 var1d var2 var3 var4b var5b var6 var7 var8 var9 ind* , lag(2)  /* Model 16*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1e var2 var3 var4a var5a ind* , lag(2)  /* Model 17*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1e var2 var3 var4a var5a var6 var7 var8 var9 ind* , lag(2)  /* Model 18*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  


xtfmb cf_tplus1 var1e var2 var3 var4b var5b ind* , lag(2)  /* Model 19*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb cf_tplus1 var1e var2 var3 var4b var5b var6 var7 var8 var9 ind* , lag(2)  /* Model 20*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1f var2 var3 var4a var5a ind* , lag(2)  /* Model 21*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1f var2 var3 var4a var5a var6 var7 var8 var9 ind* , lag(2)  /* Model 22*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  


xtfmb cf_tplus1 var1f var2 var3 var4b var5b ind* , lag(2)  /* Model 23*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb cf_tplus1 var1f var2 var3 var4b var5b var6 var7 var8 var9 ind* , lag(2)  /* Model 24*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1g var2 var3 var4a var5a ind* , lag(2)  /* Model 25*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1g var2 var3 var4a var5a var6 var7 var8 var9 ind* , lag(2)  /* Model 26*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  


xtfmb cf_tplus1 var1g var2 var3 var4b var5b ind* , lag(2)  /* Model 27*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb cf_tplus1 var1g var2 var3 var4b var5b var6 var7 var8 var9 ind* , lag(2)  /* Model 28*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1h var2 var3 var4a var5a ind* , lag(2)  /* Model 29*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1h var2 var3 var4a var5a var6 var7 var8 var9 ind* , lag(2)  /* Model 30*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  


xtfmb cf_tplus1 var1h var2 var3 var4b var5b ind* , lag(2)  /* Model 31*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb cf_tplus1 var1h var2 var3 var4b var5b var6 var7 var8 var9 ind* , lag(2)  /* Model 32*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1i var2 var3 var4a var5a ind* , lag(2)  /* Model 33*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1i var2 var3 var4a var5a var6 var7 var8 var9 ind* , lag(2)  /* Model 34*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  


xtfmb cf_tplus1 var1i var2 var3 var4b var5b ind* , lag(2)  /* Model 35*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb cf_tplus1 var1i var2 var3 var4b var5b var6 var7 var8 var9 ind* , lag(2)  /* Model 36*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1j var2 var3 var4a var5a ind* , lag(2)  /* Model 37*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  

xtfmb roa1 var1j var2 var3 var4a var5a var6 var7 var8 var9 ind* , lag(2)  /* Model 38*/
outreg2 using "Table 1.xls",  ctitle("roa1") bdec(4) tdec(4) tstat  


xtfmb cf_tplus1 var1j var2 var3 var4b var5b ind* , lag(2)  /* Model 39*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

xtfmb cf_tplus1 var1j var2 var3 var4b var5b var6 var7 var8 var9 ind* , lag(2)  /* Model 40*/
outreg2 using "Table 1.xls",  ctitle("cf_tplus1") bdec(4) tdec(4) tstat  

restore




/********************************TABLE-4 *******************************************/


preserve
gen dummy = dep1*100
drop dep1
rename dummy dep1


xtfmb dep1 var1a var2 var3 var11 var12 var13 var14 ind* , lag(2) /* Model 1*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat 

xtfmb dep1 var1a var2 var3 var11 var12 var13 var14 var10a ind* , lag(2) /* Model 2*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1a var2 var3 var7 var8 var9 var11 var12 var13 var14 ind* , lag(2) /* Model 3*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1a var2 var3 var7 var8 var9 var10a var11 var12 var13 var14 ind* , lag(2) /* Model 4*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1b var2 var3 var11 var12 var13 var14 ind* , lag(2)  /* Model 5*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1b var2 var3 var11 var12 var13 var14 var10b ind* , lag(2)  /* Model 6*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  


xtfmb dep1 var1b var2 var3 var7 var8 var9 var11 var12 var13 var14 ind* , lag(2)  /* Model 7*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1b var2 var3 var7 var8 var9 var10b var11 var12 var13 var14 ind* , lag(2)  /* Model 8*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1c var2 var3 var11 var12 var13 var14 ind* , lag(2)  /* Model 9*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1c var2 var3 var11 var12 var13 var14 var10c  ind* , lag(2)  /* Model 10*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  


xtfmb dep1 var1c var2 var3 var7 var8 var9 var11 var12 var13 var14 ind* , lag(2)  /* Model 11*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1c var2 var3 var7 var8 var9 var10c var11 var12 var13 var14 ind* , lag(2)  /* Model 12*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1d var2 var3 var11 var12 var13 var14 ind* , lag(2)  /* Model 13*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1d var2 var3 var11 var12 var13 var14 var10d  ind* , lag(2)  /* Model 14*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  


xtfmb dep1 var1d var2 var3 var7 var8 var9 var11 var12 var13 var14 ind* , lag(2)  /* Model 15*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1d var2 var3 var7 var8 var9 var10d var11 var12 var13 var14 ind* , lag(2)  /* Model 16*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1e var2 var3 var11 var12 var13 var14 ind* , lag(2)  /* Model 17*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1e var2 var3 var11 var12 var13 var14 var10e  ind* , lag(2)  /* Model 18*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  


xtfmb dep1 var1e var2 var3 var7 var8 var9 var11 var12 var13 var14 ind* , lag(2)  /* Model 19*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1e var2 var3 var7 var8 var9 var10e var11 var12 var13 var14 ind* , lag(2)  /* Model 20*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1f var2 var3 var11 var12 var13 var14 ind* , lag(2)  /* Model 21*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1f var2 var3 var11 var12 var13 var14 var10f ind* , lag(2)  /* Model 22*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  


xtfmb dep1 var1f var2 var3 var7 var8 var9 var11 var12 var13 var14 ind* , lag(2)  /* Model 23*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1f var2 var3 var7 var8 var9 var10f var11 var12 var13 var14 ind* , lag(2)  /* Model 24*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1g var2 var3 var11 var12 var13 var14 ind* , lag(2)  /* Model 25*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1g var2 var3 var11 var12 var13 var14 var10g ind* , lag(2)  /* Model 26*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  


xtfmb dep1 var1g var2 var3 var7 var8 var9 var11 var12 var13 var14 ind* , lag(2)  /* Model 27*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1g var2 var3 var7 var8 var9 var10g var11 var12 var13 var14 ind* , lag(2)  /* Model 28*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1h var2 var3 var11 var12 var13 var14 ind* , lag(2)  /* Model 29*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1h var2 var3 var11 var12 var13 var14 var10h ind* , lag(2)  /* Model 30*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  


xtfmb dep1 var1h var2 var3 var7 var8 var9 var11 var12 var13 var14 ind* , lag(2)  /* Model 31*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1h var2 var3 var7 var8 var9 var10h var11 var12 var13 var14 ind* , lag(2)  /* Model 32*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1i var2 var3 var11 var12 var13 var14 ind* , lag(2)  /* Model 33*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1i var2 var3 var11 var12 var13 var14 var10i ind* , lag(2)  /* Model 34*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  


xtfmb dep1 var1i var2 var3 var7 var8 var9 var11 var12 var13 var14 ind* , lag(2)  /* Model 35*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1i var2 var3 var7 var8 var9 var10i var11 var12 var13 var14 ind* , lag(2)  /* Model 36*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1j var2 var3 var11 var12 var13 var14 ind* , lag(2)  /* Model 37*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1j var2 var3 var11 var12 var13 var14 var10j ind* , lag(2)  /* Model 38*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  


xtfmb dep1 var1j var2 var3 var7 var8 var9 var11 var12 var13 var14 ind* , lag(2)  /* Model 39*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

xtfmb dep1 var1j var2 var3 var7 var8 var9 var10j var11 var12 var13 var14 ind* , lag(2)  /* Model 40*/
outreg2 using "Table 2.xls",  ctitle("dep1") bdec(4) tdec(4) tstat  

restore
