/*

File: 06 - Analyze Mouse Data
								
Authors: 		Erin Macke, Claire Daviss, and Emma Williams Baron (equal authorship)
Date:			June 25, 2024
Project: 		Study 2 in "Untapped Potential: Designed Digital Trace Data in Online Survey Experiments"
Description:	This file run analyses of the mouse data.


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
log using "$do/log/06_analyze_mouse_data.log", replace



********************************************************************************
* Load data for analysis                                                       *
********************************************************************************

use "$data/analytic_sample.dta", clear



********************************************************************************
* Analysis                                                                     *
********************************************************************************

* Regressing parent on mousecount in each cell in each section

* Men, start section
* Creating matrix
* Rows: 240 cells; Columns: x cell, y cell, B, SE, p, N
matrix men_start = J(240, 6, .)
matrix colnames men_start = x y b se p n
local row = 0
foreach x of numlist 0/11 {
	foreach y of numlist 0/19 {
		di "x = `x', y = `y'"
		qui { 
			reg x`x'y`y' i.parent if section == 1 & woman == 0
			matrix reg_output = r(table)
			
			local row = `row' + 1
			matrix men_start[`row',1] = `x'
			matrix men_start[`row',2] = `y'
			matrix men_start[`row',3] = reg_output[1,2] // B
			matrix men_start[`row',4] = reg_output[2,2] // SE
			matrix men_start[`row',5] = reg_output[4,2] // p
			matrix men_start[`row',6] = e(N) // N
		}
	}
}

* Women, start section
* Creating matrix
* Rows: 240 cells; Columns: x cell, y cell, B, SE, p, N
matrix women_start = J(240, 6, .)
matrix colnames women_start = x y b se p n
local row = 0
foreach x of numlist 0/11 {
	foreach y of numlist 0/19 {
		di "x = `x', y = `y'"
		qui { 
			reg x`x'y`y' i.parent if section == 1 & woman == 1
			matrix reg_output = r(table)
			
			local row = `row' + 1
			matrix women_start[`row',1] = `x'
			matrix women_start[`row',2] = `y'
			matrix women_start[`row',3] = reg_output[1,2] // B
			matrix women_start[`row',4] = reg_output[2,2] // SE
			matrix women_start[`row',5] = reg_output[4,2] // p
			matrix women_start[`row',6] = e(N) // N
		}
	}
}

* Men, education section
* Creating matrix
* Rows: 240 cells; Columns: x cell, y cell, B, SE, p, N
matrix men_ed = J(240, 6, .)
matrix colnames men_ed = x y b se p n
local row = 0
foreach x of numlist 0/11 {
	foreach y of numlist 0/19 {
		di "x = `x', y = `y'"
		qui { 
			reg x`x'y`y' i.parent if section == 2 & woman == 0
			matrix reg_output = r(table)
			
			local row = `row' + 1
			matrix men_ed[`row',1] = `x'
			matrix men_ed[`row',2] = `y'
			matrix men_ed[`row',3] = reg_output[1,2] // B
			matrix men_ed[`row',4] = reg_output[2,2] // SE
			matrix men_ed[`row',5] = reg_output[4,2] // p
			matrix men_ed[`row',6] = e(N) // N
		}
	}
}

* Women, education section
* Creating matrix
* Rows: 240 cells; Columns: x cell, y cell, B, SE, p, N
matrix women_ed = J(240, 6, .)
matrix colnames women_ed = x y b se p n
local row = 0
foreach x of numlist 0/11 {
	foreach y of numlist 0/19 {
		di "x = `x', y = `y'"
		qui { 
			reg x`x'y`y' i.parent if section == 2 & woman == 1
			matrix reg_output = r(table)
			
			local row = `row' + 1
			matrix women_ed[`row',1] = `x'
			matrix women_ed[`row',2] = `y'
			matrix women_ed[`row',3] = reg_output[1,2] // B
			matrix women_ed[`row',4] = reg_output[2,2] // SE
			matrix women_ed[`row',5] = reg_output[4,2] // p
			matrix women_ed[`row',6] = e(N) // N
		}
	}
}

* Men, work section
* Creating matrix
* Rows: 240 cells; Columns: x cell, y cell, B, SE, p, N
matrix men_work = J(240, 6, .)
matrix colnames men_work = x y b se p n
local row = 0
foreach x of numlist 0/11 {
	foreach y of numlist 0/19 {
		di "x = `x', y = `y'"
		qui { 
			reg x`x'y`y' i.parent if section == 3 & woman == 0
			matrix reg_output = r(table)
			
			local row = `row' + 1
			matrix men_work[`row',1] = `x'
			matrix men_work[`row',2] = `y'
			matrix men_work[`row',3] = reg_output[1,2] // B
			matrix men_work[`row',4] = reg_output[2,2] // SE
			matrix men_work[`row',5] = reg_output[4,2] // p
			matrix men_work[`row',6] = e(N) // N
		}
	}
}

* Women, work section
* Creating matrix
* Rows: 240 cells; Columns: x cell, y cell, B, SE, p, N
matrix women_work = J(240, 6, .)
matrix colnames women_work = x y b se p n
local row = 0
foreach x of numlist 0/11 {
	foreach y of numlist 0/19 {
		di "x = `x', y = `y'"
		qui { 
			reg x`x'y`y' i.parent if section == 3 & woman == 1
			matrix reg_output = r(table)
			
			local row = `row' + 1
			matrix women_work[`row',1] = `x'
			matrix women_work[`row',2] = `y'
			matrix women_work[`row',3] = reg_output[1,2] // B
			matrix women_work[`row',4] = reg_output[2,2] // SE
			matrix women_work[`row',5] = reg_output[4,2] // p
			matrix women_work[`row',6] = e(N) // N
		}
	}
}

* Men, misc section
* Creating matrix
* Rows: 240 cells; Columns: x cell, y cell, B, SE, p, N
matrix men_misc = J(240, 6, .)
matrix colnames men_misc = x y b se p n
local row = 0
foreach x of numlist 0/11 {
	foreach y of numlist 0/19 {
		di "x = `x', y = `y'"
		qui { 
			reg x`x'y`y' i.parent if section == 4 & woman == 0
			matrix reg_output = r(table)
			
			local row = `row' + 1
			matrix men_misc[`row',1] = `x'
			matrix men_misc[`row',2] = `y'
			matrix men_misc[`row',3] = reg_output[1,2] // B
			matrix men_misc[`row',4] = reg_output[2,2] // SE
			matrix men_misc[`row',5] = reg_output[4,2] // p
			matrix men_misc[`row',6] = e(N) // N
		}
	}
}

* Women, misc section
* Creating matrix
* Rows: 240 cells; Columns: x cell, y cell, B, SE, p, N
matrix women_misc = J(240, 6, .)
matrix colnames women_misc = x y b se p n
local row = 0
foreach x of numlist 0/11 {
	foreach y of numlist 0/19 {
		di "x = `x', y = `y'"
		qui { 
			reg x`x'y`y' i.parent if section == 4 & woman == 1
			matrix reg_output = r(table)
			
			local row = `row' + 1
			matrix women_misc[`row',1] = `x'
			matrix women_misc[`row',2] = `y'
			matrix women_misc[`row',3] = reg_output[1,2] // B
			matrix women_misc[`row',4] = reg_output[2,2] // SE
			matrix women_misc[`row',5] = reg_output[4,2] // p
			matrix women_misc[`row',6] = e(N) // N
		}
	}
}


********************************************************************************
* Save and output matrices                                                     *
********************************************************************************

global groups "men_start women_start men_ed women_ed men_work women_work men_misc women_misc"
foreach g of global groups {
	svmat `g', names(col)
	gen p_star = "*" if p<.05
	preserve
		keep x-p_star
		drop if x==.
		export delimited using "$output/`g'_mousecount_gaps_by_parent.csv", ///
			replace
	restore
	drop x-p_star
}

log close
