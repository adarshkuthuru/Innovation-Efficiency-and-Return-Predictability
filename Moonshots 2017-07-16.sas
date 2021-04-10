
proc datasets lib=work kill nolist memtype=data;
quit;

libname IE 'E:\Local Disk F\Industry Innovation Networks\Innovation2\Innovation efficiency paper'; run;

libname INV 'E:\Local Disk F\Industry Innovation Networks\Innovation2'; run;

libname HMS 'E:\Local Disk F\Industry Innovation Networks\Innovation2\Moonshots paper'; run;


***Import data;
PROC IMPORT OUT= hms.nber_new
            DATAFILE= "E:\Local Disk F\Industry Innovation Networks\Innovation2\Innovation efficiency paper\New data 2017-07-08\all_data_21JAN14_nber.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

data hms.nber_new;
	set hms.nber_new;
	if missing(permno)=0;
	fyear=year(fyenddt);
run;

/**Converts fiscal year into calendar year data;*/
/**/
/*data hms.nber_new;*/
/*   set hms.nber_new;*/
/*   if (1<=month(fyenddt)<=5) then fyear=fyear+1;*/
/*run;*/





**linking ibes data with other databases;
*downloaded hms.ibes_link from ccmlinks;
*downloaded hms.mf from ibes in wrds;

proc sql;
	create table hms.ibes as
	select distinct a.*,b.gvkey,b.lpermno,b.cusip,b.sic
	from hms.mf as a left join hms.ibes_link as b
	on a.oftic=b.tic ;
quit;

data hms.ibes;
	set hms.ibes;
	if missing(oftic)=0;
	if missing(gvkey)=0;
run;

proc sort data=hms.ibes out=hms.ibes_distinct nodupkey; by oftic gvkey lpermno cusip sic; run;

proc sql;
	create table hms.ibes_distinct as
	select distinct a.ofctic,b.gvkey,b.lpermno,b.cusip,b.sic
	from hms.ibes;
quit;


*merging capx with nber_new dataset;
proc sql;
	create table hms.nber_new1 as
	select distinct a.*,b.capx
	from  hms.nber_new as a left join INV.annual_final1 as b
	on a.fyear=b.fyear and a.gvkey=input(b.gvkey,best6.)
	order by a.gvkey,a.fyear;
quit;

*creating at_1 variable;
proc sql;
	create table hms.nber_new1 as
	select distinct a.*, b.at as at_1
	from hms.nber_new1 as a left join hms.nber_new1 as b 
	on a.gvkey=b.gvkey and a.fyear=b.fyear+1 
	order by a.gvkey,a.fyear;
quit;

*adding adj_citations data from nber dataset;
proc sql;
	create table hms.nber_new1 as
	select distinct a.*, b.cites_adj_l5y as adj_cit,b.npat
	from hms.nber_new1 as a left join ie.nber as b 
	on a.gvkey=b.gvkey and a.fyear=b.fyear 
	order by a.gvkey,a.fyear;
quit;

*restricting the data to the given time period;
data hms.nber_new2;
	set hms.nber_new1;
	if fyear>=1976 & fyear<=2012; 
	RDP=rd/at_1;
	CAPXP=capx/at_1;
	Novelty=citation/npat;
	if int(siccd/1000)=6 then delete;
	if int(siccd/100)=49 then delete;
	id=1;
run;


/*1.RDP*/

proc univariate data=hms.nber_new2 noprint;
  var RDP;
  output pctlpre=P_  out=hms.test pctlpts=1,99;
run;

*winsorizing;
data hms.test;
	set hms.test;
	id=1;
run;

proc sql;
	create table hms.nber_new2 as
	select distinct a.*,b.p_1 as p_11,b.p_99 as p_199
	from hms.nber_new2 as a left join hms.test as b
	on a.id=b.id;
quit;

data hms.nber_new2;
	set hms.nber_new2;
	if missing(RDP)=0 and RDP<=p_11 then RDP=p_11;
	if missing(RDP)=0 and RDP>=p_199 then RDP=p_199;
	drop p_11 p_199;
run;

proc sql;
	create table hms.table1_stats as
	select distinct count(RDP), mean(RDP)*100,std(RDP)*100, median(RDP)*100
	from hms.nber_new2;
quit;

data hms.table1_stats;
	set hms.table1_stats;
    _TEMG002=_TEMA005;
	_TEMG003=_TEMA006;
	_TEMG004=_TEMA007;
	drop _TEMA005 _TEMA006 _TEMA007;
run;


/*2. CAPXP*/

proc univariate data=hms.nber_new2 noprint;
  var CAPXP;
  output pctlpre=P_  out=hms.test2 pctlpts=1,99;
run;
*winsorizing;
data hms.test2;
	set hms.test2;
	id=1;
run;

proc sql;
	create table hms.nber_new2 as
	select distinct a.*,b.p_1,b.p_99
	from hms.nber_new2 as a left join hms.test2 as b
	on a.id=b.id;
quit;

data hms.nber_new2;
	set hms.nber_new2;
	if missing(CAPXP)=0 and CAPXP<=p_1 then CAPXP=p_1;
	if missing(CAPXP)=0 and CAPXP>=p_99 then CAPXP=p_99;
	drop p_1 p_99;
run;

proc sql;
	create table hms.table1_stats2 as
	select distinct count(CAPXP), mean(CAPXP)*100,std(CAPXP)*100, median(CAPXP)*100
	from hms.nber_new2;
quit;

data hms.table1_stats2;
	set hms.table1_stats2;
    _TEMG002=_TEMA005;
	_TEMG003=_TEMA006;
	_TEMG004=_TEMA007;
	drop _TEMA005 _TEMA006 _TEMA007;
run;


/*3.Patents*/

proc univariate data=hms.nber_new2 noprint;
  var npat;
  output pctlpre=P_  out=hms.test3 pctlpts=1,99;
run;

proc sql;
	create table hms.table1_stats3 as
	select distinct count(npat), mean(npat), std(npat), median(npat)
	from hms.nber_new2;
quit;


/*4.Citations*/

proc sql;
	create table hms.table1_stats4 as
	select distinct count(citation), mean(citation), std(citation), median(citation)
	from hms.nber_new2;
quit;
proc univariate data=hms.nber_new2 noprint;
  var citation;
  output pctlpre=P_  out=hms.test4 pctlpts=1,99;
run;


/*5.Novelty*/

proc univariate data=hms.nber_new2 noprint;
  var Novelty;
  output pctlpre=P_  out=hms.test5 pctlpts=1,99;
run;

*winsorizing;
data hms.test5;
	set hms.test5;
	id=1;
run;

proc sql;
	create table hms.nber_new2 as
	select distinct a.*,b.p_1,b.p_99
	from hms.nber_new2 as a left join hms.test5 as b
	on a.id=b.id;
quit;

data hms.nber_new2;
	set hms.nber_new2;
	if missing(Novelty)=0 and Novelty<=p_1 then Novelty=p_1;
	if missing(Novelty)=0 and Novelty>=p_99 then Novelty=p_99;
	drop p_1 p_99;
run;

proc sql;
	create table hms.table1_stats5 as
	select distinct count(Novelty), mean(Novelty),std(Novelty), median(Novelty)
	from hms.nber_new2;
quit;


/*6.Originality*/

proc univariate data=hms.nber_new2 noprint;
  var avg_originality;
  output pctlpre=P_  out=hms.test6 pctlpts=1,99;
run;

*winsorizing;
data hms.test6;
	set hms.test6;
	id=1;
run;

proc sql;
	create table hms.nber_new2 as
	select distinct a.*,b.p_1,b.p_99
	from hms.nber_new2 as a left join hms.test6 as b
	on a.id=b.id;
quit;

data hms.nber_new2;
	set hms.nber_new2;
	if missing(avg_originality)=0 and avg_originality<=p_1 then avg_originality=p_1;
	if missing(avg_originality)=0 and avg_originality>=p_99 then avg_originality=p_99;
	drop p_1 p_99;
run;

proc sql;
	create table hms.table1_stats6 as
	select distinct count(avg_originality), mean(avg_originality),std(avg_originality), median(avg_originality)
	from hms.nber_new2;
quit;


/*7.Generality*/

proc univariate data=hms.nber_new2 noprint;
  var avg_generality;
  output pctlpre=P_  out=hms.test7 pctlpts=1,99;
run;

*winsorizing;
data hms.test7;
	set hms.test7;
	id=1;
run;

proc sql;
	create table hms.nber_new2 as
	select distinct a.*,b.p_1,b.p_99
	from hms.nber_new2 as a left join hms.test7 as b
	on a.id=b.id;
quit;

data hms.nber_new2;
	set hms.nber_new2;
	if missing(avg_generality)=0 and avg_generality<=p_1 then avg_generality=p_1;
	if missing(avg_generality)=0 and avg_generality>=p_99 then avg_generality=p_99;
	drop p_1 p_99;
run;

proc sql;
	create table hms.table1_stats7 as
	select distinct count(avg_generality), mean(avg_generality), std(avg_generality), median(avg_generality)
	from hms.nber_new2;
quit;

**Combining final results;
data hms.test_new;
	set hms.table1_stats hms.table1_stats2 hms.table1_stats3 hms.table1_stats4 hms.table1_stats5 hms.table1_stats6 hms.table1_stats7;
run;

data hms.test_new2;
	set hms.test hms.test2 hms.test3 hms.test4 hms.test5 hms.test6 hms.test7;
	drop id;
run;

data hms.test_new;
	merge hms.test_new hms.test_new2;
run;


****Calculation of VP(Value to price);

data hms.ibes_test;
    set hms.ibes;
	mon=month(ANNDATS);
	yr=year(ANNDATS);
	monyr=catx('/',mon,yr);
/*	lag_gvkey=lag(gvkey);*/
	mon1=ANNDATS;
	format mon1 MONYY7.;
run;

proc sql;
	create table hms.ibes_test1 as
	select distinct gvkey, monyr, mon,yr,mean(VALUE) as EPS
	from hms.ibes_test
	group by gvkey, monyr;
quit;

proc sort data=hms.ibes_test1; by gvkey yr mon; run;



/*data hms.ibes_test2;*/
/*	set hms.ibes_test1;*/
/*	by gvkey;*/
/*	yr_1=lag(yr);*/
/*	mon_1=lag(mon);*/
/*	if yr=yr_1 then n=sum(mon,-mon_1);*/
/*	else n=sum(-(yr_1+1),yr)*12+(12-mon_1)+mon;*/
/*	if first.gvkey then n=.;*/
/*	drop mon_1 yr_1;*/
/*run;*/
/**/
/*data hms.ibes_test3;*/
/*	set hms.ibes_test2;*/
/*	if n=1;*/
/*run;*/
/**/
/*data hms.ibes_test3;*/
/*	set hms.ibes_test3;*/
/*	by gvkey;*/
/*	yr_1=lag(yr);*/
/*	mon_1=lag(mon);*/
/*	if yr=yr_1 then n1=sum(mon,-mon_1);*/
/*	else n1=sum(-(yr_1+1),yr)*12+(12-mon_1)+mon;*/
/*	if first.gvkey then n1=.;*/
/*	drop mon_1 yr_1;*/
/*run;*/
/**/
/*/*Deleting firms which have less than 1 month data */*/
/**/
/*proc sql;*/
/*	create table hms.ibes_test2 as*/
/*	select distinct gvkey,count(distinct monyr) as ncount*/
/*	from hms.ibes_test1*/
/*	group by gvkey;*/
/*quit;*/
/**/
/*data hms.ibes_test2;*/
/*	set hms.ibes_test2;*/
/*	if ncount<3 then delete;*/
/*run;*/
/**/
/*proc sql;*/
/*	create table hms.ibes_test3 as*/
/*	select distinct b.**/
/*	from hms.ibes_test2 as a,hms.ibes_test1 as b*/
/*	where a.gvkey=b.gvkey;*/
/*quit;*/
/**/
/*proc sql;*/
/*  drop table hms.ibes_test1,hms.ibes_test2;*/
/*quit;





*********************************************************************;
/*Merging Monthly stock data with ccmlinks and then with IBES data */
proc sql;
	create table hms.monthly_new as
	select distinct a.*,b.gvkey
	from hms.monthly_data as a,hms.ccmlinks as b
	where a.permno=b.lpermno;
quit;

proc sql;
	create table hms.monthly_new1 as
	select distinct a.*,b.*
	from hms.ibes_test1 as a left join hms.monthly_new as b
	on a.gvkey=b.gvkey and mon=month(b.date) and yr=year(b.date);
quit;

proc sort data=hms.monthly_new1; by gvkey yr mon; run;

data hms.monthly_new1;
	set hms.monthly_new1;
	by gvkey;
	yr_1=lag(yr);
	mon_1=lag(mon);
	if yr=yr_1 then n=sum(mon,-mon_1);
	else n=sum(-(yr_1+1),yr)*12+(12-mon_1)+mon;
	if first.gvkey then n=.;
	drop mon_1 yr_1;
	row=_N_;
run;

**creating EPS1, EPS2, n1 and n2 variables;
proc sql;
	create table hms.monthly_new1 as
	select distinct a.*,b.n as n1,b.eps as eps1
	from hms.monthly_new1 as a left join hms.monthly_new1 as b
	on a.gvkey=b.gvkey and a.row=b.row-1;
quit;

proc sql;
	create table hms.monthly_new1 as
	select distinct a.*,b.n as n2,b.eps as eps2
	from hms.monthly_new1 as a left join hms.monthly_new1 as b
	on a.gvkey=b.gvkey and a.row=b.row-2;
quit;

proc sort data=hms.monthly_new1; by gvkey yr mon; run;

**Merging above dataset with Book Equiy data;
/*proc sql;*/
/*	create table hms.monthly_new1 as*/
/*	select distinct a.*,b.CEQ*/
/*	from hms.monthly_new1 as a left join hms.moonshots1 as b*/
/*	on a.gvkey=b.gvkey and a.yr=year(b.DATADATE);*/
/*quit;*/

proc sql;
	create table hms.monthly_new1 as
	select distinct a.*,b.bkvlps
	from hms.monthly_new1 as a left join inv.annual as b
	on a.gvkey=b.gvkey and a.yr=year(b.DATADATE);
quit;

proc sort data=hms.monthly_new1; by gvkey yr mon; run;

/*data hms.monthly_new2;*/
/*	set hms.monthly_new1;*/
/*	if n1=1 and n2=1 then V_t=sum((sum(eps/100,-ret)*CEQ)/(1+ret),(sum(eps1/100,-ret)*CEQ)/(1+ret)**2,(sum(eps2/100,-ret)*CEQ)/ret*(1+ret)**2)/abs(PRC);*/
/*	else if n1=1 and n2>1 then V_t=sum((sum(eps/100,-ret)*CEQ)/(1+ret),(sum(eps1/100,-ret)*CEQ)/(1+ret)**2,(sum(eps1/100,-ret)*CEQ)/ret*(1+ret)**2)/abs(PRC);*/
/*	else V_t=sum((sum(eps/100,-ret)*CEQ)/(1+ret),(sum(eps/100,-ret)*CEQ)/(1+ret)**2,(sum(eps/100,-ret)*CEQ)/ret*(1+ret)**2)/abs(PRC);*/
/*run;*/

data hms.monthly_new2;
	set hms.monthly_new1;
	if n1=1 and n2=1 then V_t=sum((sum(eps/100,-ret)*bkvlps)/(1+ret),(sum(eps1/100,-ret)*bkvlps)/(1+ret)**2,(sum(eps2/100,-ret)*bkvlps)/ret*(1+ret)**2)/abs(PRC);
	else if n1=1 and n2>1 then V_t=sum((sum(eps/100,-ret)*bkvlps)/(1+ret),(sum(eps1/100,-ret)*bkvlps)/(1+ret)**2,(sum(eps1/100,-ret)*bkvlps)/ret*(1+ret)**2)/abs(PRC);
	else V_t=sum((sum(eps/100,-ret)*bkvlps)/(1+ret),(sum(eps/100,-ret)*bkvlps)/(1+ret)**2,(sum(eps/100,-ret)*bkvlps)/ret*(1+ret)**2)/abs(PRC);
run;



********************************************************************
                         Control variables;
********************************************************************;


*Converts fiscal year into calendar year data;

data hms.moonshots1;
   set hms.moonshots1;
   month=month(datadate);
   if (1<=month<=5) then fyear=fyear+1;
run;

**merging nber_new2 & moonshots1;
proc sql;
	create table hms.nber_new2 as
	select distinct a.*,b.*
	from hms.nber_new2 as a left join hms.moonshots1 as b
	on a.gvkey=input(b.gvkey,best12.) and a.fyear=b.fyear;
quit;

**creating sale_3 variable to calculate GS;
proc sql;
	create table hms.nber_new2 as
	select distinct a.*,b.sale as sale_3
	from hms.nber_new2 as a left join hms.nber_new2 as b
	on a.gvkey=b.gvkey and a.fyear=b.fyear+3;
quit;

**creating ceq_1, re_1 and txdb_1 variable;

proc sql;
	create table hms.nber_new2 as
	select distinct a.*,b.ceq as ceq_1, b.re as re_1, b.txdb as txdb_1
	from hms.nber_new2 as a left join hms.nber_new2 as b
	on a.gvkey=b.gvkey and a.fyear=b.fyear+1;
quit;

**calculating annual trading volume and merging with nber_new2;


data hms.controls;
	set hms.nber_new2;
	BP=be/me;
	CFP=sum(IB,DP,RDP)/at_1;
	GS=(sale-sale_3)/sale_3;
	Leverage=sum(DLTT,DLC)/(sum(DLTT,DLC,SEQ));
	EI=sum(ceq,-ceq_1,re,-re_1,txdb,-txdb_1)/at_1;
run;



****   8) VP;

proc sql;
	create table hms.VP as
	select distinct gvkey,yr,mean(V_t) as VP
	from hms.monthly_new2
	group by gvkey,yr;
quit;

**merge VP with controls dataset;
proc sql;
	create table hms.controls as
	select distinct a.*,b.VP
	from hms.controls as a left join hms.VP as b
	on a.gvkey=input(b.gvkey,best12.) and a.fyear=b.yr;
quit;


proc univariate data=hms.controls noprint;
  var VP;
  output pctlpre=P_  out=hms.test pctlpts=1,99;
run;
*winsorizing;
data hms.test;
	set hms.test;
	id=1;
run;

/*data hms.controls;*/
/*	set hms.controls;*/
/*	id=1;*/
/*run;*/


proc sql;
	create table hms.controls as
	select distinct a.*,b.p_1,b.p_99
	from hms.controls as a left join hms.test as b
	on a.id=b.id;
quit;

data hms.controls;
	set hms.controls;
	if missing(VP)=0 and VP<=p_1 then VP=p_1;
	if missing(VP)=0 and VP>=p_99 then VP=p_99;
	drop p_1 p_99;
run;

proc sql;
	create table hms.table1_stats1 as
	select distinct count(VP), mean(VP),std(VP), median(VP)
	from hms.controls;
quit;



***(9)BP;

proc univariate data=hms.controls noprint;
  var BP;
  output pctlpre=P_  out=hms.test2 pctlpts=1,99;
run;
*winsorizing;
data hms.test2;
	set hms.test2;
	id=1;
run;

proc sql;
	create table hms.controls as
	select distinct a.*,b.p_1,b.p_99
	from hms.controls as a left join hms.test2 as b
	on a.id=b.id;
quit;

data hms.controls;
	set hms.controls;
	if missing(BP)=0 and BP<=p_1 then BP=p_1;
	if missing(BP)=0 and BP>=p_99 then BP=p_99;
	drop p_1 p_99;
run;

proc sql;
	create table hms.table1_stats2 as
	select distinct count(BP), mean(BP),std(BP), median(BP)
	from hms.controls;
quit;

***(10)GS;

proc univariate data=hms.controls noprint;
  var GS;
  output pctlpre=P_  out=hms.test3 pctlpts=1,99;
run;
*winsorizing;
data hms.test3;
	set hms.test3;
	id=1;
run;

proc sql;
	create table hms.controls as
	select distinct a.*,b.p_1,b.p_99
	from hms.controls as a left join hms.test3 as b
	on a.id=b.id;
quit;

data hms.controls;
	set hms.controls;
	if missing(GS)=0 and GS<=p_1 then GS=p_1;
	if missing(GS)=0 and GS>=p_99 then GS=p_99;
	drop p_1 p_99;
run;

proc sql;
	create table hms.table1_stats3 as
	select distinct count(GS), mean(GS),std(GS), median(GS)
	from hms.controls;
quit;


***(11)LEVERAGE;

proc univariate data=hms.controls noprint;
  var LEVERAGE;
  output pctlpre=P_  out=hms.test4 pctlpts=1,99;
run;
*winsorizing;
data hms.test4;
	set hms.test4;
	id=1;
run;

proc sql;
	create table hms.controls as
	select distinct a.*,b.p_1,b.p_99
	from hms.controls as a left join hms.test4 as b
	on a.id=b.id;
quit;

data hms.controls;
	set hms.controls;
	if missing(LEVERAGE)=0 and LEVERAGE<=p_1 then LEVERAGE=p_1;
	if missing(LEVERAGE)=0 and LEVERAGE>=p_99 then LEVERAGE=p_99;
	drop p_1 p_99;
run;

proc sql;
	create table hms.table1_stats4 as
	select distinct count(LEVERAGE), mean(LEVERAGE),std(LEVERAGE), median(LEVERAGE)
	from hms.controls;
quit;

***(12)AT;

proc univariate data=hms.controls noprint;
  var AT_1;
  output pctlpre=P_  out=hms.test5 pctlpts=1,99;
run;
*winsorizing;
data hms.test5;
	set hms.test5;
	id=1;
run;

proc sql;
	create table hms.controls as
	select distinct a.*,b.p_1,b.p_99
	from hms.controls as a left join hms.test5 as b
	on a.id=b.id;
quit;

data hms.controls;
	set hms.controls;
	if missing(AT_1)=0 and AT_1<=p_1 then AT_1=p_1;
	if missing(AT_1)=0 and AT_1>=p_99 then AT_1=p_99;
	drop p_1 p_99;
run;

proc sql;
	create table hms.table1_stats5 as
	select distinct count(AT_1), mean(AT_1),std(AT_1), median(AT_1)
	from hms.controls;
quit;

***(13)LTG;

proc sql;
	create table hms.LTG1 as
	select distinct oftic,year(ANNDATS) as fyear,mean(value) as LTG
	from hms.LTG
	group by OFTIC,year(ANNDATS);
quit;

data hms.LTG1;
	set hms.LTG1;
	if missing(OFTIC)=0;
	LTG1=LTG/100;
run;

**linking IBES with compustat data;
proc sql;
	create table hms.LTG1 as
	select distinct a.*,b.gvkey,b.lpermno,b.cusip,b.sic
	from hms.LTG1 as a left join hms.ibes_link as b
	on a.oftic=b.tic ;
quit;


**Merging LTG1 with controls dataset;
proc sql;
	create table hms.controls as
	select distinct a.*,b.LTG1
	from hms.controls as a left join hms.LTG1 as b
	on a.gvkey=input(b.gvkey,best12.) and a.fyear=b.fyear;
quit;

proc univariate data=hms.controls noprint;
  var LTG1;
  output pctlpre=P_  out=hms.test6 pctlpts=1,99;
run;

proc sql;
	create table hms.table1_stats6 as
	select distinct count(LTG1), mean(LTG1),std(LTG1), median(LTG1)
	from hms.controls;
quit;

***(14)EI;

proc univariate data=hms.controls noprint;
  var EI;
  output pctlpre=P_  out=hms.test7 pctlpts=1,99;
run;
*winsorizing;
data hms.test7;
	set hms.test7;
	id=1;
run;

proc sql;
	create table hms.controls as
	select distinct a.*,b.p_1,b.p_99
	from hms.controls as a left join hms.test7 as b
	on a.id=b.id;
quit;

data hms.controls;
	set hms.controls;
	if missing(EI)=0 and EI<=p_1 then EI=p_1;
	if missing(EI)=0 and EI>=p_99 then EI=p_99;
	drop p_1 p_99;
run;

proc sql;
	create table hms.table1_stats7 as
	select distinct count(EI), mean(EI)*100,std(EI)*100, median(EI)*100
	from hms.controls;
quit;

data hms.table1_stats7;
	set hms.table1_stats7;
    _TEMG002=_TEMA005;
	_TEMG003=_TEMA006;
	_TEMG004=_TEMA007;
	drop _TEMA005 _TEMA006 _TEMA007;
run;


***(15)Turnover;

proc sql;
	create table hms.volume as
	select distinct permno,year(date) as fyear, mean(vol/shrout) as turnover
	from hms.vol
	group by permno,year(date);
quit;

**merging with controls dataset;
proc sql;
	create table hms.controls as
	select distinct a.*,b.turnover 
	from hms.controls as a left join hms.volume as b
	on a.permno=b.permno and a.fyear=b.fyear;
quit;

proc univariate data=hms.controls noprint;
  var turnover;
  output pctlpre=P_  out=hms.test8 pctlpts=1,99;
run;
*winsorizing;
data hms.test8;
	set hms.test8;
	id=1;
run;

proc sql;
	create table hms.controls as
	select distinct a.*,b.p_1,b.p_99
	from hms.controls as a left join hms.test8 as b
	on a.id=b.id;
quit;

data hms.controls;
	set hms.controls;
	if missing(turnover)=0 and turnover<=p_1 then turnover=p_1;
	if missing(turnover)=0 and turnover>=p_99 then turnover=p_99;
	drop p_1 p_99;
run;

proc sql;
	create table hms.table1_stats8 as
	select distinct count(turnover), mean(turnover)*100,std(turnover)*100, median(turnover)*100
	from hms.controls;
quit;

data hms.table1_stats8;
	set hms.table1_stats8;
    _TEMG002=_TEMA005;
	_TEMG003=_TEMA006;
	_TEMG004=_TEMA007;
	drop _TEMA005 _TEMA006 _TEMA007;
run;



**(16) CF;

proc univariate data=hms.controls noprint;
  var CFP;
  output pctlpre=P_  out=hms.test9 pctlpts=1,99;
run;
*winsorizing;
data hms.test9;
	set hms.test9;
	id=1;
run;

proc sql;
	create table hms.controls as
	select distinct a.*,b.p_1,b.p_99
	from hms.controls as a left join hms.test9 as b
	on a.id=b.id;
quit;

data hms.controls;
	set hms.controls;
	if missing(CFP)=0 and CFP<=p_1 then CFP=p_1;
	if missing(CFP)=0 and CFP>=p_99 then CFP=p_99;
	drop p_1 p_99;
run;

proc sql;
	create table hms.table1_stats9 as
	select distinct count(CFP), mean(CFP)*100,std(CFP)*100, median(CFP)*100
	from hms.controls;
quit;

data hms.table1_stats9;
	set hms.table1_stats9;
    _TEMG002=_TEMA005;
	_TEMG003=_TEMA006;
	_TEMG004=_TEMA007;
	drop _TEMA005 _TEMA006 _TEMA007;
run;


**Combining control variables results;

data hms.test_new2;
	set hms.table1_stats1 hms.table1_stats2 hms.table1_stats3 hms.table1_stats4 hms.table1_stats5 hms.table1_stats6 hms.table1_stats7 hms.table1_stats8 hms.table1_stats9;
run;

data hms.test_new3;
	set hms.test hms.test2 hms.test3 hms.test4 hms.test5 hms.test6 hms.test7 hms.test8 hms.test9;
	drop id;
run;

data hms.test_new2;
	merge hms.test_new2 hms.test_new3;
run;


*********************************************************
                             MF_Flow
*********************************************************;


***********************
***Estimating outflows
**********************;

data hms.Mutualfundsreturns_CRSP;
	set hms.Mutualfundsreturns_CRSP;
	quarter=qtr(CALDT);
	fyear=year(CALDT);
run;

**creating quartlerly returns variable;
proc sql;
	create table hms.fundflowscrsp_qtrly as
	select distinct CRSP_FUNDNO,fyear,quarter,sum(mret) as ret
	from hms.Mutualfundsreturns_CRSP
	group by CRSP_FUNDNO,fyear,quarter;
quit;

**Creating end of quarter TA variable;
data hms.fundflowscrsp1;
	set hms.Mutualfundsreturns_CRSP;
	by CRSP_FUNDNO fyear quarter;
	if last.quarter=1;
run; 

**Merging returns and TA variable;
proc sql;
	create table hms.fundflowscrsp as
	select distinct a.*,b.mtna
	from hms.fundflowscrsp_qtrly as a left join hms.fundflowscrsp1 as b
	on a.CRSP_FUNDNO=b.CRSP_FUNDNO and a.quarter=b.quarter and a.fyear=b.fyear;
quit;

data hms.fundflowscrsp;
	set hms.fundflowscrsp;
	n=_N_;
run;

proc sql;
	create table hms.fundflowscrsp as
	select distinct a.*,b.mtna as mtna_1
	from hms.fundflowscrsp as a left join hms.fundflowscrsp as b
	on a.CRSP_FUNDNO=b.CRSP_FUNDNO and a.n=b.n+1;
quit;

data hms.fundflowscrsp;
	set hms.fundflowscrsp;
	outflow=sum(-mtna_1*(1+ret),mtna)/(mtna_1);
run;


**merging quarterly data with price and shares data;

data hms.mf_flows1;
	set hms.mf_flows1;
	date=intnx('month',Rdate,-1); /*reported late by a month */
	format date date9.;
	quarter=qtr(date);
	fyear=year(date);
run;

proc sql;
	create table hms.fundflowscrsp1 as
	select distinct a.*,b.outflow
	from hms.mf_flows1 as a left join hms.fundflowscrsp as b
	on a.FUNDNO=b.CRSP_FUNDNO and a.quarter=b.quarter and a.fyear=b.fyear;
quit;

**QFlow numerator;
data hms.fundflowscrsp1;
	set hms.fundflowscrsp1;
	if outflow>0.05 then outflow1=outflow;
run;

data hms.fundflowscrsp1;
	set hms.fundflowscrsp1;
	QF_num=outflow*shares*prc;
	QF_num1=outflow1*shares*prc;
run;

**Merging the above dataset with trading volume from CRSP;

proc sql;
	create table hms.tradingvol_qtrly as
	select distinct permno,cusip,fyear,quarter,sum(vol) as qtrly_vol
	from hms.monthlydatacrsp
	group by permno,fyear,quarter;
quit;


proc sql;
	create table hms.fundflowscrsp1 as
	select distinct a.*,b.permno,b.qtrly_vol
	from hms.fundflowscrsp1 as a left join hms.tradingvol_qtrly as b
	on a.cusip=b.cusip and a.quarter=b.quarter and a.fyear=b.fyear;
quit;





** estimating QFlow final;

proc sql;
	create table hms.QFlow as
	select distinct permno,cusip,fyear,sum(QF_num/(qtrly_vol*PRC)) as QFlow,
	sum(QF_num1/(qtrly_vol*PRC)) as QFlow1 /*numerator is already in millions*/
	from hms.fundflowscrsp1
	group by permno,fyear;
quit;

/*proc sql;*/
/*	create table hms.QFlow1 as*/
/*	select distinct permno,cusip,fyear,sum(QFlow) as QFlow_annual*/
/*	from hms.QFlow*/
/*	group by permno,cusip,fyear;*/
/*quit;*/

/*data hms.controls;*/
/*	set hms.controls;*/
/*	drop QFlow QFlow1;*/
/*run; */

***Merging controls and QFlow datasets;
proc sql;
	create table hms.controls as
	select distinct a.*,b.QFlow,b.QFlow1
	from hms.controls as a left join hms.QFlow as b
	on a.permno=b.permno and a.fyear=b.fyear;
quit;


proc univariate data=hms.controls noprint;
  var QFlow1;
  output pctlpre=P_  out=hms.test pctlpts=1,99;
run;
*winsorizing;
data hms.test;
	set hms.test;
	id=1;
run;

proc sql;
	create table hms.controls as
	select distinct a.*,b.p_1,b.p_99
	from hms.controls as a left join hms.test as b
	on a.id=b.id;
quit;

data hms.controls;
	set hms.controls;
	if missing(QFlow1)=0 and QFlow1<=p_1 then QFlow1=p_1;
	if missing(QFlow1)=0 and QFlow1>=p_99 then QFlow1=p_99;
	drop p_1 p_99;
run;

proc sql;
	create table hms.table1_stats10 as
	select distinct count(QFlow1), mean(QFlow1),std(QFlow1), median(QFlow1)
	from hms.controls;
quit;


******Adding age varibale to controls dataset;

data hms.age;
	set hms.age;
	if 1<=month(BEGDAT)<=6 then fyear=year(BEGDAT);
	else fyear=year(BEGDAT)+1;
run;


proc sql;
	create table hms.controls as
	select distinct a.*,sum(-b.fyear,a.fyear) as age
	from hms.controls as a left join hms.age as b
	on a.permno=b.permno;
quit; 

data hms.controls;
	set hms.controls;
	if age>50 then age=.;
run;

proc univariate data=hms.controls noprint;
  var age;
  output pctlpre=P_  out=hms.test pctlpts=1,99;
run;

proc sql;
	create table hms.table1_stats11 as
	select distinct count(age), mean(age),std(age), median(age)
	from hms.controls;
quit;
************************************************************

                      Normalizing
***********************************************************;

data hms.controls1;
	set hms.controls;
	keep permno fyear RDP CAPXP npat citation Novelty avg_originality avg_generality VP QFlow1 BP GS CFP Leverage 
	age AT_1 LTG1 EI turnover id;
	id=1;
run;

proc sql;
	create table hms.stats as
	select distinct mean(RDP) as mean_var1,std(RDP) as std_var1,
	mean(CAPXP) as mean_var2,std(CAPXP) as std_var2,
	mean(npat) as mean_var3,std(npat) as std_var3,
	mean(citation) as mean_var4,std(citation) as std_var4,
	mean(Novelty) as mean_var5,std(Novelty) as std_var5,
	mean(avg_originality) as mean_var6,std(avg_originality) as std_var6,
	mean(avg_generality) as mean_var7,std(avg_generality) as std_var7,
	mean(VP) as mean_var8,std(VP) as std_var8,
	mean(QFlow1) as mean_var9,std(QFlow1) as std_var9,
	mean(BP) as mean_var10,std(BP) as std_var10,
	mean(GS) as mean_var11,std(GS) as std_var11,
	mean(CFP) as mean_var12,std(CFP) as std_var12,
	mean(Leverage) as mean_var13,std(Leverage) as std_var13,
	mean(age) as mean_var14,std(age) as std_var14,
	mean(AT_1) as mean_var15,std(AT_1) as std_var15,
	mean(LTG1) as mean_var16,std(LTG1) as std_var16,
	mean(EI) as mean_var17,std(EI) as std_var17,
	mean(turnover) as mean_var18,std(turnover) as std_var18
	from hms.controls1;
quit;

data hms.stats;
	set hms.stats;
	id=1;
run;

proc sql;
	create table hms.controls1 as
	select distinct a.*,b.*
	from hms.controls1 as a left join hms.stats as b
	on a.id=b.id;
quit;


**Demeaning;
data hms.controls1;
	set hms.controls1;
	var1=RDP-mean_var1;
	var2=CAPXP-mean_var2; 
	var3=npat-mean_var3; 
	var4=citation-mean_var4; 
	var5=Novelty-mean_var5; 
	var6=avg_originality-mean_var6; 
	var7=avg_generality-mean_var7; 
	var8=VP-mean_var8; 
	var9=QFlow1-mean_var9;
	var10=BP-mean_var10; 
	var11=GS-mean_var11; 
	var12=CFP-mean_var12; 
	var13=Leverage-mean_var13;
	var14=age-mean_var14;
	var15=at_1-mean_var15;
	var16=ltg1-mean_var16;
	var17=EI-mean_var17;
	var18=turnover-mean_var18;

	drop mean_var1 mean_var2 mean_var3 mean_var4 mean_var5 mean_var6 mean_var7 mean_var8 mean_var9 mean_var10 
    mean_var11 mean_var12 mean_var13 mean_var14 mean_var15 mean_var16 mean_var17 mean_var18;
run;

**Normalizing;

data hms.controls1;
	set hms.controls1;
	var1=var1/std_var1;
	var2=var2/std_var2; 
	var3=var3/std_var3; 
	var4=var4/std_var4; 
	var5=var5/std_var5; 
	var6=var6/std_var6; 
	var7=var7/std_var7; 
	var8=var8/std_var8; 
	var9=var9/std_var9;
	var10=var10/std_var10;
	var11=var11/std_var11; 
	var12=var12/std_var12; 
	var13=var13/std_var13;
    var14=var14/std_var14; 
	var15=var15/std_var15; 
	var16=var16/std_var16; 
	var17=var17/std_var17; 
	var18=var18/std_var18;  

	drop std_var1 std_var2 std_var3 std_var4a std_var5a std_var4b std_var5b std_var6 std_var7 std_var8 std_var9
	std_var10 std_var11 std_var12 std_var13 std_var14 std_var15 std_var16 std_var17 std_var18;
run;

proc sql;
	create table hms.controls1 as
	select distinct a.*,b.twodigit
	from hms.controls1 as a left join hms.controls as b
	on a.permno=b.permno and a.fyear=b.fyear;
quit;

proc sort data=hms.controls1 nodupkey; by permno fyear;run;

**adding gvkey variable in controls dataset;
proc sql;
	create table hms.controls1 as
	select distinct a.*,b.gvkey
	from hms.controls1 as a left join hms.controls as b
	on a.permno=b.permno and a.fyear=b.fyear;
quit;

**merging ACT and LCT data with controls1;

proc sql;
	create table hms.controls1 as
	select distinct a.*,(b.act/b.lct) as CR
	from hms.controls1 as a left join inv.new as b
	on a.gvkey=input(b.gvkey,best12.) and a.fyear=b.fyear;
quit;

**Adding dummies used in tables 6-9;

*(1)low VP;

proc univariate data=hms.controls1 noprint;
  var var8;
  output pctlpre=P_  out=hms.test pctlpts=20; /*, 75 to 100 by 5*/
run;

data hms.test;
	set hms.test;
	id=1;
run;

proc sql;
	create table hms.controls1 as
	select distinct a.*,b.P_20
	from hms.controls1 as a left join hms.test as b
	on a.id=b.id;
quit;

data hms.controls1;
	set hms.controls1;
	if var8<=p_20 then lowVP=1;
	else lowVP=0;
	drop p_20;
run;

*(2)low Flow;

proc univariate data=hms.controls1 noprint;
  var var9;
  output pctlpre=P_  out=hms.test pctlpts=20; /*, 75 to 100 by 5*/
run;

data hms.test;
	set hms.test;
	id=1;
run;

proc sql;
	create table hms.controls1 as
	select distinct a.*,b.P_20
	from hms.controls1 as a left join hms.test as b
	on a.id=b.id;
quit;

data hms.controls1;
	set hms.controls1;
	if var9<=p_20 then lowFlow=1;
	else lowFlow=0;
	drop p_20;
run;

*(3)High GS;

proc univariate data=hms.controls1 noprint;
  var var11;
  output pctlpre=P_  out=hms.test pctlpts=80; /*, 75 to 100 by 5*/
run;

data hms.test;
	set hms.test;
	id=1;
run;

proc sql;
	create table hms.controls1 as
	select distinct a.*,b.P_80
	from hms.controls1 as a left join hms.test as b
	on a.id=b.id;
quit;

data hms.controls1;
	set hms.controls1;
	if var11>=p_80 then HighGS=1;
	else HighGS=0;
	drop p_80;
run;

*(4)High Turn;

proc univariate data=hms.controls1 noprint;
  var var18;
  output pctlpre=P_  out=hms.test pctlpts=80; /*, 75 to 100 by 5*/
run;

data hms.test;
	set hms.test;
	id=1;
run;

proc sql;
	create table hms.controls1 as
	select distinct a.*,b.P_80
	from hms.controls1 as a left join hms.test as b
	on a.id=b.id;
quit;

data hms.controls1;
	set hms.controls1;
	if var18>=p_80 then Highturn=1;
	else Highturn=0;
	drop p_80;
run;

**adding roa_t variable in controls dataset;
proc sql;
	create table hms.controls1 as
	select distinct a.*,b.roa_t
	from hms.controls1 as a left join hms.controls as b
	on a.permno=b.permno and a.fyear=b.fyear;
quit;


**adding CR_1 variable and calculating change in CR;
proc sql;
	create table hms.controls1 as
	select distinct a.*,b.cr as cr_1
	from hms.controls1 as a left join hms.controls1 as b
	on a.permno=b.permno and a.fyear=b.fyear+1;
quit;

proc sort data=hms.controls1 nodupkey; by permno fyear;run;

data hms.controls1;
	set hms.controls1;
	DCR=CR-CR_1;
	drop cr cr_1;
run;
