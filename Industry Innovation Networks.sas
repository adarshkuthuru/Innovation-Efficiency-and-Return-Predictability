libname NCentral 'F:\Industry Innovation Networks'; run;

PROC IMPORT OUT= WORK.Centrality
            DATAFILE= "F:\Industry Innovation Networks\Data\Innovation_Centrality_4digit_SIC.xlsx"
            DBMS=EXCEL REPLACE;
     RANGE="sheet1$";
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= WORK.Closeness
            DATAFILE= "F:\Industry Innovation Networks\Data\ICTCloseness.xlsx"
            DBMS=EXCEL REPLACE;
     RANGE="allpat_network_ictcloseness$";
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= WORK.FF3
            DATAFILE= "F:\Industry Innovation Networks\Data\FF3factor_monthly.xlsx"
            DBMS=EXCEL REPLACE;
     RANGE="FF3factor_monthly$";
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC IMPORT OUT= WORK.FF5
            DATAFILE= "F:\Industry Innovation Networks\Data\FF5factor_monthly.xlsx"
            DBMS=EXCEL REPLACE;
     RANGE="FF5factor_monthly$";
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
PROC IMPORT OUT= WORK.MOM
            DATAFILE= "F:\Industry Innovation Networks\Data\FFMomentum_monthly.xlsx"
            DBMS=EXCEL REPLACE;
     RANGE="FFMomentum_monthly$";
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;



/*Monthly stock data with SIC & share codes from CRSP*/

data NCentral.MonthlySIC2; 
  set NCentral.MonthlySIC;
  if missing(prc)=1 then delete;
  if missing(siccd)=1 then delete;
  if missing(ret)=1 then delete;
run;

proc sort data=NCentral.MonthlySIC2; by siccd date; run;


/*Monthly stock data */
data NCentral.MonthlySIC2;
  set NCentral.MonthlySIC2;
   if missing(PRC)=0 and missing(SHROUT)=0 and SHROUT>0 then ME=(abs(PRC)*SHROUT*1000)/1000000; *SHROUT SHOULD BE GREATER THAN 0 TO MAKE SENSE;   
   label ME='Market Cap ($M)';
   if missing(ME)=1 then delete;
   keep permno Date SICCD PRC RET ME;
run;
proc sort data=NCentral.MonthlySIC2 nodupkey; by permno date; run;

/*calculation of weights*/

data MonthlySIC2;
  set NCentral.MonthlySIC2;
  by permno date;
  LagME=lag(ME);
  if first.permno=1 then LagME=.;
run;
data MonthlySIC2;
  set MonthlySIC2;
  nvar=catt(date,siccd);
run;

proc sort data=MonthlySIC2; by nvar  ME; run; 

data MonthlySIC2;
  set MonthlySIC2;
  by nvar;
  Retain SumME;
  SumME = sum(SumME,LagME);
  if first.nvar=1 then SumME=LagME;
run;


proc sql;
  create table MonthlySIC3 as
  select distinct *, max(SumME) as MaxSumME
  from MonthlySIC2
  group by nvar
  order by nvar, ME desc;
quit;

/*Monthly industry level returns */

data MonthlySIC3;
  set MonthlySIC3;
  wt=LagME/MaxSumME;
  ret1=wt*ret;
run;


proc sql;
  create table MonthlySIC4 as
  select distinct date, siccd, nvar, max(ret1) as MonthlyRet
  from MonthlySIC3
  group by nvar;
/*  order by nvar, ME desc;*/
quit;

data MonthlySIC4;  
  set MonthlySIC4;
  if missing(MonthlyRet)=1 then delete;
  year=year(date);
  year1=year-1;
run;



/*******************************/
/*** Form pf quintiles based on closeness ***/
/*******************************/


proc sort data=Closeness; by citingGyear ictCloseness; run;

data Closeness;
  set Closeness;
  if missing(ictDist)=1 then delete;
run; 

/*creating numeric siccd column*/
data Closeness;
   set Closeness;
   siccd = input(citingSic, 4.);
run;

proc rank data=Closeness groups=5 out=Closeness_quint;
  by citingGyear;
  var ictCloseness;
  ranks Rank_closeness; 
run;

data Closeness_quint;
  set Closeness_quint;
  Rank_closeness=Rank_closeness+1; /*1 is low and 5 is high*/
run;

/*merging quintiles with returns data */

proc sql;
  create table MonthlySIC5 as
  select distinct a.*, b.Date,b.MonthlyRet
  from Closeness_quint as a, MonthlySIC4 as b
  where a.citingGyear=b.year1 and a.siccd=b.siccd /*because this years quintiles are used to predict next years returns*/
  order by a.citingGyear,a.Rank_closeness,a.citingSic;
quit;
proc sort data=MonthlySIC5 out=MonthlySIC6; by Date; run;

/*Constructing high-low portfolios*/
proc sql;
  create table MonthlySIC6A as
  select distinct Date, Rank_closeness,mean(MonthlyRet) as HoldRet
  from MonthlySIC6
  group by Date, Rank_closeness
  order by Date, Rank_closeness;
quit;

proc sql;
  create table HighLow as
  select distinct a.date, 6 as Rank_closeness, a.HoldRet-b.HoldRet as HighLowRet
  from MonthlySIC6A(where=(Rank_closeness=5)) as a, MonthlySIC6A(where=(Rank_closeness=1)) as b
  where a.Date=b.Date;        
quit;

data HighLow;
  set HighLow;
  year=year(date);
  month=month(date);
run;

/*data set for FF3 and momentum regression */
proc sql;
  create table model1 as
  select distinct a.date, a.HighLowRet, b.*,c.mom
  from HighLow as a, FF3 as b,Mom as c
  where a.year=b.year=c.year and a.month=b.month=c.month;        
quit;

/*data set for FF5 and momentum regression */
proc sql;
  create table model3 as
  select distinct a.date, a.HighLowRet, b.*,c.mom
  from HighLow as a, FF5 as b,Mom as c
  where a.year=b.year=c.year and a.month=b.month=c.month;        
quit;


***Alpha;
/* model1 results */
proc reg data=model1 noprint tableout outest=model1_Alpha;
  model HighLowRet = Mkt_RF SMB HML;
quit;

/* model2 results */
proc reg data=model1 noprint tableout outest=model2_Alpha;
  model HighLowRet = Mkt_RF SMB HML Mom;
quit;


/* model3 results */
proc reg data=model3 noprint tableout outest=model3_Alpha;
  model HighLowRet = Mkt_RF SMB HML RMW CMA;
quit;


/* model4 results */
proc reg data=model3 noprint tableout outest=model4_Alpha;
  model HighLowRet = Mkt_RF SMB HML RMW CMA Mom;
quit;




/*** Full Sample Results ***/
***Mean, STD, T-stat;
proc means data=HighLow noprint;
  var HighLowRet;
  output out=MeanRet mean=mean_HighLowRet;
quit;

proc means data=HighLow noprint;
  var HighLowRet;
  output out=TstatRet t=tstat_HighLowRet;
quit;

proc means data=HighLow noprint;
  var HighLowRet;
  output out=STDRet std=std_HighLowRet;
quit;

data MeanRet;
  set MeanRet;
  drop _Type_ _Freq_;
  Var=1;
  Stat='Mean';
  mean_HighLowRet=mean_HighLowRet*12*100;
run;
data TstatRet;
  set TstatRet;
  drop _Type_ _Freq_;
  Var=2;
  Stat='T-Stat';
run;
data STDRet;
  set STDRet;
  drop _Type_ _Freq_;
  Var=3;
  Stat='STD';
  std_HighLowRet=std_HighLowRet*sqrt(12)*100;
run;


/*******************************/
/*** Form pf quintiles based on centrality ***/
/*******************************/


proc sort data=centrality; by citing_gyear evcentrality; run;

data centrality;
  set centrality;
  if missing(evcentrality)=1 then delete;
run; 

/*creating numeric siccd column*/
data centrality;
   set centrality;
   siccd = input(cited_sic, 4.);
run;

proc rank data=centrality groups=5 out=centrality_quint;
  by citing_gyear;
  var evcentrality;
  ranks Rank_centrality; 
run;

data centrality_quint;
  set centrality_quint;
  Rank_centrality=Rank_centrality+1; /*1 is low and 5 is high*/
run;

/*merging quintiles with returns data */

proc sql;
  create table MonthlySIC7 as
  select distinct a.*, b.Date,b.MonthlyRet
  from centrality_quint as a, MonthlySIC4 as b
  where a.citing_gyear=b.year1 and a.siccd=b.siccd /*because this years quintiles are used to predict next years returns*/
  order by a.citing_gyear,a.Rank_centrality,a.siccd;
quit;

proc sort data=MonthlySIC7 out=MonthlySIC7; by Date; run;

/*Constructing high-low portfolios*/
proc sql;
  create table MonthlySIC7A as
  select distinct Date, Rank_centrality,mean(MonthlyRet) as HoldRet
  from MonthlySIC7
  group by Date, Rank_centrality
  order by Date, Rank_centrality;
quit;

proc sql;
  create table HighLowCent as
  select distinct a.date, 6 as Rank_centrality, a.HoldRet-b.HoldRet as HighLowRet
  from MonthlySIC7A(where=(Rank_centrality=5)) as a, MonthlySIC7A(where=(Rank_centrality=1)) as b
  where a.Date=b.Date;        
quit;

data HighLowCent;
  set HighLowCent;
  year=year(date);
  month=month(date);
run;

/*data set for FF3 and momentum regression */
proc sql;
  create table model5 as
  select distinct a.date, a.HighLowRet, b.*,c.mom
  from HighLowCent as a, FF3 as b,Mom as c
  where a.year=b.year=c.year and a.month=b.month=c.month;        
quit;

/*data set for FF5 and momentum regression */
proc sql;
  create table model7 as
  select distinct a.date, a.HighLowRet, b.*,c.mom
  from HighLowCent as a, FF5 as b,Mom as c
  where a.year=b.year=c.year and a.month=b.month=c.month;        
quit;


***Alpha;
/* model5 results */
proc reg data=model5 noprint tableout outest=model5_Alpha;
  model HighLowRet = Mkt_RF SMB HML;
quit;


/* model6 results */
proc reg data=model5 noprint tableout outest=model6_Alpha;
  model HighLowRet = Mkt_RF SMB HML Mom;
quit;


/* model7 results */
proc reg data=model7 noprint tableout outest=model7_Alpha;
  model HighLowRet = Mkt_RF SMB HML RMW CMA;
quit;


/* model8 results */
proc reg data=model7 noprint tableout outest=model8_Alpha;
  model HighLowRet = Mkt_RF SMB HML RMW CMA Mom;
quit;




/*** Full Sample Results ***/
***Mean, STD, T-stat;
proc means data=HighLowCent noprint;
  var HighLowRet;
  output out=MeanRetCent mean=mean_HighLowRet;
quit;

proc means data=HighLowCent noprint;
  var HighLowRet;
  output out=TstatRetCent t=tstat_HighLowRet;
quit;

proc means data=HighLowCent noprint;
  var HighLowRet;
  output out=STDRetCent std=std_HighLowRet;
quit;

data MeanRetCent;
  set MeanRetCent;
  drop _Type_ _Freq_;
  Var=1;
  Stat='Mean';
  mean_HighLowRet=mean_HighLowRet*12*100;
run;
data TstatRetCent;
  set TstatRetCent;
  drop _Type_ _Freq_;
  Var=2;
  Stat='T-Stat';
run;
data STDRetCent;
  set STDRetCent;
  drop _Type_ _Freq_;
  Var=3;
  Stat='STD';
  std_HighLowRet=std_HighLowRet*sqrt(12)*100;
run;
