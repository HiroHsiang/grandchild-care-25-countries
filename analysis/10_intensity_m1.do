*==============================================================================*
* A 题 · 强度亚组 M1:care3(0不带/1低中/2重度) × 5结局 × 4队列
*   重度=Di Gessa 2016(约每天 或 ≥15h/周);行动能力结局剔除 ADL/IADL
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"

capture program drop runint
program define runint
    args tag
    foreach y in dep cog ls srh {
        capture confirm variable z_`y'
        if _rc continue
        di "===== `tag' `y' ====="
        quietly capture xtreg z_`y' i.care3 $cv i.wavenum, fe vce(cluster id)
        if _rc==0 estimates store I`tag'_`y'
    }
    capture confirm variable z_mob
    if _rc==0 {
        di "===== `tag' mob(无ADL/IADL) ====="
        quietly capture xtreg z_mob i.care3 $cvm i.wavenum, fe vce(cluster id)
        if _rc==0 estimates store I`tag'_mob
    }
end

*===== CHARLS =====*
use "d:/跨国数据/跨国数据/CHARLS_中国/Working_data/charls_260525.dta", clear
merge 1:1 ID wave using "$T/charls_a2.dta", keep(master match) nogen
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
global cv  "partnered hhsize work lninc own chronic adl iadl"
global cvm "partnered hhsize work lninc own chronic"
runint C

*===== SHARE =====*
use "d:/跨国数据/跨国数据/SHARE_欧洲/Working_data/share.dta", clear
merge 1:1 mergeid wave using "$T/share_a2.dta", keep(master match) nogen
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
runint S

*===== HRS =====*
use "d:/跨国数据/跨国数据/HRS_美国/Working_data/hrs.dta", clear
merge 1:1 hhidpn wave using "$T/hrs_a2.dta", keep(master match) nogen
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
global cv  "partnered hhsize work lninc chronic adl iadl"
global cvm "partnered hhsize work lninc chronic"
runint H

*===== MHAS =====*
use "d:/跨国数据/跨国数据/MHAS_墨西哥/Working_data/mhas.dta", clear
merge 1:1 rahhidnp wave using "$T/mhas_a2.dta", keep(master match) nogen
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
global cv  "partnered hhsize work lninc own chronic adl iadl"
global cvm "partnered hhsize work lninc own chronic"
runint M

*===== 汇总 =====*
foreach y in dep cog mob ls srh {
    di _n "########## `y'(1=低中 vs 不带;2=重度 vs 不带) ##########"
    capture noisily estimates table IC_`y' IS_`y' IH_`y' IM_`y', ///
        b(%9.4f) se(%9.4f) p(%9.3f) keep(1.care3 2.care3) stats(N N_g)
}
