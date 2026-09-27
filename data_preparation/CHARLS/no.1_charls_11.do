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
use "$raw_data\2011charls\demographic_background.dta",clear
merge 1:1 ID using "$raw_data\2011charls\health_care_and_insurance.dta",nogen nolabel
merge 1:1 ID using "$raw_data\2011charls\health_status_and_functioning.dta",nogen nolabel
merge 1:1 ID using "$raw_data\2011charls\individual_income.dta",nogen nolabel
merge 1:1 ID using "$raw_data\2011charls\interviewer_observation.dta",nogen nolabel
merge 1:1 ID using "$raw_data\2011charls\work_retirement_and_pension.dta",nogen nolabel
merge 1:1 ID using "$raw_data\2011charls\biomarkers.dta",nogen nolabel
merge 1:1 ID using "$raw_data\2011charls\Blood_20140429.dta",nogen nolabel
merge 1:1 ID using "$raw_data\2011charls\weight.dta",keep(1 3) nogen nolabel
merge m:1 householdID using "$raw_data\2011charls\household_income.dta",keep(1 3) nogen nolabel
merge m:1 householdID using "$raw_data\2011charls\household_roster.dta",keep(1 3) nogen nolabel
merge m:1 householdID using "$raw_data\2011charls\housing_characteristics.dta",keep(1 3) nogen nolabel
merge m:1 householdID using "$raw_data\2011charls\family_information.dta",keep(1 3) nogen nolabel
merge m:1 householdID using "$raw_data\2011charls\family_transfer.dta",keep(1 3) nogen nolabel

*****修改wave1中的ID和householdID
replace householdID = householdID + "0"
replace ID = householdID + substr(ID,-2,2)  //由于2011年ID和2013年不一样

*****是否残疾
gen r1disability=.
replace r1disability=1 if da005_1_==1 | da005_2_==1 | da005_3_==1 | da005_4_==1 | da005_5_==1 
replace r1disability=0 if da005_1_==2 & da005_2_==2 & da005_3_==2 & da005_4_==2 & da005_5_==2 

*****认知能力=心智状况+情景记忆能力(此处的量表得分0-21分)
*心智状况=日期认知(5分)+计算(5分)+画图能力(11分)
*情景记忆能力=词组回忆(即时回忆+延时回忆)(10分)
*日期认知/正确回答月份
gen r1mo =.
replace r1mo = 0 if !mi(dc001s1) | !mi(dc001s3) | !mi(dc002)
replace r1mo = 1 if dc001s2 == 2

*日期认知/正确回答日期
gen r1dy =.
replace r1dy = 0 if !mi(dc001s1) | !mi(dc001s2) | !mi(dc002)
replace r1dy = 1 if dc001s3 == 3 

*日期认知/正确回答哪年
gen r1yr =.
replace r1yr = 0 if !mi(dc001s2) | !mi(dc001s3) | !mi(dc002)
replace r1yr = 1 if dc001s1 == 1 

*日期认知/正确回答哪周
gen r1dw =.
replace r1dw = 0 if dc002 == 2 | (!mi(dc001s1) | !mi(dc001s2) | !mi(dc001s3))
replace r1dw = 1 if dc002 == 1 

*日期认知/正确回答哪个季节
gen r1ds =.
replace r1ds = 0 if dc003 == 2 | (!mi(dc001s1) | !mi(dc001s2) | !mi(dc001s3))
replace r1ds = 1 if dc003 == 1 

*日期认知/正确回答所有日期(5分)
egen r1orient = rowtotal(r1mo r1dy r1yr r1dw),mi
egen r1date_cognition = rowtotal(r1mo r1dy r1yr r1dw r1ds),mi

*****社交活动(前4期) 
recode da056s1-da056s11 (1/11=1) (.e=0)  //重新编码为0/1
gen r1social1=da056s1 
gen r1social2=da056s2 
gen r1social3=da056s3 
gen r1social4=da056s4 
gen r1social5=da056s5 
gen r1social6=da056s6 
gen r1social7=da056s7 
gen r1social8=da056s8 
gen r1social9=da056s9 
gen r1social10=da056s10 
gen r1social11=da056s11

*****每种活动频率
forvalues i=1/11 {
  replace da057_`i'_=4 if da056s`i'==0 //4代表参加频率为0 
}

rename (da057_1_ da057_2_ da057_3_ da057_4_ da057_5_ da057_6_ da057_7_ da057_8_ ///
da057_9_ da057_10_ da057_11_) (r1freq_social1 r1freq_social2 r1freq_social3 r1freq_social4 r1freq_social5 ///
r1freq_social6 r1freq_social7 r1freq_social8 r1freq_social9 r1freq_social10 r1freq_social11)

*****2020年将志愿者和照顾病人合并，因此我们又重新给出了新的变量
replace da056s6=1 if da056s7==1  //将社交活动合并
rename (da056s1 da056s2 da056s3 da056s4 da056s5 da056s6 da056s8 da056s11) ///
(r1act_1 r1act_2 r1act_3 r1act_4 r1act_5 r1act_6 r1act_7 r1act_8)

gen r1freq_act_1=r1freq_social1
gen r1freq_act_2=r1freq_social2
gen r1freq_act_3=r1freq_social3
gen r1freq_act_4=r1freq_social4
gen r1freq_act_5=r1freq_social5
egen r1freq_act_6=rowmin(r1freq_social6 r1freq_social7)   //数字越小频率越高
gen r1freq_act_7=r1freq_social8
gen r1freq_act_8=r1freq_social11

*****是否有各种医疗保险
recode ea001s1 ea001s2 ea001s3 ea001s4 ea001s5 ea001s6 ea001s7 ea001s8  ///
ea001s9 (.e=0) (1/9=1)

rename (ea001s1 ea001s2 ea001s3 ea001s4 ea001s5 ea001s6 ea001s7 ea001s8 ///
ea001s9) (r1ea001s1 r1ea001s3 r1ea001s4 r1ea001s2 r1ea001s5 r1ea001s6   ///
r1ea001s7 r1ea001s8 r1ea001s11)   //保持每年的医保名字相同
  
*****血检指标
rename (bloodweight qc1_va003 qc1_vb002 qc1_vb006 qc1_vb009 newbun newglu ///
newcrea newcho newtg newhdl newldl newcrp newhba1c newua qc1_vb005 qc1_vb004 ///
cystatinc) (r1bloodweight r1bl_fasting r1bl_wbc r1bl_mcv r1bl_plt r1bl_bun ///
r1bl_glu r1bl_crea r1bl_cho r1bl_tg r1bl_hdl r1bl_ldl r1bl_crp r1bl_hbalc r1bl_ua ///
r1bl_hct r1bl_hgb r1bl_cysc) 
  
*****跌倒
recode da023 (1=1) (2=0) (else=.),gen(r1fall_down)  

*****是否佩戴眼镜
recode da032 (1=1) (2=2) (3=0) (else=.),gen(r1glass)

*****远视视力
replace da033=5 if mi(da033) & da032==2
recode da033 (1=5) (2=4) (3=3) (4=2) (5=1) (else=.),gen(r1eyesight_distance) 

*****近视视力 
replace da034=5 if mi(da034) & da032==2
recode da034 (1=5) (2=4) (3=3) (4=2) (5=1) (else=.),gen(r1eyesight_close)  

*****听力
recode da038 (1=1) (2=0) (else=.),gen(r1hear_aid)  
recode da039 (1=5) (2=4) (3=3) (4=2) (5=1) (else=.),gen(r1hear)  

*****睡眠时间
rename (da049 da050) (r1sleep_night r1sleep_nap) 

*****疼痛
forvalues i=1/15 {
 recode da042s`i' (1/15=1) (.e=0)
 replace da042s`i'=0 if da041==2
 rename da042s`i' r1da042s`i'
}

*****是否掉光牙齿
recode da040 (1=1) (2=0) (else=.),gen(r1teeth)

*****髋骨骨折
recode da025 (1=1) (2=0) (else=.),gen(r1hip)

*****身体活动时间
gen r1vgactime=.  //每次高强度身体活动的时间
replace r1vgactime=0 if da051_1_==2
replace r1vgactime=20 if da051_1_==1 & da053_1_==1 & da054_1_==1
replace r1vgactime=75 if da051_1_==1 & da053_1_==1 & da054_1_==2
replace r1vgactime=180 if da051_1_==1 & da053_1_==2 & da055_1_==1
replace r1vgactime=240 if da051_1_==1 & da053_1_==2 & da055_1_==2

gen r1mdactime=.  //每次中等强度身体活动的时间
replace r1mdactime=0 if da051_2_==2
replace r1mdactime=20 if da051_2_==1 & da053_2_==1 & da054_2_==1
replace r1mdactime=75 if da051_2_==1 & da053_2_==1 & da054_2_==2
replace r1mdactime=180 if da051_2_==1 & da053_2_==2 & da055_2_==1
replace r1mdactime=240 if da051_2_==1 & da053_2_==2 & da055_2_==2

gen r1ltactime=.  //每次轻度身体活动的时间
replace r1ltactime=0  if da051_3_==2
replace r1ltactime=20  if da051_3_==1 & da053_3_==1 & da054_3_==1
replace r1ltactime=75  if da051_3_==1 & da053_3_==1 & da054_3_==2
replace r1ltactime=180 if da051_3_==1 & da053_3_==2 & da055_3_==1
replace r1ltactime=240 if da051_3_==1 & da053_3_==2 & da055_3_==2

*****是否知道自己患有慢性病
recode da008_1_ da008_5_ da008_11_ (1=1) (2/3=0)
rename (da008_1_ da008_5_ da008_11_) (r1hibpe_self r1lunge_self r1psyche_self)

*****癌症部位
forvalues i=1/23 {
  recode da017s`i' (`i'=1) (else=.),gen(r1da017s`i')
}

*****取暖燃料
recode i021 (1 3 4 5=0) (2 6=1) (7=.),gen(r1clean_heat)
replace r1clean_heat=0 if i020==1

*****做饭燃料
recode i022 (2 3 4 5=0) (1 6=1) (7=.),gen(r1clean_cook)

*****房间数量
egen r1room=rowtotal(i012_1 i012_2),mi

*****是否有自来水
recode i017 (1=1) (2=0), gen(r1water)

*****是否有电
recode i016 (1=1) (2=0), gen(r1electricity)

*****厕所卫生差
gen r1toilet=0 if !mi(i012_3)
replace r1toilet=1 if i012_3==0 | i015==2

*****建筑材料差
recode i004 (1/3=0) (4/10=1),gen(r1build)

*****保存特定变量
keep ID r1date_cognition r1ea001s1 r1ea001s2 r1ea001s3 r1ea001s4 ///
r1ea001s5 r1ea001s6 r1ea001s7 r1ea001s8 r1ea001s11 r1disability r1water r1bloodweight r1bl_fasting ///
r1bl_wbc r1bl_mcv r1bl_plt r1bl_bun r1bl_glu r1bl_crea r1bl_cho r1bl_tg r1bl_hdl ///
r1bl_ldl r1bl_crp r1bl_hbalc r1bl_ua r1bl_hct r1bl_hgb r1bl_cysc r1fall_down ///
r1glass r1eyesight_distance r1eyesight_close r1hear_aid r1hear r1sleep_night ///
r1sleep_nap r1da042s1 r1da042s2 r1da042s3 r1da042s4 r1da042s5 r1da042s6 r1da042s7 ///
r1da042s8 r1da042s9 r1da042s10 r1da042s11 r1da042s12 r1da042s13 r1da042s14 ///
r1da042s15 r1teeth r1hip r1ltactime r1mdactime r1vgactime r1hibpe_self r1lunge_self /// 
r1psyche_self r1da017s1 r1da017s2 r1da017s3 r1da017s4 r1da017s5 r1da017s6 r1da017s7 /// 
r1da017s8 r1da017s9 r1da017s10 r1da017s11 r1da017s12 r1da017s13 r1da017s14 r1da017s15 /// 
r1da017s16 r1da017s17 r1da017s18 r1da017s19 r1da017s20 r1da017s21 r1da017s22 r1da017s23 /// 
r1ds r1act_1 r1act_2 r1act_3 r1act_4 r1act_5 r1act_6 r1act_7 r1act_8 r1freq_act_1 /// 
r1freq_act_2 r1freq_act_3 r1freq_act_4 r1freq_act_5 r1freq_act_6 r1freq_act_7 ///
r1freq_act_8 r1social1 r1social2 r1social3 r1social4 r1social5 r1social6 r1social7 ///
r1social8 r1social9 r1social10 r1social11 r1freq_social1 r1freq_social2 /// 
r1freq_social3 r1freq_social4 r1freq_social5 r1freq_social6 r1freq_social7 /// 
r1freq_social8 r1freq_social9 r1freq_social10 r1freq_social11 r1clean_heat ///
r1clean_cook r1build r1toilet r1electricity r1water r1room

*****保存数据集 
save "$temp_data/charls11.dta",replace //保存数据

*****因wave2数据需要匹配wave1的牙齿数据,在此单独保存
keep ID r1teeth
save "$temp_data/teeth_charls11.dta",replace  //单独保存牙齿数据
