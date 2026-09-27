*==============================================================================*
* A 题 · ELSA 强度补齐(W8–9 带孙模块)
*   caglk = 过去12个月照看孙辈(宽口径,Di Gessa 式) 1=是 2=否,负值=缺失
*   周小时 = max( (39×学期周时 + 13×假期周时)/52 , 全年 天×时 , 难说 天×时 )
*   care3: 0 否 / 1 是且<15h/周 / 2 是且≥15h/周
*   crosswalk: 原始 idauniq → 分析 idauniqc(取自 h_elsa_g3)
*==============================================================================*
clear all
set more off
set maxvar 32767
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
global D "d:/跨国数据/跨国数据"

* crosswalk
use idauniq idauniqc using "$D/ELSA_英国/Raw_data/Harmonized ELSA/h_elsa_g3.dta", clear
duplicates drop idauniq, force
tempfile xw
save `xw'

tempfile el
local first = 1
foreach pair in "wave8/wave_8_elsa_data_eul_v2 8" "wave9/wave_9_elsa_data_eul_v1 9" {
    tokenize `pair'
    local f  `1'
    local wv `2'
    use idauniq caglk cagtwd cagtwda cagtwe cagtwea caghol caghoa cagty cagtya cagdif cagdifa ///
        using "$D/ELSA_英国/Raw_data/`f'.dta", clear
    foreach v in caglk cagtwd cagtwda cagtwe cagtwea caghol caghoa cagty cagtya cagdif cagdifa {
        replace `v' = . if `v'<0
    }
    gen tw = cond(missing(cagtwd),0,cagtwd)*cond(missing(cagtwda),0,cagtwda) ///
           + cond(missing(cagtwe),0,cagtwe)*cond(missing(cagtwea),0,cagtwea)
    gen hw = cond(missing(caghol),0,caghol)*cond(missing(caghoa),0,caghoa)
    gen wkA = (39*tw + 13*hw)/52
    gen wkB = cond(missing(cagty),0,cagty)*cond(missing(cagtya),0,cagtya)
    gen wkC = cond(missing(cagdif),0,cagdif)*cond(missing(cagdifa),0,cagdifa)
    gen wk_hrs = max(wkA, wkB, wkC)
    replace wk_hrs = 112 if wk_hrs>112 & !missing(wk_hrs)
    gen byte care_broad = .
    replace care_broad = 1 if caglk==1
    replace care_broad = 0 if caglk==2
    gen wave = `wv'
    keep idauniq wave care_broad wk_hrs
    if `first' {
        save `el', replace
        local first = 0
    }
    else {
        append using `el'
        save `el', replace
    }
}
use `el', clear
merge m:1 idauniq using `xw', keep(match) nogen
gen byte care3 = .
replace care3 = 0 if care_broad==0
replace care3 = 1 if care_broad==1
replace care3 = 2 if care_broad==1 & wk_hrs>=15 & !missing(wk_hrs)
keep idauniqc wave care_broad care3 wk_hrs
duplicates drop idauniqc wave, force
save "$T/elsa_int.dta", replace
di "== ELSA W8-9 宽口径带孙率 & care3 =="
tab wave care_broad, row nofreq
tab care3, m
quietly summ wk_hrs if care_broad==1, detail
di "照料者周小时: p50=" r(p50) " p75=" r(p75) " p90=" r(p90)

*========================= ELSA 强度 M1(W8–9)=========================*
use "$D/ELSA_英国/Working_data/elsa.dta", clear
merge 1:1 idauniqc wave using "$T/elsa_a1.dta", keep(master match) nogen
merge 1:1 idauniqc wave using "$T/elsa_int.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(idauniqc)
egen wavenum=group(wave)
xtset id wavenum
quietly summ cesd
gen z_dep=(cesd-r(mean))/r(sd)
quietly summ tr20
gen z_cog=(tr20-r(mean))/r(sd)
egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob=. if mob_nm<6
quietly summ mob
gen z_mob=(mob-r(mean))/r(sd)
quietly summ satlife_e
gen z_ls=(satlife_e-r(mean))/r(sd)
quietly summ shlt
gen z_srh=(shlt-r(mean))/r(sd)
gen partnered=(mstath==1) if !missing(mstath)
gen lninc=asinh(hitot)
egen chronic=rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
gen adl=adltot6
gen iadl=iadltot2_e
gen hhsize=hhhres
foreach y in dep cog ls srh {
    di "===== ELSA 强度 `y' ====="
    quietly capture xtreg z_`y' i.care3 partnered hhsize work lninc own chronic adl iadl i.wavenum, fe vce(cluster id)
    if _rc==0 estimates store IE_`y'
}
di "===== ELSA 强度 mob(无ADL/IADL) ====="
quietly capture xtreg z_mob i.care3 partnered hhsize work lninc own chronic i.wavenum, fe vce(cluster id)
if _rc==0 estimates store IE_mob

di _n "########## ELSA 强度 M1(W8-9;1=低中 2=重度) ##########"
estimates table IE_dep IE_cog IE_mob IE_ls IE_srh, ///
    b(%9.4f) se(%9.4f) p(%9.3f) keep(1.care3 2.care3) stats(N N_g)
