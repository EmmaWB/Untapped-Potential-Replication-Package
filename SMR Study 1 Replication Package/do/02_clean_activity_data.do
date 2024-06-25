/*

File: 02 - Clean Digital Trace Activity Data
								
Authors: 		Erin Macke, Claire Daviss, and Emma Williams Baron (equal authorship)
Date:			June 25, 2024
Project: 		Study 1 in "Untapped Potential: Designed Digital Trace Data in Online Survey Experiments"
Description:	This file takes activity data downloaded from the interactive digital resume
					website and creates a file to be merged with Qualtrics survey data.

*/



********************************************************************************
* Preparing environment                                                        *
********************************************************************************

* Setting filepath globals
global wd "UPDATE HERE WITH YOUR WORKING DIRECTORY FILEPATH"		// update with your own working directory filepath here
global do "$wd/do"
global data "$wd/data"
global output "$wd/output"
set scheme s2mono

* Setting log
cap log close
log using "$do/log/02_clean_activity_data.log", replace

* Clearing environment
clear all



********************************************************************************
* Load data                                                                    *
********************************************************************************

* Import CSV storing activity data
import delimited code time activity candidate ///
	using "$data/rawdata/activity_data.csv", clear
	
* Removing any odd characters from code (code is equivalent to unique user ID)
ssc install charlist
charlist code
return list
display r(ascii)
foreach i of numlist 123/195 {
	replace code = subinstr(code, "`=char(`i')'", "", .)
}
replace code = subinstr(code, char(34), "", .) // removes quotation marks

* Replacing resume candidate number with 2 or 3
* Note: this is necessary to merge with Qualtrics data. Candidate A = 2, Candidate B = 3. 
replace candidate = candidate + 1

	
	
********************************************************************************
* Create timing variables                                                      *
********************************************************************************

* Creating variables: time of first and last activities
gen double timestamp = clock(time, "MDY hms")
bysort code candidate: egen double mintime = min(timestamp)
bysort code candidate: egen double maxtime = max(timestamp)
format timestamp mintime maxtime %tc

* Creating variable: total time spent on resume in deciles
gen tottime = seconds(maxtime - mintime)


	
********************************************************************************
* Applying variable labels                                                     *
********************************************************************************

label var code 				"Website Code"
label var time 				"Activity Time"
label var activity 			"Activity Description"
label var candidate			"Candidate/Resume Number"
label var timestamp			"Activity Timestamp"
label var mintime			"Earliest Activity Timestamp"
label var maxtime			"Latest Activity Timestamp"
label var tottime			"Total Time Spent on Resume in Seconds"


********************************************************************************
* Paring down, reshaping, and saving data                                      *
********************************************************************************

* Keeping only the variables needed for next stages
keep code candidate tottime

* Deleting duplicates
/* Note: there are duplicate observations because each row is an activity/digital 
	trace, but we need only one measure per survey participant: total time on the resume in deciles.
*/
duplicates drop

/* 
Here we reshape the dataset so that each observation is a survey participant, 
uniquely identified by "code," with variables corresponding to the two candidates they viewed.
*/
reshape wide tottime, i(code) j(candidate)
	
* Save dataset for merging with other datasets in later do-files
save "$data/activity_data_wide.dta", replace

log close


