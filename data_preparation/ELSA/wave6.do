clear all
set more off
set maxvar 120000
global root= "E:/ELSA_英国"
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
use "$raw_data/wave6/wave_6_financial_derived_variables_CN.dta",clear
merge 1:1 idauniq using "$raw_data/wave6/wave_6_ifs_derived_variables_CN.dta",nogen 
*merge m:1 idauniq using "$rRaw_data/wave6/wave_6_pensiongrid_archive_v1_CN.dta",nogen 
merge 1:1 idauniq using "$raw_data/wave6/wave_6_elsa_cortisol_data_eul_CN.dta",nogen 
merge 1:1 idauniq using "$raw_data/wave6/wave_6_elsa_data_v2_CN.dta",nogen 
merge 1:1 idauniq using "$raw_data/wave6/wave_6_elsa_nurse_data_v2_CN.dta",nogen 

*****是否有爱好
recode scptr2 (-9 -2=.),gen(r6hobby)

*****政党、工会或环保组织的成员
recode scorg01 (-9 -2=.),gen(r6group1) 

*****租户团体、居民团体或邻里守望组织的成员
recode scorg02 (-9 -2=.),gen(r6group2) 

*****教堂或其他宗教团体的成员
recode scorg03 (-9 -2=.),gen(r6group3) 

*****慈善协会的成员
recode scorg04 (-9 -2=.),gen(r6group4) 

*****教育、艺术或音乐团体或夜校的成员
recode scorg05 (-9 -2=.),gen(r6group5) 

*****社交俱乐部的成员
recode scorg06 (-9 -2=.),gen(r6group6) 

*****体育俱乐部、健身房或锻炼班的成员
recode scorg07 (-9 -2=.),gen(r6group7) 

*****其他组织、俱乐部或社团的成员
recode scorg08 (-9 -2=.),gen(r6group8) 

*****是否使用天然气
rename usesgas r6usesgas

*****是否使用电力
rename useselec r6useselec

*****是否使用煤
rename usescoal r6usescoal

*****是否使用煤油
rename usespara r6usespara

*****是否使用石油
rename usesoil r6usesoil

*****是否使用木材
rename useswood r6useswood

*****是否使用其他燃料
rename usesotherf r6usesotherf

*****总体而言，你昨天的快乐感受如何？
recode scovha (-9 -2=.),gen(r6happiness)

*****是否至少每周使用互联网
recode scint (-9 -2=.) (1/2=1) (3/6=0),gen(r6internet)

*****睡眠时长
recode heslpe (-9 -8=.),gen(r6sleep_hour)

*****保留特定变量
keep idauniq r6hobby r6group1 r6group2 r6group3 r6group4 r6group5 r6group6 ///
r6group7 r6group8  r6usesgas r6useselec r6usescoal r6usespara r6usesoil ///
r6useswood r6usesotherf r6happiness r6sleep_hour r6internet
save "$temp_data/elsa_wave6.dta",replace