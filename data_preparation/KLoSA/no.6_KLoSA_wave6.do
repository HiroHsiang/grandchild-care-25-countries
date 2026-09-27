
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
use "E:\KLoSA_韩国\Raw_data\wave6\e_imp_w06_CN.dta",clear
keep if v_imputation_ == 1 //只保留第一条
merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave6\w06_e_CN.dta",nogen nolabel force
*merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave6\w06_Exit_e_CN.dta",nogen nolabel force
merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave6\Lt06_e_CN.dta",nogen nolabel force
merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave6\str06_e_CN.dta",nogen nolabel force


*****是否参加各种组织活动以及频率
forvalues i=1/7 {
 gen r6act`i'=w06A033m0`i'
 replace w06A035_0`i'=0 if w06A033m0`i'==0
 rename w06A035_0`i' r6freq_`i'  //数字越大频率越低
}

*****每次身体活动的分钟
rename w06C112 r6vigact_minute 

*****疼痛
rename (w06C088m01 w06C088m02 w06C088m03 w06C088m04 w06C088m05 w06C088m06 ///
 w06C088m07 w06C088m08 w06C088m09 w06C088m10 w06C088m11 w06C088m12 w06C088m13 ///
 w06C089 w06C090 w06C091 w06C092 w06C093 w06C094 w06C095 w06C096 w06C097 ///
 w06C098 w06C099 w06C100 w06C101) (r6pain_1 r6pain_2 r6pain_3 r6pain_4 r6pain_5 r6pain_6 ///
 r6pain_7 r6pain_8 r6pain_9 r6pain_10 r6pain_11 r6pain_12 r6pain_13 r6painlv_1 /// 
 r6painlv_2 r6painlv_3 r6painlv_4 r6painlv_5 r6painlv_6 r6painlv_7 r6painlv_8 r6painlv_9 ///
 r6painlv_10 r6painlv_11 r6painlv_12 r6painlv_13)

forvalues i=1/13 {
 replace r6painlv_`i'=0 if r6pain_`i'==0
 recode r6painlv_`i' (0=0) (1=1) (3=2) (5=3)
}

*****认知/星期几
gen r6dw= .
replace r6dw = 0 if w06C402==5
replace r6dw = 1 if w06C402==1 

*****认知/年月日
gen r6dat =.
replace r6dat = 0 if w06C401==5
replace r6dat =w06C401 if inrange(w06C401,1,3)

*****认知/季节
gen r6ssn = .
replace r6ssn = 0 if w06C403==5
replace r6ssn = 1 if w06C403==1

*****认知/地点
gen r6place = .
replace r6place = 0 if w06C404==5
replace r6place = 1 if w06C404==1

*****认知/完整的地址
gen r6cgdaddr = .
replace r6cgdaddr = 0 if w06C405==5
replace r6cgdaddr = w06C405 if inrange(w06C405,1,4)

*****认知/即时记忆
gen r6imrc3 =.
replace r6imrc3 = 0  if w06C406==5
replace r6imrc3 =w06C406 if inrange(w06C406,1,3)

*****认知/注意力和计算力
gen r6ser7 =.
replace r6ser7 = 0 if  (w06C407 ==5 | w06C408==5 | w06C409==5 | w06C410==5  | w06C411==5) 
replace r6ser7 = 1 if w06C407==1
replace r6ser7 = r6ser7+1 if w06C408==1
replace r6ser7 = r6ser7+1 if w06C409==1
replace r6ser7 = r6ser7+1 if w06C410==1
replace r6ser7 = r6ser7+1 if w06C411==1

*****认知/延迟记忆
gen r6dlrc3 =.
replace r6dlrc3 =  0 if w06C412==5 
replace r6dlrc3 = w06C412 if inrange(w06C412,1,3)

*****认知/两次记忆
gen r6tr6 = .
replace r6tr6 = r6imrc + r6dlrc if !mi(r6imrc) & !mi(r6dlrc)

*****认知/命名
gen r6object1=.
replace r6object1 =  0 if w06C413==5
replace r6object1 =  1 if w06C413==1

*****认知/命名
gen r6object2=.
replace r6object2 =  0 if w06C414==5
replace r6object2 =  1 if w06C414==1

*****认知/重复句子
gen r6rpsnt= .
replace r6rpsnt = 0  if w06C415==5
replace r6rpsnt = 1  if w06C415==1

*****认知/执行力
gen r6execu= .
replace r6execu = 0  if w06C416==5
replace r6execu = 1  if w06C416==1
replace r6execu = 2  if w06C416==2
replace r6execu = 3  if w06C416==3

*****认知/闭眼说话
gen r6task= .
replace r6task = 0  if w06C417==5
replace r6task = 1  if w06C417==1 
replace r6task = 2  if w06C417==3 

*****认知/写一个完整的句子
gen r6write= .
replace r6write = 0  if w06C418==5
replace r6write = 1  if w06C418==1 

*****认知/绘图
gen r6draw= .
replace r6draw = 0  if w06C419==5
replace r6draw = 1  if w06C419==1 

recode r6task (1=0) (2=1),gen(r6task1)
egen r6cog_total=rowtotal(r6dw r6dat r6ssn r6place r6cgdaddr r6imrc3 ///
r6ser7 r6dlrc3 r6object1 r6object2 r6rpsnt r6execu r6task1 r6write r6draw),mi

*****认知障碍
recode r6cog_total (0/17=1) (18/23=2) (24/30=3),gen(r6dementia)

*****保存特定变量
keep pid r6act1 r6act2 r6act3 r6act4 r6act5 r6act6 r6act7 r6freq_1 r6freq_2 ///
r6freq_3 r6freq_4 r6freq_5 r6freq_6 r6freq_7 r6vigact_minute r6pain_1 r6pain_2 ///
r6pain_3 r6pain_4 r6pain_5 r6pain_6 r6pain_7 r6pain_8 r6pain_9 r6pain_10 ///
r6pain_11 r6pain_12 r6pain_13 r6painlv_1 r6painlv_2 r6painlv_3 r6painlv_4 ///
r6painlv_5 r6painlv_6 r6painlv_7 r6painlv_8 r6painlv_9 r6painlv_10 r6painlv_11 ///
r6painlv_12 r6painlv_13 r6dw r6dat r6ssn r6place r6cgdaddr r6imrc3 r6ser7 ///
r6dlrc3 r6tr6 r6object1 r6object2  r6rpsnt r6execu r6task r6write r6draw ///
r6cog_total r6dementia 

save "$temp_data\w06.dta",replace