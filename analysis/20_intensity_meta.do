*==============================================================================*
* A 题 · 敏感性3:强度亚组逐国 → 两系数 meta(低中 vs 不带;重度 vs 不带)
*   单元:CHARLS / HRS / MHAS / ELSA(W8-9) + SHARE 拆国(care3 非缺 N>=1500)
*   结局:cog dep ls(有故事的三个);REML+KH
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
capture postclose im
postfile im str20 clab str5 outc double(b1 se1 b2 se2) long n ///
    using "$T/intensity_meta_input.dta", replace

capture program drop runint2
program define runint2
    args tag
    foreach y in cog dep ls srh {
        capture confirm variable z_`y'
        if _rc continue
        quietly capture xtreg z_`y' i.care3 $cv i.wavenum, fe vce(cluster id)
        if _rc==0 {
            capture post im ("`tag'") ("`y'") (_b[1.care3]) (_se[1.care3]) (_b[2.care3]) (_se[2.care3]) (e(N))
        }
    }
    capture confirm variable z_mob
    if _rc==0 {
        quietly capture xtreg z_mob i.care3 $cvm i.wavenum, fe vce(cluster id)
        if _rc==0 {
            capture post im ("`tag'") ("mob") (_b[1.care3]) (_se[1.care3]) (_b[2.care3]) (_se[2.care3]) (e(N))
        }
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
gen satc=satlife
replace satc=. if satlife==6
quietly summ satc
gen z_ls=(satc-r(mean))/r(sd)
egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob=. if mob_nm<6
quietly summ mob
gen z_mob=(mob-r(mean))/r(sd)
quietly summ srh
gen z_srh=(srh-r(mean))/r(sd)
gen partnered=inlist(marry,1,2,3) if !missing(marry)
gen lninc=ln(income_total+1)
gen adl=adlab_c
gen hhsize=family_size
gen chronic=chronic_num
global cv  "partnered hhsize work lninc own chronic adl iadl"
global cvm "partnered hhsize work lninc own chronic"
runint2 China

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
quietly summ satlife_h
gen z_ls=(satlife_h-r(mean))/r(sd)
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
egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob=. if mob_nm<6
quietly summ mob
gen z_mob=(mob-r(mean))/r(sd)
quietly summ shlt
gen z_srh=(shlt-r(mean))/r(sd)
global cv  "partnered hhsize work lninc chronic adl iadl"
global cvm "partnered hhsize work lninc chronic"
runint2 "United States"

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
gen satr=4-satlife_m if inlist(satlife_m,1,2,3)
quietly summ satr
gen z_ls=(satr-r(mean))/r(sd)
gen partnered=inlist(mstath,1,2,3) if !missing(mstath)
gen lninc=asinh(itot)
egen chronic=rowtotal(hibpe diabe cancre hearte stroke arthre)
gen adl=adltot6
gen iadl=iadlfour
gen hhsize=hhres
egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob=. if mob_nm<6
quietly summ mob
gen z_mob=(mob-r(mean))/r(sd)
quietly summ shlt
gen z_srh=(shlt-r(mean))/r(sd)
global cv  "partnered hhsize work lninc own chronic adl iadl"
global cvm "partnered hhsize work lninc own chronic"
runint2 Mexico

*===== ELSA(W8-9) =====*
use "d:/跨国数据/跨国数据/ELSA_英国/Working_data/elsa.dta", clear
merge 1:1 idauniqc wave using "$T/elsa_a1.dta", keep(master match) nogen
merge 1:1 idauniqc wave using "$T/elsa_int.dta", keep(master match) nogen
keep if agey>=50 & agey<=105 & !missing(agey)
keep if ngk>0 & !missing(ngk)
egen id=group(idauniqc)
egen wavenum=group(wave)
xtset id wavenum
quietly summ cesd
gen z_dep=(cesd-r(mean))/r(sd)
quietly summ tr20
gen z_cog=(tr20-r(mean))/r(sd)
quietly summ satlife_e
gen z_ls=(satlife_e-r(mean))/r(sd)
gen partnered=(mstath==1) if !missing(mstath)
gen lninc=asinh(hitot)
egen chronic=rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
gen adl=adltot6
gen iadl=iadltot2_e
gen hhsize=hhhres
egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob=. if mob_nm<6
quietly summ mob
gen z_mob=(mob-r(mean))/r(sd)
quietly summ shlt
gen z_srh=(shlt-r(mean))/r(sd)
global cv  "partnered hhsize work lninc own chronic adl iadl"
global cvm "partnered hhsize work lninc own chronic"
runint2 England

*===== SHARE 拆国 =====*
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
quietly summ satlife
gen z_ls=(satlife-r(mean))/r(sd)
gen partnered=inlist(mstath,1,2,3) if !missing(mstath)
gen lninc=asinh(hhitothhinc)
egen chronic=rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
egen adl=rowtotal(walkra dressa batha eata beda toilta)
egen iadl=rowtotal(phonea medsa moneya shopa mealsa)
gen hhsize=hhres
egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
replace mob=. if mob_nm<6
quietly summ mob
gen z_mob=(mob-r(mean))/r(sd)
quietly summ shlt
gen z_srh=(shlt-r(mean))/r(sd)
global cv  "partnered hhsize work lninc own chronic adl iadl"
global cvm "partnered hhsize work lninc own chronic"
quietly levelsof country, local(cids)
foreach c of local cids {
    quietly count if country==`c' & !missing(care3)
    if r(N) < 1500 continue
    local en ""
    foreach pair in "11 Austria" "12 Germany" "13 Sweden" "14 Netherlands" "15 Spain" "16 Italy" "17 France" "18 Denmark" "19 Greece" "20 Switzerland" "23 Belgium" "25 Israel" "28 Czechia" "29 Poland" "31 Luxembourg" "32 Hungary" "33 Portugal" "34 Slovenia" "35 Estonia" "47 Croatia" {
        tokenize `pair'
        if `c'==`1' local en "`2'"
    }
    if "`en'"=="" local en "c`c'"
    preserve
    quietly keep if country==`c'
    runint2 "`en'"
    restore
}
postclose im

*===== meta:两系数 × 三结局 =====*
use "$T/intensity_meta_input.dta", clear
export delimited using "$T/intensity_meta_input.csv", replace
foreach y in cog dep ls mob srh {
    foreach c in 1 2 {
        local lab = cond(`c'==1,"低中vs不带","重度vs不带")
        preserve
        quietly keep if outc=="`y'" & !missing(se`c') & se`c'>0
        quietly count
        local k=r(N)
        quietly meta set b`c' se`c', studylabel(clab) random(reml) nometashow
        quietly meta summarize, se(khartung)
        di "`y' `lab' : K=`k'  theta=" %8.4f r(theta) "  p=" %6.4f r(p) "  I2=" %5.1f r(I2) "%"
        restore
    }
}
di _n "===== mob 两级 完整合并(供图用) ====="
foreach c in 1 2 {
    preserve
    quietly keep if outc=="mob" & !missing(se`c') & se`c'>0
    quietly meta set b`c' se`c', studylabel(clab) random(reml) nometashow
    meta summarize, se(khartung) predinterval(95) nostudies
    restore
}
