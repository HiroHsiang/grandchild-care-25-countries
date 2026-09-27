
clear all
set more off
set maxvar 20000
global root= "E:\KLoSA_韩国"
***************************** 注：运行前更改上述路径 ***************************
global dofiles=      "$root\Dofiles"         
global raw_data=     "$root\Raw_data"
global working_data= "$root\Working_data"
global temp_data=    "$root\Temp_data"

cap mkdir "$raw_data"      // 自动创建文件夹
cap mkdir "$temp_data"     // `cap` 命令可让错误的代码继续运行
cap mkdir "$working_data"    
cap mkdir "$dofiles"       // 如果已经创建了这些文件夹，也可以运行

*Summary: 七大老年健康数据库训练营
*Authors: Shawn (微信公众账号丁点帮你 & 顶刊研习社)
*Date Published: August 1, 2024
********************************************************************************
use "E:\KLoSA_韩国\Raw_data\wave8\w08_e_CN.dta",clear
*merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave8\w08_exit_e_CN.dta",nogen nolabel force
merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave8\Lt08_e_CN.dta",nogen nolabel force
merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave8\str08_e_CN.dta",nogen nolabel force

*****是否参加各种组织活动以及频率
forvalues i=1/7 {
 gen r8act`i'=w08A033m0`i'
 replace w08A035_0`i'=0 if w08A033m0`i'==0
 rename w08A035_0`i' r8freq_`i'  //数字越大频率越低
}

*****每次身体活动的分钟
rename w08C112 r8vigact_minute 

*****疼痛
rename (w08C088m01 w08C088m02 w08C088m03 w08C088m04 w08C088m05 w08C088m06 ///
 w08C088m07 w08C088m08 w08C088m09 w08C088m10 w08C088m11 w08C088m12 w08C088m13 ///
 w08C089 w08C090 w08C091 w08C092 w08C093 w08C094 w08C095 w08C096 w08C097 ///
 w08C098 w08C099 w08C100 w08C101) (r8pain_1 r8pain_2 r8pain_3 r8pain_4 r8pain_5 r8pain_6 ///
 r8pain_7 r8pain_8 r8pain_9 r8pain_10 r8pain_11 r8pain_12 r8pain_13 r8painlv_1 /// 
 r8painlv_2 r8painlv_3 r8painlv_4 r8painlv_5 r8painlv_6 r8painlv_7 r8painlv_8 r8painlv_9 ///
 r8painlv_10 r8painlv_11 r8painlv_12 r8painlv_13)

forvalues i=1/13 {
 replace r8painlv_`i'=0 if r8pain_`i'==0
 recode r8painlv_`i' (0=0) (1=1) (3=2) (5=3)
}

*****保存特定变量
keep pid r8act1 r8act2 r8act3 r8act4 r8act5 r8act6 r8act7 r8freq_1 r8freq_2 ///
r8freq_3 r8freq_4 r8freq_5 r8freq_6 r8freq_7 r8vigact_minute r8pain_1 r8pain_2 ///
r8pain_3 r8pain_4 r8pain_5 r8pain_6 r8pain_7 r8pain_8 r8pain_9 r8pain_10 ///
r8pain_11 r8pain_12 r8pain_13 r8painlv_1 r8painlv_2 r8painlv_3 r8painlv_4 ///
r8painlv_5 r8painlv_6 r8painlv_7 r8painlv_8 r8painlv_9 r8painlv_10 r8painlv_11 ///
r8painlv_12 r8painlv_13 

save "$temp_data\w08.dta",replace