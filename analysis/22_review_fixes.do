*==============================================================================*
* A 题 · 审稿复核补跑(2026-09-08 用户批准 1–5 项)
*   用法:global COH charls|elsa|hrs|mhas|klosa|share1|share2  然后 do 本文件
*   每单元(国家)×结局 post 到 Temp/fix_$COH.dta,kind =
*     noinc  : M1 去收入协变量(全队列敏感性,回应中国口径问题)   b se
*     agesq  : M1 + 年龄平方项(个体内可识别;线性年龄被吸收)     b se
*     int    : 三级强度 M1;b=低中 se;b2=重度 se2;bd=重度−低中 sed(lincom)
*     placebo: 队列层 z_y ~ F.care + care + cv;b=fcare se;b2=care se2
*==============================================================================*
set more off
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
capture postclose fx
postfile fx str20 unit str5 outc str8 kind double(b se b2 se2 bd sed) long n ///
    using "$T/fix_$COH.dta", replace

capture program drop runfix
program define runfix
    * 需已备:z_* care [care3] $cv $cvm $agev id wavenum(xtset)
    args unit
    foreach y in cog dep ls srh mob mmse {
        capture confirm variable z_`y'
        if _rc continue
        local cvy = cond("`y'"=="mob", "$cvm", "$cv")
        local cvni : subinstr local cvy "lninc" "", all
        * noinc
        quietly capture xtreg z_`y' i.care `cvni' i.wavenum, fe vce(cluster id)
        if _rc==0 post fx ("`unit'") ("`y'") ("noinc") (_b[1.care]) (_se[1.care]) (.) (.) (.) (.) (e(N))
        * agesq(cog dep mob)
        if inlist("`y'","cog","dep","mob") {
            quietly capture xtreg z_`y' i.care `cvy' c.${agev}#c.${agev} i.wavenum, fe vce(cluster id)
            if _rc==0 post fx ("`unit'") ("`y'") ("agesq") (_b[1.care]) (_se[1.care]) (.) (.) (.) (.) (e(N))
        }
        * intensity + lincom
        capture confirm variable care3
        if _rc==0 {
            quietly capture xtreg z_`y' i.care3 `cvy' i.wavenum, fe vce(cluster id)
            if _rc==0 {
                quietly lincom 2.care3 - 1.care3
                post fx ("`unit'") ("`y'") ("int") (_b[1.care3]) (_se[1.care3]) (_b[2.care3]) (_se[2.care3]) (r(estimate)) (r(se)) (e(N))
            }
        }
    }
end

capture program drop runplacebo
program define runplacebo
    args unit
    capture drop fcare
    gen fcare = F.care
    foreach y in dep mob ls srh cog mmse {
        capture confirm variable z_`y'
        if _rc continue
        local cvy = cond("`y'"=="mob", "$cvm", "$cv")
        quietly capture xtreg z_`y' fcare care `cvy' i.wavenum, fe vce(cluster id)
        if _rc==0 post fx ("`unit'") ("`y'") ("placebo") (_b[fcare]) (_se[fcare]) (_b[care]) (_se[care]) (.) (.) (e(N))
    }
end

capture program drop mkmob
program define mkmob
    egen mob_nm=rownonmiss(chaira climsa stoopa armsa lifta dimea)
    egen mob=rowtotal(chaira climsa stoopa armsa lifta dimea)
    replace mob=. if mob_nm<6
    quietly summ mob
    gen z_mob=(mob-r(mean))/r(sd)
end

*===== CHARLS =====*
if "$COH"=="charls" {
    use "d:/跨国数据/跨国数据/CHARLS_中国/Working_data/charls_260525.dta", clear
    merge 1:1 ID wave using "$T/charls_a1.dta", keep(master match) nogen
    merge 1:1 ID wave using "$T/charls_a2.dta", keep(master match) nogen keepusing(care3)
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
    runfix China
    runplacebo China
}

*===== ELSA =====*
if "$COH"=="elsa" {
    use "d:/跨国数据/跨国数据/ELSA_英国/Working_data/elsa.dta", clear
    merge 1:1 idauniqc wave using "$T/elsa_a1.dta", keep(master match) nogen
    merge 1:1 idauniqc wave using "$T/elsa_int.dta", keep(master match) nogen keepusing(care3)
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
    runfix England
    runplacebo England
}

*===== HRS =====*
if "$COH"=="hrs" {
    use "d:/跨国数据/跨国数据/HRS_美国/Working_data/hrs.dta", clear
    merge 1:1 hhidpn wave using "$T/hrs_a1.dta", keep(master match) nogen
    merge 1:1 hhidpn wave using "$T/hrs_a2.dta", keep(master match) nogen keepusing(care3)
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
    runfix "United States"
    runplacebo "United States"
}

*===== MHAS =====*
if "$COH"=="mhas" {
    use "d:/跨国数据/跨国数据/MHAS_墨西哥/Working_data/mhas.dta", clear
    merge 1:1 rahhidnp wave using "$T/mhas_a1.dta", keep(master match) nogen
    merge 1:1 rahhidnp wave using "$T/mhas_a2.dta", keep(master match) nogen keepusing(care3)
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
    runfix Mexico
    runplacebo Mexico
}

*===== KLoSA(无 care3、无 mob/ls)=====*
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
    runfix "South Korea"
    runplacebo "South Korea"
}

*===== SHARE(拆两半跑;placebo 在 share1 做队列层)=====*
if "$COH"=="share1" | "$COH"=="share2" {
    use "d:/跨国数据/跨国数据/SHARE_欧洲/Working_data/share.dta", clear
    merge 1:1 mergeid wave using "$T/share_a1.dta", keep(master match) nogen
    merge 1:1 mergeid wave using "$T/share_a2.dta", keep(master match) nogen keepusing(care3)
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
    if "$COH"=="share1" runplacebo "SHARE"
    quietly levelsof country, local(cids)
    local i = 0
    foreach c of local cids {
        quietly count if country==`c' & !missing(care)
        if r(N) < 1500 continue
        local ++i
        if "$COH"=="share1" & mod(`i',2)==0 continue
        if "$COH"=="share2" & mod(`i',2)==1 continue
        local cname : label (country) `c'
        preserve
        quietly keep if country==`c'
        runfix "`cname'"
        restore
    }
}
postclose fx
use "$T/fix_$COH.dta", clear
di _n "===== $COH 完成:post 行数 " _N " ====="
tab kind
