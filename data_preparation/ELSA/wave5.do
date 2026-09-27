
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
use "$raw_data/wave5/wave_5_ifs_derived_variables_CN.dta",clear
*merge m:1 idauniq using "$raw_data/wave5/wave_5_pension_grid_v3_CN.dta",nogen 
merge 1:1 idauniq using "$raw_data/wave5/wave_5_pension_wealth_CN.dta",nogen 
merge 1:1 idauniq using "$raw_data/wave5/w5_elsa_additional_cognitive_function_vars_CN.dta",nogen 
merge 1:1 idauniq using "$raw_data/wave5/wave_5_elsa_data_v4_CN.dta",nogen 
merge 1:1 idauniq using "$raw_data/wave5/wave_5_financial_derived_variables_CN.dta",nogen 

*****是否有爱好
recode scpt02 (-9 -2=.),gen(r5hobby)

*****政党、工会或环保组织的成员
recode scorg01 (-9 -2=.),gen(r5group1) 

*****租户团体、居民团体或邻里守望组织的成员
recode scorg02 (-9 -2=.),gen(r5group2) 

*****教堂或其他宗教团体的成员
recode scorg03 (-9 -2=.),gen(r5group3) 

*****慈善协会的成员
recode scorg04 (-9 -2=.),gen(r5group4) 

*****教育、艺术或音乐团体或夜校的成员
recode scorg05 (-9 -2=.),gen(r5group5) 

*****社交俱乐部的成员
recode scorg06 (-9 -2=.),gen(r5group6) 

*****体育俱乐部、健身房或锻炼班的成员
recode scorg07 (-9 -2=.),gen(r5group7) 

*****其他组织、俱乐部或社团的成员
recode scorg08 (-9 -2=.),gen(r5group8) 

*****是否使用天然气
rename usesgas r5usesgas

*****是否使用电力
rename useselec r5useselec

*****是否使用煤
rename usescoal r5usescoal

*****是否使用煤油
rename usespara r5usespara

*****是否使用石油
rename usesoil r5usesoil

*****是否使用木材
rename useswood r5useswood

*****是否使用其他燃料
rename usesotherf r5usesotherf

*****保留特定变量
keep idauniq r5hobby r5group1 r5group2 r5group3 r5group4 r5group5 r5group6 ///
r5group7 r5group8 r5usesgas r5useselec r5usescoal r5usespara r5usesoil ///
r5useswood r5usesotherf

save "$temp_data/elsa_wave5.dta",replace