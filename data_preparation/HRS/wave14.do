
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
use "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18pr_r.dta",clear
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18s_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18t_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18tn_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18v_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18w_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18y_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18a_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18b_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18c_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18d_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18f_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18g_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18i_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18io_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18j_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18j3_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18lb_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18m1_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18m2_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18n_r.dta",nogen nolabel
merge 1:1 hhid pn using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18p_r.dta",nogen nolabel
merge m:1 hhid qsubhh using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18q_h.dta",nogen nolabel
merge m:1 hhid qsubhh using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18r_h.dta",nogen nolabel
merge m:1 hhid qsubhh using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18u_h.dta",nogen nolabel
merge m:1 hhid qsubhh using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18e_h.dta",nogen nolabel
merge m:1 hhid qsubhh using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18pr_h.dta",nogen nolabel
merge m:1 hhid qsubhh using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18io_h.dta",nogen nolabel
merge m:1 hhid qsubhh using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18h_h.dta",nogen nolabel
merge m:1 hhid qsubhh using "$raw_data/2018 HRS/2018 HRS Core/h18sta/h18a_h.dta",nogen nolabel
save "$temp_data/hrs_wave14.dta",replace //保存单独的临时数据集
*/
********************************************************************************

use "$raw_data/2018 RAND HRS Fat File/h18f2b_CN.dta",clear
*****与子女至少每月联系一次
gen r14cntc=.
replace r14cntc=0 if qlb006==5 
replace r14cntc=1 if inlist(qlb008a,1,2,3) | inlist(qlb008b,1,2,3) | inlist(qlb008c,1,2,3) | inlist(qlb008d,1,2,3) 
replace r14cntc=0 if inlist(qlb008a,4,5,6) & inlist(qlb008b,4,5,6) & inlist(qlb008c,4,5,6) & inlist(qlb008d,4,5,6) 

*****与亲戚至少每月联系一次
gen r14cntr=.
replace r14cntr=0 if qlb010==5 
replace r14cntr=1 if inlist(qlb012a,1,2,3) | inlist(qlb012b,1,2,3) | inlist(qlb012c,1,2,3) | inlist(qlb012d,1,2,3) 
replace r14cntr=0 if inlist(qlb012a,4,5,6) & inlist(qlb012b,4,5,6) & inlist(qlb012c,4,5,6) & inlist(qlb012d,4,5,6) 

*****与朋友至少每月联系一次
gen r14cntf=.
replace r14cntf=0 if qlb014==5 
replace r14cntf=1 if inlist(qlb016a,1,2,3) | inlist(qlb016b,1,2,3) | inlist(qlb016c,1,2,3) | inlist(qlb016d,1,2,3)
replace r14cntf=0 if inlist(qlb016a,4,5,6) & inlist(qlb016b,4,5,6) & inlist(qlb016c,4,5,6) & inlist(qlb016d,4,5,6)

*****是否有爱好
recode qlb001r (1/5=1) (6/7=0),gen(r14hobby)

*****各种社会活动
rename (qlb001a qlb001b qlb001c qlb001d qlb001e qlb001f qlb001g qlb001h  ///
qlb001i qlb001j qlb001k qlb001l qlb001m qlb001n qlb001o qlb001p qlb001q  ///
qlb001r qlb001s qlb001t qlb001u) (r14care_adult r14with_grand r14volunteer r14charity ///
r14education r14club r14nonreligious r14pray r14read r14watch_tel r14word_game ///
r14play_card r14writing r14use_computer r14gardening r14bake r14sew r14do_hobby ///
r14exercize r14walk r14art)

*****过去12个月志愿者服务
recode qg086 (1=1) (5=0) (else=.),gen(r14vol)

*****志愿服务时间区间
gen r14hour_vol=.
replace r14hour_vol=1 if qg195==1
replace r14hour_vol=2 if qg195==3 | (qg195==5 & qg196==1)
replace r14hour_vol=3 if qg195==5 & (qg196==3 | qg196==5)
replace r14hour_vol=0 if qg086==5

*****是否有子女居住在10英里内
recode qe012 (1=1) (5=0) (else=.),gen(r14away_child)

keep hhid pn r14cntc r14cntr r14cntf r14hobby r14care_adult r14with_grand ///
r14volunteer r14charity r14education r14club r14nonreligious r14pray r14read ///
r14watch_tel r14word_game r14play_card r14writing r14use_computer r14gardening ///
r14bake r14sew r14do_hobby r14exercize r14walk r14art r14vol r14hour_vol r14away_child

save "$temp_data/hrs_wave14_temp.dta",replace
