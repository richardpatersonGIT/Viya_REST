
options symbolgen;

%macro exportCaslibs(server=, exportdirectory=, username=, password=); 

	filename resp TEMP encoding='UTF-8';

	proc http method="GET" url="&server/casManagement/servers/cas-shared-default/caslibs" oauth_bearer=SAS_SERVICES
		username="&username" password="&password" out=resp; debug level=1;
		headers "Accept"="application/vnd.sas.collection+json";
	run;

	libname resp json;
    libname out "&exportdirectory";
    
    proc sql;
     create table out.caslibs as
     select * from resp.items
     where name='ocs_temp3';
     
     select strip(name) as name into :caslib1-
     from resp.items
     where name='ocs_temp3';
    quit;
 
    libname resp clear;
    libname out clear;
     

    %do i=1 %to &sqlobs;

		filename resp "&exportdirectory/&&caslib&i...json" encoding='UTF-8';

		proc http method="GET" url="&server/casManagement/servers/cas-shared-default/caslibs/&&caslib&i" oauth_bearer=SAS_SERVICES
			username="&username" password="&password" out=resp; debug level=1;
			headers "Accept"="application/vnd.sas.cas.caslib+json";
		run;

	%end;
%mend exportCaslibs;
%exportCaslibs(server=https://ocsnl-viya1.internal.ocs-consulting.com,
 			   exportdirectory=/tmp,
 			   username=rp1,
 			   password=The year is 2021);


%macro importCaslibs(server=, importdirectory=, filter=, deleteifexists=N, username=, password=);
	
	libname import "&importdirectory";
	
 	filename log "&importdirectory/import.log" encoding='UTF-8' mod; 
	
	proc sql;
    	select strip(name) into :caslib1-
    	from import.caslibs
    	%if %bquote(&filter) NE %then where &filter;;
    quit;
    
    %do i=1 %to &sqlobs;
    
    	filename resp "&importdirectory/&&caslib&i...json";
    	
    	
    	proc http method="DELETE" in=resp url="&server/casManagement/servers/cas-shared-default/caslibs/&&caslib&i" oauth_bearer=SAS_SERVICES
			username="&username" password="&password" out=log; debug level=1;
			;
		run;
		
    	
		proc http method="POST" in=resp url="&server/casManagement/servers/cas-shared-default/caslibs" oauth_bearer=SAS_SERVICES
			username="&username" password="&password" out=log; debug level=1;
			headers "Accept"="application/vnd.sas.cas.caslib+json"
				"Content-Type"="application/vnd.sas.cas.caslib+json";
		run;
		
	%end;
	

%mend importcaslibs;

/* https://developer.sas.com/apis/rest/v3.5/Compute/#create-a-caslib */

%importcaslibs(server=https://ocsnl-viya1.internal.ocs-consulting.com, 
			   importdirectory=/tmp,
			   filter=%str(name='ocs_temp3'),
			   username=rp1, 
			   password=The year is 2021);





