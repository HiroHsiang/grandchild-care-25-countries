
clear all
set more off
set maxvar 120000
global root= "E:/MHAS_墨西哥"
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
use "$raw_data/wave1/Core survey Data/h_indiv.dta",clear
merge 1:1 unhhid ps3 using "$raw_data/wave1/Core survey Data/sect_a.dta",nogen
merge 1:1 unhhid ps3 using "$raw_data/wave1/Core survey Data/sect_c.dta",nogen force
merge 1:1 unhhid ps3 using "$raw_data/wave1/Core survey Data/sect_d.dta",nogen
merge 1:1 unhhid ps3 using "$raw_data/wave1/Core survey Data/sect_e.dta",nogen
merge 1:1 unhhid ps3 using "$raw_data/wave1/Core survey Data/sect_f.dta",nogen
merge 1:1 unhhid ps3 using "$raw_data/wave1/Core survey Data/sect_i.dta",nogen
merge 1:1 unhhid ps3 using "$raw_data/wave1/Core survey Data/sect_ps.dta",keep(1 3) nogen
merge 1:1 unhhid ps3 using "$raw_data/wave1/Core survey Data/sect_pc.dta",nogen
merge 1:1 unhhid ps3 using "$raw_data/wave1/Anthropometric Measures/sect_l.dta",nogen
merge m:1 unhhid using "$raw_data/wave1/Core survey Data/sect_k.dta",nogen
merge m:1 unhhid using "$raw_data/wave1/Core survey Data/sect_j.dta",nogen
merge m:1 unhhid using "$raw_data/wave1/Imputations of Economic Variables/sect_kimp_2.dta",nogen
merge m:1 unhhid using "$raw_data/wave1/Imputations of Economic Variables/sect_jimp_2.dta",nogen

keep unhhid ps3 
save "$temp_data/wave1.dta",replace



































