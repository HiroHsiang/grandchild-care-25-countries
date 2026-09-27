*==============================================================================*
* A 题 · 全 moderator meta-regression 网格
*   moderator:内生2(careprev coresid3)+ 外部8(gdppc childcare02 flfp idv
*             gini famspend le65f retagew;缺失单元自动缩K)
*   结局:dep(主靶)+ cog mob ls srh;单变量逐个;REML+KH
*==============================================================================*
clear all
set more off
global F "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/figures"

import delimited using "$F/moderators_external.csv", clear varnames(1) encoding(utf8)
tempfile ext
save `ext'
import delimited using "$F/plotdata_A.csv", clear varnames(1) encoding(utf8)
merge 1:1 clab using `ext', nogen
* 量纲整理:GDP 取 log
gen lgdp = ln(gdppc)
tempfile all
save `all'

foreach y in dep cog mob ls srh {
    di _n "########## 结局:`y'(每行:moderator b p R2 K)##########"
    foreach m in careprev coresid3 lgdp childcare02 flfp idv gini famspend le65f retagew {
        use `all', clear
        keep clab b`y' se`y' `m'
        rename (b`y' se`y') (b se)
        quietly drop if missing(b) | missing(se) | missing(`m')
        quietly count
        local k = r(N)
        if `k' < 8 {
            di "  `m' : K=`k' 太少,跳过"
            continue
        }
        quietly meta set b se, studylabel(clab) random(reml) nometashow
        capture quietly meta regress `m', se(khartung)
        if _rc {
            di "  `m' : 失败 rc=" _rc
            continue
        }
        scalar bb = _b[`m']
        scalar ss = _se[`m']
        scalar pp = 2*ttail(e(df_r), abs(bb/ss))
        scalar r2 = e(R2)
        di "  `m' : b=" %9.5f bb "  p=" %6.4f pp "  R2=" %5.1f r2 "%  K=`k'"
    }
}
