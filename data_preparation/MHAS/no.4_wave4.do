
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
use "$raw_data/wave4/Core survey Data/sect_cover_int_2015.dta",clear
merge 1:1 cunicah np using "$raw_data/wave4/Core survey Data/sect_a_c_d_e_pc_f_h_i_2015.dta",nogen
merge m:1 cunicah subhog_15 using "$raw_data/wave4/Core survey Data/sect_g_j_k_sa_2015.dta",nogen
merge m:1 cunicah subhog_15 using "$raw_data/wave4/Imputations of Economic Variables/Sect_K_imputed_2015.dta",nogen
merge m:1 cunicah subhog_15 using "$raw_data/wave4/Imputations of Economic Variables/Sect_J_imputed_2015.dta",nogen
merge 1:1 cunicah np using "$raw_data/wave4/Cognitive Aging Ancillary Study (Mex-Cog)/Cognitive_Assessment_Mex_Cog_2016.dta",nogen
merge 1:1 cunicah np using "$raw_data/wave4/Cognitive Aging Ancillary Study (Mex-Cog)/Informant_Interview_Mex_Cog_2016.dta",nogen
merge 1:1 cunicah np using "$raw_data/wave4/Cognitive Aging Ancillary Study (Mex-Cog)/Master_Follow_up_File_Mex_Cog_2016.dta",nogen
merge 1:1 cunicah np using "$raw_data/wave4/Cognitive Aging Ancillary Study (Mex-Cog)/Anthropometrics_and_Biomarkers_Mex_Cog_2016.dta",nogen
keep cunicah np
save "$temp_data/wave4.dta",replace