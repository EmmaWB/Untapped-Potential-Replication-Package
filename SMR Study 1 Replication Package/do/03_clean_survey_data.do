/*

File: 03 - Clean Survey Data
								
Authors: 		Erin Macke, Claire Daviss, and Emma Williams Baron (equal authorship)
Date:			June 25, 2024
Project: 		Study 1 in "Untapped Potential: Designed Digital Trace Data in Online Survey Experiments"
Description:	This file takes Prolific data, cleans it, and prepares it to
					merge with Qualtrics data. It then takes Qualtrics survey data, cleans it, 
					reshapes it into a wide format, and merges it with the resume data.
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
log using "$do/log/03_clean_survey_data.log", replace

* Clearing environment
clear all


********************************************************************************
* Import and clean Prolific survey data                                        *
********************************************************************************

* Prolific pretest data will be used to exclude participants later                     
import delimited prolific_pid using ///
	"$data/rawdata/prolific_pretest_data.csv", clear	
save "$data/prolific_pretest_pid.dta", replace
	
*** Part 1 of main Prolific data collection
import delimited prolific_pid temp_prolific_status using ///
	"$data/rawdata/prolific_data_part1.csv", clear	
encode temp_prolific_status, gen(prolific_status)
drop temp*
sort prolific_pid
save "$data/prolific_part1.dta", replace

*** Part 2 of main Prolific data collection
import delimited prolific_pid temp_prolific_status using ///
	"$data/rawdata/prolific_data_part2.csv", clear		
encode temp_prolific_status, gen(prolific_status)
drop temp*
sort prolific_pid
save "$data/prolific_part2.dta", replace

*** Append the two parts of the main Prolific data collection
append using "$data/prolific_part1.dta"
save "$data/prolific_data.dta", replace
	
********************************************************************************
* Import and clean Qualtrics survey data                                       *
********************************************************************************

* Import Qualtrics data from excel sheet
import excel "$data/rawdata/qualtrics_data.xlsx", firstrow clear
	
* Unique respondent id
gen id = _n
label var id "Respondent Id"
order id // move to front of dataset
	
* Respondent completed survey
label var gc "Respondent Completed Survey"
label def gc_lbl 1 "Completed Survey"
label val gc gc_lbl

* Encoding job-type labels
label def jobtypelbl 1 "inperson" 2 "hybrid" 3 "remote"
encode temp_jobtype, gen(jobtype) label(jobtypelbl)
label var jobtype "Job Type"

* Cleaning gender condition variable
recode temp_condition (0 = 1 "Woman")(1 = 0 "Man"), gen(woman) // raw Qualtrics data has 1 = men so we are reverse coding here for women = 1
recode temp_condition (0 = 0 "Woman")(1 = 1 "Man"), gen(man)
label var woman "Candidate Gender Condition"

* Unique website code for each respondent
gen str temp_code=""
replace temp_code = temp_code_woman if woman == 1
replace temp_code = temp_code_man if woman == 0
	
* Removing capitalization & spaces in code
gen code = lower(temp_code)
replace code = subinstr(code, " ", "", .)
label var code "Real Code Entry"
	/* Note: This is the code the respondent enters while they are looking at
	Candidate A's resume. It is a unique code, produced via the DTP Resume
	website, and contains a common word and a number between 1 and 99. 
	It's important for this variable to be named "code", as it will be used
	to merge with the resume and activity data. */

drop temp*

* Cleaning duplicates on prolific_pid
duplicates tag prolific_pid, gen(dup)
drop if dup != 0 & gc != 1 // dropping duplicates who entered the survey multiple times but only completed it once
drop dup

* Saving the wide data: Each observation is a survey respondent. Respondent-level variables are ordered first.
save "$data/survey_data_wide.dta", replace

log close

	
