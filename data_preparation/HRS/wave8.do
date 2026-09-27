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
use "$raw_data/2006 HRS/H06N_R.dta",clear
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06P_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06PR_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06RC_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06S_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06T_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06TN_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06V_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06W_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06Y_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06A_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06B_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06C_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06D_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06F_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06G_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06I_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06IO_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06J_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06K_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06L_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06LB_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06M0_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06M1_R.dta",nogen nolabel
merge 1:1 HHID PN using "$raw_data/2006 HRS/H06M2_R.dta",nogen nolabel
merge m:1 HHID KSUBHH using "$raw_data/2006 HRS/H06E_H.dta",nogen nolabel
merge m:1 HHID KSUBHH using "$raw_data/2006 HRS/H06IO_H.dta",nogen nolabel
merge m:1 HHID KSUBHH using "$raw_data/2006 HRS/H06H_H.dta",nogen nolabel
merge m:1 HHID KSUBHH using "$raw_data/2006 HRS/H06A_H.dta",nogen nolabel
merge m:1 HHID KSUBHH using "$raw_data/2006 HRS/H06U_H.dta",nogen nolabel
merge m:1 HHID KSUBHH using "$raw_data/2006 HRS/H06Q_H.dta",nogen nolabel
merge m:1 HHID KSUBHH using "$raw_data/2006 HRS/H06R_H.dta",nogen nolabel
merge m:1 HHID KSUBHH using "$raw_data/2006 HRS/H06PR_H.dta",nogen nolabel
save "$temp_data/hrs_wave8.dta",replace //保存单独的临时数据集
*/
********************************************************************************

use "$raw_data/2006 RAND HRS Fat File/h06f4a_CN.dta",clear  //导入数据
*****与子女至少每月联系一次
gen r8cntc=.
replace r8cntc=0 if klb007==5 
replace r8cntc=1 if inlist(klb009a,1,2,3) | inlist(klb009b,1,2,3) | inlist(klb009c,1,2,3) 
replace r8cntc=0 if inlist(klb009a,4,5,6) & inlist(klb009b,4,5,6) & inlist(klb009c,4,5,6) 

*****与亲戚至少每月联系一次
gen r8cntr=.
replace r8cntr=0 if klb011==5 
replace r8cntr=1 if inlist(klb013a,1,2,3) | inlist(klb013b,1,2,3) | inlist(klb013c,1,2,3) 
replace r8cntr=0 if inlist(klb013a,4,5,6) & inlist(klb013b,4,5,6) & inlist(klb013c,4,5,6) 

*****与朋友至少每月联系一次
gen r8cntf=.
replace r8cntf=0 if klb015==5 
replace r8cntf=1 if inlist(klb017a,1,2,3) | inlist(klb017b,1,2,3) | inlist(klb017c,1,2,3) 
replace r8cntf=0 if inlist(klb017a,4,5,6) & inlist(klb017b,4,5,6) & inlist(klb017c,4,5,6) 

*****志愿者服务
recode kg086 (1=1) (5=0) (else=.),gen(r8vol)

*****志愿服务时间区间
gen r8hour_vol=.
replace r8hour_vol=1 if kg195==1
replace r8hour_vol=2 if kg195==3 | (kg195==5 & kg196==1)
replace r8hour_vol=3 if kg195==5 & (kg196==3 | kg196==5)
replace r8hour_vol=0 if kg086==5

*****是否有子女居住在10英里内
recode ke012 (1=1) (5=0) (else=.),gen(r8away_child)

keep hhid pn r8cntc r8cntr r8cntf r8vol r8hour_vol r8away_child
save "$temp_data/hrs_wave8_temp.dta",replace


