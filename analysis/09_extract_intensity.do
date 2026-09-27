*==============================================================================*
* A 题 · 阶段2:强度提取 → care3(0不带/1低中/2重度)
*   统一定义(Di Gessa 2016):重度 = 约每天(SHARE频率臂) 或 ≥15h/周
*   小时换算:年均≥780h/年(=15×52);HRS 2年≥1560h
*   层级:CHARLS/HRS/SHARE=本人小时/频率;MHAS=household 小时(条目所限,caveat)
*   ELSA(仅W8+模块,后补)/KLoSA(无小时)不做强度
*==============================================================================*
clear all
set more off
set maxvar 32767
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
global D "d:/跨国数据/跨国数据"

*========================= CHARLS(2013/15/18 = wave2/3/4)==================*
tempfile ch
local first = 1
foreach pair in "2013charls 2" "2015charls 3" "2018charls 4" {
    tokenize `pair'
    local dir `1'
    local wv  `2'
    use ID cf003_1_* cf003_2_* using "$D/CHARLS_中国/Raw_data/`dir'/Family_Transfer.dta", clear
    gen double anyhrs = 0
    forvalues k=1/11 {
        capture confirm variable cf003_1_`k'_
        if _rc continue
        gen double _h`k' = cf003_1_`k'_ * cf003_2_`k'_
        replace _h`k' = 0 if missing(_h`k')
        replace anyhrs = anyhrs + _h`k'
        drop _h`k'
    }
    gen hrs_yr = anyhrs
    gen wave = `wv'
    keep ID wave hrs_yr
    if `first' {
        save `ch', replace
        local first = 0
    }
    else {
        append using `ch'
        save `ch', replace
    }
}
use `ch', clear
duplicates drop ID wave, force
save "$T/charls_int.dta", replace
quietly summ hrs_yr, detail
di "CHARLS 本人年小时: p50=" r(p50) " p90=" r(p90) " N=" r(N)

*========================= SHARE(w1,2,4–8)=================================*
tempfile sh
local first = 1
foreach w in 1 2 4 5 6 7 8 {
    use mergeid sp014_ sp016_* using "$D/SHARE_欧洲/Raw_data/Wave `w' Release 9.0.0/sharew`w'_rel9-0-0_sp.dta", clear
    gen byte daily = 0
    foreach v of varlist sp016_* {
        replace daily = 1 if `v'==1
    }
    replace daily = . if sp014_==. | sp014_<0
    gen wave = `w'
    keep mergeid wave daily
    if `first' {
        save `sh', replace
        local first = 0
    }
    else {
        append using `sh'
        save `sh', replace
    }
}
use `sh', clear
duplicates drop mergeid wave, force
save "$T/share_int.dta", replace
quietly summ daily
di "SHARE 约每天占比(照料者内含0): " %5.3f r(mean) " N=" r(N)

*========================= HRS(2006–2020 = w8–15)==========================*
tempfile hr
local first = 1
foreach trio in "2006 h06f4a k 8" "2008 h08f3a l 9" "2010 hd10f6a m 10" "2012 h12f3a n 11" "2014 h14f2b o 12" "2016 h16f2c p 13" "2018 h18f2b q 14" "2020 h20f1a r 15" {
    tokenize `trio'
    local yr `1'
    local f  `2'
    local p  `3'
    local wv `4'
    capture use hhidpn `p'e063 using "$D/HRS_美国/Raw_data/`yr' RAND HRS Fat File/`f'.dta", clear
    if _rc {
        di "HRS `yr' 提取失败 rc=" _rc
        continue
    }
    rename `p'e063 rhrs2y
    gen wave = `wv'
    keep hhidpn wave rhrs2y
    if `first' {
        save `hr', replace
        local first = 0
    }
    else {
        append using `hr'
        save `hr', replace
    }
}
use `hr', clear
duplicates drop hhidpn wave, force
save "$T/hrs_int.dta", replace
quietly summ rhrs2y, detail
di "HRS 本人2年小时: p50=" r(p50) " p90=" r(p90) " N=" r(N)

*========================= 汇总:构建 care3 并验患病率 =========================*
* CHARLS
use "$T/charls_a1.dta", clear
merge 1:1 ID wave using "$T/charls_int.dta", keep(master match) nogen
gen byte care3 = .
replace care3 = 0 if care==0
replace care3 = 1 if care==1
replace care3 = 2 if care==1 & hrs_yr>=780 & !missing(hrs_yr)
save "$T/charls_a2.dta", replace
di _n "== CHARLS care3 =="
tab care3, m
* SHARE
use "$T/share_a1.dta", clear
merge 1:1 mergeid wave using "$T/share_int.dta", keep(master match) nogen
gen byte care3 = .
replace care3 = 0 if care==0
replace care3 = 1 if care==1
replace care3 = 2 if care==1 & daily==1
save "$T/share_a2.dta", replace
di _n "== SHARE care3 =="
tab care3, m
* HRS
use "$T/hrs_a1.dta", clear
merge 1:1 hhidpn wave using "$T/hrs_int.dta", keep(master match) nogen
gen byte care3 = .
replace care3 = 0 if care==0
replace care3 = 1 if care==1
replace care3 = 2 if care==1 & rhrs2y>=1560 & !missing(rhrs2y)
save "$T/hrs_a2.dta", replace
di _n "== HRS care3 =="
tab care3, m
* MHAS(household 小时 caveat)
use "$T/mhas_a1.dta", clear
gen byte care3 = .
replace care3 = 0 if care==0
replace care3 = 1 if care==1
replace care3 = 2 if care==1 & hrs>=780 & !missing(hrs)
save "$T/mhas_a2.dta", replace
di _n "== MHAS care3 =="
tab care3, m
