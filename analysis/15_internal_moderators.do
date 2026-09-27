*==============================================================================*
* A 题 · 内生 moderator 2:同住率 coresid3 = P(家庭人数>=3 | 50+,有孙辈)
*   逐单元计算 → 并入 plotdata → meta regress(五结局)
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
capture postclose cr
postfile cr str20 clab double coresid3 using "$T/coresid.dta", replace

* CHARLS
use ID wave age family_size using "d:/跨国数据/跨国数据/CHARLS_中国/Working_data/charls_260525.dta", clear
merge 1:1 ID wave using "$T/charls_a1.dta", keep(match) nogen keepusing(care)
keep if age>=50 & age<=105 & !missing(care)
quietly summ family_size if !missing(family_size)
quietly gen c3 = family_size>=3 if !missing(family_size)
quietly summ c3
post cr ("China") (r(mean))
* ELSA
use idauniqc wave agey hhhres using "d:/跨国数据/跨国数据/ELSA_英国/Working_data/elsa.dta", clear
merge 1:1 idauniqc wave using "$T/elsa_a1.dta", keep(match) nogen keepusing(care ngk)
keep if agey>=50 & agey<=105 & ngk>0 & !missing(care)
quietly gen c3 = hhhres>=3 if !missing(hhhres)
quietly summ c3
post cr ("England") (r(mean))
* HRS
use hhidpn wave ragey_e hhres using "d:/跨国数据/跨国数据/HRS_美国/Working_data/hrs.dta", clear
merge 1:1 hhidpn wave using "$T/hrs_a1.dta", keep(match) nogen keepusing(care ngk)
keep if ragey_e>=50 & ragey_e<=105 & ngk>0 & !missing(care)
quietly gen c3 = hhres>=3 if !missing(hhres)
quietly summ c3
post cr ("United States") (r(mean))
* MHAS
use rahhidnp wave agey hhres using "d:/跨国数据/跨国数据/MHAS_墨西哥/Working_data/mhas.dta", clear
merge 1:1 rahhidnp wave using "$T/mhas_a1.dta", keep(match) nogen keepusing(care ngk)
keep if agey>=50 & agey<=105 & ngk>0 & !missing(care)
quietly gen c3 = hhres>=3 if !missing(hhres)
quietly summ c3
post cr ("Mexico") (r(mean))
* KLoSA
use pid wave agey hres using "d:/跨国数据/跨国数据/KLoSA_韩国/Working_data/klosa.dta", clear
merge 1:1 pid wave using "$T/klosa_a1.dta", keep(match) nogen keepusing(care ngk)
keep if agey>=50 & agey<=105 & ngk>0 & !missing(care)
quietly gen c3 = hres>=3 if !missing(hres)
quietly summ c3
post cr ("South Korea") (r(mean))
* SHARE 逐国
use mergeid wave agey hhres country using "d:/跨国数据/跨国数据/SHARE_欧洲/Working_data/share.dta", clear
merge 1:1 mergeid wave using "$T/share_a1.dta", keep(match) nogen keepusing(care ngk)
keep if agey>=50 & agey<=105 & ngk>0 & !missing(care)
quietly gen c3 = hhres>=3 if !missing(hhres)
foreach pair in "11 Austria" "12 Germany" "13 Sweden" "14 Netherlands" "15 Spain" "16 Italy" "17 France" "18 Denmark" "19 Greece" "20 Switzerland" "23 Belgium" "25 Israel" "28 Czechia" "29 Poland" "31 Luxembourg" "32 Hungary" "33 Portugal" "34 Slovenia" "35 Estonia" "47 Croatia" {
    tokenize `pair'
    quietly count if country==`1'
    if r(N)<1500 continue
    quietly summ c3 if country==`1'
    post cr ("`2'") (r(mean))
}
postclose cr

* 并入 plotdata 并重存
import delimited using "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/figures/plotdata_A.csv", clear varnames(1) encoding(utf8)
merge 1:1 clab using "$T/coresid.dta", nogen
export delimited using "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/figures/plotdata_A.csv", replace
di "== coresid3 分布 =="
list clab coresid3, noobs
* meta regress 五结局
foreach y in cog dep mob ls srh {
    preserve
    keep clab b`y' se`y' coresid3
    rename (b`y' se`y') (b se)
    quietly drop if missing(b) | missing(se)
    quietly meta set b se, studylabel(clab) random(reml) nometashow
    di _n "########## `y' ~ coresid3(同住率) ##########"
    meta regress coresid3, se(khartung)
    restore
}
