
clear all
set more off
set maxvar 120000
global root= "E:/HRS_美国"
***************************** 注：运行前更改上述路径 ***************************
global dofiles=      "$root/Dofiles"         
global raw_data=     "$root/Raw_data"
global working_data= "$root/Working_data"
global temp_data=    "$root/Temp_data"

cap mkdir "$raw_data"      // 自动创建文件夹
cap mkdir "$temp_data"     // `cap` 命令可让错误的代码继续运行
cap mkdir "$working_data"    
cap mkdir "$dofiles"       // 如果已经创建了这些文件夹，也可以运行

*Summary: 七大老年健康数据库训练营
*Authors: Shawn (微信公众账号丁点帮你 & 顶刊研习社)
*Date Published: August 1, 2024
********************************************************************************
/*
use "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20PR_R.dta",clear
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20S_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20T_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20TN_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20V_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20W_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20Y_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20A_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20B_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20C_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20COV_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20D_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20F_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20G_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20IO_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20J_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20J3_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20LB_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20M1_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20M2_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20N_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20P_R.dta",nogen nolabel
merge m:1 HHID RSUBHH using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20Q_H.dta",nogen nolabel
merge m:1 HHID RSUBHH using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20R_H.dta",nogen nolabel
merge m:1 HHID RSUBHH using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20U_H.dta",nogen nolabel
merge m:1 HHID RSUBHH using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20A_H.dta",nogen nolabel
merge m:1 HHID RSUBHH using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20H_H.dta",nogen nolabel
merge m:1 HHID RSUBHH using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20PR_H.dta",nogen nolabel
merge m:1 HHID RSUBHH using "$raw_data/2020 HRS/2020 HRS Core/h20sta/H20E_H.dta",nogen nolabel
save "$temp_data/hrs_wave15.dta",replace //保存单独的临时数据集
*/
********************************************************************************

use "$raw_data/2020 RAND HRS Fat File/h20f1a_CN.dta",clear
*****与子女至少每月联系一次
gen r15cntc=.
replace r15cntc=0 if rlb006==5 
replace r15cntc=1 if inlist(rlb008a,1,2,3) | inlist(rlb008b,1,2,3) | inlist(rlb008c,1,2,3) | inlist(rlb008d,1,2,3) 
replace r15cntc=0 if inlist(rlb008a,4,5,6) & inlist(rlb008b,4,5,6) & inlist(rlb008c,4,5,6) & inlist(rlb008d,4,5,6) 

*****与亲戚至少每月联系一次
gen r15cntr=.
replace r15cntr=0 if rlb010==5 
replace r15cntr=1 if inlist(rlb012a,1,2,3) | inlist(rlb012b,1,2,3) | inlist(rlb012c,1,2,3) | inlist(rlb012d,1,2,3) 
replace r15cntr=0 if inlist(rlb012a,4,5,6) & inlist(rlb012b,4,5,6) & inlist(rlb012c,4,5,6) & inlist(rlb012d,4,5,6) 

*****与朋友至少每月联系一次
gen r15cntf=.
replace r15cntf=0 if rlb014==5 
replace r15cntf=1 if inlist(rlb016a,1,2,3) | inlist(rlb016b,1,2,3) | inlist(rlb016c,1,2,3) | inlist(rlb016d,1,2,3) 
replace r15cntf=0 if inlist(rlb016a,4,5,6) & inlist(rlb016b,4,5,6) & inlist(rlb016c,4,5,6) & inlist(rlb016d,4,5,6) 


*****是否有爱好
recode rlb001r (1/5=1) (6/7=0),gen(r15hobby)

*****各种社会活动
rename (rlb001a rlb001b rlb001c rlb001d rlb001e rlb001f rlb001g rlb001h rlb001i ///
rlb001j rlb001k rlb001l rlb001m rlb001n rlb001o rlb001p rlb001q rlb001r rlb001s ///
rlb001t rlb001u) (r15care_adult r15with_grand r15volunteer r15charity ///
r15education r15club r15nonreligious r15pray r15read r15watch_tel r15word_game ///
r15play_card r15writing r15use_computer r15gardening r15bake r15sew r15do_hobby ///
r15exercize r15walk r15art)

*****过去12个月志愿者服务
recode rg086 (1=1) (5=0) (else=.),gen(r15vol)

*****志愿服务时间区间
gen r15hour_vol=.
replace r15hour_vol=1 if rg195==1
replace r15hour_vol=2 if rg195==3 | (rg195==5 & rg196==1)
replace r15hour_vol=3 if rg195==5 & (rg196==3 | rg196==5)
replace r15hour_vol=0 if rg086==5

*****是否有子女居住在10英里内
recode re012 (1=1) (5=0) (else=.),gen(r15away_child)

keep hhid pn r15cntc r15cntr r15cntf r15hobby r15care_adult r15with_grand ///
r15volunteer r15charity r15education r15club r15nonreligious r15pray r15read ///
r15watch_tel r15word_game r15play_card r15writing r15use_computer r15gardening ///
r15bake r15sew r15do_hobby r15exercize r15walk r15art r15vol r15hour_vol r15away_child

save "$temp_data/hrs_wave15_temp.dta",replace