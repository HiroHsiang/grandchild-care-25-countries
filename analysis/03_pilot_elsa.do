*==============================================================================*
* A 题 · ELSA 试点:带孙 → 认知/抑郁/行动能力(M0/M1 × 3)
*   暴露 = r?gkcare1w(上周照护孙辈;严口径,阶段2 找宽口径)
*   样本 = 50+,有孙辈(ngk>0);波 1–9(2002–2019)
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"

use "d:/跨国数据/跨国数据/ELSA_英国/Working_data/elsa.dta", clear
merge 1:1 idauniqc wave using "$T/elsa_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id = group(idauniqc)
egen wavenum = group(wave)
xtset id wavenum

*---- 结局 pooled-z ----
quietly summ cesd
gen z_dep = (cesd-r(mean))/r(sd)
quietly summ tr20
gen z_cog = (tr20-r(mean))/r(sd)
egen mob_nm = rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob = rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob = . if mob_nm<6
quietly summ mob
gen z_mob = (mob-r(mean))/r(sd)

*---- 协变量 ----
gen partnered = (mstath==1) if !missing(mstath)
gen lninc = asinh(hitot)
local chr ""
foreach v in hibpe diabe cancre lunge hearte stroke arthre psyche {
    capture confirm variable `v'
    if _rc==0 local chr "`chr' `v'"
}
di "ELSA 慢性病条目: `chr'"
egen chronic = rowtotal(`chr')
egen chrnm = rownonmiss(`chr')
replace chronic = . if chrnm==0
gen adl = adltot6
gen iadl = iadltot2_e

di "===== ELSA 描述(50+,有孙辈)====="
summ care ngk agey partnered hhhres work lninc own chronic adl iadl if !missing(care)

di "######## ELSA 抑郁 ########"
di "-- M0 --"
xtreg z_dep i.care i.wavenum, fe vce(cluster id)
estimates store E_dep_m0
di "-- M1 --"
xtreg z_dep i.care i.partnered c.hhhres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store E_dep_m1
di "######## ELSA 认知 ########"
di "-- M0 --"
xtreg z_cog i.care i.wavenum, fe vce(cluster id)
estimates store E_cog_m0
di "-- M1 --"
xtreg z_cog i.care i.partnered c.hhhres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store E_cog_m1
di "######## ELSA 行动能力限制(M1 无 ADL/IADL) ########"
di "-- M0 --"
xtreg z_mob i.care i.wavenum, fe vce(cluster id)
estimates store E_mob_m0
di "-- M1 --"
xtreg z_mob i.care i.partnered c.hhhres i.work c.lninc i.own c.chronic i.wavenum, fe vce(cluster id)
estimates store E_mob_m1

di "===== ELSA 汇总(care 系数)====="
estimates table E_dep_m0 E_dep_m1 E_cog_m0 E_cog_m1 E_mob_m0 E_mob_m1, ///
    b(%9.4f) se(%9.4f) p(%9.3f) keep(1.care) stats(N N_g)
