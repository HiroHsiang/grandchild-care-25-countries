* MICE 第3段:估计三结局 M1
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
capture confirm file "$T/charls_mi10.dta"
if _rc==0 use "$T/charls_mi10.dta", clear
else use "$T/charls_mi5.dta", clear
di "M = " _N/41074 - 1
mi xtset id wavenum
di _n "######## MICE 抑郁(listwise +0.051 p=.016;QA全样本 +0.012 ns) ########"
mi estimate, post dots: xtreg z_dep i.care i.partnered c.hhsize i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store MI_dep
di _n "######## MICE 满意度(listwise -0.030 p=.22) ########"
mi estimate, post dots: xtreg z_ls i.care i.partnered c.hhsize i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store MI_ls
di _n "######## MICE 认知(listwise +0.048 p=.041) ########"
mi estimate, post dots: xtreg z_cog i.care i.partnered c.hhsize i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store MI_cog
estimates table MI_dep MI_ls MI_cog, b(%9.4f) se(%9.4f) p(%9.3f) keep(1.care) stats(N)
