*==============================================================================*
* A 题 · 选择效应双联检(认知结局):
*   ① 未来暴露安慰剂: z_cog ~ fcare + care + 协变量 + i.wave (FE)
*        fcare 显著 => "将来才带孙者当期已更好" => 时变选择存在
*   ② Arellano–Bond: xtabond z_cog(lag1), pre(care) —— NatMed 同款
*   3 波队列(CHARLS/MHAS)A-B 用 capture,不可识别则报告不可行
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"

capture program drop runchk
program define runchk
    * 需已备: z_cog care 协变量(cv 宏) id wavenum 已 xtset;args = 队列代号
    args tag
    gen fcare = F.care
    di "===== `tag' ① 安慰剂(fcare=未来带孙) ====="
    capture noisily xtreg z_cog fcare care $cv i.wavenum, fe vce(cluster id)
    if _rc==0 estimates store P_`tag'
    di "===== `tag' ② Arellano-Bond ====="
    quietly tab wavenum, gen(_wd)
    capture drop _wd1
    capture noisily xtabond z_cog $cv _wd*, lags(1) pre(care) vce(robust)
    if _rc==0 estimates store A_`tag'
    else di "`tag': xtabond 不可识别/失败 rc=" _rc
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
runchk C

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
runchk E

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
runchk H

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
runchk S

*===== MHAS =====*
use "d:/跨国数据/跨国数据/MHAS_墨西哥/Working_data/mhas.dta", clear
merge 1:1 rahhidnp wave using "$T/mhas_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(rahhidnp)
egen wavenum=group(wave)
xtset id wavenum
quietly summ tr16
gen z_cog=(tr16-r(mean))/r(sd)
gen partnered=inlist(mstath,1,2,3) if !missing(mstath)
gen lninc=asinh(itot)
egen chronic=rowtotal(hibpe diabe cancre hearte stroke arthre)
gen adl=adltot6
gen iadl=iadlfour
gen hhsize=hhres
runchk M

*===== KLoSA =====*
use "d:/跨国数据/跨国数据/KLoSA_韩国/Working_data/klosa.dta", clear
merge 1:1 pid wave using "$T/klosa_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(pid)
egen wavenum=group(wave)
xtset id wavenum
quietly summ cog_total
gen z_cog=(cog_total-r(mean))/r(sd)
gen partnered=inlist(mstath,1,2,3) if !missing(mstath)
gen lninc=asinh(itothhinc)
egen chronic=rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
egen adl=rowtotal(dressb bathb eatb toiltb bedb_k)
egen iadl=rowtotal(mealsb shopb medsb moneyb phoneb)
gen hhsize=hres
runchk K

*===== 汇总 =====*
di _n "########## ① 安慰剂:fcare(未来带孙)系数 ##########"
capture noisily estimates table P_C P_E P_H P_S P_M P_K, b(%9.4f) se(%9.4f) p(%9.3f) keep(fcare care) stats(N N_g)
di _n "########## ② Arellano-Bond:care 系数(控 L.z_cog) ##########"
capture noisily estimates table A_C A_E A_H A_S A_M A_K, b(%9.4f) se(%9.4f) p(%9.3f) keep(care LD.z_cog) stats(N N_g)
