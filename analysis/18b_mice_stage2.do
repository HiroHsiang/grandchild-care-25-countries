* MICE 第2段:续插补至 M=10 → 落盘
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
use "$T/charls_mi5.dta", clear
mi impute chained ///
    (pmm, knn(5)) lninc adl iadl chronic z_dep z_ls z_cog ///
    (logit) own work partnered ///
    = care hhsize age i.wavenum, add(5) rseed(20260832) augment dots
save "$T/charls_mi10.dta", replace
di "STAGE2 DONE M=10"
