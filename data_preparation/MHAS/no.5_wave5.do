
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
use "$raw_data/wave5/Core survey Data/sect_a_c_d_f_e_pc_h_i_2018.dta",clear
merge m:1 cunicah subhog_18 using  "$raw_data/wave5/Core survey Data/sect_g_j_k_sa_2018.dta",nogen
merge 1:1 cunicah np using  "$raw_data/wave5/Hair Samples/MHAS 2018 - Heavy Metals Exposure.dta",nogen
keep cunicah np
save "$temp_data/wave5.dta",replace