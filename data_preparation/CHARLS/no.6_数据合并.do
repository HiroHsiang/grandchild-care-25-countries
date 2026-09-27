
clear all
set more off
set maxvar 20000
global root= "E:\CHARLS_中国"
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
************************************ 数据合并 **********************************
use "$raw_data\Harmonized_CHARLS_D\H_CHARLS_D_Data.dta", clear     //导入数据 
merge 1:1 ID using "$temp_data/charls11.dta",keep(1 3) nogen nolabel
merge 1:1 ID using "$temp_data/charls13.dta",keep(1 3) nogen nolabel
merge 1:1 ID using "$temp_data/charls15.dta",keep(1 3) nogen nolabel
merge 1:1 ID using "$temp_data/charls18.dta",keep(1 3) nogen nolabel
merge 1:1 ID using "$temp_data/charls20",nogen nolabel
merge m:1 communityID using "$raw_data\2013charls\PSU.dta",nogen nolabel
********************************************************************************
*****是否参与本次调查
*inw1 inw2 inw3 inw4 inw5
replace inw5=0 if mi(inw5)

*****受访年份
*r1iwy r2iwy r3iwy r4iwy r5iwy

*****受访月份
*r1iwm r2iwm r3iwm r4iwm r5iwm

*****出生年份
*rabyear

*****出生月份
*rabmonth
replace rabmonth=r5birthmonth if mi(rabmonth)

*****死亡年份
*radyear 
replace radyear=exb001_1 if mi(radyear)

*****死亡年份
*radmonth
replace radmonth=exb001_2 if mi(radmonth)

*****是否死亡
*r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat
gen r5iwstat=0
replace r5iwstat= 1 if inw5==1
replace r5iwstat= 9 if inw5==0 & inlist(r4iwstat,1,4,9)
replace r5iwstat= 4 if inw5==0 & died==0
replace r5iwstat= 5 if inw5==0 & died==1
replace r5iwstat= 6 if inw5==0 & inlist(r4iwstat,5,6)

forvalues i=1/5 {
 recode r`i'iwstat (0=.) (1 4=0) (5 6=1) (9=.)
}

forvalues i=2/5 {
 replace r`i'iwstat=1 if radyear<r`i'iwy & !mi(radyear) & !mi(r`i'iwy)
 replace r`i'iwstat=1 if radyear==r`i'iwy & radmonth<=r`i'iwm & !mi(radyear) & !mi(r`i'iwy)
 replace r`i'iwstat=0 if radyear==r`i'iwy & radmonth>r`i'iwm & !mi(radyear) & !mi(r`i'iwy)
 replace r`i'iwstat=0 if radyear>r`i'iwy & !mi(radyear) & !mi(r`i'iwy)
}

replace r3iwstat=1 if r2iwstat==1
replace r4iwstat=1 if r3iwstat==1
replace r5iwstat=1 if r4iwstat==1

*****补充死亡年份和月份
forvalues i=1/5 {
  bys communityID:egen r`i'iwy_=mode(r`i'iwy), maxmode
  replace r`i'iwy=r`i'iwy_ if mi(r`i'iwy)
  bys communityID:egen r`i'iwm_=mode(r`i'iwm), maxmode
  replace r`i'iwm=r`i'iwm_ if mi(r`i'iwm)
}

replace radyear=(r1iwy + r2iwy)/2 if mi(radyear) & !mi(r1iwy) & !mi(r2iwy) & r1iwstat==0 & r2iwstat==1
replace radyear=(r1iwy + r3iwy)/2 if mi(radyear) & !mi(r1iwy) & !mi(r3iwy) & r1iwstat==0 & mi(r2iwstat) & r3iwstat==1 
replace radyear=(r1iwy + r4iwy)/2 if mi(radyear) & !mi(r1iwy) & !mi(r4iwy) & r1iwstat==0 & mi(r2iwstat) & mi(r3iwstat) & r4iwstat==1
replace radyear=(r1iwy + r5iwy)/2 if mi(radyear) & !mi(r1iwy) & !mi(r5iwy) & r1iwstat==0 & mi(r2iwstat) & mi(r3iwstat) & mi(r4iwstat) & r5iwstat==1 
replace radyear=(r2iwy + r3iwy)/2 if mi(radyear) & !mi(r2iwy) & !mi(r3iwy) & r2iwstat==0 & r3iwstat==1 
replace radyear=(r2iwy + r4iwy)/2 if mi(radyear) & !mi(r2iwy) & !mi(r4iwy) & r2iwstat==0 & mi(r3iwstat) & r4iwstat==1 
replace radyear=(r2iwy + r5iwy)/2 if mi(radyear) & !mi(r2iwy) & !mi(r5iwy) & r2iwstat==0 & mi(r3iwstat) & mi(r4iwstat) & r5iwstat==1 
replace radyear=(r3iwy + r4iwy)/2 if mi(radyear) & !mi(r3iwy) & !mi(r4iwy) & r3iwstat==0 & r4iwstat==1 
replace radyear=(r3iwy + r5iwy)/2 if mi(radyear) & !mi(r3iwy) & !mi(r5iwy) & r3iwstat==0 & mi(r4iwstat) & r5iwstat==1 
replace radyear=(r4iwy + r5iwy)/2 if mi(radyear) & !mi(r4iwy) & !mi(r5iwy) & r4iwstat==0 & r5iwstat==1 
replace radyear= int(radyear) 

replace radmonth=(r1iwm + r2iwm)/2 if !mi(r1iwm) & !mi(r2iwm) & r1iwstat==0 & r2iwstat==1 & mi(radmonth)
replace radmonth=(r1iwm + r3iwm)/2 if !mi(r1iwm) & !mi(r3iwm) & r1iwstat==0 & mi(r2iwstat) & r3iwstat==1 & mi(radmonth)
replace radmonth=(r1iwm + r4iwm)/2 if !mi(r1iwm) & !mi(r4iwm) & r1iwstat==0 & mi(r2iwstat) & mi(r3iwstat) & r4iwstat==1 & mi(radmonth)
replace radmonth=(r1iwm + r5iwm)/2 if !mi(r1iwm) & !mi(r5iwm) & r1iwstat==0 & mi(r2iwstat) & mi(r3iwstat) & mi(r4iwstat) & r5iwstat==1 & mi(radmonth)
replace radmonth=(r2iwm + r3iwm)/2 if !mi(r2iwm) & !mi(r3iwm) & r2iwstat==0 & r3iwstat==1 & mi(radmonth)
replace radmonth=(r2iwm + r4iwm)/2 if !mi(r2iwm) & !mi(r4iwm) & r2iwstat==0 & mi(r3iwstat) & r4iwstat==1 & mi(radmonth)
replace radmonth=(r2iwm + r5iwm)/2 if !mi(r2iwm) & !mi(r5iwm) & r2iwstat==0 & mi(r3iwstat) & mi(r4iwstat) & r5iwstat==1 & mi(radmonth)
replace radmonth=(r3iwm + r4iwm)/2 if !mi(r3iwm) & !mi(r4iwm) & r3iwstat==0 & r4iwstat==1 & mi(radmonth)
replace radmonth=(r3iwm + r5iwm)/2 if !mi(r3iwm) & !mi(r5iwm) & r3iwstat==0 & mi(r4iwstat) & r5iwstat==1 & mi(radmonth)
replace radmonth=(r4iwm + r5iwm)/2 if !mi(r4iwm) & !mi(r5iwm) & r4iwstat==0 & r5iwstat==1 & mi(radmonth)
replace radmonth= int(radmonth)

*****年龄 
*r1age r2age r3age r4age r5age
replace rabyear=zrbirthyear if mi(rabyear) & !mi(zrbirthyear)
forvalues i=1/5 {
  gen r`i'age=r`i'iwy-rabyear if !mi(r`i'iwy) & !mi(rabyear) //调查年份减出生年份
}

*****性别
*ragender
replace ragender = r5gender if (ragender != r5gender) & !mi(r5gender) 
recode ragender (1=1) (2=0) 

*****教育程度
*raeduc_c raeducl
gen edu=r5educ_c  //以最新的教育程度为基础
replace edu=raeduc_c if mi(r5educ_c)  //填补之前的教育
drop raeduc_c 
recode edu (1/3=1) (4=2) (5=3) (6/11=4),gen(raeduc_c)

drop raeducl //删除原来统一的三级教育分类
recode edu (1/5=1) (6/7=2) (8/11=3),gen(raeducl)
 
*****婚姻状况
*r1mstath r2mstath r3mstath r4mstath r5mstath 

****户口4分类
*r1hukou r2hukou r3hukou r4hukou r5hukou

*****居住在农村或城市
*h1rural h2rural h3rural h4rural h5rural

*****户口2分类
*r1rural2 r2rural2 r3rural2 r4rural2 r5rural2
recode r5hukou (1=1) (2/3=0) (else=.),gen(r5rural2)

*****自评健康
*r1shlta r2shlta r3shlta r4shlta r5shlta
forvalues i=1/5 {
  recode r`i'shlta (1=5) (2=4) (3=3) (4=2) (5=1) //越大越好
}

*****ADL/穿衣
*r1dressa r2dressa r3dressa r4dressa r5dressa
 
*****ADL/沐浴
*r1batha r2batha r3batha r4batha r5batha

*****ADL/进食
*r1eata r2eata r3eata r4eata r5eata

*****ADL/上下床
*r1beda r2beda r3beda r4beda r5beda

*****ADL/使用厕所
*r1toilta r2toilta r3toilta r4toilta r5toilta

*****ADL/控制排尿
*r1urina r2urina r3urina r4urina r5urina

*****IADL/打电话
*r2phonea r3phonea r4phonea r5phonea 

*****IADL/管理资金
*r1moneya r2moneya r3moneya r4moneya r5moneya 

*****IADL/服用药物
*r1medsa r2medsa r3medsa r4medsa r5medsa

*****IADL/购买食品杂货
*r1shopa r2shopa r3shopa r4shopa r5shopa

*****IADL/准备饭菜
*r1mealsa r2mealsa r3mealsa r4mealsa r5mealsa

*****IADL/打扫房屋
*r1housewka r2housewka r3housewka r4housewka r5housewka

*****其他功能限制/跑步或慢跑1公里
*r1joga r2joga r3joga r4joga

*****其他功能限制/步行1公里
*r1walk1kma r2walk1kma r3walk1kma r4walk1kma

*****其他功能限制/步行100米
*r1walk100a r2walk100a r3walk100a r4walk100a

*****其他功能限制/长时间坐着从椅子上站起来
*r1chaira r2chaira r3chaira r4chaira 

*****其他功能限制/不休息地爬几层楼梯
*r1climsa r2climsa r3climsa r4climsa 

*****其他功能限制/弯腰跪下或蹲下
*r1stoopa r2stoopa r3stoopa r4stoopa 

*****其他功能限制/举起或搬运超过10斤的重物
*r1lifta r2lifta r3lifta r4lifta 

*****其他功能限制/从桌子上捡起硬币
*r1dimea r2dimea r3dimea r4dimea

*****其他功能限制/手臂超过肩膀
*r1armsa r2armsa r3armsa r4armsa

*****ADL(6分)
*r1adlab_c r2adlab_c r3adlab_c r4adlab_c r5adlab_c  

*****IADL(5分)
*r1iadl r2iadl r3iadl r4iadl r5iadl
forvalues i=1/4 {
  egen r`i'iadl=rowtotal(r`i'moneya r`i'medsa r`i'shopa r`i'mealsa r`i'housewka),mi 
}

*****医生是否诊断患有高血压
*r1hibpe r2hibpe r3hibpe r4hibpe r5hibpe

*****医生是否诊断患有糖尿病
*r1diabe r2diabe r3diabe r4diabe r5diabe

*****医生是否诊断患有癌症或恶性肿瘤
*r1cancre r2cancre r3cancre r4cancre r5cancre

*****医生是否诊断患有慢性肺部疾病
*r1lunge r2lunge r3lunge r4lunge r5lunge

*****医生是否诊断患有心脏病
*r1hearte r2hearte r3hearte r4hearte r5hearte

*****医生是否诊断患有中风
*r1stroke r2stroke r3stroke r5stroke

*****医生是否诊断患有精神问题
*r1psyche r2psyche r3psyche r4psyche r5psyche

*****医生是否诊断患有关节炎或风湿病
*r1arthre r2arthre r3arthre r4arthre r5arthre

*****医生是否诊断患有血脂异常
*r1dyslipe r2dyslipe r3dyslipe r4dyslipe r5dyslipe

*****医生是否诊断患有肝脏疾病
*r1livere r2livere r3livere r4livere r5livere

*****医生是否诊断患有任何肾脏疾病
*r1kidneye r2kidneye r3kidneye r4kidneye r5kidneye

*****医生是否诊断患有胃部或其他消化系统疾病
*r1digeste r2digeste r3digeste r4digeste r5digeste

*****医生是否诊断患有哮喘
*r1asthmae r2asthmae r3asthmae r4asthmae r5asthmae

*****医生是否诊断患有记忆相关疾病
*r1memrye r2memrye r3memrye r4memrye r5memrye

*****服用西方现代高血压药物
*r1rxhibp r2rxhibp r3rxhibp r4rxhibp

*****是否服用任何治疗高血压的药物
*r1rxhibp_c r2rxhibp_c r3rxhibp_c r4rxhibp_c 

*****是否注射胰岛素治疗糖尿病
*r1rxdiabi r2rxdiabi r3rxdiabi r4rxdiabi 

*****是否注射胰岛素或正在服用糖尿病西药
*r1rxdiab r2rxdiab r3rxdiab r4rxdiab 

*****是否正在服用任何治疗糖尿病的药物
*r1rxdiab_c r2rxdiab_c r3rxdiab_c r4rxdiab_c 

*****是否服用过西药治疗癌症
*r1cncrmeds r2cncrmeds r3cncrmeds r4cncrmeds 

*****过去两年内服用过任何药物治疗癌症
*r1cncrmeds_c r2cncrmeds_c r3cncrmeds_c r4cncrmeds_c 

*****过去两年内是否接受过化疗治疗癌症
*r1cncrchem r2cncrchem r3cncrchem r4cncrchem 

*****过去两年内是否接受过手术治疗癌症
*r1cncrsurg r2cncrsurg r3cncrsurg r4cncrsurg 

*****过去两年内是否接受过放射治疗癌症
*r1cncrradn r2cncrradn r3cncrradn r4cncrradn

*****是否服用西药治疗慢性肺病
*r1rxlung r2rxlung r3rxlung r4rxlung 

*****是否服用任何药物治疗慢性肺病
*r1rxlung_c r2rxlung_c r3rxlung_c r4rxlung_c 

*****是否服用西药治疗心脏病
*r1rxheart r2rxheart r3rxheart r4rxheart 

*****是否服用任何药物治疗心脏病
*r1rxheart_c r2rxheart_c r3rxheart_c r4rxheart_c 

*****是否服用西药治疗中风
*r1rxstrok r2rxstrok r3rxstrok r4rxstrok 

*****是否正在服用任何药物治疗中风
*r1rxstrok_c r2rxstrok_c r3rxstrok_c r4rxstrok_c 

*****是否正在服用药物治疗精神问题
*r1rxpsych r2rxpsych r3rxpsych r4rxpsych 

*****是否正在接受精神问题的治疗
*r1trpsych r2trpsych r3trpsych r4trpsych 

*****是否服用西药治疗关节炎或风湿病
*r1rxarthr r2rxarthr r3rxarthr r4rxarthr 

*****是否服用任何药物治疗关节炎或风湿病
*r1rxarthr_c r2rxarthr_c r3rxarthr_c r4rxarthr_c 

*****是否服用西药治疗血脂异常
*r1rxdyslip r2rxdyslip r3rxdyslip r4rxdyslip 

*****是否服用任何药物治疗血脂异常
*r1rxdyslip_c r2rxdyslip_c r3rxdyslip_c r4rxdyslip_c 

*****是否服用西药治疗肝病
*r1rxliver r2rxliver r3rxliver r4rxliver 

*****服用任何药物治疗肝病
*r1rxliver_c r2rxliver_c r3rxliver_c r4rxliver_c 

*****是否服用西药治疗肾脏疾病
*r1rxkidney r2rxkidney r3rxkidney r4rxkidney 

*****是否服用任何药物治疗肾脏疾病
*r1rxkidney_c r2rxkidney_c r3rxkidney_c r4rxkidney_c 

*****是否服用西药治疗胃或其他消化系统疾病
*r1rxdigest r2rxdigest r3rxdigest r4rxdigest 

*****是否服用任何药物治疗胃或其他消化系统疾病
*r1rxdigest_c r2rxdigest_c r3rxdigest_c r4rxdigest_c 

*****是否服用西药治疗记忆相关疾病
*r1rxmemry r2rxmemry r3rxmemry r4rxmemry 

*****是否服用任何药物治疗记忆相关疾病
*r1rxmemry_c r2rxmemry_c r3rxmemry_c r4rxmemry_c 

*****是否每周至少进行10分钟的剧烈身体活动
*r1vgact_c r2vgact_c r3vgact_c r4vgact_c r5vgact_c 

*****每周剧烈活动的天数
*r1vgactx_c r2vgactx_c r3vgactx_c r4vgactx_c r5vgactx_c 

*****是否每周至少进行10分钟的中等身体活动
*r1mdact_c r2mdact_c r3mdact_c r4mdact_c r5mdact_c 

*****每周中等身体活动的天数
*r1mdactx_c r2mdactx_c r3mdactx_c r4mdactx_c r5mdactx_c 

*****是否每周至少进行10分钟的轻度身体活动
*r1ltact_c r2ltact_c r3ltact_c r4ltact_c r5ltact_c 

*****每周轻度身体活动的天数
*r1ltactx_c r2ltactx_c r3ltactx_c r4ltactx_c r5ltactx_c 

***每周是否至少10分钟的身体活动
*r1phy_acta r2phy_acta r3phy_acta r4phy_acta r5phy_acta
forvalues i=1/5 {
 gen r`i'phy_acta=. 
 replace r`i'phy_acta=1 if r`i'vgact_c==1 | r`i'mdact_c==1 | r`i'ltact_c==1
 replace r`i'phy_acta=0 if r`i'vgact_c==0 & r`i'mdact_c==0 & r`i'ltact_c==0
}

***每周是否至少一次中等或剧烈活动
*r1phy_actb r2phy_actb r3phy_actb r4phy_actb r5phy_actb
forvalues i=1/5 {
 gen r`i'phy_actb=. 
 replace r`i'phy_actb=1 if r`i'vgact_c==1 
 replace r`i'phy_actb=0 if r`i'vgact_c==0 
}

***每周身体活动的代谢量
*r1totmet r2totmet r3totmet r4totmet r5totmet
forvalue i=1/5 {
  gen r`i'vgacmet =. 
  replace r`i'vgacmet = 8.0 * r`i'vgactx_c * r`i'vgactime if !mi(r`i'vgactime) & !mi(r`i'vgactx_c)   //代谢量=系数 * 天数 * 时长
  replace r`i'vgacmet = 0 if r`i'vgact_c==0 | r`i'vgactx_c==0  //没有重度身体活动则为0
  
  gen r`i'mdacmet =.
  replace r`i'mdacmet = 4.0 * r`i'mdactx_c * r`i'mdactime if !mi(r`i'mdactime) & !mi(r`i'mdactx_c) 
  replace r`i'mdacmet = 0 if r`i'mdact_c==0 | r`i'mdactx_c==0 //没有中度身体活动则为0
  
  gen r`i'ltacmet =. 
  replace r`i'ltacmet = 3.3 * r`i'ltactx_c * r`i'ltactime if !mi(r`i'ltactime) & !mi(r`i'ltactx_c) 
  replace r`i'ltacmet = 0 if r`i'ltact_c==0 | r`i'ltactx_c==0 //没有中度身体活动则为0
  
  egen r`i'totmet= rowtotal(r`i'vgacmet r`i'mdacmet r`i'ltacmet)   //身体活动产生的总代谢量
  replace r`i'totmet=. if r`i'vgacmet==. | r`i'mdacmet==. | r`i'ltacmet==.
}

*****曾经是否饮酒
*r1drinkev r2drinkev r3drinkev r4drinkev r4drinkev 

*****去年是否饮酒
*r1drinkl r2drinkl r3drinkl r4drinkl r4drinkl r5drinkl

*****曾经是否吸烟
*r1smokev r2smokev r3smokev r4smokev r5smokev

*****现在是否吸烟
*r1smoken r2smoken r3smoken r4smoken r5smoken

*****吸烟数量
*r1smokef r2smokef r3smokef r4smokef r5smokef

*****去年去年住院
*r1hosp1y r2hosp1y r3hosp1y r4hosp1y r5hosp1y

*****去年住院次数
*r1hsptim1y r2hsptim1y r3hsptim1y r4hsptim1y  r5hsptim1y 

*****去年最近住院的夜数
*r1hspnite r2hspnite r3hspnite r4hspnite 

*****上月是否门诊
*r1doctor1m r2doctor1m r3doctor1m r4doctor1m r5doctor1m 

*****上月门诊次数
*r1doctim1m r2doctim1m r3doctim1m r4doctim1m r5doctim1m

*****去年是否看过牙医
*r2dentst1y r3dentst1y 

*****去年的牙科诊疗次数
*r2dentim1y r3dentim1y 

*****上月是否去过中医院
*r1trdmed1m r2trdmed1m r3trdmed1m r4trdmed1m 

*****上月到访中医院的次数
*r1trdmdtim1m r2trdmdtim1m r3trdmdtim1m r4trdmdtim1m 

*****去年的自费住院费用
*r1oophos1y r2oophos1y r3oophos1y r4oophos1y

*****去年的住院总开支
*r1tothos1y r2tothos1y r3tothos1y r4tothos1y

*****上月的门诊自付费用
*r1oopdoc1m r2oopdoc1m r3oopdoc1m r4oopdoc1m 

*****上月的门诊总费用
*r1totdoc1m r2totdoc1m r3totdoc1m r4totdoc1m 

*****去年的牙科护理自付支出
*r2oopden1y r3oopden1y 
 
*****去年的牙科护理总支出
*r2totden1y r3totden1y

*****过去一年的牙科护理总支出
*r2totden1y r3totden1y

*****是否领取医疗保险
*r1ins r2ins r3ins r4ins r5ins
forvalues i=1/4 {
  gen r`i'ins=.
  replace r`i'ins=1 if r`i'higov==1 | r`i'hipriv==1 | r`i'hiothp==1
  replace r`i'ins=0 if r`i'higov==0 & r`i'hipriv==0 & r`i'hiothp==0
}

*****是否领取养老保险
*r1pension r2pension r3pension r4pension r4pension r5pension
forvalues i=1/4 {
  gen r`i'pension=.
  replace r`i'pension=1 if r`i'pubpen==1 | r`i'peninc==1 | r`i'othpen==1 | r`i'jcpen==1 
  replace r`i'pension=0 if r`i'pubpen==0 & r`i'peninc==0 & r`i'othpen==0 & r`i'jcpen==0 
}

*****自评记忆状况
*r1slfmem r2slfmem r3slfmem r4slfmem r5slfmem
forvalues i=1/5 {
  recode r`i'slfmem (1=5) (2=4) (3=3) (4=2) (5=1)
}
*****即时记忆
*r1imrc r2imrc r3imrc r4imrc r5imrc 

*****延迟记忆
*r1dlrc r2dlrc r3dlrc r4dlrc r5dlrc

*****序列7测试
*r1ser7 r2ser7 r3ser7 r4ser7 r5ser7 

*****是否能够正确回忆月份
*r1mo r2mo r3mo r4mo r5mo 

*****是否能够正确回忆日期
*r1dy r2dy r3dy r4dy r5dy

*****是否能够正确回忆年份
*r1yr r2yr r3yr r4yr r5yr

*****是否能够正确回忆周
*r1dw r2dw r3dw r4dw r5dw

*****是否能够正确回答季节
*r1ds r2ds r3ds r4ds r5ds

*****是否能够正确回答日期定向
*r1orient r2orient r3orient r4orient r5orient
 
*****是否能够复制指定的图片
*r1draw r2draw r3draw r4draw r5draw

*****单词回忆总分
*r1tr20 r2tr20 r3tr20 r4tr20 r5tr20 

*****非住房金融财富总额
*h1atotfa h2atotfa h3atotfa h4atotfa
replace h1atotfa=h1atotfa/c2011cpindex*c2010cpindex
replace h2atotfa=h2atotfa/c2013cpindex*c2010cpindex
replace h3atotfa=h3atotfa/c2015cpindex*c2010cpindex
replace h4atotfa=h4atotfa/c2018cpindex*c2010cpindex

*****家庭总收入
*hh1itot hh2itot hh3itot hh4itot hh5itot
replace hh1itot=hh1itot/c2011cpindex*c2010cpindex
replace hh2itot=hh2itot/c2013cpindex*c2010cpindex
replace hh3itot=hh3itot/c2015cpindex*c2010cpindex
replace hh4itot=hh4itot/c2018cpindex*c2010cpindex
replace hh5itot=hh5itot/128.1*c2010cpindex

*****家庭总消费
*hh1ctot hh2ctot hh3ctot hh4ctot hh5ctot 
replace hh1ctot=hh1ctot/c2011cpindex*c2010cpindex
replace hh2ctot=hh2ctot/c2013cpindex*c2010cpindex
replace hh3ctot=hh3ctot/c2015cpindex*c2010cpindex
replace hh4ctot=hh4ctot/c2018cpindex*c2010cpindex
replace hh5ctot=hh5ctot/128.1*c2010cpindex

*****家庭人均消费
*hh1cperc hh2cperc hh3cperc hh4cperc hh5cperc
replace hh1cperc=hh1cperc/c2011cpindex*c2010cpindex
replace hh2cperc=hh2cperc/c2013cpindex*c2010cpindex
replace hh3cperc=hh3cperc/c2015cpindex*c2010cpindex
replace hh4cperc=hh4cperc/c2018cpindex*c2010cpindex
replace hh5cperc=hh5cperc/128.1*c2010cpindex

*****家庭规模
*h1hhres h2hhres h3hhres h4hhres h5hhres

*****儿子数量
*h1son h2son h3son h4son h5son

*****女儿数量
*h1dau h2dau h3dau h4dau h5dau

*****子女数量
*h1child h2child h3child h4child h5child

*****17岁时母亲是否从事农业工作
*ramomoccup_c
recode ramomoccup_c (1=1) (2=0)

*****17岁前父亲是否从事农业工作
*radadoccup_c
recode radadoccup_c (1=1) (2=0)

*****是否有子女与他们共同居住
*h1coresd h2coresd h3coresd h4coresd h5coresd

*****是否有子女与家庭及其配偶居住在同一城市或县
*h1lvnear h2lvnear h3lvnear h4lvnear

*****是否每周与父母联系
*h1pcnt h2pcnt h3pcnt h4pcnt

*****是否每周与子女进行面对面接触
*h1kcntf h2kcntf h3kcntf h4kcntf h5kcntf

*****是否每周通过电话、短信、邮件或电子邮件与子女联系
*h1kcntpm h2kcntpm h3kcntpm h4kcntpm h5kcntpm

*****是否每周亲自或通过电话、短信、邮件或电子邮件与他们的任何子女联系
*h1kcnt h2kcnt h3kcnt h4kcnt h5kcnt

*****过去一个月内是否参加过任何社会活动
*r1socwk r2socwk r3socwk r4socwk r5socwk

*****过去一年中是否从其子女/孙辈那里获得任何经济援助
*h1fcany h2fcany h3fcany h4fcany h5fcany

*****过去一年中从子女/孙辈那里获得的经济援助金额
*h1fcamt h2fcamt h3fcamt h4fcamt h5fcamt

*****过去一年是否向其子女/孙辈提供任何经济援助
*h1tcany h2tcany h3tcany h4tcany h5tcany

*****过去一年中向子女/孙辈提供的经济援助金额
*h1tcamt h2tcamt h3tcamt h4tcamt h5tcamt

*****过去一年中是否从其父母/公公婆婆那里获得任何经济援助
*h1fpany h2fpany h3fpany h4fpany

*****过去一年中从其父母/公公婆婆处获得的经济援助金额
*h1fpamt h2fpamt h3fpamt h4fpamt

*****过去一年有否向其父母/公公婆婆提供任何经济援助
*h1tpany h2tpany h3tpany h4tpany

*****过去一年中向其父母/公公婆婆提供的经济援助金额
*h1tpamt h2tpamt h3tpamt h4tpamt

*****是否工作
*r1work r2work r3work r4work r5work 

*****是否正式退休
*r1fret_c r2fret_c r3fret_c r4fret_c r5fret_c 

*****正式退休月份
*r1retmon r2retmon r3retmon r4retmon r5retmon

*****正式退休年份
*r1retyr r2retyr r3retyr r4retyr r5retyr 

*****第1次步行2.5米所花费的秒数
*r1wspeed1 r2wspeed1 r3wspeed1 

*****第2次步行2.5米所花费的秒数
*r1wspeed2 r2wspeed2 r3wspeed2 

*****行走速度的平均值
*r1wspeed r2wspeed r3wspeed 

*****是否愿意并且能够完成步行速度测试
*r1walkcomp r2walkcomp r3walkcomp 

*****第1次收缩压读数
*r1systo1 r2systo1 r3systo1 

*****第2次收缩压读数
*r1systo2 r2systo2 r3systo2 

*****第3次收缩压读数
*r1systo3 r2systo3 r3systo3 

*****收缩压读数平均值
*r1systo r2systo r3systo 

*****第1次舒张压读数
*r1diasto1 r2diasto1 r3diasto1 

*****第2次舒张压读数
*r1diasto2 r2diasto2 r3diasto2 

*****第3次舒张压读数
*r1diasto3 r2diasto3 r3diasto3

*****舒张压读数的平均值
*r1diasto r2diasto r3diasto 

*****第1次脉冲读数
*r1pulse1 r2pulse1 r3pulse1
 
*****第2次脉冲读数
*r1pulse2 r2pulse2 r3pulse2 

*****第3次脉冲读数
*r1pulse3 r2pulse3 r3pulse3 

*****脉冲读数的平均值
*r1pulse r2pulse r3pulse 

*****是否愿意并能够完成血压测量
*r1bpcomp r2bpcomp r3bpcomp 

*****完成血压测量前30分钟内是否吸烟、饮酒或进行任何剧烈运动
*r1bpact30 r2bpact30 r3bpact30 

*****左手第1次力量测量值
*r1lgrip1 r2lgrip1 r3lgrip1 

*****左手第2次力量测量值
*r1lgrip2 r2lgrip2 r3lgrip2 

*****左手力量测量最大值
*r1lgrip r2lgrip r3lgrip 

*****右手第1次力量测量值
*r1rgrip1 r2rgrip1 r3rgrip1 

*****右手第2次力量测量值
*r1rgrip2 r2rgrip2 r3rgrip2 

*****右手力量测量最大值
*r1rgrip r2rgrip r3rgrip 

*****优势手的最大测量值
*r1gripsum r2gripsum r3gripsum 

*****是否愿意并且能够完成握力测试
*r1gripcomp r2gripcomp r3gripcomp 

*****测量身高
*r1mheight r2mheight r3mheight 

*****测量体重
*r1mweight r2mweight r3mweight
 
*****测量腰围
*r1mwaist r2mwaist r3mwaist 

*****身体质量指数BMI
*r1mbmi r2mbmi r3mbmi 

*****BMI分类
*r1mbmicata r2mbmicata r3mbmicata

*****是否愿意并能够完成身高测量
*r1htcomp r2htcomp r3htcomp 

*****是否愿意并能够完成体重测量
*r1wtcomp r2wtcomp r3wtcomp 

*****是否愿意并能够完成腰围测量
*r1watcomp r2watcomp r3watcomp 

*****第1次呼吸测试
*r1puff1 r2puff1 r3puff1 

*****第2次呼吸测试
*r1puff2 r2puff2 r3puff2 

*****第3次呼吸测试
*r1puff3 r2puff3 r3puff3 

*****呼吸测试最大测量值
*r1puff r2puff r3puff 

*****是否愿意并能够完成呼吸测试
*r1puffcomp r2puffcomp r3puffcomp 

*****双脚半前后站立测试的时间
*r1semitan r2semitan r3semitan 

*****是否保持10秒双脚半前后站立的平衡
*r1semidone r2semidone r3semidone 

*****是否愿意并能够完成双脚半前后站立测试
*r1semicomp r2semicomp r3semicomp 

*****是否使用任何补偿运动来稳定双脚半前后站立
*r1semitanc r2semitanc r3semitanc 

*****双脚前后直线站立测试的时间
*r1fulltan r2fulltan r3fulltan 

*****双脚前后直线站立是否保持整整30/60秒的平衡
*r1fulldone r2fulldone r3fulldone 

*****是否愿意并能够完成双脚前后直线站立
*r1fullcomp r2fullcomp r3fullcomp 

*****是否使用任何补偿运动来稳定双脚前后直线站立
*r1fulltanc r2fulltanc r3fulltanc 

*****双脚并拢站立时间
*r1sbstan r2sbstan r3sbstan 

*****是否保持10秒双脚并拢站立
*r1sbsdone r2sbsdone r3sbsdone 

*****是否愿意并且能够完成双脚并拢站立
*r1sbscomp r2sbscomp r3sbscomp 

*****是否使用任何补偿性运动稳定双脚并拢站立
*r1sbstanc r2sbstanc r3sbstanc 

*****重复从椅子站起的时间
*r1chr5sec r2chr5sec r3chr5sec 

*****完成椅子站起的次数
*r1chr5num r2chr5num r3chr5num 

*****是否愿意且能完成5次椅子站起
*r1chr5comp r2chr5comp r3chr5comp 

*****椅子站立测试中是否躯干或手臂
*r1chr5bmv r2chr5bmv r3chr5bmv 

*****是否照料孙子女
*h1gkcare h2gkcare h3gkcare h4gkcare

*****女性监护人在其成长过程中是否酗酒或有毒品问题
*ramomdrug

*****男性监护人在其成长过程中是否酗酒或有毒品问题
*radaddrug

*****监护人在其成长过程中是否有酗酒或吸毒问题
*rapadrug

*****16岁前是否曾因健康问题缺课一个月或更长时间
*ramischlth

*****16岁前自评健康状况
*rahltcom
recode rahltcom (1=5) (2=4) (3=3) (4=2) (5=1)

*****17岁前家庭财务状况
*rafinacom
recode rafinacom (1=5) (2=4) (3=3) (4=2) (5=1)

*****过去一周感到感到情绪低落的频率
*r1depresl r2depresl r3depresl r4depresl r5depresl

*****过去一周做任何事都很费劲的频率
*r1effortl r2effortl r3effortl r4effortl r5effortl

*****过去一周感到睡眠不好的频率
*r1sleeprl r2sleeprl r3sleeprl r4sleeprl r5sleeprl

*****过去一周感到愉快的频率
*r1whappyl r2whappyl r3whappyl r4whappyl r5whappyl

*****过去一周感到孤独的频率
*r1flonel r2flonel r3flonel r4flonel r5flonel

*****过去一周因一些小事而烦恼的频率
*r1botherl r2botherl r3botherl r4botherl r5botherl

*****过去一周感到无法继续我的生活的频率
*r1goingl r2goingl r3goingl r4goingl r5goingl

*****过去一周感到在做事时很难集中精力的频率
*r1mindtsl r2mindtsl r3mindtsl r4mindtsl r5mindtsl

*****过去一周对未来抱有希望的频率
*r1fhopel r2fhopel r3fhopel r4fhopel r5fhopel

*****过去一周感到恐惧的频率
*r1fearll r2fearll r3fearll r4fearll r5fearll

*****CESD10
*r1cesd10 r2cesd10 r3cesd10 r4cesd10 r5cesd10

*****生活满意度(越大越满意)
*r1satlife r2satlife r3satlife r4satlife r5satlife

*****生活满意度z评分
*r1satlifez r2satlifez r3satlifez r4satlifez r5satlifez

*****认知功能
*r1recall r2recall r3recall r4recall r5recall
*r1executive r2executive r3executive r4executive r5executive
*r1total_cognition r2total_cognition r3total_cognition r4total_cognition r5total_cognition
forvalues i=1/4 {
  gen r`i'recall=r`i'tr20/2 
}

forvalues i=1/4 {
  egen r`i'executive=rowtotal(r`i'date_cognition r`i'ser7 r`i'draw)
  replace r`i'executive=. if mi(r`i'date_cognition) | mi(r`i'ser7) | mi(r`i'draw)
}

forvalues i=1/4 {
  egen r`i'total_cognition=rowtotal(r`i'recall r`i'executive),mi //认知能力=情景记忆+心智状况
}


*****慢性病
*r1chronic_num r2chronic_num r3chronic_num r4chronic_num r5chronic_num
forvalues i=1/5 {
egen r`i'chronic_num=rowtotal(r`i'hibpe  r`i'diabe  r`i'dyslipe  r`i'cancre ///
  r`i'lunge  r`i'livere r`i'hearte  r`i'stroke  r`i'kidneye  r`i'digeste ///
  r`i'psyche  r`i'memrye  r`i'arthre  r`i'asthmae)
replace r`i'chronic_num=. if mi(r`i'hibpe) & mi(r`i'diabe) & mi(r`i'dyslipe) & ///
  mi(r`i'cancre) & mi(r`i'lunge) & mi(r`i'livere) & mi(r`i'hearte) & ///
  mi(r`i'stroke) & mi(r`i'kidneye) & mi(r`i'digeste) & mi(r`i'psyche) & ///
  mi(r`i'memrye) & mi(r`i'arthre) & mi(r`i'asthmae) 
}

***患病年份和患病月份
*da009_1_1_ da009_1_2_ da009_1_3_ da009_1_4_ da009_1_5_ da009_1_6_ da009_1_7_ 
*da009_1_8_ da009_1_9_ da009_1_10_ da009_1_11_ da009_1_12_ da009_1_13_ da009_1_14_ 
forvalues i=1/14 {
 gen da009_1_`i'_= r4da009_1_`i'_
 replace da009_1_`i'_=r4da009_2_`i'_ + rabyear if !mi(r4da009_2_`i'_) & !mi(rabyear) & mi(da009_1_`i'_)
 replace da009_1_`i'_=. if da009_1_`i'_ > r4iwy & !mi(da009_1_`i'_)
}

egen num=rowtotal(r1hibpe r2hibpe r3hibpe r4hibpe r5hibpe r1hibpe_self r2hibpe_self r3hibpe_self r4hibpe_self r5hibpe_self)
replace da009_1_1_=. if num==0
drop num

egen num=rowtotal(r1dyslipe r2dyslipe r3dyslipe r4dyslipe r5dyslipe)
replace da009_1_2_=. if num==0
drop num

egen num=rowtotal(r1diabe r2diabe r3diabe r4diabe r5diabe)
replace da009_1_3_=. if num==0
drop num

egen num=rowtotal(r1cancre r2cancre r3cancre r4cancre r5cancre)
replace da009_1_4_=. if num==0
drop num

egen num=rowtotal(r1lunge r2lunge r3lunge r4lunge r5lunge r1lunge_self r2lunge_self r3lunge_self r4lunge_self r5lunge_self)
replace da009_1_5_=. if num==0
drop num

egen num=rowtotal(r1livere r2livere r3livere r4livere r5livere)
replace da009_1_6_=. if num==0
drop num

egen num=rowtotal(r1hearte r2hearte r3hearte r4hearte r5hearte)
replace da009_1_7_=. if num==0
drop num

egen num=rowtotal(r1stroke r2stroke r3stroke r4stroke r5stroke)
replace da009_1_8_=. if num==0
drop num

egen num=rowtotal(r1kidneye r2kidneye r3kidneye r4kidneye r5kidneye)
replace da009_1_9_=. if num==0
drop num

egen num=rowtotal(r1digeste r2digeste r3digeste r4digeste r5digeste)
replace da009_1_10_=. if num==0
drop num

egen num=rowtotal(r1psyche r2psyche r3psyche r4psyche r5psyche r1psyche_self r2psyche_self r3psyche_self r4psyche_self r5psyche_self)
replace da009_1_11_=. if num==0
drop num

egen num=rowtotal(r1memrye r2memrye r3memrye r4memrye r5memrye)
replace da009_1_12_=. if num==0
drop num

egen num=rowtotal(r1arthre r2arthre r3arthre r4arthre r5arthre)
replace da009_1_13_=. if num==0
drop num

egen num=rowtotal(r1asthmae r2asthmae r3asthmae r4asthmae r5asthmae)
replace da009_1_14_=. if num==0
drop num

***民族
*nation

***是否残疾
*r1disability r2disability r3disability r4disability 

*****晚上睡眠时间
*r1sleep_night r2sleep_night r3sleep_night r4sleep_night r5sleep_night 

*****午休时间
*r1sleep_nap r2sleep_nap r3sleep_nap r4sleep_nap r5sleep_nap 

*****是否配戴眼镜
*r1glass r2glass r3glass r4glass

*****远视力
*r1eyesight_distance r2eyesight_distance r3eyesight_distance r4eyesight_distance

*****近视力
*r1eyesight_close r2eyesight_close r3eyesight_close r4eyesight_close 

*****是否佩戴助听器
*r1hear_aid r2hear_aid r3hear_aid r4hear_aid 

*****听力
*r1hear r2hear r3hear r4hear 

*****地区划分
*参考:https://www.stats.gov.cn/hd/lyzx/zxgk/202107/t20210730_1820095.html
gen region= ""
replace region = "东部" if province == "上海市" | ///
                 province == "北京" | ///
                 province == "天津" | ///
                 province == "安徽省" | ///
                 province == "山东省" | ///
                 province == "山西省" | ///
                 province == "广东省" | ///
                 province == "江苏省" | ///
                 province == "江西省" | ///
                 province == "河北省" | ///
                 province == "浙江省" | ///
                 province == "福建省"
replace region = "中部" if province == "河南省" | ///
                 province == "湖北省" | ///
                 province == "湖南省"
replace region = "西部" if province == "内蒙古自治区" | ///
                 province == "广西省" | ///
                 province == "重庆市" | ///
                 province == "四川省" | ///
                 province == "贵州省" | ///
                 province == "云南省" | ///
                 province == "陕西省" | ///
                 province == "甘肃省" | ///
                 province == "青海省" | ///
                 province == "宁夏回族自治区" | ///
                 province == "新疆维吾尔自治区"
replace region = "东北" if province == "吉林省" | ///
                 province == "辽宁省" | ///
                 province == "黑龙江省"
				 
*****癌症部位
*r@da017s*

***甘油三酯葡萄糖指数(TyG指数)
*r1tyg r3tyg 
*r1tyg_bmi r3tyg_bmi
foreach i in 1 3 {
  gen r`i'tyg=ln(r`i'bl_tg*r`i'bl_glu/2) if !mi(r`i'bl_tg) & !mi(r`i'bl_glu)
}

foreach i in 1 3 {
  gen r`i'tyg_bmi=ln(r`i'bl_tg*r`i'bl_glu/2)*r`i'mbmi if !mi(r`i'bl_tg) & !mi(r`i'bl_glu) & !mi(r`i'mbmi)
}

***昼夜节律综合征/代谢综合征
*r1circs r3circs
*r1mets r3mets
foreach i in 1 3 {
  gen r`i'item1=0 if !mi(r`i'mwaist)
  replace r`i'item1=1 if r`i'mwaist>=85 & !mi(r`i'mwaist) & ragender==1
  replace r`i'item1=1 if r`i'mwaist>=80 & !mi(r`i'mwaist) & ragender==0
}

foreach i in 1 3 {
  gen r`i'item2=0 if !mi(r`i'bl_tg)
  replace r`i'item2=1 if r`i'bl_tg>=150 & !mi(r`i'bl_tg) 
  replace r`i'item2=1 if r`i'rxdyslip_c==1
}

foreach i in 1 3 {
  gen r`i'item3=0 if !mi(r`i'bl_hdl)
  replace r`i'item3=1 if r`i'bl_hdl<40 & !mi(r`i'bl_hdl) & ragender==1
  replace r`i'item3=1 if r`i'bl_hdl<50 & !mi(r`i'bl_hdl) & ragender==0
  replace r`i'item3=1 if r`i'rxdyslip_c==1
}

foreach i in 1 3 {
  gen r`i'item4=0 if !mi(r`i'systo)
  replace r`i'item4=1 if r`i'systo>=130 & !mi(r`i'systo)
  replace r`i'item4=1 if r`i'diasto>=85 & !mi(r`i'diasto)
  replace r`i'item4=1 if r`i'rxhibp_c==1
}

foreach i in 1 3 {
  gen r`i'item5=0 if !mi(r`i'bl_glu)
  replace r`i'item5=1 if r`i'bl_glu>=100 & !mi(r`i'bl_glu)
  replace r`i'item5=1 if r`i'rxhibp_c==1
}

foreach i in 1 3 {
  gen r`i'item6=0 if !mi(r`i'sleep_night)
  replace r`i'item6=1 if r`i'sleep_night<6 & !mi(r`i'sleep_night)
}

foreach i in 1 3 {
  gen r`i'item7=0 if !mi(r`i'cesd10)
  replace r`i'item7=1 if r`i'cesd10>=10 & !mi(r`i'cesd10)
}

foreach i in 1 3 {
  egen r`i'num=rowtotal(r`i'item1 r`i'item2 r`i'item3 r`i'item4 r`i'item5 r`i'item6 r`i'item7),mi
  egen r`i'miss=rowmiss(r`i'item1 r`i'item2 r`i'item3 r`i'item4 r`i'item5 r`i'item6 r`i'item7)
  recode r`i'num (0/2=0) (3/7=1),gen(r`i'mets)
  recode r`i'num (0/3=0) (4/7=1),gen(r`i'circs)
  replace r`i'mets=. if r`i'miss>=1
  replace r`i'circs=. if r`i'miss>=1
  drop r`i'miss
}

***虚弱指数
*r1frailtya r2frailtya r3frailtya r4frailtya
forvalues i=1/4 {
  recode r`i'glass (1/2=1) (3=0),gen(r`i'eye)
  recode r`i'shlta (4/5=0) (1/3=1) (else=.),gen(r`i'health)
  recode r`i'cesd10 (0/10=0) (11/30=1),gen(r`i'depression) 
  gen r`i'cog=(14-(r`i'tr20/2 + r`i'orient))/14 if !mi(r`i'tr20) & !mi(r`i'orient)
  egen r`i'frailtya=rowtotal(r`i'hibpe r`i'diabe r`i'hearte r`i'stroke r`i'cancre ///
  r`i'arthre r`i'lunge r`i'asthmae r`i'psyche r`i'memrye r`i'eye r`i'hear_aid r`i'health /// 
  r`i'dressa r`i'batha r`i'eata r`i'beda r`i'toilta r`i'medsa r`i'moneya r`i'shopa r`i'mealsa ///
  r`i'housewka r`i'walk100a r`i'chaira r`i'climsa r`i'lifta r`i'dimea r`i'stoopa r`i'armsa ///
  r`i'depression r`i'cog),mi
  egen r`i'framissa=rowmiss(r`i'hibpe r`i'diabe r`i'hearte r`i'stroke r`i'cancre ///
  r`i'arthre r`i'lunge r`i'asthmae r`i'psyche r`i'memrye r`i'eye r`i'hear_aid r`i'health /// 
  r`i'dressa r`i'batha r`i'eata r`i'beda r`i'toilta r`i'medsa r`i'moneya r`i'shopa r`i'mealsa ///
  r`i'housewka r`i'walk100a r`i'chaira r`i'climsa r`i'lifta r`i'dimea r`i'stoopa r`i'armsa ///
  r`i'depression r`i'cog)
  replace r`i'frailtya=. if r`i'framissa>=1
  replace r`i'frailtya=(r`i'frailtya/32)*100
}


*****衰弱指数
*r1frailtyb r2frailtyb r3frailtyb r4frailtyb
forvalues i=1/4 {
  recode r`i'eyesight_close (0/1=1) (2=0.75) (3=0.5) (4=0.25) (5=0),gen(r`i'sight2)
}

forvalues i=1/4 {
  recode r`i'hear (1=1) (2=0.75) (3=0.5) (4=0.25) (5=0),gen(r`i'hear2)
  replace r`i'hear2=1 if r`i'hear_aid==1
}

forvalues i=1/4 {
  recode r`i'shlt (0/1=1) (2=0.75) (3=0.5) (4=0.25) (5=0),gen(r`i'shlt2)
}

forvalues i=1/4 {
  gen r`i'cogition=(29-r`i'tr20 - r`i'mo - r`i'dy - r`i'yr - r`i'dw - r`i'ser7)/29 ///
  if !mi(r`i'tr20) & !mi(r`i'mo) & !mi(r`i'dy) & !mi(r`i'yr) & !mi(r`i'dw) & !mi(r`i'ser7)
}

forvalues i=1/4 {
egen r`i'frailtyb=rowtotal(r`i'hibpe r`i'diabe r`i'hearte r`i'stroke r`i'cancre ///
  r`i'arthre r`i'lunge r`i'psyche r`i'memrye r`i'sight2 r`i'hear2 r`i'shlt2 ///
  r`i'dressa r`i'batha r`i'eata r`i'beda r`i'toilta r`i'moneya r`i'medsa r`i'shopa /// 
  r`i'mealsa r`i'walk1kma r`i'chaira r`i'climsa r`i'lifta r`i'dimea r`i'stoopa ///
  r`i'armsa r`i'depression r`i'cogition),mi
replace r`i'frailtyb=r`i'frailtyb/30*100
}

*****针对摔倒和骨折进行替换
*r1fall_down r2fall_down r3fall_down r4fall_down r5fall_down
*r1hip r2hip r3hip r4hip r5hip
replace r2fall_down=1 if r1fall_down==1 
replace r3fall_down=1 if r2fall_down==1 
replace r4fall_down=1 if r3fall_down==1 
replace r5fall_down=1 if r4fall_down==1 

replace r2hip=1 if r1hip==1 
replace r3hip=1 if r2hip==1 
replace r4hip=1 if r3hip==1 
replace r5hip=1 if r4hip==1

*****社会隔离4分
forvalues i=1/5 {
 recode r`i'mstath (1 2 3=0) (4 5 7 8=1),gen(r`i'sisa1) //未婚（包括分居、离婚、丧偶或未婚）
 recode h`i'hhres (1=1) (2/99=0),gen(r`i'sisa2)  //独居
 recode h`i'kcnt (1=0) (0=1),gen(r`i'sisa3) //与子女的接触少于每周一次
 recode r`i'socwk (1=0) (0=1),gen(r`i'sisa4)  //过去一个月不参加任何社交活动
 egen r`i'sisa=rowtotal(r`i'sisa1 r`i'sisa2 r`i'sisa3 r`i'sisa4),mi
}

*****社会隔离6分
forvalues i=1/5 {
 recode r`i'mstath (1 2 3=0) (4 5 7 8=1),gen(r`i'sisb1) //未婚（包括分居、离婚、丧偶或未婚）
 recode h`i'hhres (1=1) (2/99=0),gen(r`i'sisb2)  //独居
 recode h`i'kcntf (1=0) (0=1),gen(r`i'sisb3) //与子女见面少于每周一次
 recode r`i'socwk (1=0) (0=1),gen(r`i'sisb4)  //过去一个月不参加任何社交活动
 gen r`i'sisb5=h`i'rural  //生活在农村
 recode h`i'kcntpm (1=0) (0=1),gen(r`i'sisb6) //每周通过电话或者电子邮件与孩子接触少于每周一次
 egen r`i'sisb=rowtotal(r`i'sisb1 r`i'sisb2 r`i'sisb3 r`i'sisb4 r`i'sisb5 r`i'sisb6),mi
}

*****按需求间隔依赖性分类划分的功能依赖性
*r1dependency r2dependency r3dependency r4dependency r5dependency 
forvalues i=1/5 {
  gen r`i'dependency=.
  replace r`i'dependency=0 if r`i'batha==0 & r`i'moneya==0 & r`i'shopa==0 & r`i'housewka==0 & ///
  r`i'mealsa==0 & r`i'medsa==0 & r`i'eata==0 & r`i'dressa==0 & r`i'beda==0 & r`i'toilta==0 
  replace r`i'dependency=1 if r`i'batha==1 | r`i'moneya==1 | r`i'shopa==1 | r`i'housewka==1 
  replace r`i'dependency=2 if (r`i'mealsa==1 | r`i'medsa==1) & (r`i'batha==0 & r`i'moneya==0 & r`i'shopa==0 & r`i'housewka==0) 
  replace r`i'dependency=3 if (r`i'eata==1 | r`i'dressa==1 | r`i'beda==1 | r`i'toilta==1) & ///
  (r`i'mealsa==0 & r`i'medsa==0 & r`i'batha==0 & r`i'moneya==0 & r`i'shopa==0 & r`i'housewka==0) 
}


*****认知的z标准化(ref基线)
*r1memory_z r2memory_z r3memory_z r4memory_z r5memory_z 
*r1orient_z r2orient_z r3orient_z r4orient_z r5orient_z 
*r1executive_z r2executive_z r3executive_z r4executive_z r5executive_z
*r1tcog_z_z r2tcog_z_z r3tcog_z_z r4tcog_z_z r5tcog_z_z 

forvalues i=1/5 {
 egen r`i'mean_memory=mean(r1tr20)
 egen r`i'sd_memory=sd(r1tr20)
 gen r`i'memory_z=(r`i'tr20-r`i'mean_memory)/r`i'sd_memory
}

*****定向的z标准化(ref基线)
forvalues i=1/5 {
 egen r`i'mean_orient=mean(r1orient)
 egen r`i'sd_orient=sd(r1orient)
 gen r`i'orient_z=(r`i'orient-r`i'mean_orient)/r`i'sd_orient
}

*****执行的z标准化(ref基线)
forvalues i=1/5 {
 egen r`i'mean_executive=mean(r1ser7)
 egen r`i'executive_sd=sd(r1ser7)
 gen r`i'executive_z=(r`i'ser7-r`i'mean_executive)/r`i'executive_sd
}
*****总体认知能力z标准化(ref基线)
forvalues i=1/5 {
 egen r`i'tcog_z=rowmean(r`i'memory_z r`i'orient_z r`i'executive_z)
 egen r`i'tcog_z_mean=mean(r1tcog_z)
 egen r`i'tcog_z_sd=sd(r1tcog_z)
 gen r`i'tcog_z_z=(r`i'tcog_z-r`i'tcog_z_mean)/r`i'tcog_z_sd
}

*****认知的z标准化
*r1z_memory r2z_memory r3z_memory r4z_memory r5z_memory
*r1z_orient r2z_orient r3z_orient r4z_orient r5z_orient
*r1z_executive r2z_executive r3z_executive r4z_executive r5z_executive
*r1z_cog29 r2z_cog29 r3z_cog29 r4z_cog29 r5z_cog29
forvalues i=1/5 {
  zscore r`i'tr20 
  zscore r`i'orient
  zscore r`i'ser7
  egen r`i'cog29=rowtotal(r`i'tr20 r`i'orient r`i'ser7),mi
  zscore r`i'cog29
  drop r`i'cog29
  rename (z_r`i'tr20 z_r`i'orient z_r`i'ser7 z_r`i'cog29) (r`i'z_tr20 r`i'z_orient r`i'z_ser7 r`i'z_cog29)
}

*****爱好
forvalues i=1/5 {
  gen r`i'hobby=.
  replace r`i'hobby=1 if r`i'act_2==1 | r`i'act_4==1 | r`i'act_5==1 | r`i'act_6==1 | r`i'act_7==1
  replace r`i'hobby=0 if r`i'act_2==0 & r`i'act_4==0 & r`i'act_5==0 & r`i'act_6==0 & r`i'act_7==0
}


*****保留所需的变量
keep ID householdID communityID  ///
inw1 inw2 inw3 inw4 inw5 city province ///
da009_1_1_ da009_1_2_ da009_1_3_ da009_1_4_ da009_1_5_ da009_1_6_ da009_1_7_ ///
da009_1_8_ da009_1_9_ da009_1_10_ da009_1_11_ da009_1_12_ da009_1_13_ da009_1_14_  ///
h1atotfa h2atotfa h3atotfa h4atotfa ///
h1child h2child h3child h4child h5child ///
h1coresd h2coresd h3coresd h4coresd h5coresd ///
h1dau h2dau h3dau h4dau h5dau ///
h1fcamt h2fcamt h3fcamt h4fcamt h5fcamt ///
h1fcany h2fcany h3fcany h4fcany h5fcany ///
h1fpamt h2fpamt h3fpamt h4fpamt ///
h1fpany h2fpany h3fpany h4fpany ///
h1gkcare h2gkcare h3gkcare h4gkcare ///
h1hhres h2hhres h3hhres h4hhres h5hhres ///
h1kcnt h2kcnt h3kcnt h4kcnt h5kcnt ///
h1kcntf h2kcntf h3kcntf h4kcntf h5kcntf ///
h1kcntpm h2kcntpm h3kcntpm h4kcntpm h5kcntpm ///
h1lvnear h2lvnear h3lvnear h4lvnear ///
h1pcnt h2pcnt h3pcnt h4pcnt ///
h1rural h2rural h3rural h4rural h5rural ///
h1son h2son h3son h4son h5son ///
h1tcamt h2tcamt h3tcamt h4tcamt h5tcamt ///
h1tcany h2tcany h3tcany h4tcany h5tcany ///
h1tpamt h2tpamt h3tpamt h4tpamt ///
h1tpany h2tpany h3tpany h4tpany ///
hh1cperc hh2cperc hh3cperc hh4cperc hh5cperc ///
hh1ctot hh2ctot hh3ctot hh4ctot hh5ctot  ///
hh1itot hh2itot hh3itot hh4itot hh5itot ///
nation  ///
r1adlab_c r2adlab_c r3adlab_c r4adlab_c r5adlab_c   ///
r1age r2age r3age r4age r5age ///
r1armsa r2armsa r3armsa r4armsa ///
r1arthre r2arthre r3arthre r4arthre r5arthre ///
r1asthmae r2asthmae r3asthmae r4asthmae r5asthmae ///
r1batha r2batha r3batha r4batha r5batha ///
r1beda r2beda r3beda r4beda r5beda ///
r1botherl r2botherl r3botherl r4botherl r5botherl ///
r1bpact30 r2bpact30 r3bpact30  ///
r1bpcomp r2bpcomp r3bpcomp  ///
r1cancre r2cancre r3cancre r4cancre r5cancre ///
r1cesd10 r2cesd10 r3cesd10 r4cesd10 r5cesd10 ///
r1chaira r2chaira r3chaira r4chaira  ///
r1chr5bmv r2chr5bmv r3chr5bmv  ///
r1chr5comp r2chr5comp r3chr5comp  ///
r1chr5num r2chr5num r3chr5num  ///
r1chr5sec r2chr5sec r3chr5sec  ///
r1chronic_num r2chronic_num r3chronic_num r4chronic_num r5chronic_num ///
r1circs r3circs ///
r1climsa r2climsa r3climsa r4climsa  ///
r1cncrchem r2cncrchem r3cncrchem r4cncrchem  ///
r1cncrmeds r2cncrmeds r3cncrmeds r4cncrmeds  ///
r1cncrmeds_c r2cncrmeds_c r3cncrmeds_c r4cncrmeds_c  ///
r1cncrradn r2cncrradn r3cncrradn r4cncrradn ///
r1cncrsurg r2cncrsurg r3cncrsurg r4cncrsurg ///
r1depresl r2depresl r3depresl r4depresl r5depresl ///
r1diabe r2diabe r3diabe r4diabe r5diabe ///
r1diasto r2diasto r3diasto  ///
r1diasto1 r2diasto1 r3diasto1  ///
r1diasto2 r2diasto2 r3diasto2  ///
r1diasto3 r2diasto3 r3diasto3 ///
r1digeste r2digeste r3digeste r4digeste r5digeste ///
r1dimea r2dimea r3dimea r4dimea ///
r1disability r2disability r3disability r4disability  ///
r1dlrc r2dlrc r3dlrc r4dlrc r5dlrc ///
r1doctim1m r2doctim1m r3doctim1m r4doctim1m r5doctim1m ///
r1doctor1m r2doctor1m r3doctor1m r4doctor1m r5doctor1m  ///
r1draw r2draw r3draw r4draw r5draw ///
r1dressa r2dressa r3dressa r4dressa r5dressa ///
r1drinkev r2drinkev r3drinkev r4drinkev r4drinkev  ///
r1drinkl r2drinkl r3drinkl r4drinkl r4drinkl r5drinkl ///
r1ds r2ds r3ds r4ds r5ds ///
r1dw r2dw r3dw r4dw r5dw ///
r1dy r2dy r3dy r4dy r5dy ///
r1dyslipe r2dyslipe r3dyslipe r4dyslipe r5dyslipe ///
r1eata r2eata r3eata r4eata r5eata ///
r1effortl r2effortl r3effortl r4effortl r5effortl ///
r1executive r2executive r3executive r4executive r5executive ///
r1fall_down r2fall_down r3fall_down r4fall_down r5fall_down ///
r1fearll r2fearll r3fearll r4fearll r5fearll ///
r1fhopel r2fhopel r3fhopel r4fhopel r5fhopel ///
r1flonel r2flonel r3flonel r4flonel r5flonel ///
r1frailtya r2frailtya r3frailtya r4frailtya ///
r1fret_c r2fret_c r3fret_c r4fret_c r5fret_c  ///
r1fullcomp r2fullcomp r3fullcomp  ///
r1fulldone r2fulldone r3fulldone  ///
r1fulltan r2fulltan r3fulltan  ///
r1fulltanc r2fulltanc r3fulltanc  ///
r1goingl r2goingl r3goingl r4goingl r5goingl ///
r1gripcomp r2gripcomp r3gripcomp  ///
r1gripsum r2gripsum r3gripsum  ///
r1hearte r2hearte r3hearte r4hearte r5hearte ///
r1hibpe r2hibpe r3hibpe r4hibpe r5hibpe ///
r1hip r2hip r3hip r4hip r5hip ///
r1hosp1y r2hosp1y r3hosp1y r4hosp1y r5hosp1y ///
r1housewka r2housewka r3housewka r4housewka r5housewka ///
r1hspnite r2hspnite r3hspnite r4hspnite  ///
r1hsptim1y r2hsptim1y r3hsptim1y r4hsptim1y  r5hsptim1y  ///
r1htcomp r2htcomp r3htcomp  ///
r1hukou r2hukou r3hukou r4hukou r5hukou ///
r1iadl r2iadl r3iadl r4iadl r5iadl ///
r1imrc r2imrc r3imrc r4imrc r5imrc  ///
r1ins r2ins r3ins r4ins r5ins ///
r1iwm r2iwm r3iwm r4iwm r5iwm ///
r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat ///
r1iwy r2iwy r3iwy r4iwy r5iwy ///
r1joga r2joga r3joga r4joga ///
r1kidneye r2kidneye r3kidneye r4kidneye r5kidneye ///
r1lgrip r2lgrip r3lgrip  ///
r1lgrip1 r2lgrip1 r3lgrip1  ///
r1lgrip2 r2lgrip2 r3lgrip2  ///
r1lifta r2lifta r3lifta r4lifta  ///
r1livere r2livere r3livere r4livere r5livere ///
r1ltact_c r2ltact_c r3ltact_c r4ltact_c r5ltact_c  ///
r1ltactx_c r2ltactx_c r3ltactx_c r4ltactx_c r5ltactx_c  ///
r1lunge r2lunge r3lunge r4lunge r5lunge ///
r1mbmi r2mbmi r3mbmi  ///
r1mbmicata r2mbmicata r3mbmicata ///
r1mdact_c r2mdact_c r3mdact_c r4mdact_c r5mdact_c  ///
r1mdactx_c r2mdactx_c r3mdactx_c r4mdactx_c r5mdactx_c  ///
r1mealsa r2mealsa r3mealsa r4mealsa r5mealsa ///
r1medsa r2medsa r3medsa r4medsa r5medsa ///
r1memrye r2memrye r3memrye r4memrye r5memrye ///
r1mets r3mets ///
r1mheight r2mheight r3mheight /// 
r1mindtsl r2mindtsl r3mindtsl r4mindtsl r5mindtsl /// 
r1mo r2mo r3mo r4mo r5mo  /// 
r1moneya r2moneya r3moneya r4moneya r5moneya  /// 
r1mstath r2mstath r3mstath r4mstath r5mstath  /// 
r1mwaist r2mwaist r3mwaist  /// 
r1mweight r2mweight r3mweight /// 
r1oopdoc1m r2oopdoc1m r3oopdoc1m r4oopdoc1m  /// 
r1oophos1y r2oophos1y r3oophos1y r4oophos1y /// 
r1orient r2orient r3orient r4orient r5orient /// 
r1pension r2pension r3pension r4pension r4pension r5pension /// 
r1phy_acta r2phy_acta r3phy_acta r4phy_acta r5phy_acta ///
r1phy_actb r2phy_actb r3phy_actb r4phy_actb r5phy_actb ///
r1psyche r2psyche r3psyche r4psyche r5psyche ///
r1puff r2puff r3puff  ///
r1puff1 r2puff1 r3puff1  ///
r1puff2 r2puff2 r3puff2 /// 
r1puff3 r2puff3 r3puff3 /// 
r1puffcomp r2puffcomp r3puffcomp  ///
r1pulse r2pulse r3pulse  ///
r1pulse1 r2pulse1 r3pulse1 ///
r1pulse2 r2pulse2 r3pulse2  ///
r1pulse3 r2pulse3 r3pulse3  ///
r1recall r2recall r3recall r4recall r5recall ///
r1retmon r2retmon r3retmon r4retmon r5retmon ///
r1retyr r2retyr r3retyr r4retyr r5retyr /// 
r1rgrip r2rgrip r3rgrip  ///
r1rgrip1 r2rgrip1 r3rgrip1  ///
r1rgrip2 r2rgrip2 r3rgrip2  ///
r1rural2 r2rural2 r3rural2 r4rural2 r5rural2 ///
r1rxarthr r2rxarthr r3rxarthr r4rxarthr /// 
r1rxarthr_c r2rxarthr_c r3rxarthr_c r4rxarthr_c  ///
r1rxdiab r2rxdiab r3rxdiab r4rxdiab  ///
r1rxdiab_c r2rxdiab_c r3rxdiab_c r4rxdiab_c /// 
r1rxdiabi r2rxdiabi r3rxdiabi r4rxdiabi  ///
r1rxdigest r2rxdigest r3rxdigest r4rxdigest  ///
r1rxdigest_c r2rxdigest_c r3rxdigest_c r4rxdigest_c ///
r1rxdyslip r2rxdyslip r3rxdyslip r4rxdyslip  ///
r1rxdyslip_c r2rxdyslip_c r3rxdyslip_c r4rxdyslip_c  ///
r1rxheart r2rxheart r3rxheart r4rxheart  ///
r1rxheart_c r2rxheart_c r3rxheart_c r4rxheart_c  ///
r1rxhibp r2rxhibp r3rxhibp r4rxhibp ///
r1rxhibp_c r2rxhibp_c r3rxhibp_c r4rxhibp_c /// 
r1rxkidney r2rxkidney r3rxkidney r4rxkidney  ///
r1rxkidney_c r2rxkidney_c r3rxkidney_c r4rxkidney_c  ///
r1rxliver r2rxliver r3rxliver r4rxliver  ///
r1rxliver_c r2rxliver_c r3rxliver_c r4rxliver_c  ///
r1rxlung r2rxlung r3rxlung r4rxlung  ///
r1rxlung_c r2rxlung_c r3rxlung_c r4rxlung_c  ///
r1rxmemry r2rxmemry r3rxmemry r4rxmemry  ///
r1rxmemry_c r2rxmemry_c r3rxmemry_c r4rxmemry_c  ///
r1rxpsych r2rxpsych r3rxpsych r4rxpsych  ///
r1rxstrok r2rxstrok r3rxstrok r4rxstrok  ///
r1rxstrok_c r2rxstrok_c r3rxstrok_c r4rxstrok_c  ///
r1satlife r2satlife r3satlife r4satlife r5satlife ///
r1satlifez r2satlifez r3satlifez r4satlifez r5satlifez ///
r1sbscomp r2sbscomp r3sbscomp  ///
r1sbsdone r2sbsdone r3sbsdone  ///
r1sbstan r2sbstan r3sbstan  ///
r1sbstanc r2sbstanc r3sbstanc /// 
r1semicomp r2semicomp r3semicomp  ///
r1semidone r2semidone r3semidone  ///
r1semitan r2semitan r3semitan  ///
r1semitanc r2semitanc r3semitanc  ///
r1ser7 r2ser7 r3ser7 r4ser7 r5ser7  ///
r1shlta r2shlta r3shlta r4shlta r5shlta ///
r1shopa r2shopa r3shopa r4shopa r5shopa ///
r1sleeprl r2sleeprl r3sleeprl r4sleeprl r5sleeprl ///
r1slfmem r2slfmem r3slfmem r4slfmem r5slfmem ///
r1smokef r2smokef r3smokef r4smokef r5smokef ///
r1smoken r2smoken r3smoken r4smoken r5smoken ///
r1smokev r2smokev r3smokev r4smokev r5smokev ///
r1socwk r2socwk r3socwk r4socwk r5socwk ///
r1stoopa r2stoopa r3stoopa r4stoopa  ///
r1stroke r2stroke r3stroke r5stroke ///
r1systo r2systo r3systo  ///
r1systo1 r2systo1 r3systo1  ///
r1systo2 r2systo2 r3systo2  ///
r1systo3 r2systo3 r3systo3  ///
r1toilta r2toilta r3toilta r4toilta r5toilta ///
r1total_cognition r2total_cognition r3total_cognition r4total_cognition r5total_cognition ///
r1totdoc1m r2totdoc1m r3totdoc1m r4totdoc1m  ///
r1tothos1y r2tothos1y r3tothos1y r4tothos1y ///
r1totmet r2totmet r3totmet r4totmet r5totmet ///
r1tr20 r2tr20 r3tr20 r4tr20 r5tr20  ///
r1trdmdtim1m r2trdmdtim1m r3trdmdtim1m r4trdmdtim1m  ///
r1trdmed1m r2trdmed1m r3trdmed1m r4trdmed1m  ///
r1trpsych r2trpsych r3trpsych r4trpsych  ///
r1tyg r3tyg  ///
r1tyg_bmi r3tyg_bmi ///
r1urina r2urina r3urina r4urina r5urina ///
r1vgact_c r2vgact_c r3vgact_c r4vgact_c r5vgact_c  ///
r1vgactx_c r2vgactx_c r3vgactx_c r4vgactx_c r5vgactx_c  ///
r1walk100a r2walk100a r3walk100a r4walk100a ///
r1walk1kma r2walk1kma r3walk1kma r4walk1kma ///
r1walkcomp r2walkcomp r3walkcomp  ///
r1watcomp r2watcomp r3watcomp  ///
r1whappyl r2whappyl r3whappyl r4whappyl r5whappyl ///
r1work r2work r3work r4work r5work  ///
r1wspeed r2wspeed r3wspeed  ///
r1wspeed1 r2wspeed1 r3wspeed1  ///
r1wspeed2 r2wspeed2 r3wspeed2  ///
r1wtcomp r2wtcomp r3wtcomp  ///
r1yr r2yr r3yr r4yr r5yr ///
r2dentim1y r3dentim1y  ///
r2dentst1y r3dentst1y /// 
r2oopden1y r3oopden1y ///
r2totden1y r3totden1y ///
r2phonea r3phonea r4phonea r5phonea  ///
r2totden1y r3totden1y ///
rabmonth ///
rabyear ///
radaddrug ///
radadoccup_c ///
radmonth ///
radyear  ///
raeduc_c raeducl ///
rafinacom ///
ragender ///
rahltcom ///
ramischlth ///
ramomdrug ///
ramomoccup_c ///
rapadrug ///
region ///
r1bloodweight r1bl_fasting r1bl_wbc r1bl_mcv r1bl_plt ///
r1bl_bun r1bl_glu r1bl_crea r1bl_cho r1bl_tg r1bl_hdl r1bl_ldl r1bl_crp ///
r1bl_hbalc r1bl_ua r1bl_hct r1bl_hgb r1bl_cysc ///
r3bloodweight r3bl_fasting r3bl_wbc r3bl_mcv r3bl_plt ///
r3bl_bun r3bl_glu r3bl_crea r3bl_cho r3bl_tg r3bl_hdl r3bl_ldl r3bl_crp ///
r3bl_hbalc r3bl_ua r3bl_hct r3bl_hgb r3bl_cysc r3bl_top_coding_tg ///
r1act_1 r1act_2 r1act_3 r1act_4 r1act_5 r1act_6 r1act_7 r1act_8 r1freq_act_1 /// 
r1freq_act_2 r1freq_act_3 r1freq_act_4 r1freq_act_5 r1freq_act_6 r1freq_act_7 ///
r1freq_act_8 r1social1 r1social2 r1social3 r1social4 r1social5 r1social6 r1social7 ///
r1social8 r1social9 r1social10 r1social11 r1freq_social1 r1freq_social2 /// 
r1freq_social3 r1freq_social4 r1freq_social5 r1freq_social6 r1freq_social7 /// 
r1freq_social8 r1freq_social9 r1freq_social10 r1freq_social11 ///
r2act_1 r2act_2 r2act_3 r2act_4 r2act_5 r2act_6 r2act_7 r2act_8 ///  
r2freq_act_1 r2freq_act_2 r2freq_act_3 r2freq_act_4 r2freq_act_5 r2freq_act_6 ///
r2freq_act_7 r2freq_act_8 r2freq_social1 r2freq_social2 r2freq_social3  ///
r2freq_social4 r2freq_social5 r2freq_social6 r2freq_social7 r2freq_social8 /// 
r2freq_social9 r2freq_social10 r2freq_social11 ///
r3act_1 r3act_2 r3act_3 r3act_4 r3act_5 r3act_6 ///
r3act_7 r3act_8  r3freq_act_1 r3freq_act_2 r3freq_act_3 r3freq_act_4 r3freq_act_5 ///
r3freq_act_6 r3freq_act_7 r3freq_act_8 r3social1 r3social2 r3social3 r3social4 ///
r3social5 r3social6 r3social7 r3social8 r3social9 r3social10 r3social11 ///
r3freq_social1 r3freq_social2 r3freq_social3 r3freq_social4 r3freq_social5 ///
r3freq_social6 r3freq_social7 r3freq_social8 r3freq_social9 r3freq_social10 r3freq_social11 ///
r4act_1 r4act_2 r4act_3 r4act_4 r4act_5 r4act_6 r4act_7 r4act_8 r4freq_act_1 r4freq_act_2 r4freq_act_3 /// 
r4freq_act_4 r4freq_act_5 r4freq_act_6 r4freq_act_7 r4freq_act_8 r4social1 /// 
r4social2 r4social3 r4social4 r4social5 r4social6 r4social7 r4social8 /// 
r4social9 r4social10 r4social11 r4freq_social1 r4freq_social2 r4freq_social3 /// 
r4freq_social4 r4freq_social5 r4freq_social6 r4freq_social7 r4freq_social8 /// 
r4freq_social9 r4freq_social10 r4freq_social11 ///
r5freq_act_1 r5freq_act_2 r5freq_act_3 /// 
r5freq_act_4 r5freq_act_5 r5freq_act_6 r5freq_act_7 r5freq_act_8 ///
r5act_1 r5act_2 r5act_3 r5act_4 r5act_5 r5act_6 r5act_7 r5act_8 ///
r1teeth r2teeth r3teeth r4teeth /// 
r1da042s1 r2da042s1 r3da042s1 r4da042s1 r5da042s1 /// 
r1da042s2 r2da042s2 r3da042s2 r4da042s2 r5da042s2 /// 
r1da042s3 r2da042s3 r3da042s3 r4da042s3 r5da042s3 /// 
r1da042s4 r2da042s4 r3da042s4 r4da042s4 r5da042s4 /// 
r1da042s5 r2da042s5 r3da042s5 r4da042s5 r5da042s5 /// 
r1da042s6 r2da042s6 r3da042s6 r4da042s6 r5da042s6 /// 
r1da042s7 r2da042s7 r3da042s7 r4da042s7 r5da042s7 /// 
r1da042s8 r2da042s8 r3da042s8 r4da042s8 r5da042s8 /// 
r1da042s9 r2da042s9 r3da042s9 r4da042s9 r5da042s9 /// 
r1da042s10 r2da042s10 r3da042s10 r4da042s10 r5da042s10 /// 
r1da042s11 r2da042s11 r3da042s11 r4da042s11 r5da042s11 ///
r1da042s12 r2da042s12 r3da042s12 r4da042s12 r5da042s12 /// 
r1da042s13 r2da042s13 r3da042s13 r4da042s13 r5da042s13 /// 
r1da042s14 r2da042s14 r3da042s14 r4da042s14 r5da042s14 /// 
r1da042s15 r2da042s15 r3da042s15 r4da042s15 r5da042s15 ///
r1act_1 r1act_2 r1act_3 r1act_4 r1act_5 r1act_6 r1act_7 r1act_8 ///
r2act_1 r2act_2 r2act_3 r2act_4 r2act_5 r2act_6 r2act_7 r2act_8 ///
r3act_1 r3act_2 r3act_3 r3act_4 r3act_5 r3act_6 r3act_7 r3act_8 ///
r4act_1 r4act_2 r4act_3 r4act_4 r4act_5 r4act_6 r4act_7 r4act_8 ///
r5act_1 r5act_2 r5act_3 r5act_4 r5act_5 r5act_6 r5act_7 r5act_8 ///
r1glass r2glass r3glass r4glass ///
r1eyesight_distance r2eyesight_distance r3eyesight_distance r4eyesight_distance /// 
r1eyesight_close r2eyesight_close r3eyesight_close r4eyesight_close /// 
r1hear_aid r2hear_aid r3hear_aid r4hear_aid /// 
r1hear r2hear r3hear r4hear /// 
r3sati_child r4sati_child r5sati_child ///
r1sleep_night r1sleep_nap r2sleep_night r2sleep_nap ///
r3sleep_night r3sleep_nap r4sleep_night r4sleep_nap r5sleep_night r5sleep_nap ///
r1da017s1 r1da017s2 r1da017s3 r1da017s4 r1da017s5 r1da017s6 r1da017s7 r1da017s8 /// 
r1da017s9 r1da017s10 r1da017s11 r1da017s12 r1da017s13 r1da017s14 r1da017s15 /// 
r1da017s16 r1da017s17 r1da017s18 r1da017s19 r1da017s20 r1da017s21 r1da017s22 /// 
r1da017s23 r2da017s1 r2da017s2 r2da017s3 r2da017s4 r2da017s5 r2da017s6 r2da017s7 /// 
r2da017s8 r2da017s9 r2da017s10 r2da017s11 r2da017s12 r2da017s13 r2da017s14 r2da017s15 /// 
r2da017s16 r2da017s17 r2da017s18 r2da017s19 r2da017s20 r2da017s21 r2da017s22 r2da017s23 ///
r3da017s1 r3da017s2 r3da017s3 r3da017s4 r3da017s5 r3da017s6 r3da017s7 r3da017s8 /// 
r3da017s9 r3da017s10 r3da017s11 r3da017s12 r3da017s13 r3da017s14 r3da017s15 /// 
r3da017s16 r3da017s17 r3da017s18 r3da017s19 r3da017s20 r3da017s21 r3da017s22 /// 
r3da017s23 r4da017s1 r4da017s2 r4da017s3 r4da017s4 r4da017s5 r4da017s6 r4da017s7 /// 
r4da017s8 r4da017s9 r4da017s10 r4da017s11 r4da017s12 r4da017s13 r4da017s14 ///
r4da017s15 r4da017s16 r4da017s17 r4da017s18 r4da017s19 r4da017s20 r4da017s21 ///
r4da017s22 r4da017s23 ///
r5ea001s1 r5ea001s2 r5ea001s3 r5ea001s4 r5ea001s5 r5ea001s11 /// 
r4ea001s1 r4ea001s2 r4ea001s3 r4ea001s4 r4ea001s5 r4ea001s6 r4ea001s7 r4ea001s8 r4ea001s9 r4ea001s10 r4ea001s11 ///
r3ea001s1 r3ea001s2 r3ea001s3 r3ea001s4 r3ea001s5 r3ea001s6 r3ea001s7 r3ea001s8 r3ea001s9 r3ea001s11  ///
r2ea001s1 r2ea001s3 r2ea001s4 r2ea001s2 r2ea001s5 r2ea001s6 r2ea001s7 r2ea001s8 r2ea001s9 r2ea001s11  ///
r1ea001s1 r1ea001s2 r1ea001s3 r1ea001s4 r1ea001s5 r1ea001s6 r1ea001s7 r1ea001s8 r1ea001s11 ///
r1hibpe_self r1lunge_self r1psyche_self /// 
r2hibpe_self r2lunge_self r2psyche_self /// 
r3hibpe_self r3lunge_self r3psyche_self /// 
r4hibpe_self r4lunge_self r4psyche_self /// 
r5hibpe_self r5lunge_self r5psyche_self /// 
r5parkinson ///
r1sisa r2sisa r3sisa r4sisa r5sisa ///
r1sisb r2sisb r3sisb r4sisb r5sisb ///
r1dependency r2dependency r3dependency r4dependency r5dependency ///
r1clean_heat r1clean_cook r2clean_heat r2clean_cook r3clean_heat r3clean_cook ///
r4clean_heat r4clean_cook r5clean_heat r5clean_cook ///
r1build r1toilet r1electricity r1water r1room ///
r2build r2toilet r2electricity r2water r2room ///
r3build r3toilet r3water r3room ///
r4build r4toilet r4electricity r4water r4room ///
r5build r5toilet r5electricity r5water r5room ///
r1frailtyb r2frailtyb r3frailtyb r4frailtyb ///
r1memory_z r2memory_z r3memory_z r4memory_z r5memory_z /// 
r1orient_z r2orient_z r3orient_z r4orient_z r5orient_z /// 
r1executive_z r2executive_z r3executive_z r4executive_z r5executive_z ///
r1tcog_z_z r2tcog_z_z r3tcog_z_z r4tcog_z_z r5tcog_z_z ///
r1hobby r2hobby r3hobby r4hobby r5hobby ///
r1z_tr20 r1z_orient r1z_ser7 r1z_cog29 ///  
r2z_tr20 r2z_orient r2z_ser7 r2z_cog29 ///  
r3z_tr20 r3z_orient r3z_ser7 r3z_cog29 ///  
r4z_tr20 r4z_orient r4z_ser7 r4z_cog29 /// 
r5z_tr20 r5z_orient r5z_ser7 r5z_cog29 ///
 
*****将其转化为面板数据  
reshape long inw@  h@atotfa h@child h@coresd h@dau h@fcamt h@fcany h@fpamt h@fpany h@gkcare ///
h@hhres h@kcnt h@kcntf h@kcntpm h@lvnear h@pcnt h@rural h@son h@tcamt h@tcany ///
h@tpamt h@tpany hh@cperc hh@ctot hh@itot r@adlab_c r@age r@armsa r@arthre ///
r@asthmae r@batha r@beda r@botherl r@bpact30 r@bpcomp r@cancre r@cesd10 r@chaira ///
r@chr5bmv r@chr5comp r@chr5num r@chr5sec r@chronic_num r@circs r@climsa ///
r@cncrchem r@cncrmeds r@cncrmeds_c r@cncrradn r@cncrsurg r@depresl r@diabe ///
r@diasto r@diasto1 r@diasto2 r@diasto3 r@digeste r@dimea r@disability r@dlrc ///
r@doctim1m r@doctor1m r@draw r@dressa r@drinkev r@drinkl r@ds r@dw r@dy ///
r@dyslipe r@eata r@effortl r@executive r@fall_down r@fearll r@fhopel r@flonel ///
r@frailtya r@fret_c r@fullcomp r@fulldone r@fulltan r@fulltanc r@goingl ///
r@gripcomp r@gripsum r@hearte r@hibpe r@hip r@hosp1y r@housewka r@hspnite ///
r@hsptim1y r@htcomp r@hukou r@iadl r@imrc r@ins r@iwm r@iwstat r@iwy r@joga ///
r@kidneye r@lgrip r@lgrip1 r@lgrip2 r@lifta r@livere r@ltact_c r@ltactx_c ///
r@lunge r@mbmi r@mbmicata r@mdact_c r@mdactx_c r@mealsa r@medsa r@memrye ///
r@mets r@mheight r@mindtsl r@mo r@moneya r@mstath r@mwaist r@mweight ///
r@oopdoc1m r@oophos1y r@orient r@pension r@phy_acta r@phy_actb r@psyche r@puff r@puff1 ///
r@puff2 r@puff3 r@puffcomp r@pulse r@pulse1 r@pulse2 r@pulse3 r@recall r@retmon ///
r@retyr r@rgrip r@rgrip1 r@rgrip2 r@rural2 r@rxarthr r@rxarthr_c r@rxdiab ///
r@rxdiab_c  r@rxdiabi r@rxdigest r@rxdigest_c r@rxdyslip r@rxdyslip_c ///
r@rxheart r@rxheart_c r@rxhibp r@rxhibp_c r@rxkidney r@rxkidney_c r@rxliver ///
r@rxliver_c r@rxlung r@rxlung_c r@rxmemry r@rxmemry_c r@rxpsych r@rxstrok ///
r@rxstrok_c r@satlife r@satlifez r@sbscomp r@sbsdone r@sbstan r@sbstanc ///
r@semicomp r@semidone r@semitan r@semitanc r@ser7 r@shlta r@shopa r@sleeprl ///
r@slfmem r@smokef r@smoken r@smokev r@socwk r@stoopa r@stroke r@systo r@systo1 ///
r@systo2 r@systo3 r@toilta r@total_cognition r@totdoc1m r@tothos1y r@totmet /// 
r@tr20 r@trdmdtim1m r@trdmed1m r@trpsych r@tyg r@tyg_bmi r@urina r@vgact_c ///
r@vgactx_c r@walk100a r@walk1kma r@walkcomp r@watcomp r@whappyl r@work r@wspeed ///
r@wspeed1 r@wspeed2 r@wtcomp r@yr r@dentim1y r@dentst1y r@oopden1y /// 
r@phonea r@totden1y r@bloodweight r@bl_fasting r@bl_wbc r@bl_mcv r@bl_plt ///
r@bl_bun r@bl_glu r@bl_crea r@bl_cho r@bl_tg r@bl_hdl r@bl_ldl r@bl_crp ///
r@bl_hbalc r@bl_ua r@bl_hct r@bl_hgb r@bl_cysc r@bl_top_coding_tg r@teeth ///
r@da042s1 r@da042s2 r@da042s3 r@da042s4 r@da042s5  r@da042s6 r@da042s7 r@da042s8 r@da042s9 ///
r@da042s10 r@da042s11 r@da042s12 r@da042s13 r@da042s14 r@da042s15 r@glass ///
r@eyesight_distance r@eyesight_close r@hear_aid r@hear r@sati_child r@sleep_night /// 
r@sleep_nap r@da017s1 r@da017s2 r@da017s3 r@da017s4 r@da017s5 r@da017s6 r@da017s7 /// 
r@da017s8 r@da017s9 r@da017s10 r@da017s11 r@da017s12 r@da017s13 r@da017s14 ///
r@da017s15 r@da017s16 r@da017s17 r@da017s18 r@da017s19 r@da017s20 ///
r@da017s21 r@da017s22 r@da017s23 r@hibpe_self r@lunge_self r@psyche_self ///
r@ea001s1 r@ea001s2 r@ea001s3 r@ea001s4 r@ea001s5 r@ea001s6 r@ea001s7 r@ea001s8 ///
r@ea001s9 r@ea001s10 r@ea001s11 r@parkinson r@act_1 r@act_2 r@act_3 r@act_4 /// 
r@act_5 r@act_6 r@act_7 r@act_8 r@freq_act_1 r@freq_act_2 r@freq_act_3  ///
r@freq_act_4 r@freq_act_5 r@freq_act_6 r@freq_act_7 r@freq_act_8 r@social1 /// 
r@social2 r@social3 r@social4 r@social5 r@social6 r@social7 r@social8 r@social9  ///
r@social10 r@social11 r@freq_social1 r@freq_social2 r@freq_social3 r@freq_social4 /// 
r@freq_social5 r@freq_social6 r@freq_social7 r@freq_social8 r@freq_social9 /// 
r@freq_social10 r@freq_social11 r@sisa r@sisb r@dependency r@clean_heat ///
r@clean_cook r@build r@toilet r@electricity r@water r@room r@frailtyb r@memory_z ///
r@orient_z r@executive_z r@tcog_z_z r@hobby r@z_tr20 r@z_orient r@z_ser7 r@z_cog29,i(ID) j(wave)
				
				
*****重新命名变量				
rename (ID wave householdID communityID rabmonth rabyear radyear radmonth ///
ragender ramomoccup_c radadoccup_c ramomdrug radaddrug rapadrug rahltcom ///
ramischlth rafinacom nation rhibpe rdyslipe rdiabe rcancre rlunge rlivere ///
rhearte rstroke rkidneye rdigeste rpsyche rmemrye rarthre rasthmae rdoctim1m ///
rhsptim1y rda042s1 rda042s2 rda042s3 rda042s4 rda042s5 rda042s6 rda042s7 ///
rda042s8 rda042s9 rda042s10 rda042s11 rda042s12 rda042s13 rda042s14 rda042s15 ///
rsleep_night rsleep_nap rvgactx_c rmdactx_c rltactx_c rdressa rbatha reata rbeda rtoilta rurina ///
rhousewka rmealsa rshopa rphonea rmedsa rmoneya rwork rfret_c riwy riwm inw ///
hrural rmstath rhukou rshlta radlab_c riadl rvgact_c rmdact_c rltact_c rdrinkl ///
rsmokev rsmoken rsmokef rdoctor1m rhosp1y rpension rins rslfmem rimrc rdlrc ///
rtr20 rrecall rmo rdy ryr rdw rds rorient rdraw rser7 rexecutive rtotal_cognition ///
rsocwk hhhres hson hdau hchild hcoresd hkcntf hkcntpm hkcnt hhctot hhcperc hfcamt ///
hfcany htcamt htcany hhitot rdepresl reffortl rsleeprl rwhappyl rflonel rbotherl ///
rgoingl rmindtsl rfhopel rfearll rcesd10 rretmon rretyr rfall_down rhip ///
rsati_child rsatlife rsatlifez province city riwstat rage raeduc_c raeducl ///
rrural2 rphy_acta rphy_actb rtotmet rchronic_num da009_1_1_ da009_1_2_ da009_1_3_ ///
da009_1_4_ da009_1_5_ da009_1_6_ da009_1_7_ da009_1_8_ da009_1_9_ da009_1_10_ /// 
da009_1_11_ da009_1_12_ da009_1_13_ da009_1_14_ region hatotfa hfpamt hfpany ///
hgkcare hlvnear hpcnt htpamt htpany rarmsa rbpact30 rbpcomp rchaira rchr5bmv ///
rchr5comp rchr5num rchr5sec rcircs rclimsa rcncrchem rcncrmeds rcncrmeds_c ///
rcncrradn rcncrsurg rdiasto rdiasto1 rdiasto2 rdiasto3 rdimea rdisability ///
rdrinkev rfrailtya rfullcomp rfulldone rfulltan rfulltanc rgripcomp ///
rgripsum rhspnite rhtcomp rjoga rlgrip rlgrip1 rlgrip2 rlifta rmbmi rmbmicata ///
rmets rmheight rmwaist rmweight roopdoc1m roophos1y rpuff rpuff1 rpuff2 rpuff3 ///
rpuffcomp rpulse rpulse1 rpulse2 rpulse3 rrgrip rrgrip1 rrgrip2 rrxarthr ///
rrxarthr_c rrxdiab rrxdiab_c rrxdiabi rrxdigest rrxdigest_c rrxdyslip rrxdyslip_c ///
rrxheart rrxheart_c rrxhibp rrxhibp_c rrxkidney rrxkidney_c rrxliver rrxliver_c ///
rrxlung rrxlung_c rrxmemry rrxmemry_c rrxpsych rrxstrok rrxstrok_c rsbscomp ///
rsbsdone rsbstanc rsemicomp rsemidone rsemitan rsemitanc rstoopa rsysto rsysto1 ///
rsysto2 rsysto3 rtotdoc1m rtothos1y rtrdmdtim1m rtrdmed1m rtrpsych rtyg rtyg_bmi ///
rwalk100a rwalk1kma rwalkcomp rwatcomp rwspeed rwspeed1 rwspeed2 rwtcomp rdentim1y /// 
rdentst1y roopden1y rtotden1y rbloodweight rbl_fasting rbl_wbc rbl_mcv rbl_plt ///
rbl_bun rbl_glu rbl_crea rbl_cho rbl_tg rbl_hdl rbl_ldl rbl_crp rbl_hbalc rbl_ua ///
rbl_hct rbl_hgb rbl_cysc rbl_top_coding_tg rteeth rglass ///
reyesight_distance reyesight_close rhear_aid rhear rda017s1 rda017s2 rda017s3 /// 
rda017s4 rda017s5 rda017s6 rda017s7 rda017s8 rda017s9 rda017s10 rda017s11 ///
rda017s12 rda017s13 rda017s14 rda017s15 rda017s16 rda017s17 rda017s18 ///
rda017s19 rda017s20 rda017s21 rda017s22 rda017s23 rea001s1 rea001s2 rea001s3 ///
rea001s4 rea001s5 rea001s6 rea001s7 rea001s8 rea001s9 rea001s10 rea001s11 ///
rhibpe_self rlunge_self rpsyche_self rparkinson rsbstan ract_1 ract_2 ract_3 ract_4 /// 
ract_5 ract_6 ract_7 ract_8 rfreq_act_1 rfreq_act_2 rfreq_act_3  ///
rfreq_act_4 rfreq_act_5 rfreq_act_6 rfreq_act_7 rfreq_act_8 rsocial1 /// 
rsocial2 rsocial3 rsocial4 rsocial5 rsocial6 rsocial7 rsocial8 rsocial9  ///
rsocial10 rsocial11 rfreq_social1 rfreq_social2 rfreq_social3 rfreq_social4 /// 
rfreq_social5 rfreq_social6 rfreq_social7 rfreq_social8 rfreq_social9 /// 
rfreq_social10 rfreq_social11 rsisa rsisb rdependency rclean_heat rclean_cook ///
rbuild rtoilet relectricity rwater rroom rfrailtyb rmemory_z rorient_z rexecutive_z ///
rtcog_z_z rhobby rz_tr20 rz_orient rz_ser7 rz_cog29) ///
(ID wave householdID communityID rabmonth rabyear radyear radmonth ///
ragender ramomoccup_c radadoccup_c ramomdrug radaddrug rapadrug rahltcom ///
ramischlth rafinacom nation hibpe dyslipe diabe cancre lunge livere ///
hearte stroke kidneye digeste psyche memrye arthre asthmae doctor_time ///
hospital_time da042s1 da042s2 da042s3 da042s4 da042s5 da042s6 da042s7 ///
da042s8 da042s9 da042s10 da042s11 da042s12 da042s13 da042s14 da042s15 ///
sleep_night sleep_nap vgactx_c mdactx_c ltactx_c dressa batha eata beda toilta urina ///
housewka mealsa shopa phonea medsa moneya work retire iwy iwm inw ///
hrural marry hukou srh adlab_c iadl vgact_c mdact_c ltact_c drinkl ///
smokev smoken smokef doctor hospital pension ins slfmem imrc dlrc ///
tr20 recall mo dy yr dw ds orient draw ser7 executive total_cognition ///
socwk family_size hson hdau hchild hcoresd kcntf kcntpm kcnt hctot hhcperc /// 
fcamt fcany tcamt tcany income_total depresl effortl sleeprl whappyl /// 
flonel botherl goingl mindtsl fhopel fearll cesd10 retmon retyr fall_down hip ///
sati_child satlife satlifez province city iwstat age raeduc_c raeducl ///
rural2 phy_acta phy_actb totmet chronic_num da009_1_1_ da009_1_2_ da009_1_3_ ///
da009_1_4_ da009_1_5_ da009_1_6_ da009_1_7_ da009_1_8_ da009_1_9_ da009_1_10_ ///
da009_1_11_ da009_1_12_ da009_1_13_ da009_1_14_ region hatotfa hfpamt hfpany ///
hgkcare hlvnear hpcnt htpamt htpany armsa bpact30 bpcomp chaira chr5bmv ///
chr5comp chr5num chr5sec circs climsa cncrchem cncrmeds cncrmeds_c ///
cncrradn cncrsurg diasto diasto1 diasto2 diasto3 dimea disability ///
drinkev frailtya fullcomp fulldone fulltan fulltanc gripcomp ///
gripsum hspnite htcomp joga lgrip lgrip1 lgrip2 lifta bmi bmicata ///
mets mheight mwaist mweight oopdoc1m oophos1y puff puff1 puff2 puff3 ///
puffcomp pulse pulse1 pulse2 pulse3 rgrip rgrip1 rgrip2 rxarthr rxarthr_c ///
rxdiab rxdiab_c rxdiabi rxdigest rxdigest_c rxdyslip rxdyslip_c ///
rxheart rxheart_c rxhibp rxhibp_c rxkidney rxkidney_c rxliver rxliver_c ///
rxlung rxlung_c rxmemry rxmemry_c rxpsych rxstrok rxstrok_c sbscomp ///
sbsdone sbstanc semicomp semidone semitan semitanc stoopa systo systo1 ///
systo2 systo3 totdoc1m tothos1y trdmdtim1m trdmed1m trpsych tyg tyg_bmi ///
walk100a walk1kma walkcomp watcomp wspeed wspeed1 wspeed2 wtcomp dentim1y ///
dentst1y oopden1y totden1y bloodweight bl_fasting bl_wbc bl_mcv bl_plt ///
bl_bun bl_glu bl_crea bl_cho bl_tg bl_hdl bl_ldl bl_crp bl_hbalc bl_ua ///
bl_hct bl_hgb bl_cysc bl_top_coding_tg teeth glass ///
eyesight_distance eyesight_close hear_aid hear da017s1 da017s2 da017s3 ///
da017s4 da017s5 da017s6 da017s7 da017s8 da017s9 da017s10 da017s11 ///
da017s12 da017s13 da017s14 da017s15 da017s16 da017s17 da017s18 ///
da017s19 da017s20 da017s21 da017s22 da017s23 ea001s1 ea001s2 ea001s3 ///
ea001s4 ea001s5 ea001s6 ea001s7 ea001s8 ea001s9 ea001s10 ea001s11 ///
hibpe_self lunge_self psyche_self parkinson sbstan act_1 act_2 act_3 act_4 /// 
act_5 act_6 act_7 act_8 freq_act_1 freq_act_2 freq_act_3  ///
freq_act_4 freq_act_5 freq_act_6 freq_act_7 freq_act_8 social1 /// 
social2 social3 social4 social5 social6 social7 social8 social9  ///
social10 social11 freq_social1 freq_social2 freq_social3 freq_social4 /// 
freq_social5 freq_social6 freq_social7 freq_social8 freq_social9 /// 
freq_social10 freq_social11 sisa sisb dependency clean_heat clean_cook /// 
build toilet electricity water room frailtyb memory_z orient_z executive_z ///
tcog_z_z hobby z_tr20 z_orient z_ser7 z_cog29)				
			
				 
*****只保留参与每一轮调查的样本
keep if inw==1   //只保留参与调查的个体
drop inw
label drop _all  //删除原有标签
  
*****赋予变量标签   
label var act_1 "串门、跟朋友交往" 
label var act_2 "打麻将、下棋、打牌、去社区活动室" 
label var act_3 "无偿向与您不住在一起的亲人、朋友或者邻居提供帮助" 
label var act_4 "去公园或者其他场所跳舞、健身、练气功等" 
label var act_5 "参加社团组织活动" 
label var act_6 "志愿者活动或者慈善活动" 
label var act_7 "上学或者参加培训课程" 
label var act_8 "其他社交"  
label var freq_act_1 "频率/串门、跟朋友交往" 
label var freq_act_2 "频率/打麻将、下棋、打牌、去社区活动室" 
label var freq_act_3 "频率/无偿向与您不住在一起的亲人、朋友或者邻居提供帮助" 
label var freq_act_4 "频率/去公园或者其他场所跳舞、健身、练气功等" 
label var freq_act_5 "频率/参加社团组织活动" 
label var freq_act_6 "频率/志愿者活动或者慈善活动" 
label var freq_act_7 "频率/上学或者参加培训课程" 
label var freq_act_8 "频率/其他社交"
label var social1 "串门、跟朋友交往"
label var social2 "打麻将、下棋、打牌、去社区活动室"
label var social3 "向与您不住在一起的亲人、朋友或者邻居提供帮助"
label var social4 "跳舞、健身、练气功等"
label var social5 "参加社团组织活动"
label var social6 "志愿者活动或者慈善活动"
label var social7 "照顾与您不住在一起的病人或残疾人"
label var social8 "上学或者参加培训课程"
label var social9 "炒股"
label var social10 "上网"
label var social11 "其他社交活动"
label var freq_social1 "频率/串门、跟朋友交往"
label var freq_social2 "频率/打麻将、下棋、打牌、去社区活动室"
label var freq_social3 "频率/向与您不住在一起的亲人、朋友或者邻居提供帮助"
label var freq_social4 "频率/跳舞、健身、练气功等"
label var freq_social5 "频率/参加社团组织活动"
label var freq_social6 "频率/志愿者活动或者慈善活动"
label var freq_social7 "频率/照顾与您不住在一起的病人或残疾人"
label var freq_social8 "频率/上学或者参加培训课程"
label var freq_social9 "频率/炒股"
label var freq_social10 "频率/上网"
label var freq_social11 "频率/其他社交活动"
label var adlab_c "ADL(6项有困难)"
label var age "年龄" 
label var armsa "其他功能限制/手臂超过肩膀" 
label var arthre "关节炎" 
label var asthmae "哮喘病" 
label var batha "ADL/沐浴"  
label var beda "ADL/上下床"  
label var bl_bun "Blood Urea Nitrogen (BUN) (mg/dl)尿素氮"
label var bl_cho "Total Cholesterol (mg/dl)总胆固醇"
label var bl_crea "Creatinine (mg/dl)肌酐"
label var bl_crp "C-Reactive Protein (CRP) C反应蛋白(mg/l)"
label var bl_cysc "Cystatin C胱抑素C(mg/l)"
label var bl_fasting  "是否空腹"
label var bl_glu "Glucose (mg/dl)血糖"
label var bl_hbalc "Glycated Hemoglobin糖化血红蛋白 (%)"
label var bl_hct "Hematocrit红细胞比容(%)"
label var bl_hdl "Hdl Cholesterol高密度脂蛋白胆固醇 (mg/dl)"
label var bl_hgb "Hemoglobin血红蛋白 (g/dl)"
label var bl_ldl "Ldl Cholesterol低密度脂蛋白胆固醇 (mg/dl)"
label var bl_mcv "MCV平均红细胞体积(fl)"
label var bl_plt "Platelets血小板计数(10^9/L)"
label var bl_tg "Triglycerides甘油三酯 (mg/dl)"
label var bl_top_coding_tg  "Whether or not top-coding Triglycerides values to 500"
label var bl_ua "Uric Acid尿酸(mg/dl)"
label var bl_wbc  "White Blood Cell in Thousands白细胞"
label var bmi "BMI"
label var bmicata "身体质量分类"
label var botherl "过去一周因一些小事而烦恼的频率" 
label var bpact30 "完成血压测量前30分钟内是否吸烟、饮酒或进行任何剧烈运动" 
label var bpcomp "是否愿意并能够完成血压测量" 
label var cancre "癌症" 
label var cesd10 "心理健康(30分,越大越差)" 
label var chaira "其他功能限制/长时间坐着从椅子上站起来" 
label var chr5bmv "椅子站立测试中是否躯干或手臂" 
label var chr5comp "是否完成5次站立"
label var chr5num "完成站立的次数"
label var chr5sec "5次站立的时间"
label var chronic "是否有慢性病"
label var chronic_num "慢性病数量"
label var circs "CircS昼夜节律综合症"
label var city "城市" 
label var climsa "其他功能限制/不休息地爬几层楼梯" 
label var cncrchem "过去两年内是否接受过化疗治疗癌症" 
label var cncrmeds "是否服用过西药治疗癌症或缓解症状" 
label var cncrmeds_c "过去两年内服用过任何药物治疗癌症" 
label var cncrradn "过去两年内是否接受过放射治疗癌症" 
label var cncrsurg "过去两年内是否接受过手术治疗癌症" 
label var communityID "社区编码"    
label var da009_1_1_ "高血压_患病年份"  
label var da009_1_10_ "胃部疾病_患病年份"  
label var da009_1_11_ "情感_患病年份"  
label var da009_1_12_ "记忆相关_患病年份"  
label var da009_1_13_ "关节炎_患病年份"  
label var da009_1_14_ "哮喘_患病年份"  
label var da009_1_2_ "血脂异常_患病年份"  
label var da009_1_3_ "糖尿病_患病年份"  
label var da009_1_4_ "癌症_患病年份"  
label var da009_1_5_ "肺部_患病年份"  
label var da009_1_6_ "肝脏疾病_患病年份"  
label var da009_1_7_ "心脏病_患病年份"  
label var da009_1_8_ "中风_患病年份"  
label var da009_1_9_ "肾脏疾病_患病年份"  
label var da017s1 "癌症部位/大脑"
label var da017s10 "癌症部位/肝脏"
label var da017s11 "癌症部位/胰腺"
label var da017s12 "癌症部位/肾脏"
label var da017s13 "癌症部位/前列腺"
label var da017s14 "癌症部位/睾丸"
label var da017s15 "癌症部位/卵巢"
label var da017s16 "癌症部位/子宫颈"
label var da017s17 "癌症部位/子宫内膜"
label var da017s18 "癌症部位/结肠或直肠"
label var da017s19 "癌症部位/膀胱"
label var da017s2 "癌症部位/口腔"
label var da017s20 "癌症部位/皮肤"
label var da017s21 "癌症部位/非何杰金淋巴瘤"
label var da017s22 "癌症部位/白血病"
label var da017s23 "癌症部位/其他器官"
label var da017s3 "癌症部位/喉"
label var da017s4 "癌症部位/咽"
label var da017s5 "癌症部位/甲状腺"
label var da017s6 "癌症部位/肺"
label var da017s7 "癌症部位/乳房"
label var da017s8 "癌症部位/食管"
label var da017s9 "癌症部位/胃"
label var da042s1 "头疼" 
label var da042s10 "臀部疼"
label var da042s11 "腿疼"
label var da042s12 "膝盖疼"
label var da042s13 "脚踝疼"
label var da042s14 "脚趾头疼"
label var da042s15 "脖子疼"
label var da042s2 "肩膀疼" 
label var da042s3 "胳膊疼" 
label var da042s4 "手腕疼"
label var da042s5 "手指疼"
label var da042s6 "胸疼"
label var da042s7 "胃疼"
label var da042s8 "背疼"
label var da042s9 "腰疼"
label var dentim1y "去年的牙科诊疗次数"
label var dentst1y "去年是否看过牙医"
label var depresl "过去一周感到抑郁的频率" 
label var diabe "糖尿病" 
label var diasto "第2/3次舒张压"
label var diasto1 "第1次舒张压"
label var diasto2 "第2次舒张压"
label var diasto3 "第3次舒张压"
label var digeste "胃病" 
label var dimea "其他功能限制/从桌子上捡起硬币" 
label var disability "是否残疾"
label var dlrc "认知/延迟记忆" 
label var doctor "过去一个月是否门诊"
label var doctor_time "过去一个月门诊次数"
label var draw "认知/绘画"
label var dressa "ADL/穿衣"  
label var drinkev "是否饮过酒"
label var drinkl "现在是否饮酒" 
label var ds "认知/季节"
label var dw "认知/周" 
label var dy "认知/日" 
label var dyslipe "血脂异常" 
label var ea001s1 "城镇职工医疗保险" 
label var ea001s10 "长期护理保险" 
label var ea001s11 "其他医疗保险" 
label var ea001s2 "城乡居民医疗保险" 
label var ea001s3 "城镇居民医疗保险" 
label var ea001s4 " 新型农村合作医疗保险" 
label var ea001s5 "公费医疗" 
label var ea001s6 "医疗救助" 
label var ea001s7 "商业医疗保险: 单位购买" 
label var ea001s8 "商业医疗保险: 个人购买" 
label var ea001s9 "城镇无业居民大病医疗保险" 
label var eata "ADL/进食"  
label var effortl "过去一周做任何事都很费劲的频率" 
label var executive "心智状况(0~11分)" 
label var eyesight_close "近视情况" 
label var eyesight_distance "远视情况"
label var fall_down "跌倒"
label var family_size "家庭规模"
label var fcamt "过去一年中从子女/孙辈那里获得的经济援助金额"
label var fcany "过去一年中是否从其子女/孙辈那里获得任何经济援助" 
label var fearll "过去一周感到恐惧的频率" 
label var fhopel "过去一周对未来抱有希望的频率" 
label var flonel "过去一周感到孤独的频率" 
label var frailtya "虚弱指数"
label var fullcomp "是否愿意并能够完成双脚前后直线站立" 
label var fulldone "双脚前后直线站立是否保持整整30/60秒的平衡" 
label var fulltan "双脚前后直线站立测试的时间"
label var fulltanc "是否使用任何补偿运动来稳定双脚前后直线站立"
label var glass "戴眼镜"
label var goingl "过去一周无法继续我的生活的频率" 
label var gripcomp "是否愿意并且能够完成握力测试"
label var gripsum "优势手的最大测量值"
label var hatotfa "非住房金融财富总额" 
label var hchild "健在子女数"
label var hcoresd "是否与子女同住" 
label var hctot "家庭总消费" 
label var hdau "女儿数量"
label var hear "听力"
label var hear_aid "助听器"
label var hearte "心脏病" 
label var hfpamt "过去一年中从其父母/公公婆婆处获得的经济援助金额" 
label var hfpany "过去一年中是否从其父母/公公婆婆那里获得任何经济援助" 
label var hgkcare "是否照料孙子女" 
label var hhcperc "家庭人均消费" 
label var hibpe "高血压" 
label var hibpe_self "是否知道自己有高血压"
label var hip "髋骨骨折"
label var hlvnear "是否有子女与家庭及其配偶居住在同一城市或县" 
label var hospital "过去一年是否住院"
label var hospital_time "过去一年住院次数"
label var householdID "家庭编码"   
label var housewka "IADL/打扫房屋"  
label var hpcnt "是否每周与父母联系" 
label var hrural "居住在农村或城市"
label var hson "儿子数量"
label var hspnite "住院天数"
label var htcomp "是否愿意并能够完成身高测量"
label var htpamt "过去一年中向其父母/公公婆婆提供的经济援助金额" 
label var htpany "过去一年有否向其父母/公公婆婆提供任何经济援助" 
label var hukou "户口4分类" 
label var iadl "IADL(5项有困难)"
label var ID "受访者编码"  
label var imrc "认知/即时记忆" 
label var income_total "家庭总收入"
label var ins "是否有医疗保险"
label var iwm "调查月份"
label var iwstat "本期是否死亡"
label var iwy "调查年份"
label var joga "其他功能限制/跑步或慢跑1公里"
label var kcnt "是否每周亲自或通过电话、短信、邮件或电子邮件与他们的任何子女联系" 
label var kcntf "是否每周与子女进行面对面接触" 
label var kcntpm "是否每周通过电话、短信、邮件或电子邮件与子女联系" 
label var kidneye "肾脏疾病" 
label var lgrip "左手的最大握力测试"
label var lgrip1 "左手的第1次握力测试"
label var lgrip2 "左手的第2次握力测试"
label var lifta "其他功能限制/举起或搬运超过10斤的重物"
label var livere "肝脏疾病" 
label var ltact_c "轻度身体活动"
label var ltactx_c "每周轻度身体活动的天数"  
label var lunge "肺病" 
label var lunge_self "是否知道自己有肺部疾病"
label var marry "婚姻" 
label var mdact_c "中度身体活动"
label var mdactx_c "每周中等身体活动的天数"  
label var mealsa "IADL/准备饭菜"  
label var medsa "IADL/服用药物" 
label var memrye "记忆疾病" 
label var mets "MetS代谢综合征" 
label var mheight "身高/m"
label var mindtsl "过去一周感到难以集中注意力的频率" 
label var mo "认知/月" 
label var moneya "IADL/管理资金" 
label var mwaist "腰围/cm"
label var mweight "体重/kg"
label var nation "是否汉族"
label var oopden1y "去年的牙科护理自付支出"
label var oopdoc1m "门诊自付费用"
label var oophos1y "住院自付费用"
label var orient "认知/日期"
label var parkinson "帕金森2020年独有"
label var pension "是否有养老保险"
label var phonea "IADL/打电话"  
label var phy_acta "是否每周任何身体活动"  
label var phy_actb "是否每周中等或者剧烈身体活动"  
label var province "省份" 
label var psyche "精神疾病" 
label var psyche_self "是否知道自己有情感精神疾病"
label var puff "呼吸测试最大值"
label var puff1 "第一次呼吸测试"
label var puff2 "第二次呼吸测试"
label var puff3 "第三次呼吸测试"
label var puffcomp "是否愿意并能够完成呼吸测试"
label var pulse "第2/3次脉搏的均值"
label var pulse1 "第1次脉搏"
label var pulse2 "第2次脉搏"
label var pulse3 "第3次脉搏"
label var rabmonth "出生月份" 
label var rabyear "出生年份"
label var radaddrug "男性监护人在其成长过程中是否酗酒或有毒品问题"  
label var radadoccup_c "17岁前父亲从事农业"  
label var radmonth "死亡月份"
label var radyear "死亡年份"
label var raeduc_c "教育"
label var raeducl "教育统一分类"
label var rafinacom "17岁前家庭财务状况"  
label var ragender "性别" 
label var rahltcom "16岁前的相对健康状况"  
label var ramischlth "16岁前是否曾因健康问题缺课一个月或更长时间"  
label var ramomdrug "女性监护人在其成长过程中是否酗酒或有毒品问题"  
label var ramomoccup_c "17岁前母亲从事农业"  
label var rapadrug "监护人在其成长过程中是否酗酒或有毒品问题"  
label var recall "情景记忆(0~10分)" 
label var region "地区(东/中/西/东北)"
label var retire "是否退休"
label var retmon "正式退休月份" 
label var retyr "正式退休年份"  
label var rgrip "右手的最大握力测试"
label var rgrip1 "右手的第1次握力测试"
label var rgrip2 "右手的第2次握力测试"
label var rural "居住地"
label var rural2 "户口2分类" 
label var rxarthr "是否服用西药治疗关节炎或风湿病"
label var rxarthr_c "是否服用任何药物治疗关节炎或风湿病"
label var rxdiab "是否注射胰岛素或正在服用糖尿病西药"
label var rxdiab_c "是否正在服用任何治疗糖尿病的药物"
label var rxdiabi "是否注射胰岛素治疗糖尿病"
label var rxdigest "是否服用西药治疗胃或其他消化系统疾病"
label var rxdigest_c "是否服用任何药物治疗胃或其他消化系统疾病"
label var rxdyslip "是否服用西药治疗血脂异常"
label var rxdyslip_c "是否服用任何药物治疗血脂异常"
label var rxheart "是否服用西药治疗心脏病"  
label var rxheart_c "是否服用任何药物治疗心脏病" 
label var rxhibp "是否服用治疗高血压的西药" 
label var rxhibp_c "是否服用任何治疗高血压的药物" 
label var rxkidney "是否服用西药治疗肾脏疾病" 
label var rxkidney_c "是否服用任何药物治疗肾脏疾病" 
label var rxliver "是否服用西药治疗肝病" 
label var rxliver_c "服用任何药物治疗肝病" 
label var rxlung "是否服用西药治疗慢性肺病"
label var rxlung_c "是否服用任何药物治疗慢性肺病" 
label var rxmemry "是否服用西药治疗记忆相关疾病" 
label var rxmemry_c "是否服用任何药物治疗记忆相关疾病" 
label var rxpsych "是否正在服用药物治疗精神问题"  
label var rxstrok "是否服用西药治疗中风"  
label var rxstrok_c "是否正在服用任何药物治疗中风"
label var sati_child "子女关系满意度"
label var satlife  "生活满意度"
label var satlifez "生活满意度z评分" 
label var sbscomp "是否愿意并且能够完成双脚并拢站立"
label var sbsdone "是否保持10秒双脚并拢站立"
label var sbstan "双脚并拢站立时间"
label var sbstanc "是否使用任何补偿性运动稳定双脚并拢站立"
label var semicomp "是否愿意并能够完成双脚半前后站立测试"
label var semidone "是否保持10秒双脚半前后站立的平衡"
label var semitan "双脚半前后站立测试的时间"
label var semitanc "是否使用任何补偿运动来稳定双脚半前后站立"
label var ser7 "认知/序列7"
label var shopa "IADL/购买食品杂货"  
label var sleep_nap "午睡时间"  
label var sleep_night "晚上睡眠时间"
label var sleeprl "过去一周感到睡眠不安的频率" 
label var slfmem "自评记忆" 
label var smokef "吸烟数量" 
label var smoken "现在是否吸烟" 
label var smokev "是否吸过烟"
label var socwk "是否每月参与社交"
label var srh "自评健康" 
label var stoopa "其他功能限制/弯腰跪下或蹲下"
label var stroke "中风" 
label var systo "第2/3次收缩压的均值"
label var systo1 "第1次收缩压"
label var systo2 "第2次收缩压"
label var systo3 "第3次收缩压"
label var tcamt "过去一年中向子女/孙辈提供的经济援助金额"
label var tcany "过去一年是否向其子女/孙辈提供任何经济援助" 
label var teeth "掉牙"
label var toilta "ADL/使用厕所"  
label var total_cognition "认知能力(0~21分,越大越好)" 
label var totden1y "去年的牙科护理总支出"
label var totdoc1m "门诊总费用"
label var tothos1y "住院总费用"
label var totmet "身体活动产生的总代谢量"
label var tr20 "认知/单词记忆得分" 
label var trdmdtim1m "上月到访中医院的次数"
label var trdmed1m "上月是否去过中医院"
label var trpsych "是否正在接受精神问题的治疗"
label var tyg "甘油三酯葡萄糖指数(TyG指数)"
label var tyg_bmi "油三酯葡萄糖体重指数(TyG-BMI指数)"
label var urina "ADL/控制排尿"  
label var vgact_c "重度身体活动"
label var vgactx_c "每周剧烈活动的天数"  
label var walk100a "其他功能限制/步行100米"
label var walk1kma "其他功能限制/步行1公里"
label var walkcomp "是否完成步速测试"
label var watcomp "是否愿意并能够完成腰围测量"
label var wave "第几波调查"  
label var whappyl "过去一周感到快乐的频率" 
label var work "是否工作"  
label var wspeed "步行速度测试-均值"
label var wspeed1 "步行速度测试-第1次"
label var wspeed2 "步行速度测试-第2次"
label var wtcomp "是否愿意并能够完成体重测量"
label var yr "认知/年" 
label var sisa "社会隔离0~4分"
label var sisb "社会隔离0~6分"
label var dependency "功能依赖性"
label var clean_heat "取暖使用污染燃料"
label var clean_cook "做饭使用污染燃料"
label var build "建筑材料差"
label var toilet "厕所卫生差" 
label var electricity "是否有电" 
label var water "是否有自来水" 
label var room "房间数"
label var frailtyb "虚弱指数b"
label var memory_z "认知/记忆z标准化(ref1)"
label var orient_z "认知/定向z标准化(ref1)"
label var executive_z "认知/执行能力z标准化(ref1)"
label var tcog_z_z "认知/总认知能力z标准化(ref1)"
label var hobby "是否有爱好"
label var z_tr20 "认知/z-score记忆"
label var z_orient "认知/z-score定向"
label var z_ser7 "认知/z-score计算或者执行"
label var z_cog29 "认知/z-score总认知29分"


*****所有缺失值类型转为.
mvencode _all, mv(-999) 
mvdecode _all, mv(-999)

*****计算整个样本的认知状况
* 定义年龄组变量
gen age_group = .
replace age_group = 1 if age >= 45 & age <= 49
replace age_group = 2 if age >= 50 & age <= 54
replace age_group = 3 if age >= 55 & age <= 59
replace age_group = 4 if age >= 60 & age <= 64
replace age_group = 5 if age >= 65 & age <= 69
replace age_group = 6 if age >= 70 & age <= 74
replace age_group = 7 if age >= 75 & age <= 79
replace age_group = 8 if age >= 80

* 计算每个年龄组在两个认知领域上的平均值和标准差
foreach var in imrc dlrc orient ser7 {
    bys age_group: egen mean_`var' = mean(`var')
    bys age_group: egen sd_`var' = sd(`var')
}

* 计算Z分数
foreach var in imrc dlrc orient ser7 {
    gen z`var' = (`var' - mean_`var') / sd_`var'
}

* 标记认知状况
gen cog_status = 0
foreach var in imrc dlrc orient ser7 {
    replace cog_status = 1 if z`var' < -1.5
}

label var cog_status "认知状况"
label var age_group "45岁以上的分组"
drop mean_imrc sd_imrc mean_dlrc sd_dlrc mean_orient sd_orient mean_ser7 sd_ser7 ///
zimrc zdlrc zorient zser7


*****赋予数值标签(说明数值的具体含义)
label define yesno_ 0 "否" 1 "是"
label value ramomoccup_c radadoccup_c ramomdrug radaddrug rapadrug ramischlth ///
nation hibpe dyslipe diabe cancre lunge livere hearte stroke kidneye digeste ///
psyche memrye arthre asthmae hibpe_self lunge_self psyche_self da042s1 da042s2 ///
da042s3 da042s4 da042s5 da042s6 da042s7 da042s8 da042s9 da042s10 da042s11 ///
da042s12 da042s13 da042s14 da042s15 act_1 act_2 act_3 act_4 act_5 act_6 ///
act_7 act_8 dressa batha eata beda toilta urina housewka mealsa shopa phonea ///
medsa moneya work retire parkinson vgact_c mdact_c ltact_c drinkl smokev ///
smoken doctor hospital pension ins ea001s1 ea001s2 ea001s3 ea001s4 ea001s5 ///
ea001s11 socwk hcoresd kcntf kcntpm kcnt fcany tcany fall_down hip iwstat ///
phy_acta phy_actb hfpany hgkcare hlvnear hpcnt htpany armsa bpact30 bpcomp chaira ///
chr5bmv chr5comp circs climsa cncrchem cncrmeds cncrmeds_c cncrradn cncrsurg ///
dimea disability drinkev fullcomp fulldone fulltanc gripcomp htcomp joga lifta ///
puffcomp rxarthr rxarthr_c rxdiab rxdiab_c rxdiabi rxdigest rxdigest_c ///
rxdyslip rxdyslip_c rxheart rxheart_c rxhibp rxhibp_c rxkidney rxkidney_c ///
rxliver rxliver_c rxlung rxlung_c rxmemry rxmemry_c rxpsych rxstrok rxstrok_c ///
sbscomp sbsdone sbstanc semicomp semidone semitanc stoopa trdmed1m trpsych ///
walk100a walk1kma walkcomp watcomp wtcomp dentst1y bl_fasting social1 social2 ///
social3 social4 social5 social6 social7 social8 social9 social10 social11 ///
teeth glass hear_aid da017s1 da017s2 da017s3 da017s4 da017s5 da017s6 da017s7 ///
da017s8 da017s9 da017s10 da017s11 da017s12 da017s13 da017s14 da017s15 da017s16 ///
da017s17 da017s18 da017s19 da017s20 da017s21 da017s22 da017s23 ea001s6 ea001s7 ///
ea001s8 ea001s9 ea001s10 mets clean_heat clean_cook build toilet electricity water ///
cog_status hobby yesno_

label define wave_ 1 "wave1" 2 "wave2" 3 "wave3" 4 "wave4" 5 "wave5"
label value wave wave_ 

label define gender_ 0 "女性" 1 "男性"
label value ragender gender_ 

label define rahltcom_ 1 "更不健康" 2 "些许不健康" 3 "一般" 4 "些许健康" 5 "更健康"
label values rahltcom rahltcom_

label define health_ 1 "很差" 2 "较差" 3 "一般" 4 "较好" 5 "很好"
label value srh health_

label define slfmem_ 1 "不好" 2 "一般" 3 "好" 4 "很好" 5 "极好"
label value slfmem slfmem_

label define sati_ 1 "一点也不满意" 2 "不太满意" 3 "比较满意" 4 "非常满意" 5 "极其满意"
label value satlife sati_child sati_

label define marry_ 1 "已婚" 2 "已婚但不住在一起" 3 "同居" 4 "分居" 5 "离异" 7 "丧偶" 8 "从未结婚"
label value marry marry_

label define rural_ 0 "城市" 1 "农村"
label value hrural rural2 rural_ 

label define hukou_ 1 "农业户口" 2 "非农业户口" 3 "统一户口" 4 "没有户口"
label values hukou hukou_

label define bl_fasting_ 1 "是" 2 "否" 
label value bl_fasting bl_fasting_

label define eyesight_ 1 "不好" 2 "一般" 3 "好" 4 "很好" 5 "极好"
label value hear eyesight_distance eyesight_close eyesight_

label define glass_ 0 "否" 1 "是" 2 "失明"
label value glass glass_

label define raeduc_c_ 1 "未完成小学" 2 "小学" 3 "中学" 4 "高中及以上"
label values raeduc_c raeduc_c_

label define raeducl_ 1 "低于初中学历" 2 "高中和职业培训" 3 "高等教育" 
label values raeducl raeducl_

label define dependency_ 0 "独立" 1 "低依赖性" 2 "中等依赖性" 3 "高依赖性"
label values dependency dependency_	 

*****final sort
sort ID

*****compress dataset
compress	

*****add label
label data "Shawn老师 @丁点帮你"

*****add notes
notes drop _dta
note: Shawn老师->微信公众账号@丁点帮你

save "$working_data/charls.dta",replace  //保存数据

*****单独保存每一期数据
local num_waves = 5 // 设置波次总数，这里是5个波次

forvalues wave = 1/`num_waves' {
    use "$working_data/charls.dta", clear
    keep if wave == `wave'
    save "$working_data/charls_wave`wave'.dta", replace
}

