*==============================================================================*
* A 题 · HRS 试点:带孙 → 认知/抑郁/行动能力(M0/M1 × 3)
*   暴露 = h?gksit(照料孙辈≥100h/2年;household 层)
*   样本 = 50+,有孙辈(ngk>0);working 波5–15,暴露覆盖波5–14(2000–2018)
*   注:own(住房产权)待阶段2 从 fat 提取,本轮 M1 暂无 own
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"

use "d:/跨国数据/跨国数据/HRS_美国/Working_data/hrs.dta", clear
merge 1:1 hhidpn wave using "$T/hrs_a1.dta", keep(master match) nogen
keep if ragey_e>=50 & ragey_e<=105 & !missing(ragey_e)
keep if ngk>0 & !missing(ngk)
egen id = group(hhidpn)
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
gen partnered = inlist(mstath,1,2,3) if !missing(mstath)
gen lninc = asinh(itot)
local chr ""
foreach v in hibpe diabe cancre lunge hearte stroke arthre psyche {
    capture confirm variable `v'
    if _rc==0 local chr "`chr' `v'"
}
di "HRS 慢性病条目: `chr'"
egen chronic = rowtotal(`chr')
egen chrnm = rownonmiss(`chr')
replace chronic = . if chrnm==0
capture confirm variable adl6a
if _rc==0 gen adl = adl6a
else {
    egen adl = rowtotal(walkra dressa batha eata beda toilta)
    egen _anm = rownonmiss(walkra dressa batha eata beda toilta)
    replace adl = . if _anm<6
}
capture confirm variable iadl5a
if _rc==0 gen iadl = iadl5a
else {
    egen iadl = rowtotal(phonea moneya medsa shopa mealsa)
    egen _inm = rownonmiss(phonea moneya medsa shopa mealsa)
    replace iadl = . if _inm<5
}

di "===== HRS 描述(50+,有孙辈)====="
summ care ngk ragey_e partnered hhres work lninc chronic adl iadl if !missing(care)

di "######## HRS 抑郁 ########"
di "-- M0 --"
xtreg z_dep i.care i.wavenum, fe vce(cluster id)
estimates store H_dep_m0
di "-- M1 --"
xtreg z_dep i.care i.partnered c.hhres i.work c.lninc c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store H_dep_m1
di "######## HRS 认知 ########"
di "-- M0 --"
xtreg z_cog i.care i.wavenum, fe vce(cluster id)
estimates store H_cog_m0
di "-- M1 --"
xtreg z_cog i.care i.partnered c.hhres i.work c.lninc c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store H_cog_m1
di "######## HRS 行动能力限制(M1 无 ADL/IADL) ########"
di "-- M0 --"
xtreg z_mob i.care i.wavenum, fe vce(cluster id)
estimates store H_mob_m0
di "-- M1 --"
xtreg z_mob i.care i.partnered c.hhres i.work c.lninc c.chronic i.wavenum, fe vce(cluster id)
estimates store H_mob_m1

di "===== HRS 汇总(care 系数)====="
estimates table H_dep_m0 H_dep_m1 H_cog_m0 H_cog_m1 H_mob_m0 H_mob_m1, ///
    b(%9.4f) se(%9.4f) p(%9.3f) keep(1.care) stats(N N_g)
