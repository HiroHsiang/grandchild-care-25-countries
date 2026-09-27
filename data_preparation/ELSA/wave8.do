
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
use "$raw_data/wave8/wave_8_elsa_ifs_dvs_eul_v1_CN.dta",clear
merge 1:1 idauniq using "$raw_data/wave8/wave_8_elsa_nurse_data_eul_v1_CN.dta",nogen 
*merge m:1 idauniq using "$raw_data/wave8/wave_8_elsa_pensiongrid_eul_v1_CN.dta",nogen 
merge 1:1 idauniq using "$raw_data/wave8/wave_8_elsa_data_eul_v2_CN.dta",nogen 
merge 1:1 idauniq using "$raw_data/wave8/wave_8_elsa_financial_dvs_eul_v1_CN.dta",nogen 

*****是否有爱好
recode scptrhb (-3 -2=.),gen(r8hobby)

*****政党、工会或环保组织的成员
recode scorgpo (-3 -2=.),gen(r8group1)
 
*****租户团体、居民团体或邻里守望组织的成员
recode scorgnw (-3 -2=.),gen(r8group2) 

*****教堂或其他宗教团体的成员
recode scorgrl (-3 -2=.),gen(r8group3) 

*****慈善协会的成员
recode scorgch (-3 -2=.),gen(r8group4) 

*****教育、艺术或音乐团体或夜校的成员
recode scorged (-3 -2=.),gen(r8group5) 

*****社交俱乐部的成员
recode scorgsc (-3 -2=.),gen(r8group6) 

*****体育俱乐部、健身房或锻炼班的成员
recode scorgsp (-3 -2=.),gen(r8group7) 

*****其他组织、俱乐部或社团的成员
recode scorgsp (-3 -2=.),gen(r8group8) 

*****是否使用天然气
rename usesgas r8usesgas

*****是否使用电力
rename useselec r8useselec

*****是否使用煤
rename usescoal r8usescoal

*****是否使用煤油
rename usespara r8usespara

*****是否使用石油
rename usesoil r8usesoil

*****是否使用木材
rename useswood r8useswood

*****是否使用其他燃料
rename usesotherf r8usesotherf

*****总体而言，你昨天的快乐感受如何？
recode scovha (-3 -2=.),gen(r8happiness)

*****睡眠时长
recode heslpe (-1 -8=.),gen(r8sleep_hour)

*****是否至少每周使用互联网
recode scint (-3 -2=.) (1/2=1) (3/6=0),gen(r8internet)

*****保留特定变量
keep idauniq r8hobby r8group1 r8group2 r8group3 r8group4 r8group5 r8group6 ///
r8group7 r8group8 r8usesgas r8useselec r8usescoal r8usespara r8usesoil ///
r8useswood r8usesotherf r8happiness r8sleep_hour r8internet
save "$temp_data/elsa_wave8.dta",replace