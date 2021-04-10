/*libname NCentral 'F:\Industry Innovation Networks'; run;*/
libname NCentral 'F:\Industry Innovation Networks\Data'; run;

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

PROC IMPORT OUT= WORK.CitedComp
            DATAFILE= "F:\Industry Innovation Networks\Data\Citing_Cited_Firms.xlsx"
            DBMS=EXCEL REPLACE;
     RANGE="cited_firms$";
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;



/*Monthly stock data with SIC & share codes from CRSP*/

data MonthlySIC2; 
  set NCentral.MonthlySIC;
  if missing(prc)=1 then delete;
  if missing(siccd)=1 then delete;
  if missing(ret)=1 then delete;
run;
proc sort data=MonthlySIC2; by siccd date; run;


/*Monthly stock data */
data MonthlySIC2;
  set MonthlySIC2;
   if missing(PRC)=0 and missing(SHROUT)=0 and SHROUT>0 then ME=(abs(PRC)*SHROUT*1000)/1000000; *SHROUT SHOULD BE GREATER THAN 0 TO MAKE SENSE;   
   label ME='Market Cap ($M)';
   if missing(ME)=1 then delete;
   keep permno Date SICCD PRC RET ME;
run;
proc sort data=MonthlySIC2 nodupkey; by permno date; run;


/* Industry level monthly returns */
data MonthlySIC2;
  set MonthlySIC2;
  by permno date;
  LagME=lag(ME);
  if first.permno=1 then LagME=.;
run;

proc sort data=MonthlySIC2; by date permno; run;

data MonthlySIC2;
  set MonthlySIC2;
  year=year(date);
run;


proc sql;
  create table IndMonRet as
  select distinct date, siccd, sum(LagME*Ret)/sum(LagME) as IndRet
  from MonthlySIC2
  group by date, siccd;
quit;
data IndMonRet;
  set IndMonRet;
  if missing(IndRet)=1 then delete;
run;


/*
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
*/

/*Monthly industry level returns */
/*
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
  *order by nvar, ME desc;
quit;

data MonthlySIC4;  
  set MonthlySIC4;
  if missing(MonthlyRet)=1 then delete;
  year=year(date);
  year1=year-1;
run;
*/


/*****************************************/
/*** Form quintiles based on closeness ***/
/*****************************************/


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

/* merging quintiles with returns data */
proc sql;
  create table MonthlySIC5 as
  select distinct a.*, b.Date, b.IndRet
  from Closeness_quint as a, IndMonRet as b
  where a.siccd=b.siccd and year(b.date)=a.citingGyear+1  /*because this years quintiles are used to predict next years returns*/
  order by a.citingGyear, a.Rank_closeness, a.citingSic;
quit;
proc sort data=MonthlySIC5 out=MonthlySIC6; by Date Rank_closeness; run;


/*Constructing high-low portfolios*/
proc sql;
  create table MonthlySIC6A as
  select distinct Date, Rank_closeness, mean(IndRet) as HoldRet
  from MonthlySIC6
  group by Date, Rank_closeness
  order by Date, Rank_closeness;
quit;

*Hedge portfolio;
proc sql;
  create table HighLow as
  select distinct a.date, 6 as Rank_closeness, a.HoldRet-b.HoldRet as HoldRet
  from MonthlySIC6A(where=(Rank_closeness=5)) as a, MonthlySIC6A(where=(Rank_closeness=1)) as b
  where a.Date=b.Date;        
quit;

data MonthlySIC7;
  set MonthlySIC6A HighLow;
run;
proc sort data=MonthlySIC7; by date Rank_closeness; run;

data MonthlySIC7;
  set MonthlySIC7;
  year=year(date);
  month=month(date);
run;

/* Factor Data */
proc sql;
  create table MonthlySIC8 as
  select distinct a.date, a.Rank_closeness, a.HoldRet, b.*,c.mom
  from MonthlySIC7 as a, FF3 as b,Mom as c
  where a.year=b.year=c.year and a.month=b.month=c.month;        
quit;

data MonthlySIC8;
  set MonthlySIC8;
  if 1<=Rank_Closeness<=5 then ExRet = HoldRet - RF;
  if Rank_Closeness=6 then ExRet = HoldRet;
run;



/* Summary Stats of Portfolio Returns */
proc sort data=MonthlySIC8; by Rank_Closeness Date; run;
proc means data=MonthlySIC8 noprint;
  by Rank_Closeness;
  var HoldRet ExRet;
  output out=SumStats mean=Mean_HoldRet Mean_ExRet Std=Std_HoldRet Std_ExRet;
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
  create table MonthlySIC9 as
  select distinct a.*, b.Date, b.IndRet
  from centrality_quint as a, IndMonRet as b
  where year(b.date)=a.citing_gyear+1 and a.siccd=b.siccd /*because this years quintiles are used to predict next years returns*/
  order by a.citing_gyear,a.Rank_centrality,a.siccd;
quit;

proc sort data=MonthlySIC9 out=MonthlySIC9; by Date; run;

/*Constructing high-low portfolios*/
proc sql;
  create table MonthlySIC9A as
  select distinct Date, Rank_centrality, mean(IndRet) as HoldRet
  from MonthlySIC9
  group by Date, Rank_centrality
  order by Date, Rank_centrality;
quit;

proc sql;
  create table HighLowCent as
  select distinct a.date, 6 as Rank_centrality, a.HoldRet-b.HoldRet as HoldRet
  from MonthlySIC9A(where=(Rank_centrality=5)) as a, MonthlySIC9A(where=(Rank_centrality=1)) as b
  where a.Date=b.Date;        
quit;

data MonthlySIC10;
  set MonthlySIC9A HighLowCent;
run;
proc sort data=MonthlySIC10; by date Rank_centrality; run;

data MonthlySIC10;
  set MonthlySIC10;
  year=year(date);
  month=month(date);
run;

/* Factor Data */
proc sql;
  create table MonthlySIC11 as
  select distinct a.date, a.Rank_centrality, a.HoldRet, b.*,c.mom
  from MonthlySIC10 as a, FF5 as b,Mom as c
  where a.year=b.year=c.year and a.month=b.month=c.month;        
quit;

data MonthlySIC11;
  set MonthlySIC11;
  if 1<=Rank_centrality<=5 then ExRet = HoldRet - RF;
  if Rank_centrality=6 then ExRet = HoldRet;
run;
