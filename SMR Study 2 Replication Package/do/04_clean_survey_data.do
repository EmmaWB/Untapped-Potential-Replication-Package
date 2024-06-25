/*

File: 04 - Clean Survey Data
								
Authors: 		Erin Macke, Claire Daviss, and Emma Williams Baron (equal authorship)
Date:			June 25, 2024
Project: 		Study 2 in "Untapped Potential: Designed Digital Trace Data in Online Survey Experiments"
Description:	This file cleans the survey data from Qualtrics, reshapes it 
					wide, and merges it with the resume data.

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
log using "$do/log/04_clean_survey_data.log", replace

* Clearing environment
clear all



********************************************************************************
* Load data and create respondent-level dataset                                 *
********************************************************************************

* Import Qualtrics data from excel sheet
import excel "$data/rawdata/survey_data.xlsx", firstrow clear

* Respondent is a "good complete" (completed survey)
destring gc, replace
label var gc "Respondent Completed Survey"
label def gc_lbl 1 "Completed Survey"
label val gc gc_lbl

* Encoding accountability labels
rename sd accountable	
label var accountable "Accountability Condition"
label define accountable_l 0 "Control" 1 "Accountability treatment"
label val accountable accountable_l
		
* Relabeling gender condition variable
rename condition man
label var man "Candidate Gender Condition"
label def man_lbl 0 "Woman Candidates" 1 "Man Candidates"
label val man man_lbl
order man, after(accountable)

* Unique website code for each respondent
gen str temp_code=""
replace temp_code = code_woman if man == 0
replace temp_code = code_man if man == 1
	
* Removing capitalization & spaces in code
gen code = lower(temp_code)
replace code = subinstr(code, " ", "", .)
label var code "Real Code Entry"
	/* Note: This is the code the respondent enters while they are looking at
	Candidate A's resume. It is a unique code, produced via the DTP Resume
	website, and contains a common word and a number between 1 and 99. 
	It's important for this variable to be named "code", as it will be used
	to merge with the resume and activity data. */

* Keep only necessary variables
keep code gc accountable	

* Keep only those who completed the survey and entered a linking code
keep if gc == 1 & code != ""
	
* Saving respondent-level dataset
save "$data/survey_data_wide.dta", replace

log close
	
