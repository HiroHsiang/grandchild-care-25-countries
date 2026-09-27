
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
use "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_gv_imputations.dta",clear //生成的插补数据
keep if implicat==1
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_cv_r.dta",keep(match) nogen nolabel //个人封面数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_ac.dta",nogen nolabel //活动数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_as.dta",nogen nolabel //资产数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_br.dta",nogen nolabel //行为风险 数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_cf.dta",nogen nolabel //认知功能数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_ch.dta",nogen nolabel //儿童数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_co.dta",nogen nolabel //消费数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_dn.dta",nogen nolabel //人口统计和网络数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_ep.dta",nogen nolabel //就业和养老金数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_ex.dta",nogen nolabel //期望数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_ft.dta",nogen nolabel //财富转移数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_gs.dta",nogen nolabel //握力数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_hc.dta",nogen nolabel //医疗保健数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_hh.dta",nogen nolabel //家庭收入数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_ho.dta",nogen nolabel //住房数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_iv.dta",nogen nolabel //访谈员观察数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_it.dta",nogen nolabel //计算机使用数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_mh.dta",nogen nolabel //心理健康数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_ph.dta",nogen nolabel //身体健康数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_pf.dta",nogen nolabel //峰值流量数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_sp.dta",nogen nolabel //社会支持数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_sn.dta",nogen nolabel //社交网络数据 
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_technical_variables.dta",nogen nolabel //技术变量数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_dropoff.dta",nogen nolabel //Dropoff data
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_gv_health.dta",nogen nolabel //生成的健康数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_gv_housing.dta",nogen nolabel //生成的房屋数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_gv_isced.dta",nogen nolabel //生成的国际教育标准分类数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_gv_weights.dta",nogen nolabel //生成的权重数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_gv_dbs.dta",nogen nolabel //生成的干血斑数据
merge 1:1 mergeid using "$raw_data/Wave 6 Release 9.0.0/sharew6_rel9-0-0_gv_networks.dta",nogen nolabel //生成的社交网络信息数据
save "$temp_data/share_wave6.dta",replace  //保存在临时数据集中

use "E:/SHARE_欧洲/Temp_data/share_wave6_CN.dta",clear 
*sample 1

*****对生活的满意度10分
recode ac012_ (-2 -1=.),gen(r6satlife)

*****幸福感4分
recode ac022_ (-1 -2=.),gen(r6happiness)

***是否有爱好
gen r6hobby=.
replace r6hobby=0 if ac035d1==0 & ac035d4==0 & ac035d5==0 & ac035d7==0 & ac035d8==0 & ac035d9==0 & ac035d10==0
replace r6hobby=1 if ac035d1==1 | ac035d4==1 | ac035d5==1 | ac035d7==1 | ac035d8==1 | ac035d9==1 | ac035d10==1

***过去一年中的活动：做过志愿者或慈善工作
recode ac035d* (-1 -2=.)
gen r6act1=ac035d1 

***过去一年中的活动：参加过教育或培训课程
gen r6act2=ac035d4

***过去一年中的活动：参加过体育、社交或其他类型的俱乐部
gen r6act3=ac035d5

***过去一年中的活动：参与过政治或社区相关的组织
gen r6act5=ac035d7

***过去一年中的活动：阅读书籍、杂志或报纸
gen r6act6=ac035d8

***过去一年中的活动：进行文字或数字游戏（填字游戏/数独等）
gen r6act7=ac035d9

***过去一年中的活动：玩纸牌或棋类游戏，例如国际象棋
gen r6act8=ac035d10

***过去12个月中参与志愿者/慈善工作的频率
recode ac036_* (-1 -2=.) (1=4) (2=3) (3=2) (4=1)
foreach i in 1 4 5 7 8 9 10 {
  replace ac036_`i'=0 if ac035d`i'==0
}

gen r6freq_act1=ac036_1

***过去12个月中参加教育或培训课程的频率
gen r6freq_act2=ac036_4

***过去12个月中参加体育/社交/其他类型俱乐部的频率
gen r6freq_act3=ac036_5

***过去12个月中参与政治/社区相关组织的频率
gen r6freq_act5=ac036_7

***过去12个月内阅读书籍、杂志或报纸的频率
gen r6freq_act6=ac036_8

***过去12个月内玩文字或数字游戏的频率
gen r6freq_act7=ac036_9

***过去12个月内玩纸牌或棋类游戏的频率
gen r6freq_act8=ac036_10

***网络
recode it004_ (1=1) (5=0) (else=.),gen(r6internet)

*****保存特定的变量
keep mergeid r6hobby r6satlife r6happiness r6act1 r6act2 r6act3 r6act5 ///
r6act6 r6act7 r6act8 r6freq_act1 r6freq_act2 r6freq_act3 r6freq_act5 ///
r6freq_act6 r6freq_act7 r6freq_act8 r6internet

save "$temp_data/share_wave6_temp.dta",replace 

