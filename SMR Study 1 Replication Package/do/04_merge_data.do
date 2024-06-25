/*

File: 04 - Merge Survey, Resume, and Digital Trace Data, and Reshape for Analysis
								
Authors: 		Erin Macke, Claire Daviss, and Emma Williams Baron (equal authorship)
Date:			June 25, 2024
Project: 		Study 1 in "Untapped Potential: Designed Digital Trace Data in Online Survey Experiments"
Description: 	This file merges the cleaned datasets created in prior do-files, 
					identifies the analytic sample, and reshapes the data for analysis.
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
log using "$do/log/04_merge_data.log", replace

* Clearing environment
clear all

********************************************************************************
* Merge Qualtrics, Prolific, and Resume data                                   *
********************************************************************************

* Load survey data
use "$data/survey_data_wide.dta", clear

* Merging Prolific data from pretest study
merge 1:1 prolific_pid using "$data/prolific_pretest_pid.dta"

* Remove Prolific PIDs with no Qualtrics data (i.e., participated in pretest but not main survey)
drop if _merge==2
duplicates tag code, gen(code_dup)
drop if code_dup > 0 & gc != 1 // droppping duplicates who did not complete survey
drop code_dup

* Creating variable indicating pretest participation
gen pretest = _merge==3
label var pretest "Respondent Participated in Pretest"
label def pretestlbl 0 "Did not participate in pretest" ///
	1 "Participated in pretest"
label val pretest pretestlbl
drop _merge

* Merge main Prolifific data
merge 1:1 prolific_pid using "$data/prolific_data.dta" // note those who do not merge did not finish the survey 
drop _merge
duplicates tag code, gen(code_dup)
drop if code_dup > 0 & gc != 1 // droppping duplicates who did not complete survey
drop code_dup

* Merge resume data
merge 1:1 code using "$data/resume_data_wide.dta"
recode _merge (1 = 1 "Entered code incorrectly"), gen(badcode)
drop _merge

* Merge digital trace data
merge 1:1 code using "$data/activity_data_wide.dta"
drop _merge



********************************************************************************
* Identify analytic sample                                                     *
********************************************************************************
gen analytic_sample = 1
replace analytic_sample = 0 if gc != 1 // completed survey
replace analytic_sample = 0 if prolific_status != 1 // paid for survey (indicates completed everything successfully)
replace analytic_sample = 0 if pretest != 0 // not in pretest
replace analytic_sample = 0 if jobtype == . // assigned to job type treatment/control 
replace analytic_sample = 0 if woman == . // assigned to gender treatment/control
replace analytic_sample = 0 if badcode == 1 // entered linking code correctly
replace analytic_sample = 0 if code == "left12" | code == "lunch56" | code == "mountain58" | code == "olive85" | code == "tea38" // 5 respondents who weren't already dropped from analytic sample who didn't answer all survey questions


keep if analytic_sample == 1 // keep only the observations in the analytic sample
keep id code prolific_pid jobtype woman man parent2 parent3 tottime2 tottime3 // keep only the variables used in analysis

* Save the final wide (respondent-level) dataset
save "$data/analysis_data_wide.dta", replace



********************************************************************************
* Reshape the data for analysis                                                *
* This takes the data from wide, which is at the survey respondent level, to   *
*	long, which is at the job candidate level and which is used in analyses.   *
********************************************************************************

* Load the wide data
use "$data/analysis_data_wide.dta", clear

* Reshape long
reshape long parent tottime, i(id) j(candidate)

* Generate tottime deciles variable
xtile tottime_deciles = tottime, nq(10)	
label var tottime_deciles	"Total Time Spent on Resume in Deciles"


* Save the long (candidate-level) dataset
save "$data/analysis_data_long.dta", replace

log close
	
