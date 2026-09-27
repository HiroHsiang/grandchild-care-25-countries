*==============================================================================*
* A 题 · 墨西哥/SHARE(pooled)/韩国 试点(M1-only × 三结局;KLoSA 无行动能力)
*   M1: z_y ~ care + partnered hhsize work lninc own chronic adl iadl + i.wave
*   行动能力结局剔除 ADL/IADL;样本 50+ 有孙辈(ngk>0)
*   SHARE 本轮 pooled 出总系数作试点;逐国拆分在 meta 阶段
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"

*========================= MHAS =========================*
use "d:/跨国数据/跨国数据/MHAS_墨西哥/Working_data/mhas.dta", clear
merge 1:1 rahhidnp wave using "$T/mhas_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id = group(rahhidnp)
egen wavenum = group(wave)
xtset id wavenum
quietly summ cesd_m
gen z_dep = (cesd_m-r(mean))/r(sd)
quietly summ tr16
gen z_cog = (tr16-r(mean))/r(sd)
egen mob_nm = rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob = rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob = . if mob_nm<6
quietly summ mob
gen z_mob = (mob-r(mean))/r(sd)
gen partnered = inlist(mstath,1,2,3) if !missing(mstath)
gen lninc = asinh(itot)
egen chronic = rowtotal(hibpe diabe cancre hearte stroke arthre)
egen chrnm = rownonmiss(hibpe diabe cancre hearte stroke arthre)
replace chronic = . if chrnm==0
gen adl = adltot6
gen iadl = iadlfour
di "===== MHAS 描述 ====="
summ care ngk agey partnered hhres work lninc own chronic adl iadl if !missing(care)
di "######## MHAS 抑郁 M1 ########"
xtreg z_dep i.care i.partnered c.hhres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store M_dep
di "######## MHAS 认知 M1 ########"
xtreg z_cog i.care i.partnered c.hhres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store M_cog
di "######## MHAS 行动 M1(无ADL/IADL) ########"
xtreg z_mob i.care i.partnered c.hhres i.work c.lninc i.own c.chronic i.wavenum, fe vce(cluster id)
estimates store M_mob

*========================= SHARE(pooled)=========================*
use "d:/跨国数据/跨国数据/SHARE_欧洲/Working_data/share.dta", clear
merge 1:1 mergeid wave using "$T/share_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id = group(mergeid)
egen wavenum = group(wave)
xtset id wavenum
quietly summ eurod
gen z_dep = (eurod-r(mean))/r(sd)
quietly summ tr20
gen z_cog = (tr20-r(mean))/r(sd)
egen mob_nm = rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob = rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob = . if mob_nm<6
quietly summ mob
gen z_mob = (mob-r(mean))/r(sd)
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
di "===== SHARE 描述 ====="
summ care ngk agey partnered hhres work lninc own chronic adl iadl if !missing(care)
di "######## SHARE 抑郁 M1 ########"
xtreg z_dep i.care i.partnered c.hhres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store S_dep
di "######## SHARE 认知 M1 ########"
xtreg z_cog i.care i.partnered c.hhres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store S_cog
di "######## SHARE 行动 M1(无ADL/IADL) ########"
xtreg z_mob i.care i.partnered c.hhres i.work c.lninc i.own c.chronic i.wavenum, fe vce(cluster id)
estimates store S_mob

*========================= KLoSA =========================*
use "d:/跨国数据/跨国数据/KLoSA_韩国/Working_data/klosa.dta", clear
merge 1:1 pid wave using "$T/klosa_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id = group(pid)
egen wavenum = group(wave)
xtset id wavenum
quietly summ cesd10a
gen z_dep = (cesd10a-r(mean))/r(sd)
quietly summ cog_total
gen z_cog = (cog_total-r(mean))/r(sd)
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
di "===== KLoSA 描述 ====="
summ care ngk agey partnered hres work lninc own chronic adl iadl if !missing(care)
di "######## KLoSA 抑郁 M1 ########"
xtreg z_dep i.care i.partnered c.hres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store K_dep
di "######## KLoSA 认知 M1 ########"
xtreg z_cog i.care i.partnered c.hres i.work c.lninc i.own c.chronic c.adl c.iadl i.wavenum, fe vce(cluster id)
estimates store K_cog

di "===== 三队列汇总(care 系数,M1)====="
estimates table M_dep M_cog M_mob S_dep S_cog S_mob K_dep K_cog, ///
    b(%9.4f) se(%9.4f) p(%9.3f) keep(1.care) stats(N N_g)
