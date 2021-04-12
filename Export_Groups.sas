
/* this macro creates an export file ready for using with the CLI command */

/* sas-admin transfer export --request @/tmp/exportgroups.json */

/* {
"Version":1,
"name":"&packagename",
"description":"&packagedescription",
"items":[
"/identities/groups/SASAdministrators"
,
"/identities/groups/EsriUsers"
,
"/identities/groups/DataBuilders"
,
"/identities/groups/ApplicationAdministrators"
,
"/identities/groups/SASScoreUsers"
,
"/identities/groups/Content creators"
,
"/identities/groups/All_Windows_RO"
,
"/identities/groups/EInvoice"
,
"/identities/groups/All_Windows"
,
"/identities/groups/Change_Password"
,
"/identities/groups/Portal_Administrator"
,
"/identities/groups/Notifications_WSC"
,
"/identities/groups/group2"
,
"/identities/groups/group1"
]
}
*/



%macro exportGroups(server=, exportfile=, username=, password=); 
  
  filename response TEMP encoding='UTF-8';
  proc http url="&server/identities/groups?limit=10000" OAUTH_BEARER=SAS_SERVICES
    username="&username"
    password="&password"
    out=response;
    headers "Accept"="application/json";
  run;
  
  libname response json;
  libname out (work);
  proc sql;
     create table out.groups as
     select * from response.items
     where providerid='local';
  quit;
     
  filename export "&exportfile";
  data _null_;
    file export;
    set out.groups end=end;
    if _n_=1 then do;
    put '{';
    put '"Version":1,';
    put '"name":"&packagename",';
    put '"description":"&packagedescription",';
    put '"items":[';
    end;
    put '"/identities/groups/' id +(-1) '"';
    if not end then put ',';
    if end then do;
    put ']';
    put '}';
    end;
 run;
   
%mend exportGroups;
  
  
%exportGroups(server=https://ocsnl-viya1.internal.ocs-consulting.com,
 			  exportfile=/tmp/exportgroups.json,
 			  username=rp1,
 			  password=The year is 2021);  


