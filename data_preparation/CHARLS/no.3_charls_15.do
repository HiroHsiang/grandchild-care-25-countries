clear all
set more off
set maxvar 20000
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
use "$raw_data/2015charls/Demographic_Background.dta",clear
merge 1:1 ID using "$raw_data/2015charls/Health_Status_and_Functioning.dta",nogen nolabel
merge 1:1 ID using "$raw_data/2015charls/Health_Care_and_Insurance.dta",keep(1 3) nogen nolabel		
merge 1:1 ID using "$raw_data/2015charls/Individual_Income.dta",keep(1 3) nogen nolabel	
merge 1:1 ID using "$raw_data/2015charls/Biomarker.dta",keep(1 3) nogen nolabel
merge 1:1 ID using "$raw_data/2015charls/Blood.dta",keep(1 3) nogen nolabel	
merge m:1 householdID using "$raw_data/2015charls/Household_Income.dta",keep(1 3) nogen nolabel	
merge m:1 householdID using "$raw_data/2015charls/Family_Information.dta",keep(1 3) nogen nolabel	
merge m:1 householdID using "$raw_data/2015charls/Family_Transfer.dta",keep(1 3) nogen nolabel	
merge m:1 householdID using "$raw_data/2015charls/Housing_Characteristics.dta",keep(1 3) nogen nolabel

*****将wave2的慢病数据匹配过来	
merge 1:1 ID using "$temp_data/charls13_chronic.dta",keep(1 3) nogen nolabel

*****残疾
forvalues i=1/5 {
  replace da005_`i'_=zda005_`i'_ if mi(da005_`i'_) & !mi(zda005_`i'_)
}

gen r3disability=.
replace r3disability=1 if da005_1_==1 | da005_2_==1 | da005_3_==1 | da005_4_==1 | da005_5_==1 
replace r3disability=0 if da005_1_==2 & da005_2_==2 & da005_3_==2 & da005_4_==2 & da005_5_==2 		
				
*****日期认知得分
*日期认知/正确回答月
gen r3mo = .
replace r3mo = 0 if !mi(dc001s1) | !mi(dc001s3) | !mi(dc002)
replace r3mo = 1 if dc001s2 == 2

*日期认知/正确回答日
gen r3dy = .
replace r3dy = 0 if !mi(dc001s1) | !mi(dc001s2) | !mi(dc002)
replace r3dy = 1 if dc001s3 == 3 

*日期认知/正确回答年
gen r3yr =.
replace r3yr = 0 if !mi(dc001s2) | !mi(dc001s3) | !mi(dc002)
replace r3yr = 1 if dc001s1 == 1 

*日期认知/正确回答周
gen r3dw =.
replace r3dw = 0 if dc002 == 2 | (!mi(dc001s1) | !mi(dc001s2) | !mi(dc001s3))
replace r3dw = 1 if dc002 == 1 

*日期认知/正确回答季节
gen r3ds =.
replace r3ds = 0 if dc003 == 2 | (!mi(dc001s1) | !mi(dc001s2) | !mi(dc001s3))
replace r3ds = 1 if dc003 == 1 

*日期认知/正确回答日期
egen r3date_cognition = rowtotal(r3mo r3dy r3yr r3dw r3ds), mi

*****社交活动
recode da056s* (1/11=1) (.=0)
gen r3social1=da056s1 
gen r3social2=da056s2 
gen r3social3=da056s3 
gen r3social4=da056s4 
gen r3social5=da056s5 
gen r3social6=da056s6 
gen r3social7=da056s7 
gen r3social8=da056s8 
gen r3social9=da056s9 
gen r3social10=da056s10 
gen r3social11=da056s11

*****每种活动频率
forvalues i=1/11 {
  replace da057_`i'_=4 if da056s`i'==0 //4代表参加频率为0 
}

rename (da057_1_ da057_2_ da057_3_ da057_4_ da057_5_ da057_6_ da057_7_ da057_8_ ///
da057_9_ da057_10_ da057_11_) (r3freq_social1 r3freq_social2 r3freq_social3 r3freq_social4 ///
r3freq_social5 r3freq_social6 r3freq_social7 r3freq_social8 r3freq_social9 r3freq_social10 r3freq_social11)

*****2020年将志愿者和照顾病人合并，因此我们又重新给出了新的变量
replace da056s6=1 if da056s7==1
rename (da056s1 da056s2 da056s3 da056s4 da056s5 da056s6 da056s8 da056s11) ///
 (r3act_1 r3act_2 r3act_3 r3act_4 r3act_5 r3act_6 r3act_7 r3act_8)
 
gen r3freq_act_1=r3freq_social1
gen r3freq_act_2=r3freq_social2
gen r3freq_act_3=r3freq_social3
gen r3freq_act_4=r3freq_social4
gen r3freq_act_5=r3freq_social5
egen r3freq_act_6=rowmin(r3freq_social6 r3freq_social7)
gen r3freq_act_7=r3freq_social8
gen r3freq_act_8=r3freq_social11

*****各种医保类型
forvalue i=1/10{
 gen r3ins`i'=. 
 replace r3ins`i'=0 if !mi(ea001_w3_1_`i'_) | !mi(ea001_w3_2_`i'_ ) | !mi(ea001_w3_3_`i'_)
 replace r3ins`i'=1 if ea001_w3_2_`i'_==1 | ea001_w3_3_`i'_==1
 replace r3ins`i'=. if mi(ea001_w3_2_`i'_) & mi(ea001_w3_3_`i'_)
}
rename (r3ins1 r3ins2 r3ins3 r3ins4 r3ins5 r3ins6 r3ins7 r3ins8 r3ins9 r3ins10) ///
(r3ea001s1 r3ea001s3 r3ea001s4 r3ea001s2 r3ea001s5 r3ea001s6 r3ea001s7 r3ea001s8 ///
r3ea001s9 r3ea001s11)

*****血检指标
rename (Blood_weight bl_fasting bl_wbc bl_mcv bl_plt bl_bun bl_glu bl_crea ///
  bl_cho bl_tg bl_hdl bl_ldl bl_crp bl_hbalc bl_ua bl_hct bl_hgb bl_cysc ///
  bl_top_coding_tg) (r3bloodweight r3bl_fasting r3bl_wbc r3bl_mcv r3bl_plt ///
  r3bl_bun r3bl_glu r3bl_crea r3bl_cho r3bl_tg r3bl_hdl r3bl_ldl r3bl_crp ///
  r3bl_hbalc r3bl_ua r3bl_hct r3bl_hgb r3bl_cysc r3bl_top_coding_tg)
  
*****跌倒
recode da023 (1=1) (2=0) (else=.),gen(r3fall_down)  

*****是否佩戴眼镜
recode da032 (1=1) (2=2) (3=0) (4=1) (else=.),gen(r3glass)

*****远视视力
replace da033=5 if mi(da033) & da032==2
recode da033 (1=5) (2=4) (3=3) (4=2) (5=1) (else=.),gen(r3eyesight_distance) 
 
*****近视视力
replace da034=5 if mi(da034) & da032==2
recode da034 (1=5) (2=4) (3=3) (4=2) (5=1) (else=.),gen(r3eyesight_close)  

*****听力
replace da038=zda038 if zda038==1 & mi(da038)
recode da038 (1=1) (2=0) (else=.),gen(r3hear_aid)  
recode da039 (1=5) (2=4) (3=3) (4=2) (5=1) (else=.),gen(r3hear)  

*****睡眠时间
rename (da049 da050) (r3sleep_night r3sleep_nap) 

*****疼痛
forvalues i=1/15 {
  recode da042s`i' (1/15=1) 
  replace da042s`i'=0 if !mi(da041) & mi(da042s`i')
  rename da042s`i' r3da042s`i'
}

*****掉光牙齿
replace da040=1 if mi(da040) & zda040==1
recode da040 (1=1) (2=0) (else=.),gen(r3teeth)

*****髋骨骨折
recode da025 (1=1) (2=0) (else=.),gen(r3hip)

*****身体活动时长区间
gen r3vgactime=.     //每次重度身体活动的时长
replace r3vgactime=20 if da051_1_==1 & da053_1_==1 & da054_1_==1
replace r3vgactime=75 if da051_1_==1 & da053_1_==1 & da054_1_==2
replace r3vgactime=180 if da051_1_==1 & da053_1_==2 & da055_1_==1
replace r3vgactime=240 if da051_1_==1 & da053_1_==2 & da055_1_==2

gen r3mdactime=.     //每次中度身体活动的时长
replace r3mdactime=20 if da051_2_==1 & da053_2_==1 & da054_2_==1
replace r3mdactime=75 if da051_2_==1 & da053_2_==1 & da054_2_==2
replace r3mdactime=180 if da051_2_==1 & da053_2_==2 & da055_2_==1
replace r3mdactime=240 if da051_2_==1 & da053_2_==2 & da055_2_==2

gen r3ltactime=.     //每次轻度身体活动的时长
replace r3ltactime=20 if da051_3_==1 & da053_3_==1 & da054_3_==1
replace r3ltactime=75 if da051_3_==1 & da053_3_==1 & da054_3_==2
replace r3ltactime=180 if da051_3_==1 & da053_3_==2 & da055_3_==1
replace r3ltactime=240 if da051_3_==1 & da053_3_==2 & da055_3_==2

*****是否知道自己患有慢性病
recode da008_1_ da008_5_ da008_11_ (1=1) (2/3=0)
rename (da008_1_ da008_5_ da008_11_) (r3hibpe_self r3lunge_self r3psyche_self)

*****慢性病时间
forvalues i=1/14 {
 gen r3da009_1_`i'_=zda009_1_`i'_
 replace r3da009_1_`i'_=da009_1_1_ if mi(r3da009_1_`i'_)
 replace r3da009_1_`i'_=r2da009_1_`i'_ if mi(r3da009_1_`i'_) & !mi(r2da009_1_`i'_)
 gen r3da009_2_`i'_=zda009_2_`i'_
 replace r3da009_2_`i'_=da009_2_`i'_ if mi(r3da009_2_`i'_)
 replace r3da009_2_`i'_=r2da009_2_`i'_ if mi(r3da009_2_`i'_) & !mi(r2da009_2_`i'_)
}

*****子女关系满意度
recode dc044_w3 (1=5) (2=4) (3=3) (4=2) (5=1) (6=.),gen(r3sati_child) 

*****癌症部位
forvalues i=1/23 {
  recode da017s`i' (`i'=1) (else=.),gen(r3da017s`i')
}

*****取暖燃料
recode i021 (1 3 4 5=0) (2 6=1) (7=.),gen(r3clean_heat)
replace r3clean_heat=0 if i020==2

*****做饭燃料
recode i022 (2 3 4 5=0) (1 6=1) (7=.),gen(r3clean_cook)

*****房间数量
egen r3room=rowtotal(i012_1 i012_2),mi

*****是否有自来水
recode i017 (1=1) (2=0), gen(r3water)

*****厕所卫生差
gen r3toilet=0 if !mi(i012_3)
replace r3toilet=1 if i012_3==0 | i015==2

*****建筑材料差
recode i004 (1=0) (2/7=1),gen(r3build)

*****保存所需变量  
keep ID r3date_cognition r3ea001s1 r3ea001s2 r3ea001s3 r3ea001s4 r3ea001s5 ///
r3ea001s6 r3ea001s7 r3ea001s8 r3ea001s9 r3ea001s11 r3disability r3water r3bloodweight ///
r3bl_fasting r3bl_wbc r3bl_mcv r3bl_plt r3bl_bun r3bl_glu r3bl_crea r3bl_cho /// 
r3bl_tg r3bl_hdl r3bl_ldl r3bl_crp r3bl_hbalc r3bl_ua r3bl_hct r3bl_hgb ///
r3bl_cysc r3bl_top_coding_tg r3fall_down r3glass r3eyesight_distance r3eyesight_close ///
r3hear_aid r3hear r3sleep_night r3sleep_nap r3da042s1 r3da042s2 r3da042s3 r3da042s4 /// 
r3da042s5 r3da042s6 r3da042s7 r3da042s8 r3da042s9 r3da042s10 r3da042s11 r3da042s12 /// 
r3da042s13 r3da042s14 r3da042s15 r3teeth r3hip r3ltactime r3mdactime r3vgactime /// 
r3hibpe_self r3lunge_self r3psyche_self r3da009_1_1_ r3da009_1_2_ r3da009_1_3_ ///
r3da009_1_4_ r3da009_1_5_ r3da009_1_6_ r3da009_1_7_ r3da009_1_8_ r3da009_1_9_  ///
r3da009_1_10_ r3da009_1_11_ r3da009_1_12_ r3da009_1_13_ r3da009_1_14_ r3da009_2_1_ ///
r3da009_2_2_ r3da009_2_3_ r3da009_2_4_ r3da009_2_5_ r3da009_2_6_ r3da009_2_7_ ///
r3da009_2_8_  r3da009_2_9_ r3da009_2_10_ r3da009_2_11_ r3da009_2_12_ r3da009_2_13_ ///
r3da009_2_14_ r3sati_child r3da017s1 r3da017s2 r3da017s3 r3da017s4 r3da017s5 ///
r3da017s6 r3da017s7 r3da017s8 r3da017s9 r3da017s10 r3da017s11 r3da017s12 r3da017s13 ///
r3da017s14 r3da017s15 r3da017s16 r3da017s17 r3da017s18 r3da017s19 r3da017s20 r3da017s21 ///
r3da017s22 r3da017s23 r3ds r3act_1 r3act_2 r3act_3 r3act_4 r3act_5 r3act_6 ///
r3act_7 r3act_8  r3freq_act_1 r3freq_act_2 r3freq_act_3 r3freq_act_4 r3freq_act_5 ///
r3freq_act_6 r3freq_act_7 r3freq_act_8 r3social1 r3social2 r3social3 r3social4 ///
r3social5 r3social6 r3social7 r3social8 r3social9 r3social10 r3social11 ///
r3freq_social1 r3freq_social2 r3freq_social3 r3freq_social4 r3freq_social5 ///
r3freq_social6 r3freq_social7 r3freq_social8 r3freq_social9 r3freq_social10 ///
r3freq_social11 r3clean_heat r3clean_cook r3build r3toilet r3water r3room
  
*****保存数据集
save "$temp_data/charls15.dta",replace	 //保存数据

*****保存所需变量
keep ID r3da009_1_1_ r3da009_1_2_ ///
  r3da009_1_3_ r3da009_1_4_ r3da009_1_5_ r3da009_1_6_ ///
  r3da009_1_7_ r3da009_1_8_ r3da009_1_9_ r3da009_1_10_ r3da009_1_11_ r3da009_1_12_ ///
  r3da009_1_13_ r3da009_1_14_ r3da009_2_1_ r3da009_2_2_ r3da009_2_3_ r3da009_2_4_ ///
  r3da009_2_5_ r3da009_2_6_ r3da009_2_7_ r3da009_2_8_ r3da009_2_9_ r3da009_2_10_ ///
  r3da009_2_11_ r3da009_2_12_ r3da009_2_13_ r3da009_2_14_
  
*****保存数据集  
save "$temp_data/charls15_chronic.dta",replace	 //单独保存wave3的慢性病数据