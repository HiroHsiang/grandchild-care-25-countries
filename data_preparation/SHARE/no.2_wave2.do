clear all
set more off
set maxvar 20000
global root= "E:/SHARE_欧洲"

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
use "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_gv_imputations.dta",clear //生成的插补数据
keep if implicat==1
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_cv_r.dta",keep(match) nogen //个人封面数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_ac.dta",nogen //活动数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_as.dta",nogen //资产数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_br.dta",nogen //行为风险 数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_cf.dta",nogen //认知功能数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_ch.dta",nogen //儿童数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_co.dta",nogen //消费数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_dn.dta",nogen //人口统计和网络数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_ep.dta",nogen //就业和养老金数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_ex.dta",nogen //期望数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_ft.dta",nogen //财富转移数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_gs.dta",nogen //握力数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_hc.dta",nogen //医疗保健数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_hh.dta",nogen //家庭收入数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_ho.dta",nogen //住房数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_iv.dta",nogen //访谈员观察数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_mh.dta",nogen //心理健康数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_ph.dta",nogen //身体健康数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_pf.dta",nogen //峰值流量数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_sp.dta",nogen //社会支持数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_ws.dta",nogen //步行速度数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_technical_variables.dta",nogen //技术变量数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_vignettes.dta",nogen //Vignette files数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_dropoff.dta",nogen //Dropoff data
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_gv_health.dta",nogen //生成的健康数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_gv_housing.dta",nogen //生成的房屋数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_gv_isced.dta",nogen //生成的国际教育标准分类数据
merge 1:1 mergeid using "$raw_data/Wave 2 Release 9.0.0/sharew2_rel9-0-0_gv_weights.dta",nogen //生成的权重数据
save "$temp_data/share_wave2.dta",replace  //保存在临时数据集中

use "$temp_data/share_wave2_CN.dta",clear
*sample 1

*****对生活的满意度10分
recode ac012_ (-2 -1=.),gen(r2satlife)

*****幸福感4分
recode ac022_ (-1=.),gen(r2happiness)

***是否有爱好
recode ac002d* (-1 -2=.)  
gen r2hobby=.
replace r2hobby=0 if ac002d1==0 & ac002d4==0 & ac002d5==0 & ac002d7==0
replace r2hobby=1 if ac002d1==1 | ac002d4==1 | ac002d5==1 | ac002d7==1

***上个月的活动：志愿或慈善工作
gen r2act1=ac002d1

***上个月的活动：照顾生病或残疾的成年人
gen r2act2=ac002d2

***上个月的活动：为家人、朋友或邻居提供帮助
gen r2act3=ac002d3

***上个月的活动：参加教育或培训课程
gen r2act4=ac002d4

***上个月的活动：参加体育、社交或其他类型的俱乐部
gen r2act5=ac002d5

***上个月的活动：参加宗教组织
gen r2act6=ac002d6

***上个月的活动：参加政治或社区组织
gen r2act7=ac002d7

***频率/志愿或慈善工作
recode ac003_* (-1 -2=.) (1=3) (2=2) (3=1) 
forvalues i=1/7 {
  replace ac003_`i'=0 if ac002d`i'==0
}
gen r2freq_act1=ac003_1

***频率/照顾生病或残疾的成年人
gen r2freq_act2=ac003_2

***频率/为家人、朋友或邻居提供帮助
gen r2freq_act3=ac003_3

***频率/参加教育或培训课程
gen r2freq_act4=ac003_4

***频率/参加体育、社交或其他类型的俱乐部
gen r2freq_act5=ac003_5

***频率/参加宗教组织
gen r2freq_act6=ac003_6

***频率/参加政治或社区组织
gen r2freq_act7=ac003_7

*****保存特定的变量
keep mergeid r2hobby r2satlife r2happiness r2act1 r2act2 r2act3 r2act4 r2act5 ///
r2act6 r2act7 r2freq_act1 r2freq_act2 r2freq_act3 r2freq_act4 r2freq_act5 r2freq_act6 r2freq_act7

save "$temp_data/share_wave2_temp.dta",replace 
