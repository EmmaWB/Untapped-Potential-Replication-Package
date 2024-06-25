/*

File: 01 - Clean Resume Data
								
Authors: 		Erin Macke, Claire Daviss, and Emma Williams Baron (equal authorship)
Date:			June 25, 2024
Project: 		Study 2 in "Untapped Potential: Designed Digital Trace Data in Online Survey Experiments"
Description: 	This file takes resume data downloaded from the DTP Resume website 
					and creates a file to be merged with Qualtrics survey data.

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
log using "$do/log/01_clean_resume_data.log", replace

* Clearing environment
clear all



********************************************************************************
* Load data                                                                    *
********************************************************************************

* Import CSV storing resume data
import delimited code temp_gender_string temp_parent_string candidate ///
	using "$data/rawdata/resume_data.csv", clear
	
* Removing any odd characters from code (code is a unique user ID that was generated by the interactive digital resumes)
ssc install charlist
charlist code
return list
display r(ascii)
foreach i of numlist 123/195 { // nonstandard characters
	replace code = subinstr(code, "`=char(`i')'", "", .)
}
replace code = subinstr(code, char(34), "", .) // removes quotation marks


	
********************************************************************************
* Labeling variables & values                                                  *
********************************************************************************

* Encode the string variables so we can use them as numbers in analyses
foreach field in gender parent {
	encode temp_`field'_string, gen(temp_`field')
	drop temp_`field'_string
}

* Code the values to 0/1 rather than 1/2 and set the value labels
recode temp_gender 	(1 = 0 "Man") /// 
					(2 = 1 "Woman"), gen(woman)
recode temp_parent	(1 = 0 "Non-parent") ///
					(2 = 1 "Parent"), gen(parent)

* Drop the old versions of the variables now that we don't need them
drop temp*

* Replacing resume candidate number to match Qualtrics data. Candidate A = 2, Candidate B = 3. 
replace candidate = candidate + 1

* Label the variables
label var woman "Resume Gender"
label var parent "Resume Parental Status"
label var candidate "Candidate Number"



********************************************************************************
* Save long dataset                                                            *
********************************************************************************

* Save in .dta
save "$data/resume_data_long.dta", replace

* Generate long dataset as CSV file (for R)
export delimited using "$data/resume_data_long.csv", replace



********************************************************************************
* Reshaping to wide and saving dataset                                         *
********************************************************************************

/* 
Here we reshape the dataset so that each observation is a survey participant, 
uniquely identified by "code," with variables corresponding to the two 
candidates they viewed.
*/
reshape wide woman parent, i(code) j(candidate)
	
* Save dataset for merging with other datasets
save "$data/resume_data_wide.dta", replace

log close