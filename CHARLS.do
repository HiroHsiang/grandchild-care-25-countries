* CHARLS: analysis variables from H_CHARLS_D_Data.dta (Harmonized CHARLS D, waves 1-4), Family_Transfer.dta of 2013, 2015 and 2018,
* and the 2020 wave files Demographic_Background, Health_Status_and_Functioning, Individual_Income, Work_Retirement, Weights, COVID_Module

clear all
set more off
set maxvar 32767

local conds hibpe diabe dyslipe cancre lunge livere hearte stroke kidneye digeste psyche memrye arthre asthmae
local mobility chaira climsa stoopa armsa lifta dimea

tempfile resp20 person hc panel hours

* 2020 respondents: anyone present in a person-level file; outcomes and person-level items only
use ID ba001 ba002 zrbirthyear ba003_1 zredu ba010 using "$data/CHARLS/2020/Demographic_Background.dta", clear
local cesd dc016 dc017 dc018 dc019 dc020 dc021 dc022 dc023 dc024 dc025
local words ""
forvalues k = 1/10 {
    local words `words' dc012_s`k' dc028_s`k'
}
merge 1:1 ID using "$data/CHARLS/2020/Health_Status_and_Functioning.dta", nogen keepusing(da001 `words' `cesd' dc026)
foreach f in Individual_Income Work_Retirement Weights COVID_Module {
    merge 1:1 ID using "$data/CHARLS/2020/`f'.dta", nogen keepusing(ID)
}

replace zrbirthyear = ba003_1 if missing(zrbirthyear)
gen byte sex20 = cond(!missing(ba002), ba002, ba001)
gen byte edu20 = cond(!missing(zredu), zredu, ba010)

gen byte srh = 6 - da001 if inrange(da001, 1, 5)
gen byte ls = 6 - dc026 if inrange(dc026, 1, 5)
foreach v of local words {
    replace `v' = 1 if inrange(`v', 1, 10)
}
egen imm = rowtotal(dc012_s*), missing
egen del = rowtotal(dc028_s*), missing
gen recall = imm + del
local items ""
foreach v of local cesd {
    gen byte c_`v' = `v' - 1 if inrange(`v', 1, 4)
    local items `items' c_`v'
}
* positive items (hopeful, happy) reversed
replace c_dc020 = 3 - c_dc020
replace c_dc023 = 3 - c_dc023
* sum of answered items, as in the harmonised score
egen dep = rowtotal(`items'), missing

gen byte wave = 5
gen year = 2020
keep ID wave year zrbirthyear sex20 edu20 srh ls recall dep
save `resp20'

* person-level birth year, sex and education (2020 report preferred for sex and education)
use ID rabyear ragender raeduc_c using "$data/CHARLS/H_CHARLS_D_Data.dta", clear
merge 1:1 ID using `resp20', keepusing(zrbirthyear sex20 edu20) nogen
replace rabyear = zrbirthyear if missing(rabyear)
replace ragender = sex20 if !missing(sex20)
replace raeduc_c = edu20 if !missing(edu20)
gen female = ragender == 2 if !missing(ragender)
gen edulow = inrange(raeduc_c, 1, 5) if !missing(raeduc_c)
keep ID rabyear female edulow
save `person'

* Harmonized CHARLS, waves 1-4
local gv ID c2010cpindex c2011cpindex c2013cpindex c2015cpindex c2018cpindex hh1ahrto hh2ahrto hh3ahrto h4ahrto
forvalues w = 1/4 {
    local gv `gv' inw`w' s`w'id r`w'iwy r`w'mstath r`w'shlta r`w'adlab_c r`w'tr20 r`w'cesd10 r`w'satlife r`w'work ///
        h`w'hhres hh`w'itot h`w'gkcare
    foreach s in moneya medsa shopa mealsa housewka `mobility' `conds' {
        local gv `gv' r`w'`s'
    }
}
use `gv' using "$data/CHARLS/H_CHARLS_D_Data.dta", clear
save `hc'

* grandchild-care hours in the past year (waves 2-4): weeks x hours per week, summed over children;
* the family respondent's spouse is reported in the spouse columns
local ftyear 2013 2015 2018
forvalues w = 2/4 {
    local y : word `=`w'-1' of `ftyear'
    use ID cf003_* using "$data/CHARLS/`y'/Family_Transfer.dta", clear
    gen double hrs1 = 0
    gen double hrs2 = 0
    foreach v of varlist cf003_1_*_ {
        local k = substr("`v'", 9, length("`v'") - 9)
        * negative codes and impossible values (weeks > 52, hours a week > 168) treated as missing
        replace hrs1 = hrs1 + cf003_1_`k'_*cf003_2_`k'_ if inrange(cf003_1_`k'_, 0, 52) & inrange(cf003_2_`k'_, 0, 168)
        replace hrs2 = hrs2 + cf003_3_`k'_*cf003_4_`k'_ if inrange(cf003_3_`k'_, 0, 52) & inrange(cf003_4_`k'_, 0, 168)
    }
    merge 1:1 ID using `hc', keep(master match) keepusing(s`w'id) nogen
    * spouse ID: 11 characters = 2011 form, household part one digit shorter; "0" = no spouse
    gen ID2 = cond(strlen(s`w'id) == 11, substr(s`w'id, 1, 9) + "0" + substr(s`w'id, 10, 2), cond(strlen(s`w'id) == 12, s`w'id, ""))
    rename ID ID1
    gen long row = _n
    keep row ID1 ID2 hrs1 hrs2
    reshape long ID hrs, i(row) j(resp)
    drop if ID == ""
    gen byte wave = `w'
    if `w' > 2 append using `hours'
    save `hours', replace
}
* own report preferred over the spouse's report
bysort ID wave (resp): keep if _n == 1
keep ID wave hrs
save `hours', replace

local cpiyear 2011 2013 2015 2018
forvalues w = 1/4 {
    use `hc' if inw`w' == 1, clear
    local y : word `w' of `cpiyear'
    gen byte wave = `w'
    gen year = r`w'iwy
    gen recall = r`w'tr20
    gen dep = r`w'cesd10
    gen ls = r`w'satlife
    gen srh = cond(inrange(r`w'shlta, 1, 5), 6 - r`w'shlta, r`w'shlta)
    gen partnered = inlist(r`w'mstath, 1, 2, 3) if !missing(r`w'mstath)
    gen hhsize = h`w'hhres
    gen work = r`w'work
    gen float inc = hh`w'itot/c`y'cpindex*c2010cpindex
    egen iadl = rowtotal(r`w'moneya r`w'medsa r`w'shopa r`w'mealsa r`w'housewka), missing
    gen adl = r`w'adlab_c
    local clist ""
    foreach c of local conds {
        local clist `clist' r`w'`c'
    }
    egen chronic = rowtotal(`clist'), missing
    foreach m of local mobility {
        gen `m' = r`w'`m'
    }
    local ah = cond(`w' == 4, "h4ahrto", "hh`w'ahrto")
    gen care = h`w'gkcare
    * .g = no (young) grandchildren
    gen nogk = h`w'gkcare == .g
    gen own = `ah' > 0 if !missing(`ah')
    * nogk left missing when neither care nor home ownership is reported
    replace nogk = . if missing(care) & missing(own)
    keep ID wave year recall dep ls srh partnered hhsize work inc iadl adl chronic `mobility' care nogk own
    if `w' > 1 append using `panel'
    save `panel', replace
}

* care intensity: 2 = at least 780 hours (15 a week) in the past year
merge 1:1 ID wave using `hours', keep(master match) nogen
gen byte care3 = care if inlist(care, 0, 1)
replace care3 = 2 if care == 1 & hrs >= 780 & !missing(hrs)
drop hrs

append using `resp20'

* Derived variables
merge m:1 ID using `person', keep(master match) nogen
gen age = year - rabyear
gen float lninc = ln(inc + 1)

rename ID pid
label data "CHARLS analysis variables"
keep pid wave year age female edulow care care3 nogk own recall dep ls srh `mobility' partnered hhsize work lninc chronic adl iadl
order pid wave year age female edulow care care3 nogk own recall dep ls srh `mobility' partnered hhsize work lninc chronic adl iadl
compress
sort pid wave
save "$work/charls.dta", replace
