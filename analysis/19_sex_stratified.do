*==============================================================================*
* A 题 · 敏感性2:性别分层(6队列 × 5结局 × 祖母/祖父,M1)
*   预期(文献):祖母效应更强。SHARE 合并为一单元。
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
capture postclose sx
postfile sx str10 cohort str5 outc str6 sex double(b se p) long n ///
    using "$T/sex_stratified.dta", replace

capture program drop runsex
program define runsex
    args tag
    * 需已备 female(1=女) z_* 协变量($cv/$cvm) id wavenum
    foreach y in dep cog ls srh {
        capture confirm variable z_`y'
        if _rc continue
        forvalues f=0/1 {
            local sx = cond(`f'==1,"female","male")
            quietly capture xtreg z_`y' i.care $cv i.wavenum if female==`f', fe vce(cluster id)
            if _rc==0 {
                local p = 2*ttail(e(df_r), abs(_b[1.care]/_se[1.care]))
                post sx ("`tag'") ("`y'") ("`sx'") (_b[1.care]) (_se[1.care]) (`p') (e(N))
            }
        }
    }
    capture confirm variable z_mob
    if _rc==0 {
        forvalues f=0/1 {
            local sx = cond(`f'==1,"female","male")
            quietly capture xtreg z_mob i.care $cvm i.wavenum if female==`f', fe vce(cluster id)
            if _rc==0 {
                local p = 2*ttail(e(df_r), abs(_b[1.care]/_se[1.care]))
                post sx ("`tag'") ("mob") ("`sx'") (_b[1.care]) (_se[1.care]) (`p') (e(N))
            }
        }
    }
end

*===== CHARLS =====*
use "d:/跨国数据/跨国数据/CHARLS_中国/Working_data/charls_260525.dta", clear
merge 1:1 ID wave using "$T/charls_a1.dta", keep(master match) nogen
keep if age>=50 & age<=105 & !missing(age)
egen id=group(ID)
egen wavenum=group(wave)
xtset id wavenum
quietly summ cesd10
gen z_dep=(cesd10-r(mean))/r(sd)
quietly summ tr20
gen z_cog=(tr20-r(mean))/r(sd)
egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob=. if mob_nm<6
quietly summ mob
gen z_mob=(mob-r(mean))/r(sd)
gen satc=satlife
replace satc=. if satlife==6
quietly summ satc
gen z_ls=(satc-r(mean))/r(sd)
quietly summ srh
gen z_srh=(srh-r(mean))/r(sd)
gen partnered=inlist(marry,1,2,3) if !missing(marry)
gen lninc=ln(income_total+1)
gen adl=adlab_c
gen hhsize=family_size
gen chronic=chronic_num
gen female=(ragender==0) if !missing(ragender)
global cv  "partnered hhsize work lninc own chronic adl iadl"
global cvm "partnered hhsize work lninc own chronic"
runsex CHARLS

*===== ELSA =====*
use "d:/跨国数据/跨国数据/ELSA_英国/Working_data/elsa.dta", clear
merge 1:1 idauniqc wave using "$T/elsa_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(idauniqc)
egen wavenum=group(wave)
xtset id wavenum
quietly summ cesd
gen z_dep=(cesd-r(mean))/r(sd)
quietly summ tr20
gen z_cog=(tr20-r(mean))/r(sd)
egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob=. if mob_nm<6
quietly summ mob
gen z_mob=(mob-r(mean))/r(sd)
quietly summ satlife_e
gen z_ls=(satlife_e-r(mean))/r(sd)
quietly summ shlt
gen z_srh=(shlt-r(mean))/r(sd)
gen partnered=(mstath==1) if !missing(mstath)
gen lninc=asinh(hitot)
egen chronic=rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
gen adl=adltot6
gen iadl=iadltot2_e
gen hhsize=hhhres
gen female=(ragender==0) if !missing(ragender)
runsex ELSA

*===== HRS =====*
use "d:/跨国数据/跨国数据/HRS_美国/Working_data/hrs.dta", clear
merge 1:1 hhidpn wave using "$T/hrs_a1.dta", keep(master match) nogen
keep if ragey_e>=50 & ragey_e<=105 & !missing(ragey_e)
keep if ngk>0 & !missing(ngk)
egen id=group(hhidpn)
egen wavenum=group(wave)
xtset id wavenum
quietly summ cesd
gen z_dep=(cesd-r(mean))/r(sd)
quietly summ tr20
gen z_cog=(tr20-r(mean))/r(sd)
egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob=. if mob_nm<6
quietly summ mob
gen z_mob=(mob-r(mean))/r(sd)
quietly summ satlife_h
gen z_ls=(satlife_h-r(mean))/r(sd)
quietly summ shlt
gen z_srh=(shlt-r(mean))/r(sd)
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
gen female=(ragender==0) if !missing(ragender)
global cv  "partnered hhsize work lninc chronic adl iadl"
global cvm "partnered hhsize work lninc chronic"
runsex HRS

*===== SHARE(pooled) =====*
use "d:/跨国数据/跨国数据/SHARE_欧洲/Working_data/share.dta", clear
merge 1:1 mergeid wave using "$T/share_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(mergeid)
egen wavenum=group(wave)
xtset id wavenum
quietly summ eurod
gen z_dep=(eurod-r(mean))/r(sd)
quietly summ tr20
gen z_cog=(tr20-r(mean))/r(sd)
egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob=. if mob_nm<6
quietly summ mob
gen z_mob=(mob-r(mean))/r(sd)
quietly summ satlife
gen z_ls=(satlife-r(mean))/r(sd)
quietly summ shlt
gen z_srh=(shlt-r(mean))/r(sd)
gen partnered=inlist(mstath,1,2,3) if !missing(mstath)
gen lninc=asinh(hhitothhinc)
egen chronic=rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
egen adl=rowtotal(walkra dressa batha eata beda toilta)
egen iadl=rowtotal(phonea medsa moneya shopa mealsa)
gen hhsize=hhres
gen female=(ragender==0) if !missing(ragender)
global cv  "partnered hhsize work lninc own chronic adl iadl"
global cvm "partnered hhsize work lninc own chronic"
runsex SHARE

*===== MHAS =====*
use "d:/跨国数据/跨国数据/MHAS_墨西哥/Working_data/mhas.dta", clear
merge 1:1 rahhidnp wave using "$T/mhas_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(rahhidnp)
egen wavenum=group(wave)
xtset id wavenum
quietly summ cesd_m
gen z_dep=(cesd_m-r(mean))/r(sd)
quietly summ tr16
gen z_cog=(tr16-r(mean))/r(sd)
egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob=. if mob_nm<6
quietly summ mob
gen z_mob=(mob-r(mean))/r(sd)
gen satr=4-satlife_m if inlist(satlife_m,1,2,3)
quietly summ satr
gen z_ls=(satr-r(mean))/r(sd)
quietly summ shlt
gen z_srh=(shlt-r(mean))/r(sd)
gen partnered=inlist(mstath,1,2,3) if !missing(mstath)
gen lninc=asinh(itot)
egen chronic=rowtotal(hibpe diabe cancre hearte stroke arthre)
gen adl=adltot6
gen iadl=iadlfour
gen hhsize=hhres
gen female=(ragender==0) if !missing(ragender)
runsex MHAS

*===== KLoSA =====*
use "d:/跨国数据/跨国数据/KLoSA_韩国/Working_data/klosa.dta", clear
merge 1:1 pid wave using "$T/klosa_a1.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(pid)
egen wavenum=group(wave)
xtset id wavenum
quietly summ cesd10a
gen z_dep=(cesd10a-r(mean))/r(sd)
quietly summ cog_total
gen z_cog=(cog_total-r(mean))/r(sd)
quietly summ shlt
gen z_srh=(shlt-r(mean))/r(sd)
gen partnered=inlist(mstath,1,2,3) if !missing(mstath)
gen lninc=asinh(itothhinc)
egen chronic=rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
egen adl=rowtotal(dressb bathb eatb toiltb bedb_k)
egen iadl=rowtotal(mealsb shopb medsb moneyb phoneb)
gen hhsize=hres
gen female=(ragender==0) if !missing(ragender)
runsex KLoSA
postclose sx

use "$T/sex_stratified.dta", clear
gen sig = cond(p<0.05,"*","")
format b se p %8.4f
foreach y in dep cog mob ls srh {
    di _n "########## `y' 性别分层(care 系数) ##########"
    list cohort sex b se p sig n if outc=="`y'", noobs sepby(cohort)
}
