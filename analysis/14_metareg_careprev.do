*==============================================================================*
* A 题 · meta-regression(moderator 1:各国带孙率,本数据可算)
*   五结局逐一:meta regress careprev(REML+KH);报系数/p/R²/剩余I²
*==============================================================================*
clear all
set more off
import delimited using "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/figures/plotdata_A.csv", clear varnames(1) encoding(utf8)
foreach y in cog dep mob ls srh {
    preserve
    keep clab b`y' se`y' careprev
    rename (b`y' se`y') (b se)
    quietly drop if missing(b) | missing(se)
    quietly meta set b se, studylabel(clab) random(reml) nometashow
    di _n "########## `y' ~ careprev ##########"
    meta regress careprev, se(khartung)
    restore
}
