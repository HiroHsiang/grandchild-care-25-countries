*==============================================================================*
* A 题 · 成文描述统计(2026-09-08)
*   输出(Temp/):
*     desc_table1.dta   队列层 Table 1:人数/人次/首访年龄性别教育有偶在业/带孙率/每人波数
*     desc_flow.dta     流程图计数:各排除步骤后的人次与人数
*     desc_bywave.dta   各队列各波带孙比例 + 平均访谈年
*     desc_outcome.dta  队列层各结局 M1 的 N 人次/N 人/状态改变者(与 12 号同规格)
*     desc_ageslope.dta 认知 z 分的年龄斜率(个体内 FE 无波次哑变量;横断面)→ 效应量年龄等价
*   用法:global COH <cohort>; do 本文件(驱动 run_desc_all.do 顺序跑六个)
*==============================================================================*
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"

capture program drop mkmob
program define mkmob
    egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
    egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
    replace mob=. if mob_nm<6
    quietly summ mob
    gen z_mob=(mob-r(mean))/r(sd)
end

capture program drop flowpost
program define flowpost
    args unit step
    quietly count
    local n=r(N)
    quietly capture drop _tag
    quietly bysort id: gen _tag=_n==1
    quietly count if _tag
    post fl ("`unit'") ("`step'") (`n') (r(N))
    drop _tag
end

capture program drop rundesc
program define rundesc
    args unit
    * ---- 年份变量 ----
    local yv ""
    foreach v in iwy iwindy iwendy iwyear r_iwy {
        capture confirm variable `v'
        if !_rc & "`yv'"=="" local yv "`v'"
    }
    * ---- 流程:当前数据已过年龄与孙辈限定;记 care 非缺 ----
    flowpost "`unit'" "3_care_nonmissing"
    keep if !missing(care)
    flowpost "`unit'" "4_analytic"
    * ---- Table 1(首个分析波,人级)----
    preserve
    bysort id (wavenum): keep if _n==1
    quietly count
    local np=r(N)
    quietly summ $agev
    local agem=r(mean)
    local agesd=r(sd)
    capture confirm variable ragender
    if !_rc {
        * ragender: 0=女 1=男(与 19_sex_stratified.do 一致)
        quietly count if ragender==0
        local fem = r(N)/`np'
    }
    else local fem=.
    capture confirm variable raeducl
    if !_rc {
        quietly count if raeducl==1
        local edlow=r(N)/`np'
    }
    else local edlow=.
    quietly summ partnered
    local part=r(mean)
    quietly summ work
    local wk=r(mean)
    quietly summ care
    local carep=r(mean)
    restore
    quietly count
    local nobs=r(N)
    quietly summ care
    local careobs=r(mean)
    quietly bysort id: egen _sdc=sd(care)
    quietly bysort id: gen _t1=_n==1
    quietly count if _t1 & _sdc>0 & !missing(_sdc)
    local chg=r(N)
    post t1 ("`unit'") (`np') (`nobs') (`nobs'/`np') (`agem') (`agesd') (`fem') (`edlow') (`part') (`wk') (`carep') (`careobs') (`chg')
    drop _sdc _t1
    * ---- 各波带孙比例 ----
    quietly levelsof wavenum, local(ws)
    foreach w of local ws {
        quietly summ care if wavenum==`w'
        local cp=r(mean)
        local cn=r(N)
        local yr=.
        if "`yv'"!="" {
            quietly summ `yv' if wavenum==`w'
            local yr=r(mean)
        }
        post bw ("`unit'") (`w') (`yr') (`cp') (`cn')
    }
    * ---- 各结局 M1:N 人次/N 人/changers ----
    foreach y in cog dep mob ls srh mmse {
        capture confirm variable z_`y'
        if _rc continue
        local cvy = cond("`y'"=="mob", "$cvm", "$cv")
        quietly capture xtreg z_`y' i.care `cvy' i.wavenum, fe vce(cluster id)
        if _rc continue
        quietly gen _s=e(sample)
        quietly bysort id: egen _sdc=sd(care) if _s
        quietly bysort id: egen _t1=min(cond(_s,_n,.))
        quietly count if _s & _sdc>0 & !missing(_sdc)
        local chg_obs=r(N)
        quietly bysort id _s: gen _f=_n==1 if _s
        quietly count if _f==1 & _sdc>0 & !missing(_sdc)
        post oc ("`unit'") ("`y'") (e(N)) (e(N_g)) (r(N))
        drop _s _sdc _t1 _f
    }
    * ---- 认知年龄斜率 ----
    quietly capture xtreg z_cog $agev, fe vce(cluster id)
    if !_rc {
        local bw_=_b[$agev]
        local sw_=_se[$agev]
    }
    else {
        local bw_=.
        local sw_=.
    }
    quietly capture reg z_cog $agev, vce(cluster id)
    if !_rc {
        local bc_=_b[$agev]
        local sc_=_se[$agev]
    }
    else {
        local bc_=.
        local sc_=.
    }
    post ag ("`unit'") (`bw_') (`sw_') (`bc_') (`sc_')
    * ---- 纳入波次-年份 ----
    if "`yv'"!="" {
        quietly levelsof wavenum, local(ws)
        foreach w of local ws {
            quietly summ `yv' if wavenum==`w'
            post wv ("`unit'") (`w') (r(min)) (r(max))
        }
    }
end

capture postclose t1
capture postclose fl
capture postclose bw
capture postclose oc
capture postclose ag
capture postclose wv
postfile t1 str20 unit long(n_persons n_obs) double(obs_per_person age_mean age_sd female edu_low partnered working care_first care_obs) long changers using "$T/desc_table1_$COH.dta", replace
postfile fl str20 unit str24 step long(n_obs n_persons) using "$T/desc_flow_$COH.dta", replace
postfile bw str20 unit int wavenum double(year care_share) long n using "$T/desc_bywave_$COH.dta", replace
postfile oc str20 unit str5 outc long(n_obs n_persons changers) using "$T/desc_outcome_$COH.dta", replace
postfile ag str20 unit double(b_within se_within b_cross se_cross) using "$T/desc_ageslope_$COH.dta", replace
postfile wv str20 unit int wavenum double(year_min year_max) using "$T/desc_waves_$COH.dta", replace

*===== CHARLS =====*
if "$COH"=="charls" {
    use "d:/跨国数据/跨国数据/CHARLS_中国/Working_data/charls_260525.dta", clear
    merge 1:1 ID wave using "$T/charls_a1.dta", keep(master match) nogen
    egen id=group(ID)
    flowpost "China" "0_all"
    keep if age>=50 & age<=105 & !missing(age)
    flowpost "China" "1_age50plus"
    flowpost "China" "2_has_grandchild"
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
    rundesc China
}

*===== ELSA =====*
if "$COH"=="elsa" {
    use "d:/跨国数据/跨国数据/ELSA_英国/Working_data/elsa.dta", clear
    merge 1:1 idauniqc wave using "$T/elsa_a1.dta", keep(master match) nogen
    egen id=group(idauniqc)
    flowpost "England" "0_all"
    keep if agey>=50 & agey<=105 & !missing(agey)
    flowpost "England" "1_age50plus"
    keep if ngk>0 & !missing(ngk)
    flowpost "England" "2_has_grandchild"
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
    rundesc England
}

*===== HRS =====*
if "$COH"=="hrs" {
    use "d:/跨国数据/跨国数据/HRS_美国/Working_data/hrs.dta", clear
    merge 1:1 hhidpn wave using "$T/hrs_a1.dta", keep(master match) nogen
    egen id=group(hhidpn)
    flowpost "United States" "0_all"
    keep if ragey_e>=50 & ragey_e<=105 & !missing(ragey_e)
    flowpost "United States" "1_age50plus"
    keep if ngk>0 & !missing(ngk)
    flowpost "United States" "2_has_grandchild"
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
    rundesc "United States"
}

*===== MHAS =====*
if "$COH"=="mhas" {
    use "d:/跨国数据/跨国数据/MHAS_墨西哥/Working_data/mhas.dta", clear
    merge 1:1 rahhidnp wave using "$T/mhas_a1.dta", keep(master match) nogen
    egen id=group(rahhidnp)
    flowpost "Mexico" "0_all"
    keep if agey>=50 & agey<=105 & !missing(agey)
    flowpost "Mexico" "1_age50plus"
    keep if ngk>0 & !missing(ngk)
    flowpost "Mexico" "2_has_grandchild"
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
    rundesc Mexico
}

*===== KLoSA =====*
if "$COH"=="klosa" {
    use "d:/跨国数据/跨国数据/KLoSA_韩国/Working_data/klosa.dta", clear
    merge 1:1 pid wave using "$T/klosa_a1.dta", keep(master match) nogen
    egen id=group(pid)
    flowpost "South Korea" "0_all"
    keep if agey>=50 & agey<=105 & !missing(agey)
    flowpost "South Korea" "1_age50plus"
    keep if ngk>0 & !missing(ngk)
    flowpost "South Korea" "2_has_grandchild"
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
    rundesc "South Korea"
}

*===== SHARE(队列层 + 逐国 Table1/bywave)=====*
if "$COH"=="share" {
    use "d:/跨国数据/跨国数据/SHARE_欧洲/Working_data/share.dta", clear
    merge 1:1 mergeid wave using "$T/share_a1.dta", keep(master match) nogen
    egen id=group(mergeid)
    flowpost "SHARE" "0_all"
    keep if agey>=50 & agey<=105 & !missing(agey)
    flowpost "SHARE" "1_age50plus"
    keep if ngk>0 & !missing(ngk)
    flowpost "SHARE" "2_has_grandchild"
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
    preserve
    rundesc SHARE
    restore
    quietly levelsof country, local(cids)
    foreach c of local cids {
        quietly count if country==`c' & !missing(care)
        local nc=r(N)
        local en ""
        foreach pair in "11 Austria" "12 Germany" "13 Sweden" "14 Netherlands" "15 Spain" "16 Italy" "17 France" "18 Denmark" "19 Greece" "20 Switzerland" "23 Belgium" "25 Israel" "28 Czechia" "29 Poland" "31 Luxembourg" "32 Hungary" "33 Portugal" "34 Slovenia" "35 Estonia" "47 Croatia" {
            tokenize `pair'
            if `c'==`1' local en "`2'"
        }
        if "`en'"=="" local en "c`c'"
        * 小国也记流程与人数(供"覆盖 28 国"口径)
        preserve
        quietly keep if country==`c'
        flowpost "`en'" "2_has_grandchild"
        if `nc' >= 1500 {
            capture noisily rundesc "`en'"
        }
        else {
            keep if !missing(care)
            flowpost "`en'" "4_analytic_small"
        }
        restore
    }
}
postclose t1
postclose fl
postclose bw
postclose oc
postclose ag
postclose wv
di _n "===== $COH 描述统计完成 ====="
