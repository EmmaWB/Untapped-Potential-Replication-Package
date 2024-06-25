/*

File: 03 - Clean Mouse Movement Data
								
Authors: 		Erin Macke, Claire Daviss, and Emma Williams Baron (equal authorship)
Date:			June 25, 2024
Project: 		Study 2 in "Untapped Potential: Designed Digital Trace Data in Online Survey Experiments"
Description: 	This file cleans mouse data downloaded from the DTP Resume website 
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
log using "$do/log/03_clean_mouse_data.log", replace

* Clearing environment
clear all



********************************************************************************
* Load data                                                                    *
********************************************************************************

* Import CSV storing mouse movement data
import delimited code time x y candidate ///
	using "$data/rawdata/mouse_data.csv", clear
		
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
* Merging with section status dataset                                          *
********************************************************************************

	/* Note: Here we merge the mouse data with a dataset that notes the
	section status, that is which section was open at the time of each mouse
	movement. This dataset is created in the prior do-file (02_clean_activity_data.do). */

* Merging file
merge m:1 code candidate using "$data/section_status_wide.dta"
tab code if _merge==2 // activity data, but no mouse data (wind78 is error)
drop if _merge==2 
tab code candidate if _merge==1

	/* Note: _merge==1 means that there is mouse data but no activity data -- 
	meaning, they entered the website but never opened a section. This could be 
	an error, or could reflect an actual way that a few respondents interacted
	with the resume. We thus keep these data. */

* Changing time variable to time format
gen double dt = clock(time, "M D Y hms")
format dt %tc
drop time
rename dt time

* Generating section status variable
sort code candidate time
gen section=1, after(candidate) // default is "start" section
label val section section_lbl
foreach i of numlist 1/26 { // 26 is the maximum number of section start/end 
* times in this dataset
	qui replace section=section`i' if time>=section_start`i'
}
	/* Note: Here we create one "section" variable that indicates the section
	that was open at the time of each mouse movement. */
	
* Keeping only current section status
drop section1-_merge



********************************************************************************
* Cleaning mouse data across section statuses                                  *
********************************************************************************

* Cleaning X coordinates
histogram x
keep if x <= 600	
/* Note: The code was setup to collect mouse track movements within an x range
from 0 to 600. Mouse track movements that appear outside of that region
are apparent errors and uninterpretable. */

* Cleaning Y coordinates															
histogram y if x != .
sum y
/* Y starts at the top of the page (so 0 means higher on the page, 1000 means 
	lowest on the page). Additionally, due to a calibration error, y values were 
	recorded 40 pixels below where they should correspond on the image. We discovered these
	errors in matching (x,y) scatter plots to images, a good check for validity.
	To correct these errors, we flip the scale and implement a vertical 
	transformation. We then keep only observations that would appear in the 
	appropriate range (0 to 1000 in the adjusted scale). */
gen rev_y = (y*-1) + r(max) - 40
keep if rev_y >= 0 & rev_y <= 1000

graph twoway scatter rev_y x if section == 3, ///
	mcolor(%5) msize(tiny) xsize(6) ysize(10) ///
	xti("") yti("") ylab(0(20)1000, angle(0) labsize(tiny)) ///
	xlab(0(20)600, grid labsize(tiny))

* Creating cells for analysis
gen x_tc = x
replace x_tc = 599 if x == 600 // include 600 in 599 x coordinates
gen x_cell = floor(x_tc/50)

gen y_tc = rev_y
replace y_tc = 999 if rev_y == 1000 // include 1000 in 999 y coordinates
gen y_cell = floor(y_tc/50)

sum *_cell // value corresponds to top left coordinate for cell

* Sum of mouse tracks per cell
bysort code candidate section x_cell y_cell: gen mousecount = _N



********************************************************************************
* Save datasets                                                                *
********************************************************************************

* Saving long data: each observation is a mouse track
save "$data/mouse_data_long.dta", replace
export delimited using "$data/mouse_data_long.csv", replace

* Creating wider data: each observation is a code*candidate*section combination
foreach x of numlist 0/11 {
	foreach y of numlist 0/19 {
		qui gen x`x'y`y' = mousecount if x_cell == `x' & y_cell == `y'
		qui replace x`x'y`y' = 0 if x`x'y`y' == .
		qui bysort code candidate section: ereplace x`x'y`y' = total(x`x'y`y')
	}
}
keep code candidate section x0y0-x11y19
duplicates drop

*** Sort by code and candidate before saving
sort code candidate
save "$data/mouse_data_wide.dta", replace
export delimited using "$data/mouse_data_wide.csv", replace

* Log close --------------------------------------------------------------------
log close
