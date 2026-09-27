*==============================================================================*
* A 题 · 逐国估计 + 五结局 meta(二值暴露 M1)
*   单元 = SHARE 逐国(估计N≥1500) + 中/英/美/墨/韩
*   每国×结局:z_y ~ care + 协变量 + i.wave(FE, cluster id);post b/se/N
*   meta:REML + Knapp–Hartung;报 pooled θ、I²、τ²
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
capture postclose mp
postfile mp str20 country str5 outc double(b se) long n ///
    using "$T/meta_input_A.dta", replace

capture program drop postone
program define postone
    args cname outc cvlist
    quietly capture xtreg z_`outc' i.care `cvlist' i.wavenum, fe vce(cluster id)
    if _rc==0 {
        post mp ("`cname'") ("`outc'") (_b[1.care]) (_se[1.care]) (e(N))
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
foreach y in dep cog ls srh {
    postone "China" `y' "partnered hhsize work lninc own chronic adl iadl"
}
postone "China" mob "partnered hhsize work lninc own chronic"

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
foreach y in dep cog ls srh {
    postone "England" `y' "partnered hhsize work lninc own chronic adl iadl"
}
postone "England" mob "partnered hhsize work lninc own chronic"

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
foreach y in dep cog ls srh {
    postone "USA" `y' "partnered hhsize work lninc chronic adl iadl"
}
postone "USA" mob "partnered hhsize work lninc chronic"

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
foreach y in dep cog ls srh {
    postone "Mexico" `y' "partnered hhsize work lninc own chronic adl iadl"
}
postone "Mexico" mob "partnered hhsize work lninc own chronic"

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
foreach y in dep cog srh {
    postone "Korea" `y' "partnered hhsize work lninc own chronic adl iadl"
}

*===== SHARE 逐国 =====*
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
quietly levelsof country, local(cids)
foreach c of local cids {
    local cname : label (country) `c'
    quietly count if country==`c' & !missing(care)
    if r(N) < 1500 continue
    preserve
    quietly keep if country==`c'
    foreach y in dep cog ls srh {
        postone "`cname'" `y' "partnered hhsize work lninc own chronic adl iadl"
    }
    postone "`cname'" mob "partnered hhsize work lninc own chronic"
    restore
}
postclose mp

*===== meta:五结局 =====*
use "$T/meta_input_A.dta", clear
export delimited using "$T/meta_input_A.csv", replace
foreach y in dep cog mob ls srh {
    preserve
    quietly keep if outc=="`y'" & !missing(se) & se>0
    quietly count
    local k = r(N)
    quietly meta set b se, studylabel(country) random(reml) nometashow
    quietly meta summarize, se(khartung)
    di "===== `y' : K=`k'  theta=" %7.4f r(theta) "  p=" %6.4f r(p) ///
       "  I2=" %5.1f r(I2) "%  tau=" %6.4f sqrt(r(tau2))
    restore
}
di _n "########## 认知 逐国森林(核心结局) ##########"
preserve
quietly keep if outc=="cog"
quietly meta set b se, studylabel(country) random(reml) nometashow
meta summarize, se(khartung)
restore
