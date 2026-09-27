clear all
set more off
set maxvar 120000
global root= "E:/MHAS_墨西哥"
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
use "$raw_data/Harmonized MHAS File/H_MHAS_c2.dta",clear
merge m:1 unhhid ps3 using "$temp_data/wave1.dta",nogen
merge m:1 cunicah acthog ent2 using "$temp_data/wave2.dta",nogen
merge m:1 cunicah np using "$temp_data/wave3.dta",nogen force
merge m:1 cunicah np using "$temp_data/wave4.dta",nogen force
merge m:1 cunicah np using "$temp_data/wave5.dta",nogen force
drop if rahhidnp==""

*****个人标识符
*rahhidnp

*****家庭标识符
*h1hhidc h2hhidc h3hhidc h4hhidc h5hhidc

*****是否参与本次调查
*inw1 inw2 inw3 inw4 inw5
label define yesno_ 1 "是" 0 "否"
label values inw1 inw2 inw3 inw4 inw5 yesno_

*****是否死亡
*r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat
forvalues i=1/5 {
 recode r`i'iwstat (0 1 4=0) (5 6=1) (9=.)	
}
label values r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat yesno_

*****是否代理回答
*r1proxy r2proxy r3proxy r4proxy r5proxy
label values r1proxy r2proxy r3proxy r4proxy r5proxy yesno_

*****受访月份
*r1iwm r2iwm r3iwm r4iwm r5iwm

*****受访年份
*r1iwy r2iwy r3iwy r4iwy r5iwy

*****出生年份
*rabyear

*****出生月份
*rabmonth

*****死亡年份
*radyear

*****死亡月份
*radmonth

*****年龄
*r3agey r4agey r5agey

*****性别
*ragender
recode ragender (1=1) (2=0)
label define ragender_ 0 "女性" 1 "男性"
label values ragender ragender_

*****受教育年限
*raedyrs

*****统一可比的教育程度
*raeducl
label define raeducl_ 1 "低于高中学历" 2 "高中和职业培训" 3 "高等教育"
label values raeducl raeducl_

*****是否能够读写
*raliterate
label values raliterate yesno_

*****是否能够从1数到10
*ranumerate
label values ranumerate yesno_ 

*****婚姻状况
*r1mstath r2mstath r3mstath r4mstath r5mstath
label define mstath_ 1 "已婚" 3 "同居" 4 "分居" 5 "离婚" 7 "丧偶" 8 "从未结婚"
label values r1mstath r2mstath r3mstath r4mstath r5mstath mstath_

*****家庭居住在城市还是农村
*h1rural h3rural h4rural h5rural
label define rural_ 0 "城市" 1 "农村"
label values h1rural h3rural h4rural h5rural rural_

*****自评健康
*r1shlt r2shlt r3shlt r4shlt r5shlt
label define shlt_ 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好"
label values r1shlt r2shlt r3shlt r4shlt r5shlt shlt_

*****ADL/在房间里走动是否困难
*r1walkra r2walkra r3walkra r4walkra r5walkra
label values r1walkra r2walkra r3walkra r4walkra r5walkra yesno_

*****ADL/穿衣是否困难
*r1dressa r2dressa r3dressa r4dressa r5dressa
label values r1dressa r2dressa r3dressa r4dressa r5dressa yesno_

*****ADL/洗澡是否困难
*r1batha r2batha r3batha r4batha r5batha
label values r1batha r2batha r3batha r4batha r5batha yesno_

*****ADL/吃饭是否困难
*r1eata r2eata r3eata r4eata r5eata
label values r1eata r2eata r3eata r4eata r5eata yesno_

*****ADL/上下床是否困难
*r1beda r2beda r3beda r4beda r5beda
label values r1beda r2beda r3beda r4beda r5beda yesno_

*****ADL/上厕所是否困难
*r1toilta r2toilta r3toilta r4toilta r5toilta
label values r1toilta r2toilta r3toilta r4toilta r5toilta yesno_

*****IADL/日常生活工具活动困难
*r1moneya r2moneya r3moneya r4moneya r5moneya
label values r1moneya r2moneya r3moneya r4moneya r5moneya yesno_

*****IADL/管理金钱
*r1medsa r2medsa r3medsa r4medsa r5medsa
label values r1medsa r2medsa r3medsa r4medsa r5medsa yesno_

*****IADL/购买杂货
*r1shopa r2shopa r3shopa r4shopa r5shopa
label values r1shopa r2shopa r3shopa r4shopa r5shopa yesno_

*****IADL/准备饭菜
*r1mealsa r2mealsa r3mealsa r4mealsa r5mealsa
label values r1mealsa r2mealsa r3mealsa r4mealsa r5mealsa yesno_

*****其他限制/步行几个街区
*r1walksa r2walksa r3walksa r4walksa r5walksa
label values r1walksa r2walksa r3walksa r4walksa r5walksa yesno_

*****其他限制/跑步和慢跑一公里
*r1joga r2joga r3joga r4joga r5joga
label values r1joga r2joga r3joga r4joga r5joga yesno_

*****其他限制/步行一个街区
*r1walk1a r2walk1a r3walk1a r4walk1a r5walk1a
label values r1walk1a r2walk1a r3walk1a r4walk1a r5walk1a yesno_

*****其他限制/坐约2小时
*r1sita r2sita r3sita r4sita r5sita
label values r1sita r2sita r3sita r4sita r5sita yesno_

*****其他限制/长时间坐着从椅子上站起来
*r1chaira r2chaira r3chaira r4chaira r5chaira
label values r1chaira r2chaira r3chaira r4chaira r5chaira yesno_

*****其他限制/不休息地爬几段楼梯
*r1climsa r2climsa r3climsa r4climsa r5climsa
label values r1climsa r2climsa r3climsa r4climsa r5climsa yesno_

*****其他限制/不休息地爬一段楼梯
*r1clim1a r2clim1a r3clim1a r4clim1a r5clim1a
label values r1clim1a r2clim1a r3clim1a r4clim1a r5clim1a yesno_

*****其他限制/弯腰跪下或蹲伏
*r1stoopa r2stoopa r3stoopa r4stoopa r5stoopa
label values r1stoopa r2stoopa r3stoopa r4stoopa r5stoopa yesno_

*****其他限制/举起或搬运超过5公斤的重物
*r1lifta r2lifta r3lifta r4lifta r5lifta
label values r1lifta r2lifta r3lifta r4lifta r5lifta yesno_

*****其他限制/从桌子上捡起一枚小硬币
*r1dimea r2dimea r3dimea r4dimea r5dimea
label values r1dimea r2dimea r3dimea r4dimea r5dimea yesno_

*****其他限制/手臂超过肩膀
*r1armsa r2armsa r3armsa r4armsa r5armsa
label values r1armsa r2armsa r3armsa r4armsa r5armsa yesno_

*****其他限制/推或拉大型物体
*r1pusha r2pusha r3pusha r4pusha r5pusha
label values r1pusha r2pusha r3pusha r4pusha r5pusha yesno_

*****ADL总分(6项)
*r1adltot6 r2adltot6 r3adltot6 r4adltot6 r5adltot6

*****IADL总分(4项)
*r1iadlfour r2iadlfour r3iadlfour r4iadlfour r5iadlfour

*****医生是否诊断曾经或目前患有高血压
*r1hibpe r2hibpe r3hibpe r4hibpe r5hibpe
label values r1hibpe r2hibpe r3hibpe r4hibpe r5hibpe yesno_

*****医生是否诊断曾经或目前患有糖尿病或高血糖
*r1diabe r2diabe r3diabe r4diabe r5diabe
label values r1diabe r2diabe r3diabe r4diabe r5diabe yesno_

*****医生是否诊断曾经或目前患有癌症
*r1cancre r2cancre r3cancre r4cancre r5cancre
label values r1cancre r2cancre r3cancre r4cancre r5cancre yesno_

*****医生是否诊断曾经或目前患有呼吸系统疾病
*r1respe r2respe r3respe r4respe r5respe
label values r1respe r2respe r3respe r4respe r5respe yesno_

*****医生是否诊断曾经或目前患有心脏病发作
*r1hrtatte r2hrtatte r3hrtatte r4hrtatte r5hrtatte
label values r1hrtatte r2hrtatte r3hrtatte r4hrtatte r5hrtatte yesno_

*****医生是否诊断曾经或目前患有心脏疾病
*r4hearte r5hearte
label values r4hearte r5hearte yesno_

*****医生是否诊断曾经或目前患有中风
*r1stroke r2stroke r3stroke r4stroke r5stroke
label values r1stroke r2stroke r3stroke r4stroke r5stroke yesno_

*****医生是否诊断曾经或目前患有关节炎或风湿病
*r1arthre r2arthre r3arthre r4arthre r5arthre
label values r1arthre r2arthre r3arthre r4arthre r5arthre yesno_

*****是否服用高血压药物
*r1rxhibp r2rxhibp r3rxhibp r4rxhibp r5rxhibp
label values r1rxhibp r2rxhibp r3rxhibp r4rxhibp r5rxhibp yesno_

*****是否口服糖尿病药物
*r1rxdiabo r2rxdiabo r3rxdiabo r4rxdiabo r5rxdiabo
label values r1rxdiabo r2rxdiabo r3rxdiabo r4rxdiabo r5rxdiabo yesno_

*****是否使用胰岛素注射治疗糖尿病
*r1rxdiabi r2rxdiabi r3rxdiabi r4rxdiabi r5rxdiabi
label values r1rxdiabi r2rxdiabi r3rxdiabi r4rxdiabi r5rxdiabi yesno_

*****是否使用任何治疗糖尿病的药物(口服药物或胰岛素注射)
*r1rxdiab r2rxdiab r3rxdiab r4rxdiab r5rxdiab
label values r1rxdiab r2rxdiab r3rxdiab r4rxdiab r5rxdiab yesno_

*****是否接受化疗或药物治疗癌症
*r1cncrchem r2cncrchem r3cncrchem r4cncrchem r5cncrchem
label values r1cncrchem r2cncrchem r3cncrchem r4cncrchem r5cncrchem yesno_

*****是否接受过手术或活检以治疗癌症
*r1cncrsurg r2cncrsurg r3cncrsurg r4cncrsurg r5cncrsurg
label values r1cncrsurg r2cncrsurg r3cncrsurg r4cncrsurg r5cncrsurg yesno_

*****是否接受过放射或x射线治疗癌症
*r1cncrradn r2cncrradn r3cncrradn r4cncrradn r5cncrradn
label values r1cncrradn r2cncrradn r3cncrradn r4cncrradn r5cncrradn yesno_

*****是否接受了治疗癌症的药物或治疗症状(疼痛、恶心、皮疹)
*r1cncrmeds r2cncrmeds r3cncrmeds r4cncrmeds r5cncrmeds
label values r1cncrmeds r2cncrmeds r3cncrmeds r4cncrmeds r5cncrmeds yesno_

*****是否接受过另一种未指明的癌症治疗
*r1cncrothr r2cncrothr r3cncrothr r4cncrothr r5cncrothr
label values r1cncrothr r2cncrothr r3cncrothr r4cncrothr r5cncrothr yesno_

*****是否服用呼吸系统疾病的药物，如哮喘或肺气肿
*r1rxresp r2rxresp r3rxresp r4rxresp r5rxresp
label values r1rxresp r2rxresp r3rxresp r4rxresp r5rxresp yesno_

*****是否因心脏病发作而服用药物
*r1rxhrtat r2rxhrtat r3rxhrtat r4rxhrtat r5rxhrtat
label values r1rxhrtat r2rxhrtat r3rxhrtat r4rxhrtat r5rxhrtat yesno_

*****是否服用中风药物
*r1rxstrok r2rxstrok r3rxstrok r4rxstrok r5rxstrok
label values r1rxstrok r2rxstrok r3rxstrok r4rxstrok r5rxstrok yesno_

*****是否服用关节炎药物
*r1rxarthr r2rxarthr r3rxarthr r4rxarthr r5rxarthr
label values r1rxarthr r2rxarthr r3rxarthr r4rxarthr r5rxarthr yesno_ 

*****最近被诊断出患有癌症的年龄
*r1reccancr r2reccancr r3reccancr r4reccancr r5reccancr

*****最近心脏病发作的年龄
*r1rechrtatt r2rechrtatt r3rechrtatt r4rechrtatt r5rechrtatt

*****最近中风的年龄
*r1recstrok r2recstrok r3recstrok r4recstrok r5recstrok

*****自评的视力
*r1sight r2sight r3sight r4sight r5sight
forvalues i=1/5 {
  recode r`i'sight  (1=5) (2=4) (3=3) (4=2) (5=1) (6=0)	
}
label define sight_ 0 "失明" 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好"
label values r1sight r2sight r3sight r4sight r5sight sight_

*****是否经常戴眼镜
*r1glasses r2glasses r3glasses r4glasses r5glasses
label values r1glasses r2glasses r3glasses r4glasses r5glasses yesno_

*****自评听力
*r1hearing r2hearing r3hearing r4hearing r5hearing
label define hearing_ 0 "失聪" 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好"
label values r1hearing r2hearing r3hearing r4hearing r5hearing hearing_

*****是否经常佩戴助听器
*r1hearaid r2hearaid r3hearaid r4hearaid r5hearaid
label values r1hearaid r2hearaid r3hearaid r4hearaid r5hearaid yesno_

*****最近2年内是否跌倒过
*r1fall r2fall r3fall r4fall r5fall
label values r1fall r2fall r3fall r4fall r5fall yesno_

*****摔倒的次数(过去2年)
*r1fallnum r2fallnum r3fallnum r4fallnum r5fallnum

*****是否曾因跌倒而严重受伤需要接受治疗
*r1fallinj r2fallinj r3fallinj r4fallinj r5fallinj
label values r1fallinj r2fallinj r3fallinj r4fallinj r5fallinj yesno_

*****50岁生日之后是否有过骨折(包括髋部)
*r1hip50e r2hip50e r3hip50e r4hip50e
label values r1hip50e r2hip50e r3hip50e r4hip50e yesno_

*****过去两年中是否骨折(包括髋部)
*r3hip_m r4hip_m r5hip_m
label values r3hip_m r4hip_m r5hip_m yesno_

*****过去两年内是否髋部骨折
*r5hip
label values r5hip yesno_

*****过去2年内是否有过尿失禁
*r1urina2y r2urina2y
label values r1urina2y r2urina2y yesno_

*****过去2年是否在咳嗽打喷嚏时失禁
*r3urinurg2y r4urinurg2y r5urinurg2y
label values r3urinurg2y r4urinurg2y r5urinurg2y yesno_

*****有尿意但不能及时到达洗手间时是否出现过尿失禁
*r3urincgh2y r4urincgh2y r5urincgh2y
label values r3urincgh2y r4urincgh2y r5urincgh2y yesno_

*****过去2年内是否经历过脚或脚踝的持续肿胀
*r1swell r2swell r3swell r4swell r5swell
label values r1swell r2swell r3swell r4swell r5swell yesno_

*****过去2年内躺下时是否感到呼吸困难
*r1breath_m r2breath_m r3breath_m r4breath_m r5breath_m
label values r1breath_m r2breath_m r3breath_m r4breath_m r5breath_m yesno_

*****是否经历过持续的喘息或咳嗽或带痰
*r1wheeze r2wheeze
label values r1wheeze r2wheeze yesno_

*****是否经历过严重的疲劳或疲惫
*r1fatigue r2fatigue r3fatigue r4fatigue r5fatigue
label values r1fatigue r2fatigue r3fatigue r4fatigue r5fatigue yesno_

*****入睡困难的频率
*r4fallslp r5fallslp
label define slp_ 1 "大部分时间" 2 "有时" 3 "很少或者从不"
label values r4fallslp r5fallslp slp_

*****夜间醒来的频率
*r4wakent r5wakent
label values r4wakent r5wakent slp_

*****醒得太早而无法再入睡的频率
*r4wakeup r5wakeup
label values r4wakeup r5wakeup slp_

*****醒来时感到精力充沛的频率
*r3rested r4rested r5rested
label values r3rested r4rested r5rested slp_

*****是否感到疼痛
*r1painfr r2painfr r3painfr r4painfr r5painfr
label values r1painfr r2painfr r3painfr r4painfr r5painfr yesno_

*****疼痛程度
*r1painlv r2painlv r3painlv r4painlv r5painlv
label define painlv_ 0 "没有" 1 "轻度" 2 "中等" 3 "严重" 
label values r1painlv r2painlv r3painlv r4painlv r5painlv painlv_

*****疼痛是否干扰了日常活动
*r1paina r2paina r3paina r4paina r5paina
label values r1paina r2paina r3paina r4paina r5paina yesno_

*****是否曾经做过子宫切除术
*r4hystere r5hystere
label values r4hystere r5hystere yesno_

*****最后一次月经的年龄
*r4lstmnspd r5lstmnspd

*****自我报告BMI
*r1bmi r2bmi r3bmi r4bmi r5bmi

*****自我报告身高m
*r1height r2height r3height r4height r5height

*****自我报告体重kg
*r1weight r2weight r3weight r4weight r5weight

*****过去两年中是否每周参加三次或以上的剧烈活动
*r1vigact r2vigact r3vigact r4vigact r5vigact
label values r1vigact r2vigact r3vigact r4vigact r5vigact yesno_

*****是否喝过酒
*r1drink r2drink r3drink r4drink r5drink
label values r1drink r2drink r3drink r4drink r5drink yesno_

*****每周饮酒的天数
*r1drinkd r2drinkd r3drinkd r4drinkd r5drinkd

*****喝酒的数量
*r1drinkn r2drinkn r3drinkn r4drinkn r5drinkn

*****是否曾经酗酒
*r1drinkb r2drinkb r3drinkb r4drinkb r5drinkb
label values r1drinkb r2drinkb r3drinkb r4drinkb r5drinkb yesno_

*****过去3个月内酗酒的天数
*r1binged r2binged r3binged r4binged r5binged

*****是否吸过烟
*r1smokev r2smokev r3smokev r4smokev r5smokev
label values r1smokev r2smokev r3smokev r4smokev r5smokev yesno_

*****目前是否吸烟
*r1smoken r2smoken r3smoken r4smoken r5smoken
label values r1smoken r2smoken r3smoken r4smoken r5smoken yesno_

*****每天通常吸烟的数量
*r1smokef r2smokef r3smokef r4smokef r5smokef

*****开始吸烟的年龄
*r1strtsmok r2strtsmok r3strtsmok r4strtsmok r5strtsmok

*****戒烟的年龄
*r1quitsmok r2quitsmok r3quitsmok r4quitsmok r5quitsmok

*****过去两年内血液胆固醇检查
*r1cholst r2cholst r3cholst r4cholst r5cholst
label values r1cholst r2cholst r3cholst r4cholst r5cholst yesno_

*****过去两年内是否流感疫苗
*r3flusht r4flusht r5flusht
label values r3flusht r4flusht r5flusht yesno_

*****过去两年内是否每月乳房自我检查
*r1breast r2breast r3breast r4breast r5breast
label values r1breast r2breast r3breast r4breast r5breast yesno_

*****过去两年内是否乳房x光检查
*r1mammog r2mammog r3mammog r4mammog r5mammog
label values r1mammog r2mammog r3mammog r4mammog r5mammog yesno_

*****过去两年内是否子宫颈抹片检查
*r1papsm r2papsm r3papsm r4papsm r5papsm
label values r1papsm r2papsm r3papsm r4papsm r5papsm yesno_

*****过去两年内是否前列腺癌检查
*r1prost r2prost r3prost r4prost r5prost
label values r1prost r2prost r3prost r4prost r5prost yesno_

*****过去12个月内是否至少有一次过夜住院
*r1hosp1y r2hosp1y r3hosp1y r4hosp1y r5hosp1y
label values r1hosp1y r2hosp1y r3hosp1y r4hosp1y r5hosp1y yesno_

*****过去12个月内所有住院的总过夜数
*r1hspnit1y r2hspnit1y r3hspnit1y r4hspnit1y r5hspnit1y

*****过去12个月内是否至少看过一次医生
*r1doctor1y r2doctor1y r3doctor1y r4doctor1y r5doctor1y
label values r1doctor1y r2doctor1y r3doctor1y r4doctor1y r5doctor1y yesno_

*****过去12个月报告的就诊次数
*r1doctim1y r2doctim1y r3doctim1y r4doctim1y r5doctim1y

*****过去12个月内是否报告至少一次门诊手术
*r1outpt1y r2outpt1y r3outpt1y r4outpt1y r5outpt1y
label values r1outpt1y r2outpt1y r3outpt1y r4outpt1y r5outpt1y yesno_

*****过去12个月内是否报告至少一次牙科就诊
*r1dentst1y r2dentst1y r3dentst1y r4dentst1y r5dentst1y
label values r1dentst1y r2dentst1y r3dentst1y r4dentst1y r5dentst1y yesno_

*****过去12个月报告的牙科就诊总数
*r1dentim1y r2dentim1y r3dentim1y r4dentim1y r5dentim1y

*****过去12个月的自付住院费用
*r1oophos1y r2oophos1y r3oophos1y r4oophos1y r5oophos1y

*****过去12个月民间疗法自费支出
*r1oopfhho1y r2oopfhho1y r3oopfhho1y r4oopfhho1y

*****过去12个月牙医自费支出
*r1oopden1y r2oopden1y r3oopden1y r4oopden1y r5oopden1y

*****过去12个月的门诊手术自费支出
*r1ooposrg1y r2ooposrg1y r3ooposrg1y r4ooposrg1y r5ooposrg1y

*****过去12个月医生自付费用的总额
*r1oopdoc1y r2oopdoc1y r3oopdoc1y r4oopdoc1y r5oopdoc1y

*****过去12个月的自付医疗支出总额
*r1oopmd1y r2oopmd1y r3oopmd1y r4oopmd1y r5oopmd1y

*****是否被任何政府健康保险计划所覆盖
*r1higov r2higov r3higov r4higov r5higov
label values r1higov r2higov r3higov r4higov r5higov yesno_

*****是否有任何私人医疗健康保险
*r1hipriv r2hipriv r3hipriv r4hipriv r5hipriv
label values r1hipriv r2hipriv r3hipriv r4hipriv r5hipriv yesno_

*****是否因为是工人或曾经是工人而享有健康保险
*r1covr_m r2covr_m r3covr_m r4covr_m r5covr_m
label values r1covr_m r2covr_m r3covr_m r4covr_m r5covr_m yesno_

*****是否因为其配偶是或曾经是工人而获得医疗保险
*r1covs_m r2covs_m r3covs_m r4covs_m r5covs_m
label values r1covs_m r2covs_m r3covs_m r4covs_m r5covs_m yesno_

*****参加的健康保险计划的数量
*r1henum r2henum r3henum r4henum r5henum

*****认知/视觉问题
*r1novisual r2novisual r3novisual r4novisual r5novisual

*****认知/是否报告握住的铅笔有任何问题
*r1nopencil r2nopencil r3nopencil r4nopencil r5nopencil

*****认知/自我报告的记忆
*r3slfmem r4slfmem r5slfmem
forvalues i=3/5 {
  recode r`i'slfmem (1=5) (2=4) (3=3) (4=2) (5=1)	
}
label define slfmem_ 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好"
label values r3slfmem r4slfmem r5slfmem slfmem_

*****认知/即时回忆
*r1imrc8 r2imrc8 r3imrc8 r4imrc8 r5imrc8

*****认知/单词延迟回忆
*r1dlrc8 r2dlrc8 r3dlrc8 r4dlrc8 r5dlrc8

*****认知/单词总分
*r1tr16 r2tr16 r3tr16 r4tr16 r5tr16

*****认知/视觉空间任务得分2
*r1idraw2 r2idraw2

*****认知/视觉空间任务得分1
*r3idraw1 r4idraw1 r5idraw1

*****认知/延迟视觉空间任务得分2
*r1ddraw2 r2ddraw2

*****认知/延迟视觉空间任务得分1
*r3ddraw1 r4ddraw1 r5ddraw1

*****认知/语言流利度
*r3verbf r4verbf r5verbf

*****认知/视觉扫描评分
*r1vscan r2vscan r3vscan r4vscan r5vscan

*****认知/倒算得分
*r3bwc20 r4bwc20

*****认知/是否能够成功地从20开始连续倒数10个数
*r3bwc20_m r4bwc20_m

*****认知/是否能够正确地报告日
*r2dy r3dy r4dy

*****认知/是否能够正确地报告月
*r2mo r3mo r4mo

*****认知/是否能够正确地报告年
*r2yr r3yr r4yr

*****认知/是否能够正确地报告日期
*r2orient_m r3orient_m r4orient_m

*****正确减法的个数
*r4ser7 r5ser7

*****房屋所有权
*h1hownrnt h2hownrnt h3hownrnt h4hownrnt h5hownrnt
label define hownrnt_ 1 "自有" 2 "租赁" 3 "其他安排"
label values h1hownrnt h2hownrnt h3hownrnt h4hownrnt h5hownrnt hownrnt_

*****家庭的总财富
*h1atotb h2atotb h3atotb h4atotb h5atotb

*****夫妻每年的个人收入
*r1iearn r2iearn r3iearn r4iearn r5iearn

*****夫妻总收入
*h1itot h2itot h3itot h4itot h5itot

*****家庭每月的总消费水平
*hh1ctot1m hh1ctot1m hh2ctot1m hh3ctot1m hh4ctot1m hh5ctot1m

*****家庭成员人数
*h1hhres h2hhres h3hhres h4hhres h5hhres

*****健在子女数
*h1child h2child h3child h4child h5child

*****健在儿子数
*h1son h2son h3son h4son h5son

*****健在女儿数
*h1dau h2dau h3dau h4dau h5dau

*****母亲是否还活着
*r1momliv r2momliv r3momliv r4momliv r5momliv
label values r1momliv r2momliv r3momliv r4momliv r5momliv yesno_

*****父亲是否还活着
*r1dadliv r2dadliv r3dadliv r4dadliv r5dadl
label values r1dadliv r2dadliv r3dadliv r4dadliv r5dadl yesno_

*****母亲的教育程度
*rameduc_m 
label define rameduc_m_ 1 "未完成任何正规教育" 2 "一些小学" 3 "小学" 4 "小学以上"
label values rameduc_m rameduc_m_

*****父亲的教育程度
*rafeduc_m
label define rafeduc_m_ 1 "未完成任何正规教育" 2 "一些小学" 3 "小学" 4 "小学以上"
label values rafeduc_m rafeduc_m_

*****是否有子女共同居住
*h1coresd h2coresd h3coresd h4coresd h5coresd
label values h1coresd h2coresd h3coresd h4coresd h5coresd yesno_

*****是否每周与亲戚朋友联系
*r3rfcnt r4rfcnt r5rfcnt
label values r3rfcnt r4rfcnt r5rfcnt yesno_

*****与亲朋好友联系的频率
*r3rfcntx_m r4rfcntx_m r5rfcntx_m
forvalues i=3/5 {
  recode r`i'rfcntx_m (1=9) (2=8) (3=7) (4=6) (5=5) (6=4) (7=3) (8=2) (9=1)
}
label define rfcntx_m_ 9 "几乎每天" 8 "每周四次以上" 7 "每周两三次" 6 "一周一次" ///
  5 "每月四次以上" 4 "每月两三次" 3 "每月一次" 2 "几乎从不/偶尔" 1 "从不"
label values r3rfcntx_m r4rfcntx_m r5rfcntx_m rfcntx_m_

*****是否每周参加这些社会活动
*r3socwk r4socwk r5socwk
label values r3socwk r4socwk r5socwk yesno_

*****参加社会活动的频率
*r3socact_m r4socact_m r5socact_m
forvalues i=3/5 {
  recode r`i'socact_m (1=9) (2=8) (3=7) (4=6) (5=5) (6=4) (7=3) (8=2) (9=1)
}
label define socact_m_ 9 "几乎每天" 8 "每周四次以上" 7 "每周两三次" 6 "一周一次" ///
  5 "每月四次以上" 4 "每月两三次" 3 "每月一次" 2 "几乎从不/偶尔" 1 "从不"
label values r3socact_m r4socact_m r5socact_m socact_m_

*****是否每周参加教会组织的活动
*r2relgwk r3relgwk r4relgwk r5relgwk
label values r2relgwk r3relgwk r4relgwk r5relgwk yesno_

*****过去两年是否从子女孙辈那里获得任何经济援助
*h1fcany h2fcany h3fcany h4fcany h5fcany
label values h1fcany h2fcany h3fcany h4fcany h5fcany yesno_

*****过去一年中从其子女/孙辈那里获得的总估算金融转移金额
*h1fcamt h2fcamt h3fcamt h4fcamt

*****过去两年内是否给予子女/孙辈任何经济帮助
*h2tcany h3tcany h4tcany h5tcany
label values h2tcany h3tcany h4tcany h5tcany yesno_

*****过去一年中给子女/孙辈的估算金融转移总额
*h1tcamt h2tcamt h3tcamt h4tcamt

*****过去两年内是否向其父母提供任何经济帮助
*r1tpany r2tpany r3tpany r4tpany r5tpany
label values r1tpany r2tpany r3tpany r4tpany r5tpany yesno_

*****过去两年中给父母的财务转移金额
*r1tpamt r2tpamt r3tpamt r4tpamt

*****是否正在工作
*r1work r2work r3work r4work r5work
label values r1work r2work r3work r4work r5work yesno_

*****是否自雇
*r1slfemp r2slfemp r3slfemp r4slfemp r5slfemp
label values r1slfemp r2slfemp r3slfemp r4slfemp r5slfemp yesno_

*****劳动力状态
*r1lbrf_m r2lbrf_m r3lbrf_m r4lbrf_m r5lbrf_m
label define lbrf_m_ 1 "工作" 2 "失业" 3 "退休" 4 "残疾" 5 "不处于劳动力状态" 6 "失业或退休或残疾" 
label values r1lbrf_m r2lbrf_m r3lbrf_m r4lbrf_m r5lbrf_m lbrf_m_

*****退休状况
*r2retemp r3retemp r4retemp r5retemp
label define retemp_ 0 "工作中" 1 "退休" 2 "处于其他状态并报告退休"
label values r2retemp r3retemp r4retemp r5retemp retemp_

*****退休年份
*r2retyr r3retyr r4retyr r5retyr

*****目前是否领取任何公共养老金
*r1pubpen r2pubpen r3pubpen r4pubpen r5pubpen
label values r1pubpen r2pubpen r3pubpen r4pubpen r5pubpen yesno_

*****目前是否正在领取私人养老金
*r1peninc r2peninc r3peninc r4peninc r5peninc
label values r1peninc r2peninc r3peninc r4peninc r5peninc yesno_

*****目前是否领取其他养老金
*r1open r2open r3open r4open r5open
label values r1open r2open r3open r4open r5open yesno_

*****测量的身高m
*r1mheight r2mheight r3mheight

*****是否愿意和能够完成身高测量
*r1htcomp r2htcomp r3htcomp
label values r1htcomp r2htcomp r3htcomp yesno_

*****测量的体重kg
*r1mweight r2mweight r3mweight

*****是否愿意和能够完成体重测量
*r1wtcomp r2wtcomp r3wtcomp
label values r1wtcomp r2wtcomp r3wtcomp yesno_

*****测量的BMI
*r1mbmi r2mbmi r3mbmi

*****BMI类别
*r1mbmicat r2mbmicat r3mbmicat
label define mbmicat_ 1 "体重不足" 2 "正常体重" 3 "肥胖前期" 4 "肥胖等级1" ///
  5 "肥胖等级2" 6 "肥胖3级" 
label values r1mbmicat r2mbmicat r3mbmicat mbmicat_

*****测量的腰围cm
*r1mwaist r2mwaist r3mwaist

*****是否愿意和能够完成腰围测量
*r1watcomp r2watcomp r3watcomp
label values r1watcomp r2watcomp r3watcomp yesno_

*****测量的臀围cm
*r1mhip r2mhip r3mhip

*****是否愿意和能够完成臀围测量
*r1hipcomp r2hipcomp r3hipcomp
label values r1hipcomp r2hipcomp r3hipcomp yesno_

*****测量的坐高cm
*r2sithght r3sithght

*****完成测量的椅子高度
*r2chairhght r3chairhght

*****是否愿意并且能够完成坐姿高度测量
*r2sthtcomp r3sthtcomp
label values r2sthtcomp r3sthtcomp yesno_

*****是否因为安全原因无法完成坐姿高度测量
*r2sthtsft r3sthtsft
label values r2sthtsft r3sthtsft yesno_

*****是否尝试完成坐姿高度测量但无法完成
*r2sthttryu r3sthttryu
label values r2sthttryu r3sthttryu yesno_

*****是否拒绝完成坐姿高度测量
*r2sthtref r3sthtref
label values r2sthtref r3sthtref yesno_

*****右脚平衡测试结果
*r1balrtsec r2balrtsec r3balrtsec

*****右脚是否至少完成了10秒的平衡测试
*r1balrt r2balrt r3balrt

*****是否愿意并能够完成右脚平衡测试
*r1balrtcomp r2balrtcomp r3balrtcomp
label values r1balrtcomp r2balrtcomp r3balrtcomp yesno_

*****左脚平衡测试结果
*r1ballfsec r2ballfsec r3ballfsec

*****左脚是否至少完成了10秒的左脚平衡测试
*r1ballf r2ballf r3ballf
label values r1ballf r2ballf r3ballf yesno_

*****是否愿意并能够完成左脚平衡测试
*r1ballfcomp r2ballfcomp r3ballfcomp
label values r1ballfcomp r2ballfcomp r3ballfcomp yesno_

*****是否因为安全原因无法完成平衡测试
*r1balsft r2balsft r3balsft
label values r1balsft r2balsft r3balsft yesno_

*****拒绝并没有试图完成平衡
*r1balref r2balref r3balref
label values r1balref r2balref r3balref yesno_

*****是否尝试完成平衡测试但无法完成
*r1baltryu r2baltryu r3baltryu
label values r1baltryu r2baltryu r3baltryu yesno_

*****第一次收缩压
*r3systo1

*****第二次收缩压
*r3systo2

*****收缩压的平均值
*r3systo

*****第一次舒张压
*r3diasto1

*****第二次舒张压
*r3diasto2

*****舒张压的平均值
*r3diasto

*****第一次脉冲
*r3pulse1

*****第二次脉冲
*r3pulse2

*****脉冲读数的平均值
*r3pulse

*****是否愿意并能够完成血压测量
*r3bpcomp
label values r3bpcomp yesno_

*****3米内的第一次步行速度测量值
*r3wspeed1

*****3米内的第二次步行速度测量值
*r3wspeed2

*****3米内的步行速度的平均值
*r3wspeed

*****是否愿意并且能够完成步行速度练习
*r3walkcomp
label values r3walkcomp yesno_

*****是否因为安全原因无法完成步行速度练习
*r3walksft
label values r3walksft yesno_

*****是否试图完成步行速度练习但无法完成
*r3walktryu
label values r3walktryu yesno_

*****是否拒绝完成步行速度练习
*r3walkref
label values r3walkref yesno_

*****是否因为其他原因没有完成步行速度练习
*r3walkothr
label values r3walkothr yesno_

*****右手第1次力量测量值
*r3rgrip1

*****右手第2次力量测量值
*r3rgrip2

*****右手力量测量值均值
*r3rgrip

*****左手第1次力量测量值
*r3lgrip1

*****左手第2次力量测量值
*r3lgrip2

*****左手力量测量均值
*r3lgrip

*****是否愿意并且能够完成手部力量测量
*r3gripcomp
label values r3gripcomp yesno_

*****是否因为安全原因无法完成手握测量
*r3gripsft
label values r3gripsft yesno_

*****是否拒绝完成手握测量
*r3gripref
label values r3gripref yesno_

*****是否因为其他原因没有完成手握测量
*r3gripothr
label values r3gripothr yesno_

*****CESD-9
*r1cesd_m r2cesd_m r3cesd_m r4cesd_m r5cesd_m

*****生活满意度
*r3satlife_m r4satlife_m r5satlife_m 
label define satlife_m_ 1 "同意" 2 "中立" 3 "不同意"
label values r3satlife_m r4satlife_m r5satlife_m  satlife_m_

*****生活满意度z评分
*r3satlifez r4satlifez r5satlifez

*****自评社会阶层
*r2cantril

keep h1atotb h2atotb h3atotb h4atotb h5atotb ///
h1child h2child h3child h4child h5child ///
h1coresd h2coresd h3coresd h4coresd h5coresd ///
h1dau h2dau h3dau h4dau h5dau ///
h1fcamt h2fcamt h3fcamt h4fcamt ///
h1fcany h2fcany h3fcany h4fcany h5fcany ///
h1hhres h2hhres h3hhres h4hhres h5hhres ///
h1hownrnt h2hownrnt h3hownrnt h4hownrnt h5hownrnt ///
h1itot h2itot h3itot h4itot h5itot ///
h1rural h3rural h4rural h5rural ///
h1son h2son h3son h4son h5son ///
h1tcamt h2tcamt h3tcamt h4tcamt ///
h2tcany h3tcany h4tcany h5tcany ///
hh1ctot1m hh1ctot1m hh2ctot1m hh3ctot1m hh4ctot1m hh5ctot1m ///
inw1 inw2 inw3 inw4 inw5 ///
r1adltot6 r2adltot6 r3adltot6 r4adltot6 r5adltot6 ///
r1armsa r2armsa r3armsa r4armsa r5armsa ///
r1arthre r2arthre r3arthre r4arthre r5arthre ///
r1ballf r2ballf r3ballf ///
r1ballfcomp r2ballfcomp r3ballfcomp ///
r1ballfsec r2ballfsec r3ballfsec ///
r1balref r2balref r3balref ///
r1balrt r2balrt r3balrt ///
r1balrtcomp r2balrtcomp r3balrtcomp ///
r1balrtsec r2balrtsec r3balrtsec ///
r1balsft r2balsft r3balsft ///
r1baltryu r2baltryu r3baltryu ///
r1batha r2batha r3batha r4batha r5batha ///
r1beda r2beda r3beda r4beda r5beda ///
r1binged r2binged r3binged r4binged r5binged ///
r1bmi r2bmi r3bmi r4bmi r5bmi ///
r1breast r2breast r3breast r4breast r5breast ///
r1breath_m r2breath_m r3breath_m r4breath_m r5breath_m ///
r1cancre r2cancre r3cancre r4cancre r5cancre ///
r1cesd_m r2cesd_m r3cesd_m r4cesd_m r5cesd_m ///
r1chaira r2chaira r3chaira r4chaira r5chaira ///
r1cholst r2cholst r3cholst r4cholst r5cholst ///
r1clim1a r2clim1a r3clim1a r4clim1a r5clim1a ///
r1climsa r2climsa r3climsa r4climsa r5climsa ///
r1cncrchem r2cncrchem r3cncrchem r4cncrchem r5cncrchem ///
r1cncrmeds r2cncrmeds r3cncrmeds r4cncrmeds r5cncrmeds ///
r1cncrothr r2cncrothr r3cncrothr r4cncrothr r5cncrothr ///
r1cncrradn r2cncrradn r3cncrradn r4cncrradn r5cncrradn ///
r1cncrsurg r2cncrsurg r3cncrsurg r4cncrsurg r5cncrsurg ///
r1covr_m r2covr_m r3covr_m r4covr_m r5covr_m ///
r1covs_m r2covs_m r3covs_m r4covs_m r5covs_m ///
r1dadliv r2dadliv r3dadliv r4dadliv r5dadl ///
r1ddraw2 r2ddraw2 ///
r1dentim1y r2dentim1y r3dentim1y r4dentim1y r5dentim1y ///
r1dentst1y r2dentst1y r3dentst1y r4dentst1y r5dentst1y ///
r1diabe r2diabe r3diabe r4diabe r5diabe ///
r1dimea r2dimea r3dimea r4dimea r5dimea ///
r1dlrc8 r2dlrc8 r3dlrc8 r4dlrc8 r5dlrc8 ///
r1doctim1y r2doctim1y r3doctim1y r4doctim1y r5doctim1y ///
r1doctor1y r2doctor1y r3doctor1y r4doctor1y r5doctor1y ///
r1dressa r2dressa r3dressa r4dressa r5dressa ///
r1drink r2drink r3drink r4drink r5drink ///
r1drinkb r2drinkb r3drinkb r4drinkb r5drinkb ///
r1drinkd r2drinkd r3drinkd r4drinkd r5drinkd ///
r1drinkn r2drinkn r3drinkn r4drinkn r5drinkn ///
r1eata r2eata r3eata r4eata r5eata ///
r1fall r2fall r3fall r4fall r5fall ///
r1fallinj r2fallinj r3fallinj r4fallinj r5fallinj ///
r1fallnum r2fallnum r3fallnum r4fallnum r5fallnum ///
r1fatigue r2fatigue r3fatigue r4fatigue r5fatigue ///
r1glasses r2glasses r3glasses r4glasses r5glasses ///
r1hearaid r2hearaid r3hearaid r4hearaid r5hearaid ///
r1hearing r2hearing r3hearing r4hearing r5hearing ///
r1height r2height r3height r4height r5height ///
r1henum r2henum r3henum r4henum r5henum ///
r1hibpe r2hibpe r3hibpe r4hibpe r5hibpe ///
r1higov r2higov r3higov r4higov r5higov ///
r1hip50e r2hip50e r3hip50e r4hip50e ///
r1hipcomp r2hipcomp r3hipcomp ///
r1hipriv r2hipriv r3hipriv r4hipriv r5hipriv ///
r1hosp1y r2hosp1y r3hosp1y r4hosp1y r5hosp1y ///
r1hrtatte r2hrtatte r3hrtatte r4hrtatte r5hrtatte ///
r1hspnit1y r2hspnit1y r3hspnit1y r4hspnit1y r5hspnit1y ///
r1htcomp r2htcomp r3htcomp ///
r1iadlfour r2iadlfour r3iadlfour r4iadlfour r5iadlfour ///
r1idraw2 r2idraw2 ///
r1iearn r2iearn r3iearn r4iearn r5iearn ///
r1imrc8 r2imrc8 r3imrc8 r4imrc8 r5imrc8 ///
r1iwm r2iwm r3iwm r4iwm r5iwm ///
r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat ///
r1iwy r2iwy r3iwy r4iwy r5iwy ///
r1joga r2joga r3joga r4joga r5joga ///
r1lbrf_m r2lbrf_m r3lbrf_m r4lbrf_m r5lbrf_m ///
r1lifta r2lifta r3lifta r4lifta r5lifta ///
r1mammog r2mammog r3mammog r4mammog r5mammog ///
r1mbmi r2mbmi r3mbmi ///
r1mbmicat r2mbmicat r3mbmicat ///
r1mealsa r2mealsa r3mealsa r4mealsa r5mealsa ///
r1medsa r2medsa r3medsa r4medsa r5medsa ///
r1mheight r2mheight r3mheight ///
r1mhip r2mhip r3mhip ///
r1momliv r2momliv r3momliv r4momliv r5momliv ///
r1moneya r2moneya r3moneya r4moneya r5moneya ///
r1mstath r2mstath r3mstath r4mstath r5mstath ///
r1mwaist r2mwaist r3mwaist ///
r1mweight r2mweight r3mweight ///
r1nopencil r2nopencil r3nopencil r4nopencil r5nopencil ///
r1novisual r2novisual r3novisual r4novisual r5novisual ///
r1oopden1y r2oopden1y r3oopden1y r4oopden1y r5oopden1y ///
r1oopdoc1y r2oopdoc1y r3oopdoc1y r4oopdoc1y r5oopdoc1y ///
r1oopfhho1y r2oopfhho1y r3oopfhho1y r4oopfhho1y ///
r1oophos1y r2oophos1y r3oophos1y r4oophos1y r5oophos1y ///
r1oopmd1y r2oopmd1y r3oopmd1y r4oopmd1y r5oopmd1y ///
r1ooposrg1y r2ooposrg1y r3ooposrg1y r4ooposrg1y r5ooposrg1y ///
r1open r2open r3open r4open r5open ///
r1outpt1y r2outpt1y r3outpt1y r4outpt1y r5outpt1y ///
r1paina r2paina r3paina r4paina r5paina ///
r1painfr r2painfr r3painfr r4painfr r5painfr ///
r1painlv r2painlv r3painlv r4painlv r5painlv ///
r1papsm r2papsm r3papsm r4papsm r5papsm ///
r1peninc r2peninc r3peninc r4peninc r5peninc ///
r1prost r2prost r3prost r4prost r5prost ///
r1proxy r2proxy r3proxy r4proxy r5proxy ///
r1pubpen r2pubpen r3pubpen r4pubpen r5pubpen ///
r1pusha r2pusha r3pusha r4pusha r5pusha ///
r1quitsmok r2quitsmok r3quitsmok r4quitsmok r5quitsmok ///
r1reccancr r2reccancr r3reccancr r4reccancr r5reccancr ///
r1rechrtatt r2rechrtatt r3rechrtatt r4rechrtatt r5rechrtatt ///
r1recstrok r2recstrok r3recstrok r4recstrok r5recstrok ///
r1respe r2respe r3respe r4respe r5respe ///
r1rxarthr r2rxarthr r3rxarthr r4rxarthr r5rxarthr ///
r1rxdiab r2rxdiab r3rxdiab r4rxdiab r5rxdiab ///
r1rxdiabi r2rxdiabi r3rxdiabi r4rxdiabi r5rxdiabi ///
r1rxdiabo r2rxdiabo r3rxdiabo r4rxdiabo r5rxdiabo ///
r1rxhibp r2rxhibp r3rxhibp r4rxhibp r5rxhibp ///
r1rxhrtat r2rxhrtat r3rxhrtat r4rxhrtat r5rxhrtat ///
r1rxresp r2rxresp r3rxresp r4rxresp r5rxresp ///
r1rxstrok r2rxstrok r3rxstrok r4rxstrok r5rxstrok ///
r1shlt r2shlt r3shlt r4shlt r5shlt ///
r1shopa r2shopa r3shopa r4shopa r5shopa ///
r1sight r2sight r3sight r4sight r5sight ///
r1sita r2sita r3sita r4sita r5sita ///
r1slfemp r2slfemp r3slfemp r4slfemp r5slfemp ///
r1smokef r2smokef r3smokef r4smokef r5smokef ///
r1smoken r2smoken r3smoken r4smoken r5smoken ///
r1smokev r2smokev r3smokev r4smokev r5smokev ///
r1stoopa r2stoopa r3stoopa r4stoopa r5stoopa ///
r1stroke r2stroke r3stroke r4stroke r5stroke ///
r1strtsmok r2strtsmok r3strtsmok r4strtsmok r5strtsmok ///
r1swell r2swell r3swell r4swell r5swell ///
r1toilta r2toilta r3toilta r4toilta r5toilta ///
r1tpamt r2tpamt r3tpamt r4tpamt ///
r1tpany r2tpany r3tpany r4tpany r5tpany ///
r1tr16 r2tr16 r3tr16 r4tr16 r5tr16 ///
r1urina2y r2urina2y ///
r1vigact r2vigact r3vigact r4vigact r5vigact ///
r1vscan r2vscan r3vscan r4vscan r5vscan ///
r1walk1a r2walk1a r3walk1a r4walk1a r5walk1a ///
r1walkra r2walkra r3walkra r4walkra r5walkra ///
r1walksa r2walksa r3walksa r4walksa r5walksa ///
r1watcomp r2watcomp r3watcomp ///
r1weight r2weight r3weight r4weight r5weight ///
r1wheeze r2wheeze ///
r1work r2work r3work r4work r5work ///
r1wtcomp r2wtcomp r3wtcomp ///
r2cantril ///
r2chairhght r3chairhght ///
r2dy r3dy r4dy ///
r2mo r3mo r4mo ///
r2orient_m r3orient_m r4orient_m ///
r2relgwk r3relgwk r4relgwk r5relgwk ///
r2retemp r3retemp r4retemp r5retemp ///
r2retyr r3retyr r4retyr r5retyr ///
r2sithght r3sithght ///
r2sthtcomp r3sthtcomp ///
r2sthtref r3sthtref ///
r2sthtsft r3sthtsft ///
r2sthttryu r3sthttryu ///
r2yr r3yr r4yr ///
r3agey r4agey r5agey ///
r3bpcomp ///
r3bwc20 r4bwc20 ///
r3bwc20_m r4bwc20_m ///
r3ddraw1 r4ddraw1 r5ddraw1 ///
r3diasto ///
r3diasto1 ///
r3diasto2 ///
r3flusht r4flusht r5flusht ///
r3gripcomp ///
r3gripothr ///
r3gripref ///
r3gripsft ///
r3hip_m r4hip_m r5hip_m ///
r3idraw1 r4idraw1 r5idraw1 ///
r3lgrip ///
r3lgrip1 ///
r3lgrip2 ///
r3pulse ///
r3pulse1 ///
r3pulse2 ///
r3rested r4rested r5rested ///
r3rfcnt r4rfcnt r5rfcnt ///
r3rfcntx_m r4rfcntx_m r5rfcntx_m ///
r3rgrip ///
r3rgrip1 ///
r3rgrip2 ///
r3satlife_m r4satlife_m r5satlife_m  ///
r3satlifez r4satlifez r5satlifez ///
r3slfmem r4slfmem r5slfmem ///
r3socact_m r4socact_m r5socact_m ///
r3socwk r4socwk r5socwk ///
r3systo ///
r3systo1 ///
r3systo2 ///
r3urincgh2y r4urincgh2y r5urincgh2y ///
r3urinurg2y r4urinurg2y r5urinurg2y ///
r3verbf r4verbf r5verbf ///
r3walkcomp ///
r3walkothr ///
r3walkref ///
r3walksft ///
r3walktryu ///
r3wspeed ///
r3wspeed1 ///
r3wspeed2 ///
r4fallslp r5fallslp ///
r4hearte r5hearte ///
r4hystere r5hystere ///
r4lstmnspd r5lstmnspd ///
r4ser7 r5ser7 ///
r4wakent r5wakent ///
r4wakeup r5wakeup ///
r5hip ///
rabmonth ///
rabyear ///
radmonth ///
radyear ///
raeducl ///
raedyrs ///
rafeduc_m ///
ragender ///
rahhidnp ///
raliterate ///
rameduc_m  ///
ranumerate ///
h1hhidc h2hhidc h3hhidc h4hhidc h5hhidc


reshape long h@atotb h@child h@coresd h@dau h@fcamt h@fcany h@hhres h@hownrnt h@itot ///
 h@rural h@son h@tcamt h@tcany hh@ctot1m inw@ r@adltot6 r@armsa r@arthre r@ballf /// 
 r@ballfcomp r@ballfsec r@balref r@balrt r@balrtcomp r@balrtsec r@balsft  ///
 r@baltryu r@batha r@beda r@binged r@bmi r@breast r@breath_m r@cancre r@cesd_m  ///
 r@chaira r@cholst r@clim1a r@climsa r@cncrchem r@cncrmeds r@cncrothr r@cncrradn /// 
 r@cncrsurg r@covr_m r@covs_m r@dadliv r@ddraw2 r@dentim1y r@dentst1y r@diabe /// 
 r@dimea r@dlrc8 r@doctim1y r@doctor1y r@dressa r@drink r@drinkb r@drinkd r@drinkn  ///
 r@eata r@fall r@fallinj r@fallnum r@fatigue r@glasses r@hearaid r@hearing r@height /// 
 r@henum r@hibpe r@higov r@hip50e r@hipcomp r@hipriv r@hosp1y r@hrtatte r@hspnit1y /// 
 r@htcomp r@iadlfour r@idraw2 r@iearn r@imrc8 r@iwm r@iwstat r@iwy r@joga r@lbrf_m /// 
 r@lifta r@mammog r@mbmi r@mbmicat r@mealsa r@medsa r@mheight r@mhip r@momliv /// 
 r@moneya r@mstath r@mwaist r@mweight r@nopencil r@novisual r@oopden1y r@oopdoc1y  ///
 r@oopfhho1y r@oophos1y r@oopmd1y r@ooposrg1y r@open r@outpt1y r@paina r@painfr  ///
 r@painlv r@papsm r@peninc r@prost r@proxy r@pubpen r@pusha r@quitsmok r@reccancr /// 
 r@rechrtatt r@recstrok r@respe r@rxarthr r@rxdiab r@rxdiabi r@rxdiabo r@rxhibp  ///
 r@rxhrtat r@rxresp r@rxstrok r@shlt r@shopa r@sight r@sita r@slfemp r@smokef  ///
 r@smoken r@smokev r@stoopa r@stroke r@strtsmok r@swell r@toilta r@tpamt r@tpany  ///
 r@tr16 r@urina2y r@vigact r@vscan r@walk1a r@walkra r@walksa r@watcomp r@weight /// 
 r@wheeze r@work r@wtcomp r@cantril r@chairhght r@dy r@mo r@orient_m r@relgwk  ///
 r@retemp r@retyr r@sithght r@sthtcomp r@sthtref r@sthtsft r@sthttryu r@yr r@agey  ///
 r@bpcomp r@bwc20 r@bwc20_m r@ddraw1 r@diasto r@diasto1 r@diasto2 r@flusht r@gripcomp  ///
 r@gripothr r@gripref r@gripsft r@hip_m r@idraw1 r@lgrip r@lgrip1 r@lgrip2 r@pulse  ///
 r@pulse1 r@pulse2 r@rested r@rfcnt r@rfcntx_m r@rgrip r@rgrip1 r@rgrip2 r@satlife_m  ///
 r@satlifez r@slfmem r@socact_m r@socwk r@systo r@systo1 r@systo2 r@urincgh2y  ///
 r@urinurg2y r@verbf r@walkcomp r@walkothr r@walkref r@walksft r@walktryu r@wspeed  ///
 r@wspeed1 r@wspeed2 r@fallslp r@hearte r@hystere r@lstmnspd r@ser7 r@wakent  ///
 r@wakeup r@hip h@hhidc,i(rahhidnp) j(wave)

rename (rahhidnp wave inw riwstat rproxy riwm riwy rabyear rabmonth radyear /// 
radmonth ragey ragender raedyrs raeducl raliterate ranumerate rmstath hrural  ///
rshlt rwalkra rdressa rbatha reata rbeda rtoilta rmoneya rmedsa rshopa rmealsa  ///
rwalksa rjoga rwalk1a rsita rchaira rclimsa rclim1a rstoopa rlifta rdimea rarmsa /// 
rpusha radltot6 riadlfour rhibpe rdiabe rcancre rrespe rhrtatte rhearte rstroke  ///
rarthre rrxhibp rrxdiabo rrxdiabi rrxdiab rcncrchem rcncrsurg rcncrradn rcncrmeds /// 
rcncrothr rrxresp rrxhrtat rrxstrok rrxarthr rreccancr rrechrtatt rrecstrok  ///
rsight rglasses rhearing rhearaid rfall rfallnum rfallinj rhip_m rhip rurinurg2y  ///
rurincgh2y rswell rbreath_m rfatigue rfallslp rwakent rwakeup rrested rpainfr  ///
rpainlv rpaina rhystere rlstmnspd rbmi rweight rheight rvigact rdrink rdrinkd /// 
rdrinkn rdrinkb rbinged rsmokev rsmoken rsmokef rstrtsmok rquitsmok rcholst  ///
rflusht rbreast rmammog rpapsm rprost rhosp1y rhspnit1y rdoctor1y rdoctim1y /// 
routpt1y rdentst1y rdentim1y roophos1y roopden1y rooposrg1y roopdoc1y roopmd1y /// 
rhigov rhipriv rcovr_m rcovs_m rhenum rnovisual rnopencil rslfmem rimrc8 rdlrc8  ///
rtr16 ridraw1 rddraw1 rverbf rvscan rser7 hhownrnt hatotb riearn hitot hhctot1m /// 
hhhres hchild hson hdau rmomliv rdadliv rameduc_m rafeduc_m hcoresd rrfcnt  ///
rrfcntx_m rsocwk rsocact_m rrelgwk hfcany htcany rtpany rwork rslfemp rlbrf_m  ///
rretemp rretyr rpubpen rpeninc ropen rcesd_m rsatlife_m rsatlifez hfcamt htcamt  ///
rballf rballfcomp rballfsec rbalref rbalrt rbalrtcomp rbalrtsec rbalsft rbaltryu /// 
rddraw2 rhip50e rhipcomp rhtcomp ridraw2 rmbmi rmbmicat rmheight rmhip rmwaist  ///
rmweight roopfhho1y rtpamt rurina2y rwatcomp rwheeze rwtcomp rcantril rchairhght ///
rdy rmo rorient_m rsithght rsthtcomp rsthtref rsthtsft rsthttryu ryr rbpcomp  ///
rbwc20 rbwc20_m rdiasto rdiasto1 rdiasto2 rgripcomp rgripothr rgripref rgripsft  ///
rlgrip rlgrip1 rlgrip2 rpulse rpulse1 rpulse2 rrgrip rrgrip1 rrgrip2 rsysto /// 
rsysto1 rsysto2 rwalkcomp rwalkothr rwalkref rwalksft rwalktryu rwspeed ///
rwspeed1 rwspeed2 hhhidc) ///
(rahhidnp wave inw iwstat proxy iwm iwy rabyear rabmonth radyear /// 
radmonth agey ragender raedyrs raeducl raliterate ranumerate mstath rural  ///
shlt walkra dressa batha eata beda toilta moneya medsa shopa mealsa  ///
walksa joga walk1a sita chaira climsa clim1a stoopa lifta dimea armsa /// 
pusha adltot6 iadlfour hibpe diabe cancre respe hrtatte hearte stroke  ///
arthre rxhibp rxdiabo rxdiabi rxdiab cncrchem cncrsurg cncrradn cncrmeds /// 
cncrothr rxresp rxhrtat rxstrok rxarthr reccancr rechrtatt recstrok  ///
sight glasses hearing hearaid fall fallnum fallinj hip_m hip urinurg2y  ///
urincgh2y swell breath_m fatigue fallslp wakent wakeup rested painfr  ///
painlv paina hystere lstmnspd bmi weight height vigact drink drinkd /// 
drinkn drinkb binged smokev smoken smokef strtsmok quitsmok cholst  ///
flusht breast mammog papsm prost hosp1y hspnit1y doctor1y doctim1y /// 
outpt1y dentst1y dentim1y oophos1y oopden1y ooposrg1y oopdoc1y oopmd1y /// 
higov hipriv covr_m covs_m henum novisual nopencil slfmem imrc8 dlrc8  ///
tr16 idraw1 ddraw1 verbf vscan ser7 hownrnt atotb iearn itot ctot1m /// 
hhres child son dau momliv dadliv rameduc_m rafeduc_m coresd rfcnt  ///
rfcntx_m socwk socact_m relgwk fcany tcany tpany work slfemp lbrf_m  ///
retemp retyr pubpen peninc open cesd_m satlife_m satlifez fcamt tcamt  ///
ballf ballfcomp ballfsec balref balrt balrtcomp balrtsec balsft baltryu /// 
ddraw2 hip50e hipcomp htcomp idraw2 mbmi mbmicat mheight mhip mwaist  ///
mweight oopfhho1y tpamt urina2y watcomp wheeze wtcomp cantril chairhght ///
dy mo orient_m sithght sthtcomp sthtref sthtsft sthttryu yr bpcomp  ///
bwc20 bwc20_m diasto diasto1 diasto2 gripcomp gripothr gripref gripsft  ///
lgrip lgrip1 lgrip2 pulse pulse1 pulse2 rgrip rgrip1 rgrip2 systo /// 
systo1 systo2 walkcomp walkothr walkref walksft walktryu wspeed ///
wspeed1 wspeed2 hhidc)


label var adltot6 "ADL总分(6项)"
label var agey "年龄"
label var armsa "其他限制/手臂超过肩膀"
label var arthre "医生是否诊断曾经或目前患有关节炎或风湿病"
label var atotb "家庭的总财富"
label var ballf "左脚完成了至少10秒的平衡测试"
label var ballfcomp "是否愿意并能够完成左脚平衡测试"
label var ballfsec "左脚平衡测试结果"
label var balref "拒绝并没有试图完成平衡"
label var balrt "是否用右脚完成了至少10秒的平衡测试"
label var balrtcomp "是否愿意并能够完成右脚平衡测试"
label var balrtsec "右脚平衡测试结果"
label var balsft "是否因为安全原因无法完成平衡测试"
label var baltryu "是否尝试完成平衡测试但无法完成"
label var batha "ADL/洗澡是否困难"
label var beda "ADL/上下床是否困难"
label var binged "过去3个月内酗酒的天数"
label var bmi "自我报告BMI"
label var bpcomp "是否愿意并能够完成血压测量"
label var breast "过去两年内是否每月乳房自我检查"
label var breath_m "过去2年内躺下时是否感到呼吸困难"
label var bwc20 "认知/倒算得分"
label var bwc20_m "认知/是否能够成功地从20开始连续倒数10个数"
label var cancre "医生是否诊断曾经或目前患有癌症"
label var cantril "自评社会阶层"
label var cesd_m "CESD-9"
label var chaira "其他限制/长时间坐着从椅子上站起来"
label var chairhght "完成测量的椅子高度"
label var child "健在子女数"
label var cholst "过去两年内血液胆固醇检查"
label var clim1a "其他限制/不休息地爬一段楼梯"
label var climsa "其他限制/不休息地爬几段楼梯"
label var cncrchem "是否接受化疗或药物治疗癌症"
label var cncrmeds "是否接受了治疗癌症的药物或治疗症状(疼痛、恶心、皮疹)"
label var cncrothr "是否接受过另一种未指明的癌症治疗"
label var cncrradn "是否接受过放射或x射线治疗癌症"
label var cncrsurg "是否接受过手术或活检以治疗癌症"
label var coresd "是否有子女共同居住"
label var covr_m "是否因为是工人或曾经是工人而享有健康保险"
label var covs_m "是否因为其配偶是或曾经是工人而获得医疗保险"
label var ctot1m "家庭每月的总消费水平"
label var dadl "父亲是否还活着"
label var dau "健在女儿数"
label var ddraw1 "认知/延迟视觉空间任务得分1"
label var ddraw2 "认知/延迟视觉空间任务得分2"
label var dentim1y "过去12个月报告的牙科就诊总数"
label var dentst1y "过去12个月内是否报告至少一次牙科就诊"
label var diabe "医生是否诊断曾经或目前患有高血压"
label var diabe "医生是否诊断曾经或目前患有糖尿病或高血糖"
label var diasto "舒张压的平均值"
label var diasto1 "第一次舒张压"
label var diasto2 "第二次舒张压"
label var dimea "其他限制/从桌子上捡起一枚小硬币"
label var dlrc8 "认知/单词延迟回忆"
label var doctim1y "过去12个月报告的就诊次数"
label var doctim1y "过去12个月内是否至少看过一次医生"
label var dressa "ADL/穿衣是否困难"
label var drink "是否喝过酒"
label var drinkb "是否曾经酗酒"
label var drinkd "每周饮酒的天数"
label var drinkn "喝酒的数量"
label var dy "认知/是否能够正确地报告日"
label var eata "ADL/吃饭是否困难"
label var fall "最近2年内是否跌倒过"
label var fallinj "是否曾因跌倒而严重受伤需要接受治疗"
label var fallnum "摔倒的次数(过去2年)"
label var fallslp "入睡困难的频率"
label var fatigue "是否经历过严重的疲劳或疲惫"
label var fcamt "过去一年中从其子女/孙辈那里获得的总估算金融转移金额"
label var fcany "过去两年是否从子女孙辈那里获得任何经济援助"
label var flusht "过去两年内是否流感疫苗"
label var glasses "是否经常戴眼镜"
label var gripcomp "是否愿意并且能够完成手部力量测量"
label var gripothr "是否因为其他原因没有完成手握测量"
label var gripref "是否拒绝完成手握测量"
label var gripsft "是否因为安全原因无法完成手握测量"
label var hearaid "是否经常佩戴助听器"
label var hearing "自评听力"
label var hearte "医生是否诊断曾经或目前患有心脏疾病"
label var height "自我报告身高m"
label var henum "参加的健康保险计划的数量"
label var hhres "家庭成员人数"
label var higov "是否被任何政府健康保险计划所覆盖"
label var hip "过去两年内是否髋部骨折"
label var hip_m "过去两年中是否骨折(包括髋部)"
label var hip50e "50岁生日之后是否有过骨折，包括髋部骨折"
label var hipcomp "是否愿意和能够完成臀围测量"
label var hipriv "是否有任何私人医疗健康保险"
label var hosp1y "过去12个月内是否至少有一次过夜住院"
label var hownrnt "房屋所有权"
label var hrtatte "医生是否诊断曾经或目前患有心脏病发作"
label var hspnit1y "过去12个月内所有住院的总过夜数"
label var htcomp "是否愿意和能够完成身高测量"
label var hystere "是否曾经做过子宫切除术"
label var iadlfour "IADL总分(4项)"
label var idraw1 "认知/视觉空间任务得分1"
label var idraw2 "认知/视觉空间任务得分2"
label var iearn "夫妻每年的个人收入"
label var imrc8 "认知/单词即时回忆"
label var inw "是否参与本次调查"
label var itot "夫妻总收入"
label var iwm "受访月份"
label var iwstat "是否死亡"
label var iwy "受访年份"
label var joga "其他限制/跑步和慢跑一公里"
label var lbrf_m "劳动力状态"
label var lgrip "左手力量测量均值"
label var lgrip1 "左手第1次力量测量值"
label var lgrip2 "左手第2次力量测量值"
label var lifta "其他限制/举起或搬运超过5公斤的重物"
label var lstmnspd "最后一次月经的年龄"
label var mammog "过去两年内是否乳房x光检查"
label var mbmi "测量的BMI"
label var mbmicat "BMI类别"
label var mealsa "IADL/准备饭菜是否困难"
label var medsa "IADL/管理金钱是否困难"
label var mheight "测量的身高m"
label var mhip "测量的臀围cm"
label var mo "认知/是否能够正确地报告月"
label var momliv "母亲是否还活着"
label var moneya "IADL/日常生活工具活动是否困难"
label var mstath "婚姻状况"
label var mwaist "测量的腰围cm"
label var mweight "测量的体重kg"
label var nopencil "认知/是否报告握住铅笔有任何问题"
label var novisual "认知/视觉问题"
label var oopden1y "过去12个月牙医自费支出"
label var oopdoc1y "过去12个月医生自付费用的总额"
label var oopfhho1y "过去12个月民间疗法自费支出"
label var oophos1y "过去12个月的自付住院费用"
label var oopmd1y "过去12个月的自付医疗支出总额"
label var ooposrg1y "过去12个月的门诊手术自费支出"
label var open "目前是否领取其他养老金"
label var orient_m "认知/是否能够正确地报告日"
label var outpt1y "过去12个月内是否报告至少一次门诊手术"
label var paina "疼痛是否干扰了日常活动"
label var painfr "是否感到疼痛"
label var painlv "疼痛程度"
label var papsm "过去两年内是否子宫颈抹片检查"
label var peninc "目前是否正在领取私人养老金"
label var prost "过去两年内是否前列腺癌检查"
label var proxy "是否代理回答"
label var pubpen "目前是否领取任何公共养老金"
label var pulse "脉冲读数的平均值"
label var pulse1 "第一次脉冲"
label var pulse2 "第二次脉冲"
label var pusha "其他限制/推或拉大型物体"
label var quitsmok "戒烟的年龄"
label var rabmonth "出生月份"
label var rabyear "出生年份"
label var radmonth "死亡月份"
label var radyear "死亡年份"
label var raeducl "统一可比的教育程度"
label var raedyrs "受教育年限"
label var rafeduc_m "父亲的教育程度"
label var ragender "性别"
label var rahhidnp "个人标识符"
label var raliterate "是否能够读写"
label var rameduc_m "母亲的教育程度"
label var ranumerate "是否能够从1数到10"
label var reccancr "最近被诊断出患有癌症的年龄"
label var rechrtatt "最近一次心脏病发作的年龄"
label var recstrok "最近中风的年龄"
label var relgwk "是否每周参加教会组织的活动
label var respe "医生是否诊断曾经或目前患有呼吸系统疾病"
label var rested "醒来时感到精力充沛的频率"
label var retemp "退休状况"
label var retyr "退休年份"
label var rfcnt "是否每周与亲戚朋友联系"
label var rfcntx_m "与亲朋好友联系的频率"
label var rgrip "右手力量测量值均值"
label var rgrip1 "右手第1次力量测量值"
label var rgrip2 "右手第2次力量测量值"
label var rural "家庭居住在城市还是农村"
label var rxarthr "是否服用关节炎药物"
label var rxdiab "是否使用任何治疗糖尿病的药物(口服药物或胰岛素注射)"
label var rxdiabi "是否使用胰岛素注射治疗糖尿病"
label var rxdiabo "是否口服糖尿病药物"
label var rxhibp "是否服用高血压药物"
label var rxhrtat "是否因心脏病发作而服用药物"
label var rxresp "是否服用呼吸系统疾病的药物，如哮喘或肺气肿"
label var rxstrok "是否服用中风药物"
label var satlife_m "生活满意度"
label var satlifez "生活满意度z评分"
label var ser7 "正确减法的个数"
label var shlt "自评健康"
label var shopa "IADL/购买杂货是否困难"
label var sight "自评的视力"
label var sita "其他限制/坐约2小时"
label var sithght "测量的坐高cm"
label var slfemp "是否自雇"
label var slfmem "自我报告的记忆"
label var smokef "每天通常吸烟的数量"
label var smoken "目前是否吸烟"
label var smokev "是否吸过烟"
label var socact_m "参加社会活动的频率"
label var socwk "是否每周参加这些社会活动"
label var son "健在儿子数"
label var sthtcomp "是否愿意并且能够完成坐姿高度测量"
label var sthtref "是否拒绝完成坐姿高度测量"
label var sthttryu "是否尝试完成坐姿高度测量但无法完成"
label var stoopa "其他限制/弯腰跪下或蹲伏"
label var stroke "医生是否诊断曾经或目前患有中风"
label var strtsmok "开始吸烟的年龄"
label var swell "过去2年内是否经历过脚或脚踝的持续肿胀"
label var systo "收缩压的平均值"
label var systo1 "第一次收缩压"
label var systo2 "第二次收缩压"
label var tcamt "过去一年中给子女/孙辈的估算金融转移总额"
label var tcany "过去两年内是否给予子女/孙辈任何经济帮助"
label var sthtsft "是否因为安全原因无法完成坐姿高度测量"
label var toilta "ADL/上厕所是否困难"
label var tpamt "过去两年中给父母的财务转移金额"
label var tpany "过去两年内是否向其父母提供任何经济帮助"
label var tr16 "认知/单词总分"
label var urina2y "过去2年内是否有过尿失禁"
label var urincgh2y "有尿意但不能及时到达洗手间时是否出现过尿失禁"
label var urinurg2y "过去2年是否在咳嗽打喷嚏时失禁"
label var verbf "认知/语言流利度"
label var vigact "过去两年中是否每周参加三次或以上的剧烈活动"
label var vscan "认知/视觉扫描评分"
label var wakent "夜间醒来的频率"
label var wakeup "醒得太早而无法再入睡的频率"
label var walk1a "其他限制/步行一个街区"
label var walkcomp "是否愿意并且能够完成步行速度练习"
label var walkothr "是否因为其他原因没有完成步行速度练习"
label var walkra "ADL/在房间里走动是否困难"
label var walkref "是否拒绝完成步行速度练习"
label var walksa "其他限制/步行几个街区"
label var walksft "是否因为安全原因无法完成步行速度练习"
label var walktryu "是否试图完成步行速度练习但无法完成"
label var watcomp "是否愿意和能够完成腰围测量"
label var weight "自我报告体重kg"
label var wheeze "是否经历过持续的喘息或咳嗽或带痰"
label var work "是否正在工作"
label var wspeed "3米内的步行速度的平均值"
label var wspeed1 "3米内的第一次步行速度测量值"
label var wspeed2 "3米内的第二次步行速度测量值"
label var wtcomp "是否愿意和能够完成体重测量"
label var yr "认知/是否能够正确地报告年"
label var hibpe "医生是否诊断曾经或目前患有高血压"
label define wave_ 1 "第1轮" 2 "第2轮" 3 "第3轮" 4 "第4轮" 5 "第5轮"
label values wave wave_
label var wave "第几次调查"
label var hhidc "家庭标识符"

*****所有缺失值类型转为.
mvencode _all, mv(-999.99) 
mvdecode _all, mv(-999.99)

*****保留参与受访的个体
keep if inw==1

*****final sort
sort rahhidnp

*****compress dataset
compress	

*****add label
label data "Shawn老师 @丁点帮你"

*****add notes
notes drop _dta
note: Shawn老师->微信公众账号@丁点帮你
save "$working_data/mhas.dta",replace























