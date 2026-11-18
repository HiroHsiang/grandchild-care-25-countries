* KLoSA: analysis variables from H_KLoSA_e2.dta (Harmonized KLoSA, version E.2) and the
* KLoSA imputation files e_imp_w03.dta, e_imp_w04.dta, e_imp_w05.dta, e_imp_w05_new.dta, e_imp_w06.dta, e_imp_w07.dta

clear all
set more off
set maxvar 32767

* Cognition: K-MMSE items C401-C419, first imputation record, waves 3-7 (the wave-8 files carry no K-MMSE items)
local items
forvalues i = 401/419 {
    local items `items' C`i'
}
tempfile cog
local first 1
forvalues w = 3/7 {
    * wave 5: continuing panel and refresh sample are separate files
    local src = cond(`w' == 5, "e_imp_w05 e_imp_w05_new", "e_imp_w0`w'")
    local imp = cond(`w' >= 6, "v_imputation_", "vimputation_")
    local wvars
    foreach x of local items {
        local wvars `wvars' w0`w'`x'
    }
    clear
    foreach f of local src {
        append using "$data/KLoSA/`f'.dta", keep(pid `imp' `wvars')
    }
    keep if `imp' == 1
    isid pid
    rename w0`w'C* c*
    gen byte wave = `w'

    * binary items: 1 = correct, 5 = incorrect
    foreach i in 402 403 404 413 414 415 418 419 {
        gen byte k`i' = cond(c`i' == 1, 1, cond(c`i' == 5, 0, .))
    }
    * graded items: 1-3 (address: 1-4) = number correct, 5 = none correct
    foreach i in 401 405 406 412 416 {
        local top = cond(`i' == 405, 4, 3)
        gen byte k`i' = cond(inrange(c`i', 1, `top'), c`i', cond(c`i' == 5, 0, .))
    }
    * read-and-obey task: 3 = both parts done, 1 = one part, 5 = none
    gen byte k417 = cond(c417 == 3, 1, cond(inlist(c417, 1, 5), 0, .))
    * serial sevens: number correct, scored when the first answer is correct or any answer is wrong
    egen byte k407 = anycount(c407 c408 c409 c410 c411), values(1)
    replace k407 = . if c407 != 1 & !inlist(5, c407, c408, c409, c410, c411)

    gen recall = k406 + k412
    egen mmse = rowtotal(k*), missing
    keep pid wave recall mmse
    if !`first' append using `cog'
    save `cog', replace
    local first 0
}

* Harmonized KLoSA, waves 3-8
local rstubs agey iwy mstath shlt cesd10a itothhinc work gksit hownrnt ///
    hibpe diabe cancre lunge hearte stroke arthre psyche ///
    dressb bathb eatb toiltb bedb_k mealsb shopb medsb moneyb phoneb
local hvars pid ragender raeducl
forvalues w = 3/8 {
    local hvars `hvars' inw`w' h`w'hhres h`w'grchild
    foreach s of local rstubs {
        if !("`s'" == "cesd10a" & `w' > 4) local hvars `hvars' r`w'`s'
    }
}
use `hvars' using "$data/KLoSA/H_KLoSA_e2.dta", clear

local rlong
foreach s of local rstubs {
    local rlong `rlong' r@`s'
}
reshape long inw h@hhres h@grchild `rlong', i(pid) j(wave)
foreach s of local rstubs {
    rename r`s' `s'
}
rename (hhhres hgrchild) (hhres grchild)
keep if inw == 1

merge 1:1 pid wave using `cog', keep(master match) nogenerate

* Outcomes
* shlt is 1 = excellent ... 5 = poor; reversed so that higher = better
gen srh = 6 - shlt
* CES-D 10 is harmonised as cesd10a in waves 1-4 only (later waves use a different response scale)
gen dep = cesd10a

* Grandchild care and household
gen care = gksit
gen ngk = grchild
gen own = (hownrnt == 1) if !missing(hownrnt)

* Covariates
gen age = agey
gen year = iwy
gen female = (ragender == 2) if !missing(ragender)
gen edulow = (raeducl == 1) if !missing(raeducl)
gen partnered = inlist(mstath, 1, 2, 3) if !missing(mstath)
gen hhsize = hhres
gen lninc = asinh(itothhinc)
egen chronic = rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
egen adl = rowtotal(dressb bathb eatb toiltb bedb_k)
egen iadl = rowtotal(mealsb shopb medsb moneyb phoneb)

local out pid wave year age female edulow care ngk own recall dep srh mmse ///
    partnered hhsize work lninc chronic adl iadl
keep `out'
order `out'
compress
sort pid wave
save "$work/klosa.dta", replace
