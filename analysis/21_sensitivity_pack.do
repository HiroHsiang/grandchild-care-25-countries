*==============================================================================*
* A 题 · 敏感性4打包:
*   (a) 排除 COVID 波(SHARE w8、KLoSA w8=2020)→ 重估受影响单元 → 重跑 cog/dep meta
*   (b) 等效性带 ±0.10 SD:mob 与 dep 的 90% CI(TOST 逻辑)
*   (c) leave-one-country-out:cog(报 theta 波动范围)
*   (d) Egger 小样偏倚检验:cog + dep
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"

*--------------------- (a) COVID 波排除 ---------------------*
capture postclose cv
postfile cv str20 country str5 outc double(b se) using "$T/covid_excl.dta", replace
* KLoSA 去 w8
use "d:/跨国数据/跨国数据/KLoSA_韩国/Working_data/klosa.dta", clear
merge 1:1 pid wave using "$T/klosa_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
keep if wave!=8
egen id=group(pid)
egen wavenum=group(wave)
xtset id wavenum
quietly summ cesd10a
gen z_dep=(cesd10a-r(mean))/r(sd)
quietly summ cog_total
gen z_cog=(cog_total-r(mean))/r(sd)
gen partnered=inlist(mstath,1,2,3) if !missing(mstath)
gen lninc=asinh(itothhinc)
egen chronic=rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
egen adl=rowtotal(dressb bathb eatb toiltb bedb_k)
egen iadl=rowtotal(mealsb shopb medsb moneyb phoneb)
gen hhsize=hres
foreach y in cog dep {
    quietly capture xtreg z_`y' i.care partnered hhsize work lninc own chronic adl iadl i.wavenum, fe vce(cluster id)
    if _rc==0 post cv ("South Korea") ("`y'") (_b[1.care]) (_se[1.care])
}
* SHARE 逐国去 w8
use "d:/跨国数据/跨国数据/SHARE_欧洲/Working_data/share.dta", clear
merge 1:1 mergeid wave using "$T/share_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
keep if wave!=8
egen id=group(mergeid)
egen wavenum=group(wave)
xtset id wavenum
quietly summ eurod
gen z_dep=(eurod-r(mean))/r(sd)
quietly summ tr20
gen z_cog=(tr20-r(mean))/r(sd)
gen partnered=inlist(mstath,1,2,3) if !missing(mstath)
gen lninc=asinh(hhitothhinc)
egen chronic=rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
egen adl=rowtotal(walkra dressa batha eata beda toilta)
egen iadl=rowtotal(phonea medsa moneya shopa mealsa)
gen hhsize=hhres
quietly levelsof country, local(cids)
foreach c of local cids {
    quietly count if country==`c' & !missing(care)
    if r(N) < 1500 continue
    local en ""
    foreach pair in "11 Austria" "12 Germany" "13 Sweden" "14 Netherlands" "15 Spain" "16 Italy" "17 France" "18 Denmark" "19 Greece" "20 Switzerland" "23 Belgium" "25 Israel" "28 Czechia" "29 Poland" "31 Luxembourg" "32 Hungary" "33 Portugal" "34 Slovenia" "35 Estonia" "47 Croatia" {
        tokenize `pair'
        if `c'==`1' local en "`2'"
    }
    if "`en'"=="" local en "c`c'"
    preserve
    quietly keep if country==`c'
    foreach y in cog dep {
        quietly capture xtreg z_`y' i.care partnered hhsize work lninc own chronic adl iadl i.wavenum, fe vce(cluster id)
        if _rc==0 post cv ("`en'") ("`y'") (_b[1.care]) (_se[1.care])
    }
    restore
}
postclose cv

* 组装:未受影响单元沿用原系数(从 plotdata_A 取,含中国英美墨),受影响单元换新
import delimited using "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/figures/plotdata_A.csv", clear varnames(1) encoding(utf8)
keep clab bcog secog bdep sedep
tempfile base
save `base'
use "$T/covid_excl.dta", clear
reshape wide b se, i(country) j(outc) string
rename (country bcog secog bdep sedep) (clab n_bcog n_secog n_bdep n_sedep)
merge 1:1 clab using `base', nogen
foreach s in bcog secog bdep sedep {
    replace `s' = n_`s' if !missing(n_`s')
}
foreach y in cog dep {
    preserve
    keep clab b`y' se`y'
    quietly drop if missing(b`y') | missing(se`y')
    quietly meta set b`y' se`y', studylabel(clab) random(reml) nometashow
    quietly meta summarize, se(khartung)
    di "(a) 去COVID波 `y' : K=" r(N) "  theta=" %8.4f r(theta) "  p=" %6.4f r(p) "  I2=" %5.1f r(I2) "%"
    restore
}

*--------------------- (b) 等效性带 ±0.10 SD ---------------------*
use "$T/meta_input_A.dta", clear
foreach y in mob dep ls srh {
    preserve
    quietly keep if outc=="`y'" & !missing(se) & se>0
    quietly meta set b se, studylabel(country) random(reml) nometashow
    quietly meta summarize, se(khartung) level(90)
    local lo : di %7.4f r(ci_lb)
    local hi : di %7.4f r(ci_ub)
    local inband = (r(ci_lb)>-0.10 & r(ci_ub)<0.10)
    di "(b) `y' 90%CI=[`lo',`hi']  ±0.10带内=" cond(`inband',"是(等效于无实质效应)","否")
    restore
}

*--------------------- (c) leave-one-out:认知 ---------------------*
use "$T/meta_input_A.dta", clear
keep if outc=="cog" & !missing(se) & se>0
quietly levelsof country, local(cs)
local tmin = 99
local tmax = -99
local pmax = 0
foreach c of local cs {
    preserve
    quietly drop if country=="`c'"
    quietly meta set b se, studylabel(country) random(reml) nometashow
    quietly meta summarize, se(khartung)
    if r(theta)<`tmin' {
        local tmin=r(theta)
        local cmin "`c'"
    }
    if r(theta)>`tmax' {
        local tmax=r(theta)
        local cmax "`c'"
    }
    if r(p)>`pmax' local pmax=r(p)
    restore
}
di "(c) 认知 LOO:theta 范围 [" %6.4f `tmin' "(去`cmin') , " %6.4f `tmax' "(去`cmax')]  最大p=" %6.4f `pmax'

*--------------------- (d) Egger ---------------------*
foreach y in cog dep {
    use "$T/meta_input_A.dta", clear
    quietly keep if outc=="`y'" & !missing(se) & se>0
    quietly meta set b se, studylabel(country) random(reml) nometashow
    di "(d) `y' Egger:"
    meta bias, egger
}
