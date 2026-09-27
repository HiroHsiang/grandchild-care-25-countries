*==============================================================================*
* A 题 · 六队列多重插补(MICE)主分析(用户 2026-09-08 批准;先例 Gong 2026 六队列全插补)
*   用法(批处理):global COH charls|elsa|hrs|mhas|klosa|share ; global M 20 ; do 本文件
*   每单元(国家):按 12 号脚本同法建变量 → 有缺失的协变量与结局登记为 imputed
*   → mi impute chained(全部 pmm knn5,含二值;RHS=care 年龄 波次 + 完整协变量)
*   → mi xtset → mi estimate: xtreg z_y i.care cv i.wavenum, fe vce(cluster id)
*   → post b se fmi N 到 Temp/mi_$COH.dta;插补数据落盘 Temp/mi_data_<unit>.dta
*==============================================================================*
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
if "$M"=="" global M 20
capture postclose mp2
postfile mp2 str20 unit str5 outc double(b se fmi) long n ///
    using "$T/mi_$COH.dta", replace

capture program drop mkmob
program define mkmob
    egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
    egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
    replace mob=. if mob_nm<6
    quietly summ mob
    gen z_mob=(mob-r(mean))/r(sd)
end

capture program drop runmi
program define runmi
    args unit
    di _n "########## MICE unit: `unit'  (M=$M) ##########"
    keep if !missing(care) & !missing($agev)
    xtset, clear
    * ---- 保留变量 ----
    local kp "id wavenum care $agev"
    foreach v in partnered hhsize work lninc own chronic adl iadl z_cog z_dep z_mob z_ls z_srh z_mmse {
        capture confirm variable `v'
        if !_rc local kp "`kp' `v'"
    }
    keep `kp'
    * ---- 分类:有缺失 → imputed(连续 pmm / 二值 logit);完整 → regular ----
    local pm ""
    local lg ""
    local rhs "care $agev i.wavenum"
    foreach v in hhsize lninc chronic adl iadl z_cog z_dep z_mob z_ls z_srh z_mmse {
        capture confirm variable `v'
        if _rc continue
        quietly count if missing(`v')
        if r(N)>0 local pm "`pm' `v'"
        else if !inlist("`v'","z_cog","z_dep","z_mob","z_ls","z_srh","z_mmse") local rhs "`rhs' `v'"
    }
    foreach v in partnered work own {
        capture confirm variable `v'
        if _rc continue
        quietly count if missing(`v')
        if r(N)>0 local lg "`lg' `v'"
        else local rhs "`rhs' `v'"
    }
    di "imputed(pmm): `pm'"
    di "imputed(logit): `lg'"
    di "regular RHS: `rhs'"
    mi set flong
    mi register imputed `pm' `lg'
    * 二值变量亦用 PMM(ELSA logit 在观测数据上完全分离 r(430);PMM 自观测值抽取,六队列统一)
    local spec "(pmm, knn(5)) `pm' `lg'"
    mi impute chained `spec' = `rhs', add($M) rseed(20260908) augment dots
    local fn = subinstr("`unit'"," ","_",.)
    save "$T/mi_data_`fn'.dta", replace
    mi xtset id wavenum
    foreach y in cog dep ls srh mob mmse {
        capture confirm variable z_`y'
        if _rc continue
        local cvy = cond("`y'"=="mob", "$cvm", "$cv")
        di _n "===== `unit' · `y' ====="
        capture noisily mi estimate, post dots: xtreg z_`y' i.care `cvy' i.wavenum, fe vce(cluster id)
        if _rc==0 {
            capture scalar fm = e(fmi_max)
            if _rc scalar fm = .
            post mp2 ("`unit'") ("`y'") (_b[1.care]) (_se[1.care]) (fm) (e(N))
        }
        else di "`unit' `y' failed rc=" _rc
    }
end

*===== CHARLS =====*
if "$COH"=="charls" {
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
    mkmob
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
    global agev "age"
    runmi China
}

*===== ELSA =====*
if "$COH"=="elsa" {
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
    mkmob
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
    global cv  "partnered hhsize work lninc own chronic adl iadl"
    global cvm "partnered hhsize work lninc own chronic"
    global agev "agey"
    runmi England
}

*===== HRS =====*
if "$COH"=="hrs" {
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
    mkmob
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
    global agev "ragey_e"
    runmi "United States"
}

*===== MHAS =====*
if "$COH"=="mhas" {
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
    mkmob
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
    global agev "agey"
    runmi Mexico
}

*===== KLoSA =====*
if "$COH"=="klosa" {
    use "d:/跨国数据/跨国数据/KLoSA_韩国/Working_data/klosa.dta", clear
    merge 1:1 pid wave using "$T/klosa_a1.dta", keep(master match) nogen
    keep if agey>=50 & agey<=105 & !missing(agey)
    keep if ngk>0 & !missing(ngk)
    egen id=group(pid)
    egen wavenum=group(wave)
    xtset id wavenum
    quietly summ cesd10a
    gen z_dep=(cesd10a-r(mean))/r(sd)
    * 2026-09-08 用户定:韩国主分析认知=tr6(3词即时+延迟回忆,0-6,与其他队列同构);MMSE-K 总分作敏感性 z_mmse
    quietly summ tr6
    gen z_cog=(tr6-r(mean))/r(sd)
    quietly summ cog_total
    gen z_mmse=(cog_total-r(mean))/r(sd)
    quietly summ shlt
    gen z_srh=(shlt-r(mean))/r(sd)
    gen partnered=inlist(mstath,1,2,3) if !missing(mstath)
    gen lninc=asinh(itothhinc)
    egen chronic=rowtotal(hibpe diabe cancre lunge hearte stroke arthre psyche)
    egen adl=rowtotal(dressb bathb eatb toiltb bedb_k)
    egen iadl=rowtotal(mealsb shopb medsb moneyb phoneb)
    gen hhsize=hres
    global cv  "partnered hhsize work lninc own chronic adl iadl"
    global cvm "partnered hhsize work lninc own chronic"
    global agev "agey"
    runmi "South Korea"
}

*===== SHARE 逐国插补 =====*
if "$COH"=="share" {
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
    mkmob
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
    global cv  "partnered hhsize work lninc own chronic adl iadl"
    global cvm "partnered hhsize work lninc own chronic"
    global agev "agey"
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
        capture noisily runmi "`en'"
        if _rc di "!!! `en' failed rc=" _rc
        restore
    }
}
postclose mp2
use "$T/mi_$COH.dta", clear
di _n "===== $COH MICE 完成:post 行数 " _N " ====="
list, noobs
