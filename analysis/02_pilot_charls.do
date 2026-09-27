*==============================================================================*
* A 题 · CHARLS 试点(逐国模板):带孙 → 认知/抑郁/行动能力
*   M0 = 裸FE(care + 波次);M1 = NatMed 9 项时变协变量(主,进 meta)
*   结局特异:行动能力结局剔除 ADL/IADL 协变量
*   样本:50+;有(幼)孙辈(care 提问 universe);2013/15/18 三波
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"

use "d:/跨国数据/跨国数据/CHARLS_中国/Working_data/charls_260525.dta", clear
merge 1:1 ID wave using "$T/charls_a1.dta", keep(master match) nogen

keep if age>=50 & age<=105 & !missing(age)
egen id = group(ID)
egen wavenum = group(wave)
xtset id wavenum

*==================== 结局(国内 pooled-z)====================*
quietly summ cesd10
gen z_dep = (cesd10-r(mean))/r(sd)
quietly summ tr20
gen z_cog = (tr20-r(mean))/r(sd)
egen mob_nm = rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob = rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob = . if mob_nm<6
quietly summ mob
gen z_mob = (mob-r(mean))/r(sd)

*==================== 协变量(NatMed 9 项)====================*
gen partnered = inlist(marry,1,2,3) if !missing(marry)
gen lninc = ln(income_total+1)
* ADL/IADL:CHARLS working 现成总分(adlab_c=6项ADL,iadl=5项IADL)
gen adl = adlab_c

di "===== 描述:带孙率/协变量覆盖(50+,有孙辈universe)====="
summ care age partnered family_size work lninc own chronic_num adl iadl if !missing(care)

*==================== M0 / M1 × 三结局 ====================*
di "######## 抑郁(越高越差) ########"
di "-- M0 --"
xtreg z_dep i.care i.wavenum, fe vce(cluster id)
estimates store C_dep_m0
di "-- M1 --"
xtreg z_dep i.care i.partnered c.family_size i.work c.lninc i.own ///
    c.chronic_num c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store C_dep_m1

di "######## 认知(越高越好) ########"
di "-- M0 --"
xtreg z_cog i.care i.wavenum, fe vce(cluster id)
estimates store C_cog_m0
di "-- M1 --"
xtreg z_cog i.care i.partnered c.family_size i.work c.lninc i.own ///
    c.chronic_num c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store C_cog_m1

di "######## 行动能力限制(越高越差;协变量剔除 ADL/IADL) ########"
di "-- M0 --"
xtreg z_mob i.care i.wavenum, fe vce(cluster id)
estimates store C_mob_m0
di "-- M1(无 ADL/IADL) --"
xtreg z_mob i.care i.partnered c.family_size i.work c.lninc i.own ///
    c.chronic_num i.wavenum, fe vce(cluster id)
estimates store C_mob_m1

di "===== CHARLS 试点汇总(care 系数;M1 进 meta)====="
estimates table C_dep_m0 C_dep_m1 C_cog_m0 C_cog_m1 C_mob_m0 C_mob_m1, ///
    b(%9.4f) se(%9.4f) keep(1.care) stats(N N_g)
