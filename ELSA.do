* ELSA: analysis variables from the Harmonized ELSA file h_elsa_g3.dta (Gateway to Global Aging Data,
* version G3, waves 1-9) and the wave 8 and 9 main data files (grandchild-care module)

clear all
set more off
set maxvar 32767

local rstubs iwindy agey gkcare1w grchild_e hownrnt tr20 cesd satlife_e shlt ///
    chaira climsa stoopa armsa lifta dimea mstath work adltot6 iadltot2_e      ///
    hibpe diabe cancre lunge hearte stroke arthre psyche
local hstubs itot hhres

* Care intensity, waves 8-9: weekly hours of grandchild care in the last 12 months
tempfile hours
clear
save `hours', emptyok
foreach f in "8 wave_8_elsa_data_eul_v2" "9 wave_9_elsa_data_eul_v1" {
    tokenize `f'
    use idauniq caglk cagtwd cagtwda cagtwe cagtwea caghol caghoa cagty cagtya cagdif cagdifa ///
        using "$data/ELSA/`2'.dta", clear
    foreach v of varlist cag* {
        replace `v' = . if `v' < 0
    }
    * term time (39 weeks) and holidays (13 weeks), a regular weekly pattern, or an irregular pattern
    gen term = cond(missing(cagtwd), 0, cagtwd) * cond(missing(cagtwda), 0, cagtwda) ///
        + cond(missing(cagtwe), 0, cagtwe) * cond(missing(cagtwea), 0, cagtwea)
    gen hol = cond(missing(caghol), 0, caghol) * cond(missing(caghoa), 0, caghoa)
    gen wkhrs = max((39 * term + 13 * hol) / 52, ///
        cond(missing(cagty), 0, cagty) * cond(missing(cagtya), 0, cagtya), ///
        cond(missing(cagdif), 0, cagdif) * cond(missing(cagdifa), 0, cagdifa))
    replace wkhrs = 112 if wkhrs > 112 & !missing(wkhrs)
    gen byte carey = 1 if caglk == 1
    replace carey = 0 if caglk == 2
    gen byte wave = `1'
    keep idauniq wave carey wkhrs
    append using `hours'
    save `hours', replace
}

use "$data/ELSA/h_elsa_g3.dta", clear

* Keep the wave-specific items that exist and reshape to person-wave rows
local vars idauniqc idauniq ragender raeducl
local stubs inw@
foreach s of local rstubs {
    local stubs `stubs' r@`s'
}
foreach s of local hstubs {
    local stubs `stubs' h@`s'
}
forvalues w = 1/9 {
    foreach s of local stubs {
        local v = subinstr("`s'", "@", "`w'", 1)
        capture confirm variable `v', exact
        if !_rc local vars `vars' `v'
    }
}
keep `vars'
reshape long `stubs', i(idauniqc) j(wave)
keep if inw == 1
merge 1:1 idauniq wave using `hours', keep(master match) nogenerate

* Identifiers, timing, demographics
rename (idauniqc riwindy ragey) (pid year age)
gen byte female = (ragender == 2) if !missing(ragender)
gen byte edulow = (raeducl == 1) if !missing(raeducl)

* Grandchildren and housing
gen byte care = rgkcare1w
gen ngk = rgrchild_e
gen byte own = (rhownrnt == 1) if !missing(rhownrnt)
* waves 8-9 only: 0 = no care, 1 = care, 2 = care for 15 or more hours a week
gen byte care3 = carey + (carey == 1 & wkhrs >= 15 & !missing(wkhrs)) if !missing(carey)

* Outcomes
gen recall = rtr20
gen dep = rcesd
* reversed so that 7 = strongly agree
gen ls = 8 - rsatlife_e
* 1 = poor ... 5 = excellent
gen srh = 6 - rshlt
rename (rchaira rclimsa rstoopa rarmsa rlifta rdimea) (chaira climsa stoopa armsa lifta dimea)

* Covariates
gen byte partnered = (rmstath == 1) if !missing(rmstath)
gen hhsize = hhhres
rename rwork work
gen lninc = asinh(hitot)
egen chronic = rowtotal(rhibpe rdiabe rcancre rlunge rhearte rstroke rarthre rpsyche)
gen adl = radltot6
gen iadl = riadltot2_e

keep pid wave year age female edulow care care3 ngk own recall dep ls srh ///
    chaira climsa stoopa armsa lifta dimea partnered hhsize work lninc chronic adl iadl
order pid wave year age female edulow care care3 ngk own recall dep ls srh ///
    chaira climsa stoopa armsa lifta dimea partnered hhsize work lninc chronic adl iadl
compress
sort pid wave
save "$work/elsa.dta", replace
