* MHAS: analysis variables from the Harmonized MHAS file, version C.2 (H_MHAS_c2.dta)

clear all
set more off
set maxvar 32767

local ritems iwy agey tr16 cesd_m shlt chaira climsa stoopa armsa lifta dimea ///
    mstath work hibpe diabe cancre stroke arthre adltot6 iadlfour
local hitems gccare_m gccarehr_m grchild hownrnt itot hhres

* Life satisfaction is asked from wave 3 on
local vars rahhidnp ragender raeducl r3satlife_m r4satlife_m r5satlife_m
forvalues w = 1/5 {
    local vars `vars' inw`w'
    foreach v of local ritems {
        local vars `vars' r`w'`v'
    }
    foreach v of local hitems {
        local vars `vars' h`w'`v'
    }
}
use `vars' using "$data/MHAS/H_MHAS_c2.dta", clear

local stubs inw
foreach v in `ritems' satlife_m {
    local stubs `stubs' r@`v'
}
foreach v of local hitems {
    local stubs `stubs' h@`v'
}
reshape long `stubs', i(rahhidnp) j(wave)
keep if inw == 1

rename (rahhidnp riwy ragey) (pid year age)
gen byte female = ragender == 2 if !missing(ragender)
gen byte edulow = raeducl == 1 if !missing(raeducl)

* Grandchild care
rename (hgccare_m hgccarehr_m hgrchild) (care carehrs ngk)
* 0 = no care, 1 = care, 2 = 780 or more hours in the last year (15 hours a week); hours are reported for the household
gen byte care3 = care + (care == 1 & carehrs >= 780 & !missing(carehrs)) if !missing(care)
gen byte own = hhownrnt == 1 if !missing(hhownrnt)

* Outcomes
rename (rtr16 rcesd_m) (recall dep)
* satlife_m: 1 = agree ... 3 = disagree; reversed so that 3 = most satisfied
gen byte ls = 4 - rsatlife_m if inlist(rsatlife_m, 1, 2, 3)
* shlt: 1 = excellent ... 5 = poor; reversed so that 5 = excellent
gen byte srh = 6 - rshlt
foreach v in chaira climsa stoopa armsa lifta dimea {
    rename r`v' `v'
}

* Covariates
gen byte partnered = inlist(rmstath, 1, 2, 3) if !missing(rmstath)
rename (hhhres rwork radltot6 riadlfour) (hhsize work adl iadl)
gen lninc = asinh(hitot)
* Heart problems are left out: wave 3 asks about them only after a heart attack
egen chronic = rowtotal(rhibpe rdiabe rcancre rstroke rarthre)

local out pid wave year age female edulow care care3 ngk own recall dep ls srh ///
    chaira climsa stoopa armsa lifta dimea partnered hhsize work lninc chronic adl iadl
keep `out'
order `out'
compress
sort pid wave
save "$work/mhas.dta", replace
