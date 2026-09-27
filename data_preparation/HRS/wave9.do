
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
use "$raw_data/2008 HRS/H08A_R.dta",clear
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08B_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08C_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08D_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08F_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08G_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08I_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08IO_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08J_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08K_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08L_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08LB_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08M1_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08M2_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08N_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08P_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08PR_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08RC_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08S_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08T_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08TN_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08V_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08W_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2008 HRS/H08Y_R.dta",nogen nolabel
merge m:1 HHID LSUBHH using "$raw_data/2008 HRS/H08E_H.dta",nogen nolabel
merge m:1 HHID LSUBHH using "$raw_data/2008 HRS/H08H_H.dta",nogen nolabel
merge m:1 HHID LSUBHH using "$raw_data/2008 HRS/H08IO_H.dta",nogen nolabel
merge m:1 HHID LSUBHH using "$raw_data/2008 HRS/H08PR_H.dta",nogen nolabel
merge m:1 HHID LSUBHH using "$raw_data/2008 HRS/H08Q_H.dta",nogen nolabel
merge m:1 HHID LSUBHH using "$raw_data/2008 HRS/H08R_H.dta",nogen nolabel
merge m:1 HHID LSUBHH using "$raw_data/2008 HRS/H08U_H.dta",nogen nolabel
merge m:1 HHID LSUBHH using "$raw_data/2008 HRS/H08A_H.dta",nogen nolabel
save "$temp_data/hrs_wave9.dta",replace //保存单独的临时数据集
*/
********************************************************************************

use "$raw_data/2008 RAND HRS Fat File/h08f3a_CN.dta",clear
*****与子女至少每月联系一次
gen r9cntc=.
replace r9cntc=0 if llb007==5 
replace r9cntc=1 if inlist(llb009a,1,2,3) | inlist(llb009b,1,2,3) | inlist(llb009c,1,2,3) 
replace r9cntc=0 if inlist(llb009a,4,5,6) & inlist(llb009b,4,5,6) & inlist(llb009c,4,5,6) 

*****与亲戚至少每月联系一次
gen r9cntr=.
replace r9cntr=0 if llb011==5 
replace r9cntr=1 if inlist(llb013a,1,2,3) | inlist(llb013b,1,2,3) | inlist(llb013c,1,2,3) 
replace r9cntr=0 if inlist(llb013a,4,5,6) & inlist(llb013b,4,5,6) & inlist(llb013c,4,5,6) 

*****与朋友至少每月联系一次
gen r9cntf=.
replace r9cntf=0 if llb015==5 
replace r9cntf=1 if inlist(llb017a,1,2,3) | inlist(llb017b,1,2,3) | inlist(llb017c,1,2,3) 
replace r9cntf=0 if inlist(llb017a,4,5,6) & inlist(llb017b,4,5,6) & inlist(llb017c,4,5,6) 

*****是否有爱好
recode llb001p (1/5=1) (6=0),gen(r9hobby)

*****社会活动
rename (llb001a llb001b llb001c llb001d llb001e llb001f llb001g llb001h llb001i ///
llb001j llb001k llb001l llb001m llb001n llb001o llb001p llb001q llb001r) ///
(r9care_adult r9volunteer r9charity r9education r9club r9nonreligious r9pray ///
r9read r9word_game r9play_card r9writing r9use_computer r9gardening r9bake ///
r9sew r9do_hobby r9exercize r9walk)

*****志愿者服务
recode lg086 (1=1) (5=0) (else=.),gen(r9vol)

*****志愿服务时间区间
gen r9hour_vol=.
replace r9hour_vol=1 if lg195==1
replace r9hour_vol=2 if lg195==3 | (lg195==5 & lg196==1)
replace r9hour_vol=3 if lg195==5 & (lg196==3 | lg196==5)
replace r9hour_vol=0 if lg086==5

*****是否有子女居住在10英里内
recode le012 (1=1) (5=0) (else=.),gen(r9away_child)

keep hhid pn r9cntc r9cntr r9cntf r9hobby r9care_adult r9volunteer r9charity  ///
r9education r9club r9nonreligious r9pray r9read r9word_game r9play_card ///
r9writing r9use_computer r9gardening r9bake r9sew r9do_hobby r9exercize ///
r9walk r9vol r9hour_vol r9away_child
save "$temp_data/hrs_wave9_temp.dta",replace



