capture log close

log using "king_assignment5.log", replace

/*Assignment 5*/
/*Robb King*/
/*February 25*/

set more off

global ddir "../data/"

use ${ddir}plans.dta, clear

/*1. Create a basic model with four or five key covariates, including 
continuous, at least two categorical variables and binary variables.*/
//Covariates: byrace(categorical) bysex(binary) bystexp(binary) bypared(categorical)

foreach myvar of varlist stu_id-f1psepln{
	foreach i of numlist -4 -8 -9{
		replace `myvar'=. if `myvar'==`i'
			} //end of inner loop
		} //end of outer loop
		
//Turn bysex into a binary variable
gen female=bysex==2
replace female=. if bysex==.

label var female "Female"

//Turn bystexp into a binary variable that designates 1 as students who expect to get a degree after high school
gen earn_degree=bystexp==3
replace earn_degree=1 if bystexp==5
replace earn_degree=1 if bystexp==6
replace earn_degree=1 if bystexp==7
replace earn_degree=. if bystexp==.

label var earn_degree "Expectation to earn a degree after high school"

local y bynels2r

reg `y' i.byrace i.bypared female earn_degree

/*2. Run a model with the dependent variable specified as the log of the dv. 
In the code, interpret the coefficients from this model and briefly (1 sentence) 
discuss the differences between the results from this model and the results from the basic model.*/

gen log_y = log(`y')

reg log_y i.byrace i.bypared female earn_degree

/*3. Run a model with the continuous independent variable as a quadratic 
function. Discuss why this expansion should or should not be included.*/

gen byses1_sq = byses1^2

reg `y' i.byrace i.bypared female earn_degree byses1 byses1_sq

/*Comments: byses_sq should be included because there is probably a certain point
in ses where reading scores level off and stops increasing at the same pace we would 
potentially see with byses by itself.*/

/*4. Run a model with an interaction between the continuous independent variable 
and the binary independent variable. Using the margins command, create a plot that 
shows how the dependent variable changes as a function of these two variables.*/

eststo female_ses: reg `y' i.female##c.byses1 

sum byses1, detail
local mymin=r(min)
local mymax=r(max)

estimates restore female_ses

eststo marg1: margins, predict(xb) at(female=(1 0) (mean) byses1=(`mymin'(1)`mymax')) post

esttab marg1 using margins.rtf, margin label nostar ci ///
	varlabels(1._at "SES Q1" ///
				2._at "SES Q2" ///
				3._at "SES Q3" ///
				4._at "SES Q4" ///
				5._at "SES Q1" ///
				6._at "SES Q2" ///
				7._at "SES Q3" ///
				8._at "SES Q4") ///
	replace
				
marginsplot, recast(bar) by(female) xtitle("") 

/*5. Run a model with an interaction between two categorical variables, or a 
categorical variable and a binary variable. Create two tables, on which shows 
the coefficients, another which shows predicted levels of the dependent variable 
as a function of the independent variables.*/

eststo race_female: reg `y' female##ib(freq).byrace

esttab race_female using race_female.rtf, varwidth(50) label ///
	nobaselevels ///
	nomtitle ///
	nodepvars ///
	b(3) ///
	se(3) ///
	replace

eststo marg2: margins, predict(xb) at(byrace=(1 2 3 4 5 6 7) female=(0 1)) post

esttab marg2 using margins2.rtf, margin label nostar ci ///
	varlabels(1._at "Male, American Indian/Native" ///
				2._at "Male, Asian/Hawaiian, Pacific Islander" ///
				3._at "Male, Black or African American" ///
				4._at "Male, Hispanic, No Race" ///
				5._at "Male, Hispanic, Race" ///
				6._at "Male, Multiracial" ///
				7._at "Male, White" ///
				8._at "Female, American Indian/Native" ///
				9._at "Female, Asian/Hawaiian, Pacific Islander" ///
				10._at "Female, Black or African American" ///
				11._at "Female, Hispanic, No Race" ///
				12._at "Female, Hispanic, Race" ///
				13._at "Female, Multiracial" ///
				14._at "Female, White") ///
				replace

log close
exit





