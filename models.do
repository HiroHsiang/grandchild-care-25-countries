* Within-person associations of grandchild care with grandparents' health, by country
* Reads the study files written by CHARLS.do ... SHARE.do from $work; writes estimates and descriptives to $results
* and the imputed datasets to $work. Set $work and $results before running; optionally $studies (e.g. "elsa mhas")
* and $countries (SHARE countries, e.g. "Austria Belgium") to run a subset.
* The reasons for the choices made here (sample, standardisation, covariates, imputation, sensitivity analyses)
* are set out in docs/analysis_decisions.md.

version 19
set more off
capture mkdir "$results"
if "$studies"=="" global studies "charls elsa hrs mhas klosa share"
global M 20

capture postclose est
postfile est str20 unit str5 outc str8 kind double(b se b2 se2 bd sed fmi) long(n ng) ///
    using "$results/estimates.dta", replace
capture postclose t1
postfile t1 str20 study str20 unit long(persons obs) double(age_m age_sd) long(women edlow partnered n_partnered ///
    work n_work care_first care_obs changers) using "$results/table1.dta", replace
capture postclose fl
postfile fl str20 study str24 step long(obs persons) using "$results/flow.dta", replace
capture postclose bw
postfile bw str20 study str20 unit int wave double(year_m year_min year_max care) long n using "$results/bywave.dta", replace
capture postclose cd
postfile cd str20 unit double(careprev coresid3) long changers using "$results/country_descriptors.dta", replace
capture postclose ag
postfile ag str20 study double(b se) using "$results/age_slope.dta", replace

* Study setup: sample, standardised outcomes, covariates
capture program drop setup
program define setup
    args study
    use "$work/`study'.dta", clear
    * extended missing codes (.a-.z) as system missing, so that they are imputed
    quietly foreach v of varlist _all {
        capture confirm numeric variable `v'
        if !_rc replace `v' = . if missing(`v')
    }
    flowcount `study' "all"
    * MHAS waves of 2012, 2015 and 2018
    if "`study'"=="mhas" keep if wave>=3
    keep if age>=50 & age<=105 & !missing(age)
    flowcount `study' "age50to105"
    * At least one grandchild. CHARLS has no count of grandchildren in the files used; respondents without
    * (young) grandchildren have care = .g, which is set to missing above, so they leave the sample when the
    * analysis is restricted to observed care status.
    if "`study'"!="charls" keep if ngk>0 & !missing(ngk)
    flowcount `study' "grandchild"
    egen id=group(pid)
    egen wavenum=group(wave)
    xtset id wavenum
    * Outcomes standardised within study (SHARE as a whole), so that coefficients are within-person differences
    * in SD units and can be pooled across studies whose scales differ
    foreach p in "recall cog" "dep dep" "ls ls" "srh srh" "mmse mmse" {
        tokenize `p'
        capture confirm variable `1'
        if _rc continue
        quietly summ `1'
        gen z_`2'=(`1'-r(mean))/r(sd)
    }
    capture confirm variable chaira
    if !_rc {
        egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
        egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
        replace mob=. if mob_nm<6
        quietly summ mob
        gen z_mob=(mob-r(mean))/r(sd)
    }
    * Time-varying covariates as in Mak et al. (2023). Home ownership is not available in HRS. ADL and IADL
    * limitations ($cvm) are left out when mobility limitations is the outcome, because they measure overlapping
    * physical function. Age is not entered: its linear change is absorbed by the individual and wave fixed
    * effects (an age-squared term is added in ccmodels). Sex and education do not change and are absorbed.
    if "`study'"=="hrs" {
        global cv  "partnered hhsize work lninc chronic adl iadl"
        global cvm "partnered hhsize work lninc chronic"
    }
    else {
        global cv  "partnered hhsize work lninc own chronic adl iadl"
        global cvm "partnered hhsize work lninc own chronic"
    }
end

capture program drop flowcount
program define flowcount
    args study step
    quietly count
    local n=r(N)
    tempvar t
    quietly bysort pid: gen byte `t'=_n==1
    quietly count if `t'
    post fl ("`study'") ("`step'") (`n') (r(N))
end

capture program drop changer
program define changer
    capture drop _sdc
    quietly bysort id: egen _sdc=sd(care)
    gen byte changer=_sdc>0 & !missing(_sdc)
    drop _sdc
end

* Complete-case models: main, without income, with age squared, by intensity
* Individual fixed effects with wave dummies and standard errors clustered by person: only changes in care status
* within a person identify the association, so stable differences between people cannot bias it.
* - noinc: income is the covariate with most missing values (about 38% in CHARLS, 33% in KLoSA)
* - agesq: checks whether the association reflects non-linear ageing (cognition, depression, mobility)
* - int: low-to-moderate (1) and intensive (2) care against none, and their difference estimated within country
capture program drop ccmodels
program define ccmodels
    args unit
    foreach y in cog dep ls srh mob {
        capture confirm variable z_`y'
        if _rc continue
        local cvy = cond("`y'"=="mob", "$cvm", "$cv")
        quietly xtreg z_`y' i.care `cvy' i.wavenum, fe vce(cluster id)
        post est ("`unit'") ("`y'") ("cc") (_b[1.care]) (_se[1.care]) (.) (.) (.) (.) (.) (e(N)) (e(N_g))
        local cvni : subinstr local cvy "lninc" "", all
        quietly xtreg z_`y' i.care `cvni' i.wavenum, fe vce(cluster id)
        post est ("`unit'") ("`y'") ("noinc") (_b[1.care]) (_se[1.care]) (.) (.) (.) (.) (.) (e(N)) (e(N_g))
        if inlist("`y'","cog","dep","mob") {
            quietly xtreg z_`y' i.care `cvy' c.age#c.age i.wavenum, fe vce(cluster id)
            post est ("`unit'") ("`y'") ("agesq") (_b[1.care]) (_se[1.care]) (.) (.) (.) (.) (.) (e(N)) (e(N_g))
        }
        capture confirm variable care3
        if !_rc {
            quietly xtreg z_`y' i.care3 `cvy' i.wavenum, fe vce(cluster id)
            quietly lincom 2.care3 - 1.care3
            post est ("`unit'") ("`y'") ("int") (_b[1.care3]) (_se[1.care3]) (_b[2.care3]) (_se[2.care3]) ///
                (r(estimate)) (r(se)) (.) (e(N)) (e(N_g))
        }
    }
end

* Study-level models: next-wave care status (placebo) and stratification by sex
* Placebo: if healthier respondents were more likely to start care, care at the next wave would predict current
* outcomes after current care is controlled for. Both are fitted by study, with the SHARE countries together.
capture program drop studymodels
program define studymodels
    args study
    gen fcare = F.care
    foreach y in dep mob ls srh cog {
        capture confirm variable z_`y'
        if _rc continue
        local cvy = cond("`y'"=="mob", "$cvm", "$cv")
        quietly xtreg z_`y' fcare care `cvy' i.wavenum, fe vce(cluster id)
        post est ("`study'") ("`y'") ("placebo") (_b[fcare]) (_se[fcare]) (_b[care]) (_se[care]) (.) (.) (.) (e(N)) (e(N_g))
        forvalues f=0/1 {
            local k = cond(`f'==1, "women", "men")
            quietly xtreg z_`y' i.care `cvy' i.wavenum if female==`f', fe vce(cluster id)
            post est ("`study'") ("`y'") ("`k'") (_b[1.care]) (_se[1.care]) (.) (.) (.) (.) (.) (e(N)) (e(N_g))
        }
    }
    drop fcare
end

* Multiple imputation (chained equations, predictive mean matching) and fixed-effects models
* Main analysis. Imputed separately within each country, so that the imputation model allows associations to differ
* between countries as the analysis model does. Predictive mean matching (5 nearest neighbours) draws observed
* values only, which keeps counts and bounded scores within their ranges. Predictors: care status, age, wave and
* the fully observed covariates. M = 20, combined by Rubin's rules. w2020 marks the wave collected in 2020.
capture program drop mimodels
program define mimodels
    args unit w2020
    keep if !missing(care) & !missing(age)
    xtset, clear
    local kp "id wavenum care age"
    foreach v in partnered hhsize work lninc own chronic adl iadl z_cog z_dep z_mob z_ls z_srh z_mmse {
        capture confirm variable `v'
        if !_rc local kp "`kp' `v'"
    }
    keep `kp'
    local pm ""
    local lg ""
    local rhs "care age i.wavenum"
    foreach v in hhsize lninc chronic adl iadl z_cog z_dep z_mob z_ls z_srh z_mmse {
        capture confirm variable `v'
        if _rc continue
        quietly count if missing(`v')
        if r(N)>0 local pm "`pm' `v'"
        else if !inlist("`v'","z_cog","z_dep","z_mob","z_ls","z_srh","z_mmse") local rhs "`rhs' `v'"
    }
    foreach v in partnered work own {
        capture confirm variable `v'
        if _rc continue
        quietly count if missing(`v')
        if r(N)>0 local lg "`lg' `v'"
        else local rhs "`rhs' `v'"
    }
    mi set flong
    mi register imputed `pm' `lg'
    * fixed tie-breaking in sorts, so that each country's imputations do not depend on what was run before
    set sortseed 20260908
    mi impute chained (pmm, knn(5)) `pm' `lg' = `rhs', add($M) rseed(20260908) augment
    local fn = subinstr("`unit'"," ","_",.)
    save "$work/mi_`fn'.dta", replace
    mi xtset id wavenum
    foreach y in cog dep ls srh mob {
        capture confirm variable z_`y'
        if _rc continue
        local cvy = cond("`y'"=="mob", "$cvm", "$cv")
        mi estimate, post: xtreg z_`y' i.care `cvy' i.wavenum, fe vce(cluster id)
        post est ("`unit'") ("`y'") ("mi") (_b[1.care]) (_se[1.care]) (.) (.) (.) (.) (e(fmi_max)) (e(N)) (.)
        if "`w2020'"!="" {
            mi estimate, post: xtreg z_`y' i.care `cvy' i.wavenum if wavenum!=`w2020', fe vce(cluster id)
            post est ("`unit'") ("`y'") ("excl2020") (_b[1.care]) (_se[1.care]) (.) (.) (.) (.) (.) (e(N)) (.)
        }
    }
end

* Descriptives of an analytic sample (care and age observed)
capture program drop describe1
program define describe1
    args study unit
    preserve
    keep if !missing(care)
    changer
    quietly count
    local obs=r(N)
    quietly summ care
    local care_obs=r(sum)
    bysort id (wavenum): keep if _n==1
    quietly count
    local np=r(N)
    quietly summ age
    local am=r(mean)
    local asd=r(sd)
    foreach v in female edulow partnered work care changer {
        quietly summ `v'
        local s_`v'=r(sum)
        local n_`v'=r(N)
    }
    post t1 ("`study'") ("`unit'") (`np') (`obs') (`am') (`asd') (`s_female') (`s_edulow') (`s_partnered') ///
        (`n_partnered') (`s_work') (`n_work') (`s_care') (`care_obs') (`s_changer')
    restore
end

capture program drop bywave
program define bywave
    args study unit
    quietly levelsof wave if !missing(care), local(ws)
    foreach w of local ws {
        quietly summ year if wave==`w' & !missing(care)
        local ym=r(mean)
        local y0=r(min)
        local y1=r(max)
        quietly summ care if wave==`w'
        post bw ("`study'") ("`unit'") (`w') (`ym') (`y0') (`y1') (r(mean)) (r(N))
    }
end

* Characteristics at the first analytic wave: changer 1 = care status changed, 0 = no change in two or more waves,
* 2 = observed in one wave only
capture program drop changers1
program define changers1
    args unit
    preserve
    keep if !missing(care)
    changer
    bysort id: gen nw=_N
    replace changer=2 if nw==1
    bysort id (wavenum): keep if _n==1
    foreach v in own z_mob z_ls adl iadl {
        capture confirm variable `v'
        if _rc gen `v'=.
    }
    local cl ""
    foreach v in age female edulow partnered work hhsize own chronic adl iadl care nw z_cog z_dep z_mob z_srh z_ls {
        local cl "`cl' (count) n_`v'=`v' (mean) m_`v'=`v' (sd) s_`v'=`v'"
    }
    gen long persons=1
    collapse (sum) persons `cl', by(changer)
    gen str20 unit="`unit'"
    capture append using "$results/changers.dta"
    save "$results/changers.dta", replace
    restore
end

capture erase "$results/changers.dta"

foreach study of global studies {
    local unit = cond("`study'"=="charls","China",cond("`study'"=="elsa","England",cond("`study'"=="hrs","United States", ///
        cond("`study'"=="mhas","Mexico",cond("`study'"=="klosa","South Korea","SHARE")))))
    setup `study'
    studymodels `study'
    * SHARE is analysed by country. Countries with fewer than 1,500 observations with care status (nine countries,
    * each with a single wave of the care item, so no within-person change) are not analysed.
    if "`study'"=="share" {
        quietly levelsof country, local(cids)
        gen byte analysed=0
        foreach c of local cids {
            quietly count if country==`c' & !missing(care)
            if r(N)>=1500 replace analysed=1 if country==`c'
        }
    }
    else gen byte analysed=1
    preserve
    keep if !missing(care)
    if "`study'"=="share" flowcount `study' "care"
    keep if analysed
    flowcount `study' "analytic"
    * within-person age slope of memory, used in meta.R to express the memory association in years of decline
    quietly xtreg z_cog age, fe vce(cluster id)
    post ag ("`study'") (_b[age]) (_se[age])
    describe1 `study' "`unit'"
    bywave `study' "`unit'"
    restore
    * wave collected in 2020 (KLoSA wave 8, SHARE wave 8), left out in a sensitivity analysis because parts of it
    * were collected during the COVID-19 pandemic
    local w2020 ""
    if inlist("`study'","klosa","share") {
        quietly summ wavenum if wave==8
        local w2020=r(min)
    }
    if "`study'"=="share" {
        quietly levelsof country if analysed, local(units)
        foreach c of local units {
            local unit ""
            foreach pair in "11 Austria" "12 Germany" "13 Sweden" "14 Netherlands" "15 Spain" "16 Italy" "17 France" ///
                "18 Denmark" "19 Greece" "20 Switzerland" "23 Belgium" "25 Israel" "28 Czechia" "29 Poland" ///
                "31 Luxembourg" "32 Hungary" "33 Portugal" "34 Slovenia" "35 Estonia" "47 Croatia" {
                tokenize `pair'
                if `c'==`1' local unit "`2'"
            }
            if "$countries"!="" & !strpos(" $countries ", " `unit' ") continue
            preserve
            keep if country==`c'
            describe1 `study' "`unit'"
            bywave `study' "`unit'"
            quietly summ care if !missing(care)
            local cp=r(mean)
            gen c3=hhsize>=3 if !missing(hhsize) & !missing(care)
            quietly summ c3
            local c3m=r(mean)
            drop c3
            post cd ("`unit'") (`cp') (`c3m') (.)
            changers1 "`unit'"
            ccmodels "`unit'"
            mimodels "`unit'" `w2020'
            restore
        }
    }
    else {
        quietly summ care if !missing(care)
        local cp=r(mean)
        gen c3=hhsize>=3 if !missing(hhsize) & !missing(care)
        quietly summ c3
        local c3m=r(mean)
        drop c3
        post cd ("`unit'") (`cp') (`c3m') (.)
        changers1 "`unit'"
        ccmodels "`unit'"
        mimodels "`unit'" `w2020'
    }
}

postclose est
postclose t1
postclose fl
postclose bw
postclose cd
postclose ag
foreach f in estimates table1 flow bywave country_descriptors age_slope changers {
    use "$results/`f'.dta", clear
    export delimited using "$results/`f'.csv", replace
}
