
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
use "$raw_data/2016 HRS/H16LB_R.dta",clear
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16M1_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16M2_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16N_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16P_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16PR_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16S_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16T_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16TN_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16V_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16W_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16Y_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16A_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16B_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16C_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16D_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16F_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16G_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16I_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16IO_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16J_R.dta",npgen nolabel
merge 1:1 HHID PN using "$raw_data/2016 HRS/H16J3_R.dta",npgen nolabel
merge m:1 HHID PSUBHH using "$raw_data/2016 HRS/H16PR_H.dta",npgen nolabel
merge m:1 HHID PSUBHH using "$raw_data/2016 HRS/H16IO_H.dta",npgen nolabel
merge m:1 HHID PSUBHH using "$raw_data/2016 HRS/H16H_H.dta",npgen nolabel
merge m:1 HHID PSUBHH using "$raw_data/2016 HRS/H16A_H.dta",npgen nolabel
merge m:1 HHID PSUBHH using "$raw_data/2016 HRS/H16E_H.dta",npgen nolabel
merge m:1 HHID PSUBHH using "$raw_data/2016 HRS/H16U_H.dta",npgen nolabel
merge m:1 HHID PSUBHH using "$raw_data/2016 HRS/H16Q_H.dta",npgen nolabel
merge m:1 HHID PSUBHH using "$raw_data/2016 HRS/H16R_H.dta",npgen nolabel
save "$temp_data/hrs_wave13.dta",replace //保存单独的临时数据集
*/
********************************************************************************

use "$raw_data/2016 RAND HRS Fat File/h16f2c_CN.dta",clear
*****与子女至少每月联系一次
gen r13cntc=.
replace r13cntc=0 if plb006==5 
replace r13cntc=1 if inlist(plb008a,1,2,3) | inlist(plb008b,1,2,3) | inlist(plb008c,1,2,3) | inlist(plb008d,1,2,3) 
replace r13cntc=0 if inlist(plb008a,4,5,6) & inlist(plb008b,4,5,6) & inlist(plb008c,4,5,6) & inlist(plb008d,4,5,6) 

*****与亲戚至少每月联系一次
gen r13cntr=.
replace r13cntr=0 if plb010==5 
replace r13cntr=1 if inlist(plb012a,1,2,3) | inlist(plb012b,1,2,3) | inlist(plb012c,1,2,3) | inlist(plb012d,1,2,3)
replace r13cntr=0 if inlist(plb012a,4,5,6) & inlist(plb012b,4,5,6) & inlist(plb012c,4,5,6) & inlist(plb012d,4,5,6) 

*****与朋友至少每月联系一次
gen r13cntf=.
replace r13cntf=0 if plb014==5 
replace r13cntf=1 if inlist(plb016a,1,2,3) | inlist(plb016b,1,2,3) | inlist(plb016c,1,2,3) | inlist(plb016d,1,2,3) 
replace r13cntf=0 if inlist(plb016a,4,5,6) & inlist(plb016b,4,5,6) & inlist(plb016c,4,5,6) & inlist(plb016d,4,5,6)

*****是否有爱好
recode plb001r (1/5=1) (6/7=0),gen(r13hobby) 

*****各种社会活动
rename (plb001a plb001b plb001c plb001d plb001e plb001f plb001g plb001h plb001i ///
plb001j plb001k plb001l plb001m plb001n plb001o plb001p plb001q plb001r plb001s ///
plb001t plb001u) (r13care_adult r13with_grand r13volunteer r13charity ///
r13education r13club r13nonreligious r13pray r13read r13watch_tel r13word_game ///
r13play_card r13writing r13use_computer r13gardening r13bake r13sew r13do_hobby ///
r13exercize r13walk r13art)

*****过去12个月志愿者服务
recode pg086 (1=1) (5=0) (else=.),gen(r13vol)

*****志愿服务时间区间
gen r13hour_vol=.
replace r13hour_vol=1 if pg195==1
replace r13hour_vol=2 if pg195==3 | (pg195==5 & pg196==1)
replace r13hour_vol=3 if pg195==5 & (pg196==3 | pg196==5)
replace r13hour_vol=0 if pg086==5

*****是否有子女居住在10英里内
recode pe012 (1=1) (5=0) (else=.),gen(r13away_child)

keep hhid pn r13cntc r13cntr r13cntf r13hobby r13care_adult r13with_grand ///
r13volunteer r13charity r13education r13club r13nonreligious r13pray r13read ///
r13watch_tel r13word_game r13play_card r13writing r13use_computer r13gardening ///
r13bake r13sew r13do_hobby r13exercize r13walk r13art r13vol r13hour_vol r13away_child

save "$temp_data/hrs_wave13_temp.dta",replace