clear all
set more off
set maxvar 20000
global root= "d:\跨国数据\跨国数据\CHARLS_中国"
***************************** 注：运行前更改上述路径 ***************************
global dofiles=      "$root\Dofiles"
global raw_data=     "$root\Raw_data"
global working_data= "$root\Working_data"
global temp_data=    "$root\Temp_data"

cap mkdir "$raw_data"
cap mkdir "$temp_data"
cap mkdir "$working_data"
cap mkdir "$dofiles"

*Summary: 七大老年健康数据库训练营
*Authors: Shawn (微信公众账号丁点帮你 & 顶刊研习社)
*Date Published: August 1, 2024
*****修订: 260525 补充 wave4 卒中变量 r4stroke（原脚本遗漏 da007_8_）
********************************************************************************
use "$raw_data/2018charls/Cognition.dta", clear
merge 1:1 ID using "$raw_data/2018charls/Health_Status_and_Functioning.dta",nogen nolabel
merge 1:1 ID using "$raw_data/2018charls/Demographic_Background.dta",nogen nolabel
merge 1:1 ID using "$raw_data/2018charls/Health_Care_and_Insurance.dta",nogen nolabel
merge 1:1 ID using "$raw_data/2018charls/Individual_Income.dta",nogen nolabel
merge 1:1 ID using "$raw_data/2018charls/Pension.dta",nogen nolabel
merge 1:1 ID using "$raw_data/2018charls/Work_Retirement.dta",nogen nolabel
merge m:1 householdID using "$raw_data/2018charls/Household_Income.dta",keep(1 3) nogen nolabel
merge m:1 householdID using "$raw_data/2018charls/Family_Transfer.dta",keep(1 3) nogen nolabel
merge m:1 householdID using "$raw_data/2018charls/Household_Income.dta",keep(1 3) nogen nolabel
merge m:1 householdID using "$raw_data/2018charls/Housing.dta",keep(1 3) nogen nolabel

*****将wave3的慢病匹配过来
merge 1:1 ID using "$temp_data/charls15_chronic.dta",keep(1 3) nogen nolabel

*****残疾
forvalues i=1/5 {
  replace da005_`i'_=zdisability_`i'_ if mi(da005_`i'_) & !mi(zdisability_`i'_)
}
gen r4disability=.
replace r4disability=1 if da005_1_==1 | da005_2_==1 | da005_3_==1 | da005_4_==1 | da005_5_==1
replace r4disability=0 if da005_1_==2 & da005_2_==2 & da005_3_==2 & da005_4_==2 & da005_5_==2

*****日期认知得分
*日期认知/正确回答月
gen r4mo = .
replace r4mo = 0 if dc006_w4 == 5
replace r4mo = 1 if dc006_w4 == 1

*日期认知/正确回答日
gen r4dy = .
replace r4dy = 0 if dc003_w4 == 5
replace r4dy = 1 if dc003_w4 == 1

*日期认知/正确回答年
gen r4yr = .
replace r4yr = .p if db032 == 4
replace r4yr = 0 if dc001_w4 == 5
replace r4yr = 1 if dc001_w4 == 1

*日期认知/正确回答星期
gen r4dw = .
replace r4dw = 0 if dc005_w4 == 5
replace r4dw = 1 if dc005_w4 == 1

*日期认知/正确回答季节
gen r4ds = .
replace r4ds = 0 if dc002_w4 == 5
replace r4ds = 1 if dc002_w4 == 1

*日期认知/正确回答日期
egen r4date_cognition = rowtotal(r4mo r4dy r4yr r4dw r4ds),mi


*****社交活动
recode da056_s* (1/11=1)
gen r4social1=da056_s1
gen r4social2=da056_s2
gen r4social3=da056_s3
gen r4social4=da056_s4
gen r4social5=da056_s5
gen r4social6=da056_s6
gen r4social7=da056_s7
gen r4social8=da056_s8
gen r4social9=da056_s9
gen r4social10=da056_s10
gen r4social11=da056_s11

*****每种活动频率
forvalues i=1/11 {
  replace da057_`i'_=4 if da056_s`i'==0 //4代表参加频率为0
}
rename (da057_1_ da057_2_ da057_3_ da057_4_ da057_5_ da057_6_ da057_7_ da057_8_ ///
da057_9_ da057_10_ da057_11_) (r4freq_social1 r4freq_social2 r4freq_social3 r4freq_social4 ///
r4freq_social5 r4freq_social6 r4freq_social7 r4freq_social8 r4freq_social9 r4freq_social10 r4freq_social11)

*****2020年将志愿者和照顾病人合并，因此我们又重新给出了新的变量
replace da056_s6=1 if da056_s7==1
rename (da056_s1 da056_s2 da056_s3 da056_s4 da056_s5 da056_s6 da056_s8 da056_s11) ///
 (r4act_1 r4act_2 r4act_3 r4act_4 r4act_5 r4act_6 r4act_7 r4act_8)

gen r4freq_act_1=r4freq_social1
gen r4freq_act_2=r4freq_social2
gen r4freq_act_3=r4freq_social3
gen r4freq_act_4=r4freq_social4
gen r4freq_act_5=r4freq_social5
egen r4freq_act_6=rowmin(r4freq_social6 r4freq_social7)
gen r4freq_act_7=r4freq_social8
gen r4freq_act_8=r4freq_social11

*****民族
recode bg001_w4 (1=1) (2/11=0) (else=.),gen(nation)

*****各种医保类型
recode ea001_w4_s* (1/11=1)
rename (ea001_w4_s1 ea001_w4_s2 ea001_w4_s3 ea001_w4_s4 ea001_w4_s5 ///
 ea001_w4_s6 ea001_w4_s7 ea001_w4_s8 ea001_w4_s9 ea001_w4_s10 ea001_w4_s11) ///
 (r4ea001s1 r4ea001s2 r4ea001s3 r4ea001s4 r4ea001s5 r4ea001s6 r4ea001s7 ///
 r4ea001s8 r4ea001s9 r4ea001s10 r4ea001s11)

*****跌倒
replace da023_w4=da023 if mi(da023_w4) & !mi(da023)
recode da023_w4 (1=1) (2=0) (else=.),gen(r4fall_down)

*****是否佩戴眼镜
recode da032 (1=1) (2=2) (3=0) (4=1) (else=.),gen(r4glass)

*****远视视力
replace da033=5 if mi(da033) & da032==2
recode da033 (1=5) (2=4) (3=3) (4=2) (5=1) (else=.),gen(r4eyesight_distance)

*****近视视力
replace da034=5 if mi(da034) & da032==2
recode da034 (1=5) (2=4) (3=3) (4=2) (5=1) (else=.),gen(r4eyesight_close)

*****听力
recode da038_w4 (1=1) (2=0) (else=.),gen(r4hear_aid)
recode da039 (1=5) (2=4) (3=3) (4=2) (5=1) (else=.),gen(r4hear)

*****睡眠时间
rename (da049 da050) (r4sleep_night r4sleep_nap)

*****疼痛
forvalues i=1/15 {
  recode da042_s`i' (1/15=1)
  replace da042_s`i'=0 if da041_w4==1
  rename da042_s`i' r4da042s`i'
}

*****牙齿
replace da040=1 if mi(da040) & ztooth==1
recode da040 (1=1) (2=0) (else=.),gen(r4teeth)

*****髋骨骨折
replace da025=da025_w4 if mi(da025)
recode da025 (1=1) (2=0) (else=.),gen(r4hip)

*****身体活动的时间区间
gen  r4vgactime=.
replace r4vgactime=0 if da051_1_==2
replace r4vgactime=20 if da051_1_==1 & da053_1_==1 & da054_1_==1
replace r4vgactime=75 if da051_1_==1 & da053_1_==1 & da054_1_==2
replace r4vgactime=180 if da051_1_==1 & da053_1_==2 & da055_1_==1
replace r4vgactime=240 if da051_1_==1 & da053_1_==2 & da055_1_==2

gen r4mdactime=.
replace r4mdactime=0 if da051_2_==2
replace r4mdactime=20 if da051_2_==1 & da053_2_==1 & da054_2_==1
replace r4mdactime=75 if da051_2_==1 & da053_2_==1 & da054_2_==2
replace r4mdactime=180 if da051_2_==1 & da053_2_==2 & da055_2_==1
replace r4mdactime=240 if da051_2_==1 & da053_2_==2 & da055_2_==2

gen r4ltactime=.
replace r4ltactime=0 if da051_3_==2
replace r4ltactime=20 if da051_3_==1 & da053_3_==1 & da054_3_==1
replace r4ltactime=75 if da051_3_==1 & da053_3_==1 & da054_3_==2
replace r4ltactime=180 if da051_3_==1 & da053_3_==2 & da055_3_==1
replace r4ltactime=240 if da051_3_==1 & da053_3_==2 & da055_3_==2

*****是否知道自己患有慢性病
recode da008_w2_1_1_ da008_w2_1_5_ da008_w2_1_11_ (1=1) (2/3=0)
rename (da008_w2_1_1_ da008_w2_1_5_ da008_w2_1_11_) (r4hibpe_self r4lunge_self r4psyche_self)

*****医生是否诊断患有中风 (260525补充：原脚本遗漏此变量)
*原始变量：da007_8_ = "Diagnosed with Stroke by a Doctor"，1=Yes 2=No
recode da007_8_ (1=1) (2=0) (else=.), gen(r4stroke_260525)

*****慢性病时间
rename (da009_1_1_ da009_1_2_ da009_1_3_ da009_1_4_ da009_1_5_ da009_1_6_ da009_1_7_ ///
 da009_1_8_ da009_1_9_ da009_1_10_ da009_1_11_ da009_1_12_ da009_1_13_ ///
 da009_1_14_ da009_2_1_ da009_2_2_ da009_2_3_ da009_2_4_ da009_2_5_ da009_2_6_ da009_2_7_ ///
 da009_2_8_ da009_2_9_ da009_2_10_ da009_2_11_ da009_2_12_ da009_2_13_ da009_2_14_) ///
 (r4da009_1_1_ r4da009_1_2_ r4da009_1_3_ r4da009_1_4_ r4da009_1_5_ r4da009_1_6_ r4da009_1_7_ ///
 r4da009_1_8_ r4da009_1_9_ r4da009_1_10_ r4da009_1_11_ r4da009_1_12_ r4da009_1_13_ ///
 r4da009_1_14_ r4da009_2_1_ r4da009_2_2_ r4da009_2_3_ r4da009_2_4_ r4da009_2_5_ r4da009_2_6_  r4da009_2_7_ ///
 r4da009_2_8_ r4da009_2_9_ r4da009_2_10_ r4da009_2_11_ r4da009_2_12_ r4da009_2_13_ r4da009_2_14_)

*****时间替换
forvalues i=1/14 {
 replace r4da009_1_`i'_= r3da009_1_`i'_ if mi(r4da009_1_`i'_) & !mi(r3da009_1_`i'_)
 replace r4da009_1_`i'_= r3da009_1_`i'_ if mi(r4da009_1_`i'_) & !mi(r3da009_1_`i'_)
 replace r4da009_2_`i'_= r3da009_2_`i'_ if mi(r4da009_2_`i'_) & !mi(r3da009_2_`i'_)
 replace r4da009_2_`i'_= r3da009_2_`i'_ if mi(r4da009_2_`i'_) & !mi(r3da009_2_`i'_)
}

*****子女关系满意度
recode dc044_w3 (1=5) (2=4) (3=3) (4=2) (5=1) (6=.),gen(r4sati_child)

*****癌症部位
forvalues i=1/23 {
  recode da017_s`i' (`i'=1) (else=.),gen(r4da017s`i')
}

*****取暖燃料
recode i021_w4 (1 3 4 5 8=0) (2 6=1) (7=.),gen(r4clean_heat)
replace r4clean_heat=0 if i020==2

*****做饭燃料
recode i022_w4 (2 3 4 5 8=0) (1 6=1) (7=.),gen(r4clean_cook)

*****房间数量
egen r4room=rowtotal(i012_1 i012_2),mi

*****是否有自来水
recode i017 (1=1) (2=0), gen(r4water)

*****是否有电
recode i016 (1=1) (2=0), gen(r4electricity)

*****厕所卫生差
gen r4toilet=0 if !mi(i012_3)
replace r4toilet=1 if i012_3==0 | i015==2

*****建筑材料差
recode i004 (1=0) (2/7=1),gen(r4build)

*****保存所需变量（260525：在原始keep列表基础上增加 r4stroke_260525）
keep ID r4date_cognition nation r4ea001s1 r4ea001s2 r4ea001s3 r4ea001s4 r4ea001s5 ///
r4ea001s6 r4ea001s7 r4ea001s8 r4ea001s9 r4ea001s10 r4ea001s11 r4disability r4water ///
r4fall_down r4glass r4eyesight_distance r4eyesight_close r4hear_aid r4hear ///
r4sleep_night r4sleep_nap r4da042s1 r4da042s2 r4da042s3 r4da042s4 r4da042s5 ///
r4da042s6 r4da042s7 r4da042s8 r4da042s9 r4da042s10 r4da042s11 r4da042s12 ///
r4da042s13 r4da042s14 r4da042s15 r4teeth r4hip r4ltactime r4mdactime r4vgactime ///
r4da009_1_1_ r4da009_1_2_ r4da009_1_3_ r4da009_1_4_ r4da009_1_5_ r4da009_1_6_ ///
r4da009_1_7_ r4da009_1_8_ r4da009_1_9_ r4da009_1_10_  r4da009_1_11_ r4da009_1_12_ ///
r4da009_1_13_ r4da009_1_14_ r4da009_2_1_ r4da009_2_2_ r4da009_2_3_ ///
r4da009_2_4_ r4da009_2_5_ r4da009_2_6_  r4da009_2_7_ r4da009_2_8_ r4da009_2_9_  ///
r4da009_2_10_ r4da009_2_11_ r4da009_2_12_ r4da009_2_13_ r4da009_2_14_ r4hibpe_self ///
r4lunge_self r4psyche_self r4sati_child r4stroke_260525 r4da017s1 r4da017s2 r4da017s3 ///
r4da017s4 r4da017s5 r4da017s6 r4da017s7 r4da017s8 r4da017s9 r4da017s10 r4da017s11 ///
r4da017s12 r4da017s13 r4da017s14 r4da017s15 r4da017s16 r4da017s17 r4da017s18 ///
r4da017s19 r4da017s20 r4da017s21 r4da017s22 r4da017s23 r4ds r4act_1 r4act_2 r4act_3 ///
r4act_4 r4act_5 r4act_6 r4act_7 r4act_8  r4freq_act_1 r4freq_act_2 r4freq_act_3 ///
r4freq_act_4 r4freq_act_5 r4freq_act_6 r4freq_act_7 r4freq_act_8 r4social1 ///
r4social2 r4social3 r4social4 r4social5 r4social6 r4social7 r4social8 ///
r4social9 r4social10 r4social11 r4freq_social1 r4freq_social2 r4freq_social3 ///
r4freq_social4 r4freq_social5 r4freq_social6 r4freq_social7 r4freq_social8 ///
r4freq_social9 r4freq_social10 r4freq_social11 r4clean_heat r4clean_cook ///
r4build r4toilet r4electricity r4water r4room

*****保存数据（覆盖同名temp文件，供 no.6_数据合并_260525.do 调用）
save "$temp_data/charls18.dta",replace
