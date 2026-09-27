
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

use "$raw_data\wave3\e_imp_w03_CN.dta",clear
keep if vimputation_ == 1  //只保留第一条
merge 1:1 pid using "$raw_data\wave3\w03_e_CN.dta",nogen nolabel
merge 1:1 pid using "$raw_data\wave3\Lt03_e_CN.dta",nogen nolabel
merge 1:1 pid using "$raw_data\wave3\str03_e_CN.dta",nogen nolabel
*merge 1:1 pid using "$raw_data\wave3\w03_exit_e_CN.dta",nogen nolabel

*****是否参加各种组织活动以及频率
forvalues i=1/7 {
 gen r3act`i'=w03A033m0`i'
 replace w03A035_0`i'=0 if w03A033m0`i'==0
 rename w03A035_0`i' r3freq_`i'  //数字越大频率越低
}

*****每次身体活动的分钟
rename w03C112 r3vigact_minute 

*****疼痛
rename (w03C088m01 w03C088m02 w03C088m03 w03C088m04 w03C088m05 w03C088m06 ///
 w03C088m07 w03C088m08 w03C088m09 w03C088m10 w03C088m11 w03C088m12 w03C088m13 ///
 w03C089 w03C090 w03C091 w03C092 w03C093 w03C094 w03C095 w03C096 w03C097 ///
 w03C098 w03C099 w03C100 w03C101) (r3pain_1 r3pain_2 r3pain_3 r3pain_4 r3pain_5 r3pain_6 ///
 r3pain_7 r3pain_8 r3pain_9 r3pain_10 r3pain_11 r3pain_12 r3pain_13 r3painlv_1 /// 
 r3painlv_2 r3painlv_3 r3painlv_4 r3painlv_5 r3painlv_6 r3painlv_7 r3painlv_8 r3painlv_9 ///
 r3painlv_10 r3painlv_11 r3painlv_12 r3painlv_13)

forvalues i=1/13 {
 replace r3painlv_`i'=0 if r3pain_`i'==0
 recode r3painlv_`i' (0=0) (1=1) (3=2) (5=3)
}

*****认知/星期几
gen r3dw= .
replace r3dw = 0 if w03C402==5
replace r3dw = 1 if w03C402==1 

*****认知/年月日
gen r3dat =.
replace r3dat = 0 if w03C401==5
replace r3dat =w03C401 if inrange(w03C401,1,3)

*****认知/季节
gen r3ssn = .
replace r3ssn = 0 if w03C403==5
replace r3ssn = 1 if w03C403==1

*****认知/地点
gen r3place = .
replace r3place = 0 if w03C404==5
replace r3place = 1 if w03C404==1

*****认知/完整的地址
gen r3cgdaddr = .
replace r3cgdaddr = 0 if w03C405==5
replace r3cgdaddr = w03C405 if inrange(w03C405,1,4)

*****认知/即时记忆
gen r3imrc3 =.
replace r3imrc3 = 0  if w03C406==5
replace r3imrc3 =w03C406 if inrange(w03C406,1,3)

*****认知/注意力和计算力
gen r3ser7 =.
replace r3ser7 = 0 if  (w03C407 ==5 | w03C408==5 | w03C409==5 | w03C410==5  | w03C411==5) 
replace r3ser7 = 1 if w03C407==1
replace r3ser7 = r3ser7+1 if w03C408==1
replace r3ser7 = r3ser7+1 if w03C409==1
replace r3ser7 = r3ser7+1 if w03C410==1
replace r3ser7 = r3ser7+1 if w03C411==1

*****认知/延迟记忆
gen r3dlrc3 =.
replace r3dlrc3 =  0 if w03C412==5 
replace r3dlrc3 = w03C412 if inrange(w03C412,1,3)

*****认知/两次记忆
gen r3tr6 = .
replace r3tr6 = r3imrc + r3dlrc if !mi(r3imrc) & !mi(r3dlrc)

*****认知/命名
gen r3object1=.
replace r3object1 =  0 if w03C413==5
replace r3object1 =  1 if w03C413==1

*****认知/命名
gen r3object2=.
replace r3object2 =  0 if w03C414==5
replace r3object2 =  1 if w03C414==1

*****认知/重复句子
gen r3rpsnt= .
replace r3rpsnt = 0  if w03C415==5
replace r3rpsnt = 1  if w03C415==1

*****认知/执行力
gen r3execu= .
replace r3execu = 0  if w03C416==5
replace r3execu = 1  if w03C416==1
replace r3execu = 2  if w03C416==2
replace r3execu = 3  if w03C416==3

*****认知/闭眼说话
gen r3task= .
replace r3task = 0  if w03C417==5
replace r3task = 1  if w03C417==1 
replace r3task = 2  if w03C417==3 

*****认知/写一个完整的句子
gen r3write= .
replace r3write = 0  if w03C418==5
replace r3write = 1  if w03C418==1 

*****认知/绘图
gen r3draw= .
replace r3draw = 0  if w03C419==5
replace r3draw = 1  if w03C419==1 

recode r3task (1=0) (2=1),gen(r3task1)
egen r3cog_total=rowtotal(r3dw r3dat r3ssn r3place r3cgdaddr r3imrc3 ///
r3ser7 r3dlrc3 r3object1 r3object2 r3rpsnt r3execu r3task1 r3write r3draw),mi

*****认知障碍
recode r3cog_total (0/17=1) (18/23=2) (24/30=3),gen(r3dementia)

*****保存特定变量
keep pid r3act1 r3act2 r3act3 r3act4 r3act5 r3act6 r3act7 r3freq_1 r3freq_2 ///
r3freq_3 r3freq_4 r3freq_5 r3freq_6 r3freq_7 r3vigact_minute r3pain_1 r3pain_2 ///
r3pain_3 r3pain_4 r3pain_5 r3pain_6 r3pain_7 r3pain_8 r3pain_9 r3pain_10 ///
r3pain_11 r3pain_12 r3pain_13 r3painlv_1 r3painlv_2 r3painlv_3 r3painlv_4 ///
r3painlv_5 r3painlv_6 r3painlv_7 r3painlv_8 r3painlv_9 r3painlv_10 r3painlv_11 ///
r3painlv_12 r3painlv_13 r3dw r3dat r3ssn r3place r3cgdaddr r3imrc3 r3ser7 ///
r3dlrc3 r3tr6 r3object1 r3object2  r3rpsnt r3execu r3task r3write r3draw ///
r3cog_total r3dementia 

save "$temp_data\w03.dta",replace