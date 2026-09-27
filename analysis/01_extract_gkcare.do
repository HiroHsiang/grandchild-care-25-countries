*==============================================================================*
* A题 步骤1:从 Gateway Harmonized 文件提取隔代照料变量 → person-wave 长表
* 输出:Temp/gkcare_<cohort>.dta(不改动任何原 working 数据)
*==============================================================================*
clear all
set more off
set maxvar 32767
local out "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
capture mkdir "`out'"

*---------------- ELSA: r1-r9 gkcare1w(上周照料孙辈 0/1) ----------------*
use idauniqc r1gkcare1w r2gkcare1w r3gkcare1w r4gkcare1w r5gkcare1w ///
    r6gkcare1w r7gkcare1w r8gkcare1w r9gkcare1w ///
    using "d:/跨国数据/跨国数据/ELSA_英国/Raw_data/Harmonized ELSA/h_elsa_g3.dta", clear
reshape long r@gkcare1w, i(idauniqc) j(wave)
rename rgkcare1w gkcare
label var gkcare "上周照料孙辈(0/1, harmonized ELSA)"
drop if missing(gkcare)
save "`out'/gkcare_elsa.dta", replace
di "ELSA 提取完成: " _N " person-wave"

*---------------- SHARE: r gkcare(照料孙辈,频率 careg) + gksit ----------------*
use mergeid r1gkcare r2gkcare r4gkcare r5gkcare r6gkcare r7gkcare r8gkcare ///
    r1gksit r2gksit r4gksit r5gksit r6gksit r7gksit r8gksit ///
    using "d:/跨国数据/跨国数据/SHARE_欧洲/Raw_data/Harmonized SHARE/H_SHARE_f2.dta", clear
reshape long r@gkcare r@gksit, i(mergeid) j(wave)
rename rgkcare gkcare_freq
rename rgksit  gksit_freq
label var gkcare_freq "照料孙辈频率(careg, harmonized SHARE)"
label var gksit_freq  "看护孙辈频率(careg, harmonized SHARE)"
drop if missing(gkcare_freq) & missing(gksit_freq)
save "`out'/gkcare_share.dta", replace
di "SHARE 提取完成: " _N " person-wave"

*---------------- HRS: h1-h14 gksit(household 照料孙辈≥100h/2年) ----------------*
use hhidpn h1gksit h2gksit h3gksit h4gksit h5gksit h6gksit h7gksit ///
    h8gksit h9gksit h10gksit h11gksit h12gksit h13gksit h14gksit ///
    using "d:/跨国数据/跨国数据/HRS_美国/Raw_data/Gateway Harmonized HRS/H_HRS_d.dta", clear
reshape long h@gksit, i(hhidpn) j(wave)
rename hgksit gkcare
label var gkcare "照料孙辈>=100h/2年(household, harmonized HRS)"
drop if missing(gkcare)
save "`out'/gkcare_hrs.dta", replace
di "HRS 提取完成: " _N " person-wave"

*---------------- MHAS: h1-h5 gccare_m(照料子女/孙辈≥1h/周)+小时 ----------------*
use rahhidnp h1gccare_m h2gccare_m h3gccare_m h4gccare_m h5gccare_m ///
    h1gccarehr_m h2gccarehr_m h3gccarehr_m h4gccarehr_m h5gccarehr_m ///
    using "d:/跨国数据/跨国数据/MHAS_墨西哥/Raw_data/Harmonized MHAS File/H_MHAS_c2.dta", clear
reshape long h@gccare_m h@gccarehr_m, i(rahhidnp) j(wave)
rename hgccare_m   gkcare
rename hgccarehr_m gkcare_hr
label var gkcare    "照料子女/孙辈>=1h/周(household, harmonized MHAS)"
label var gkcare_hr "照料子女/孙辈小时/年(household, harmonized MHAS)"
drop if missing(gkcare) & missing(gkcare_hr)
save "`out'/gkcare_mhas.dta", replace
di "MHAS 提取完成: " _N " person-wave"

di "===== 全部提取完成 ====="
