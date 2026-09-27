clear all
set more off
set maxvar 120000
global root= "E:/CHARLS_中国"
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
use "$raw_data\2013charls\Demographic_Background.dta",clear
merge 1:1 ID using "$raw_data\2013charls\Health_Care_and_Insurance.dta",nogen nolabel
merge 1:1 ID using "$raw_data\2013charls\Health_Status_and_Functioning.dta",nogen nolabel
merge 1:1 ID using "$raw_data\2013charls\Individual_Income.dta",keep(1 3) nogen nolabel
merge 1:1 ID using "$raw_data\2013charls\Interviewer_Observation.dta",keep(1 3) nogen nolabel
merge 1:1 ID using "$raw_data\2013charls\Work_Retirement_and_Pension.dta",keep(1 3) nogen nolabel
merge 1:1 ID using "$raw_data\2013charls\Biomarker.dta",keep(1 3) nogen nolabel
merge m:1 householdID using "$raw_data\2013charls\Family_Information.dta",keep(1 3) nogen nolabel
merge m:1 householdID using "$raw_data\2013charls\Family_Transfer.dta",keep(1 3) nogen nolabel
merge m:1 householdID using "$raw_data\2013charls\Household_Income.dta",keep(1 3) nogen nolabel
merge m:1 householdID using "$raw_data\2013charls\Housing_Characteristics.dta",keep(1 3) nogen nolabel

*****合并wave1的牙齿数据
merge 1:1 ID using "$temp_data/teeth_charls11.dta",keep(1 3) nogen nolabel

*****残疾
gen r2disability=.
replace r2disability=1 if da005_1_==1 | da005_2_==1 | da005_3_==1 | da005_4_==1 | da005_5_==1 
replace r2disability=0 if da005_1_==2 & da005_2_==2 & da005_3_==2 & da005_4_==2 & da005_5_==2 

*****日期认知得分
*日期认知/正确回答月
gen r2mo =.
replace r2mo = 0 if !mi(dc001s1) | !mi(dc001s3) | !mi(dc002)
replace r2mo = 1 if dc001s2 == 2

*日期认知/正确回答日
gen r2dy = .
replace r2dy = 0 if !mi(dc001s1) | !mi(dc001s2) | !mi(dc002)
replace r2dy = 1 if dc001s3 == 3 

*日期认知/正确回答年
gen r2yr =.
replace r2yr = 0 if !mi(dc001s2) | !mi(dc001s3) | !mi(dc002)
replace r2yr = 1 if dc001s1 == 1 

*日期认知/正确回答周
gen r2dw =.
replace r2dw = 0 if dc002 == 2 | (!mi(dc001s1) | !mi(dc001s2) | !mi(dc001s3))
replace r2dw = 1 if dc002 == 1 

*日期认知/正确回答季节
gen r2ds =.
replace r2ds = 0 if dc003 == 2 | (!mi(dc001s1) | !mi(dc001s2) | !mi(dc001s3))
replace r2ds = 1 if dc003 == 1 

*****日期认知/正确回答日期
egen r2date_cognition = rowtotal(r2mo r2dy r2yr r2dw r2ds), mi

*****社交活动
recode da056s* (1/11=1) (.=0)

gen r2social1=da056s1 
gen r2social2=da056s2 
gen r2social3=da056s3 
gen r2social4=da056s4 
gen r2social5=da056s5 
gen r2social6=da056s6 
gen r2social7=da056s7 
gen r2social8=da056s8 
gen r2social9=da056s9 
gen r2social10=da056s10 
gen r2social11=da056s11

*****每种活动频率
forvalues i=1/11 {
  replace da057_`i'_=4 if da056s`i'==0 //4代表参加频率为0 
}

rename (da057_1_ da057_2_ da057_3_ da057_4_ da057_5_ da057_6_ da057_7_ da057_8_ ///
da057_9_ da057_10_ da057_11_) (r2freq_social1 r2freq_social2 r2freq_social3 r2freq_social4 ///
r2freq_social5 r2freq_social6 r2freq_social7 r2freq_social8 r2freq_social9 r2freq_social10 r2freq_social11)

*****2020年将志愿者和照顾病人合并，因此我们又重新给出了新的变量
replace da056s6=1 if da056s7==1
rename (da056s1 da056s2 da056s3 da056s4 da056s5 da056s6 da056s8 da056s11) ///
 (r2act_1 r2act_2 r2act_3 r2act_4 r2act_5 r2act_6 r2act_7 r2act_8)
 
gen r2freq_act_1=r2freq_social1
gen r2freq_act_2=r2freq_social2
gen r2freq_act_3=r2freq_social3
gen r2freq_act_4=r2freq_social4
gen r2freq_act_5=r2freq_social5
egen r2freq_act_6=rowmin(r2freq_social6 r2freq_social7)
gen r2freq_act_7=r2freq_social8
gen r2freq_act_8=r2freq_social11

*****是否有各种医疗保险
recode ea001s1 ea001s2 ea001s3 ea001s4 ea001s5 ea001s6 ea001s7 ea001s8 ///
ea001s9 ea001s10 (.=0) (1/10=1)

rename (ea001s1 ea001s2 ea001s3 ea001s4 ea001s5 ea001s6 ea001s7 ea001s8 ///
ea001s9 ea001s10) (r2ea001s1 r2ea001s3 r2ea001s4 r2ea001s2 r2ea001s5 r2ea001s6 ///
r2ea001s7 r2ea001s8 r2ea001s9 r2ea001s11)
 
*****跌倒
recode da023 (1=1) (2=0) (else=.),gen(r2fall_down)  

*****是否佩戴眼镜
recode da032 (1=1) (2=2) (3=0) (4=1) (else=.),gen(r2glass)

*****远视视力
replace da033=5 if mi(da033) & da032==2
recode da033 (1=5) (2=4) (3=3) (4=2) (5=1) (else=.),gen(r2eyesight_distance) 

*****近视视力 
replace da034=5 if mi(da034) & da032==2
recode da034 (1=5) (2=4) (3=3) (4=2) (5=1) (else=.),gen(r2eyesight_close)  

*****听力
replace da038=zda038 if zda038==1 & mi(da038)
recode da038 (1=1) (2=0) (else=.),gen(r2hear_aid)  
recode da039 (1=5) (2=4) (3=3) (4=2) (5=1) (else=.),gen(r2hear) 

*****睡眠时间
rename (da049 da050) (r2sleep_night r2sleep_nap) 

*****疼痛
forvalues i=1/15 {
  recode da042s`i' (1/15=1) 
  replace da042s`i'=0 if !mi(wb16) & mi(da042s`i')
  rename da042s`i' r2da042s`i'
}

*****掉光牙齿
recode da040 (1=1) (2=0) (else=.),gen(r2teeth)
replace r2teeth=1 if r1teeth==1

*****髋骨骨折
recode da025 (1=1) (2=0) (else=.),gen(r2hip)

***身体活动时间区间
gen r2vgactime=.  //高强度身体活动时间
replace r2vgactime=0 if da051_1_==2
replace r2vgactime=20 if da051_1_==1 & da053_1_==1  & da054_1_==1
replace r2vgactime=75 if da051_1_==1 & da053_1_==1  & da054_1_==2
replace r2vgactime=180 if da051_1_==1 & da053_1_==2 & da055_1_==1
replace r2vgactime=240 if da051_1_==1 & da053_1_==2 & da055_1_==2

gen r2mdactime=.  //中等强度身体活动时间
replace r2mdactime=0 if da051_2_==2
replace r2mdactime=20 if da051_2_==1 & da053_2_==1  & da054_2_==1
replace r2mdactime=75 if da051_2_==1 & da053_2_==1  & da054_2_==2
replace r2mdactime=180 if da051_2_==1 & da053_2_==2 & da055_2_==1
replace r2mdactime=240 if da051_2_==1 & da053_2_==2 & da055_2_==2
 
gen r2ltactime=.  //轻度身体活动时间
replace r2ltactime=0 if da051_3_==2
replace r2ltactime=20 if da051_3_==1 & da053_3_==1 & da054_3_==1
replace r2ltactime=75 if da051_3_==1 & da053_3_==1 & da054_3_==2
replace r2ltactime=180 if da051_3_==1 & da053_3_==2 & da055_3_==1
replace r2ltactime=240 if da051_3_==1 & da053_3_==2 & da055_3_==2 

*****是否知道自己患有慢性病
recode da008_1_ da008_5_ da008_11_ (1=1) (2/3=0)
rename (da008_1_ da008_5_ da008_11_) (r2hibpe_self r2lunge_self r2psyche_self)

*****慢性病时间
forvalues i=1/14 {
  replace da009_1_`i'_=zda009_1_`i'_ if mi(da009_1_`i'_) & !mi(zda009_1_`i'_)
  replace da009_2_`i'_=zda009_2_`i'_ if mi(da009_2_`i'_) & !mi(zda009_2_`i'_)
  rename (da009_1_`i'_ da009_2_`i'_) (r2da009_1_`i'_ r2da009_2_`i'_)
}

*****癌症部位
forvalues i=1/23 {
  recode da017s`i' (`i'=1) (else=.),gen(r2da017s`i')
}

*****取暖燃料
recode i021 (1 3 4 5=0) (2 6=1) (7=.),gen(r2clean_heat)
replace r2clean_heat=0 if i020==1

*****做饭燃料
recode i022 (2 3 4 5=0) (1 6=1) (7=.),gen(r2clean_cook)

*****房间数量
recode i012_1 i012_2 (-9999=.)
egen r2room=rowtotal(i012_1 i012_2),mi

*****是否有自来水
recode i017 (1=1) (2=0), gen(r2water)

*****是否有电
recode i016 (1=1) (2=0), gen(r2electricity)

*****厕所卫生差
gen r2toilet=0 if !mi(i012_3)
replace r2toilet=1 if i012_3==0 | i015==2

*****建筑材料差
recode i004 (1/3=0) (4/10=1),gen(r2build)

*****保留所需变量
keep ID r2date_cognition r2ea001s1 r2ea001s3 r2ea001s4 r2ea001s2 r2ea001s5 r2ea001s6 ///
r2ea001s7 r2ea001s8 r2ea001s9 r2ea001s11 r2disability r2water r2fall_down r2glass ///
r2eyesight_distance r2eyesight_close r2hear_aid r2hear r2sleep_night r2sleep_nap /// 
r2da042s1 r2da042s2 r2da042s3 r2da042s4 r2da042s5 r2da042s6 r2da042s7 r2da042s8 /// 
r2da042s9 r2da042s10 r2da042s11 r2da042s12 r2da042s13 r2da042s14 r2da042s15 r2teeth ///
r2hip r2ltactime r2mdactime r2vgactime r2da009_1_1_ ///
r2da009_1_2_ r2da009_1_3_ r2da009_1_4_ r2da009_1_5_ r2da009_1_6_ r2da009_1_7_ r2da009_1_8_ /// 
r2da009_1_9_ r2da009_1_10_ r2da009_1_11_ r2da009_1_12_ r2da009_1_13_ r2da009_1_14_ /// 
r2da009_2_1_ r2da009_2_2_ r2da009_2_3_ r2da009_2_4_ r2da009_2_5_ r2da009_2_6_  ///
r2da009_2_7_ r2da009_2_8_ r2da009_2_9_ r2da009_2_10_ r2da009_2_11_ r2da009_2_12_  ///
r2da009_2_13_ r2da009_2_14_ r2hibpe_self r2lunge_self r2psyche_self  ///
r2da017s1 r2da017s2 r2da017s3 r2da017s4 r2da017s5 r2da017s6 r2da017s7 r2da017s8 /// 
r2da017s9 r2da017s10 r2da017s11 r2da017s12 r2da017s13 r2da017s14 r2da017s15 /// 
r2da017s16 r2da017s17 r2da017s18 r2da017s19 r2da017s20 r2da017s21 r2da017s22 ///
r2da017s23 r2ds r2act_1 r2act_2 r2act_3 r2act_4 r2act_5 r2act_6 r2act_7 r2act_8 /// 
r2social1 r2social2 r2social3 r2social4 r2social5 r2social6 r2social7 r2social8 /// 
r2social9 r2social10 r2social11 r2freq_act_1 r2freq_act_2 r2freq_act_3 r2freq_act_4 /// 
r2freq_act_5 r2freq_act_6 r2freq_act_7 r2freq_act_8 r2freq_social1 r2freq_social2 /// 
r2freq_social3 r2freq_social4 r2freq_social5 r2freq_social6 r2freq_social7 r2freq_social8 /// 
r2freq_social9 r2freq_social10 r2freq_social11 r2clean_heat r2clean_cook ///
r2build r2toilet r2electricity r2water r2room
 
*****保存数据集  
save "$temp_data/charls13.dta",replace	 //保存数据

*****因wave3数据需要匹配wave2数据,在此单独保存
keep ID r2da009_1_1_ r2da009_1_2_ r2da009_1_3_ r2da009_1_4_ r2da009_1_5_ r2da009_1_6_ ///
r2da009_1_7_ r2da009_1_8_ r2da009_1_9_ r2da009_1_10_ r2da009_1_11_ r2da009_1_12_ ///
r2da009_1_13_ r2da009_1_14_ r2da009_2_1_ r2da009_2_2_ r2da009_2_3_ r2da009_2_4_ ///
r2da009_2_5_ r2da009_2_6_ r2da009_2_7_ r2da009_2_8_ r2da009_2_9_ r2da009_2_10_ ///
r2da009_2_11_ r2da009_2_12_ r2da009_2_13_ r2da009_2_14_

*****保存数据集  
save "$temp_data/charls13_chronic.dta",replace	 //单独保存wave2的慢性病数据