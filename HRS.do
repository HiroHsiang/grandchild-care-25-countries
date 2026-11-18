* HRS: analysis variables from the RAND HRS Longitudinal File 1992-2020 V2 (randhrs1992_2020v2.dta),
* the Gateway Harmonized HRS, version D (H_HRS_d.dta), waves 5-15 (2000-2020), and the RAND HRS Fat Files 2006-2020

clear all
set more off
set maxvar 32767

local ritems iwendy agey_e mstath shlt cesd chaira climsa stoopa armsa lifta dimea ///
    hibpe diabe cancre lunge hearte stroke arthre psyche adl6a iadl5a work
local hitems hhres itot

* Care intensity, waves 8-15: hours spent caring for grandchildren in the last two years (RAND HRS Fat Files)
tempfile hours
clear
save `hours', emptyok
foreach f in "8 h06f4a k" "9 h08f3a l" "10 hd10f6a m" "11 h12f3a n" "12 h14f2b o" "13 h16f2c p" "14 h18f2b q" "15 h20f1a r" {
    tokenize `f'
    use hhidpn `3'e063 using "$data/HRS/`2'.dta", clear
    rename `3'e063 carehrs
    * codes for don't know and refused, and values above the hours in two years (2 x 8,760)
    replace carehrs = . if carehrs > 17520
    gen byte wave = `1'
    append using `hours'
    save `hours', replace
}

* RAND HRS
local vars hhidpn ragender
forvalues w = 5/15 {
    local vars `vars' inw`w'
    foreach v of local ritems {
        local vars `vars' r`w'`v'
    }
    foreach v of local hitems {
        local vars `vars' h`w'`v'
    }
    if `w' <= 13 local vars `vars' r`w'tr20
    else local vars `vars' r`w'tr20w r`w'tr20p
}
use `vars' using "$data/HRS/randhrs1992_2020v2.dta", clear

* From wave 14 word recall is split by interview mode (web, else face-to-face/telephone; never both)
forvalues w = 14/15 {
    gen byte r`w'tr20 = cond(!missing(r`w'tr20w), r`w'tr20w, r`w'tr20p)
    drop r`w'tr20w r`w'tr20p
}

* Gateway Harmonized HRS; grandchild items end at wave 14, life satisfaction starts at wave 9
preserve
local vars hhidpn raeducl
forvalues w = 5/15 {
    if `w' <= 14 local vars `vars' h`w'gksit h`w'grchild
    if `w' >= 9 local vars `vars' r`w'satlife_h
}
use `vars' using "$data/HRS/H_HRS_d.dta", clear
tempfile gateway
save `gateway'
restore
merge 1:1 hhidpn using `gateway', keep(master match) nogenerate

foreach v in `ritems' tr20 satlife_h {
    rename r#`v' `v'#
}
foreach v in `hitems' gksit grchild {
    rename h#`v' `v'#
}
reshape long inw `ritems' tr20 satlife_h `hitems' gksit grchild, i(hhidpn) j(wave)
keep if inw == 1
merge 1:1 hhidpn wave using `hours', keep(master match) nogenerate

rename hhidpn pid
rename iwendy year
rename agey_e age
gen byte female = ragender == 2 if !missing(ragender)
gen byte edulow = raeducl == 1 if !missing(raeducl)

* Grandchild care
rename gksit care
rename grchild ngk
* 0 = no care, 1 = care, 2 = care for 1,560 or more hours in two years (15 hours a week)
gen byte care3 = care + (care == 1 & carehrs >= 1560 & !missing(carehrs)) if !missing(care)

* Outcomes
rename tr20 recall
rename cesd dep
rename satlife_h ls
* shlt: 1 = excellent ... 5 = poor; reversed so that 5 = excellent
gen byte srh = 6 - shlt

* Covariates
gen byte partnered = inlist(mstath, 1, 2, 3) if !missing(mstath)
rename hhres hhsize
gen lninc = asinh(itot)
egen chronic = rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
rename adl6a adl
rename iadl5a iadl

local out pid wave year age female edulow care care3 ngk recall dep ls srh ///
    chaira climsa stoopa armsa lifta dimea partnered hhsize work lninc chronic adl iadl
keep `out'
order `out'
compress
sort pid wave
save "$work/hrs.dta", replace
