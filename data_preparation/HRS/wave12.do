
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
use "$raw_data/2014 HRS/H14A_R.dta",clear
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14B_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14C_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14D_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14F_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14G_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14I_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14IO_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14J_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14K_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14L_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14LB_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14M1_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14M2_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14N_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14P_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14PR_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14RC_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14S_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14T_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14TN_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14V_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14W_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2014 HRS/H14Y_R.dta",nogen nolabel
merge m:1 HHID OSUBHH using "$raw_data/2014 HRS/H14A_H.dta",nogen nolabel
merge m:1 HHID OSUBHH using "$raw_data/2014 HRS/H14E_H.dta",nogen nolabel
merge m:1 HHID OSUBHH using "$raw_data/2014 HRS/H14H_H.dta",nogen nolabel
merge m:1 HHID OSUBHH using "$raw_data/2014 HRS/H14IO_H.dta",nogen nolabel
merge m:1 HHID OSUBHH using "$raw_data/2014 HRS/H14PR_H.dta",nogen nolabel
merge m:1 HHID OSUBHH using "$raw_data/2014 HRS/H14U_H.dta",nogen nolabel
merge m:1 HHID OSUBHH using "$raw_data/2014 HRS/H14Q_H.dta",nogen nolabel
merge m:1 HHID OSUBHH using "$raw_data/2014 HRS/H14R_H.dta",nogen nolabel
save "$temp_data/hrs_wave12.dta",replace //保存单独的临时数据集
*/
********************************************************************************

use "$raw_data/2014 RAND HRS Fat File/h14f2b_CN.dta",clear
*****与子女至少每月联系一次
gen r12cntc=.
replace r12cntc=0 if olb006==5 
replace r12cntc=1 if inlist(olb008a,1,2,3) | inlist(olb008b,1,2,3) | inlist(olb008c,1,2,3) | inlist(olb008d,1,2,3) 
replace r12cntc=0 if inlist(olb008a,4,5,6) & inlist(olb008b,4,5,6) & inlist(olb008c,4,5,6) & inlist(olb008d,4,5,6) 

*****与亲戚至少每月联系一次
gen r12cntr=.
replace r12cntr=0 if olb010==5 
replace r12cntr=1 if inlist(olb012a,1,2,3) | inlist(olb012b,1,2,3) | inlist(olb012c,1,2,3) | inlist(olb012d,1,2,3) 
replace r12cntr=0 if inlist(olb012a,4,5,6) & inlist(olb012b,4,5,6) & inlist(olb012c,4,5,6) & inlist(olb012d,4,5,6) 

*****与朋友至少每月联系一次
gen r12cntf=.
replace r12cntf=0 if olb014==5 
replace r12cntf=1 if inlist(olb016a,1,2,3) | inlist(olb016b,1,2,3) | inlist(olb016c,1,2,3) | inlist(olb016d,1,2,3) 
replace r12cntf=0 if inlist(olb016a,4,5,6) & inlist(olb016b,4,5,6) & inlist(olb016c,4,5,6) & inlist(olb016d,4,5,6)

*****是否有爱好
recode olb001r (1/5=1) (6/7=0),gen(r12hobby)

*****各种社会活动
rename (olb001a olb001b olb001c olb001d olb001e olb001f olb001g olb001h ///
olb001i olb001j olb001k olb001l olb001m olb001n olb001o olb001p olb001q ///
olb001r olb001s olb001t) (r12care_adult r12with_grand r12volunteer r12charity ///
r12education r12club r12nonreligious r12pray r12read r12watch_tel r12word_game ///
r12play_card r12writing r12use_computer r12gardening r12bake r12sew r12do_hobby ///
r12exercize r12walk)

*****过去12个月志愿者服务
recode og086 (1=1) (5=0) (else=.),gen(r12vol)

*****志愿服务时间区间
gen r12hour_vol=.
replace r12hour_vol=1 if og195==1
replace r12hour_vol=2 if og195==3 | (og195==5 & og196==1)
replace r12hour_vol=3 if og195==5 & (og196==3 | og196==5)
replace r12hour_vol=0 if og086==5

*****是否有子女居住在10英里内
recode oe012 (1=1) (5=0) (else=.),gen(r12away_child)

keep hhid pn r12cntc r12cntr r12cntf r12hobby r12care_adult r12with_grand ///
r12volunteer r12charity r12education r12club r12nonreligious r12pray r12read ///
r12watch_tel r12word_game r12play_card r12writing r12use_computer r12gardening ///
r12bake r12sew r12do_hobby r12exercize r12walk r12vol r12hour_vol r12away_child

save "$temp_data/hrs_wave12_temp.dta",replace