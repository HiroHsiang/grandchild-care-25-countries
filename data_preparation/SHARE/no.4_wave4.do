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
use "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_gv_imputations.dta",clear
keep if implicat==1  //保留第一条
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_cv_r.dta",keep(match) nogen  //过滤数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_ac.dta",nogen //活动数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_as.dta",nogen  //资产数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_br.dta",nogen  //行为风险 数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_cf.dta",nogen  //认知功能数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_ch.dta",nogen  //儿童数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_co.dta",nogen  //消费数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_dn.dta",nogen  //人口统计和网络数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_ep.dta",nogen  //就业和养老金数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_ex.dta",nogen  //期望数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_ft.dta",nogen  //财富转移数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_gs.dta",nogen  //握力数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_hc.dta",nogen  //医疗保健数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_hh.dta",nogen  //家庭收入数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_ho.dta",nogen //住房数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_iv.dta",nogen  //访谈员观察数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_mh.dta",nogen  //心理健康数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_ph.dta",nogen  //身体健康数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_pf.dta",nogen //峰值流量数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_sp.dta",nogen  //社会支持数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_sn.dta",nogen  //社交网络数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_technical_variables.dta",nogen  //技术变量数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_dropoff.dta",nogen   //Dropoff data
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_gv_health.dta",nogen  //生成的健康数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_gv_housing.dta",nogen  //生成的房屋数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_gv_isced.dta",nogen  //生成的国际教育标准分类数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_gv_weights.dta",nogen  //生成的权重数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_gv_networks.dta",nogen  //生成的社交网络信息数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_gv_ssw.dta",nogen //生成的社会保障财富数据
merge 1:1 mergeid using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_gv_children.dta",nogen  //生成的综合儿童信息
*using "$raw_data/Wave 4 Release 9.0.0/sharew4_rel9-0-0_gv_exrates.dta",nogen  //汇率数据
save "$temp_data/share_wave4.dta",replace  //保存在临时数据集中


use "E:/SHARE_欧洲/Temp_data/share_wave4_CN.dta",clear
*sample 1

*****对生活的满意度10分
recode ac012_ (-2 -1=.),gen(r4satlife)

*****幸福感4分
recode ac022_ (-1 -2=.),gen(r4happiness)

***是否有爱好
gen r4hobby=.
replace r4hobby=0 if ac035d1==0 & ac035d4==0 & ac035d5==0 & ac035d7==0 & ac035d8==0 & ac035d9==0 & ac035d10==0
replace r4hobby=1 if ac035d1==1 | ac035d4==1 | ac035d5==1 | ac035d7==1 | ac035d8==1 | ac035d9==1 | ac035d10==1

***过去一年中的活动：做过志愿者或慈善工作
recode ac035d* (-1 -2=.)
gen r4act1=ac035d1 

***过去一年中的活动：参加过教育或培训课程
gen r4act2=ac035d4

***过去一年中的活动：参加过体育、社交或其他类型的俱乐部
gen r4act3=ac035d5

***过去一年中的活动：参与过宗教组织的活动
gen r4act4=ac035d6

***过去一年中的活动：参与过政治或社区相关的组织
gen r4act5=ac035d7

***过去一年中的活动：阅读书籍、杂志或报纸
gen r4act6=ac035d8

***过去一年中的活动：进行文字或数字游戏（填字游戏/数独等）
gen r4act7=ac035d9

***过去一年中的活动：玩纸牌或棋类游戏，例如国际象棋
gen r4act8=ac035d10

***过去12个月中参与志愿者/慈善工作的频率
recode ac036_* (-1 -2=.) (1=4) (2=3) (3=2) (4=1)
foreach i in 1 4 5 6 7 8 9 10 {
  replace ac036_`i'=0 if ac035d`i'==0
}

gen r4freq_act1=ac036_1

***过去12个月中参加教育或培训课程的频率
gen r4freq_act2=ac036_4

***过去12个月中参加体育/社交/其他类型俱乐部的频率
gen r4freq_act3=ac036_5

***过去12个月中参与宗教组织活动的频率
gen r4freq_act4=ac036_6

***过去12个月中参与政治/社区相关组织的频率
gen r4freq_act5=ac036_7

***过去12个月内阅读书籍、杂志或报纸的频率
gen r4freq_act6=ac036_8

***过去12个月内玩文字或数字游戏的频率
gen r4freq_act7=ac036_9

***过去12个月内玩纸牌或棋类游戏的频率
gen r4freq_act8=ac036_10

*****保存特定的变量
keep mergeid r4hobby r4satlife r4happiness r4act1 r4act2 r4act3 r4act4 r4act5 ///
r4act6 r4act7 r4act8 r4freq_act1 r4freq_act2 r4freq_act3 r4freq_act4 r4freq_act5 ///
r4freq_act6 r4freq_act7 r4freq_act8

save "$temp_data/share_wave4_temp.dta",replace 