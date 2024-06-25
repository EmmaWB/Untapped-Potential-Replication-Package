/*

File: 02 - Clean Digital Trace Activity Data
								
Authors: 		Erin Macke, Claire Daviss, and Emma Williams Baron (equal authorship)
Date:			June 25, 2024
Project: 		Study 2 in "Untapped Potential: Designed Digital Trace Data in Online Survey Experiments"
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
	
* Removing any odd characters from code
charlist code
return list
display r(ascii)
foreach i of numlist 123/195 {
replace code = subinstr(code, "`=char(`i')'", "", .)
}
replace code = subinstr(code, char(34), "", .) // removes quotation marks
	
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
* Generating section status variables                                          *
********************************************************************************

* Which section is open
gen section=.
cap label drop section_lbl
label def section_lbl 1 "Start" 2 "Education Open" 3 "Work Open" 4 "Misc Open"
label val section section_lbl

* Setting sections open according to "opened" buttons
replace section=1 if activity=="entered website"
replace section=2 if activity=="opened education section"
replace section=3 if activity=="opened work section"
replace section=4 if activity=="opened misc section"

* If respondent "closes" a section, returns to "start"
replace section=1 if activity=="closed education section" | ///
	activity=="closed work section" | activity=="closed misc section"
	
* Generating temporary variable to flag section activities
gen section_tag=section!=.

* Creating variable: time of first/last activity
gen double timestamp = clock(time, "MDY hms")
bysort code candidate: egen double mintime = min(timestamp)
bysort code candidate: egen double maxtime = max(timestamp)
format timestamp mintime maxtime %tc

* Section open start times
gen double section_start=clock(time, "MDY hms") if section!=.
format section_start %tc

* Section close end times
sort code candidate section_tag timestamp
gen double section_end = section_start[_n+1] if code==code[_n+1] & ///
	candidate==candidate[_n+1] & section_tag==1
format section_end %tc
replace section_end=maxtime if section_end==. & section_tag==1

* Section total time
gen sectiontime = seconds(section_end - section_start)

	
********************************************************************************
* Applying labels                                                              *
********************************************************************************

label var code 				"Website Code"
label var activity 			"Activity Description"
label var candidate 		"Candidate Number"
label var section			"Section Open"

* Creating subset of full dataset, with just section start times ---------------

* Subsetting data
preserve
keep if section_tag==1
keep code candidate section section_start
sort code candidate section_start section

* Tagging the first section button
bysort code candidate (section_start section): gen sn = _n
gen flag = sn==2 & section==1 // the second section logically cannot be "start"
tab flag
drop if sn==1 & section==1 // drop all "start" activities; assume start before first section is open.
drop if sn==2 & section==1 // drop if second section is "start", logical fallacy
drop sn flag

* Reshaping wide
bysort code candidate: gen section_n = _n
sum section_n // check the max
reshape wide section section_start, i(code candidate) j(section_n)

tab section1 // no "start" section1

* Saving file
save "$data/section_status_wide.dta", replace

	
log close
