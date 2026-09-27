* MICE 第1段:建库+插补 M=5 → 落盘
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
use "d:/跨国数据/跨国数据/CHARLS_中国/Working_data/charls_260525.dta", clear
merge 1:1 ID wave using "$T/charls_a1.dta", keep(master match) nogen
keep if age>=50 & age<=105 & !missing(age)
keep if !missing(care)
egen id = group(ID)
egen wavenum = group(wave)
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
mi set flong
mi register imputed lninc own work partnered chronic adl iadl z_dep z_ls z_cog
mi register regular care hhsize age wavenum
mi impute chained ///
    (pmm, knn(5)) lninc adl iadl chronic z_dep z_ls z_cog ///
    (logit) own work partnered ///
    = care hhsize age i.wavenum, add(5) rseed(20260831) augment dots
save "$T/charls_mi5.dta", replace
di "STAGE1 DONE M=5"
