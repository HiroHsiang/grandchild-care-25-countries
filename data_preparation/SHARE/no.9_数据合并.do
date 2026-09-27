
clear all
set more off
set maxvar 120000
global root= "E:/SHARE_欧洲"
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

use "E:/SHARE_欧洲/Raw_data/Harmonized SHARE/H_SHARE_f2.dta", clear
*use "E:/SHARE_欧洲/Raw_data/Harmonized SHARE/H_SHARE_备用.dta",clear
merge 1:1 mergeid using "$temp_data/share_wave1_temp.dta",nogen nolabel
merge 1:1 mergeid using "$temp_data/share_wave2_temp.dta",nogen nolabel
merge 1:1 mergeid using "$temp_data/share_wave4_temp.dta",nogen nolabel
merge 1:1 mergeid using "$temp_data/share_wave5_temp.dta",nogen nolabel
merge 1:1 mergeid using "$temp_data/share_wave6_temp.dta",nogen nolabel
merge 1:1 mergeid using "$temp_data/share_wave7_temp.dta",nogen nolabel
merge 1:1 mergeid using "$temp_data/share_wave8_temp.dta",nogen nolabel
label drop _all

*****家庭标识符和个人标识符
*mergeid

*****家庭标识符
*hh1hhidc hh2hhidc hh3hhidc hh4hhidc hh5hhidc hh6hhidc hh7hhidc hh8hhidc

*****所在的国家
*country
label define country_ 11 "奥地利" 12 "德国" 13 "瑞典" 14 "荷兰" 15 "西班牙" 16 "意大利" ///
  17 "法国" 18 "丹麦" 19 "希腊" 20 "瑞士" 23 "比利时" 25 "以色列" 28 "捷克共和国" 29 "波兰" ///
  30 "爱尔兰" 31 "卢森堡" 32 "匈牙利" 33"葡萄牙"  34 "斯洛文尼亚"  35 "爱沙尼亚" ///
  43 "斯洛文尼亚" 47 "克罗地亚" 48 "立陶宛" 51 "保加利亚"  53 "塞浦路斯" 55 "芬兰" ///
  57 "拉脱维亚" 59 "马耳他" 61 "罗马尼亚" 63 "斯洛伐克"
label values country country_

*****是否参与本次调查
*inw1 inw2 inw4 inw5 inw6 inw7 inw8
label define yesno_ 1 "是" 0 "否"
label values inw1 inw2 inw4 inw5 inw6 inw7 inw8 yesno_

*****是否死亡
*r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat r6iwstat r7iwstat r8iwstat
foreach i in 1 2 4 5 6 7 8 {
  recode r`i'iwstat (0 1 4=0) (5 6=1) (9=.) 
}
label values r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat r6iwstat r7iwstat r8iwstat yesno_

*****受访时间
*r1iwm r2iwm r4iwm r5iwm r6iwm r7iwm r8iwm
*r1iwy r2iwy r4iwy r5iwy r6iwy r7iwy r8iwy

*****出生年份
*rabyear rabmonth

*****死亡年月
*radyear radmonth

*****年龄
*r1agey r2agey r4agey r5agey r6agey r7agey r8agey

*****性别
*ragender
recode ragender (1=1) (2=0)
label define ragender_ 1 "男性" 0 "女性"
label values ragender ragender_

*****教育年限
*raedyrs

*****国际教育标准分类
*raedisced
label define raedisced_ 0 "没有" 1 "初等教育" 2 "初中教育" 3 "高中教育" 4 "非高等教育后期阶段" ///
  5 "第一阶段的高等教育" 6 "第二阶段的高等教育" 
label values raedisced raedisced_

*****统一可比的教育程度
*raeducl
label define raeducl_ 1 "高中以下学历"  2 "高中和职业培训" 3 "高等教育"
label values raeducl raeducl_ 

*****婚姻状况
*r1mstath r2mstath r4mstath r5mstath r6mstath r7mstath r8mstath
label define mstath_ 1 "已婚" 3 "注册伴侣关系" 4 "分居" 5 "离婚" 7 "丧偶" 8 "从未结婚"
label values r1mstath r2mstath r4mstath r5mstath r6mstath r7mstath r8mstath mstath_

*****是否本国公民
*racitizen
label values racitizen yesno_

*****宗教
*rarelig
label define rarelig_ 1 "新教" 2 "天主教" 3 "犹太人" 4 "没有/不偏好" 5 "其他" 7 "穆斯林" 8 "正教会"
label values rarelig rarelig_

*****家庭居住在城市还是农村地区
*h1rural h2rural h4rural h5rural h6rural h7rural h8rural
label define rural_ 1 "农村" 0 "城市"
label values h1rural h2rural h4rural h5rural h6rural h7rural h8rural rural_

*****自评健康
*r1shlt r2shlt r4shlt r5shlt r6shlt r7shlt r8shlt
foreach i in 1 2 4 5 6 7 8 {
  recode r`i'shlt (1=5) (2=4) (3=3) (4=2) (5=1)
}
label define shlt_ 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好"
label values r1shlt r2shlt r4shlt r5shlt r6shlt r7shlt r8shlt shlt_

*****ADL/房间里行走是否困难
*r1walkra r2walkra r4walkra r5walkra r6walkra r7walkra r8walkra
label values r1walkra r2walkra r4walkra r5walkra r6walkra r7walkra r8walkra yesno_

*****ADL/穿衣是否困难
*r1dressa r2dressa r4dressa r5dressa r6dressa r7dressa r8dressa
label values r1dressa r2dressa r4dressa r5dressa r6dressa r7dressa r8dressa yesno_

*****ADL/洗澡是否困难
*r1batha r2batha r4batha r5batha r6batha r7batha r8batha
label values r1batha r2batha r4batha r5batha r6batha r7batha r8batha yesno_

*****ADL/吃饭是否困难
*r1eata r2eata r4eata r5eata r6eata r7eata r8eata
label values r1eata r2eata r4eata r5eata r6eata r7eata r8eata yesno_

*****ADL/上下床是否困难
*r1beda r2beda r4beda r5beda r6beda r7beda r8beda
label values r1beda r2beda r4beda r5beda r6beda r7beda r8beda yesno_

*****ADL/上厕所是否困难
*r1toilta r2toilta r4toilta r5toilta r6toilta r7toilta r8toilta
label values r1toilta r2toilta r4toilta r5toilta r6toilta r7toilta r8toilta yesno_

*****IADL/使用电话是否困难
*r1phonea r2phonea r4phonea r5phonea r6phonea r7phonea r8phonea
label values r1phonea r2phonea r4phonea r5phonea r6phonea r7phonea r8phonea yesno_

*****IADL/服用药物是否困难
*r1medsa r2medsa r4medsa r5medsa r6medsa r7medsa r8medsa
label values r1medsa r2medsa r4medsa r5medsa r6medsa r7medsa r8medsa yesno_

*****IADL/理财是否困难
*r1moneya r2moneya r4moneya r5moneya r6moneya r7moneya r8moneya
label values r1moneya r2moneya r4moneya r5moneya r6moneya r7moneya r8moneya yesno_

*****IADL/购买杂货是否困难
*r1shopa r2shopa r4shopa r5shopa r6shopa r7shopa r8shopa
label values r1shopa r2shopa r4shopa r5shopa r6shopa r7shopa r8shopa yesno_

*****IADL/准备饭菜是否困难
*r1mealsa r2mealsa r4mealsa r5mealsa r6mealsa r7mealsa r8mealsa
label values r1mealsa r2mealsa r4mealsa r5mealsa r6mealsa r7mealsa r8mealsa yesno_

*****IADL/使用地图是否困难
*r1mapa r2mapa r4mapa r5mapa r6mapa r7mapa r8mapa
label values r1mapa r2mapa r4mapa r5mapa r6mapa r7mapa r8mapa yesno_

*****IADL/房屋和花园周围工作是否困难
*r1housewka r2housewka r4housewka r5housewka r7housewka r8housewka
label values r1housewka r2housewka r4housewka r5housewka r7housewka r8housewka yesno_

*****IADL/独自离开房屋和使用交通工具是否困难
*r6leavhsa r7leavhsa r8leavhsa
label values r6leavhsa r7leavhsa r8leavhsa yesno_

*****IADL/洗衣服是否困难
*r6laundrya r7laundrya r8laundrya
label values r6laundrya r7laundrya r8laundrya yesno_

*****其他功能限制/步行100米是否困难
*r1walk100a r2walk100a r4walk100a r5walk100a r6walk100a r7walk100a r8walk100a
label values r1walk100a r2walk100a r4walk100a r5walk100a r6walk100a r7walk100a r8walk100a yesno_

*****其他功能限制/坐约2小时是否困难
*r1sita r2sita r4sita r5sita r6sita r7sita r8sita
label values r1sita r2sita r4sita r5sita r6sita r7sita r8sita yesno_

*****其他功能限制/长时间坐着从椅子上站起来是否困难
*r1chaira r2chaira r4chaira r5chaira r6chaira r7chaira r8chaira
label values r1chaira r2chaira r4chaira r5chaira r6chaira r7chaira r8chaira yesno_

*****其他功能限制/不休息地爬几段楼梯是否困难
*r1climsa r2climsa r4climsa r5climsa r6climsa r7climsa r8climsa
label values r1climsa r2climsa r4climsa r5climsa r6climsa r7climsa r8climsa yesno_

*****其他功能限制/不休息地爬一段楼梯是否困难
*r1clim1a r2clim1a r4clim1a r5clim1a r6clim1a r7clim1a r8clim1a
label values r1clim1a r2clim1a r4clim1a r5clim1a r6clim1a r7clim1a r8clim1a yesno_

*****其他功能限制/举起或搬运超过10磅/5公斤的重物是否困难
*r1lifta r2lifta r4lifta r5lifta r6lifta r7lifta r8lifta
label values r1lifta r2lifta r4lifta r5lifta r6lifta r7lifta r8lifta yesno_

*****其他功能限制/弯腰跪下或蹲下是否困难
*r1stoopa r2stoopa r4stoopa r5stoopa r6stoopa r7stoopa r8stoopa
label values r1stoopa r2stoopa r4stoopa r5stoopa r6stoopa r7stoopa r8stoopa yesno_

*****其他功能限制/手臂超过肩膀是否困难
*r1armsa r2armsa r4armsa r5armsa r6armsa r7armsa r8armsa
label values r1armsa r2armsa r4armsa r5armsa r6armsa r7armsa r8armsa yesno_

*****其他功能限制/推拉大型物体是否困难
*r1pusha r2pusha r4pusha r5pusha r6pusha r7pusha r8pusha
label values r1pusha r2pusha r4pusha r5pusha r6pusha r7pusha r8pusha yesno_

*****其他功能限制/从桌子上捡起一枚小硬币是否困难
*r1dimea r2dimea r4dimea r5dimea r6dimea r7dimea r8dimea
label values r1dimea r2dimea r4dimea r5dimea r6dimea r7dimea r8dimea yesno_

*****医生是否曾诊断高血压
*r1hibpe r2hibpe r4hibpe r5hibpe r6hibpe r7hibpe r8hibpe
label values r1hibpe r2hibpe r4hibpe r5hibpe r6hibpe r7hibpe r8hibpe yesno_

*****医生是否曾诊断糖尿病或高血糖
*r1diabe r2diabe r4diabe r5diabe r6diabe r7diabe r8diabe
label values r1diabe r2diabe r4diabe r5diabe r6diabe r7diabe r8diabe yesno_

*****医生是否曾诊断癌症或恶性肿瘤
*r1cancre r2cancre r4cancre r5cancre r6cancre r7cancre r8cancre
label values r1cancre r2cancre r4cancre r5cancre r6cancre r7cancre r8cancre yesno_

*****医生是否曾诊断慢性肺部疾病
*r1lunge r2lunge r4lunge r5lunge r6lunge r7lunge r8lunge
label values r1lunge r2lunge r4lunge r5lunge r6lunge r7lunge r8lunge yesno_

*****医生是否曾诊断心脏病发作
*r1hearte r2hearte r4hearte r5hearte r6hearte r7hearte r8hearte
label values r1hearte r2hearte r4hearte r5hearte r6hearte r7hearte r8hearte yesno_

*****医生是否曾诊断中风或脑血管疾病
*r1stroke r2stroke r4stroke r5stroke r6stroke r7stroke r8stroke
label values r1stroke r2stroke r4stroke r5stroke r6stroke r7stroke r8stroke yesno_

*****医生是否曾诊断关节炎(包括骨关节炎或风湿病)
*r1arthre r2arthre r4arthre r5arthre r6arthre r7arthre r8arthre
label values r1arthre r2arthre r4arthre r5arthre r6arthre r7arthre r8arthre yesno_

*****医生是否曾诊断情感或情绪障碍
*r2psyche r4psyche r5psyche r6psyche r7psyche r8psyche
label values r2psyche r4psyche r5psyche r6psyche r7psyche r8psyche yesno_

*****医生是否曾诊断哮喘
*r1asthmae r2asthmae r4asthmae
label values r1asthmae r2asthmae r4asthmae yesno_

*****医生是否曾诊断骨质疏松症
*r1osteoe r2osteoe r4osteoe
label values r1osteoe r2osteoe r4osteoe yesno_

*****医生是否曾诊断高血胆固醇
*r1hchole r2hchole r4hchole r5hchole r6hchole r7hchole r8hchole
label values r1hchole r2hchole r4hchole r5hchole r6hchole r7hchole r8hchole yesno_

*****医生是否曾诊断帕金森病
*r1parkine r2parkine r4parkine r5parkine r6parkine r7parkine r8parkine
label values r1parkine r2parkine r4parkine r5parkine r6parkine r7parkine r8parkine yesno_

*****医生是否曾诊断白内障
*r1catracte r2catracte r4catracte r5catracte r6catracte r7catracte r8catracte
label values r1catracte r2catracte r4catracte r5catracte r6catracte r7catracte r8catracte yesno_

*****髋部骨折
*r1hipe r2hipe r4hipe r5hipe r6hipe r7hipe r8hipe
label values r1hipe r2hipe r4hipe r5hipe r6hipe r7hipe r8hipe yesno_

*****医生是否曾诊断胃或十二指肠溃疡或消化性溃疡
*r1ulcere r1ulcere r2ulcere r4ulcere r5ulcere r6ulcere r7ulcere r8ulcere
label values r1ulcere r1ulcere r2ulcere r4ulcere r5ulcere r6ulcere r7ulcere r8ulcere yesno_

*****医生是否曾诊断肾脏疾病
*r6kidneye r7kidneye r8kidneye
label values r6kidneye r7kidneye r8kidneye yesno_

*****首次被诊断为高血压的年龄
*radiaghibp

*****首次被诊断为糖尿病的年龄
*radiagdiab

*****首次被诊断出癌症的年龄
*radiagcancr

*****首次被诊断为肺部疾病的年龄
*radiaglung

*****首次被诊断患有心脏病的年龄
*radiagheart

*****首次被诊断患有中风的年龄
*radiagstrok

*****首次被诊断为关节炎的年龄
*radiagarthr

*****首次被诊断为高胆固醇的年龄
*radiaghchol

*****首次被诊断为帕金森病的年龄
*radiagparkin

*****首次被诊断患有白内障的年龄
*radiagcatrct

*****首次被诊断为髋部或股骨骨折的年龄
*radiaghip

*****首次被诊断为胃或十二指肠溃疡或消化性溃疡的年龄
*radiagulcer

*****首次被诊断为哮喘的年龄
*radiagasthma

*****首次被诊断为骨质疏松症的年龄
*radiagosteo

*****首次被诊断出情绪、神经或精神问题的年龄
*radiagpsych

*****首次被诊断为慢性肾脏疾病的年龄
*radiagkidney

*****是否服用高血压药物
*r1rxhibp r2rxhibp r4rxhibp r5rxhibp r6rxhibp r7rxhibp r8rxhibp
label values r1rxhibp r2rxhibp r4rxhibp r5rxhibp r6rxhibp r7rxhibp r8rxhibp yesno_

*****是否服用糖尿病药物
*r1rxdiab r2rxdiab r4rxdiab r5rxdiab r6rxdiab r7rxdiab r8rxdiab
label values r1rxdiab r2rxdiab r4rxdiab r5rxdiab r6rxdiab r7rxdiab r8rxdiab yesno_

*****是否服用治疗心脏问题的药物
*r1rxheart r2rxheart r4rxheart r5rxheart r6rxheart r7rxheart r8rxheart
label values r1rxheart r2rxheart r4rxheart r5rxheart r6rxheart r7rxheart r8rxheart yesno_

*****是否服用高胆固醇药物
*r1rxhchol r2rxhchol r4rxhchol r5rxhchol r6rxhchol r7rxhchol r8rxhchol
label values r1rxhchol r2rxhchol r4rxhchol r5rxhchol r6rxhchol r7rxhchol r8rxhchol yesno_

*****是否服用哮喘药物
*r1rxasthma r2rxasthma r4rxasthma
label values r1rxasthma r2rxasthma r4rxasthma yesno_

*****是否服用慢性支气管炎药物
*r1rxlung r2rxlung r4rxlung r5rxlung r6rxlung r7rxlung r8rxlung
label values r1rxlung r2rxlung r4rxlung r5rxlung r6rxlung r7rxlung r8rxlung yesno_

*****是否服用治疗焦虑或抑郁的药物
*r1rxpsych r2rxpsych r4rxpsych r5rxpsych r6rxpsych r7rxpsych r8rxpsych
label values r1rxpsych r2rxpsych r4rxpsych r5rxpsych r6rxpsych r7rxpsych r8rxpsych yesno_

*****是否服用骨质疏松症药物，激素或其他激素
*r1rxosteo r2rxosteo r4rxosteo r5rxosteo r6rxosteo r7rxosteo r8rxosteo
label values r1rxosteo r2rxosteo r4rxosteo r5rxosteo r6rxosteo r7rxosteo r8rxosteo yesno_

*****是否服用胃烧伤药物
*r1rxulcer r2rxulcer r4rxulcer r5rxulcer r6rxulcer r7rxulcer r8rxulcer
label values r1rxulcer r2rxulcer r4rxulcer r5rxulcer r6rxulcer r7rxulcer r8rxulcer yesno_

*****是否服用治疗睡眠问题的药物
*r1rxsleep r2rxsleep r4rxsleep r5rxsleep r6rxsleep r7rxsleep r8rxsleep
label values r1rxsleep r2rxsleep r4rxsleep r5rxsleep r6rxsleep r7rxsleep r8rxsleep yesno_

*****是否服用药物来抑制炎症
*r5rxinflm r6rxinflm r7rxinflm r8rxinflm
label values r5rxinflm r6rxinflm r7rxinflm r8rxinflm yesno_

*****医生是否曾诊断阿尔茨海默病或痴呆症
*r2alzdeme r4alzdeme r5alzdeme r6alzdeme r7alzdeme r8alzdeme
label values r2alzdeme r4alzdeme r5alzdeme r6alzdeme r7alzdeme r8alzdeme yesno_

*****首次被诊断为阿尔茨海默病/痴呆症的年龄
*radiagalzdem

*****身体质量指数
*r1height r2height r4height r5height r6height r7height r8height
*r1weight r2weight r4weight r5weight r6weight r7weight r8weight
*r1bmi r2bmi r4bmi r5bmi r6bmi r7bmi r8bmi

*****自评远视力
*r1dsight r2dsight r4dsight r5dsight r6dsight r7dsight r8dsight
foreach i in 1 2 4 5 6 7 8 {
 recode r`i'dsight (1=5) (2=4) (3=3) (4=2) (5=1) (6=0)		
}
label define sight_ 0 "失明" 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好"
label values r1dsight r2dsight r4dsight r5dsight r6dsight r7dsight r8dsight sight_

*****自评近视力
*r1nsight r2nsight r4nsight r5nsight r6nsight r7nsight r8nsight
foreach i in 1 2 4 5 6 7 8 {
 recode r`i'nsight (1=5) (2=4) (3=3) (4=2) (5=1) (6=0)		
}
label values r1nsight r2nsight r4nsight r5nsight r6nsight r7nsight r8nsight sight_

*****自评的听力
*r1hearing r2hearing r4hearing r5hearing r6hearing r7hearing r8hearing
foreach i in 1 2 4 5 6 7 8 {
 recode r`i'hearing (1=5) (2=4) (3=3) (4=2) (5=1) 	
}
label define hearing_ 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好"
label values r1hearing r2hearing r4hearing r5hearing r6hearing r7hearing r8hearing hearing_

*****是否经常佩戴助听器
*r1hearaid r2hearaid r4hearaid r5hearaid r6hearaid r7hearaid r8hearaid
label values r1hearaid r2hearaid r4hearaid r5hearaid r6hearaid r7hearaid r8hearaid yesno_

*****过去6个月是否因跌倒而烦恼
*r1fall_s r2fall_s r4fall_s r5fall_s r6fall_s r7fall_s r8fall_s
label values r1fall_s r2fall_s r4fall_s r5fall_s r6fall_s r7fall_s r8fall_s yesno_

*****过去6个月是否有过尿失禁
*r1urinai r2urinai r4urinai
label values r1urinai r2urinai r4urinai yesno_

*****是否受到背部、膝盖、臀部或任何其他关节疼痛的困扰
*r1pain_s r2pain_s r4pain_s
label values r1pain_s r2pain_s r4pain_s yesno_

*****是否疼痛
*r5painfr r6painfr r7painfr r8painfr
label values r5painfr r6painfr r7painfr r8painfr yesno_

*****疼痛水平
*r5painlv r6painlv r7painlv r8painlv
label define painlv_ 0 "没有" 1 "轻" 2 "温和" 3 "严重"
label values r5painlv r6painlv r7painlv r8painlv painlv_

*****是否每周至少服用一次止痛药物
*r1rxpain r2rxpain r4rxpain r5rxpain r6rxpain r7rxpain r8rxpain
label values r1rxpain r2rxpain r4rxpain r5rxpain r6rxpain r7rxpain r8rxpain yesno_

*****强度体力活动频率
*r1vgactx r2vgactx r4vgactx r5vgactx r6vgactx r7vgactx r8vgactx
label define vgactx_ 2 "至少每周一次" 3 "每周一次" 4 "每月1到3次" 5 "几乎或者没有"
label values r1vgactx r2vgactx r4vgactx r5vgactx r6vgactx r7vgactx r8vgactx vgactx_

*****中度体力活动频率
*r1mdactx r2mdactx r4mdactx r5mdactx r6mdactx r7mdactx r8mdactx
label define mdactx_ 2 "至少每周一次" 3 "每周一次" 4 "每月1到3次" 5 "几乎或者没有"
label values r1mdactx r2mdactx r4mdactx r5mdactx r6mdactx r7mdactx r8mdactx mdactx_

*****是否曾经喝过酒
*r2drinkev r4drinkev r5drinkev
label values r2drinkev r4drinkev r5drinkev yesno_

*****在一段时间内是否喝过酒
*r1drink3m r2drink3m r4drink3m r5drink3m
label values r1drink3m r2drink3m r4drink3m r5drink3m yesno_

*****在一段时间内的饮酒频率
*r1drinkx r2drinkx r4drinkx r5drinkx
label define drinkx_ 0 "不饮酒或每月少于1次" 1 "每月1~2次" 2 "每周1~2次或3~4天" 3 "每周5~6天" ///
  4 "几乎每天"
label values r1drinkx r2drinkx r4drinkx r5drinkx drinkx_

*****是否每周饮酒或在过去7天内饮酒
*r1drinkxw r2drinkxw r4drinkxw r5drinkxw r6drinkxw r7drinkxw r8drinkxw
label values r1drinkxw r2drinkxw r4drinkxw r5drinkxw r6drinkxw r7drinkxw r8drinkxw yesno_

*****是否曾经酗酒
*r2drinkb r4drinkb r5drinkb r6drinkb r7drinkb r8drinkb
label values r2drinkb r4drinkb r5drinkb r6drinkb r7drinkb r8drinkb yesno_

*****过去3个月内酗酒的频率
*r4bingedcat r5bingedcat r6bingedcat r7bingedcat r8bingedcat
label define bingedcat_ 0 "不喝或者每月少于1次" 1 "每月1~2次" 2 "每周1~2次或3~4天" 3 "每周有5~6天" 4 "每天或几乎每天"
label values r4bingedcat r5bingedcat r6bingedcat r7bingedcat r8bingedcat bingedcat_

*****曾经是否吸烟
*r1smokev r2smokev r4smokev r5smokev r6smokev r7smokev r8smokev
label values r1smokev r2smokev r4smokev r5smokev r6smokev r7smokev r8smokev yesno_

*****现在是否吸烟
*r1smoken r2smoken r4smoken r5smoken r6smoken r7smoken r8smoken
label values r1smoken r2smoken r4smoken r5smoken r6smoken r7smoken r8smoken yesno_

*****吸烟数量
*r1smokef r2smokef r6smokef r7smokef r8smokef

*****过去12个月是否住院
*r1hosp1y r2hosp1y r4hosp1y r5hosp1y r6hosp1y r7hosp1y r8hosp1y
label values r1hosp1y r2hosp1y r4hosp1y r5hosp1y r6hosp1y r7hosp1y r8hosp1y yesno_

*****过去12个月住院次数
*r1hsptim1y r2hsptim1y r4hsptim1y r5hsptim1y r6hsptim1y r7hsptim1y r8hsptim1y

*****过去12个月内住院天数
*r1hspnit1y r2hspnit1y r4hspnit1y r5hspnit1y r6hspnit1y r7hspnit1y r8hspnit1y

*****过去12个月是否门诊
*r1doctor1y r2doctor1y r4doctor1y r5doctor1y r6doctor1y r7doctor1y r8doctor1y
label values r1doctor1y r2doctor1y r4doctor1y r5doctor1y r6doctor1y r7doctor1y r8doctor1y yesno_

*****过去12个月门诊次数
*r1doctim1y r2doctim1y r4doctim1y r5doctim1y r6doctim1y r7doctim1y r8doctim1y

*****是否牙科就诊
*r1dentst1y r2dentst1y r5dentst1y r6dentst1y r7dentst1y r8dentst1y
label values r1dentst1y r2dentst1y r5dentst1y r6dentst1y r7dentst1y r8dentst1y yesno_

*****住院自付费用
*r1oophos1y r2oophos1y r5oophos1y r6oophos1y r7oophos1y

*****自费门诊费用
*r1oopdoc1y r2oopdoc1y r5oopdoc1y r6oopdoc1y r7oopdoc1y

*****购买药品的自费
*r1oopdrug1y r2oopdrug1y r5oopdrug1y r6oopdrug1y r7oopdrug1y

*****护理/养老院的自费
*r1oophmcr1y r2oophmcr1y r5oophmcr1y r6oophmcr1y r7oophmcr1y

*****牙科就诊的自费
*r5oopden1y r6oopden1y r7oopden1y

*****去年自费医疗费用总额
*r1oopmd1y r2oopmd1y r5oopmd1y r6oopmd1y r7oopmd1y

*****自我报告的记忆状况
*r4slfmem r5slfmem r6slfmem r7slfmem r8slfmem
foreach i in 4 5 6 7 8 {
 recode r`i'slfmem (1=5) (2=4) (3=3) (4=2) (5=1) 	
}
label define slfmem_ 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好"
label values r4slfmem r5slfmem r6slfmem r7slfmem r8slfmem slfmem_

*****认知/即时回忆单词10分
*r1imrc r2imrc r4imrc r5imrc r6imrc r7imrc r8imrc

*****认知/延迟回忆单词10分
*r1dlrc r2dlrc r4dlrc r5dlrc r6dlrc r7dlrc r8dlrc

*****认知/总单词记忆20分
*r1tr20 r2tr20 r4tr20 r5tr20 r6tr20 r7tr20 r8tr20

*****认知/正确减法的个数
*r4ser7 r5ser7 r6ser7 r7ser7 r8ser7

*****认知/月1分
*r1mo r2mo r4mo r5mo r6mo r7mo r8mo

*****认知/日1分
*r1dy r2dy r4dy r5dy r6dy r7dy r8dy

*****认知/年1分
*r1yr r2yr r4yr r5yr r6yr r7yr r8yr

*****认知/正确报告周1分
*r1dw r2dw r4dw r5dw r6dw r7dw r8dw

*****认知/正确报告日期4分
*r1orient r2orient r4orient r5orient r6orient r7orient r8orient

*****认知/语言流利度100分
*r1verbf r2verbf r4verbf r5verbf r6verbf r7verbf r8verbf

*****认知/数学表现能力5分
*r1numer_s r2numer_s r4numer_s r5numer_s r6numer_s r7numer_s r8numer_s

*****房屋所有权
*r1hownrnt r2hownrnt r4hownrnt r5hownrnt r6hownrnt r7hownrnt r8hownrnt
label define hownrnt_ 1 "自有房屋" 2 "租赁房屋" 3 "其他"
label values r1hownrnt r2hownrnt r4hownrnt r5hownrnt r6hownrnt r7hownrnt r8hownrnt hownrnt_

*****家庭净财富
*hh1atotb hh2atotb hh4atotb hh5atotb hh6atotb hh7atotb hh8atotb

*****夫妻层面的非住房财富总额
*h1atotn h2atotn h4atotn h5atotn h6atotn h7atotn h8atotn

*****家庭层面的非住房财富总额
*hh1atotn hh2atotn hh4atotn hh5atotn hh6atotn hh7atotn hh8atotn

*****前一年的就业收入
*r2itearn r4itearn r5itearn r6itearn r7itearn r8itearn

*****夫妻级收入总和
*h2ittot h4ittot h5ittot h6ittot h7ittot h8ittot

*****家庭总收入
*hh2itothhinc hh4itothhinc hh5itothhinc hh6itothhinc hh7itothhinc hh8itothhinc

*****家庭规模
*hh1hhres hh2hhres hh4hhres hh5hhres hh6hhres hh7hhres hh8hhres

*****健在儿子数
*h1son h2son h4son h5son h6son h7son h8son

*****健在女儿数
*h1dau h2dau h4dau h5dau h6dau h7dau h8dau

*****健在子女数
*h1child h2child h4child h5child h6child h7child h8child

*****母亲是否健在
*r1momliv r2momliv r4momliv r5momliv r6momliv r7momliv r8momliv
label values r1momliv r2momliv r4momliv r5momliv r6momliv r7momliv r8momliv yesno_

*****父亲是否健在
*r1dadliv r2dadliv r4dadliv r5dadliv r6dadliv r7dadliv r8dadliv
label values r1dadliv r2dadliv r4dadliv r5dadliv r6dadliv r7dadliv r8dadliv yesno_

*****是否与子女同住
*h1coresd h2coresd h4coresd h5coresd h6coresd h7coresd h8coresd
label values h1coresd h2coresd h4coresd h5coresd h6coresd h7coresd h8coresd yesno_

*****受访者对(孙)子女的转移支付
*h1tcany h2tcany h4tcany h5tcany h6tcany h7tcany h8tcany
label values h1tcany h2tcany h4tcany h5tcany h6tcany h7tcany h8tcany yesno_

*****(孙)子女对受访者的转移支付
*h1fcany h2fcany h4fcany h5fcany h6fcany h7fcany h8fcany
label values h1fcany h2fcany h4fcany h5fcany h6fcany h7fcany h8fcany yesno_

*****受访者对父母的转移支付
*h1tpany h2tpany h4tpany h5tpany h6tpany h7tpany h8tpany
label values h1tpany h2tpany h4tpany h5tpany h6tpany h7tpany h8tpany yesno_

*****父母对受访者的转移支付
*h1fpany h2fpany h4fpany h5fpany h6fpany h7fpany h8fpany
label values h1fpany h2fpany h4fpany h5fpany h6fpany h7fpany h8fpany yesno_

*****过去12个月内是否参加过任何社会活动
*r4socyr r5socyr r6socyr r7socyr r8socyr
label values r4socyr r5socyr r6socyr r7socyr r8socyr yesno_

*****过去四周是否做有偿工作
*r1work r2work r4work r5work r6work r7work r8work
label values r1work r2work r4work r5work r6work r7work r8work yesno_

*****是否自雇
*r1slfemp r2slfemp r4slfemp r5slfemp r6slfemp r7slfemp r8slfemp
label values r1slfemp r2slfemp r4slfemp r5slfemp r6slfemp r7slfemp r8slfemp yesno_

*****劳动力状况
*r1lbrf_s r2lbrf_s r4lbrf_s r5lbrf_s r6lbrf_s r7lbrf_s r8lbrf_s
label define lbrf_s_ 1 "受雇或自雇" 3 "失业" 5 "退休" 6 "永久生病或残疾" 8 "家庭主妇"
label values r1lbrf_s r2lbrf_s r4lbrf_s r5lbrf_s r6lbrf_s r7lbrf_s r8lbrf_s lbrf_s_

*****当前是否为政府工作
*r1jgovtemp r2jgovtemp r4jgovtemp r5jgovtemp r6jgovtemp r7jgovtemp r8jgovtemp
label values r1jgovtemp r2jgovtemp r4jgovtemp r5jgovtemp r6jgovtemp r7jgovtemp r8jgovtemp yesno_

*****是否自报退休
*r1retemp r2retemp r4retemp r5retemp r6retemp r7retemp r8retemp
label values r1retemp r2retemp r4retemp r5retemp r6retemp r7retemp r8retemp yesno_

*****自报退休月份
*r1retyr r2retyr r4retyr r5retyr r6retyr r7retyr r8retyr

*****自报退休月份
*r2retmon r4retmon r5retmon r6retmon r7retmon r8retmon

*****自我报告的活到指定年龄的概率
*r1liv10 r2liv10 r4liv10 r5liv10 r6liv10 r7liv10 r8liv10

*****是否领取公共养老金
*r1pubpen r2pubpen r4pubpen r5pubpen r6pubpen r7pubpen r8pubpen
label values r1pubpen r2pubpen r4pubpen r5pubpen r6pubpen r7pubpen r8pubpen yesno_

*****第一次走2.5米的秒数
*r1wspeed1 r2wspeed1

*****第二次走2.5米的秒数
*r1wspeed2 r2wspeed2

*****走2.5米的秒数均值
*r1wspeed r2wspeed

*****是否愿意并且能够完成步行速度测试
*r1walkcomp r2walkcomp

*****左手第1次力量测量值
*r1lgrip1 r2lgrip1 r3lgrip1 r4lgrip1 r5lgrip1 r6lgrip1 r7lgrip1 r8lgrip1

*****左手第2次力量测量值
*r1lgrip2 r2lgrip2 r3lgrip2 r4lgrip2 r5lgrip2 r6lgrip2 r7lgrip2 r8lgrip2

*****右手第1次力量测量值
*r1rgrip1 r2rgrip1 r3rgrip1 r4rgrip1 r5rgrip1 r6rgrip1 r7rgrip1 r8rgrip1

*****右手第2次力量测量值
*r1rgrip2 r2rgrip2 r3rgrip2 r4rgrip2 r5rgrip2 r6rgrip2 r7rgrip2 r8rgrip2

*****左手力量测量的最大值
*r1lgrip r2lgrip r3lgrip r4lgrip r5lgrip r6lgrip r7lgrip r8lgrip

*****右手力量测量的最大值
*r1rgrip r2rgrip r3rgrip r4rgrip r5rgrip r6rgrip r7rgrip r8rgrip

*****是否愿意并且能够完成握力测试
*r1gripcomp r2gripcomp r3gripcomp r4gripcomp r5gripcomp r6gripcomp r7gripcomp r8gripcomp
label values r1gripcomp r2gripcomp r3gripcomp r4gripcomp r5gripcomp r6gripcomp r7gripcomp r8gripcomp yesno_

*****第一次呼吸测试
*r2puff1 r4puff1 r6puff1

*****第二次呼吸测试
*r2puff2 r4puff2 r6puff2

*****最大呼吸测试测量值
*r2puff r4puff r6puff

*****是否愿意并能够完成呼吸测试
*r2puffcomp r4puffcomp r6puffcomp
label values r2puffcomp r4puffcomp r6puffcomp yesno_

*****单椅站立
*r2chr1res r5chr1res
label define chr1res_ 1 "站着不用手臂" 2 "用手臂站立" 3 "没有完成"
label values r2chr1res r5chr1res chr1res_

*****完成连续5个椅子站立所花费的秒数
*r2chr5sec r5chr5sec

*****10岁时家庭占用的房间数量
*raccrooms 

*****10岁时家中居住的人数
*raccnpeople 

*****10岁时住所是否有固定的浴室
*raccbath 
label values raccbath yesno_

*****10岁时住所是否有冷自来水供应
*raccwaterc 
label values raccwaterc yesno_

*****10岁时住所是否有热水供应
*raccwaterh 
label values raccwaterh yesno_

*****10岁时住所是否有内部厕所
*racctoilet 
label values racctoilet yesno_

*****10岁住所是否有集中供暖
*raccheating 
label values raccheating yesno_ 

*****10岁时住所的书籍数量
*raccbooks 

*****10岁时在学校数学上的相对表现
*raccmathperf

*****10岁时在学校的国家语言相对于其他人的表现
*racclangperf
recode racclangperf (1=5) (2=4) (3=3) (4=2) (5=1)
label define racclangperf_ 5 "比平均水平高得多" 4 "高于平均水平" ///
  3 "与平均水平大致相同" 2 "低于平均水平" 1 "比平均水平差得多"
label values racclangperf racclangperf_

*****统一可比的父亲的教育程度
*radadeducl
label define radadeducl_ 1 "低于高中学历" 2 "高中和职业培训" 3 "高等教育"
label values radadeducl radadeducl_ 

*****统一可比的父亲的教育程度
*ramomeducl
label define ramomeducl_ 1 "低于高中学历" 2 "高中和职业培训" 3 "高等教育"
label values ramomeducl ramomeducl_

*****10岁时父亲的职业
*radadoccup
label define radadoccup_ 1 "白领" 2 "蓝领" 4 "其他"
label values radadoccup radadoccup_

*****10岁时母亲的职业
*ramomoccup
label define ramomoccup_ 1 "白领" 2 "蓝领" 4 "其他"
label values ramomoccup ramomoccup_

*****EURO-D(12分)
*r1eurod r2eurod r4eurod r5eurod r6eurod r7eurod r8eurod

*****生活满意度(0~10分)
*r2satlife r4satlife r5satlife r6satlife r7satlife r8satlife

*****生活满意度z评分
*r2satlifez r4satlifez r5satlifez r6satlifez r7satlifez r8satlifez

*****幸福感4分
*r2happiness r4happiness r5happiness r6happiness r7happiness r8happiness
foreach i in 2 4 5 6 7 8 {
  recode r`i'happiness (1=4) (2=3) (3=2) (4=1)
}
*****爱好
*r4hobby r5hobby r6hobby r7hobby r8hobby

*****认知的z标准化
*r4memory_z r5memory_z r6memory_z r7memory_z r8memory_z
*r4orient_z r5orient_z r6orient_z r7orient_z r8orient_z 
*r4executive_z r5executive_z r6executive_z r7executive_z r8executive_z 
*r4tcog_z_z r5tcog_z_z r6tcog_z_z r7tcog_z_z r8tcog_z_z 

foreach i in 4 5 6 7 8 {
 egen r`i'mean_memory=mean(r4tr20)
 egen r`i'sd_memory=sd(r4tr20)
 gen r`i'memory_z=(r`i'tr20-r`i'mean_memory)/r`i'sd_memory
}

*****定向的z标准化(ref基线)
foreach i in 4 5 6 7 8 {
 egen r`i'mean_orient=mean(r4orient)
 egen r`i'sd_orient=sd(r4orient)
 gen r`i'orient_z=(r`i'orient-r`i'mean_orient)/r`i'sd_orient
}

*****执行的z标准化(ref基线)
foreach i in 4 5 6 7 8 {
 egen r`i'mean_executive=mean(r4ser7)
 egen r`i'executive_sd=sd(r4ser7)
 gen r`i'executive_z=(r`i'ser7-r`i'mean_executive)/r`i'executive_sd
}
*****总体认知能力z标准化(ref基线)
foreach i in 4 5 6 7 8 {
 egen r`i'tcog_z=rowmean(r`i'memory_z r`i'orient_z r`i'executive_z)
 egen r`i'tcog_z_mean=mean(r4tcog_z)
 egen r`i'tcog_z_sd=sd(r4tcog_z)
 gen r`i'tcog_z_z=(r`i'tcog_z-r`i'tcog_z_mean)/r`i'tcog_z_sd
}

*****认知的z标准化
*r4z_memory r5z_memory r6z_memory r7z_memory r8z_memory
*r4z_orient r5z_orient r6z_orient r7z_orient r8z_orient
*r4z_executive r5z_executive r6z_executive r7z_executive r8z_executive
*r4z_cog29 r5z_cog29 r6z_cog29 r7z_cog29 r8z_cog29

forvalues i=4/8 {
  zscore r`i'tr20 
  zscore r`i'orient
  zscore r`i'ser7
  egen r`i'cog29=rowtotal(r`i'tr20 r`i'orient r`i'ser7),mi
  zscore r`i'cog29
  drop r`i'cog29
  rename (z_r`i'tr20 z_r`i'orient z_r`i'ser7 z_r`i'cog29) (r`i'z_tr20 r`i'z_orient r`i'z_ser7 r`i'z_cog29)
}


*****按需求间隔依赖性分类划分的功能依赖性
*r1dependency r2dependency r4dependency r5dependency r6dependency r7dependency r8dependency 
label define dependency_ 0 "独立" 1 "低依赖性" 2 "中等依赖性" 3 "高依赖性"
foreach i in 1 2 4 5 6 7 8 {
  gen r`i'dependency=.
  replace r`i'dependency=0 if r`i'batha==0 & r`i'moneya==0 & r`i'shopa==0 & r`i'phonea==0 & ///
  r`i'mealsa==0 & r`i'medsa==0 & r`i'eata==0 & r`i'dressa==0 & r`i'beda==0 & r`i'toilta==0 & r`i'walkra==0
  replace r`i'dependency=1 if r`i'batha==1 | r`i'moneya==1 | r`i'shopa==1 | r`i'phonea==1 
  replace r`i'dependency=2 if (r`i'mealsa==1 | r`i'medsa==1) & (r`i'batha==0 & r`i'moneya==0 & r`i'shopa==0 & r`i'phonea==0) 
  replace r`i'dependency=3 if (r`i'eata==1 | r`i'dressa==1 | r`i'beda==1 | r`i'toilta==1 | r`i'walkra==1) & ///
  (r`i'mealsa==0 & r`i'medsa==0 & r`i'batha==0 & r`i'moneya==0 & r`i'shopa==0 & r`i'phonea==0) 
  label values r`i'dependency dependency_	 
}


*****社会隔离4分
foreach i in 4 5 6 7 8 {
 recode r`i'mstath (1 2 3=0) (4 5 7 8=1),gen(r`i'sisa1) //未婚（包括分居、离婚、丧偶或未婚）
 recode hh`i'hhres (1=1) (2/99=0),gen(r`i'sisa2)  //独居
 recode h`i'kcnt (1=0) (0=1),gen(r`i'sisa3) //与子女的接触少于每周一次
 recode r`i'socyr (1=0) (0=1),gen(r`i'sisa4)  //过去一年不参加任何社交活动
 egen r`i'sisa=rowtotal(r`i'sisa1 r`i'sisa2 r`i'sisa3 r`i'sisa4),mi
}

*****衰弱指数
*r1frailtyb r2frailtyb r4frailtyb r5frailtyb r6frailtyb r7frailtyb r8frailtyb
foreach i in 4 5 6 7 8 {
  recode r`i'nsight (0/1=1) (2=0.75) (3=0.5) (4=0.25) (5=0),gen(r`i'sight2)
}

foreach i in 4 5 6 7 8 {
  recode r`i'hearing (1=1) (2=0.75) (3=0.5) (4=0.25) (5=0),gen(r`i'hear2)
  replace r`i'hear2=1 if r`i'hearaid==1
}

foreach i in 4 5 6 7 8 {
  recode r`i'shlt (0/1=1) (2=0.75) (3=0.5) (4=0.25) (5=0),gen(r`i'shlt2)
}

foreach i in 4 5 6 7 8 {
  recode r`i'eurod (0/3=0) (4/12=1),gen(r`i'depression) 
}

foreach i in 4 5 6 7 8 {
  gen r`i'cogition=(29-r`i'tr20 - r`i'mo - r`i'dy - r`i'yr - r`i'dw - r`i'ser7)/29 ///
  if !mi(r`i'tr20) & !mi(r`i'mo) & !mi(r`i'dy) & !mi(r`i'yr) & !mi(r`i'dw) & !mi(r`i'ser7)
}

foreach i in 4 5 6 7 8 {
egen r`i'frailtyb=rowtotal(r`i'hibpe r`i'diabe r`i'hearte r`i'stroke r`i'cancre ///
  r`i'arthre r`i'lunge r`i'psyche r`i'alzdeme r`i'sight2 r`i'hear2 r`i'shlt2 ///
  r`i'dressa r`i'batha r`i'eata r`i'beda r`i'toilta r`i'moneya r`i'medsa r`i'shopa /// 
  r`i'mealsa r`i'walk100a r`i'chaira r`i'climsa r`i'lifta r`i'dimea r`i'stoopa ///
  r`i'armsa r`i'depression r`i'cogition),mi
replace r`i'frailtyb=r`i'frailtyb/30*100
}

*****是否使用网络
*r5internet r6internet r7internet r8internet
label values r5internet r6internet r7internet r8internet yesno_


********************************* 保存变量 *************************************
keep mergeid r1agey r2agey r4agey r5agey r6agey r7agey r8agey ///
r1armsa r2armsa r4armsa r5armsa r6armsa r7armsa r8armsa ///
r1arthre r2arthre r4arthre r5arthre r6arthre r7arthre r8arthre ///
r1asthmae r2asthmae r4asthmae ///
r1batha r2batha r4batha r5batha r6batha r7batha r8batha ///
r1beda r2beda r4beda r5beda r6beda r7beda r8beda ///
r1bmi r2bmi r4bmi r5bmi r6bmi r7bmi r8bmi ///
r1cancre r2cancre r4cancre r5cancre r6cancre r7cancre r8cancre ///
r1catracte r2catracte r4catracte r5catracte r6catracte r7catracte r8catracte ///
r1chaira r2chaira r4chaira r5chaira r6chaira r7chaira r8chaira ///
r1clim1a r2clim1a r4clim1a r5clim1a r6clim1a r7clim1a r8clim1a ///
r1climsa r2climsa r4climsa r5climsa r6climsa r7climsa r8climsa ///
r1dadliv r2dadliv r4dadliv r5dadliv r6dadliv r7dadliv r8dadliv ///
r1dentst1y r2dentst1y r5dentst1y r6dentst1y r7dentst1y r8dentst1y ///
r1diabe r2diabe r4diabe r5diabe r6diabe r7diabe r8diabe ///
r1dimea r2dimea r4dimea r5dimea r6dimea r7dimea r8dimea ///
r1dlrc r2dlrc r4dlrc r5dlrc r6dlrc r7dlrc r8dlrc ///
r1doctim1y r2doctim1y r4doctim1y r5doctim1y r6doctim1y r7doctim1y r8doctim1y ///
r1doctor1y r2doctor1y r4doctor1y r5doctor1y r6doctor1y r7doctor1y r8doctor1y ///
r1dressa r2dressa r4dressa r5dressa r6dressa r7dressa r8dressa ///
r1drink3m r2drink3m r4drink3m r5drink3m ///
r1drinkx r2drinkx r4drinkx r5drinkx ///
r1drinkxw r2drinkxw r4drinkxw r5drinkxw r6drinkxw r7drinkxw r8drinkxw ///
r1dsight r2dsight r4dsight r5dsight r6dsight r7dsight r8dsight ///
r1dw r2dw r4dw r5dw r6dw r7dw r8dw ///
r1dy r2dy r4dy r5dy r6dy r7dy r8dy ///
r1eata r2eata r4eata r5eata r6eata r7eata r8eata ///
r1eurod r2eurod r4eurod r5eurod r6eurod r7eurod r8eurod ///
r1fall_s r2fall_s r4fall_s r5fall_s r6fall_s r7fall_s r8fall_s ///
r1gripcomp r2gripcomp r3gripcomp r4gripcomp r5gripcomp r6gripcomp r7gripcomp r8gripcomp ///
r1hchole r2hchole r4hchole r5hchole r6hchole r7hchole r8hchole ///
r1hearaid r2hearaid r4hearaid r5hearaid r6hearaid r7hearaid r8hearaid ///
r1hearing r2hearing r4hearing r5hearing r6hearing r7hearing r8hearing ///
r1hearte r2hearte r4hearte r5hearte r6hearte r7hearte r8hearte ///
r1height r2height r4height r5height r6height r7height r8height ///
r1hibpe r2hibpe r4hibpe r5hibpe r6hibpe r7hibpe r8hibpe ///
r1hipe r2hipe r4hipe r5hipe r6hipe r7hipe r8hipe ///
r1hosp1y r2hosp1y r4hosp1y r5hosp1y r6hosp1y r7hosp1y r8hosp1y ///
r1housewka r2housewka r4housewka r5housewka r7housewka r8housewka ///
r1hownrnt r2hownrnt r4hownrnt r5hownrnt r6hownrnt r7hownrnt r8hownrnt ///
r1hspnit1y r2hspnit1y r4hspnit1y r5hspnit1y r6hspnit1y r7hspnit1y r8hspnit1y ///
r1hsptim1y r2hsptim1y r4hsptim1y r5hsptim1y r6hsptim1y r7hsptim1y r8hsptim1y ///
r1imrc r2imrc r4imrc r5imrc r6imrc r7imrc r8imrc ///
r1iwm r2iwm r4iwm r5iwm r6iwm r7iwm r8iwm ///
r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat r6iwstat r7iwstat r8iwstat ///
r1iwy r2iwy r4iwy r5iwy r6iwy r7iwy r8iwy ///
r1jgovtemp r2jgovtemp r4jgovtemp r5jgovtemp r6jgovtemp r7jgovtemp r8jgovtemp ///
r1lbrf_s r2lbrf_s r4lbrf_s r5lbrf_s r6lbrf_s r7lbrf_s r8lbrf_s ///
r1lgrip r2lgrip r3lgrip r4lgrip r5lgrip r6lgrip r7lgrip r8lgrip ///
r1lgrip1 r2lgrip1 r3lgrip1 r4lgrip1 r5lgrip1 r6lgrip1 r7lgrip1 r8lgrip1 ///
r1lgrip2 r2lgrip2 r3lgrip2 r4lgrip2 r5lgrip2 r6lgrip2 r7lgrip2 r8lgrip2 ///
r1lifta r2lifta r4lifta r5lifta r6lifta r7lifta r8lifta ///
r1liv10 r2liv10 r4liv10 r5liv10 r6liv10 r7liv10 r8liv10 ///
r1lunge r2lunge r4lunge r5lunge r6lunge r7lunge r8lunge ///
r1mapa r2mapa r4mapa r5mapa r6mapa r7mapa r8mapa ///
r1mdactx r2mdactx r4mdactx r5mdactx r6mdactx r7mdactx r8mdactx /// ///
r1mealsa r2mealsa r4mealsa r5mealsa r6mealsa r7mealsa r8mealsa ///
r1medsa r2medsa r4medsa r5medsa r6medsa r7medsa r8medsa ///
r1mo r2mo r4mo r5mo r6mo r7mo r8mo ///
r1momliv r2momliv r4momliv r5momliv r6momliv r7momliv r8momliv ///
r1moneya r2moneya r4moneya r5moneya r6moneya r7moneya r8moneya ///
r1mstath r2mstath r4mstath r5mstath r6mstath r7mstath r8mstath ///
r1nsight r2nsight r4nsight r5nsight r6nsight r7nsight r8nsight ///
r1numer_s r2numer_s r4numer_s r5numer_s r6numer_s r7numer_s r8numer_s ///
r1oopdoc1y r2oopdoc1y r5oopdoc1y r6oopdoc1y r7oopdoc1y ///
r1oopdrug1y r2oopdrug1y r5oopdrug1y r6oopdrug1y r7oopdrug1y /// 
r1oophmcr1y r2oophmcr1y r5oophmcr1y r6oophmcr1y r7oophmcr1y /// 
r1oophos1y r2oophos1y r5oophos1y r6oophos1y r7oophos1y ///
r1oopmd1y r2oopmd1y r5oopmd1y r6oopmd1y r7oopmd1y ///
r1orient r2orient r4orient r5orient r6orient r7orient r8orient ///
r1osteoe r2osteoe r4osteoe ///
r1pain_s r2pain_s r4pain_s ///
r1parkine r2parkine r4parkine r5parkine r6parkine r7parkine r8parkine ///
r1phonea r2phonea r4phonea r5phonea r6phonea r7phonea r8phonea ///
r1pubpen r2pubpen r4pubpen r5pubpen r6pubpen r7pubpen r8pubpen ///
r1pusha r2pusha r4pusha r5pusha r6pusha r7pusha r8pusha ///
r1retemp r2retemp r4retemp r5retemp r6retemp r7retemp r8retemp ///
r1retyr r2retyr r4retyr r5retyr r6retyr r7retyr r8retyr ///
r1rgrip r2rgrip r3rgrip r4rgrip r5rgrip r6rgrip r7rgrip r8rgrip ///
r1rgrip1 r2rgrip1 r3rgrip1 r4rgrip1 r5rgrip1 r6rgrip1 r7rgrip1 r8rgrip1 ///
r1rgrip2 r2rgrip2 r3rgrip2 r4rgrip2 r5rgrip2 r6rgrip2 r7rgrip2 r8rgrip2 ///
r1rxasthma r2rxasthma r4rxasthma ///
r1rxdiab r2rxdiab r4rxdiab r5rxdiab r6rxdiab r7rxdiab r8rxdiab ///
r1rxhchol r2rxhchol r4rxhchol r5rxhchol r6rxhchol r7rxhchol r8rxhchol ///
r1rxheart r2rxheart r4rxheart r5rxheart r6rxheart r7rxheart r8rxheart ///
r1rxhibp r2rxhibp r4rxhibp r5rxhibp r6rxhibp r7rxhibp r8rxhibp ///
r1rxlung r2rxlung r4rxlung r5rxlung r6rxlung r7rxlung r8rxlung ///
r1rxosteo r2rxosteo r4rxosteo r5rxosteo r6rxosteo r7rxosteo r8rxosteo ///
r1rxpain r2rxpain r4rxpain r5rxpain r6rxpain r7rxpain r8rxpain ///
r1rxpsych r2rxpsych r4rxpsych r5rxpsych r6rxpsych r7rxpsych r8rxpsych ///
r1rxsleep r2rxsleep r4rxsleep r5rxsleep r6rxsleep r7rxsleep r8rxsleep ///
r1rxulcer r2rxulcer r4rxulcer r5rxulcer r6rxulcer r7rxulcer r8rxulcer ///
r1shlt r2shlt r4shlt r5shlt r6shlt r7shlt r8shlt ///
r1shopa r2shopa r4shopa r5shopa r6shopa r7shopa r8shopa ///
r1sita r2sita r4sita r5sita r6sita r7sita r8sita ///
r1slfemp r2slfemp r4slfemp r5slfemp r6slfemp r7slfemp r8slfemp ///
r1smokef r2smokef r6smokef r7smokef r8smokef ///
r1smoken r2smoken r4smoken r5smoken r6smoken r7smoken r8smoken ///
r1smokev r2smokev r4smokev r5smokev r6smokev r7smokev r8smokev ///
r1stoopa r2stoopa r4stoopa r5stoopa r6stoopa r7stoopa r8stoopa ///
r1stroke r2stroke r4stroke r5stroke r6stroke r7stroke r8stroke ///
r1toilta r2toilta r4toilta r5toilta r6toilta r7toilta r8toilta ///
r1tr20 r2tr20 r4tr20 r5tr20 r6tr20 r7tr20 r8tr20 ///
r1ulcere r2ulcere r4ulcere r5ulcere r6ulcere r7ulcere r8ulcere ///
r1urinai r2urinai r4urinai ///
r1verbf r2verbf r4verbf r5verbf r6verbf r7verbf r8verbf ///
r1vgactx r2vgactx r4vgactx r5vgactx r6vgactx r7vgactx r8vgactx ///
r1walk100a r2walk100a r4walk100a r5walk100a r6walk100a r7walk100a r8walk100a ///
r1walkcomp r2walkcomp ///
r1walkra r2walkra r4walkra r5walkra r6walkra r7walkra r8walkra ///
r1weight r2weight r4weight r5weight r6weight r7weight r8weight ///
r1work r2work r4work r5work r6work r7work r8work ///
r1wspeed r2wspeed ///
r1wspeed1 r2wspeed1 ///
r1wspeed2 r2wspeed2 ///
r1yr r2yr r4yr r5yr r6yr r7yr r8yr ///
r2alzdeme r4alzdeme r5alzdeme r6alzdeme r7alzdeme r8alzdeme ///
r2chr1res r5chr1res ///
r2chr5sec r5chr5sec ///
r2drinkb r4drinkb r5drinkb r6drinkb r7drinkb r8drinkb ///
r2drinkev r4drinkev r5drinkev ///
r2itearn r4itearn r5itearn r6itearn r7itearn r8itearn ///
r2psyche r4psyche r5psyche r6psyche r7psyche r8psyche ///
r2puff r4puff r6puff ///
r2puff1 r4puff1 r6puff1 ///
r2puff2 r4puff2 r6puff2 ///
r2puffcomp r4puffcomp r6puffcomp ///
r2retmon r4retmon r5retmon r6retmon r7retmon r8retmon ///
r2satlife r4satlife r5satlife r6satlife r7satlife r8satlife ///
r2satlifez r4satlifez r5satlifez r6satlifez r7satlifez r8satlifez ///
r4bingedcat r5bingedcat r6bingedcat r7bingedcat r8bingedcat ///
r4ser7 r5ser7 r6ser7 r7ser7 r8ser7 ///
r4slfmem r5slfmem r6slfmem r7slfmem r8slfmem ///
r4socyr r5socyr r6socyr r7socyr r8socyr ///
r5oopden1y r6oopden1y r7oopden1y ///
r5painfr r6painfr r7painfr r8painfr ///
r5painlv r6painlv r7painlv r8painlv ///
r5rxinflm r6rxinflm r7rxinflm r8rxinflm ///
r6kidneye r7kidneye r8kidneye ///
r6laundrya r7laundrya r8laundrya ///
r6leavhsa r7leavhsa r8leavhsa ///
rabyear rabmonth ///
raccbath  ///
raccbooks  ///
raccheating  ///
racclangperf ///
raccmathperf ///
raccnpeople  ///
raccrooms  ///
racctoilet  ///
raccwaterc  ///
raccwaterh  ///
racitizen ///
radadeducl ///
radadoccup ///
radiagalzdem ///
radiagarthr ///
radiagasthma ///
radiagcancr ///
radiagcatrct ///
radiagdiab ///
radiaghchol ///
radiagheart ///
radiaghibp ///
radiaghip ///
radiagkidney ///
radiaglung ///
radiagosteo ///
radiagparkin ///
radiagpsych ///
radiagstrok ///
radiagulcer ///
radyear radmonth ///
raedisced ///
raeducl ///
raedyrs ///
ragender ///
ramomeducl ///
ramomoccup ///
rarelig ///
country ///
hh1atotb hh2atotb hh4atotb hh5atotb hh6atotb hh7atotb hh8atotb ///
h2atotn h4atotn h5atotn h6atotn h7atotn h8atotn ///
hh2atotn hh4atotn hh5atotn hh6atotn hh7atotn hh8atotn ///
h1child h2child h4child h5child h6child h7child h8child ///
h1coresd h2coresd h4coresd h5coresd h6coresd h7coresd h8coresd ///
h1dau h2dau h4dau h5dau h6dau h7dau h8dau ///
h1fcany h2fcany h4fcany h5fcany h6fcany h7fcany h8fcany ///
h1fpany h2fpany h4fpany h5fpany h6fpany h7fpany h8fpany ///
hh1hhidc hh2hhidc hh3hhidc hh4hhidc hh5hhidc hh6hhidc hh7hhidc hh8hhidc ///
hh1hhres hh2hhres hh4hhres hh5hhres hh6hhres hh7hhres hh8hhres ///
inw1 inw2 inw4 inw5 inw6 inw7 inw8 ///
hh2itothhinc hh4itothhinc hh5itothhinc hh6itothhinc hh7itothhinc hh8itothhinc ///
h2ittot h4ittot h5ittot h6ittot h7ittot h8ittot ///
h1rural h2rural h4rural h5rural h6rural h7rural h8rural ///
h1son h2son h4son h5son h6son h7son h8son ///
h1tcany h2tcany h4tcany h5tcany h6tcany h7tcany h8tcany ///
h1tpany h2tpany h4tpany h5tpany h6tpany h7tpany h8tpany ///
r1hobby r2hobby r4hobby r5hobby r6hobby r7hobby r8hobby ///
r2happiness r4happiness r5happiness r6happiness r7happiness r8happiness ///
r1dependency r2dependency r4dependency r5dependency r6dependency r7dependency r8dependency ///
r4sisa r5sisa r6sisa r7sisa r8sisa ///
r4frailtyb r5frailtyb r6frailtyb r7frailtyb r8frailtyb ///
r5internet r6internet r7internet r8internet ///
r4act1 r4act2 r4act3 r4act4 r4act5 r4act6 r4act7 r4act8 ///
r5act1 r5act2 r5act3 r5act4 r5act5 r5act6 r5act7 r5act8 ///
r6act1 r6act2 r6act3 r6act5 r6act6 r6act7 r6act8 ///
r7act1 r7act2 r7act3 r7act5 r7act6 r7act7 r7act8 ///
r8act1 r8act2 r8act3 r8act5 r8act6 r8act7 r8act8 ///
r4freq_act1 r4freq_act2 r4freq_act3 r4freq_act4 r4freq_act5 r4freq_act6 r4freq_act7 r4freq_act8 ///
r5freq_act1 r5freq_act2 r5freq_act3 r5freq_act4 r5freq_act5 r5freq_act6 r5freq_act7 r5freq_act8 ///
r6freq_act1 r6freq_act2 r6freq_act3 r6freq_act5 r6freq_act6 r6freq_act7 r6freq_act8 ///
r7freq_act1 r7freq_act2 r7freq_act3 r7freq_act5 r7freq_act6 r7freq_act7 r7freq_act8 ///
r8freq_act1 r8freq_act2 r8freq_act3 r8freq_act5 r8freq_act6 r8freq_act7 r8freq_act8 ///

reshape long r@agey r@armsa r@arthre r@asthmae r@batha r@beda r@bmi r@cancre r@catracte ///
  r@chaira r@clim1a r@climsa r@dadliv r@dentst1y r@diabe r@dimea r@dlrc r@doctim1y ////
  r@docto r@y r@dressa r@drink3m r@drinkx r@drinkxw r@dsight r@dw r@dy r@eata r@eurod ///
  r@fall_s r@gripcomp r@hchole r@hearaid r@hearing r@hearte r@height r@hibpe r@hipe ///
  r@hosp1y r@housewka r@hownrnt r@hspnit1y r@hsptim1y r@imrc r@iwm r@iwstat r@iwy ///
  r@jgovtemp r@lbrf_s r@lgrip r@lgrip1 r@lgrip2 r@lifta r@liv10 r@lunge r@mapa r@mdactx ///
  r@mealsa r@medsa r@mo r@momliv r@moneya r@mstath r@nsight r@numer_s r@oopdoc1y ///
  r@oopdrug1y r@oophmc r@oophos1y r@oopmd1y r@orient r@osteoe r@pain_s r@parkine ///  
  r@phonea r@pubpen r@pusha r@retemp r@retyr r@rgrip r@rgrip1 r@rgrip2 r@rxasthma ///
  r@rxdiab r@rxhchol r@rxheart r@rxhibp r@rxlung r@rxosteo r@rxpain r@rxpsych r@rxsleep ///
  r@rxulcer r@shlt r@shopa r@sita r@slfemp r@smokef r@smoken r@smokev r@stoopa r@stroke /// 
  r@toilta r@tr20 r@ulcere r@urinai r@verbf r@vgactx r@walk100a r@walkcomp r@walkra ///
  r@weight r@work r@wspeed r@wspeed1 r@wspeed2 r@yr r@alzdeme r@ch r@res r@chr5sec ///
  r@drinkb r@drinkev r@itearn r@psyche r@puff r@puff1 r@puff2 r@puffcomp r@retmon ///
  r@satlife r@satlifez r@bingedcat r@ser7 r@slfmem r@socyr r@oopden1y r@painfr ///
  r@painlv r@rxinflm r@kidneye r@laundrya r@leavhsa r@chr1res r@oophmcr1y r@doctor1y ///
  hh@atotb h@atotn hh@atotn h@child h@coresd h@dau h@fcany h@fpany hh@hhidc hh@hhres ///
  inw@ hh@itothhinc h@ittot h@rural h@son h@tcany h@tpany r@hobby r@happiness r@dependency ///
  r@sisa r@frailtyb r@internet r@act1 r@act2 r@act3 r@act4 r@act5 r@act6 r@act7 r@act8 ///
  r@freq_act1 r@freq_act2 r@freq_act3 r@freq_act4 r@freq_act5 r@freq_act6 r@freq_act7 r@freq_act8,i(mergeid) j(wave) 
  
rename (mergeid wave riwstat riwm riwy rabyear rabmonth radyear radmonth ragey /// 
 ragender raedyrs raedisced raeducl rmstath racitizen rarelig rwalkra rdressa /// 
 rbatha reata rbeda rtoilta rphonea rmedsa rmoneya rshopa rmealsa rmapa rhousewka /// 
 rleavhsa rlaundrya rwalk100a rsita rchaira rclimsa rclim1a rlifta rstoopa rarmsa /// 
 rpusha rdimea rhibpe rdiabe rcancre rlunge rhearte rstroke rarthre rpsyche rhchole /// 
 rparkine rcatracte rhipe rulcere rkidneye radiaghibp radiagdiab radiagcancr ///
 radiaglung radiagheart radiagstrok radiagarthr radiaghchol radiagparkin radiagcatrct /// 
 radiaghip radiagulcer radiagasthma radiagosteo radiagpsych radiagkidney rrxhibp  ///
 rrxdiab rrxheart rrxhchol rrxlung rrxpsych rrxosteo rrxulcer rrxsleep rrxinflm  ///
 ralzdeme radiagalzdem rheight rweight rbmi rdsight rnsight rhearing rhearaid ///
 rfall_s rpainfr rpainlv rrxpain rvgactx rmdactx rdrinkxw rdrinkb rbingedcat /// 
 rsmokev rsmoken rsmokef rhosp1y rhsptim1y rhspnit1y rdoctor1y rdoctim1y rdentst1y  ///
 rslfmem rimrc rdlrc rser7 rmo rdy ryr rdw rorient rverbf rnumer_s rtr20 rhownrnt /// 
 ritearn rmomliv rdadliv rsocyr rwork rslfemp rlbrf_s rjgovtemp rretemp rretyr rretmon ///
 rliv10 rpubpen rlgrip1 rlgrip2 rrgrip1 rrgrip2 rlgrip rrgrip rgripcomp raccrooms  ///
 raccnpeople raccbath raccwaterc raccwaterh racctoilet raccheating raccbooks  ///
 raccmathperf racclangperf radadeducl ramomeducl radadoccup ramomoccup reurod  ///
 rsatlife rsatlifez rasthmae rdrink3m rdrinkx roopdoc1y roopdrug1y  ///
 roophmc roophos1y roopmd1y rosteoe rpain_s rrxasthma rurinai rwalkcomp rwspeed  /// ///
 rwspeed1 rwspeed2 rchr5sec rdrinkev rpuff rpuff1 rpuff2 rpuffcomp  ///
 roopden1y rchr1res roophmcr1y hhatotb hchild hcoresd hdau hfcany hfpany hhhhidc ///
 hhhhres inw hhitothhinc hatotn hhatotn hittot hrural rshlt hson htcany htpany rhobby ///
 rhappiness rdependency rsisa rfrailtyb rinternet ract1 ract2 ract3 ract4 ract5 ract6 ract7 ract8 ///
 rfreq_act1 rfreq_act2 rfreq_act3 rfreq_act4 rfreq_act5 rfreq_act6 rfreq_act7 rfreq_act8) ///
 (mergeid wave iwstat iwm iwy rabyear rabmonth radyear radmonth agey /// 
 ragender raedyrs raedisced raeducl mstath racitizen rarelig walkra dressa /// 
 batha eata beda toilta phonea medsa moneya shopa mealsa mapa housewka /// 
 leavhsa laundrya walk100a sita chaira climsa clim1a lifta stoopa armsa /// 
 pusha dimea hibpe diabe cancre lunge hearte stroke arthre psyche hchole /// 
 parkine catracte hipe ulcere kidneye radiaghibp radiagdiab radiagcancr ///
 radiaglung radiagheart radiagstrok radiagarthr radiaghchol radiagparkin radiagcatrct /// 
 radiaghip radiagulcer radiagasthma radiagosteo radiagpsych radiagkidney rxhibp  ///
 rxdiab rxheart rxhchol rxlung rxpsych rxosteo rxulcer rxsleep rxinflm  ///
 alzdeme radiagalzdem height weight bmi dsight nsight hearing hearaid ///
 fall_s painfr painlv rxpain vgactx mdactx drinkxw drinkb bingedcat /// 
 smokev smoken smokef hosp1y hsptim1y hspnit1y doctor1y doctim1y dentst1y  ///
 slfmem imrc dlrc ser7 mo dy yr dw orient verbf numer_s tr20 hownrnt /// 
 itearn momliv dadliv socyr work slfemp lbrf_s jgovtemp retemp retyr retmon ///
 liv10 pubpen lgrip1 lgrip2 rgrip1 rgrip2 lgrip rgrip gripcomp raccrooms  ///
 raccnpeople raccbath raccwaterc raccwaterh racctoilet raccheating raccbooks  ///
 raccmathperf racclangperf radadeducl ramomeducl radadoccup ramomoccup eurod  ///
 satlife satlifez asthmae drink3m drinkx oopdoc1y oopdrug1y  ///
 oophmc oophos1y oopmd1y osteoe pain_s rxasthma urinai walkcomp wspeed  /// ///
 wspeed1 wspeed2 chr5sec drinkev puff puff1 puff2 puffcomp  ///
 oopden1y chr1res oophmcr1y hhatotb child coresd dau fcany fpany hhidc ///
 hhres inw hhitothhinc hatotn hhatotn hittot rural shlt son tcany tpany hobby ///
 happiness dependency sisa frailtyb internet act1 act2 act3 act4 act5 act6 act7 act8 ///
 freq_act1 freq_act2 freq_act3 freq_act4 freq_act5 freq_act6 freq_act7 freq_act8)


*****只保留参与每一轮调查的样本
keep if inw==1   //只保留参与调查的个体
drop inw

*****所有缺失值类型转为.
mvencode _all, mv(-999) 
mvdecode _all, mv(-999)

*****add notes
notes drop _dta
note: Shawn老师->微信公众账号@丁点帮你

label var satlife "生活满意度(10分)"
label var satlifez "生活满意度z评分"
label var stroke "医生是否曾诊断中风或脑血管疾病"
label var age "年龄"
label var alzdeme "医生是否曾诊断阿尔茨海默病或痴呆症"
label var armsa "其他功能限制/手臂超过肩膀是否困难"
label var arthre "医生是否曾诊断关节炎"
label var asthmae "医生是否曾诊断哮喘"
label var hhatotb "家庭净财富"
label var hatotn "夫妻层面的非住房财富总额"
label var hhatotn "家庭层面的非住房财富总额"
label var batha "ADL/洗澡是否困难"
label var beda "ADL/上下床是否困难"
label var bingedcat "过去3个月内酗酒的频率"
label var bmi "自报BMI"
label var cancre "医生是否曾诊断癌症或恶性肿瘤"
label var catracte "医生是否曾诊断白内障"
label var chaira "其他功能限制/长时间坐着从椅子上站起来是否困难"
label var child "健在子女数"
label var chr1res "单椅站立"
label var chr5sec "完成连续5个椅子站立所花费的秒数"
label var clim1a "其他功能限制/不休息地爬一段楼梯是否困难"
label var climsa "其他功能限制/不休息地爬几段楼梯是否困难"
label var coresd "是否与子女同住"
label var country "所在的国家"
label var dadliv "父亲是否健在"
label var dau "健在女儿数"
label var dentst1y "是否牙科就诊"
label var diabe "医生是否曾诊断高血压"
label var diabe "医生是否曾诊断糖尿病或高血糖"
label var dimea "其他功能限制/从桌子上捡起一枚小硬币是否困难"
label var dlrc "认知/延迟回忆单词10分"
label var doctim1y "过去12个月门诊次数"
label var doctor1y "过去12个月是否门诊"
label var dressa "ADL/穿衣是否困难"
label var drink3m "在一段时间内是否喝过酒"
label var drinkb "是否曾经酗酒"
label var drinkev "是否曾经喝过酒"
label var drinkx "在一段时间内的饮酒频率"
label var drinkxw "是否每周饮酒或在过去7天内饮酒"
label var dsight "自评远视力"
label var dw "认知/正确报告周1分"
label var dy "认知/正确报告日1分"
label var eata "ADL/吃饭是否困难"
label var eurod "EURO-D(12分)"
label var fall_s "过去6个月是否因跌倒而烦恼"
label var fcany "(孙)子女给受访者的转移支付"
label var fpany "父母对受访者的转移支付"
label var gripcomp "是否愿意并且能够完成握力测试"
label var hchole "医生是否曾诊断高血胆固醇"
label var hearaid "是否经常佩戴助听器"
label var hearing "自评的听力"
label var hearte "医生是否曾诊断心脏病发作"
label var height "自报身高m"
label var hhidc "本期家庭标识符"
label var hhres "家庭规模"
label var hipe "髋部骨折"
label var hosp1y "过去12个月是否住院"
label var housewka "IADL/房屋和花园周围工作是否困难"
label var hownrnt "房屋所有权"
label var hspnit1y "过去12个月内住院天数"
label var hsptim1y "过去12个月住院次数"
label var imrc "认知/即时回忆单词10分"
label var itearn "前一年的就业收入"
label var hhitothhinc "家庭总收入"
label var hittot "夫妻级的总税后收入"
label var iwm "受访月份"
label var iwstat "是否死亡"
label var iwy "受访年份"
label var jgovtemp "当前是否为政府工作"
label var kidneye "医生是否曾诊断肾脏疾病"
label var laundrya "IADL/洗衣服是否困难"
label var lbrf_s "劳动力状况"
label var leavhsa "IADL/独自离开房屋和使用交通工具是否困难"
label var lgrip "左手力量测量的最大值"
label var lgrip1 "左手第1次力量测量值"
label var lgrip2 "左手第2次力量测量值"
label var lifta "其他功能限制/举起或搬运超过10磅/5公斤的重物是否困难"
label var liv10 "自我报告的活到指定年龄的概率"
label var lunge "医生是否曾诊断慢性肺部疾病"
label var mapa "IADL/使用地图是否困难"
label var mdactx "中度体力活动频率"
label var mealsa "IADL/准备饭菜是否困难"
label var medsa "IADL/服用药物是否困难"
label var mergeid "个人唯一标识符"
label var mo "认知/正确报告月1分"
label var momliv "母亲是否健在"
label var moneya "IADL/理财是否困难"
label var mstath "婚姻状况"
label var nsight "自评近视力"
label var numer_s "认知/数学表现能力5分"
label var oopden1y "牙科就诊的自费"
label var oopdoc1y "门诊自付费用"
label var oopdrug1y "购买药品的自费"
label var oophmcr1y "护理/养老院的自费"
label var oophos1y "住院自付费用"
label var oopmd1y "去年自费医疗费用总额"
label var orient "认知/正确报告日期4分"
label var osteoe "医生是否曾诊断骨质疏松症"
label var pain_s "是否关节疼痛"
label var painfr "是否疼痛"
label var painlv "痛疼水平"
label var parkine "医生是否曾诊断帕金森病"
label var phonea "IADL/使用电话是否困难"
label var psyche "医生是否曾诊断情感或情绪障碍"
label var pubpen "是否领取公共养老金"
label var puff "最大呼吸测试测量值"
label var puff1 "第一次呼吸测试"
label var puff2 "第二次呼吸测试"
label var puffcomp "是否愿意并能够完成呼吸测试"
label var pusha "其他功能限制/推拉大型物体是否困难"
label var rabmonth "出生月份"
label var rabyear "出生年份"
label var raccbath "10岁时住所是否有固定的浴室"
label var raccbooks "10岁时住所的书籍数量"
label var raccheating "10岁住所是否有集中供暖"
label var racclangperf "10岁时在学校的国家语言相对于其他人的表现"
label var raccmathperf "10岁时在学校数学上的相对表现"
label var raccnpeople "10岁时家中居住的人数"
label var raccrooms "10岁时家庭占用的房间数量"
label var racctoilet "10岁时住所是否有内部厕所"
label var raccwaterc "10岁时住所是否有冷自来水供应"
label var raccwaterh "10岁时住所是否有热水供应"
label var racitizen "是否本国公民"
label var radadeducl "统一可比的父亲的教育程度"
label var radadoccup "10岁时父亲的职业"
label var radiagalzdem "首次被诊断为阿尔茨海默病/痴呆症的年龄"
label var radiagarthr "首次被诊断为关节炎的年龄"
label var radiagasthma "首次被诊断为哮喘的年龄"
label var radiagcancr "首次被诊断出癌症的年龄"
label var radiagcatrct "首次被诊断患有白内障的年龄"
label var radiagdiab "首次被诊断为糖尿病的年龄"
label var radiaghchol "首次被诊断为高胆固醇的年龄"
label var radiagheart "首次被诊断患有心脏病的年龄"
label var radiaghibp "首次被诊断为高血压的年龄"
label var radiaghip "首次被诊断为髋部或股骨骨折的年龄"
label var radiagkidney "首次被诊断为慢性肾脏疾病的年龄"
label var radiaglung "首次被诊断为肺部疾病的年龄"
label var radiagosteo "首次被诊断为骨质疏松症的年龄"
label var radiagparkin "首次被诊断为帕金森病的年龄"
label var radiagpsych "首次被诊断出情绪、神经或精神问题的年龄"
label var radiagstrok "首次被诊断患有中风的年龄"
label var radiagulcer "首次被诊断为胃或十二指肠溃疡或消化性溃疡的年龄"
label var radmonth "死亡月份"
label var radyear "死亡年份"
label var raedisced "国际教育标准分类"
label var raeducl "统一的教育程度"
label var raedyrs "教育年限"
label var ragender "性别"
label var ramomeducl "统一可比的父亲的教育程度"
label var ramomoccup "10岁时母亲的职业"
label var rarelig "宗教"
label var retemp "是否自报退休"
label var retyr "自报退休年份"
label var retmon "自报退休月份"
label var rgrip "右手力量测量的最大值"
label var rgrip1 "右手第1次力量测量值"
label var rgrip2 "右手第2次力量测量值"
label var rural "家庭居住在城市还是农村地区"
label var rxasthma "是否服用哮喘药物"
label var rxdiab "是否服用糖尿病药物"
label var rxhchol "是否服用高胆固醇药物"
label var rxheart "是否服用治疗心脏问题的药物"
label var rxhibp "是否服用高血压药物"
label var rxinflm "是否服用药物来抑制炎症"
label var rxlung "是否服用慢性支气管炎药物"
label var rxosteo "是否服用骨质疏松症药物，激素或其他激素"
label var rxpain "是否每周至少服用一次止痛药物"
label var rxpsych "是否服用治疗焦虑或抑郁的药物"
label var rxsleep "是否服用治疗睡眠问题的药物"
label var rxulcer "是否服用胃烧伤药物"
label var ser7 "认知/正确减法的个数5分"
label var shlt "自评健康"
label var shopa "IADL/购买杂货是否困难"
label var sita "其他功能限制/坐约2小时是否困难"
label var slfemp "是否自雇"
label var slfmem "自我报告的记忆状况"
label var smokef "吸烟数量"
label var smoken "现在是否吸烟"
label var smokev "曾经是否吸烟"
label var socyr "过去12个月内是否参加过任何社会活动"
label var son "健在儿子数"
label var stoopa "其他功能限制/弯腰跪下或蹲下是否困难"
label var tcany "受访者给(孙)子女的转移支付"
label var toilta "ADL/上厕所是否困难"
label var tpany "受访者对父母的转移支付"
label var tr20 "认知/总单词记忆20分"
label var ulcere "医生是否曾诊断胃或十二指肠溃疡或消化性溃疡"
label var urinai "过去6个月是否有过尿失禁"
label var verbf "认知/语言流利度100分"
label var vgactx "强度体力活动频率"
label var walk100a "其他功能限制/步行100米是否困难"
label var walkcomp "是否愿意并且能够完成步行速度测试"
label var walkra "ADL/房间里行走是否困难"
label var weight "自报体重kg"
label var work "过去四周是否做有偿工作"
label var wspeed "走2.5米的秒数均值"
label var wspeed1 "第一次走2.5米的秒数"
label var wspeed2 "第二次走2.5米的秒数"
label var yr "认知/正确报告年1分"
label var hibpe "医生是否曾诊断高血压" 
label var hobby "是否有爱好"
label var happiness "幸福感4分"
label var wave "第几次调查"
label define wave 1 "第1轮" 2 "第2轮" 3 "第3轮" 4 "第4轮" 5 "第5轮" 6 "第6轮" 7 "第7轮" 8 "第8轮"
label values wave wave
label var dependency "功能依赖性"
label var sisa "社会隔离4分"
label var frailtyb "虚弱"
label var internet "过去一周是否使用网络"
label var act1 "过去12个月中参与志愿者/慈善工作"
label var act2 "过去12个月中参加教育或培训课程" 
label var act3 "过去12个月中参加体育/社交/其他类型俱乐部" 
label var act4 "过去12个月中参与宗教组织活动"
label var act5 "过去12个月中参与政治/社区相关组织" 
label var act6 "过去12个月内阅读书籍、杂志或报纸" 
label var act7 "过去12个月内玩文字或数字游戏" 
label var act8 "过去12个月内玩纸牌或棋类游戏"
label var freq_act1 "过去12个月中参与志愿者/慈善工作的频率" 
label var freq_act2 "过去12个月中参加教育或培训课程的频率" 
label var freq_act3 "过去12个月中参加体育/社交/其他类型俱乐部的频率" 
label var freq_act4 "过去12个月中参与宗教组织活动的频率" 
label var freq_act5 "过去12个月中参与政治/社区相关组织的频率" 
label var freq_act6 "过去12个月内阅读书籍、杂志或报纸的频率" 
label var freq_act7 "过去12个月内玩文字或数字游戏的频率" 
label var freq_act8 "过去12个月内玩纸牌或棋类游戏的频率"

save "$working_data/share.dta",replace



