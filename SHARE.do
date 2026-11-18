* SHARE: analysis variables from the Harmonized SHARE file H_SHARE_f2.dta and the release 9.0.0
* activities (ac) and social support (sp) modules, e.g. sharew8_rel9-0-0_ac.dta, sharew8_rel9-0-0_sp.dta

clear all
set more off
set maxvar 32767

local waves 1 2 4 5 6 7 8
local lswaves 2 4 5 6 7 8

* Life satisfaction (0-10), not in the harmonized file
tempfile lifesat
clear
save `lifesat', emptyok
foreach w of local lswaves {
    use mergeid ac012_ using "$data/SHARE/sharew`w'_rel9-0-0_ac.dta", clear
    * -1 = don't know, -2 = refusal
    gen ls = ac012_ if ac012_ >= 0
    gen byte wave = `w'
    keep mergeid wave ls
    append using `lifesat'
    save `lifesat', replace
}

* Care intensity: almost daily care of a grandchild (social support module)
tempfile daily
clear
save `daily', emptyok
foreach w of local waves {
    use mergeid sp014_ sp016_* using "$data/SHARE/sharew`w'_rel9-0-0_sp.dta", clear
    gen byte daily = 0
    foreach v of varlist sp016_* {
        replace daily = 1 if `v' == 1
    }
    replace daily = . if missing(sp014_) | sp014_ < 0
    gen byte wave = `w'
    keep mergeid wave daily
    append using `daily'
    save `daily', replace
}

* Harmonized items, wide to long
local rvars iwy agey mstath shlt tr20 eurod work hownrnt gksit           ///
    hibpe diabe cancre lunge hearte stroke arthre psyche                ///
    walkra dressa batha eata beda toilta phonea medsa moneya shopa mealsa ///
    chaira climsa stoopa armsa lifta dimea
local hvars grchild
local hhvars hhres itothhinc

local wanted mergeid country ragender raeducl
local stubs inw
foreach w of local waves {
    local wanted `wanted' inw`w'
    foreach v of local rvars {
        local wanted `wanted' r`w'`v'
    }
    foreach v of local hvars {
        local wanted `wanted' h`w'`v'
    }
    foreach v of local hhvars {
        local wanted `wanted' hh`w'`v'
    }
}
foreach v of local rvars {
    local stubs `stubs' r@`v'
}
foreach v of local hvars {
    local stubs `stubs' h@`v'
}
foreach v of local hhvars {
    local stubs `stubs' hh@`v'
}

local hfile "$data/SHARE/H_SHARE_f2.dta"
quietly describe using "`hfile'", varlist
local present `r(varlist)'
* r1psyche and hh1itothhinc do not exist
local wanted : list wanted & present
use `wanted' using "`hfile'", clear

reshape long `stubs', i(mergeid) j(wave)
keep if inw == 1
foreach v of local rvars {
    rename r`v' `v'
}
foreach v of local hvars {
    rename h`v' `v'
}
foreach v of local hhvars {
    rename hh`v' `v'
}

merge 1:1 mergeid wave using `lifesat', keep(master match) nogenerate
merge 1:1 mergeid wave using `daily', keep(master match) nogenerate

* Identifiers and design
rename mergeid pid
gen year = iwy
gen age = agey

* Exposure
gen care = gksit
gen ngk = grchild
gen own = (hownrnt == 1) if !missing(hownrnt)
* 0 = no care, 1 = care, 2 = almost daily care
gen byte care3 = care + (care == 1 & daily == 1) if !missing(care)

* Outcomes
gen recall = tr20
gen dep = eurod
* reversed so that 5 = excellent
gen srh = 6 - shlt

* Covariates
gen female = (ragender == 2) if !missing(ragender)
gen edulow = (raeducl == 1) if !missing(raeducl)
gen partnered = inlist(mstath, 1, 2, 3) if !missing(mstath)
gen hhsize = hhres
gen lninc = asinh(itothhinc)
egen chronic = rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
egen adl = rowtotal(walkra dressa batha eata beda toilta)
egen iadl = rowtotal(phonea medsa moneya shopa mealsa)

local out pid wave year age female edulow care care3 ngk own recall dep ls srh ///
    chaira climsa stoopa armsa lifta dimea                               ///
    partnered hhsize work lninc chronic adl iadl country
keep `out'
order `out'
compress
sort pid wave
save "$work/share.dta", replace
