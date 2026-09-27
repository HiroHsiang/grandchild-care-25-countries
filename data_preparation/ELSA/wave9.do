
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
use "$raw_data/wave9/wave_9_financial_derived_variables_CN.dta",clear
merge 1:1 idauniq using "$raw_data/wave9/wave_9_ifs_derived_variables_CN.dta",nogen 
merge 1:1 idauniq using "$raw_data/wave9/wave_9_elsa_data_eul_v1_CN.dta",nogen 
*merge m:1 idauniq using "$raw_data/wave9/wave_9_elsa_pensiongrid_eul_v2_CN.dta",nogen 

*****是否有爱好
recode scptrhb (-9 -1=.),gen(r9hobby)

*****政党、工会或环保组织的成员
recode scorgpo (-9 -1=.),gen(r9group1)
 
*****租户团体、居民团体或邻里守望组织的成员
recode scorgnw (-9 -1=.),gen(r9group2) 

*****教堂或其他宗教团体的成员
recode scorgrl (-9 -1=.),gen(r9group3) 

*****慈善协会的成员
recode scorgch (-9 -1=.),gen(r9group4) 

*****教育、艺术或音乐团体或夜校的成员
recode scorged (-9 -1=.),gen(r9group5) 

*****社交俱乐部的成员
recode scorgsc (-9 -1=.),gen(r9group6) 

*****体育俱乐部、健身房或锻炼班的成员
recode scorgsp (-9 -1=.),gen(r9group7) 

*****其他组织、俱乐部或社团的成员
recode scorgsp (-9 -1=.),gen(r9group8) 

*****是否使用天然气
rename usesgas r9usesgas

*****是否使用电力
rename useselec r9useselec

*****是否使用煤
rename usescoal r9usescoal

*****是否使用煤油
rename usespara r9usespara

*****是否使用石油
rename usesoil r9usesoil

*****是否使用木材
rename useswood r9useswood

*****是否使用其他燃料
rename usesotherf r9usesotherf

*****幸福感: 总体而言，你昨天的快乐感受如何？
recode scovha (-9 -1=.),gen(r9happiness)

*****是否至少每周使用互联网
recode scint (-9 -1=.) (1/2=1) (3/6=0),gen(r9internet)

*****保留特定变量
keep idauniq r9hobby r9group1 r9group2 r9group3 r9group4 r9group5 r9group6 ///
r9group7 r9group8 r9usesgas r9useselec r9usescoal r9usespara r9usesoil ///
r9useswood r9usesotherf r9happiness r9internet

save "$temp_data/elsa_wave9.dta",replace