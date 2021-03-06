/******************** Irene Hsueh's BS 851 Homework 8 ********************/
proc import 
datafile="C:/Irene Hsueh's Documents/MS Applied Biostatistics/BS 851 - Applied Statistics in Clinical Trials I/Class 8 - Interaction and Effect Modification/Homework 8/bp.csv" 
out=bp
(rename=(trtgrp=trt))
DBMS=csv replace;   
getnames=yes;
run;

proc format; 
	value cvd_format 0="No" 1="Yes";
	value sex_format 1="Female" 0="Male";
	value trt_format 0="Placebo" 1="Treatment";
run;

data bp;
	set bp;
	label age="Age" cvd="Cardiovascular Disease" trt="Treatment" change="Change in SBP from Baseline";
	format cvd cvd_format. sex sex_format. trt trt_format.;
run;


proc print data=bp (obs=50) label;
id patid;
run;




ODS HTML close;
ODS HTML;




title "Change in Systolic Blood Pressure by Treatment";
proc means data=bp mean std ndec=1;
	class trt;
	var change;
run;
title;

title "Change in Systolic Blood Pressure by Study Site and Treatment";
proc means data=bp mean std ndec=1;
	class site trt;
	var change;
run;
title;




ODS HTML close;
ODS HTML;




title "Unadjusted Treatment Comparison";
proc glm data=bp;
	class trt (ref="Placebo");
	model change = trt / solution clparm; 
run;
title;

title "Adjusted Treatment Comparison";
proc glm data=bp;
	class trt (ref="Placebo") site;
	model change = trt site / solution clparm; 
run;
title;




ODS HTML close;
ODS HTML;




title "Assessing Interaction between Treatment and Study Site";
proc glm data=bp;
	class trt (ref="Placebo") site;
	model change = trt|site / solution clparm;
run;
title;




ODS HTML close;
ODS HTML;




data bp_dummy;
	set bp;
	if site=1 then site1=1;
	else site1=0;
	if site=2 then site2=1;
	else site2=0;
	if trt=1 then new_trt=1;
	else new_trt=0;
	trt_site1=new_trt*site1;
	trt_site2=new_trt*site2;
run;

proc print data=bp_dummy (obs=30) label;
run;


title "Assessing Interaction between Treatment and Study Site using Dummy Variables";
proc reg data=bp_dummy;
	model change = new_trt site1 site2 trt_site1 trt_site2;
	interaction: test trt_site1=0;
	interaction: test trt_site2=0;
run;
title;




ODS HTML close;
ODS HTML;




title "Treatment Comparison at Study Center 1";
proc glm data=bp;
	where site=1;
	class trt (ref="Placebo");
	model change = trt / solution clparm; 
run;
title;


title "Treatment Comparison at Study Center 2";
proc glm data=bp;
	where site=2;
	class trt (ref="Placebo");
	model change = trt / solution clparm; 
run;
title;


title "Treatment Comparison at Study Center 3";
proc glm data=bp;
	where site=3;
	class trt (ref="Placebo");
	model change = trt / solution clparm; 
run;
title;




ODS HTML close;
ODS HTML;




title "CVD by Treatment";
proc freq data=bp;
	tables trt*cvd / nopercent nocol chisq
	oddsratio (CL=wald);
run;
title;

title "CVD by Treatment and Sex";
proc freq data=bp;
	tables sex*trt*cvd / nopercent nocol cmh bdt chisq;
run;
title;




ODS HTML close;
ODS HTML;




title "Assessing Interaction between Treatment and Sex";
proc logistic data=bp;
	class trt(ref="Placebo") sex / param=ref;
	model cvd (event="Yes") = trt|sex / risklimits cl;
	oddsratio trt / at(sex=all);
run;


