*==============================================================================*
* A 题 · 森林图数据(plotdata_A.csv)
*   每国:5结局 b/se/N/N_g + careprev(带孙率) + changers(care 有个体内变化的人数)
*   末尾打印 cog/dep 的 meta summarize + 95% 预测区间(供 R 硬编码)
*==============================================================================*
clear all
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
capture postclose pd
postfile pd str20 clab str5 outc double(b se) long(n ng) ///
    using "$T/plotdata_long.dta", replace
capture postclose pc
postfile pc str20 clab double careprev long changers ///
    using "$T/plotdata_country.dta", replace

capture program drop postco
program define postco
    args cname outc cvlist
    quietly capture xtreg z_`outc' i.care `cvlist' i.wavenum, fe vce(cluster id)
    if _rc==0 post pd ("`cname'") ("`outc'") (_b[1.care]) (_se[1.care]) (e(N)) (e(N_g))
end
capture program drop postcp
program define postcp
    args cname
    quietly summ care
    local cp = r(mean)
    tempvar mn mx tg
    quietly bysort id: egen `mn' = min(care)
    quietly bysort id: egen `mx' = max(care)
    quietly egen `tg' = tag(id) if `mx'>`mn' & !missing(`mx') & !missing(`mn')
    quietly count if `tg'==1
    post pc ("`cname'") (`cp') (r(N))
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
postcp "China"
foreach y in dep cog ls srh {
    postco "China" `y' "partnered hhsize work lninc own chronic adl iadl"
}
postco "China" mob "partnered hhsize work lninc own chronic"

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
postcp "England"
foreach y in dep cog ls srh {
    postco "England" `y' "partnered hhsize work lninc own chronic adl iadl"
}
postco "England" mob "partnered hhsize work lninc own chronic"

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
postcp "United States"
foreach y in dep cog ls srh {
    postco "United States" `y' "partnered hhsize work lninc chronic adl iadl"
}
postco "United States" mob "partnered hhsize work lninc chronic"

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
postcp "Mexico"
foreach y in dep cog ls srh {
    postco "Mexico" `y' "partnered hhsize work lninc own chronic adl iadl"
}
postco "Mexico" mob "partnered hhsize work lninc own chronic"

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
postcp "South Korea"
foreach y in dep cog srh {
    postco "South Korea" `y' "partnered hhsize work lninc own chronic adl iadl"
}

*===== SHARE 逐国(英文名映射)=====*
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
preserve
clear
input long code str20 en
11 "Austria"
12 "Germany"
13 "Sweden"
14 "Netherlands"
15 "Spain"
16 "Italy"
17 "France"
18 "Denmark"
19 "Greece"
20 "Switzerland"
23 "Belgium"
25 "Israel"
28 "Czechia"
29 "Poland"
31 "Luxembourg"
32 "Hungary"
33 "Portugal"
34 "Slovenia"
35 "Estonia"
47 "Croatia"
end
tempfile enmap
save `enmap'
restore
quietly levelsof country, local(cids)
foreach c of local cids {
    quietly count if country==`c' & !missing(care)
    if r(N) < 1500 continue
    preserve
    quietly keep if country==`c'
    local en ""
    quietly {
        tempvar one
        gen `one'=1 in 1
    }
    * 查英文名
    local en ""
    foreach pair in "11 Austria" "12 Germany" "13 Sweden" "14 Netherlands" "15 Spain" "16 Italy" "17 France" "18 Denmark" "19 Greece" "20 Switzerland" "23 Belgium" "25 Israel" "28 Czechia" "29 Poland" "31 Luxembourg" "32 Hungary" "33 Portugal" "34 Slovenia" "35 Estonia" "47 Croatia" {
        tokenize `pair'
        if `c'==`1' local en "`2'"
    }
    if "`en'"=="" local en "c`c'"
    postcp "`en'"
    foreach y in dep cog ls srh {
        postco "`en'" `y' "partnered hhsize work lninc own chronic adl iadl"
    }
    postco "`en'" mob "partnered hhsize work lninc own chronic"
    restore
}
postclose pd
postclose pc

*===== 组装宽表 =====*
use "$T/plotdata_long.dta", clear
reshape wide b se n ng, i(clab) j(outc) string
merge 1:1 clab using "$T/plotdata_country.dta", nogen
export delimited using "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/figures/plotdata_A.csv", replace

*===== 精确 meta 数(供 R 硬编码)=====*
use "$T/meta_input_A.dta", clear
foreach y in cog dep {
    preserve
    quietly keep if outc=="`y'"
    quietly meta set b se, studylabel(country) random(reml) nometashow
    di "########## `y' ##########"
    meta summarize, se(khartung) predinterval(95) nostudies
    restore
}
