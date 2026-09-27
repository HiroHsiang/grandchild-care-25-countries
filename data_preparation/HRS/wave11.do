
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
use "$raw_data/2012 HRS/H12A_R.dta",clear
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12B_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12C_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12D_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12F_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12G_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12I_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12IO_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12K_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12L_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12LB_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12M1_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12M2_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12N_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12P_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12PR_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12RC_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12S_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12T_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12TN_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12TN_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12V_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12W_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2012 HRS/H12Y_R.dta",nogen nolabel
merge m:1 HHID NSUBHH using "$raw_data/2012 HRS/H12A_H.dta",nogen nolabel
merge m:1 HHID NSUBHH using "$raw_data/2012 HRS/H12H_H.dta",nogen nolabel
merge m:1 HHID NSUBHH using "$raw_data/2012 HRS/H12E_H.dta",nogen nolabel
merge m:1 HHID NSUBHH using "$raw_data/2012 HRS/H12IO_H.dta",nogen nolabel
merge m:1 HHID NSUBHH using "$raw_data/2012 HRS/H12PR_H.dta",nogen nolabel
merge m:1 HHID NSUBHH using "$raw_data/2012 HRS/H12Q_H.dta",nogen nolabel
merge m:1 HHID NSUBHH using "$raw_data/2012 HRS/H12R_H.dta",nogen nolabel
merge m:1 HHID NSUBHH using "$raw_data/2012 HRS/H12U_H.dta",nogen nolabel
save "$temp_data/hrs_wave11.dta",replace //保存单独的临时数据集
*/
********************************************************************************

use "$raw_data/2012 RAND HRS Fat File/h12f3a_CN.dta",clear
*****与子女至少每月联系一次
gen r11cntc=.
replace r11cntc=0 if nlb007==5 
replace r11cntc=1 if inlist(nlb009a,1,2,3) | inlist(nlb009b,1,2,3) | inlist(nlb009c,1,2,3) 
replace r11cntc=0 if inlist(nlb009a,4,5,6) & inlist(nlb009b,4,5,6) & inlist(nlb009c,4,5,6) 

*****与亲戚至少每月联系一次
gen r11cntr=.
replace r11cntr=0 if nlb011==5 
replace r11cntr=1 if inlist(nlb013a,1,2,3) | inlist(nlb013b,1,2,3) | inlist(nlb013c,1,2,3) 
replace r11cntr=0 if inlist(nlb013a,4,5,6) & inlist(nlb013b,4,5,6) & inlist(nlb013c,4,5,6) 

*****与朋友至少每月联系一次
gen r11cntf=.
replace r11cntf=0 if nlb015==5 
replace r11cntf=1 if inlist(nlb017a,1,2,3) | inlist(nlb017b,1,2,3) | inlist(nlb017c,1,2,3) 
replace r11cntf=0 if inlist(nlb017a,4,5,6) & inlist(nlb017b,4,5,6) & inlist(nlb017c,4,5,6) 

*****是否有爱好
recode nlb001r (1/5=1) (6/7=0),gen(r11hobby)

*****各种社会活动
rename (nlb001a nlb001b nlb001c nlb001d nlb001e nlb001f nlb001g nlb001h ///
nlb001i nlb001j nlb001k nlb001l nlb001m nlb001n nlb001o nlb001p nlb001q ///
nlb001r nlb001s nlb001t) (r11care_adult r11with_grand r11volunteer r11charity ///
r11education r11club r11nonreligious r11pray r11read r11watch_tel r11word_game ///
r11play_card r11writing r11use_computer r11gardening r11bake r11sew r11do_hobby ///
r11exercize r11walk)

*****过去12个月志愿者服务
recode  ng086 (1=1) (5=0) (else=.),gen(r11vol)

*****志愿服务时间区间
gen r11hour_vol=.
replace r11hour_vol=1 if  ng195==1
replace r11hour_vol=2 if  ng195==3 | (ng195==5 & ng196==1)
replace r11hour_vol=3 if  ng195==5 & (ng196==3 | ng196==5)
replace r11hour_vol=0 if  ng086==5

*****是否有子女居住在10英里内
recode ne012 (1=1) (5=0) (else=.),gen(r11away_child)

keep hhid pn r11cntc r11cntr r11cntf r11hobby r11care_adult r11with_grand ///
r11volunteer r11charity r11education r11club r11nonreligious r11pray r11read ///
r11watch_tel r11word_game r11play_card r11writing r11use_computer r11gardening ///
r11bake r11sew r11do_hobby r11exercize r11walk r11vol r11hour_vol r11away_child

save "$temp_data/hrs_wave11_temp.dta",replace