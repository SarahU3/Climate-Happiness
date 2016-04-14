*** Clean-up for R ***
clear
use "C:\Users\meerim\Documents\GitHub\Climate-Happiness\Data\SOEP_Meerim_12.dta"
count
* 192,841 individual-years 

*** Variables of interest: 
* Current life satisfaction: plh0182
drop if plh0182==-5 | plh0182==-2 | plh0182==-1 | plh0182==.
decode plh0182, gen(satis_labels)
gen satis=.
replace satis=1 if plh0182<3
replace satis=2 if plh0182>=3 & plh0182<=5
replace satis=3 if plh0182>=6 & plh0182<9
replace satis=4 if plh0182>=9
/*label var satis "Life satisfaction (categorical)"
label def satis_l 1 "Unsatisfied" 2 "Mildly satisfied" 3 "Satisfied" 4 "Very satisfied"
label val satis satis_l
numlabel satis_l, add*/

* Concern with environment: plh0036
drop if plh0036==-2 | plh0036==-1 
gen environ=plh0036

* Residence: bula
/*There is a mistake in the labelling: https://paneldata.org/variables/189651
Change the labels accordingly the true values for Bundeslaender. */
tab bula
#delimit ;
label define bula_EN -6 "-6. [-6] questionnaire version with modified filtering" 
-5 "-5. [-5] not contained in questionnaire" 
-4 "-4. [-4] inadmissible multiple answer" 
-3 "-3. [-3] Answer improbable" -2 "-2. [-2] Does not apply" 
-1 "-1. [-1] No Answer" 1 "Schleswig-Holstein" 
2 "Hamburg" 3 "Niedersachsen" 4 "Bremen" 
5 "Nordrhein-Westfalen" 6 "Hessen" 
7 "Rhineland-Palatinate, Saarland" 8 "Baden-Württemberg" 
9 "Bayern" 10 "Saarland" 11 "Berlin" 
12 "Brandenburg" 13 "Mecklenburg-Vorpommern" 
14 "Sachsen" 15 "Sachsen-Anhalt" 
16 "Thüringen", replace;
#delimit cr
drop if bula<0
decode bula, gen (State)

* Demographic variables

* Gender: pla0009
drop if pla0009==-2
gen gender=pla0009

* Age:
tab ple0010, missing
drop if ple0010==. | ple0010==-2 | ple0010==-1
gen age=syear-ple0010

* Employment
tab plb0022 
drop if plb0022==-2 | plb0022==-1 
gen emp=.
replace emp=1 if plb0022==9
replace emp=2 if plb0022!=9
/*label var emp "Employed or not"
label def emp_l 1 "Unemployed" 2 "Employed"
label val emp emp_l
numlabel emp_l, add*/

* Marrital status
tab pld0131
drop if pld0131==-2 | pld0131==-1 
gen fam=.
replace fam=1 if pld0131==2 | pld0131==3 | pld0131==4 | pld0131==5
replace fam=2 if pld0131==1 | pld0131==6
/*label var fam "With a partner or not"
label def fam_l 1 "W/out partner" 2 "With partner"
label val fam fam_l 
numlabel fam_l, add*/


* Children too few observations, education and income - the same

* 178,279 observations

* Time frame (1990-2012)
tab syear
drop if syear<1990
gen Year=syear
* 155076 observations

* Limitting to the model 
keep pid plh0182 satis satis_labels environ plh0036 bula State gender pla0009 syear Year age ple0010 plb0022 emp pld0131 fam
* 155076 observations
sort Year State pid

xtset pid Year

save "C:\Users\meerim\Documents\GitHub\Climate-Happiness\Data\GSOEP\SOEP_short12.dta", replace


