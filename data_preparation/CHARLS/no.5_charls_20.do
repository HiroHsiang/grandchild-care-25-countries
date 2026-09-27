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
use "$raw_data/2020charls/Demographic_Background.dta",clear 
merge 1:1 ID using "$raw_data/2020charls/Health_Status_and_Functioning.dta",nogen nolabel
merge 1:1 ID using "$raw_data/2020charls/Individual_Income.dta",nogen nolabel
merge 1:1 ID using "$raw_data/2020charls/Weights.dta",nogen nolabel
merge 1:1 ID using "$raw_data/2020charls/Work_Retirement.dta",nogen nolabel
merge 1:1 ID using "$raw_data/2020charls/COVID_Module.dta",nogen nolabel
merge m:1 householdID using "$raw_data/2020charls/Family_Information.dta",nogen nolabel
merge m:1 householdID using "$raw_data/2020charls/Household_Income.dta",nogen nolabel
merge m:1 communityID using "$raw_data/2011charls/psu.dta",keep(1 3) nogen nolabel

*****只有回答前面板块的才被视为参与者
merge 1:1 ID using "$raw_data/2020charls/Sample_Infor.dta",nolabel
gen inw5=0
replace inw5=1 if inlist(_merge,1,3)
drop _merge
merge 1:1 ID using "$raw_data/2020charls/Exit_Module.dta",nogen nolabel

*****居住地
*h5rural
recode urban_nbs (0=1) (1=0),gen(h5rural)

*****受访年份
*r5iwy
destring(iyear), gen(r5iwy) 
replace r5iwy=. if inw5==0

*****受访月份
*r5iwm
destring(imonth), gen(r5iwm) 
replace r5iwm=. if inw5==0

*****出生年份
*zrbirthyear
replace zrbirthyear=ba003_1 if mi(zrbirthyear)

*****出生月份
*r5birthmonth
gen r5birthmonth=ba003_2

*****性别
*r5gender
replace ba001=ba002 if !mi(ba002)

rename ba001 r5gender

*****教育背景
*r5educ_c
replace zredu=ba010 if mi(zredu) & !mi(ba010)
recode zredu (11/12=11),gen(r5educ_c)

*****婚姻状况
*r5mstath
gen r5mstath=.
replace r5mstath=1 if ba011==1
replace r5mstath=2 if ba011==2
replace r5mstath=4 if ba011==3
replace r5mstath=5 if ba011==4
replace r5mstath=7 if ba011==5
replace r5mstath=8 if ba011==6
replace r5mstath=3 if ba012==1

*****户口
*r5hukou
gen r5hukou=ba009

*****自评健康
*r5shlta
recode da001 (997=.),gen(r5shlta)

*****日常活动
*r5dressa r5batha r5eata r5beda r5toilta r5urina r5adlab_c
recode db001 db003 db005 db007 db009 db011 (1=0) (2/4=1)
rename (db001 db003 db005 db007 db009 db011) (r5dressa r5batha r5eata r5beda r5toilta r5urina)
egen r5adlab_c=rowtotal(r5dressa r5batha r5eata r5beda r5toilta r5urina),mi

*****ADL/穿衣困难
*r5dressa

*****ADL/沐浴困难
*r5batha

*****ADL/进食困难
*r5eata

*****ADL/上下床困难
*r5beda

*****ADL/使用厕所困难
*r5toilta

*****ADL/控制排尿
*r5urina

*****ADL总分
*r5housewka r5mealsa r5shopa r5phonea r5medsa r5moneya r5iadl
recode db012 db014 db016 db018 db020 db022 (1=0) (2/4=1)
rename (db012 db014 db016 db018 db020 db022) (r5housewka r5mealsa r5shopa r5phonea r5medsa r5moneya)
egen r5iadl=rowtotal(r5housewka r5mealsa r5shopa r5phonea r5medsa r5moneya),mi

*****IADL/管理资金
*r5moneya

*****IADL/服用药物
*r5medsa

*****IADL/购买食品杂货
*r5shopa

*****IADL/准备饭菜
*r5mealsa

*****IADL/打扫房屋
*r5housewka

*****IADL/打电话
*r5phonea

*****慢性病
*r5hibpe r5dyslipe r5diabe r5cancre r5lunge r5livere r5hearte r5stroke 
*r5kidneye r5digeste r5psyche r5memrye r5arthre r5asthmae
forvalues i=1/15 {
  replace da003_`i'_= zdisease_`i'_ if da003_`i'_==. & !mi(zdisease_`i'_) 
  recode da003_`i'_ (1=1) (2=0)
}

replace da003_12_=1 if da003_13_==1  //将两种疾病合并为1种
rename (da003_1_ da003_2_ da003_3_ da003_4_ da003_5_ da003_6_ da003_7_ da003_8_ ///
 da003_9_ da003_10_ da003_11_ da003_12_ da003_14_ da003_15_) (r5hibpe r5dyslipe ///
 r5diabe r5cancre r5lunge r5livere r5hearte r5stroke r5kidneye r5digeste r5psyche ///
 r5memrye r5arthre r5asthmae)
 
*****单独提取20年的帕金森
*r5parkinson
gen r5parkinson=da003_13_  

*****是否知道自己患有慢性病
*r5hibpe_self r5lunge_self r5psyche_self
recode da004_1_ da004_5_ da004_11_ (1=1) (2/3=0)
rename (da004_1_ da004_5_ da004_11_) (r5hibpe_self r5lunge_self r5psyche_self)

*****是否重度/中度/轻度身体活动
*r5vgact_c r5mdact_c r5ltact_c
gen r5vgact_c =.
replace r5vgact_c = 1 if da032_1_==1
replace r5vgact_c = 0 if da032_1_==2

gen r5mdact_c =.
replace r5mdact_c = 1 if da032_2_==1
replace r5mdact_c = 0 if da032_2_==2

gen r5ltact_c =.
replace r5ltact_c = 1 if da032_3_==1
replace r5ltact_c = 0 if da032_3_==2 

*****重度/中度/轻度身体活动的天数
*r5vgactx_c r5mdactx_c r5ltactx_c
replace da033_1_ = 0 if da032_1_==2 
replace da033_2_ = 0 if da032_2_==2 
replace da033_3_ = 0 if da032_3_==2 
rename (da033_1_ da033_2_ da033_3_) (r5vgactx_c r5mdactx_c r5ltactx_c)

*****身体活动的时间区间
*r5vgactime r5mdactime r5ltactime
gen r5vgactime=.  //每次重度身体活动的时间区间
replace r5vgactime=0 if da032_1_==2
replace r5vgactime=20 if da032_1_==1 & da034_1_==1 & da035_1_==1
replace r5vgactime=75 if da032_1_==1 & da034_1_==1 & da035_1_==2
replace r5vgactime=180 if da032_1_==1 & da034_1_==2 & da036_1_==1
replace r5vgactime=240 if da032_1_==1 & da034_1_==2 & da036_1_==2

gen r5mdactime=.  //每次中度身体活动的时间区间
replace r5mdactime=0 if da032_2_==2
replace r5mdactime=20 if da032_2_==1 & da034_2_==1 & da035_2_==1
replace r5mdactime=75 if da032_2_==1 & da034_2_==1 & da035_2_==2
replace r5mdactime=180 if da032_2_==1 & da034_2_==2 & da036_2_==1
replace r5mdactime=240 if da032_2_==1 & da034_2_==2 & da036_2_==2
 
gen r5ltactime=.   //每次轻度身体活动的时间区间
replace r5ltactime=0 if da032_3_==2
replace r5ltactime=20 if da032_3_==1 & da034_3_==1 & da035_3_==1
replace r5ltactime=75 if da032_3_==1 & da034_3_==1 & da035_3_==2
replace r5ltactime=180 if da032_3_==1 & da034_3_==2 & da036_3_==1
replace r5ltactime=240 if da032_3_==1 & da034_3_==2 & da036_3_==2  

*****现在饮酒
*r5drinkl
recode da051 (1/2=1) (3=0),gen(r5drinkl)

*****曾经是否吸烟
*r5smokev
replace da046= zsmoke if !mi(zsmoke) & mi(da046)
recode da046 (1=1) (2=0),gen(r5smokev)

*****现在是否吸烟
*r5smoken
recode da047 (1=1) (2/3=0),gen(r5smoken) 
replace r5smoken=0 if da046==2

*****吸烟数量
*r5smokef
gen r5smokef=da050_1

*****过去一个月门诊
*r5doctor1m r5doctim1m
recode da005 (2=0),gen(r5doctor1m)  
rename da006 r5doctim1m   

*****过去一年的住院
*r5hosp1y r5hsptim1y
recode da007 (2=0),gen(r5hosp1y) 
rename da008 r5hsptim1y

*****是否领取养老保险
*r5pension
recode ba014 (1/5=1) (6/7=0),gen(r5pension)

*****是否参与健康保险
*r5ins
recode ba016 (1/2=1) (3=0),gen(r5ins)   

*****各种医保类型
*r5ea001s1 r5ea001s2 r5ea001s3 r5ea001s4 r5ea001s5 r5ea001s11
tab ba017,gen(r5ea001s)
rename r5ea001s6 r5ea001s11  

*****自评记忆
*r5slfmem
recode dc006 (997=.),gen(r5slfmem)

*****认知能力=心智状况+情景记忆能力
*r5imrc r5dlrc r5memeory 
*心智状况(认知完整性)=日期认知+计算+画图能力
*情景记忆能力=词组回忆(即时回忆+延时回忆)
*词组即时回忆
recode dc012_s1 dc012_s2 dc012_s3 dc012_s4 dc012_s5 dc012_s6 dc012_s7 ///
  dc012_s8 dc012_s9 dc012_s10 (1/10=1)
egen r5imrc = rowtotal(dc012_s1 dc012_s2 dc012_s3 dc012_s4 dc012_s5 ///
  dc012_s6 dc012_s7 dc012_s8 dc012_s9 dc012_s10),mi 

*词组延迟回忆
recode dc028_s1 dc028_s2 dc028_s3 dc028_s4 dc028_s5 dc028_s6 dc028_s7 ///
  dc028_s8 dc028_s9 dc028_s10 (1/10=1) 
egen r5dlrc = rowtotal(dc028_s1 dc028_s2 dc028_s3 dc028_s4 dc028_s5 ///
  dc028_s6 dc028_s7 dc028_s8 dc028_s9 dc028_s10),mi
                        
*****计算词组回忆得分=(词组即时回忆+词组延迟回忆)/2   
gen r5tr20=r5imrc + r5dlrc if !mi(r5imrc) & !mi(r5dlrc)
gen r5recall = r5tr20/2 if !mi(r5tr20)

*****日期认知得分
recode dc001-dc005 (997=.d) (999=.r)
*月
gen r5mo = .
replace r5mo = 0 if dc005 == 2 | (!mi(dc001) | !mi(dc002) | !mi(dc003) | !mi(dc004))
replace r5mo = 1 if dc005 == 1

*日
gen r5dy = .
replace r5dy = 0 if dc003 == 2 | (!mi(dc001) | !mi(dc002) | !mi(dc004) | !mi(dc005))
replace r5dy = 1 if dc003 == 1

*年份
gen r5yr = .
replace r5yr = 0 if dc001 == 2 | (!mi(dc002) | !mi(dc003) | !mi(dc004) | !mi(dc005))
replace r5yr = 1 if dc001 == 1

*星期
gen r5dw = .
replace r5dw = 0 if dc004 == 2 | (!mi(dc001) | !mi(dc002) | !mi(dc003) | !mi(dc005))
replace r5dw = 1 if dc004 == 1 

*季节
gen r5ds = .
replace r5ds = 0 if dc002 == 2 | (!mi(dc001) | !mi(dc003) | !mi(dc004) | !mi(dc005))
replace r5ds = 1 if dc002 == 1

*****日期认知能力得分
*r5mo r5dy r5yr r5dw r5ds r5orient
egen r5orient = rowtotal(r5mo r5dy r5yr r5dw),mi
egen r5date_cognition = rowtotal(r5mo r5dy r5yr r5dw r5ds),mi

*画图能力得分
*r5draw
recode dc009 (997=.) (999=.)
gen r5draw = .
replace r5draw = 0 if dc009 == 2
replace r5draw = 1 if dc009 == 1

*数学题得分
*r5ser7 
recode dc007_1 dc007_2 dc007_3 dc007_4 dc007_5 (997=.) (999=.)
gen r5ser7 =. 
replace r5ser7 = 0 if !mi(dc007_1_1) | !mi(dc007_2_1) | !mi(dc007_3_1) | !mi(dc007_4_1) | !mi(dc007_5_1)
replace r5ser7 = r5ser7 + 1 if dc007_1_1 == 93
replace r5ser7 = r5ser7 + 1 if dc007_2_1 == (dc007_1_1 - 7) & !mi(dc007_1_1) & !mi(dc007_2_1)
replace r5ser7 = r5ser7 + 1 if dc007_3_1 == (dc007_2_1 - 7) & !mi(dc007_2_1) & !mi(dc007_3_1)
replace r5ser7 = r5ser7 + 1 if dc007_4_1 == (dc007_3_1 - 7) & !mi(dc007_3_1) & !mi(dc007_4_1)
replace r5ser7 = r5ser7 + 1 if dc007_5_1 == (dc007_4_1 - 7) & !mi(dc007_4_1) & !mi(dc007_5_1) 

*计算心智状况
*r5executive
egen r5executive=rowtotal(r5ser7 r5date_cognition r5draw),mi  //日期、绘画和减法

*计算认知能力总得分
*r5total_cognition
egen r5total_cognition=rowtotal(r5recall r5executive),mi //认知能力=情景记忆+心智状况

*****社交活动
*r5act_1 r5act_2 r5act_3 r5act_4 r5act_5 r5act_6 r5act_7 r5act_8
recode da038_s1-da038_s8 (1/8=1)

forvalues i=1/8 {
  replace da039_`i'_=4 if da038_s`i'==0 //4代表参加频率为0 
  rename da038_s`i' r5act_`i'
  rename da039_`i'_ r5freq_act_`i'
}

*****过去一个月内是否参加过任何社会活动
*r5socwk
gen r5socwk =.
replace r5socwk = 0 if !mi(r5act_1) | !mi(r5act_2) | !mi(r5act_4) | !mi(r5act_5) | ///
                       !mi(r5act_6) | !mi(r5act_7) 
replace r5socwk = 1 if r5act_1==1 | r5act_2==1 | r5act_4==1 | r5act_5==1 | r5act_6==1 | r5act_7==1

*****家庭人口数
*h5hhres
gen pnc=substr(ID,11,2) 
destring pnc,gen(pn)
bysort householdID: egen h5hhresp=count(pn) if inw5==1

* 如果cb001或cb002是"99"或空白，将其设为缺失值
replace cb001 = "" if cb001 == "99"
replace cb002 = "" if cb002 == "99"

* 使用split命令将cb001和cb002分割成多个变量
split cb001, generate(cb001_split) parse("~")
split cb002, generate(cb002_split) parse("~")

* 将分割后的字符串变量转换为数值变量
foreach var of varlist cb001_split* cb002_split* {
    destring `var', replace
}

* 计算cb001和cb002中的人数
egen count_cb001 = rownonmiss(cb001_split*)
egen count_cb002 = rownonmiss(cb002_split*)

* 计算总人数
egen h5hhres= rowtotal(count_cb001 count_cb002 h5hhresp)
replace h5hhres=. if mi(count_cb001) | mi(count_cb002) | mi(h5hhresp)

*****儿子数量
*h5son
forvalues i=1/17 {
  replace xchildgender_`i'_ =. if ca002_`i'_==2
  recode xchildgender_`i'_ (1=1) (2=0)
}

forvalues i=1/7 {
  recode ca006_`i'_ (1=1) (2=0)
}

egen h5son=rowtotal(ca006_1_ ca006_2_ ca006_3_ ca006_4_ ca006_5_ ca006_6_ ///
  ca006_7_ xchildgender_1_ xchildgender_2_ xchildgender_3_ xchildgender_4_ ///
  xchildgender_5_ xchildgender_6_ xchildgender_7_ xchildgender_8_ xchildgender_9_ ///
  xchildgender_10_ xchildgender_11_ xchildgender_12_ xchildgender_13_ ///
  xchildgender_14_ xchildgender_15_ xchildgender_16_ xchildgender_17_)

*****女儿数量
*h5dau
forvalues i=1/17 {
  recode xchildgender_`i'_ (1=0) (0=1)
}

forvalues i=1/7 {
  recode ca006_`i'_ (1=0) (0=1)
}

egen h5dau=rowtotal(ca006_1_ ca006_2_ ca006_3_ ca006_4_ ca006_5_ ca006_6_ ///
  ca006_7_ xchildgender_1_ xchildgender_2_ xchildgender_3_ xchildgender_4_ ///
  xchildgender_5_ xchildgender_6_ xchildgender_7_ xchildgender_8_ xchildgender_9_ ///
  xchildgender_10_ xchildgender_11_ xchildgender_12_ xchildgender_13_ ///
  xchildgender_14_ xchildgender_15_ xchildgender_16_ xchildgender_17_)
 
*****健在子女数量   
recode ca002_*_  (1=1) (2=0)   
egen h5child=rowtotal(ca002_1_ ca002_2_ ca002_3_ ca002_4_ ca002_5_ ca002_6_ ///
  ca002_7_ ca002_8_ ca002_9_ ca002_10_ ca002_11_ ca002_12_ ca002_13_ ca002_14_ ///
  ca002_15_ ca002_16_ ca002_17_) 

*****是否与子女同住
*h5coresd
egen h5long_child=rowtotal(ca014_1_ ca014_2_ ca014_3_ ca014_4_ ca014_5_ ///
ca014_6_ ca014_7_ ca014_8_ ca014_9_ ca014_10_ ca014_11_ ca014_12_ ca014_13_ ///
ca014_14_ ca014_15_ ca014_16_ ca014_17_),mi 

gen h5coresd=0 
replace h5coresd=1 if h5long_child>0 & !mi(h5long_child)
replace h5coresd=1 if cb005_1_==8 | cb005_2_==8 | cb005_3_==8 | cb005_4_==8 | ///
 cb005_5_==8 | cb005_6_==8 | cb005_7_==8 | cb005_8_==8 | cb005_9_==8 |cb005_10_==8
 
*****是否每周与子女见面
*h5kcntf
forvalues i=1/17 {
  replace ca015_`i'_=1 if ca014_`i'_==12
  recode ca015_`i'_ (1/3=1) (4/10=0)
}

gen h5kcntf=0 if !mi(ca015_1_) | !mi(ca015_2_) | !mi(ca015_3_) | !mi(ca015_4) | /// 
  !mi(ca015_5_) | !mi(ca015_6_) | !mi(ca015_7_) | !mi(ca015_8_) | !mi(ca015_9_) | ///
  !mi(ca015_10_) | !mi(ca015_11_) | !mi(ca015_12) |!mi(ca015_13_) | !mi(ca015_14_) | ///
  !mi(ca015_15_) | !mi(ca015_16_) | !mi(ca015_17_)
replace h5kcntf=1 if ca015_1_==1 & ca015_2_==1 | ca015_3_==1 | ca015_4_==1 | /// 
  ca015_5_==1 | ca015_6_==1 | ca015_7_==1 | ca015_8_==1 | ca015_9_==1 | ///
  ca015_10_==1 | ca015_11_==1 | ca015_12==1 |ca015_13_==1 | ca015_14_==1 | ///
  ca015_15_==1 | ca015_16_==1 | ca015_17_==1 

*****是否每周与子女电子联系
*h5kcntpm
forvalues i=1/17 {
  recode ca016_`i'_ (1/3=1) (4/10=0)
}
gen h5kcntpm=0 if !mi(h5long_child)
replace h5kcntpm=1 if ca016_1_==1 | ca016_2_==1 | ca016_3_==1 | ca016_4_ ==1 | ///
ca016_5_==1 | ca016_6_==1 | ca016_7_==1 | ca016_8_==1 | ca016_9_==1 | ca016_10_==1 | ///
ca016_11_==1 | ca016_12_==1 | ca016_13_==1 | ca016_14_==1 | ca016_15_==1 | ///
ca016_16_==1 | ca016_17_ ==1 

*****是否每周与他们的任何子女见面或者电子联系
*h5kcnt
gen h5kcnt=.
replace h5kcnt=1 if h5kcntf==1 | h5kcntpm==1
replace h5kcnt=0 if h5kcntf==0 & h5kcntpm==0 

*****家庭总消费
*周消费
gen hh5cbfood=.
replace gf006=gf006 + gf008 if gf007==1 & !mi(gf008) & !mi(gf006)  //增加自家生产
replace hh5cbfood = gf006 if inrange(gf006,0,200000)

gen hh5codinn=.
replace hh5codinn = gf009 if inrange(gf009,0,200000)

gen hh5cacct=.
replace hh5cacct = gf010 if inrange(gf010,0,200000) 
 
gen hh5cfood =.
replace hh5cfood = hh5cbfood + hh5codinn + hh5cacct if ///
                    !mi(hh5cbfood) & !mi(hh5codinn) & !mi(hh5cacct)
 
*月消费
gen hh5ccomu=. 
replace hh5ccomu = gf011_1 if inrange(gf011_1,0,99999)

gen hh5cutil=.
replace hh5cutil = gf011_2 if inrange(gf011_2,0,99999)

gen hh5cfuel=.
replace hh5cfuel = gf011_3 if inrange(gf011_3,0,99999)

gen hh5cserv=.
replace hh5cserv = gf011_4 if inrange(gf011_4,0,99999)

gen hh5ctran=.
replace hh5ctran = gf011_5 if inrange(gf011_5,0,99999)

gen hh5cday=.
replace hh5cday = gf011_6 if inrange(gf011_6,0,99999)

gen hh5centa=.
replace hh5centa = gf011_7 if inrange(gf011_7,0,99999) 
 
*年消费
gen hh5cnf1m =.
replace hh5cnf1m = hh5ccomu + hh5cutil + hh5cfuel + hh5cserv +  ///
  hh5ctran + hh5cday + hh5centa if !mi(hh5ccomu) & !mi(hh5cutil) & ///
  !mi(hh5cfuel) & !mi(hh5cserv) & !mi(hh5ctran) & !mi(hh5cday) & !mi(hh5centa)


forvalues i=1/16 {
  replace gf013_`i'=. if inlist(gf013_`i',-1)
}
 
gen hh5cnf1y =.
replace hh5cnf1y = gf013_1 + gf013_2 + gf013_3 + gf013_4 + gf013_5 + ///
  gf013_6 + gf013_7 + gf013_8 + gf013_9 + gf013_10 + gf013_11 + gf013_12 + ///
  gf013_13 + gf013_14 + gf013_15 + gf013_16 if !mi(gf013_1) & !mi(gf013_2) & ///
  !mi(gf013_3) & !mi(gf013_4) & !mi(gf013_5) & !mi(gf013_6) & !mi(gf013_7) & ///
  !mi(gf013_8) & !mi(gf013_9) & !mi(gf013_10) & !mi(gf013_11) & !mi(gf013_12) & ///
  !mi(gf013_13) & !mi(gf013_14) & !mi(gf013_15) & !mi(gf013_16) 
   
*****总消费
*hh5ctot  hh5cperc
gen hh5cfooda =.
replace hh5cfooda = hh5cfood*52 if !mi(hh5cfood)

gen hh5cnf1ma =.
replace hh5cnf1ma = hh5cnf1m*12 if !mi(hh5cnf1m)

gen hh5ctot =.
replace hh5ctot = hh5cfooda + hh5cnf1ma + hh5cnf1y if ///
                !mi(hh5cfooda) & !mi(hh5cnf1ma) & !mi(hh5cnf1y)
gen hh5cperc = hh5ctot/h5hhres		//人均消费


*****子女对父母的经济支持
forvalues i=1/17 {
  recode ca017_1_`i'_ ca017_1_min_`i'_ ca017_1_max_`i'_ (-1=.) 
  replace ca017_1_`i'_=(ca017_1_min_`i'_ + ca017_1_max_`i'_)/2 if mi(ca017_1_`i'_) & !mi(ca017_1_min_`i'_) & !mi(ca017_1_max_`i'_)
}

forvalues i=1/17 {
  recode ca017_3_`i'_ ca017_3_min_`i'_ ca017_3_max_`i'_ (-1=.) 
  replace ca017_3_`i'_=(ca017_3_min_`i'_ + ca017_3_max_`i'_)/2 if !mi(ca017_3_min_`i'_) | !mi(ca017_3_max_`i'_)
}

*****父母对子女的经济支持
forvalues i=1/11 {
  recode ca018_1_`i'_ ca018_1_min_`i'_ ca018_1_max_`i'_ (-1=.) 
  replace ca018_1_`i'_=(ca018_1_min_`i'_ + ca018_1_max_`i'_)/2 if mi(ca018_1_`i'_) & !mi(ca018_1_min_`i'_) & !mi(ca018_1_max_`i'_)
}

forvalues i=1/9 {
  recode ca018_3_`i'_ ca018_3_min_`i'_ ca018_3_max_`i'_ (-1=.) 
  replace ca018_3_`i'_=(ca018_3_min_`i'_ + ca018_3_max_`i'_)/2 if !mi(ca018_3_min_`i'_) | !mi(ca018_3_max_`i'_)
}  
  
*****过去一年从其子女/孙辈那里获得经济援助金额
egen h5fcamt=rowtotal(ca017_1_1_ ca017_1_2_ ca017_1_3_ ca017_1_4_ ca017_1_5_ ///
  ca017_1_6_ ca017_1_7_ ca017_1_8_ ca017_1_9_ ca017_1_10_ ca017_1_11_ ca017_1_12_ ///
  ca017_1_13_ ca017_1_14_ ca017_1_15_ ca017_1_16_ ca017_1_17_ ca017_3_1_ ///
  ca017_3_2_ ca017_3_3_ ca017_3_4_ ca017_3_5_ ca017_3_6_ ca017_3_7_ ca017_3_8_ ///
  ca017_3_9_ ca017_3_10_ ca017_3_11_ ca017_3_12_ ca017_3_13_ ca017_3_14_ ///
  ca017_3_15_ ca017_3_16_ ca017_3_17_)

*****过去一年中是否从其子女/孙辈那里获得任何经济援助
*h5fcany
gen h5fcany=0 if h5fcamt==0
replace h5fcany=1 if h5fcamt>0 & !mi(h5fcamt)

*****过去一年中向子女/孙辈提供的经济援助金额
*h5tcamt
egen h5tcamt=rowtotal(ca018_1_1_ ca018_1_2_ ca018_1_3_ ca018_1_4_ ca018_1_5_ ///
  ca018_1_6_ ca018_1_7_ ca018_1_8_ ca018_1_9_ ca018_1_10_ ca018_1_11_ ///
  ca018_1_12_ ca018_1_13_ ca018_1_14_ ca018_1_15_ ca018_1_16_ ca018_1_17_ ///
  ca018_3_1_ ca018_3_2_ ca018_3_3_ ca018_3_4_ ca018_3_5_ ca018_3_6_ ///
  ca018_3_7_ ca018_3_8_ ca018_3_9_ ca018_3_10_ ca018_3_11_ ca018_3_12_ ///
  ca018_3_13_ ca018_3_14_ ca018_3_15_ ca018_3_16_ ca018_3_17_)

*****是否向其子女/孙辈提供任何经济援助
*h5tcany
gen h5tcany=0 if h5tcamt==0
replace h5tcany=1 if h5tcamt>0 & !mi(h5tcamt)
  
*****其他家户成员的工资收入
forvalues i=1/11 {
  replace gb003_`i'_=0 if gb002_`i'_==2  
  replace gb003_`i'_=.d if gb002_`i'_==997  //不知道,下同
  replace gb003_`i'_=.r if gb002_`i'_==999  //拒绝回答,下同
  recode gb003_`i'_ (-1=.d)
}

foreach i of numlist 1/7 11 {
  replace gb003_`i'_=(gb003_min_`i'_ + gb003_max_`i'_)/2 if mi(gb003_`i'_) & gb003_min_`i'_>=0 & !mi(gb003_min_`i'_) & gb003_max_`i'_>=0 & !mi(gb003_max_`i'_)
}

*其他家户成员的工资收入应扣除的杂费部分
forvalues i=1/11 {
 gen gb004`i'=.  //生成一个变量等于应扣除的杂费部分
 recode gb005_1_`i'_  gb005_1_min_`i'_  gb005_1_max_`i'_  (-1=.d)
 replace gb005_1_`i'_=gb005_1_min_`i'_ if !mi(gb005_1_min_`i'_) & mi(gb005_1_max_`i'_)
 replace gb005_1_`i'_=gb005_1_max_`i'_ if mi(gb005_1_min_`i'_) & !mi(gb005_1_max_`i'_)
 replace gb005_1_`i'_=(gb005_1_min_`i'_ + gb005_1_max_`i'_)/2 if !mi(gb005_1_min_`i'_) & !mi(gb005_1_max_`i'_)
 replace gb004`i'=gb005_1_`i'_*12 if gb005_`i'_==1 & !mi(gb005_1_`i'_)
 replace gb004`i'=0 if gb005_`i'_==4 
}

forvalues i=1/7 {
 replace gb004`i'=gb005_2_`i'_ if gb005_`i'_==2 & !mi(gb005_2_`i'_)
 replace gb004`i'=.d if gb005_`i'_==2 & gb005_2_`i'_==-1
}

forvalues i=1/5 {
 replace gb004`i'=gb003_`i'_*(gb005_3_`i'_/100) if gb005_`i'_==3 & !mi(gb005_3_`i'_)
 replace gb004`i'=.d if gb005_`i'_==3 & gb005_3_`i'_==-1
}

*****计算其他家户成员的工资收入 - 应扣除的杂费部分
forvalues i=1/11 {
 replace gb003_`i'_=gb003_`i'_ - gb004`i' if !mi(gb003_`i'_) & !mi(gb004`i') & gb004_`i'_==2
}

egen hh5gz_other=rowtotal(gb003_1_ gb003_2_ gb003_3_ gb003_4_ gb003_5_ ///
  gb003_6_ gb003_7_ gb003_8_ gb003_9_ gb003_10_ gb003_11_) 
replace hh5gz_other=.d if gb003_1_==.d | gb003_2_==.d | gb003_3_==.d | gb003_4_==.d | ///
  gb003_5_==.d | gb003_6_==.d | gb003_7_==.d |gb003_8_==.d | gb003_9_==.d | gb003_10_==.d | gb003_11_==.d 
replace hh5gz_other=.r if gb003_1_==.r | gb003_2_==.r | gb003_3_==.r | gb003_4_==.r | ///
  gb003_5_==.r | gb003_6_==.r | gb003_7_==.r |gb003_8_==.r | gb003_9_==.r | gb003_10_==.r | gb003_11_==.r 
  

*****其他家户成员的公共转移支付收入
recode gb006_1_1_ gb006_1_2_ gb006_1_3_ gb006_1_4_ gb006_1_5_ gb006_1_6_ ///
 gb006_1_7_ gb006_2_1_ gb006_2_2_ gb006_2_3_ gb006_2_4_ gb006_3_1_ gb006_3_2_ ///
 gb006_3_3_ gb006_3_4_ gb006_4_1_ gb006_4_2_ gb006_4_3_ gb006_4_4_ gb006_4_5_ ///
 gb006_4_6_ gb006_5_1_ gb006_5_2_ gb006_5_3_ gb006_5_4_ gb006_6_1_ gb006_6_2_ ///
 gb006_6_3_ gb006_6_4_ gb006_7_1_ gb006_7_2_ gb006_7_3_ gb006_7_4_ gb006_7_6_ ///
 gb006_8_1_ gb006_8_2_ gb006_8_3_ gb006_8_4_ gb006_8_5_ gb006_8_6_ gb006_8_8_ ///
 gb006_9_1_ gb006_9_2_ gb006_9_3_ gb006_9_4_ gb008_7_1_ gb008_7_2_ gb008_7_3_ /// 
 gb008_7_4_ gb008_7_5_ gb008_8_1_ gb008_8_2_ gb008_8_3_ gb008_8_4_ gb008_8_5_ /// 
 gb008_8_6_ gb008_8_7_ gb008_9_1_ gb008_9_2_ gb008_9_3_ gb008_9_4_ gb008_9_5_ ///
 gb008_9_6_ (.=0) (-1=.d) 
 
*****计算其他家户成员的总收入 = 其他家户成员的公共转移支付收入 + 其他家户成员的工资收入减去杂费
gen hh5iothhh=hh5gz_other + gb006_1_1_ + gb006_1_2_  + gb006_1_3_  + gb006_1_4_ + ///
 gb006_1_5_ + gb006_1_6_ + gb006_1_7_ + gb006_2_1_ + gb006_2_2_ + gb006_2_3_ + ///
 gb006_2_4_ + gb006_3_1_ + gb006_3_2_ + gb006_3_3_ + gb006_3_4_ + gb006_4_1_ + ///
 gb006_4_2_ + gb006_4_3_ + gb006_4_4_ + gb006_4_5_ + gb006_4_6_ + gb006_5_1_ + ///
 gb006_5_2_ + gb006_5_3_ + gb006_5_4_ + gb006_6_1_ + gb006_6_2_ + gb006_6_3_ + ///
 gb006_6_4_ + gb006_7_1_ + gb006_7_2_ + gb006_7_3_ + gb006_7_4_ + gb006_7_6_ + ///
 gb006_8_1_ + gb006_8_2_ + gb006_8_3_ + gb006_8_4_ + gb006_8_5_ + gb006_8_6_ + ///
 gb006_8_8_ + gb006_9_1_ + gb006_9_2_ + gb006_9_3_ + gb006_9_4_ + gb008_7_1_ + ///
 gb008_7_2_ + gb008_7_3_ + gb008_7_4_ + gb008_7_5_ + gb008_8_1_ + gb008_8_2_ + ///
 gb008_8_3_ + gb008_8_4_ + gb008_8_5_ + gb008_8_6_ + gb008_8_7_ + gb008_9_1_ + ///
 gb008_9_2_ + gb008_9_3_ + gb008_9_4_ + gb008_9_5_ + gb008_9_6_ if !mi(hh5gz_other) | ///
 !mi(gb006_1_1_) | !mi(gb006_1_2_) | !mi(gb006_1_3_) | !mi(gb006_1_4_) | !mi(gb006_1_5_) | ///
 !mi(gb006_1_6_) | !mi(gb006_1_7_) | !mi(gb006_2_1_) | !mi(gb006_2_2_) | !mi(gb006_2_3_) | ///
 !mi(gb006_2_4_) | !mi(gb006_3_1_) | !mi(gb006_3_2_) | !mi(gb006_3_3_) | !mi(gb006_3_4_) | ///
 !mi(gb006_4_1_) | !mi(gb006_4_2_) | !mi(gb006_4_3_) | !mi(gb006_4_4_) | !mi(gb006_4_5_) | ///
 !mi(gb006_4_6_) | !mi(gb006_5_1_) | !mi(gb006_5_2_) | !mi(gb006_5_3_) | !mi(gb006_5_4_) | ///
 !mi(gb006_6_1_) | !mi(gb006_6_2_) | !mi(gb006_6_3_) | !mi(gb006_6_4_) | !mi(gb006_7_1_) | ///
 !mi(gb006_7_2_) | !mi(gb006_7_3_) | !mi(gb006_7_4_) | !mi(gb006_7_6_) | !mi(gb006_8_1_) | ///
 !mi(gb006_8_2_) | !mi(gb006_8_3_) | !mi(gb006_8_4_) | !mi(gb006_8_5_) | !mi(gb006_8_6_) | ///
 !mi(gb006_8_8_) | !mi(gb006_9_1_) | !mi(gb006_9_2_) | !mi(gb006_9_3_) | !mi(gb006_9_4_) | ///
 !mi(gb008_7_1_) | !mi(gb008_7_2_) | !mi(gb008_7_3_) | !mi(gb008_7_4_) | !mi(gb008_7_5_) | /// 
 !mi(gb008_8_1_) | !mi(gb008_8_2_) | !mi(gb008_8_3_) | !mi(gb008_8_4_) | !mi(gb008_8_5_) | ///
 !mi(gb008_8_6_) | !mi(gb008_8_7_) | !mi(gb008_9_1_) | !mi(gb008_9_2_) | !mi(gb008_9_3_) | ///
 !mi(gb008_9_4_) | !mi(gb008_9_5_) | !mi(gb008_9_6_) 

replace hh5iothhh=.d if hh5gz_other==.d | gb006_1_1_==.d | ///
 gb006_1_2_==.d | gb006_1_3_==.d | gb006_1_4_==.d | gb006_1_5_==.d | /// 
 gb006_1_6_==.d | gb006_1_7_==.d | gb006_2_1_==.d | gb006_2_2_==.d | /// 
 gb006_2_3_==.d | gb006_2_4_==.d | gb006_3_1_==.d | gb006_3_2_==.d | /// 
 gb006_3_3_==.d | gb006_3_4_==.d | gb006_4_1_==.d | gb006_4_2_==.d | /// 
 gb006_4_3_==.d | gb006_4_4_==.d | gb006_4_5_==.d | gb006_4_6_==.d | /// 
 gb006_5_1_==.d | gb006_5_2_==.d | gb006_5_3_==.d | gb006_5_4_==.d | /// 
 gb006_6_1_==.d | gb006_6_2_==.d | gb006_6_3_==.d | gb006_6_4_==.d | /// 
 gb006_7_1_==.d | gb006_7_2_==.d | gb006_7_3_==.d | gb006_7_4_==.d | /// 
 gb006_7_6_==.d | gb006_8_1_==.d | gb006_8_2_==.d | gb006_8_3_==.d | /// 
 gb006_8_4_==.d | gb006_8_5_==.d | gb006_8_6_==.d | gb006_8_8_==.d | /// 
 gb006_9_1_==.d | gb006_9_2_==.d | gb006_9_3_==.d | gb006_9_4_==.d | ///
 gb008_7_1_==.d | gb008_7_2_==.d | gb008_7_3_==.d | gb008_7_4_==.d | /// 
 gb008_7_5_==.d | gb008_8_1_==.d | gb008_8_2_==.d | gb008_8_3_==.d | ///
 gb008_8_4_==.d | gb008_8_5_==.d | gb008_8_6_==.d | gb008_8_7_==.d | /// 
 gb008_9_1_==.d | gb008_9_2_==.d | gb008_9_3_==.d | gb008_9_4_==.d | /// 
 gb008_9_5_==.d | gb008_9_6_==.d 

replace hh5iothhh=.r if hh5gz_other==.r | gb006_1_1_==.r | ///
 gb006_1_2_==.r | gb006_1_3_==.r | gb006_1_4_==.r | gb006_1_5_==.r | /// 
 gb006_1_6_==.r | gb006_1_7_==.r | gb006_2_1_==.r | gb006_2_2_==.r | /// 
 gb006_2_3_==.r | gb006_2_4_==.r | gb006_3_1_==.r | gb006_3_2_==.r | /// 
 gb006_3_3_==.r | gb006_3_4_==.r | gb006_4_1_==.r | gb006_4_2_==.r | /// 
 gb006_4_3_==.r | gb006_4_4_==.r | gb006_4_5_==.r | gb006_4_6_==.r | /// 
 gb006_5_1_==.r | gb006_5_2_==.r | gb006_5_3_==.r | gb006_5_4_==.r | /// 
 gb006_6_1_==.r | gb006_6_2_==.r | gb006_6_3_==.r | gb006_6_4_==.r | /// 
 gb006_7_1_==.r | gb006_7_2_==.r | gb006_7_3_==.r | gb006_7_4_==.r | /// 
 gb006_7_6_==.r | gb006_8_1_==.r | gb006_8_2_==.r | gb006_8_3_==.r | /// 
 gb006_8_4_==.r | gb006_8_5_==.r | gb006_8_6_==.r | gb006_8_8_==.r | /// 
 gb006_9_1_==.r | gb006_9_2_==.r | gb006_9_3_==.r | gb006_9_4_==.r | ///
 gb008_7_1_==.r | gb008_7_2_==.r | gb008_7_3_==.r | gb008_7_4_==.r | /// 
 gb008_7_5_==.r | gb008_8_1_==.r | gb008_8_2_==.r | gb008_8_3_==.r | ///
 gb008_8_4_==.r | gb008_8_5_==.r | gb008_8_6_==.r | gb008_8_7_==.r | /// 
 gb008_9_1_==.r | gb008_9_2_==.r | gb008_9_3_==.r | gb008_9_4_==.r | /// 
 gb008_9_5_==.r | gb008_9_6_==.r 

*****家庭农业收入
recode gc004_1 gc004_2 gc004_1_min gc004_1_max (-1=.d)
replace gc004_1=0 if gc001==2  //非农业家庭
replace gc004_2=0 if gc001==2
replace gc004_1=0 if gc003==2  //没有从事农林生产
replace gc004_2=0 if gc003==2
replace gc004_1=0 if gc004==3  //农林生产不赔不赚
replace gc004_2=0 if gc004==3

replace gc004_1=(gc004_1_min+gc004_1_max)/2 if gc004==1 & mi(gc004_1) & ///
 !mi(gc004_1_min) & !mi(gc004_1_max)  //取中间值
replace gc004_1=gc004_1_max if gc004==1 & mi(gc004_1) & ///
 mi(gc004_1_min) & !mi(gc004_1_max)  
replace gc004_1=gc004_1_min if gc004==1 & mi(gc004_1) & ///
 !mi(gc004_1_min) & mi(gc004_1_max)  
replace gc004_2=(gc004_2_min+gc004_2_max)/2 if gc004==2 & mi(gc004_2) & ///
 !mi(gc004_2_min) & !mi(gc004_2_max)  //取中间值
replace gc004_2=gc004_2_max if gc004==2 & mi(gc004_2) & ///
 mi(gc004_2_min) & !mi(gc004_2_max)  
replace gc004_2=gc004_2_min if gc004==2 & mi(gc004_2) & ///
 !mi(gc004_2_min) & mi(gc004_2_max)  
replace gc004_2=gc004_2*(-1)  //亏损取负值
 
recode gc006_1 gc006_2 gc006_1_min gc006_1_max gc006_2_min gc006_2_max (-1=.d)
replace gc006_1=0 if gc001==2   //非农业家庭
replace gc006_2=0 if gc001==2
replace gc006_1=0 if gc006==3   //牲畜/水产品收入不赔不赚
replace gc006_2=0 if gc006==3
replace gc006_1=0 if gc005==2   //没有牲畜/水产品
replace gc006_2=0 if gc005==2
replace gc006_1=(gc006_1_min+gc006_1_max)/2 if gc006==1 & mi(gc006_1) & ///
 !mi(gc006_1_min) & !mi(gc006_1_max)  //取中间值
replace gc006_1=gc006_1_max if gc006==1 & mi(gc006_1) & ///
 mi(gc006_1_min) & !mi(gc006_1_max)  
replace gc006_1=gc006_1_min if gc006==1 & mi(gc006_1) & ///
 !mi(gc006_1_min) & mi(gc006_1_max)  
replace gc006_2=(gc006_2_min+gc006_2_max)/2 if gc006==2 & mi(gc006_2) & ///
 !mi(gc006_2_min) & !mi(gc006_2_max)  //取中间值
replace gc006_2=gc006_2_max if gc006==2 & mi(gc006_2) & ///
 mi(gc006_2_min) & !mi(gc006_2_max)  
replace gc006_2=gc006_2_min if gc006==2 & mi(gc006_2) & ///
 !mi(gc006_2_min) & mi(gc006_2_max)  
replace gc006_2=gc006_2*(-1)   //亏损取负值

*****企业经营收入
recode gd004_1 gd004_2 gd004_1_min gd004_1_max gd004_2_min gd004_2_max (-1=.d)
replace gd004_1=0 if gd001==2   //非私营家庭
replace gd004_2=0 if gd001==2
replace gd004_1=0 if gd004==3   //经营收入不赔不赚
replace gd004_2=0 if gd004==3
replace gd004_1=(gd004_1_min+gd004_1_max)/2 if gd004==1 & mi(gd004_1) & ///
 !mi(gd004_1_min) & !mi(gd004_1_max)  //取中间值
replace gd004_1=gd004_1_max if gd004==1 & mi(gd004_1) & ///
 mi(gd004_1_min) & !mi(gd004_1_max)  
replace gd004_1=gd004_1_min if gd004==1 & mi(gd004_1) & ///
 !mi(gd004_1_min) & mi(gd004_1_max)  
replace gd004_2=(gd004_2_min+gd004_2_max)/2 if gd004==2 & mi(gd004_2) & ///
 !mi(gd004_2_min) & !mi(gd004_2_max)  //取中间值
replace gd004_2=gd004_2_max if gd004==2 & mi(gd004_2) & ///
 mi(gd004_2_min) & !mi(gd004_2_max)  
replace gd004_2=gd004_2_min if gd004==2 & mi(gd004_2) & ///
 !mi(gd004_2_min) & mi(gd004_2_max)  
replace gd004_2=gd004_2*(-1)

*****计算{农业收入+个体经营和私营}之和
egen hh5icap=rowtotal(gc004_1 gc004_2 gc006_1 gc006_2 gd004_1 gd004_2),mi //资本性收入=农业收入+经营收入
replace hh5icap=.m if gc001==.
replace hh5icap=.d if gc004_1==.d | gc004_2==.d | gc006_1==.d | gc006_2==.d | gd004_1==.d | gd004_2==.d 


*****家户公共转移支付收入
*低保
recode ge004_1_ ge004_2_ ge004_3_ ge004_4_ ge004_5_ ge004_min_1_ ge004_max_1_ ///
  ge004_min_2_ ge004_max_2_ ge004_min_3_ ge004_max_3_ ge004_min_4_ ge004_max_4_ ///
  ge004_min_5_ ge004_max_5_ (-1=.d)
 
forvalues i=1/5 {
  replace ge004_`i'_=(ge004_min_`i'_ + ge004_max_`i'_)/2 if mi(ge004_`i'_) & !mi(ge004_min_`i'_) & !mi(ge004_max_`i'_) //取中间值
  replace ge004_`i'_=ge004_min_`i'_ if mi(ge004_`i'_) & !mi(ge004_min_`i'_) & mi(ge004_max_`i'_)
  replace ge004_`i'_=ge004_max_`i'_ if mi(ge004_`i'_) & mi(ge004_min_`i'_) & !mi(ge004_max_`i'_)
}  

*政府补助 
recode ge006_1 ge006_2 ge006_3 ge006_4 ge006_5 ge006_6 ge006_7 ge006_8 (-1=.d)

*农业保险赔付
recode ge007 (-1=.d)

*疫情补助
recode ge008_1 ge008_1_min ge008_1_max (-1=.d)
replace ge008_1=0 if ge008==2
replace ge008_1=(ge008_1_min + ge008_1_max)/2 if mi(ge008_1) & !mi(ge008_1_min) & !mi(ge008_1_max) //取中间值
replace ge008_1=ge008_1_min if mi(ge008_1) & !mi(ge008_1_min) & mi(ge008_1_max)
replace ge008_1=ge008_1_max if mi(ge008_1) & mi(ge008_1_min) & !mi(ge008_1_max)  

*光伏发电的收入
recode ge011 (-1=.d)  
replace ge011=0 if ge009==2

*土地出租
recode ge012 ge012_min ge012_max (-1=.d)  
replace ge012=(ge012_min + ge012_max)/2 if mi(ge012) & !mi(ge012_min) & !mi(ge012_max) //取中间值
replace ge012=ge012_min if mi(ge012) & !mi(ge012_min) & mi(ge012_max)
replace ge012=ge012_max if mi(ge012) & mi(ge012_min) & !mi(ge012_max)

*房产出租
recode ge013 ge013_min ge013_max (-1=.d)  
replace ge013=(ge013_min + ge013_max)/2 if mi(ge013) & !mi(ge013_min) & !mi(ge013_max) //取中间值
replace ge013=ge013_min if mi(ge013) & !mi(ge013_min) & mi(ge013_max)
replace ge013=ge013_max if mi(ge013) & mi(ge013_min) & !mi(ge013_max)

*出租其他家庭资产
recode ge014_1 (-1=.d)
replace ge014_1=0 if ge014==2
replace ge014_1=.d if ge014==997
replace ge014_1=.r if ge014==999

*****计算其他家庭成员的公共转移支出收入之和
egen hh5igxfr=rowtotal(ge004_1_ ge004_2_ ge004_3_ ge004_4_ ge004_5_ ge006_1 ///
 ge006_2 ge006_3 ge006_4 ge006_5 ge006_6 ge006_7 ge006_8 ge007 ge008_1 ge011 ///
 ge012 ge013 ge014_1),mi
replace hh5igxfr=.m if ge006_s9==. | ge001_s6==. 
replace hh5igxfr=.d if ge004_1_==.d | ge004_2_==.d | ge004_3_==.d | ge004_4_==.d | ///
 ge004_5_==.d | ge006_1==.d | ge006_2==.d | ge006_3==.d | ge006_4==.d | ge006_5==.d | ///
 ge006_6==.d | ge006_7==.d | ge006_8==.d | ge007==.d | ge008_1==.d | ge011==.d | ///
 ge012==.d | ge013==.d | ge014_1==.d 
replace hh5igxfr=.r if ge014_1==.r
 
*****个人工资
recode ga002 ga002_min ga002_max (-1=.d)
replace ga002=0 if ga001==2 
replace ga002=(ga002_min + ga002_max)/2 if mi(ga002) & !mi(ga002_min) & !mi(ga002_max)
replace ga002=ga002_min if mi(ga002) & !mi(ga002_min) & mi(ga002_max)
replace ga002=ga002_max if mi(ga002) & mi(ga002_min) & !mi(ga002_max)

*个人工资应扣除杂费部分
recode ga004_1 ga004_1_min ga004_1_max ga004_2 ga004_3 (-1=.d)
gen r5ibonus=.
replace r5ibonus=(ga004_1_min + ga004_1_max)/2*12 if !mi(ga004_1_min) & !mi(ga004_1_max) & ga004==1
replace r5ibonus=ga004_1_min*12 if !mi(ga004_1_min) & mi(ga004_1_max) & ga004==1
replace r5ibonus=ga004_1_max*12 if mi(ga004_1_min) & !mi(ga004_1_max) & ga004==1
replace r5ibonus=ga004_2 if ga004==2
replace r5ibonus=ga002*(ga004_3/100) if !mi(ga002) & !mi(ga004_3) & ga004==3
replace r5ibonus=0 if ga004==4

gen r5itearn=ga002 
replace r5itearn=ga002-r5ibonus if ga003==2 & !mi(ga002) &!mi(r5ibonus)  //如果工资没有扣除杂费

*****计算受访者(配偶双方)的工资之和
bys householdID: egen h5itearn=total(r5itearn) if !mi(r5itearn)  

*****计算受访者(配偶双方)享受的公司福利
recode fc042_1 fc042_2 fc042_3 fc042_4 fc042_1_min fc042_1_max fc042_2_min ///
 fc042_2_max fc042_3_min fc042_3_max fc042_4_min fc042_4_max (-1=.d) (999=.r)
 
forvalues i=1/4 {
 replace fc042_`i'=(fc042_`i'_min + fc042_`i'_max)/2 if mi(fc042_`i') & !mi(fc042_`i'_min) & !mi(fc042_`i'_max)
 replace fc042_`i'=fc042_`i'_min if mi(fc042_`i') & !mi(fc042_`i'_min) & mi(fc042_`i'_max)
 replace fc042_`i'=fc042_`i'_max if mi(fc042_`i') & mi(fc042_`i'_min) & !mi(fc042_`i'_max)
}
forvalues i=1/4 {
 replace fc042_`i'=fc042_`i'*12 if !mi(fc042_`i')
}
egen r5iothr=rowtotal(fc042_1 fc042_2 fc042_3 fc042_4)
replace r5iothr=.d if fc042_1==.d | fc042_2==.d | fc042_3==.d | fc042_4==.d 
replace r5iothr=.r if fc042_1==.r | fc042_2==.r | fc042_3==.r | fc042_4==.r 
bys householdID: egen h5iothr=total(r5iothr) if !mi(r5iothr)  

*****个人转移支付收入
recode ga005_1 ga005_1_min ga005_1_max ga005_2 ga005_3 ga005_4 ga005_5 ///
 ga005_6 ga005_7 ga005_8 ga005_9 (-1=.d)
replace ga005_1=(ga005_1_min + ga005_1_max)/2 if mi(ga005_1) & !mi(ga005_1_min) & !mi(ga005_1_max)
replace ga005_1=ga005_1_min if mi(ga005_1) & !mi(ga005_1_min) & mi(ga005_1_max)
replace ga005_1=ga005_1_max if mi(ga005_1) & mi(ga005_1_min) & !mi(ga005_1_max)
egen r5igxfr=rowtotal(ga005_1 ga005_2 ga005_3 ga005_4 ga005_5 ga005_6 ga005_7 ga005_8 ga005_9)
replace r5igxfr=.d if ga005_1==.d | ga005_2==.d | ga005_3==.d | ga005_4==.d | ///
  ga005_5==.d | ga005_6==.d | ga005_7==.d | ga005_8==.d | ga005_9==.d 
replace r5igxfr=.m if ga005_s10==.

*****计算受访者(配偶双方)的转移支付收入之和
bys householdID: egen h5igxfr=total(r5igxfr) if !mi(r5igxfr)  

egen hh5itot=rowtotal(hh5iothhh hh5icap hh5igxfr h5itearn h5iothr h5igxfr),mi   //家庭总收入包括其他成员的总收入+农业和企业经营收入之和+其他家庭成员的转移支付之和+受访者的工资之和+公司福利+受访者的转移支付之和
replace hh5itot=.m if inw5==0
replace hh5itot=.m if mi(hh5iothhh) | mi(hh5icap) | mi(hh5igxfr) | mi(h5itearn) | mi(h5igxfr) | mi(h5iothr)
replace hh5itot=.d if hh5iothhh==.d | hh5icap==.d | hh5igxfr==.d | h5itearn==.d | h5igxfr==.d | h5iothr==.d
replace hh5itot=.r if hh5iothhh==.r | hh5icap==.r | hh5igxfr==.r | h5itearn==.r | h5igxfr==.r | h5iothr==.r

*****过去一周感到抑郁的频率
*r5depresl
gen r5depresl=dc018 if inrange(dc018,1,4)

*****过去一周觉得一切都是努力的频率
*r5effortl
gen r5effortl=dc019 if inrange(dc019,1,4)

*****过去一周感到睡眠不安的频率
*r5sleeprl
gen r5sleeprl=dc022 if inrange(dc022,1,4)

*****过去一周感到快乐的频率
*r5whappyl
gen r5whappyl=dc023 if inrange(dc023,1,4)

*****过去一周感到孤独的频率
*r5flonel
gen r5flonel=dc024 if inrange(dc024,1,4)

*****过去一周被通常不会困扰他们的事情所困扰
*r5botherl
gen r5botherl=dc016 if inrange(dc016,1,4)

*****过去一周感到无法行动的频率
*r5goingl
gen r5goingl=dc025 if inrange(dc025,1,4)

*****过去一周感到难以集中注意力的频率
*r5mindtsl
gen r5mindtsl=dc017 if inrange(dc017,1,4)

*****过去一周对未来抱有希望的频率
*r5fhopel
gen r5fhopel=dc020 if inrange(dc020,1,4)

*****过去一周感到恐惧的频率
*r5fearll
gen r5fearll=dc021 if inrange(dc021,1,4)

*****CESD10
recode r5whappyl (1 = 4)(2 = 3)(3 = 2)(4 = 1), gen(xr5whappyl)
recode r5fhopel (1 = 4)(2 = 3)(3 = 2)(4 = 1), gen(xr5fhopel)	
	
foreach var in r5depresl r5effortl r5sleeprl xr5whappyl r5flonel r5botherl r5goingl ///
               r5mindtsl xr5fhopel r5fearll {
	gen `var'_scale = `var' - 1
}
egen r5cesd10 = rowtotal(r5depresl_scale r5effortl_scale r5sleeprl_scale xr5whappyl_scale ///
                   r5flonel_scale r5botherl_scale r5goingl_scale r5mindtsl_scale ///
                   xr5fhopel_scale r5fearll_scale),mi
  
*****是否工作
*r5work
rename xworking r5work

*****是否退休
recode fh001 (2=0)
replace zrretired=fh001 if (zrretired==0 | zrretired==.) & !mi(fh001)
rename zrretired r5fret_c  

*****退休月份
*r5retmon
gen r5retmon=fh003_2

*****退休年份
*r5retyr
gen r5retyr=fh003_1

*****跌倒
*r5fall_down
replace da022=da023 if mi(da022) & !mi(da023)
recode da022 (1=1) (2=0) (else=.),gen(r5fall_down)

*****睡眠时间
*r5sleep_night r5sleep_nap
rename (da030 da031) (r5sleep_night r5sleep_nap) 

*****疼痛
*r5da042s1 r5da042s2 r5da042s3 r5da042s4 r5da042s5 r5da042s6 r5da042s7 
*r5da042s8 r5da042s9 r5da042s10 r5da042s11 r5da042s12 r5da042s13 r5da042s14 r5da042s15
forvalues i=1/15 {
  recode da028_s`i' (1/15=1) 
  replace da028_s`i'=0 if da027==1 
  rename da028_s`i' r5da042s`i'
}

*****髋骨骨折
*r5hip
replace da025=da026 if mi(da025)
recode da025 (1=1) (2=0) (else=.),gen(r5hip)

*****死亡变量
*died exb001_1 exb001_2 exb001_3 exb002 

*****子女关系满意度
*r5sati_child
recode dc027 (1=5) (2=4) (3=3) (4=2) (5=1) (6=.),gen(r5sati_child) 

*****生活满意度
*r5satlife
recode dc027 (1=5) (2=4) (3=3) (4=2) (5=1),gen(r5satlife)

*****生活满意度z评分
*r5satlifez
zscore r5satlife if inrange(r5satlife,1,5)
rename z_r5satlife r5satlifez

*****取暖燃料
recode i020 (1 3 4 5 8=0) (2 6=1) (7=.),gen(r5clean_heat)
replace r5clean_heat=0 if i019==1

*****做饭燃料
recode i021 (2 3 4 5 7 9=0) (1 6=1) (8=.),gen(r5clean_cook)

*****房间数量
egen r5room=rowtotal(i011_1 i011_2),mi

*****是否有自来水
recode i016 (1=1) (2=0), gen(r5water)

*****是否有电
recode i015 (1=1) (2=0), gen(r5electricity)

*****厕所卫生差
gen r5toilet=0 if !mi(i011_3)
replace r5toilet=1 if i011_3==0 | i014==2

*****建筑材料差
recode i001 (1=0) (2/7=1),gen(r5build)

*****权重信息
rename (HH_weight HH_weight_ad1 INDV_weight INDV_weight_ad2) (r5wthh r5wthha r5wtresp r5wtrespb)

*****保存所需变量  
keep ID householdID communityID inw5 h5rural r5iwy r5iwm zrbirthyear r5birthmonth ///
r5gender r5educ_c r5mstath r5hukou r5shlta r5dressa r5batha r5eata r5beda /// 
r5toilta r5urina r5adlab_c r5housewka r5mealsa r5shopa r5phonea r5medsa r5moneya /// 
r5iadl r5hibpe r5dyslipe r5diabe r5cancre r5lunge r5livere r5hearte r5stroke /// 
r5kidneye r5digeste r5psyche r5memrye r5arthre r5asthmae r5parkinson r5hibpe_self  ///
r5lunge_self r5psyche_self r5vgact_c r5mdact_c r5ltact_c r5vgactx_c r5mdactx_c ///
r5ltactx_c r5vgactime r5mdactime r5ltactime r5drinkl r5smokev r5smoken  ///
r5doctor1m r5doctim1m r5hosp1y r5hsptim1y r5pension r5ins r5ea001s1  ///
r5ea001s2 r5ea001s3 r5ea001s4 r5ea001s5 r5ea001s11 r5slfmem r5imrc r5dlrc  ///
r5recall r5tr20 r5mo r5dy r5yr r5dw r5ds r5orient r5draw r5ser7 r5executive r5total_cognition  ///
r5act_1 r5act_2 r5act_3 r5act_4 r5act_5 r5act_6 r5act_7 r5act_8 r5socwk h5hhres  ///
h5son h5dau h5child h5coresd h5kcntf h5kcntpm h5kcnt hh5ctot hh5cperc h5fcamt h5fcany /// 
h5tcamt h5tcany hh5itot r5depresl r5effortl r5sleeprl r5whappyl r5flonel  ///
r5botherl r5goingl r5mindtsl r5fhopel r5fearll r5cesd10 r5work r5satlife ///
r5fret_c r5retmon r5retyr r5sleep_night r5sleep_nap r5hip died exb001_1 exb001_2 ///
exb001_3 exb002 r5sati_child r5slfmem r5satlife r5satlifez r5wthh r5wthha ///
r5wtresp r5wtrespb r5fall_down r5smokef r5da042s1 r5da042s2 r5da042s3 r5da042s4 /// 
r5da042s5 r5da042s6 r5da042s7 r5da042s8 r5da042s9 r5da042s10 r5da042s11 /// 
r5da042s12 r5da042s13 r5da042s14 r5da042s15 r5freq_act_1 r5freq_act_2 r5freq_act_3 /// 
r5freq_act_4 r5freq_act_5 r5freq_act_6 r5freq_act_7 r5freq_act_8 r5clean_heat r5clean_cook ///
r5build r5toilet r5electricity r5water r5room
   
*****final sort
sort ID

*****compress dataset
compress	

*****add label
label data "charls202"

*****save output dataset
save "$temp_data/charls20", replace