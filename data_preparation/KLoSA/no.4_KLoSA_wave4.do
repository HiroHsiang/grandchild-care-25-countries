
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
use "$raw_data\wave4\e_imp_w04_CN.dta",clear
keep if vimputation_ == 1  //只保留第一条
merge 1:1 pid using "$raw_data\wave4\w04_e_CN.dta",nogen nolabel
merge 1:1 pid using "$raw_data\wave4\Lt04_e_CN.dta",nogen nolabel
merge 1:1 pid using "$raw_data\wave4\str04_e_CN.dta",nogen nolabel
*merge 1:1 pid using "$raw_data\wave4\w04_exit_e.dta",nogen nolabel

*****是否参加各种组织活动以及频率
forvalues i=1/7 {
 gen r4act`i'=w04A033m0`i'
 replace w04A035_0`i'=0 if w04A033m0`i'==0
 rename w04A035_0`i' r4freq_`i'  //数字越大频率越低
}

*****每次身体活动的分钟
rename w04C112 r4vigact_minute 

*****疼痛
rename (w04C088m01 w04C088m02 w04C088m03 w04C088m04 w04C088m05 w04C088m06 ///
 w04C088m07 w04C088m08 w04C088m09 w04C088m10 w04C088m11 w04C088m12 w04C088m13 ///
 w04C089 w04C090 w04C091 w04C092 w04C093 w04C094 w04C095 w04C096 w04C097 ///
 w04C098 w04C099 w04C100 w04C101) (r4pain_1 r4pain_2 r4pain_3 r4pain_4 r4pain_5 r4pain_6 ///
 r4pain_7 r4pain_8 r4pain_9 r4pain_10 r4pain_11 r4pain_12 r4pain_13 r4painlv_1 /// 
 r4painlv_2 r4painlv_3 r4painlv_4 r4painlv_5 r4painlv_6 r4painlv_7 r4painlv_8 r4painlv_9 ///
 r4painlv_10 r4painlv_11 r4painlv_12 r4painlv_13)

forvalues i=1/13 {
 replace r4painlv_`i'=0 if r4pain_`i'==0
 recode r4painlv_`i' (0=0) (1=1) (3=2) (5=3)
}

*****认知/星期几
gen r4dw= .
replace r4dw = 0 if w04C402==5
replace r4dw = 1 if w04C402==1 

*****认知/年月日
gen r4dat =.
replace r4dat = 0 if w04C401==5
replace r4dat =w04C401 if inrange(w04C401,1,3)

*****认知/季节
gen r4ssn = .
replace r4ssn = 0 if w04C403==5
replace r4ssn = 1 if w04C403==1

*****认知/地点
gen r4place = .
replace r4place = 0 if w04C404==5
replace r4place = 1 if w04C404==1

*****认知/完整的地址
gen r4cgdaddr = .
replace r4cgdaddr = 0 if w04C405==5
replace r4cgdaddr = w04C405 if inrange(w04C405,1,4)

*****认知/即时记忆
gen r4imrc3 =.
replace r4imrc3 = 0  if w04C406==5
replace r4imrc3 =w04C406 if inrange(w04C406,1,3)

*****认知/注意力和计算力
gen r4ser7 =.
replace r4ser7 = 0 if  (w04C407 ==5 | w04C408==5 | w04C409==5 | w04C410==5  | w04C411==5) 
replace r4ser7 = 1 if w04C407==1
replace r4ser7 = r4ser7+1 if w04C408==1
replace r4ser7 = r4ser7+1 if w04C409==1
replace r4ser7 = r4ser7+1 if w04C410==1
replace r4ser7 = r4ser7+1 if w04C411==1

*****认知/延迟记忆
gen r4dlrc3 =.
replace r4dlrc3 =  0 if w04C412==5 
replace r4dlrc3 = w04C412 if inrange(w04C412,1,3)

*****认知/两次记忆
gen r4tr6 = .
replace r4tr6 = r4imrc + r4dlrc if !mi(r4imrc) & !mi(r4dlrc)

*****认知/命名
gen r4object1=.
replace r4object1 =  0 if w04C413==5
replace r4object1 =  1 if w04C413==1

*****认知/命名
gen r4object2=.
replace r4object2 =  0 if w04C414==5
replace r4object2 =  1 if w04C414==1

*****认知/重复句子
gen r4rpsnt= .
replace r4rpsnt = 0  if w04C415==5
replace r4rpsnt = 1  if w04C415==1

*****认知/执行力
gen r4execu= .
replace r4execu = 0  if w04C416==5
replace r4execu = 1  if w04C416==1
replace r4execu = 2  if w04C416==2
replace r4execu = 3  if w04C416==3

*****认知/闭眼说话
gen r4task= .
replace r4task = 0  if w04C417==5
replace r4task = 1  if w04C417==1 
replace r4task = 2  if w04C417==3 

*****认知/写一个完整的句子
gen r4write= .
replace r4write = 0  if w04C418==5
replace r4write = 1  if w04C418==1 

*****认知/绘图
gen r4draw= .
replace r4draw = 0  if w04C419==5
replace r4draw = 1  if w04C419==1 

recode r4task (1=0) (2=1),gen(r4task1)
egen r4cog_total=rowtotal(r4dw r4dat r4ssn r4place r4cgdaddr r4imrc3 ///
r4ser7 r4dlrc3 r4object1 r4object2 r4rpsnt r4execu r4task1 r4write r4draw),mi

*****认知障碍
recode r4cog_total (0/17=1) (18/23=2) (24/30=3),gen(r4dementia)

*****保存特定变量
keep pid r4act1 r4act2 r4act3 r4act4 r4act5 r4act6 r4act7 r4freq_1 r4freq_2 ///
r4freq_3 r4freq_4 r4freq_5 r4freq_6 r4freq_7 r4vigact_minute r4pain_1 r4pain_2 ///
r4pain_3 r4pain_4 r4pain_5 r4pain_6 r4pain_7 r4pain_8 r4pain_9 r4pain_10 ///
r4pain_11 r4pain_12 r4pain_13 r4painlv_1 r4painlv_2 r4painlv_3 r4painlv_4 ///
r4painlv_5 r4painlv_6 r4painlv_7 r4painlv_8 r4painlv_9 r4painlv_10 r4painlv_11 ///
r4painlv_12 r4painlv_13 r4dw r4dat r4ssn r4place r4cgdaddr r4imrc3 r4ser7 ///
r4dlrc3 r4tr6 r4object1 r4object2  r4rpsnt r4execu r4task r4write r4draw ///
r4cog_total r4dementia 

save "$temp_data\w04.dta",replace