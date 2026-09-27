*==============================================================================*
* A 题 · 阶段1 提取:二值带孙暴露 + 孙辈数 + 住房产权(六队列)
*   来源 = Gateway Harmonized 文件;输出 = 人×波 长表 → Temp/
*   阶段2(强度小时/频率,另做):CHARLS cf003 / SHARE sp016 / HRS fat 小时
*   merge 键:CHARLS ID | ELSA idauniqc | SHARE mergeid | HRS hhidpn
*             | MHAS rahhidnp | KLoSA pid
*==============================================================================*
clear all
set more off
set maxvar 32767
global T "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
global D "d:/跨国数据/跨国数据"

*========================= CHARLS(w1–4 = 2011/13/15/18)====================*
use ID h1gkcare h2gkcare h3gkcare h4gkcare hh1ahrto hh2ahrto hh3ahrto h4ahrto ///
    using "$D/CHARLS_中国/Raw_data/Harmonized_CHARLS_D/h_charls_d_data.dta", clear
forvalues w=1/4 {
    gen byte care`w' = h`w'gkcare
    gen byte nogk`w' = (h`w'gkcare==.g)          // .g=无(幼)孙辈 → 样本限定标记
}
gen own1=(hh1ahrto>0) if !missing(hh1ahrto)
gen own2=(hh2ahrto>0) if !missing(hh2ahrto)
gen own3=(hh3ahrto>0) if !missing(hh3ahrto)
gen own4=(h4ahrto>0)  if !missing(h4ahrto)
keep ID care1-care4 nogk1-nogk4 own1-own4
reshape long care nogk own, i(ID) j(wave)
drop if missing(care) & missing(own)
save "$T/charls_a1.dta", replace

*========================= ELSA(w1–9)=====================================*
use idauniqc r1gkcare1w r2gkcare1w r3gkcare1w r4gkcare1w r5gkcare1w r6gkcare1w ///
    r7gkcare1w r8gkcare1w r9gkcare1w ///
    r1grchild_e r2grchild_e r3grchild_e r4grchild_e r5grchild_e r6grchild_e ///
    r7grchild_e r8grchild_e r9grchild_e ///
    r1hownrnt r2hownrnt r3hownrnt r4hownrnt r5hownrnt r6hownrnt r7hownrnt ///
    r8hownrnt r9hownrnt ///
    using "$D/ELSA_英国/Raw_data/Harmonized ELSA/h_elsa_g3.dta", clear
forvalues w=1/9 {
    gen byte care`w' = r`w'gkcare1w
    gen ngk`w'  = r`w'grchild_e
    gen byte own`w'  = (r`w'hownrnt==1) if !missing(r`w'hownrnt)
}
keep idauniqc care1-care9 ngk1-ngk9 own1-own9
reshape long care ngk own, i(idauniqc) j(wave)
drop if missing(care) & missing(ngk) & missing(own)
save "$T/elsa_a1.dta", replace

*========================= SHARE(w1,2,4–8)================================*
use mergeid r1gksit r2gksit r4gksit r5gksit r6gksit r7gksit r8gksit ///
    h1grchild h2grchild h4grchild h5grchild h6grchild h7grchild h8grchild ///
    r1hownrnt r2hownrnt r4hownrnt r5hownrnt r6hownrnt r7hownrnt r8hownrnt ///
    using "$D/SHARE_欧洲/Raw_data/Harmonized SHARE/H_SHARE_f2.dta", clear
foreach w in 1 2 4 5 6 7 8 {
    gen byte care`w' = r`w'gksit
    gen ngk`w'  = h`w'grchild
    gen byte own`w'  = (r`w'hownrnt==1) if !missing(r`w'hownrnt)
}
keep mergeid care* ngk* own*
reshape long care ngk own, i(mergeid) j(wave)
drop if missing(care) & missing(ngk) & missing(own)
save "$T/share_a1.dta", replace

*========================= HRS(w1–14;hownrnt 阶段2 从 fat 提)============*
use hhidpn h1gksit-h14gksit h1grchild h2grchild h3grchild h4grchild h5grchild ///
    h6grchild h7grchild h8grchild h9grchild h10grchild h11grchild h12grchild ///
    h13grchild h14grchild ///
    using "$D/HRS_美国/Raw_data/Gateway Harmonized HRS/H_HRS_d.dta", clear
forvalues w=1/14 {
    gen byte care`w' = h`w'gksit
    gen ngk`w'  = h`w'grchild
}
keep hhidpn care1-care14 ngk1-ngk14
reshape long care ngk, i(hhidpn) j(wave)
drop if missing(care) & missing(ngk)
save "$T/hrs_a1.dta", replace

*========================= MHAS(w1–5;含小时/年)==========================*
use rahhidnp h1gccare_m h2gccare_m h3gccare_m h4gccare_m h5gccare_m ///
    h1gccarehr_m h2gccarehr_m h3gccarehr_m h4gccarehr_m h5gccarehr_m ///
    h1grchild h2grchild h3grchild h4grchild h5grchild ///
    h1hownrnt h2hownrnt h3hownrnt h4hownrnt h5hownrnt ///
    using "$D/MHAS_墨西哥/Raw_data/Harmonized MHAS File/H_MHAS_c2.dta", clear
forvalues w=1/5 {
    gen byte care`w' = h`w'gccare_m
    gen hrs`w'  = h`w'gccarehr_m
    gen ngk`w'  = h`w'grchild
    gen byte own`w'  = (h`w'hownrnt==1) if !missing(h`w'hownrnt)
}
keep rahhidnp care1-care5 hrs1-hrs5 ngk1-ngk5 own1-own5
reshape long care hrs ngk own, i(rahhidnp) j(wave)
drop if missing(care) & missing(ngk) & missing(own)
save "$T/mhas_a1.dta", replace

*========================= KLoSA(w1–8)====================================*
use pid r1gksit r2gksit r3gksit r4gksit r5gksit r6gksit r7gksit r8gksit ///
    h1grchild h2grchild h3grchild h4grchild h5grchild h6grchild h7grchild h8grchild ///
    r1hownrnt r2hownrnt r3hownrnt r4hownrnt r5hownrnt r6hownrnt r7hownrnt r8hownrnt ///
    using "$D/KLoSA_韩国/Raw_data/H_KLoSA/h_klosa_e2.dta", clear
forvalues w=1/8 {
    gen byte care`w' = r`w'gksit
    gen ngk`w'  = h`w'grchild
    gen byte own`w'  = (r`w'hownrnt==1) if !missing(r`w'hownrnt)
}
keep pid care1-care8 ngk1-ngk8 own1-own8
reshape long care ngk own, i(pid) j(wave)
drop if missing(care) & missing(ngk) & missing(own)
save "$T/klosa_a1.dta", replace

*========================= 汇总检查 =========================*
foreach f in charls elsa share hrs mhas klosa {
    use "$T/`f'_a1.dta", clear
    quietly count
    di "`f'_a1: N=" r(N)
    quietly summ care
    di "  care 非缺失=" r(N) "  带孙率=" %5.3f r(mean)
}
