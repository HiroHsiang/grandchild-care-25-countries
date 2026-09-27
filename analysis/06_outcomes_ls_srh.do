*==============================================================================*
* A 题 · 新增结局(对齐 NatMed):生活满意度 + 自评健康 × 六队列 × M1
*   方向:两结局均"高=好"(六队列 shlt/srh 1–5 同向已核;MHAS satlife_m 反转;
*         CHARLS satlife 清洗误码6;SHARE satlife 0–10 晚波;KLoSA 无满意度)
*   M1 同主规格;此两结局按 NatMed 保留 ADL/IADL 协变量
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"

*========================= CHARLS =========================*
use "d:/跨国数据/跨国数据/CHARLS_中国/Working_data/charls_260525.dta", clear
merge 1:1 ID wave using "$T/charls_a1.dta", keep(master match) nogen
keep if age>=50 & age<=105 & !missing(age)
egen id=group(ID)
egen wavenum=group(wave)
xtset id wavenum
gen satc = satlife
replace satc = . if satlife==6
quietly summ satc
gen z_ls = (satc-r(mean))/r(sd)
quietly summ srh
gen z_srh = (srh-r(mean))/r(sd)
gen partnered = inlist(marry,1,2,3) if !missing(marry)
gen lninc = ln(income_total+1)
gen adl = adlab_c
di "######## CHARLS 满意度 M1 ########"
xtreg z_ls i.care i.partnered c.family_size i.work c.lninc i.own c.chronic_num c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store C_ls
di "######## CHARLS 自评健康 M1 ########"
xtreg z_srh i.care i.partnered c.family_size i.work c.lninc i.own c.chronic_num c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store C_srh

*========================= ELSA =========================*
use "d:/跨国数据/跨国数据/ELSA_英国/Working_data/elsa.dta", clear
merge 1:1 idauniqc wave using "$T/elsa_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(idauniqc)
egen wavenum=group(wave)
xtset id wavenum
quietly summ satlife_e
gen z_ls = (satlife_e-r(mean))/r(sd)
quietly summ shlt
gen z_srh = (shlt-r(mean))/r(sd)
gen partnered = (mstath==1) if !missing(mstath)
gen lninc = asinh(hitot)
egen chronic = rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
egen chrnm = rownonmiss(hibpe diabe cancre lunge hearte stroke arthre psyche)
replace chronic = . if chrnm==0
gen adl = adltot6
gen iadl = iadltot2_e
di "######## ELSA 满意度 M1 ########"
xtreg z_ls i.care i.partnered c.hhhres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store E_ls
di "######## ELSA 自评健康 M1 ########"
xtreg z_srh i.care i.partnered c.hhhres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store E_srh

*========================= HRS =========================*
use "d:/跨国数据/跨国数据/HRS_美国/Working_data/hrs.dta", clear
merge 1:1 hhidpn wave using "$T/hrs_a1.dta", keep(master match) nogen
keep if ragey_e>=50 & ragey_e<=105 & !missing(ragey_e)
keep if ngk>0 & !missing(ngk)
egen id=group(hhidpn)
egen wavenum=group(wave)
xtset id wavenum
quietly summ satlife_h
gen z_ls = (satlife_h-r(mean))/r(sd)
quietly summ shlt
gen z_srh = (shlt-r(mean))/r(sd)
gen partnered = inlist(mstath,1,2,3) if !missing(mstath)
gen lninc = asinh(itot)
egen chronic = rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
egen chrnm = rownonmiss(hibpe diabe cancre lunge hearte stroke arthre psyche)
replace chronic = . if chrnm==0
capture confirm variable adl6a
if _rc==0 gen adl = adl6a
else {
    egen adl = rowtotal(walkra dressa batha eata beda toilta)
}
capture confirm variable iadl5a
if _rc==0 gen iadl = iadl5a
else {
    egen iadl = rowtotal(phonea moneya medsa shopa mealsa)
}
di "######## HRS 满意度 M1 ########"
xtreg z_ls i.care i.partnered c.hhres i.work c.lninc c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store H_ls
di "######## HRS 自评健康 M1 ########"
xtreg z_srh i.care i.partnered c.hhres i.work c.lninc c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store H_srh

*========================= SHARE =========================*
use "d:/跨国数据/跨国数据/SHARE_欧洲/Working_data/share.dta", clear
merge 1:1 mergeid wave using "$T/share_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(mergeid)
egen wavenum=group(wave)
xtset id wavenum
di "-- SHARE satlife 覆盖 --"
quietly count if !missing(satlife)
di "satlife 非缺失 N=" r(N)
quietly summ satlife
gen z_ls = (satlife-r(mean))/r(sd)
quietly summ shlt
gen z_srh = (shlt-r(mean))/r(sd)
gen partnered = inlist(mstath,1,2,3) if !missing(mstath)
gen lninc = asinh(hhitothhinc)
egen chronic = rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
egen chrnm = rownonmiss(hibpe diabe cancre lunge hearte stroke arthre psyche)
replace chronic = . if chrnm==0
egen adl = rowtotal(walkra dressa batha eata beda toilta)
egen adlnm = rownonmiss(walkra dressa batha eata beda toilta)
replace adl = . if adlnm<6
egen iadl = rowtotal(phonea medsa moneya shopa mealsa)
egen iadlnm = rownonmiss(phonea medsa moneya shopa mealsa)
replace iadl = . if iadlnm<5
di "######## SHARE 满意度 M1 ########"
xtreg z_ls i.care i.partnered c.hhres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store S_ls
di "######## SHARE 自评健康 M1 ########"
xtreg z_srh i.care i.partnered c.hhres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store S_srh

*========================= MHAS =========================*
use "d:/跨国数据/跨国数据/MHAS_墨西哥/Working_data/mhas.dta", clear
merge 1:1 rahhidnp wave using "$T/mhas_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(rahhidnp)
egen wavenum=group(wave)
xtset id wavenum
gen satr = 4 - satlife_m if inlist(satlife_m,1,2,3)
quietly summ satr
gen z_ls = (satr-r(mean))/r(sd)
quietly summ shlt
gen z_srh = (shlt-r(mean))/r(sd)
gen partnered = inlist(mstath,1,2,3) if !missing(mstath)
gen lninc = asinh(itot)
egen chronic = rowtotal(hibpe diabe cancre hearte stroke arthre)
egen chrnm = rownonmiss(hibpe diabe cancre hearte stroke arthre)
replace chronic = . if chrnm==0
gen adl = adltot6
gen iadl = iadlfour
di "######## MHAS 满意度 M1 ########"
xtreg z_ls i.care i.partnered c.hhres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store M_ls
di "######## MHAS 自评健康 M1 ########"
xtreg z_srh i.care i.partnered c.hhres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store M_srh

*========================= KLoSA(仅自评健康)=========================*
use "d:/跨国数据/跨国数据/KLoSA_韩国/Working_data/klosa.dta", clear
merge 1:1 pid wave using "$T/klosa_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(pid)
egen wavenum=group(wave)
xtset id wavenum
quietly summ shlt
gen z_srh = (shlt-r(mean))/r(sd)
gen partnered = inlist(mstath,1,2,3) if !missing(mstath)
gen lninc = asinh(itothhinc)
egen chronic = rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
egen chrnm = rownonmiss(hibpe diabe cancre lunge hearte stroke arthre psyche)
replace chronic = . if chrnm==0
egen adl = rowtotal(dressb bathb eatb toiltb bedb_k)
egen adlnm = rownonmiss(dressb bathb eatb toiltb bedb_k)
replace adl = . if adlnm<5
egen iadl = rowtotal(mealsb shopb medsb moneyb phoneb)
egen iadlnm = rownonmiss(mealsb shopb medsb moneyb phoneb)
replace iadl = . if iadlnm<5
di "######## KLoSA 自评健康 M1 ########"
xtreg z_srh i.care i.partnered c.hres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store K_srh

di "===== 新结局汇总(care 系数,M1;高=好)====="
estimates table C_ls E_ls H_ls S_ls M_ls, b(%9.4f) se(%9.4f) p(%9.3f) keep(1.care) stats(N N_g)
estimates table C_srh E_srh H_srh S_srh M_srh K_srh, b(%9.4f) se(%9.4f) p(%9.3f) keep(1.care) stats(N N_g)
