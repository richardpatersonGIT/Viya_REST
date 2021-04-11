/* ----------------------------------------
Code exported from SAS Enterprise Guide
DATE: vrijdag 10 november 2017     TIME: 11:43:45
PROJECT: Create_Formats (v2.0)
PROJECT PATH: N:\Units\Ondersteunend\FNC\01 FC\02 Applicatiebeheer\SAS\SAS projecten\Maconomy222_prod\P-SAS003\Create_Formats (v2.0).egp
---------------------------------------- */

/* ---------------------------------- */
/* MACRO: enterpriseguide             */
/* PURPOSE: define a macro variable   */
/*   that contains the file system    */
/*   path of the WORK library on the  */
/*   server.  Note that different     */
/*   logic is needed depending on the */
/*   server type.                     */
/* ---------------------------------- */
%macro enterpriseguide;
%global sasworklocation;
%local tempdsn unique_dsn path;

%if &sysscp=OS %then %do; /* MVS Server */
	%if %sysfunc(getoption(filesystem))=MVS %then %do;
        /* By default, physical file name will be considered a classic MVS data set. */
	    /* Construct dsn that will be unique for each concurrent session under a particular account: */
		filename egtemp '&egtemp' disp=(new,delete); /* create a temporary data set */
 		%let tempdsn=%sysfunc(pathname(egtemp)); /* get dsn */
		filename egtemp clear; /* get rid of data set - we only wanted its name */
		%let unique_dsn=".EGTEMP.%substr(&tempdsn, 1, 16).PDSE"; 
		filename egtmpdir &unique_dsn
			disp=(new,delete,delete) space=(cyl,(5,5,50))
			dsorg=po dsntype=library recfm=vb
			lrecl=8000 blksize=8004 ;
		options fileext=ignore ;
	%end; 
 	%else %do; 
        /* 
		By default, physical file name will be considered an HFS 
		(hierarchical file system) file. 
		*/
		%if "%sysfunc(getoption(filetempdir))"="" %then %do;
			filename egtmpdir '/tmp';
		%end;
		%else %do;
			filename egtmpdir "%sysfunc(getoption(filetempdir))";
		%end;
	%end; 
	%let path=%sysfunc(pathname(egtmpdir));
    %let sasworklocation=%sysfunc(quote(&path));  
%end; /* MVS Server */
%else %do;
	%let sasworklocation = "%sysfunc(getoption(work))/";
%end;
%if &sysscp=VMS_AXP %then %do; /* Alpha VMS server */
	%let sasworklocation = "%sysfunc(getoption(work))";                         
%end;
%if &sysscp=CMS %then %do; 
	%let path = %sysfunc(getoption(work));                         
	%let sasworklocation = "%substr(&path, %index(&path,%str( )))";
%end;
%mend enterpriseguide;

%enterpriseguide


/* Conditionally delete set of tables or views, if they exists          */
/* If the member does not exist, then no action is performed   */
%macro _eg_conditional_dropds /parmbuff;
	
   	%local num;
   	%local stepneeded;
   	%local stepstarted;
   	%local dsname;
	%local name;

   	%let num=1;
	/* flags to determine whether a PROC SQL step is needed */
	/* or even started yet                                  */
	%let stepneeded=0;
	%let stepstarted=0;
   	%let dsname= %qscan(&syspbuff,&num,',()');
	%do %while(&dsname ne);	
		%let name = %sysfunc(left(&dsname));
		%if %qsysfunc(exist(&name)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;

			%end;
				drop table &name;
		%end;

		%if %sysfunc(exist(&name,view)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;
			%end;
				drop view &name;
		%end;
		%let num=%eval(&num+1);
      	%let dsname=%qscan(&syspbuff,&num,',()');
	%end;
	%if &stepstarted %then %do;
		quit;
	%end;
%mend _eg_conditional_dropds;


/* save the current settings of XPIXELS and YPIXELS */
/* so that they can be restored later               */
%macro _sas_pushchartsize(new_xsize, new_ysize);
	%global _savedxpixels _savedypixels;
	options nonotes;
	proc sql noprint;
	select setting into :_savedxpixels
	from sashelp.vgopt
	where optname eq "XPIXELS";
	select setting into :_savedypixels
	from sashelp.vgopt
	where optname eq "YPIXELS";
	quit;
	options notes;
	GOPTIONS XPIXELS=&new_xsize YPIXELS=&new_ysize;
%mend _sas_pushchartsize;

/* restore the previous values for XPIXELS and YPIXELS */
%macro _sas_popchartsize;
	%if %symexist(_savedxpixels) %then %do;
		GOPTIONS XPIXELS=&_savedxpixels YPIXELS=&_savedypixels;
		%symdel _savedxpixels / nowarn;
		%symdel _savedypixels / nowarn;
	%end;
%mend _sas_popchartsize;


ODS PROCTITLE;
OPTIONS DEV=ACTIVEX;
GOPTIONS XPIXELS=0 YPIXELS=0;
FILENAME EGHTMLX TEMP;
ODS HTML(ID=EGHTMLX) FILE=EGHTMLX
    ENCODING='utf-8'
    STYLE=HTMLBlue
    STYLESHEET=(URL="file:///C:/Program%20Files/SASHome/SASEnterpriseGuide/7.1/Styles/HTMLBlue.css")
    ATTRIBUTES=("CODEBASE"="http://www2.sas.com/codebase/graph/v94/sasgraph.exe#version=9,4")
    NOGTITLE
    NOGFOOTNOTE
    GPATH=&sasworklocation
;

/*   START OF NODE: Copy Formats Catalog   */

GOPTIONS ACCESSIBLE;
/* Insert custom code before submitted code here */
options missing='';

libname macfmt base "/part0/app/sas94/config/Lev1/AppData/SASVisualAnalytics/VisualAnalyticsAdministrator/AutoLoad/Formats";

proc catalog cat=macfmt.formats;
   copy out=APFMTLIB.formats;
run;

libname dest "/part0/app/sas94/config/Lev1/Web/SASEnvironmentManager/emi-framework/Datamart/evdmfmts";
proc catalog cat=macfmt.formats;
   copy out=dest.formats;
run;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;
%LET _SASPROGRAMFILEHOST=;


/*   START OF NODE: Create latest Formats Catalog   */

GOPTIONS ACCESSIBLE;
/* Insert custom code before submitted code here */
options missing='';

options mprint mtrace;

%macro sortkey(env=prod);
	%do x=1 %to 12;
		%if "&env"="prod" %then
			%do;
				if sorting&x^=0 then
					do;
						/*voeg alle sortings achter elkaar samen*/
						sort&x=input(put(DimGroupingNumber,$2.)||put(sorting&x,z3.),10.);
					end;
			%end;

		%if "&env"="poc" %then
			%do;
				if sorting&x^=0 then
					do;
						/*voeg alle sortings achter elkaar samen*/
						sort&x=input('111'||put(DimGroupingNumber,$2.)||put(sorting&x,z3.),10.);
					end;
			%end;

		%if "&env"="acc" %then
			%do;
				if sorting&x^=0 then
					do;
						/*voeg alle sortings achter elkaar samen*/
						sort&x=input('222'||put(DimGroupingNumber,$2.)||put(sorting&x,z3.),10.);
					end;
			%end;
	%end;
%mend sortkey;

%Macro loop;
	%Do x=1 %to 12;

		proc Sql;
			Create table grp&x as
				Select distinct
					t1.sort&x as Sorting,
					t1.Grouping&x as Grouping
				from WORK.DimGroupingLine as t1
					/*where t1.sort&x <>.*/
			;
		quit;

	%End;
%Mend loop;

Data DimGroupingLine_prod;
	set MACPRD.DimGroupingLine;

	if trim(DimGroupingNumber) ge "00" and  trim(DimGroupingNumber) le "99";
	%sortkey;
	format sort1--sort12 10.;
run;
/*
Data DimGroupingLine_poc;
	set MACOPOC.DimGroupingLine;

	if trim(DimGroupingNumber) ge "00" and  trim(DimGroupingNumber) le "99";
	%sortkey(env=poc);
	format sort1--sort12 10.;
run;
*/
Data DimGroupingLine_acc;
	set MACOACC.DimGroupingLine;

	if trim(DimGroupingNumber) ge "00" and  trim(DimGroupingNumber) le "99";
	%sortkey(env=acc);
	format sort1--sort12 10.;
run;
Data DimGroupingLine;
	set DimGroupingLine_prod DimGroupingLine_acc;
run;

%loop;

proc Datasets nofs nolist noprint lib=work;
	delete dimgroupingline_prod DimGroupingLine_acc DimGroupingLine;
quit;

run;

GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;
%LET _SASPROGRAMFILEHOST=;


/*   START OF NODE: Create Format DIM1GRP   */

GOPTIONS ACCESSIBLE;
/* --------------------------------------------------------------------
   Manipulates the incoming data into the correct format for PROC
   FORMAT to use as a CNTLIN data set.
   -------------------------------------------------------------------- */
TITLE; FOOTNOTE;
DATA WORK._EG_CFMT;
    LENGTH label $ 55;
    SET WORK.GRP1 (KEEP=Sorting Grouping RENAME=(Sorting=start Grouping=label)) END=__last;
    RETAIN fmtname "dim1grp" type "N";

    end=start;

    OUTPUT;

    IF __last = 1 THEN
      DO;
        hlo = "O";
        label = "Not Specified";
        OUTPUT;
      END;
RUN;

/* --------------------------------------------------------------------
   Creates a new format based on the data values contained within the
   source data set.
   -------------------------------------------------------------------- */
PROC FORMAT LIBRARY=APFMTLIB CNTLIN=WORK._EG_CFMT;
RUN;

/* --------------------------------------------------------------------
   Now that the new SAS format has been created, we want to tidy up by
   deleting the WORK data set
   -------------------------------------------------------------------- */
PROC SQL;
    DROP TABLE WORK._EG_CFMT;
QUIT;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Create Format DIM2GRP   */

GOPTIONS ACCESSIBLE;
/* --------------------------------------------------------------------
   Manipulates the incoming data into the correct format for PROC
   FORMAT to use as a CNTLIN data set.
   -------------------------------------------------------------------- */
TITLE; FOOTNOTE;
DATA WORK._EG_CFMT;
    LENGTH label $ 55;
    SET WORK.GRP2 (KEEP=Sorting Grouping RENAME=(Sorting=start Grouping=label)) END=__last;
    RETAIN fmtname "dim2grp" type "N";

    end=start;

    OUTPUT;

    IF __last = 1 THEN
      DO;
        hlo = "O";
        label = "Not Specified";
        OUTPUT;
      END;
RUN;

/* --------------------------------------------------------------------
   Creates a new format based on the data values contained within the
   source data set.
   -------------------------------------------------------------------- */
PROC FORMAT LIBRARY=APFMTLIB CNTLIN=WORK._EG_CFMT;
RUN;

/* --------------------------------------------------------------------
   Now that the new SAS format has been created, we want to tidy up by
   deleting the WORK data set
   -------------------------------------------------------------------- */
PROC SQL;
    DROP TABLE WORK._EG_CFMT;
QUIT;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Create Format DIM3GRP   */

GOPTIONS ACCESSIBLE;
/* --------------------------------------------------------------------
   Manipulates the incoming data into the correct format for PROC
   FORMAT to use as a CNTLIN data set.
   -------------------------------------------------------------------- */
TITLE; FOOTNOTE;
DATA WORK._EG_CFMT;
    LENGTH label $ 55;
    SET WORK.GRP3 (KEEP=Sorting Grouping RENAME=(Sorting=start Grouping=label)) END=__last;
    RETAIN fmtname "dim3grp" type "N";

    end=start;

    OUTPUT;

    IF __last = 1 THEN
      DO;
        hlo = "O";
        label = "Not Specified";
        OUTPUT;
      END;
RUN;

/* --------------------------------------------------------------------
   Creates a new format based on the data values contained within the
   source data set.
   -------------------------------------------------------------------- */
PROC FORMAT LIBRARY=APFMTLIB CNTLIN=WORK._EG_CFMT;
RUN;

/* --------------------------------------------------------------------
   Now that the new SAS format has been created, we want to tidy up by
   deleting the WORK data set
   -------------------------------------------------------------------- */
PROC SQL;
    DROP TABLE WORK._EG_CFMT;
QUIT;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Create Format DIM4GRP   */

GOPTIONS ACCESSIBLE;
/* --------------------------------------------------------------------
   Manipulates the incoming data into the correct format for PROC
   FORMAT to use as a CNTLIN data set.
   -------------------------------------------------------------------- */
TITLE; FOOTNOTE;
DATA WORK._EG_CFMT;
    LENGTH label $ 55;
    SET WORK.GRP4 (KEEP=Sorting Grouping RENAME=(Sorting=start Grouping=label)) END=__last;
    RETAIN fmtname "dim4grp" type "N";

    end=start;

    OUTPUT;

    IF __last = 1 THEN
      DO;
        hlo = "O";
        label = "Not Specified";
        OUTPUT;
      END;
RUN;

/* --------------------------------------------------------------------
   Creates a new format based on the data values contained within the
   source data set.
   -------------------------------------------------------------------- */
PROC FORMAT LIBRARY=APFMTLIB CNTLIN=WORK._EG_CFMT;
RUN;

/* --------------------------------------------------------------------
   Now that the new SAS format has been created, we want to tidy up by
   deleting the WORK data set
   -------------------------------------------------------------------- */
PROC SQL;
    DROP TABLE WORK._EG_CFMT;
QUIT;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Create Format DIM5GRP   */

GOPTIONS ACCESSIBLE;
/* --------------------------------------------------------------------
   Manipulates the incoming data into the correct format for PROC
   FORMAT to use as a CNTLIN data set.
   -------------------------------------------------------------------- */
TITLE; FOOTNOTE;
DATA WORK._EG_CFMT;
    LENGTH label $ 55;
    SET WORK.GRP5 (KEEP=Sorting Grouping RENAME=(Sorting=start Grouping=label)) END=__last;
    RETAIN fmtname "dim5grp" type "N";

    end=start;

    OUTPUT;

    IF __last = 1 THEN
      DO;
        hlo = "O";
        label = "Not Specified";
        OUTPUT;
      END;
RUN;

/* --------------------------------------------------------------------
   Creates a new format based on the data values contained within the
   source data set.
   -------------------------------------------------------------------- */
PROC FORMAT LIBRARY=APFMTLIB CNTLIN=WORK._EG_CFMT;
RUN;

/* --------------------------------------------------------------------
   Now that the new SAS format has been created, we want to tidy up by
   deleting the WORK data set
   -------------------------------------------------------------------- */
PROC SQL;
    DROP TABLE WORK._EG_CFMT;
QUIT;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Create Format DIM6GRP   */

GOPTIONS ACCESSIBLE;
/* --------------------------------------------------------------------
   Manipulates the incoming data into the correct format for PROC
   FORMAT to use as a CNTLIN data set.
   -------------------------------------------------------------------- */
TITLE; FOOTNOTE;
DATA WORK._EG_CFMT;
    LENGTH label $ 55;
    SET WORK.GRP6 (KEEP=Sorting Grouping RENAME=(Sorting=start Grouping=label)) END=__last;
    RETAIN fmtname "dim6grp" type "N";

    end=start;

    OUTPUT;

    IF __last = 1 THEN
      DO;
        hlo = "O";
        label = "Not Specified";
        OUTPUT;
      END;
RUN;

/* --------------------------------------------------------------------
   Creates a new format based on the data values contained within the
   source data set.
   -------------------------------------------------------------------- */
PROC FORMAT LIBRARY=APFMTLIB CNTLIN=WORK._EG_CFMT;
RUN;

/* --------------------------------------------------------------------
   Now that the new SAS format has been created, we want to tidy up by
   deleting the WORK data set
   -------------------------------------------------------------------- */
PROC SQL;
    DROP TABLE WORK._EG_CFMT;
QUIT;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Create Format from Data Set (7)   */

GOPTIONS ACCESSIBLE;
/* --------------------------------------------------------------------
   Manipulates the incoming data into the correct format for PROC
   FORMAT to use as a CNTLIN data set.
   -------------------------------------------------------------------- */
TITLE; FOOTNOTE;
DATA WORK._EG_CFMT;
    LENGTH label $ 55;
    SET WORK.GRP7 (KEEP=Sorting Grouping RENAME=(Sorting=start Grouping=label)) END=__last;
    RETAIN fmtname "dim7grp" type "N";

    end=start;

    OUTPUT;

    IF __last = 1 THEN
      DO;
        hlo = "O";
        label = "Not Specified";
        OUTPUT;
      END;
RUN;

/* --------------------------------------------------------------------
   Creates a new format based on the data values contained within the
   source data set.
   -------------------------------------------------------------------- */
PROC FORMAT LIBRARY=APFMTLIB CNTLIN=WORK._EG_CFMT;
RUN;

/* --------------------------------------------------------------------
   Now that the new SAS format has been created, we want to tidy up by
   deleting the WORK data set
   -------------------------------------------------------------------- */
PROC SQL;
    DROP TABLE WORK._EG_CFMT;
QUIT;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Create Format from Data Set (8)   */

GOPTIONS ACCESSIBLE;
/* --------------------------------------------------------------------
   Manipulates the incoming data into the correct format for PROC
   FORMAT to use as a CNTLIN data set.
   -------------------------------------------------------------------- */
TITLE; FOOTNOTE;
DATA WORK._EG_CFMT;
    LENGTH label $ 55;
    SET WORK.GRP8 (KEEP=Sorting Grouping RENAME=(Sorting=start Grouping=label)) END=__last;
    RETAIN fmtname "dim8grp" type "N";

    end=start;

    OUTPUT;

    IF __last = 1 THEN
      DO;
        hlo = "O";
        label = "Not Specified";
        OUTPUT;
      END;
RUN;

/* --------------------------------------------------------------------
   Creates a new format based on the data values contained within the
   source data set.
   -------------------------------------------------------------------- */
PROC FORMAT LIBRARY=APFMTLIB CNTLIN=WORK._EG_CFMT;
RUN;

/* --------------------------------------------------------------------
   Now that the new SAS format has been created, we want to tidy up by
   deleting the WORK data set
   -------------------------------------------------------------------- */
PROC SQL;
    DROP TABLE WORK._EG_CFMT;
QUIT;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Create Format from Data Set (9)   */

GOPTIONS ACCESSIBLE;
/* --------------------------------------------------------------------
   Manipulates the incoming data into the correct format for PROC
   FORMAT to use as a CNTLIN data set.
   -------------------------------------------------------------------- */
TITLE; FOOTNOTE;
DATA WORK._EG_CFMT;
    LENGTH label $ 55;
    SET WORK.GRP9 (KEEP=Sorting Grouping RENAME=(Sorting=start Grouping=label)) END=__last;
    RETAIN fmtname "dim9grp" type "N";

    end=start;

    OUTPUT;

    IF __last = 1 THEN
      DO;
        hlo = "O";
        label = "Not Specified";
        OUTPUT;
      END;
RUN;

/* --------------------------------------------------------------------
   Creates a new format based on the data values contained within the
   source data set.
   -------------------------------------------------------------------- */
PROC FORMAT LIBRARY=APFMTLIB CNTLIN=WORK._EG_CFMT;
RUN;

/* --------------------------------------------------------------------
   Now that the new SAS format has been created, we want to tidy up by
   deleting the WORK data set
   -------------------------------------------------------------------- */
PROC SQL;
    DROP TABLE WORK._EG_CFMT;
QUIT;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Create Format from Data Set (10)   */

GOPTIONS ACCESSIBLE;
/* --------------------------------------------------------------------
   Manipulates the incoming data into the correct format for PROC
   FORMAT to use as a CNTLIN data set.
   -------------------------------------------------------------------- */
TITLE; FOOTNOTE;
DATA WORK._EG_CFMT;
    LENGTH label $ 55;
    SET WORK.GRP10 (KEEP=Sorting Grouping RENAME=(Sorting=start Grouping=label)) END=__last;
    RETAIN fmtname "dim10grp" type "N";

    end=start;

    OUTPUT;

    IF __last = 1 THEN
      DO;
        hlo = "O";
        label = "Not Specified";
        OUTPUT;
      END;
RUN;

/* --------------------------------------------------------------------
   Creates a new format based on the data values contained within the
   source data set.
   -------------------------------------------------------------------- */
PROC FORMAT LIBRARY=APFMTLIB CNTLIN=WORK._EG_CFMT;
RUN;

/* --------------------------------------------------------------------
   Now that the new SAS format has been created, we want to tidy up by
   deleting the WORK data set
   -------------------------------------------------------------------- */
PROC SQL;
    DROP TABLE WORK._EG_CFMT;
QUIT;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Create Format from Data Set (11)   */

GOPTIONS ACCESSIBLE;
/* --------------------------------------------------------------------
   Manipulates the incoming data into the correct format for PROC
   FORMAT to use as a CNTLIN data set.
   -------------------------------------------------------------------- */
TITLE; FOOTNOTE;
DATA WORK._EG_CFMT;
    LENGTH label $ 55;
    SET WORK.GRP11 (KEEP=Sorting Grouping RENAME=(Sorting=start Grouping=label)) END=__last;
    RETAIN fmtname "dim11grp" type "N";

    end=start;

    OUTPUT;

    IF __last = 1 THEN
      DO;
        hlo = "O";
        label = "Not Specified";
        OUTPUT;
      END;
RUN;

/* --------------------------------------------------------------------
   Creates a new format based on the data values contained within the
   source data set.
   -------------------------------------------------------------------- */
PROC FORMAT LIBRARY=APFMTLIB CNTLIN=WORK._EG_CFMT;
RUN;

/* --------------------------------------------------------------------
   Now that the new SAS format has been created, we want to tidy up by
   deleting the WORK data set
   -------------------------------------------------------------------- */
PROC SQL;
    DROP TABLE WORK._EG_CFMT;
QUIT;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;


/*   START OF NODE: Create Format from Data Set (12)   */

GOPTIONS ACCESSIBLE;
/* --------------------------------------------------------------------
   Manipulates the incoming data into the correct format for PROC
   FORMAT to use as a CNTLIN data set.
   -------------------------------------------------------------------- */
TITLE; FOOTNOTE;
DATA WORK._EG_CFMT;
    LENGTH label $ 55;
    SET WORK.GRP12 (KEEP=Sorting Grouping RENAME=(Sorting=start Grouping=label)) END=__last;
    RETAIN fmtname "dim12grp" type "N";

    end=start;

    OUTPUT;

    IF __last = 1 THEN
      DO;
        hlo = "O";
        label = "Not Specified";
        OUTPUT;
      END;
RUN;

/* --------------------------------------------------------------------
   Creates a new format based on the data values contained within the
   source data set.
   -------------------------------------------------------------------- */
PROC FORMAT LIBRARY=APFMTLIB CNTLIN=WORK._EG_CFMT;
RUN;

/* --------------------------------------------------------------------
   Now that the new SAS format has been created, we want to tidy up by
   deleting the WORK data set
   -------------------------------------------------------------------- */
PROC SQL;
    DROP TABLE WORK._EG_CFMT;
QUIT;


GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;

;*';*";*/;quit;run;
ODS _ALL_ CLOSE;
