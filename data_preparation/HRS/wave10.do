
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
use "$raw_data/2010 HRS/H10PR_R.dta",clear
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10RC_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10S_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10T_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10TN_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10V_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10W_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10Y_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10A_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10B_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10C_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10D_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10F_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10G_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10I_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10IO_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10J_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10K_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10L_R.dta",nogen nolabel force
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10LB_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10M1_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10M2_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10N_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2010 HRS/H10P_R.dta",nogen nolabel
merge m:1 HHID MSUBHH using "$raw_data/2010 HRS/H10A_H.dta",nogen nolabel
merge m:1 HHID MSUBHH using "$raw_data/2010 HRS/H10U_H.dta",nogen nolabel
merge m:1 HHID MSUBHH using "$raw_data/2010 HRS/H10E_H.dta",nogen nolabel
merge m:1 HHID MSUBHH using "$raw_data/2010 HRS/H10PR_H.dta",nogen nolabel
merge m:1 HHID MSUBHH using "$raw_data/2010 HRS/H10Q_H.dta",nogen nolabel
merge m:1 HHID MSUBHH using "$raw_data/2010 HRS/H10R_H.dta",nogen nolabel
merge m:1 HHID MSUBHH using "$raw_data/2010 HRS/H10H_H.dta",nogen nolabel
save "$temp_data/hrs_wave10.dta",replace //保存单独的临时数据集
*/
********************************************************************************

use "$raw_data/2010 RAND HRS Fat File/hd10f6a_CN.dta",clear
*****与子女至少每月联系一次
gen r10cntc=.
replace r10cntc=0 if mlb007==5 
replace r10cntc=1 if inlist(mlb009a,1,2,3) | inlist(mlb009b,1,2,3) | inlist(mlb009c,1,2,3) 
replace r10cntc=0 if inlist(mlb009a,4,5,6) & inlist(mlb009b,4,5,6) & inlist(mlb009c,4,5,6) 

*****与亲戚至少每月联系一次
gen r10cntr=.
replace r10cntr=0 if mlb011==5 
replace r10cntr=1 if inlist(mlb013a,1,2,3) | inlist(mlb013b,1,2,3) | inlist(mlb013c,1,2,3) 
replace r10cntr=0 if inlist(mlb013a,4,5,6) & inlist(mlb013b,4,5,6) & inlist(mlb013c,4,5,6) 

*****与朋友至少每月联系一次
gen r10cntf=.
replace r10cntf=0 if mlb015==5 
replace r10cntf=1 if inlist(mlb017a,1,2,3) | inlist(mlb017b,1,2,3) | inlist(mlb017c,1,2,3) 
replace r10cntf=0 if inlist(mlb017a,4,5,6) & inlist(mlb017b,4,5,6) & inlist(mlb017c,4,5,6) 

*****是否有爱好
recode mlb001r (1/5=1) (6/7=0),gen(r10hobby)

*****各种社会活动
rename (mlb001a mlb001b mlb001c mlb001d mlb001e mlb001f mlb001g mlb001h ///
mlb001i mlb001j mlb001k mlb001l mlb001m mlb001n mlb001o mlb001p mlb001q ///
mlb001r mlb001s mlb001t) (r10care_adult r10with_grand r10volunteer r10charity ///
r10education r10club r10nonreligious r10pray r10read r10watch_tel r10word_game ///
r10play_card r10writing r10use_computer r10gardening r10bake r10sew r10do_hobby r10exercize r10walk)

*****过去12个月志愿者服务
recode mg086 (1=1) (5=0) (else=.),gen(r10vol)

*****志愿服务时间区间
gen r10hour_vol=.
replace r10hour_vol=1 if mg195==1
replace r10hour_vol=2 if mg195==3 | (mg195==5 & mg196==1)
replace r10hour_vol=3 if mg195==5 & (mg196==3 | mg196==5)
replace r10hour_vol=0 if mg086==5

*****是否有子女居住在10英里内
recode me012 (1=1) (5=0) (else=.),gen(r10away_child)

keep hhid pn r10cntc r10cntr r10cntf r10hobby r10care_adult r10with_grand ///
r10volunteer r10charity r10education r10club r10nonreligious r10pray r10read ///
r10watch_tel r10word_game r10play_card r10writing r10use_computer r10gardening ///
r10bake r10sew r10do_hobby r10exercize r10walk r10vol r10hour_vol r10away_child

save "$temp_data/hrs_wave10_temp.dta",replace

