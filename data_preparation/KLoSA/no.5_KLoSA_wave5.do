
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
use "E:\KLoSA_韩国\Raw_data\wave5\e_imp_w05_CN.dta",clear
keep if vimputation_ == 1 //只保留第一条
save "$temp_data/wave_5_imp.dta",replace 

use "E:\KLoSA_韩国\Raw_data\wave5\e_imp_w05_new_CN.dta",clear
keep if vimputation_ == 1 //只保留第一条
save "$temp_data/wave_5_add_imp.dta",replace 

merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave5\w05_e_CN.dta",nogen nolabel force
merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave5\w05_new_e_CN.dta",nogen nolabel force
merge 1:1 pid using "$temp_data/wave_5_add_imp.dta",nogen nolabel force
merge 1:1 pid using "$temp_data/wave_5_imp.dta",nogen nolabel force
*merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave5\w05_exit_e.dta",nogen nolabel force
merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave5\Lt05_e_CN.dta",nogen nolabel force
merge 1:1 pid using "E:\KLoSA_韩国\Raw_data\wave5\str05_e_CN.dta",nogen nolabel force

*****是否参加各种组织活动以及频率
forvalues i=1/7 {
 gen r5act`i'=w05A033m0`i'
 replace w05A035_0`i'=0 if w05A033m0`i'==0
 rename w05A035_0`i' r5freq_`i'  //数字越大频率越低
}

*****每次身体活动的分钟
rename w05C112 r5vigact_minute 

*****疼痛
rename (w05C088m01 w05C088m02 w05C088m03 w05C088m04 w05C088m05 w05C088m06 ///
 w05C088m07 w05C088m08 w05C088m09 w05C088m10 w05C088m11 w05C088m12 w05C088m13 ///
 w05C089 w05C090 w05C091 w05C092 w05C093 w05C094 w05C095 w05C096 w05C097 ///
 w05C098 w05C099 w05C100 w05C101) (r5pain_1 r5pain_2 r5pain_3 r5pain_4 r5pain_5 r5pain_6 ///
 r5pain_7 r5pain_8 r5pain_9 r5pain_10 r5pain_11 r5pain_12 r5pain_13 r5painlv_1 /// 
 r5painlv_2 r5painlv_3 r5painlv_4 r5painlv_5 r5painlv_6 r5painlv_7 r5painlv_8 r5painlv_9 ///
 r5painlv_10 r5painlv_11 r5painlv_12 r5painlv_13)

forvalues i=1/13 {
 replace r5painlv_`i'=0 if r5pain_`i'==0
 recode r5painlv_`i' (0=0) (1=1) (3=2) (5=3)
}


*****认知/星期几
gen r5dw= .
replace r5dw = 0 if w05C402==5
replace r5dw = 1 if w05C402==1 

*****认知/年月日
gen r5dat =.
replace r5dat = 0 if w05C401==5
replace r5dat =w05C401 if inrange(w05C401,1,3)

*****认知/季节
gen r5ssn = .
replace r5ssn = 0 if w05C403==5
replace r5ssn = 1 if w05C403==1

*****认知/地点
gen r5place = .
replace r5place = 0 if w05C404==5
replace r5place = 1 if w05C404==1

*****认知/完整的地址
gen r5cgdaddr = .
replace r5cgdaddr = 0 if w05C405==5
replace r5cgdaddr = w05C405 if inrange(w05C405,1,4)

*****认知/即时记忆
gen r5imrc3 =.
replace r5imrc3 = 0  if w05C406==5
replace r5imrc3 =w05C406 if inrange(w05C406,1,3)

*****认知/注意力和计算力
gen r5ser7 =.
replace r5ser7 = 0 if  (w05C407 ==5 | w05C408==5 | w05C409==5 | w05C410==5  | w05C411==5) 
replace r5ser7 = 1 if w05C407==1
replace r5ser7 = r5ser7+1 if w05C408==1
replace r5ser7 = r5ser7+1 if w05C409==1
replace r5ser7 = r5ser7+1 if w05C410==1
replace r5ser7 = r5ser7+1 if w05C411==1

*****认知/延迟记忆
gen r5dlrc3 =.
replace r5dlrc3 =  0 if w05C412==5 
replace r5dlrc3 = w05C412 if inrange(w05C412,1,3)

*****认知/两次记忆
gen r5tr6 = .
replace r5tr6 = r5imrc + r5dlrc if !mi(r5imrc) & !mi(r5dlrc)

*****认知/命名
gen r5object1=.
replace r5object1 =  0 if w05C413==5
replace r5object1 =  1 if w05C413==1

*****认知/命名
gen r5object2=.
replace r5object2 =  0 if w05C414==5
replace r5object2 =  1 if w05C414==1

*****认知/重复句子
gen r5rpsnt= .
replace r5rpsnt = 0  if w05C415==5
replace r5rpsnt = 1  if w05C415==1

*****认知/执行力
gen r5execu= .
replace r5execu = 0  if w05C416==5
replace r5execu = 1  if w05C416==1
replace r5execu = 2  if w05C416==2
replace r5execu = 3  if w05C416==3

*****认知/闭眼说话
gen r5task= .
replace r5task = 0  if w05C417==5
replace r5task = 1  if w05C417==1 
replace r5task = 2  if w05C417==3 

*****认知/写一个完整的句子
gen r5write= .
replace r5write = 0  if w05C418==5
replace r5write = 1  if w05C418==1 

*****认知/绘图
gen r5draw= .
replace r5draw = 0  if w05C419==5
replace r5draw = 1  if w05C419==1 

recode r5task (1=0) (2=1),gen(r5task1)
egen r5cog_total=rowtotal(r5dw r5dat r5ssn r5place r5cgdaddr r5imrc3 ///
r5ser7 r5dlrc3 r5object1 r5object2 r5rpsnt r5execu r5task1 r5write r5draw),mi

*****认知障碍
recode r5cog_total (0/17=1) (18/23=2) (24/30=3),gen(r5dementia)

*****保存特定变量
keep pid r5act1 r5act2 r5act3 r5act4 r5act5 r5act6 r5act7 r5freq_1 r5freq_2 ///
r5freq_3 r5freq_4 r5freq_5 r5freq_6 r5freq_7 r5vigact_minute r5pain_1 r5pain_2 ///
r5pain_3 r5pain_4 r5pain_5 r5pain_6 r5pain_7 r5pain_8 r5pain_9 r5pain_10 ///
r5pain_11 r5pain_12 r5pain_13 r5painlv_1 r5painlv_2 r5painlv_3 r5painlv_4 ///
r5painlv_5 r5painlv_6 r5painlv_7 r5painlv_8 r5painlv_9 r5painlv_10 r5painlv_11 ///
r5painlv_12 r5painlv_13 r5dw r5dat r5ssn r5place r5cgdaddr r5imrc3 r5ser7 ///
r5dlrc3 r5tr6 r5object1 r5object2  r5rpsnt r5execu r5task r5write r5draw ///
r5cog_total r5dementia 

save "$temp_data\w05.dta",replace