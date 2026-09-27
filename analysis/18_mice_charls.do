*==============================================================================*
* A 题 · 敏感性1:CHARLS MICE 多重插补(收入缺失43%的正式解法,NatMed 同款)
*   插补:协变量 lninc own work partnered chronic adl iadl(链式,M=10)
*   预测子:care 结局 age hhsize 波次;估计:mi estimate: xtreg M1(FE)
*   对照:listwise M1(收入子样本) vs MICE M1(全样本)
*==============================================================================*
clear all
set more off
set seed 20260831
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"

use "d:/跨国数据/跨国数据/CHARLS_中国/Working_data/charls_260525.dta", clear
merge 1:1 ID wave using "$T/charls_a1.dta", keep(master match) nogen
keep if age>=50 & age<=105 & !missing(age)
keep if !missing(care)
egen id = group(ID)
egen wavenum = group(wave)
xtset id wavenum
quietly summ cesd10
gen z_dep = (cesd10-r(mean))/r(sd)
gen satc = satlife
replace satc = . if satlife==6
quietly summ satc
gen z_ls = (satc-r(mean))/r(sd)
quietly summ tr20
gen z_cog = (tr20-r(mean))/r(sd)
gen partnered = inlist(marry,1,2,3) if !missing(marry)
gen lninc = ln(income_total+1)
gen adl = adlab_c
gen hhsize = family_size
gen chronic = chronic_num
keep id wavenum care z_dep z_ls z_cog partnered hhsize work lninc own chronic adl iadl age
di "== 缺失概况 =="
misstable summarize lninc own work partnered chronic adl iadl

mi set flong
mi register imputed lninc own work partnered chronic adl iadl z_dep z_ls z_cog
mi register regular care hhsize age wavenum
mi impute chained ///
    (pmm, knn(5)) lninc adl iadl chronic z_dep z_ls z_cog ///
    (logit) own work partnered ///
    = care hhsize age i.wavenum, add(10) rseed(20260831) augment dots
mi xtset id wavenum

di _n "######## MICE M1:抑郁(对照 listwise +0.051 p=.016;QA全样本 +0.012 ns) ########"
mi estimate, post dots: xtreg z_dep i.care i.partnered c.hhsize i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store MI_dep
di _n "######## MICE M1:满意度(对照 listwise -0.030 p=.22) ########"
mi estimate, post dots: xtreg z_ls i.care i.partnered c.hhsize i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store MI_ls
di _n "######## MICE M1:认知(对照 listwise +0.048 p=.041) ########"
mi estimate, post dots: xtreg z_cog i.care i.partnered c.hhsize i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store MI_cog

di _n "===== MICE 汇总(care 系数) ====="
estimates table MI_dep MI_ls MI_cog, b(%9.4f) se(%9.4f) p(%9.3f) keep(1.care) stats(N)
