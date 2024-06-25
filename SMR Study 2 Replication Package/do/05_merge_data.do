/*

File: 05 - Merge Survey and Resume Data
								
Authors: 		Erin Macke, Claire Daviss, and Emma Williams Baron (equal authorship)
Date:			June 25, 2024
Project: 		Study 2 in "Untapped Potential: Designed Digital Trace Data in Online Survey Experiments"
Description:	This file merges the cleaned Qualtrics survey data and resume
					data, creating complete wide and long dataset files.

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
log using "$do/log/05_merge_data.log", replace



********************************************************************************
* Creating merged wide dataset                                                 *
********************************************************************************

* Loading survey wide dataset
use "$data/survey_data_wide.dta", clear

*** Merging survey data with resume data 
merge 1:1 code using "$data/resume_data_wide.dta"
drop if _merge==2 
	// DTP Resume codes not matched to survey data
	/* Note: These resume codes are ones that we generated while we were
	testing the survey. We thus are comfortable dropping them. */
tab _merge if gc==1 // Note: 614/618 respondents (99%) had matched codes.
drop if _merge==1 
	/* Codes that were not entered accurately by respondents, 
	meaning we cannot link them to their digital trace data, and cannot include them in analyses/ */
drop _merge

* Filling in some missing data
	/* Note: Some participants have missing resume data for Candidate B. This
	is likely because they did not actually enter the Candidate B page, so
	the DTP resume website did not record their data. We will fill in the 
	missing data, based on the values available for Candidate A. */
replace woman3 = woman2 if woman3==. // same gender
replace parent3 = 0 if parent2 == 1 // opposite parental status
replace parent3 = 1 if parent2 == 0 // opposite parental status

* Fixing variable labels
foreach i of numlist 2/3 {
	label var woman`i' "Candidate `i' Gender"
	label var parent`i' "Candidate `i' Parental Status"
}

* Saving wide file
save "$data/merged_data_wide.dta", replace	
	
*** Reshape long to get candidate-level observations in preparation for merging with mouse data
reshape long woman parent, i(code) j(candidate)

*** Sort by code and candidate
sort code candidate

*** Merge with mouse activity data
merge 1:m code candidate using "$data/mouse_data_wide.dta"
drop if _merge == 2
	/* _merge = 2 indicates mouse movement data for observations we are excluding from analyses
	including testing the site ourselves and respondents who did not properly enter the linking code. */
drop if _merge == 1
	/* _merge = 1 indicates candidates with no mouse movement data, likely because
	the respondent did not open the second resume site (only 42 observations) */

*** Identify analytic sample
gen analytic_sample = 1
replace analytic_sample = 0 if gc != 1 // completed survey (every obs is a gc due to prior do-files, including here for transparency of criteria)
replace analytic_sample = 0 if accountable == . | woman == . // assigned to treatment/control for both experimental manipulations
replace analytic_sample = 0 if code == "" // good code; again including for transparency but every obs has a good code
replace analytic_sample = 0 if code == "chicken20" // technical error where respondent saw a woman and a man rather than just one gender
replace analytic_sample = 0 if code == "boat55" | ///
	code == "boat70" | ///
	code == "cake18" | ///
	code == "carrot95" | ///
	code == "chicken20" | ///
	code == "coffee29" | ///
	code == "eat73" | ///
	code == "fall64" | ///
	code == "lake62" | ///
	code == "park4" | ///
	code == "salad73" | ///
	code == "street83" | ///
	code == "swim81" | ///
	code == "thunder48"
	/* the codes dropped manually above are for a handful of respondents who did not answer
		all survey questions who were not already excluded by prior criteria */

* Keep the analytic sample and save dataset for analysis in next do-file
keep if analytic_sample == 1
	
save "$data/analytic_sample.dta", replace

log close
	
