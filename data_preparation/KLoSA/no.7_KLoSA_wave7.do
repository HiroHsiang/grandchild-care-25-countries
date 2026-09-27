
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
use "E:\KLoSA_韩国\Raw_data\wave7\e_imp_w07_CN.dta",clear
keep if v_imputation_ == 1 //只保留第一条
merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave7\w07_e_CN.dta",nogen nolabel force
*merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave7\w07_exit_e_CN.dta",nogen nolabel force
merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave7\Lt07_e_CN.dta",nogen nolabel force
merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave7\str07_e_CN.dta",nogen nolabel force

*****是否参加各种组织活动以及频率
forvalues i=1/7 {
 gen r7act`i'=w07A033m0`i'
 replace w07A035_0`i'=0 if w07A033m0`i'==0
 rename w07A035_0`i' r7freq_`i'  //数字越大频率越低
}

*****每次身体活动的分钟
rename w07C112 r7vigact_minute 

*****疼痛
rename (w07C088m01 w07C088m02 w07C088m03 w07C088m04 w07C088m05 w07C088m06 ///
 w07C088m07 w07C088m08 w07C088m09 w07C088m10 w07C088m11 w07C088m12 w07C088m13 ///
 w07C089 w07C090 w07C091 w07C092 w07C093 w07C094 w07C095 w07C096 w07C097 ///
 w07C098 w07C099 w07C100 w07C101) (r7pain_1 r7pain_2 r7pain_3 r7pain_4 r7pain_5 r7pain_6 ///
 r7pain_7 r7pain_8 r7pain_9 r7pain_10 r7pain_11 r7pain_12 r7pain_13 r7painlv_1 /// 
 r7painlv_2 r7painlv_3 r7painlv_4 r7painlv_5 r7painlv_6 r7painlv_7 r7painlv_8 r7painlv_9 ///
 r7painlv_10 r7painlv_11 r7painlv_12 r7painlv_13)

forvalues i=1/13 {
 replace r7painlv_`i'=0 if r7pain_`i'==0
 recode r7painlv_`i' (0=0) (1=1) (3=2) (5=3)
}


*****认知/星期几
gen r7dw= .
replace r7dw = 0 if w07C402==5
replace r7dw = 1 if w07C402==1 

*****认知/年月日
gen r7dat =.
replace r7dat = 0 if w07C401==5
replace r7dat =w07C401 if inrange(w07C401,1,3)

*****认知/季节
gen r7ssn = .
replace r7ssn = 0 if w07C403==5
replace r7ssn = 1 if w07C403==1

*****认知/地点
gen r7place = .
replace r7place = 0 if w07C404==5
replace r7place = 1 if w07C404==1

*****认知/完整的地址
gen r7cgdaddr = .
replace r7cgdaddr = 0 if w07C405==5
replace r7cgdaddr = w07C405 if inrange(w07C405,1,4)

*****认知/即时记忆
gen r7imrc3 =.
replace r7imrc3 = 0  if w07C406==5
replace r7imrc3 =w07C406 if inrange(w07C406,1,3)

*****认知/注意力和计算力
gen r7ser7 =.
replace r7ser7 = 0 if  (w07C407 ==5 | w07C408==5 | w07C409==5 | w07C410==5  | w07C411==5) 
replace r7ser7 = 1 if w07C407==1
replace r7ser7 = r7ser7+1 if w07C408==1
replace r7ser7 = r7ser7+1 if w07C409==1
replace r7ser7 = r7ser7+1 if w07C410==1
replace r7ser7 = r7ser7+1 if w07C411==1

*****认知/延迟记忆
gen r7dlrc3 =.
replace r7dlrc3 =  0 if w07C412==5 
replace r7dlrc3 = w07C412 if inrange(w07C412,1,3)

*****认知/两次记忆
gen r7tr6 = .
replace r7tr6 = r7imrc + r7dlrc if !mi(r7imrc) & !mi(r7dlrc)

*****认知/命名
gen r7object1=.
replace r7object1 =  0 if w07C413==5
replace r7object1 =  1 if w07C413==1

*****认知/命名
gen r7object2=.
replace r7object2 =  0 if w07C414==5
replace r7object2 =  1 if w07C414==1

*****认知/重复句子
gen r7rpsnt= .
replace r7rpsnt = 0  if w07C415==5
replace r7rpsnt = 1  if w07C415==1

*****认知/执行力
gen r7execu= .
replace r7execu = 0  if w07C416==5
replace r7execu = 1  if w07C416==1
replace r7execu = 2  if w07C416==2
replace r7execu = 3  if w07C416==3

*****认知/闭眼说话
gen r7task= .
replace r7task = 0  if w07C417==5
replace r7task = 1  if w07C417==1 
replace r7task = 2  if w07C417==3 

*****认知/写一个完整的句子
gen r7write= .
replace r7write = 0  if w07C418==5
replace r7write = 1  if w07C418==1 

*****认知/绘图
gen r7draw= .
replace r7draw = 0  if w07C419==5
replace r7draw = 1  if w07C419==1 

recode r7task (1=0) (2=1),gen(r7task1)
egen r7cog_total=rowtotal(r7dw r7dat r7ssn r7place r7cgdaddr r7imrc3 ///
r7ser7 r7dlrc3 r7object1 r7object2 r7rpsnt r7execu r7task1 r7write r7draw),mi

*****认知障碍
recode r7cog_total (0/17=1) (18/23=2) (24/30=3),gen(r7dementia)

*****保存特定变量
keep pid r7act1 r7act2 r7act3 r7act4 r7act5 r7act6 r7act7 r7freq_1 r7freq_2 ///
r7freq_3 r7freq_4 r7freq_5 r7freq_6 r7freq_7 r7vigact_minute r7pain_1 r7pain_2 ///
r7pain_3 r7pain_4 r7pain_5 r7pain_6 r7pain_7 r7pain_8 r7pain_9 r7pain_10 ///
r7pain_11 r7pain_12 r7pain_13 r7painlv_1 r7painlv_2 r7painlv_3 r7painlv_4 ///
r7painlv_5 r7painlv_6 r7painlv_7 r7painlv_8 r7painlv_9 r7painlv_10 r7painlv_11 ///
r7painlv_12 r7painlv_13 r7dw r7dat r7ssn r7place r7cgdaddr r7imrc3 r7ser7 ///
r7dlrc3 r7tr6 r7object1 r7object2  r7rpsnt r7execu r7task r7write r7draw ///
r7cog_total r7dementia 

save "$temp_data\w07.dta",replace