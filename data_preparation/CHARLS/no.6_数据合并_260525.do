*******************************************************************************
* 260525补丁：为最终数据集补充Wave4卒中变量
*
* 问题：原 no.6_数据合并.do 在 keep 列表中遗漏了 r4stroke，
*        且 no.4_charls_18.do 未从 da007_8_ 生成 r4stroke，
*        导致 charls.dta 中 wave4（2018年）的 stroke 变量全部缺失（19,816条）。
*        实际原始数据中 wave4 有 974 例卒中、18,322 例非卒中。
*
* 运行顺序：
*   1. 先运行 no.6_数据合并.do（生成原始 charls.dta）
*   2. 再运行本文件（直接读取2018年原始数据，无需其他前置脚本）
*
* 输出文件：Working_data/charls_260525.dta
*        与 charls.dta 完全相同，仅 wave4 的 stroke 变量由全缺失→有效值
*******************************************************************************

clear all
set more off
global root= "d:\跨国数据\跨国数据\CHARLS_中国"
***************************** 注：运行前更改上述路径 ***************************
global raw_data=     "$root\Raw_data"
global working_data= "$root\Working_data"

********************************************************************************
* 第一步：从2018年原始数据直接提取卒中变量，存为临时文件
* da007_8_ = "Diagnosed with Stroke by a Doctor"，1=Yes 2=No
********************************************************************************
use "$raw_data/2018charls/Health_Status_and_Functioning.dta", clear
keep ID da007_8_
recode da007_8_ (1=1) (2=0) (else=.), gen(stroke_w4_fix)
drop da007_8_
tempfile stroke_w4
save `stroke_w4'

********************************************************************************
* 第二步：载入 charls.dta，合并wave4卒中数据
********************************************************************************
use "$working_data/charls.dta", clear

* m:1 合并：charls.dta 为长格式（多行/人），Health_Status 为宽格式（1行/人）
merge m:1 ID using `stroke_w4', keep(1 3) nogen

********************************************************************************
* 第三步：仅对wave4填充缺失的stroke
* 编码与其他波次一致：0=否 1=是（yesno_标签）
********************************************************************************
replace stroke = stroke_w4_fix if wave == 4 & mi(stroke) & !mi(stroke_w4_fix)

capture label define yesno_ 0 "否" 1 "是", modify
label values stroke yesno_

drop stroke_w4_fix

********************************************************************************
* 第四步：更新 chronic_num（wave4 的慢性病总数之前因stroke缺失而偏低1）
* 仅对 stroke 有效且 chronic_num 非缺失的 wave4 行加1
********************************************************************************
replace chronic_num = chronic_num + stroke ///
    if wave == 4 & !mi(stroke) & !mi(chronic_num)

********************************************************************************
* 第五步：另存，不覆盖原始 charls.dta
********************************************************************************
save "$working_data/charls_260525.dta", replace

********************************************************************************
* 验证
********************************************************************************
di ""
di "===== 260525 补丁验证 ====="
di "输出文件：$working_data/charls_260525.dta"
di ""
di "各波次 stroke 分布（含缺失）："
tab wave stroke, missing
di ""
count if wave == 4 & stroke == 1
di "Wave4 stroke=1（卒中）：" r(N)
count if wave == 4 & stroke == 0
di "Wave4 stroke=0（无卒中）：" r(N)
count if wave == 4 & mi(stroke)
di "Wave4 stroke 仍缺失（原始问卷无应答）：" r(N)
