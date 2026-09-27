*==============================================================================*
* A 题 · Arellano-Bond 诊断(认知):estat abond(AR1/AR2) + Sargan
*   AR(2) 显著=矩条件失效;Sargan 拒绝=工具无效(需非稳健一步法)
*   队列:CHARLS / ELSA / HRS / SHARE(墨韩不可识别)
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"

capture program drop abdiag
program define abdiag
    args tag
    quietly tab wavenum, gen(_wd)
    capture drop _wd1
    di "===== `tag' AB(robust)+AR检验 ====="
    capture quietly xtabond z_cog $cv _wd*, lags(1) pre(care) vce(robust) artests(2)
    if _rc==0 {
        di "  care b=" %8.4f _b[care] "  se=" %8.4f _se[care]
        estat abond
    }
    else di "  失败 rc=" _rc
    di "===== `tag' AB(非稳健)+Sargan ====="
    capture quietly xtabond z_cog $cv _wd*, lags(1) pre(care)
    if _rc==0 estat sargan
    else di "  失败 rc=" _rc
end

*===== CHARLS =====*
use "d:/跨国数据/跨国数据/CHARLS_中国/Working_data/charls_260525.dta", clear
merge 1:1 ID wave using "$T/charls_a1.dta", keep(master match) nogen
keep if age>=50 & age<=105 & !missing(age)
egen id=group(ID)
egen wavenum=group(wave)
xtset id wavenum
quietly summ tr20
gen z_cog=(tr20-r(mean))/r(sd)
gen partnered=inlist(marry,1,2,3) if !missing(marry)
gen lninc=ln(income_total+1)
gen adl=adlab_c
gen hhsize=family_size
gen chronic=chronic_num
global cv "partnered hhsize work lninc own chronic adl iadl"
abdiag C

*===== ELSA =====*
use "d:/跨国数据/跨国数据/ELSA_英国/Working_data/elsa.dta", clear
merge 1:1 idauniqc wave using "$T/elsa_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(idauniqc)
egen wavenum=group(wave)
xtset id wavenum
quietly summ tr20
gen z_cog=(tr20-r(mean))/r(sd)
gen partnered=(mstath==1) if !missing(mstath)
gen lninc=asinh(hitot)
egen chronic=rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
gen adl=adltot6
gen iadl=iadltot2_e
gen hhsize=hhhres
abdiag E

*===== HRS =====*
use "d:/跨国数据/跨国数据/HRS_美国/Working_data/hrs.dta", clear
merge 1:1 hhidpn wave using "$T/hrs_a1.dta", keep(master match) nogen
keep if ragey_e>=50 & ragey_e<=105 & !missing(ragey_e)
keep if ngk>0 & !missing(ngk)
egen id=group(hhidpn)
egen wavenum=group(wave)
xtset id wavenum
quietly summ tr20
gen z_cog=(tr20-r(mean))/r(sd)
gen partnered=inlist(mstath,1,2,3) if !missing(mstath)
gen lninc=asinh(itot)
egen chronic=rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
capture confirm variable adl6a
if _rc==0 gen adl=adl6a
else egen adl=rowtotal(walkra dressa batha eata beda toilta)
capture confirm variable iadl5a
if _rc==0 gen iadl=iadl5a
else egen iadl=rowtotal(phonea moneya medsa shopa mealsa)
gen hhsize=hhres
gen own=.
global cv "partnered hhsize work lninc chronic adl iadl"
abdiag H

*===== SHARE =====*
use "d:/跨国数据/跨国数据/SHARE_欧洲/Working_data/share.dta", clear
merge 1:1 mergeid wave using "$T/share_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(mergeid)
egen wavenum=group(wave)
xtset id wavenum
quietly summ tr20
gen z_cog=(tr20-r(mean))/r(sd)
gen partnered=inlist(mstath,1,2,3) if !missing(mstath)
gen lninc=asinh(hhitothhinc)
egen chronic=rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
egen adl=rowtotal(walkra dressa batha eata beda toilta)
egen iadl=rowtotal(phonea medsa moneya shopa mealsa)
gen hhsize=hhres
global cv "partnered hhsize work lninc own chronic adl iadl"
abdiag S
