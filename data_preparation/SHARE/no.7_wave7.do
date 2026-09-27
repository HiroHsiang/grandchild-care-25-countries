
clear all
set more off
set maxvar 120000
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
use "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_gv_imputations.dta",clear
keep if implicat==1
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_cv_r.dta",keep(match) nogen  //个人封面数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_ac.dta",nogen //活动数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_as.dta",nogen //资产数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_br.dta",nogen //行为风险数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_cc.dta",nogen //童年情况数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_cf.dta",nogen //认知功能数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_ch.dta",nogen //儿童数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_co.dta",nogen //消费数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_dn.dta",nogen //人口统计和网络数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_dq.dta",nogen //残疾数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_ep.dta",nogen //就业和养老金数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_ex.dta",nogen //期望数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_ft.dta",nogen //财富转移数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_fs.dta",nogen //财务部分数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_gl.dta",nogen //一般生活和迫害数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_gs.dta",nogen //握力数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_hc.dta",nogen //医疗保健数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_hh.dta",nogen //家庭收入数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_ho.dta",nogen //住房数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_iv.dta",nogen //访谈员观察数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_it.dta",nogen //计算机使用数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_mh.dta",nogen //心理健康数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_ph.dta",nogen //身体健康数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_hs.dta",nogen //健康部分数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_ra.dta",nogen //回顾性住宿数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_re.dta",nogen //回顾性就业数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_rh.dta",nogen //回顾性健康护理
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_sp.dta",nogen //社会支持数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_wq.dta",nogen //工作质量数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_technical_variables.dta",nogen //技术变量数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_dropoff.dta",nogen //Dropoff data
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_gv_big5.dta",nogen //生成的五大人格特质数据 
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_gv_children.dta",nogen //生成的综合儿童信息数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_gv_health.dta",nogen //生成的健康数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_gv_housing.dta",nogen //生成的房屋数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_gv_isced.dta",nogen //生成的国际教育标准分类数据
merge 1:1 mergeid using "$raw_data/Wave 7 Release 9.0.0/sharew7_rel9-0-0_gv_weights.dta",nogen //生成的权重数据
save "$temp_data/share_wave7.dta",replace  //保存在临时数据集中

use "E:/SHARE_欧洲/Temp_data/share_wave7_CN.dta",clear
*sample 1

*****对生活的满意度10分
recode ac012_ (-2 -1=.),gen(r7satlife)

*****幸福感4分
recode ac022_ (-1 -2=.),gen(r7happiness)

***是否有爱好
gen r7hobby=.
replace r7hobby=0 if ac035d1==0 & ac035d4==0 & ac035d5==0 & ac035d7==0 & ac035d8==0 & ac035d9==0 & ac035d10==0
replace r7hobby=1 if ac035d1==1 | ac035d4==1 | ac035d5==1 | ac035d7==1 | ac035d8==1 | ac035d9==1 | ac035d10==1

***过去一年中的活动：做过志愿者或慈善工作
recode ac035d* (-1 -2=.)
gen r7act1=ac035d1 

***过去一年中的活动：参加过教育或培训课程
gen r7act2=ac035d4

***过去一年中的活动：参加过体育、社交或其他类型的俱乐部
gen r7act3=ac035d5

***过去一年中的活动：参与过政治或社区相关的组织
gen r7act5=ac035d7

***过去一年中的活动：阅读书籍、杂志或报纸
gen r7act6=ac035d8

***过去一年中的活动：进行文字或数字游戏（填字游戏/数独等）
gen r7act7=ac035d9

***过去一年中的活动：玩纸牌或棋类游戏，例如国际象棋
gen r7act8=ac035d10

***过去12个月中参与志愿者/慈善工作的频率
recode ac036_* (-1 -2=.) (1=4) (2=3) (3=2) (4=1)
foreach i in 1 4 5 7 8 9 10 {
  replace ac036_`i'=0 if ac035d`i'==0
}

gen r7freq_act1=ac036_1

***过去12个月中参加教育或培训课程的频率
gen r7freq_act2=ac036_4

***过去12个月中参加体育/社交/其他类型俱乐部的频率
gen r7freq_act3=ac036_5

***过去12个月中参与政治/社区相关组织的频率
gen r7freq_act5=ac036_7

***过去12个月内阅读书籍、杂志或报纸的频率
gen r7freq_act6=ac036_8

***过去12个月内玩文字或数字游戏的频率
gen r7freq_act7=ac036_9

***过去12个月内玩纸牌或棋类游戏的频率
gen r7freq_act8=ac036_10

***网络
recode it004_ (1=1) (5=0) (else=.),gen(r7internet)

*****保存特定的变量
keep mergeid r7hobby r7satlife r7happiness r7act1 r7act2 r7act3 r7act5 ///
r7act6 r7act7 r7act8 r7freq_act1 r7freq_act2 r7freq_act3 r7freq_act5 ///
r7freq_act6 r7freq_act7 r7freq_act8 r7internet

save "$temp_data/share_wave7_temp.dta",replace 