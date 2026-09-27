
clear all
set more off
set maxvar 20000
global root= "E:/ELSA_英国"
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

use "$raw_data/UKDA-5050-stata/stata/stata13_se/h_elsa_g3.dta",clear
merge 1:1 idauniq using "$temp_data/elsa_wave5.dta",nogen nolabel
merge 1:1 idauniq using "$temp_data/elsa_wave6.dta",nogen nolabel
merge 1:1 idauniq using "$temp_data/elsa_wave7.dta",nogen nolabel
merge 1:1 idauniq using "$temp_data/elsa_wave8.dta",nogen nolabel
merge 1:1 idauniq using "$temp_data/elsa_wave9.dta",nogen nolabel
label drop _all
*****个人标识符
*idauniqc

*****家庭标识符
*hh1hhid hh2hhid hh3hhid hh4hhid hh5hhid hh6hhid hh7hhid hh8hhid hh9hhid
*hh1hhidc hh2hhidc hh3hhidc hh4hhidc hh5hhidc hh6hhidc hh7hhidc hh8hhidc hh9hhidc

*****受访状态
*inw1 inw2 inw3 inw4 inw5 inw6 inw7 inw8 inw9
*inw1sc inw2sc inw3sc inw4sc inw5sc inw6sc inw7sc inw8sc inw9sc
label define yesno_ 1 "是" 0 "否"
label values inw1 inw2 inw3 inw4 inw5 inw6 inw7 inw8 inw9 yesno_
label values inw1sc inw2sc inw3sc inw4sc inw5sc inw6sc inw7sc inw8sc inw9sc yesno_

*****是否死亡
*r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat r6iwstat r7iwstat r8iwstat r9iwstat
forvalues i=1/9 {
  recode r`i'iwstat (0 1 4=0) (5 6=1) (7 9=.)	
}
label values r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat r6iwstat r7iwstat r8iwstat r9iwstat yesno_

*****受访年月
*r1iwindy r2iwindy r3iwindy r4iwindy r5iwindy r6iwindy r7iwindy r8iwindy r9iwindy
*r1iwindm r2iwindm r3iwindm r4iwindm r5iwindm r6iwindm r7iwindm r8iwindm r9iwindm

*****出生年份
*rabyear 

*****死亡年份
*radyear

*****年龄
*r1agey r2agey r3agey r4agey r5agey r6agey r7agey r8agey r9agey

*****年龄是否顶部编码为90
*r1fagey r2fagey r3fagey r4fagey r5fagey r6fagey r7fagey r8fagey r9fagey
label values r1fagey r2fagey r3fagey r4fagey r5fagey r6fagey r7fagey r8fagey r9fagey yesno_

*****性别
*ragender
recode ragender (1=1) (2=0)
label define gender_ 1 "男性" 0 "女性"
label values ragender gender_

*****是否白人
*raracem
recode raracem (1=1) (4=0)
label values raracem yesno_

*****教育程度
*raeduc_e 
label define raeduc_e_ 1 "不到高中" 3 "高中毕业" 4 "大专" 5 "大学及以上学历"
label values raeduc_e raeduc_e_

*****教育年限
*raedyrs_e

*****统一可比的教育程度
*raeducl
label define raeducl_ 1 "低于高中" 2 "高中和职业培训" 3 "高等教育"
label values raeducl raeducl_ 

*****婚姻状况
*r1mstath r2mstath r3mstath r4mstath r5mstath r6mstath r7mstath r8mstath r9mstath
label define mstath_ 1 "已婚或伴侣" 4 "分居" 5 "离婚" 7 "丧偶" 8 "从未结婚"
label values r1mstath r2mstath r3mstath r4mstath r5mstath r6mstath r7mstath r8mstath r9mstath mstath_

*****出生地是否为英国
*rabcountry
label values rabcountry yesno_

*****宗教
*rarelig_e
label define rarelig_e_ 1 "基督徒" 2 "佛教徒" 3 "印度教" 4 "犹太" ///
  5 "穆斯林" 6 "锡克教徒" 7 "其他非基督徒" 8 "没有"
label values rarelig_e rarelig_e_

*****访谈时是否住在护理机构中
*r3nhmliv r4nhmliv r5nhmliv r6nhmliv r7nhmliv r8nhmliv r9nhmliv
label values r3nhmliv r4nhmliv r5nhmliv r6nhmliv r7nhmliv r8nhmliv r9nhmliv yesno_

*****自评健康
*r1shlt r2shlt r4shlt r5shlt r6shlt r7shlt r8shlt r9shlt
forvalues i=5/9 {
  recode r`i'shlt (5=1) (4=2) (3=3) (2=4) (1=5)		
}
label define shlt_ 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好" 
label values r1shlt r2shlt r4shlt r5shlt r6shlt r7shlt r8shlt r9shlt shlt_

*****ADL/房间里走动是否困难
*r1walkra r2walkra r3walkra r4walkra r5walkra r6walkra r7walkra r8walkra r9walkra
label values r1walkra r2walkra r3walkra r4walkra r5walkra r6walkra r7walkra r8walkra r9walkra yesno_

*****ADL/穿衣是否困难
*r1dressa r2dressa r3dressa r4dressa r5dressa r6dressa r7dressa r8dressa r9dressa
label values r1dressa r2dressa r3dressa r4dressa r5dressa r6dressa r7dressa r8dressa r9dressa yesno_

*****ADL/洗澡和淋浴是否困难
*r1batha r2batha r3batha r5batha r6batha r7batha r8batha r9batha
label values r1batha r2batha r3batha r5batha r6batha r7batha r8batha r9batha yesno_

*****ADL/吃饭是否困难
*r1eata r2eata r3eata r4eata r5eata r6eata r7eata r8eata r9eata
label values r1eata r2eata r3eata r4eata r5eata r6eata r7eata r8eata r9eata yesno_

*****ADL/上下床是否困难
*r1beda r2beda r3beda r4beda r5beda r6beda r7beda r8beda r9beda
label values r1beda r2beda r3beda r4beda r5beda r6beda r7beda r8beda r9beda yesno_

*****ADL/上厕所是否困难
*r1toilta r2toilta r3toilta r4toilta r5toilta r6toilta r7toilta r8toilta r9toilta
label values r1toilta r2toilta r3toilta r4toilta r5toilta r6toilta r7toilta r8toilta r9toilta yesno_

*****IADL/使用地图是否困难
*r1mapa r2mapa r3mapa r4mapa r5mapa r6mapa r7mapa r8mapa r9mapa
label values r1mapa r2mapa r3mapa r4mapa r5mapa r6mapa r7mapa r8mapa r9mapa yesno_

*****IADL/使用电话是否困难
*r1phonea r2phonea r3phonea r4phonea r5phonea r6phonea r7phonea r8phonea r9phonea
label values r1phonea r2phonea r3phonea r4phonea r5phonea r6phonea r7phonea r8phonea r9phonea yesno_

*****IADL/服用药物是否困难
*r1medsa r2medsa r3medsa r4medsa r5medsa r6medsa r7medsa r8medsa r9medsa
label values r1medsa r2medsa r3medsa r4medsa r5medsa r6medsa r7medsa r8medsa r9medsa yesno_

*****IADL/理财是否困难
*r1moneya r2moneya r3moneya r4moneya r5moneya r6moneya r7moneya r8moneya
label values r1moneya r2moneya r3moneya r4moneya r5moneya r6moneya r7moneya r8moneya yesno_

*****IADL/购买杂货是否困难
*r1shopa r2shopa r3shopa r4shopa r5shopa r6shopa r7shopa r8shopa r9shopa
label values r1shopa r2shopa r3shopa r4shopa r5shopa r6shopa r7shopa r8shopa r9shopa yesno_

*****IADL/准备饭菜是否困难
*r1mealsa r2mealsa r3mealsa r4mealsa r5mealsa r6mealsa r7mealsa r8mealsa r9mealsa
label values r1mealsa r2mealsa r3mealsa r4mealsa r5mealsa r6mealsa r7mealsa r8mealsa r9mealsa yesno_

*****IADL/在房屋或花园周围工作是否困难
*r1housewka r2housewka r3housewka r4housewka r5housewka r6housewka r7housewka r8housewka r9housewka
label values r1housewka r2housewka r3housewka r4housewka r5housewka r6housewka r7housewka r8housewka r9housewka yesno_

*****IADL/识别身体危险是否困难
*r4dangera r5dangera r6dangera r7dangera r8dangera r9dangera
label values r4dangera r5dangera r6dangera r7dangera r8dangera r9dangera yesno_

*****IADL/通过语言、听觉或视觉进行交流是否困难
*r4communa r5communa r6communa r7communa r8communa r9communa
label values r4communa r5communa r6communa r7communa r8communa r9communa yesno_

*****其他功能限制/步行100码是否困难
*r1walk100a r2walk100a r3walk100a r4walk100a r5walk100a r6walk100a r7walk100a r8walk100a r9walk100a
label values r1walk100a r2walk100a r3walk100a r4walk100a r5walk100a r6walk100a r7walk100a r8walk100a r9walk100a yesno_

*****其他功能限制/坐约2小时是否困难
*r1sita r2sita r3sita r4sita r5sita r6sita r7sita r8sita r9sita
label values r1sita r2sita r3sita r4sita r5sita r6sita r7sita r8sita r9sita yesno_

*****其他功能限制/长时间坐着从椅子上站起来是否困难
*r1chaira r2chaira r3chaira r4chaira r5chaira r6chaira r7chaira r8chaira r9chaira
label values r1chaira r2chaira r3chaira r4chaira r5chaira r6chaira r7chaira r8chaira r9chaira yesno_

*****其他功能限制/不休息地爬几段楼梯是否困难
*r1climsa r2climsa r3climsa r4climsa r5climsa r6climsa r7climsa r8climsa r9climsa
label values r1climsa r2climsa r3climsa r4climsa r5climsa r6climsa r7climsa r8climsa r9climsa yesno_

*****其他功能限制/不休息地爬一段楼梯是否困难
*r1clim1a r2clim1a r3clim1a r4clim1a r5clim1a r6clim1a r7clim1a r8clim1a r9clim1a
label values r1clim1a r2clim1a r3clim1a r4clim1a r5clim1a r6clim1a r7clim1a r8clim1a r9clim1a yesno_

*****其他功能限制/举起或搬运超过10磅的重物是否困难
*r1lifta r2lifta r3lifta r4lifta r5lifta r6lifta r7lifta r8lifta r9lifta
label values r1lifta r2lifta r3lifta r4lifta r5lifta r6lifta r7lifta r8lifta r9lifta yesno_

*****其他功能限制/弯腰跪下或蹲下是否困难
*r1stoopa r2stoopa r3stoopa r4stoopa r5stoopa r6stoopa r7stoopa r8stoopa r9stoopa
label values r1stoopa r2stoopa r3stoopa r4stoopa r5stoopa r6stoopa r7stoopa r8stoopa r9stoopa yesno_

*****其他功能限制/手臂超过肩膀是否困难
*r1armsa r2armsa r3armsa r4armsa r5armsa r6armsa r7armsa r8armsa r9armsa
label values r1armsa r2armsa r3armsa r4armsa r5armsa r6armsa r7armsa r8armsa r9armsa yesno_

*****其他功能限制/推拉大型物体是否困难
*r1pusha r2pusha r3pusha r4pusha r5pusha r6pusha r7pusha r8pusha r9pusha
label values r1pusha r2pusha r3pusha r4pusha r5pusha r6pusha r7pusha r8pusha r9pusha yesno_

*****其他功能限制/桌子捡起硬币是否困难
*r1dimea r2dimea r3dimea r4dimea r5dimea r6dimea r7dimea r8dimea r9dimea
label values r1dimea r2dimea r3dimea r4dimea r5dimea r6dimea r7dimea r8dimea r9dimea yesno_

*****ADL总分
*r1adltot6 r2adltot6 r3adltot6 r4adltot6 r5adltot6 r6adltot6 r7adltot6 r8adltot6 r9adltot6

*****IADL总分
*r4iadltot2_e r5iadltot2_e r6iadltot2_e r7iadltot2_e r8iadltot2_e r9iadltot2_e

*****医生是否诊断患有高血压
*r1hibpe r2hibpe r3hibpe r4hibpe r5hibpe r6hibpe r7hibpe r8hibpe r9hibpe
label values r1hibpe r2hibpe r3hibpe r4hibpe r5hibpe r6hibpe r7hibpe r8hibpe r9hibpe yesno_

*****医生是否诊断患有糖尿病
*r1diabe r2diabe r3diabe r4diabe r5diabe r6diabe r7diabe r8diabe r9diabe
label values r1diabe r2diabe r3diabe r4diabe r5diabe r6diabe r7diabe r8diabe r9diabe yesno_

*****医生是否诊断患有癌症或恶性肿瘤(不包括轻微的皮肤癌)
*r1cancre r2cancre r3cancre r4cancre r5cancre r6cancre r7cancre r8cancre r9cancre
label values r1cancre r2cancre r3cancre r4cancre r5cancre r6cancre r7cancre r8cancre r9cancre yesno_

*****医生是否诊断患有慢性肺部疾病
*r1lunge r2lunge r3lunge r4lunge r5lunge r6lunge r7lunge r8lunge r9lunge
label values r1lunge r2lunge r3lunge r4lunge r5lunge r6lunge r7lunge r8lunge r9lunge yesno_

*****医生是否诊断患有心脏问题
*r1hearte r3hearte r4hearte r5hearte r6hearte r7hearte r8hearte r9hearte 
label values r1hearte r3hearte r4hearte r5hearte r6hearte r7hearte r8hearte r9hearte yesno_

*****医生是否诊断患有中风
*r1stroke r2stroke r3stroke r4stroke r5stroke r6stroke r7stroke r8stroke r9stroke
label values r1stroke r2stroke r3stroke r4stroke r5stroke r6stroke r7stroke r8stroke r9stroke yesno_

*****医生是否诊断患有任何情绪、神经或精神问题
*r1psyche r2psyche r3psyche r4psyche r5psyche r6psyche r7psyche r8psyche r9psyche
label values r1psyche r2psyche r3psyche r4psyche r5psyche r6psyche r7psyche r8psyche r9psyche yesno_

*****医生是否诊断患有关节炎
*r1arthre r2arthre r3arthre r4arthre r5arthre r6arthre r7arthre r8arthre r9arthre
label values r1arthre r2arthre r3arthre r4arthre r5arthre r6arthre r7arthre r8arthre r9arthre yesno_

*****医生是否诊断患有哮喘
*r1asthmae r2asthmae r3asthmae r4asthmae r5asthmae r6asthmae r7asthmae r8asthmae r9asthmae
label values r1asthmae r2asthmae r3asthmae r4asthmae r5asthmae r6asthmae r7asthmae r8asthmae r9asthmae yesno_

*****医生是否诊断患有高胆固醇
*r2hchole r3hchole r4hchole r5hchole r6hchole r7hchole r8hchole r9hchole
label values r2hchole r3hchole r4hchole r5hchole r6hchole r7hchole r8hchole r9hchole yesno_

*****医生是否诊断患有白内障
*r1catracte r2catracte r3catracte r4catracte r5catracte r6catracte r7catracte r8catracte r9catracte
label values r1catracte r2catracte r3catracte r4catracte r5catracte r6catracte r7catracte r8catracte r9catracte yesno_

*****医生是否诊断患有帕金森病
*r1parkine r2parkine r3parkine r4parkine r5parkine r6parkine r7parkine r8parkine r9parkine
label values r1parkine r2parkine r3parkine r4parkine r5parkine r6parkine r7parkine r8parkine r9parkine yesno_

*****医生是否诊断患有髋部骨折
*r1hipe r2hipe r3hipe r4hipe r5hipe r6hipe r7hipe r8hipe r9hipe
label values r1hipe r2hipe r3hipe r4hipe r5hipe r6hipe r7hipe r8hipe r9hipe yesno_

*****医生是否诊断患有心绞痛
label values r1angine r2angine r3angine r4angine r6angine r7angine r8angine r9angine yesno_

*****医生是否诊断患有心脏病发作(包括心肌梗死或冠状动脉血栓形成)
*r1hrtatte r2hrtatte r3hrtatte r4hrtatte r5hrtatte r6hrtatte r7hrtatte r8hrtatte r9hrtatte
label values r1hrtatte r2hrtatte r3hrtatte r4hrtatte r5hrtatte r6hrtatte r7hrtatte r8hrtatte r9hrtatte yesno_

*****医生是否诊断患有充血性心力衰竭
*r1conhrtfe r2conhrtfe r3conhrtfe r4conhrtfe r5conhrtfe r6conhrtfe r7conhrtfe r8conhrtfe r9conhrtfe
label values r1conhrtfe r2conhrtfe r3conhrtfe r4conhrtfe r5conhrtfe r6conhrtfe r7conhrtfe r8conhrtfe r9conhrtfe yesno_

*****医生是否诊断患有心脏杂音
*r1hrtmre r2hrtmre r3hrtmre r4hrtmre r5hrtmre r6hrtmre r7hrtmre r8hrtmre r9hrtmre
label values r1hrtmre r2hrtmre r3hrtmre r4hrtmre r5hrtmre r6hrtmre r7hrtmre r8hrtmre r9hrtmre yesno_

*****医生是否诊断患有心律异常
*r1hrtrhme r2hrtrhme r3hrtrhme r4hrtrhme r5hrtrhme r6hrtrhme r7hrtrhme r8hrtrhme r9hrtrhme
label values r1hrtrhme r2hrtrhme r3hrtrhme r4hrtrhme r5hrtrhme r6hrtrhme r7hrtrhme r8hrtrhme r9hrtrhme yesno_

*****医生是否诊断患有骨质疏松症
*r1osteoe r2osteoe r3osteoe r4osteoe r5osteoe r6osteoe r7osteoe r8osteoe r9osteoe
label values r1osteoe r2osteoe r3osteoe r4osteoe r5osteoe r6osteoe r7osteoe r8osteoe r9osteoe yesno_

*****过去2年内是否报告有心绞痛
*r1angin r2angin r3angin r4angin r5angin r6angin r7angin r8angin r9angin
label values r1angin r2angin r3angin r4angin r5angin r6angin r7angin r8angin r9angin yesno_

*****过去2年内是否报告有心脏病发作或心肌梗死
*r1hrtatt r2hrtatt r3hrtatt r4hrtatt r5hrtatt r6hrtatt r7hrtatt r8hrtatt r9hrtatt
label values r1hrtatt r2hrtatt r3hrtatt r4hrtatt r5hrtatt r6hrtatt r7hrtatt r8hrtatt r9hrtatt yesno_

*****过去2年内是否报告有任何情绪、神经或精神问题
*r1psych r2psych r3psych r4psych r5psych r6psych r7psych r8psych r9psych
label values r1psych r2psych r3psych r4psych r5psych r6psych r7psych r8psych r9psych yesno_

*****是否服用高血压药物
*r1rxhibp r2rxhibp r3rxhibp r4rxhibp r5rxhibp r6rxhibp r7rxhibp r8rxhibp r9rxhibp 
label values r1rxhibp r2rxhibp r3rxhibp r4rxhibp r5rxhibp r6rxhibp r7rxhibp r8rxhibp r9rxhibp yesno_

*****是否注射糖尿病胰岛素
*r1rxdiabi r2rxdiabi r3rxdiabi r4rxdiabi r5rxdiabi r6rxdiabi r7rxdiabi r8rxdiabi r9rxdiabi
label values r1rxdiabi r2rxdiabi r3rxdiabi r4rxdiabi r5rxdiabi r6rxdiabi r7rxdiabi r8rxdiabi r9rxdiabi yesno_

*****是否口服糖尿病药物
*r1rxdiabo r2rxdiabo r3rxdiabo r4rxdiabo r5rxdiabo r6rxdiabo r7rxdiabo r8rxdiabo r9rxdiabo
label values r1rxdiabo r2rxdiabo r3rxdiabo r4rxdiabo r5rxdiabo r6rxdiabo r7rxdiabo r8rxdiabo r9rxdiabo yesno_ 

*****是否服用口服药物或使用胰岛素注射治疗糖尿病
*r1rxdiab r2rxdiab r3rxdiab r4rxdiab r5rxdiab r6rxdiab r7rxdiab r8rxdiab r9rxdiab
label values r1rxdiab r2rxdiab r3rxdiab r4rxdiab r5rxdiab r6rxdiab r7rxdiab r8rxdiab r9rxdiab yesno_

*****是否服用慢性肺部疾病的药物
*r1rxlung r2rxlung r3rxlung r4rxlung r5rxlung r6rxlung r7rxlung r8rxlung r9rxlung
label values r1rxlung r2rxlung r3rxlung r4rxlung r5rxlung r6rxlung r7rxlung r8rxlung r9rxlung yesno_

*****是否服用哮喘药物
*r1rxasthma r2rxasthma r3rxasthma r4rxasthma r5rxasthma r6rxasthma r7rxasthma r8rxasthma r9rxasthma
label values r1rxasthma r2rxasthma r3rxasthma r4rxasthma r5rxasthma r6rxasthma r7rxasthma r8rxasthma r9rxasthma  yesno_

*****在过去两年内是否接受过任何癌症治疗
*r1trcancr r2trcancr r3trcancr r4trcancr r5trcancr r6trcancr r7trcancr r8trcancr r9trcancr
label values r1trcancr r2trcancr r3trcancr r4trcancr r5trcancr r6trcancr r7trcancr r8trcancr r9trcancr yesno_

*****是否正在服用β受体阻滞剂来诊断心脏病发作
*r2rxhrtat r5rxhrtat
label values r2rxhrtat r5rxhrtat yesno_

*****是否正在服用稀释血液的药物
*r2rxbldthn r3rxbldthn r4rxbldthn r5rxbldthn r6rxbldthn r7rxbldthn r8rxbldthn r9rxbldthn
label values r2rxbldthn r3rxbldthn r4rxbldthn r5rxbldthn r6rxbldthn r7rxbldthn r8rxbldthn r9rxbldthn yesno_ 

*****是否正在服用骨质疏松药物
*r2rxosteo r5rxosteo r6rxosteo r7rxosteo r8rxosteo r9rxosteo
label values r2rxosteo r5rxosteo r6rxosteo r7rxosteo r8rxosteo r9rxosteo yesno_

*****是否正在服用抑郁症药物
*r2rxdepres r4rxdepres r8rxdepres
label values r2rxdepres r4rxdepres r8rxdepres yesno_

*****是否正在接受抑郁症咨询
*r2trdepres r4trdepres r8trdepres
label values r2trdepres r4trdepres r8trdepres yesno_ 

*****是否正在接受高胆固醇治疗
*r2trhchol r5trhchol r6trhchol
label values r2trhchol r5trhchol r6trhchol yesno_

*****是否正在服用治疗高胆固醇的药物
*r3rxhchol r4rxhchol r5rxhchol r6rxhchol r7rxhchol r8rxhchol r9rxhchol
label values r3rxhchol r4rxhchol r5rxhchol r6rxhchol r7rxhchol r8rxhchol r9rxhchol yesno_

*****首次被诊断为心绞痛的年龄
*radiagangin

*****首次被诊断为心脏病发作(包括心肌梗死或冠状动脉血栓形成)的年龄
*rafrhrtatt

*****首次被诊断为充血性心力衰竭的年龄
*radiagchf

*****首次被诊断为糖尿病的年龄
*radiagdiab

*****首次被诊断为中风的年龄
*radiagstrok

*****首次被诊断关节炎的年龄
*radiagarthr

*****首次被诊断癌症或恶性肿瘤的年龄
*radiagcancr

*****首次被诊断帕金森病的年龄
*radiagparkin

*****首次被诊断有情绪、神经或精神问题的年龄
*radiagpsych

*****医生是否告诉受访者患有阿尔茨海默病
*r1alzhe r2alzhe r3alzhe r4alzhe r5alzhe r6alzhe r7alzhe r8alzhe r9alzhe
label values r1alzhe r2alzhe r3alzhe r4alzhe r5alzhe r6alzhe r7alzhe r8alzhe r9alzhe yesno_

*****医生是否告诉受访者患有痴呆症
*r1demene r2demene r3demene r4demene r5demene r6demene r7demene r8demene r9demene
label values r1demene r2demene r3demene r4demene r5demene r6demene r7demene r8demene r9demene yesno_

*****是否报告患有记忆障碍
*r1memrye r2memrye r3memrye r4memrye r5memrye r6memrye r7memrye r8memrye r9memrye
label values r1memrye r2memrye r3memrye r4memrye r5memrye r6memrye r7memrye r8memrye r9memrye yesno_

*****首次被诊断患有阿尔茨海默病的年龄
*radiagalzh

*****首次被诊断患有痴呆症的年龄
*radiagdemen

*****是否曾经做过关节置换手术
*r1jointre r2jointre r3jointre r4jointre r5jointre r6jointre r7jointre r8jointre r9jointre
label values r1jointre r2jointre r3jointre r4jointre r5jointre r6jointre r7jointre r8jointre r9jointre yesno_

*****是否做过髋关节置换术
*r1hipre r2hipre r3hipre r4hipre r5hipre r6hipre r7hipre r8hipre r9hipre
label values r1hipre r2hipre r3hipre r4hipre r5hipre r6hipre r7hipre r8hipre r9hipre yesno_

*****过去2年内是否做过髋关节置换术
*r1hipr r2hipr
label values r1hipr r2hipr yesno_

*****自评视力
*r1sight r2sight r3sight r4sight r5sight r6sight r7sight r8sight r9sight
forvalues i=1/9 {
 recode r`i'sight  (1=5) (2=4) (3=3) (4=2) (5=1) (6=0)	
}
label define sight_ 0 "失明" 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好" 
label values r1sight r2sight r3sight r4sight r5sight r6sight r7sight r8sight r9sight sight_

*****远视视力
*r1dsight r2dsight r3dsight r4dsight r5dsight r6dsight r7dsight r8dsight r9dsight
forvalues i=1/9 {
 recode r`i'dsight  (1=5) (2=4) (3=3) (4=2) (5=1) (6=0)	
}
label values r1dsight r2dsight r3dsight r4dsight r5dsight r6dsight r7dsight r8dsight r9dsight sight_

*****近视视力
*r1nsight r2nsight r3nsight r4nsight r5nsight r6nsight r7nsight r8nsight r9nsight
forvalues i=1/9 {
 recode r`i'nsight (1=5) (2=4) (3=3) (4=2) (5=1) (6=0)	
}
label values r1nsight r2nsight r3nsight r4nsight r5nsight r6nsight r7nsight r8nsight r9nsight sight_

*****是否做过白内障手术
*r1catrcte r2catrcte r3catrcte r4catrcte r5catrcte r6catrcte r7catrcte r8catrcte r9catrcte
label values r1catrcte r2catrcte r3catrcte r4catrcte r5catrcte r6catrcte r7catrcte r8catrcte r9catrcte yesno_

*****自评的听力
*r1hearing r2hearing r3hearing r4hearing r5hearing r6hearing r7hearing r8hearing r9hearing
forvalues i=1/9 {
 recode r`i'hearing (1=5) (2=4) (3=3) (4=2) (5=1)
}
label define hearing_ 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好" 
label values r1hearing r2hearing r3hearing r4hearing r5hearing r6hearing r7hearing r8hearing r9hearing hearing_

*****牙齿是否全部脱落
*r3noteeth r5noteeth
label values r3noteeth r5noteeth yesno_

*****自评的牙齿健康状况
*r3dentalh r5dentalh r7dentalh r8dentalh r9dentalh
foreach i in 3 5 7 8 9 {
 recode r`i'dentalh (1=5) (2=4) (3=3) (4=2) (5=1)
}
label define dentalh_ 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好" 
label values r3dentalh r5dentalh r7dentalh r8dentalh r9dentalh dentalh_ 

*****最近2年内是否跌倒过
*r1fall r2fall r3fall r5fall r6fall r7fall r8fall r9fall
label values r1fall r2fall r3fall r5fall r6fall r7fall r8fall r9fall yesno_

*****过去一年中是否摔倒过
*r4fall1y
label values r4fall1y yesno_

*****是否曾经严重受伤需要医疗
*r1fallinj r2fallinj r3fallinj r4fallinj r5fallinj r6fallinj r7fallinj r8fallinj r9fallinj
label values r1fallinj r2fallinj r3fallinj r4fallinj r5fallinj r6fallinj r7fallinj r8fallinj r9fallinj yesno_

*****过去2年中跌倒的次数
*r1fallnum r2fallnum r3fallnum r5fallnum r6fallnum r7fallnum r8fallnum r9fallnum

*****过去一年中跌倒的次数
*r4fallnum1y

*****跌倒后是否使用个人警报来寻求帮助
*r1falleq r2falleq r3falleq r4falleq r5falleq r6falleq r7falleq r8falleq r9falleq
label values r1falleq r2falleq r3falleq r4falleq r5falleq r6falleq r7falleq r8falleq r9falleq yesno_

*****过去两年是否髋部骨折
*r2hip r3hip r4hip r5hip r6hip r7hip r8hip r9hip
label values r2hip r3hip r4hip r5hip r6hip r7hip r8hip r9hip yesno_

*****是否做过子宫或子宫切除手术
*r4hystere r6hystere r7hystere
label values r4hystere r6hystere r7hystere yesno_

*****最后一次月经的年龄
*r4lstmnspd r6lstmnspd r7lstmnspd r8lstmnspd r9lstmnspd

*****是否经常感到疼痛
*r1painfr r2painfr r3painfr r4painfr r5painfr r6painfr r7painfr r8painfr r9painfr
label values r1painfr r2painfr r3painfr r4painfr r5painfr r6painfr r7painfr r8painfr r9painfr yesno_

*****疼痛程度
*r1painlv r2painlv r3painlv r4painlv r5painlv r6painlv r7painlv r8painlv r9painlv
label define painlv_ 0 "没有" 1 "轻度" 2 "中等" 3 "严重"
label values r1painlv r2painlv r3painlv r4painlv r5painlv r6painlv r7painlv r8painlv r9painlv painlv_

*****过去12个月内是否经历过尿失禁
*r1urinai r2urinai r3urinai r4urinai r5urinai r6urinai r7urinai r8urinai r9urinai
label values r1urinai r2urinai r3urinai r4urinai r5urinai r6urinai r7urinai r8urinai r9urinai yesno_

*****行走时是否经历过呼吸短促
*r1breath_e r2breath_e r3breath_e r4breath_e r5breath_e
label values r1breath_e r2breath_e r3breath_e r4breath_e r5breath_e yesno_

*****是否经历持续喘息、咳嗽或痰
*r1wheeze_e r2wheeze_e r3wheeze_e r4wheeze_e r5wheeze_e
label values r1wheeze_e r2wheeze_e r3wheeze_e r4wheeze_e r5wheeze_e yesno_

*****是否报告进行过乳房x光检查
*r5mammoge r6mammoge r7mammoge r8mammoge r9mammoge
label values r5mammoge r6mammoge r7mammoge r8mammoge r9mammoge yesno_

*****是否报告进行过前列腺检查
*r5proste r6proste r7proste r8proste r9proste
label values r5proste r6proste r7proste r8proste r9proste yesno_

*****过去两年内是否进行过乳房x光检查
*r5mammog r6mammog r7mammog
label values r5mammog r6mammog r7mammog yesno_

*****过去两年内是否进行过前列腺检查
*r5prost r6prost r7prost
label values r5prost r6prost r7prost yesno_

*****剧烈体力活动的频率
*r1vgactx_e r2vgactx_e r3vgactx_e r4vgactx_e r5vgactx_e r6vgactx_e r7vgactx_e r8vgactx_e r9vgactx_e
label define vgactx_e_ 2 "每周至少1次" 3 "每周1次" 4 "每月1~3次" 5 "几乎没有或者很少"
label values r1vgactx_e r2vgactx_e r3vgactx_e r4vgactx_e r5vgactx_e r6vgactx_e r7vgactx_e r8vgactx_e r9vgactx_e vgactx_e_

*****中等体力活动的频率
*r1mdactx_e r2mdactx_e r3mdactx_e r4mdactx_e r5mdactx_e r6mdactx_e r7mdactx_e r8mdactx_e r9mdactx_e
label values r1mdactx_e r2mdactx_e r3mdactx_e r4mdactx_e r5mdactx_e r6mdactx_e r7mdactx_e r8mdactx_e r9mdactx_e vgactx_e_

*****轻度体力活动的频率
*r1ltactx_e r2ltactx_e r3ltactx_e r4ltactx_e r5ltactx_e r6ltactx_e r7ltactx_e r8ltactx_e r9ltactx_e
label values r1ltactx_e r2ltactx_e r3ltactx_e r4ltactx_e r5ltactx_e r6ltactx_e r7ltactx_e r8ltactx_e r9ltactx_e vgactx_e_

*****过去12个月内是否喝过酒
*r1drink r2drink r3drink r4drink r5drink r6drink r7drink r8drink r9drink
label values r1drink r2drink r3drink r4drink r5drink r6drink r7drink r8drink r9drink yesno_

*****过去7天内饮酒的天数
*r2drinkd_e r3drinkd_e r4drinkd_e r5drinkd_e r6drinkd_e r7drinkd_e r8drinkd_e r9drinkd_e

*****前一周喝得最多的那一天所报告的饮酒量
*r2drinkn_e r3drinkn_e

*****过去7天内报告饮用的饮料数量
*r4drinkwn_e r5drinkwn_e r6drinkwn_e r7drinkwn_e r8drinkwn_e r9drinkwn_e

*****是否报告曾经吸烟
*r1smokev r2smokev r3smokev r4smokev r5smokev r6smokev r7smokev r8smokev r9smokev
label values r1smokev r2smokev r3smokev r4smokev r5smokev r6smokev r7smokev r8smokev r9smokev yesno_

*****现在是否报告吸烟
*r1smoken r2smoken r3smoken r4smoken r5smoken r6smoken r7smoken r8smoken r9smoken
label values r1smoken r2smoken r3smoken r4smoken r5smoken r6smoken r7smoken r8smoken r9smoken yesno_

*****平均每天抽多少支烟
*r1smokef r2smokef r3smokef r4smokef r5smokef r6smokef r7smokef r8smokef r9smokef

*****是否有私人保险
*r1hipriv r2hipriv r3hipriv r4hipriv r5hipriv r6hipriv r7hipriv r8hipriv r9hipriv
label values r1hipriv r2hipriv r3hipriv r4hipriv r5hipriv r6hipriv r7hipriv r8hipriv r9hipriv yesno_

*****认知/是否报告了认知测试
*r1cogimp r2cogimp r3cogimp r4cogimp r5cogimp r6cogimp r7cogimp r8cogimp r9cogimp
label values r1cogimp r2cogimp r3cogimp r4cogimp r5cogimp r6cogimp r7cogimp r8cogimp r9cogimp yesno_

*****认知/认知测试时是否有其他人在场
*r1cogothp r2cogothp r3cogothp r4cogothp r5cogothp r6cogothp r7cogothp r8cogothp r9cogothp
label values r1cogothp r2cogothp r3cogothp r4cogothp r5cogothp r6cogothp r7cogothp r8cogothp r9cogothp yesno_

*****认知/自我报告记忆
*r1slfmem r2slfmem r3slfmem r4slfmem r7slfmem r8slfmem r9slfmem
foreach i in 1 2 3 4 7 8 9 {
 recode r`i'slfmem (1=5) (2=4) (3=3) (4=2) (5=1)
}
label define slfmem_ 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好"
label values r1slfmem r2slfmem r3slfmem r4slfmem r7slfmem r8slfmem r9slfmem slfmem_

*****认知/由计算机还是面试官读单词回忆表
*r1readrc r2readrc r3readrc r4readrc r5readrc r6readrc r7readrc r8readrc r9readrc
label define readrc_ 1 "计算机" 2 "面试官"
label values r1readrc r2readrc r3readrc r4readrc r5readrc r6readrc r7readrc r8readrc r9readrc readrc_

*****认知/即时单词记忆
*r1imrc r2imrc r3imrc r4imrc r5imrc r6imrc r7imrc r8imrc r9imrc

*****认知/延迟词回忆
*r1dlrc r2dlrc r3dlrc r4dlrc r5dlrc r6dlrc r7dlrc r8dlrc r9dlrc

*****认知/总单词记忆
*r1tr20 r2tr20 r3tr20 r4tr20 r5tr20 r6tr20 r7tr20 r8tr20 r9tr20

*****认知/是否能够正确报告月
*r1mo r2mo r3mo r4mo r5mo r6mo r7mo r8mo r9mo

*****认知/是否能够正确报告今天的日
*r1dy r2dy r3dy r4dy r5dy r6dy r7dy r8dy r9dy

*****认知/是否能够正确报告今天的年
*r1yr r2yr r3yr r4yr r5yr r6yr r7yr r8yr r9yr

*****认知/是否能够正确报告周
*r1dw r2dw r3dw r4dw r5dw r6dw r7dw r8dw r9dw

*****认知/能够正确报告日期4分
*r1orient r2orient r3orient r4orient r5orient r6orient r7orient r8orient r9orient

*****认知/语言流利度分数
*r1verbf r2verbf r3verbf r4verbf r5verbf r7verbf r8verbf r9verbf

*****认知/数学表现能力
*r1numer_e r4numer_e r6numer_e r7numer_e r8numer_e r9numer_e

*****认知/能够记住执行两个任务中的第一个任务的正确操作的程度。
*r1prmt1 r2prmt1 r3prmt1 r4prmt1 r5prmt1

*****认知/能够记住执行正确的第二项任务的程度
*r1prmt2

*****认知/是否能够成功地从20开始连续倒数10个数字
*r7bwc20 r8bwc20 r9bwc20
label values r7bwc20 r8bwc20 r9bwc20 yesno_

*****认知/正确减法的个数
*r7ser7 r8ser7 r9ser7

*****认知/是否能够根据口头描述分别正确地命名剪刀
*r7scis r8scis r9scis

*****认知/是否能够根据口头描述分别正确地命名仙人掌
*r7cact r8cact r9cact

*****认知/是否能够正确说出英国现任君主
*r7mnrc r8mnrc r9mnrc

*****认知/是否能够正确说出英国首相
*r7pm r8pm r9pm

*****认知/是否能够正确说出美国总统
*r7pres r8pres r9pres

*****是否拥有他们目前的住所
*r1hownrnt r2hownrnt r3hownrnt r4hownrnt r5hownrnt r6hownrnt r7hownrnt r8hownrnt r9hownrnt
label values r1hownrnt r2hownrnt r3hownrnt r4hownrnt r5hownrnt r6hownrnt r7hownrnt r8hownrnt r9hownrnt yesno_

*****夫妻级是否拥有他们目前的住所
*h1hownrnt h2hownrnt h3hownrnt h4hownrnt h5hownrnt h6hownrnt h7hownrnt h8hownrnt h9hownrnt
label values h1hownrnt h2hownrnt h3hownrnt h4hownrnt h5hownrnt h6hownrnt h7hownrnt h8hownrnt h9hownrnt yesno_

*****家庭总财富
*h1atotb h2atotb h3atotb h4atotb h5atotb h6atotb h7atotb h8atotb h9atotb

*****税后个人收入
*r1itearn r2itearn r3itearn r4itearn r5itearn r6itearn r7itearn r8itearn r9itearn

*****夫妻层面的收入
*h1itot h2itot h3itot h4itot h5itot h6itot h7itot h8itot h9itot

*****家庭人均消费
*hh2cperc hh3cperc hh4cperc hh5cperc hh6cperc hh7cperc hh8cperc hh9cperc

*****家庭规模
*h1hhres h2hhres h3hhres h4hhres h5hhres h6hhres h7hhres h8hhres h9hhres

*****健在女儿数
*r1dau r2dau r3dau r4dau r5dau r6dau r7dau r8dau r9dau

*****健在儿子数
*r1son r2son r3son r4son r5son r6son r7son r8son r9son

*****健在子女数
*r1child r2child r3child r4child r5child r6child r7child r8child r9child

*****母亲是否还活着
*r1momliv r2momliv r3momliv r4momliv r5momliv r6momliv r7momliv r8momliv r9momliv
label values r1momliv r2momliv r3momliv r4momliv r5momliv r6momliv r7momliv r8momliv r9momliv yesno_

*****父亲是否还活着
*r1dadliv r2dadliv r3dadliv r4dadliv r5dadliv r6dadliv r7dadliv r8dadliv r9dadliv
label values r1dadliv r2dadliv r3dadliv r4dadliv r5dadliv r6dadliv r7dadliv r8dadliv r9dadliv yesno_

*****是否与子女同住
*h1coresd h2coresd h3coresd h4coresd h5coresd h6coresd h7coresd h8coresd h9coresd
label values h1coresd h2coresd h3coresd h4coresd h5coresd h6coresd h7coresd h8coresd h9coresd yesno_

*****是否为某个组织、俱乐部或社团的成员，并且在一年内至少参加一次委员会会议
*r1socyr r2socyr r3socyr r4socyr r5socyr r6socyr r7socyr r8socyr r9socyr
label values r1socyr r2socyr r3socyr r4socyr r5socyr r6socyr r7socyr r8socyr r9socyr yesno_

*****是否从事有偿工作
*r1work r2work r3work r4work r5work r6work r7work r8work r9work
label values r1work r2work r3work r4work r5work r6work r7work r8work r9work yesno_

*****是否自雇
*r1slfemp r2slfemp r3slfemp r4slfemp r5slfemp r6slfemp r7slfemp r8slfemp r9slfemp
label values r1slfemp r2slfemp r3slfemp r4slfemp r5slfemp r6slfemp r7slfemp r8slfemp r9slfemp yesno_

*****劳动力状况
*r1lbrf_e r2lbrf_e r3lbrf_e r4lbrf_e r5lbrf_e r6lbrf_e r7lbrf_e r8lbrf_e r9lbrf_e
label define lbrf_e_ 1 "雇佣" 2 "自雇" 3 "失业" 4 "半退休" 5 "退休" 6 "残疾" 7 "照顾家庭" 
label values r1lbrf_e r2lbrf_e r3lbrf_e r4lbrf_e r5lbrf_e r6lbrf_e r7lbrf_e r8lbrf_e r9lbrf_e lbrf_e_

*****自报是否退休
*r1retemp r2retemp r3retemp r4retemp r5retemp r6retemp r7retemp r8retemp r9retemp
label values r1retemp r2retemp r3retemp r4retemp r5retemp r6retemp r7retemp r8retemp r9retemp yesno_

*****退休年龄
*r1retage r2retage r3retage r4retage r5retage r6retage r7retage r8retage r9retage

*****再多活10年的概率
*r1liv10 r2liv10 r3liv10 r4liv10 r5liv10 r6liv10 r7liv10 r8liv10 r9liv10

*****目前是否在无残疾情况下领取公共养老金
*r1pubpen r2pubpen r3pubpen r4pubpen r5pubpen r6pubpen r7pubpen r8pubpen r9pubpen
label values r1pubpen r2pubpen r3pubpen r4pubpen r5pubpen r6pubpen r7pubpen r8pubpen r9pubpen yesno_

*****目前是否领取任何私人或雇主养老金
*r1peninc r2peninc r3peninc r4peninc r5peninc r6peninc r7peninc r8peninc r9peninc
label values r1peninc r2peninc r3peninc r4peninc r5peninc r6peninc r7peninc r8peninc r9peninc yesno_

*****是否是职业养老金计划的成员
*r1jcpen r2jcpen r3jcpen r4jcpen r5jcpen r6jcpen r7jcpen r8jcpen r9jcpen
label values r1jcpen r2jcpen r3jcpen r4jcpen r5jcpen r6jcpen r7jcpen r8jcpen r9jcpen yesno_

*****第一次行走速度
*r1wspeed1 r2wspeed1 r3wspeed1 r4wspeed1 r5wspeed1 r6wspeed1 r7wspeed1 r8wspeed1 r9wspeed1

*****第二次行走速度
*r1wspeed2 r2wspeed2 r3wspeed2 r4wspeed2 r5wspeed2 r6wspeed2 r7wspeed2 r8wspeed2 r9wspeed2

*****行走速度的平均值
*r1wspeed r2wspeed r3wspeed r4wspeed r5wspeed r6wspeed r7wspeed r8wspeed r9wspeed

*****是否愿意并且能够完成步行速度测试
*r1walkcomp r2walkcomp r3walkcomp r4walkcomp r5walkcomp r6walkcomp r7walkcomp r8walkcomp r9walkcomp
label values r1walkcomp r2walkcomp r3walkcomp r4walkcomp r5walkcomp r6walkcomp r7walkcomp r8walkcomp r9walkcomp yesno_

*****第一次收缩压读数
*r2systo1 r4systo1 r6systo1 r8systo1

*****第二次收缩压读数
*r2systo2 r4systo2 r6systo2 r8systo2

*****第三次收缩压读数
*r2systo3 r4systo3 r6systo3 r8systo3

*****收缩压读数的平均值
*r2systo r4systo r6systo r8systo

*****第一次舒张压读数
*r2diasto1 r4diasto1 r6diasto1 r8diasto1

*****第二次舒张压读数
*r2diasto2 r4diasto2 r6diasto2 r8diasto2

*****第三次舒张压读数
*r2diasto3 r4diasto3 r6diasto3 r8diasto3

*****舒张压读数的平均值
*r2diasto r4diasto r6diasto r8diasto

*****第一次脉冲读数
*r2pulse1 r4pulse1 r6pulse1 r8pulse1

*****第二次脉冲读数
*r2pulse2 r4pulse2 r6pulse2 r8pulse2

*****第三次脉冲读数
*r2pulse3 r4pulse3 r6pulse3 r8pulse3

*****脉冲读数的平均值
*r2pulse r4pulse r6pulse r8pulse

*****优势手
*r2domhand r4domhand r6domhand r8domhand
label define domhand_ 1 "右手" 2 "左手"
label values r2domhand r4domhand r6domhand r8domhand domhand_

*****左手第一次握力测量
*r2lgrip1 r4lgrip1 r6lgrip1 r8lgrip1

*****左手第二次握力测量
*r2lgrip2 r4lgrip2 r6lgrip2 r8lgrip2

*****左手第三次握力测量
*r2lgrip3 r4lgrip3 r6lgrip3 r8lgrip3

*****右手第一次握力测量
*r2rgrip1 r4rgrip1 r6rgrip1 r8rgrip1

*****右手第二次握力测量
*r2rgrip2 r4rgrip2 r6rgrip2 r8rgrip2

*****右手第三次握力测量
*r2rgrip3 r4rgrip3 r6rgrip3 r8rgrip3

*****左手的最大握力测量值
*r2lgrip r4lgrip r6lgrip r8lgrip

*****右手的最大握力测量值
*r2rgrip r4rgrip r6rgrip r8rgrip

*****优势手的最大测量值
*r2gripsum r4gripsum r6gripsum r8gripsum

*****测量身高
*r2mheight r4mheight r6mheight r8mheight

*****测量坐高
*r2msithght r4msithght

*****测量体重
*r2mweight r4mweight r6mweight r8mweight r9mweight

*****测量BMI
*r2mbmi r4mbmi r6mbmi r8mbmi

*****测量BMI分类
*r2mbmicat r4mbmicat r6mbmicat r8mbmicat
label define mbmicat_ 1 "体重不足" 2 "正常体重" 3 "肥胖前期" 4 "肥胖1级" ///
  5 "肥胖2级" 6 "肥胖3级"
label values r2mbmicat r4mbmicat r6mbmicat r8mbmicat mbmicat_ 

*****是否愿意和能够完成站立高度测量
*r2htcomp r4htcomp r6htcomp
label values r2htcomp r4htcomp r6htcomp yesno_

*****是否愿意和能够完成站立坐姿高度测量
*r2sthtcomp r4sthtcomp
label values r2sthtcomp r4sthtcomp yesno_

*****是否愿意和能够完成站立体重测量
*r2wtcomp r4wtcomp r6wtcomp r8wtcomp r9wtcomp
label values r2wtcomp r4wtcomp r6wtcomp r8wtcomp r9wtcomp yesno_

*****测量的腰围
*r2mwaist r4mwaist r6mwaist

*****测量的臀围
*r2mhip r4mhip

*****测量的腰臀比
*r2mwhratio r4mwhratio

*****是否愿意和能够完成腰围和臀围测量
*r2watcomp r4watcomp r6watcomp
label values r2watcomp r4watcomp r6watcomp yesno_

*****是否愿意和能够完成腰围和臀围测量
*r2hipcomp r4hipcomp
label values r2hipcomp r4hipcomp yesno_

*****第一次呼吸峰流速
*r2puff1 r4puff1

*****第二次呼吸峰流速
*r2puff2 r4puff2

*****第三次呼吸峰流速
*r2puff3 r4puff3

*****呼吸峰流速
*r2puff r4puff

*****第一次强制肺活量
*r2fvc1 r4fvc1

*****第二次强制肺活量
*r2fvc2 r4fvc2

*****第三次强制肺活量
*r2fvc3 r4fvc3

*****强制肺活量最大值
*r2fvc r4fvc

*****强制肺活量最大值(仅限wave6)
*r6fvc_e

*****第一次用力呼气量
*r2fev1 r4fev1

*****第二次用力呼气量
*r2fev2 r4fev2

*****第三次用力呼气量
*r2fev3 r4fev3

*****用力呼气量最大值
*r2fev r4fev

*****用力呼气量最大值
*r6fev_e

*****是否愿意并能够完成呼吸测试
*r2puffcomp r4puffcomp
label values r2puffcomp r4puffcomp yesno_

*****过去三周内是否有呼吸道感染
*r2puffrinf r4puffrinf
label values r2puffrinf r4puffrinf yesno_

*****过去24小时内是否使用了吸入器、喷雾器或任何药物来呼吸
*r2puffinhl r4puffinhl
label values r2puffinhl r4puffinhl yesno_

*****是否愿意并且能够完成Wave 6中的呼吸测试
*r6puffcomp_e
label values r6puffcomp_e yesno_

*****Wave 6过去三周内是否有呼吸道感染
*r6puffrinf_e
label values r6puffrinf_e yesno_

*****Wave 6的过去24小时内是否使用了吸入器、呼吸器或任何药物来呼吸
*r6puffinhl_e
label values r6puffinhl_e yesno_

*****双脚并拢站立平衡测试的时间
*r2sbstan r4sbstan r6sbstan

*****双脚半前后站立平衡测试的时间
*r2semitan r4semitan r6semitan

*****双脚前后成一直线站立平衡测试的时间
*r2fulltan_e r4fulltan_e r6fulltan_e

*****双脚并拢站立是否保持10秒平衡
*r2sbsdone r4sbsdone r6sbsdone
label values r2sbsdone r4sbsdone r6sbsdone yesno_

*****双脚半前后站立是否保持10秒平衡
*r2semidone r4semidone r6semidone
label values r2semidone r4semidone r6semidone yesno_

*****双脚前后成一直线站立是否保持10秒平衡
*r2fulldone_e r4fulldone_e r6fulldone_e
label values r2fulldone_e r4fulldone_e r6fulldone_e yesno_

*****是否愿意并能够完成双脚并拢站立平衡测试
*r2sbscomp r4sbscomp r6sbscomp
label values r2sbscomp r4sbscomp r6sbscomp yesno_

*****是否愿意并能够完成双脚半前后站立平衡测试
*r2semicomp r4semicomp r6semicomp
label values r2semicomp r4semicomp r6semicomp yesno_

*****是否愿意并能够完成双脚前后成一直线站立平衡测试
*r2fullcomp_e r4fullcomp_e r6fullcomp_e
label values r2fullcomp_e r4fullcomp_e r6fullcomp_e yesno_

*****是否睁着眼睛抬腿30秒
*r2legrores r4legrores r6legrores
recode r2legrores r4legrores r6legrores (1=1) (2=0)
label values r2legrores r4legrores r6legrores yesno_

*****是否闭着眼睛抬腿30秒
*r2legrsres r4legrsres r6legrsres
recode r2legrores r4legrores r6legrores (1=1) (2=0)
label values r2legrsres r4legrsres r6legrsres yesno_

*****睁着眼睛抬腿时间
*r2legrosec r4legrosec r6legrosec

*****闭着眼睛抬腿时间
*r2legrssec r4legrssec r6legrssec

*****是否愿意并且能够睁着眼睛完成抬腿测试
*r2legrocomp r4legrocomp r6legrocomp
label values r2legrocomp r4legrocomp r6legrocomp yesno_

*****是否愿意并且能够闭着眼睛完成抬腿测试
*r2legrscomp r4legrscomp r6legrscomp
label values r2legrscomp r4legrscomp r6legrscomp yesno_

*****是否愿意并且能够在不使用手臂的情况下完成单个椅架
*r2chr1comp r4chr1comp r6chr1comp
label values r2chr1comp r4chr1comp r6chr1comp yesno_

*****完成5个椅子架所花费的秒数
*r2chr5sec r4chr5sec r6chr5sec

*****完成10个椅子架所花费的秒数
*r2chr10sec r4chr10sec r6chr10sec

*****完成的椅架总数
*r2chrnum r4chrnum r6chrnum

*****是否愿意并且能够在不使用手臂的情况下完成5或10张椅子的站立测试
*r2chrcomp r4chrcomp r6chrcomp
label values r2chrcomp r4chrcomp r6chrcomp yesno_

*****在16岁之前是否因为健康问题缺课一个月或更长时间
*ramischlth 
label values ramischlth  yesno_

*****在16岁之前是否受到过父母的身体虐待
*rapabused 
label values rapabused yesno_

*****父母是否在16岁之前酗酒、吸毒或有精神健康问题
*rapadrug
label values rapadrug yesno_

*****是否曾经经历过重大火灾、洪水、地震或其他自然灾害
*ranadise
label values ranadise yesno_

*****是否曾经在战斗中使用过武器或在战斗中被射击过
*racombate
label values racombate yesno_

*****是否是严重身体攻击或攻击的受害者
*raattacke
label values raattacke yesno_

*****是否有过威胁生命的疾病或事故
*ralifethe
label values ralifethe yesno_

*****在16岁之前是否经历过重大火灾、洪水、地震或其他自然灾害
*ranadisch
label values ranadisch yesno_

*****在16岁之前是否曾经在战斗中使用过武器或在战斗中被射击
*racombatch
label values racombatch yesno_

*****在16岁之前是否遭受过严重的身体攻击或攻击
*raattackch
label values raattackch yesno_

*****在16岁之前是否有过威胁生命的疾病或事故
*ralifethch
label values ralifethch yesno_

*****是否经历过严重的经济困难
*rasfnhe
label values rasfnhe yesno_

*****在16岁之前是否经历过严重的经济困难
*rasfnhch
label values rasfnhch yesno_

*****在16岁之前是否经历过困难的生活安排
*ralivdiffch
label values ralivdiffch yesno_

*****父母是否在16岁之前分居或离婚
*rapadivch
label values rapadivch yesno_

*****在16岁之前是否与母亲分开超过6个月
*rasepmom
label values rasepmom yesno_

*****一生中经历过多少压力事件的计数
*ralsevent_e

*****10岁时被调查者家庭在住所中占用的卧室数量
*raccrooms

*****10岁时家中居住的人数
*raccnpeople

*****10岁时居住的地方的书籍数量
*raccbooks
label define raccbooks_ 1 "0~10" 2 "22~25" 3 "26~100" 4 "101~200" 5 "200+"
label values raccbooks raccbooks_

*****10岁时住所是否有固定的浴室
*raccbath
label values raccbath yesno_

*****10岁其住所是否有冷自来水供应
*raccwaterc
label values raccwaterc yesno_

*****10岁时其住所是否有热水供应
*raccwaterh
label values raccwaterh yesno_

*****10岁的住所是否有内部厕所
*racctoilet
label values racctoilet yesno_

*****10岁时的住所是否有集中供暖
*raccheating
label values raccheating yesno_

*****14岁时主要家庭供养者的职业
*ramaoccup
label define ramaoccup_ 1 "白领" 2 "蓝领" 3 "军人" 4 "其他"
label values ramaoccup ramaoccup_

*****16岁之前的自评健康状况
*rachshlt
recode rachshlt (1=5) (2=4) (3=3) (4=2) (5=1) (6=0)
label define rachshlt_ 0 "健康状况变化很大" 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好" 
label values rachshlt rachshlt_

*****16岁前是否患有传染病
*rachinfect 
label values rachinfect yesno_

*****16岁前是否患有患有哮喘
*rachasthma 
label values rachasthma yesno_

*****16岁前是否患有除哮喘以外的呼吸系统疾病(如支气管炎)
*rachresp
label values rachresp yesno_

*****16岁前是否患有除哮喘以外的过敏
*rachallerg
label values rachallerg yesno_

*****16岁前是否患有慢性耳部问题
*rachearpr
label values rachearpr yesno_

*****16岁前是否患有严重的头痛或偏头痛
*rachhdache
label values rachhdache yesno_

*****16岁前是否患有癫痫、发作或癫痫发作
*rachepilepsy
label values rachepilepsy yesno_

*****16岁前是否患有情绪、紧张或精神问题
*rachpsych
label values rachpsych yesno_

*****16岁前是否患有骨折
*rachbones
label values rachbones yesno_

*****16岁前是否患有阑尾炎
*rachappdcts
label values rachappdcts yesno_

*****16岁前是否患有儿童糖尿病或高血糖
*rachdiab
label values rachdiab yesno_

*****16岁前是否患有心脏病
*rachheart
label values rachheart yesno_

*****16岁前是否患有白血病或淋巴瘤
*rachleuk
label values rachleuk yesno_

*****16岁前是否患有癌症或恶性肿瘤
*rachcancer
label values rachcancer yesno_

*****CESD
*r1cesd r2cesd r3cesd r4cesd r5cesd r6cesd r7cesd r8cesd r9cesd

*****是否抑郁
*r5depressive r6depressive r7depressive r8depressive r9depressive
forvalues i=5/9 {
  recode r`i'cesd (0/2=0) (3/8=1),gen(r`i'depressive)
  label values r`i'depressive yesno_
}

*****昨天感到开心吗？
*r6ydhappy_e r7ydhappy_e r8ydhappy_e r9ydhappy_e

****生活满意度
*r2satlife_e r3satlife_e r4satlife_e r5satlife_e r6satlife_e r7satlife_e r8satlife_e r9satlife_e
*r2satlifez r3satlifez r4satlifez r5satlifez r6satlifez r7satlifez r8satlifez r9satlifez
forvalues i=2/9 {
 recode r`i'satlife_e (1=7) (2=6) (3=5) (4=4) (5=3) (6=2) (7=1)
}
label define satlife_e_ 1 "强烈不同意" 2 "不同意" 3 "有点不同意" 4 "中立" ///
  5 "有些同意" 6 "同意" 7 "强烈不同意"
label values r2satlife_e r3satlife_e r4satlife_e r5satlife_e r6satlife_e r7satlife_e r8satlife_e r9satlife_e satlife_e_

*****自己在社会中的地位的评价
*r1cantril r2cantril r3cantril r4cantril r5cantril r6cantril r7cantril r8cantril r9cantril

*****认知障碍
*r7dementia r8dementia r9dementia
forvalues i=7/9 {
  egen r`i'tici27=rowtotal(r`i'tr20 r`i'bwc20 r`i'ser7),mi
  recode r`i'tici27 (0/6=1) (7/11=2) (12/27=3),gen(r`i'dementia)	
}
label define dementia_ 1 "痴呆症" 2 "非痴呆的认知障碍" 3 "认知正常"
label values r7dementia r8dementia r9dementia dementia_

*****记忆的z标准化
*r5memory_z r6memory_z r7memory_z r8memory_z r9memory_z 
*r5orient_z r6orient_z r7orient_z r8orient_z r9orient_z 
*r5executive_z r6executive_z r7executive_z r8executive_z r9executive_z 
*r5tcog_z_z r6tcog_z_z r7tcog_z_z r8tcog_z_z r9tcog_z_z 

forvalues i=5/9 {
 egen r`i'mean_memory=mean(r5tr20)
 egen r`i'sd_memory=sd(r5tr20)
 gen r`i'memory_z=(r`i'tr20-r`i'mean_memory)/r`i'sd_memory
}

*****定向的z标准化(ref基线)
forvalues i=5/9 {
 egen r`i'mean_orient=mean(r5orient)
 egen r`i'sd_orient=sd(r5orient)
 gen r`i'orient_z=(r`i'orient-r`i'mean_orient)/r`i'sd_orient
}

*****执行的z标准化(ref基线)
forvalues i=5/9 {
 egen r`i'mean_executive=mean(r5verbf)
 egen r`i'executive_sd=sd(r5verbf)
 gen r`i'executive_z=(r`i'executive-r`i'mean_executive)/r`i'executive_sd
}
*****总体认知能力z标准化(ref基线)
forvalues i=5/9 {
 egen r`i'tcog_z=rowmean(r`i'memory_z r`i'orient_z r`i'executive_z)
 egen r`i'tcog_z_mean=mean(r5tcog_z)
 egen r`i'tcog_z_sd=sd(r5tcog_z)
 gen r`i'tcog_z_z=(r`i'tcog_z-r`i'tcog_z_mean)/r`i'tcog_z_sd 
}

*****按需求间隔依赖性分类划分的功能依赖性
*r5dependency r6dependency r7dependency r8dependency r9dependency 
label define dependency_ 0 "独立" 1 "低依赖性" 2 "中等依赖性" 3 "高依赖性"
forvalues i=5/9 {
  gen r`i'dependency=.
  replace r`i'dependency=0 if r`i'batha==0 & r`i'moneya==0 & r`i'shopa==0 & r`i'phonea==0 & ///
  r`i'mealsa==0 & r`i'medsa==0 & r`i'eata==0 & r`i'dressa==0 & r`i'beda==0 & r`i'toilta==0 & r`i'walkra==0 
  replace r`i'dependency=1 if r`i'batha==1 | r`i'moneya==1 | r`i'shopa==1 | r`i'phonea==1 
  replace r`i'dependency=2 if (r`i'mealsa==1 | r`i'medsa==1) & (r`i'batha==0 & r`i'moneya==0 & r`i'shopa==0 & r`i'phonea==0) 
  replace r`i'dependency=3 if (r`i'eata==1 | r`i'dressa==1 | r`i'beda==1 | r`i'toilta==1 | r`i'walkra==1) ///
  & (r`i'mealsa==0 & r`i'medsa==0 & r`i'batha==0 & r`i'moneya==0 & r`i'shopa==0 & r`i'phonea==0)  
  label values r`i'dependency dependency_
}

*****衰弱指数
*r5frailty r6frailty r7frailty r8frailty r9frailty 
*衰弱定义为衰弱指数≥25，非衰弱定义为衰弱指数<25
forvalues i=5/9 {
  gen r`i'memory1=r`i'memrye 
  replace r`i'memory1=1 if r`i'alzhe==1 | r`i'demene==1
}

forvalues i=5/9 {
  recode r`i'sight (0/1=1) (2=0.75) (3=0.5) (4=0.25) (5=0),gen(r`i'sight1)
}

forvalues i=5/9 {
  recode r`i'hearing (1=1) (2=0.75) (3=0.5) (4=0.25) (5=0),gen(r`i'hearing1)
}

forvalues i=5/9 {
  recode r`i'shlt (0/1=1) (2=0.75) (3=0.5) (4=0.25) (5=0),gen(r`i'shlt1)
}

forvalues i=7/9 {
  egen r`i'cog_total=rowtotal(r`i'tr20 r`i'mo r`i'dy r`i'yr r`i'dw r`i'ser7)
  gen r`i'cogition=(29-r`i'tr20 - r`i'mo - r`i'dy - r`i'yr - r`i'dw - r`i'ser7)/29
}

forvalues i=7/9 {
egen r`i'frailty=rowtotal(r`i'hibpe r`i'diabe r`i'hearte r`i'stroke r`i'cancre ///
  r`i'arthre r`i'lunge r`i'psyche r`i'memory1 r`i'sight1 r`i'hearing1 r`i'shlt1 ///
  r`i'dressa r`i'batha r`i'eata r`i'beda r`i'toilta r`i'moneya r`i'medsa r`i'shopa /// 
  r`i'mealsa r`i'walk100a r`i'chaira r`i'climsa r`i'lifta r`i'dimea r`i'stoopa ///
  r`i'armsa r`i'depressive r`i'cogition),mi
replace r`i'frailty=r`i'frailty/30*100
}


*****感到缺乏陪伴的频率
*r5complac r6complac r7complac r8complac r9complac 
label define lone_ 1 "很少或从不" 2 "有时" 3 "经常"
label values r5complac r6complac r7complac r8complac r9complac lone_

*****感到被忽略的频率
*r5leftout r6leftout r7leftout r8leftout r9leftout 
label values r5leftout r6leftout r7leftout r8leftout r9leftout  lone_

*****感到被他人孤立的频率
*r5isolate r6isolate r7isolate r8isolate r9isolate 
label values r5isolate r6isolate r7isolate r8isolate r9isolate  lone_

*****感觉与周围人合拍的频率
*r5intune r6intune r7intune r8intune r9intune 
label values r5intune r6intune r7intune r8intune r9intune lone_

*****四个不同的孤独问题的平均值
*r5lnlys r6lnlys r7lnlys r8lnlys r9lnlys 

*****三个不同的孤独问题的平均值
*r5lnlys3 r6lnlys3 r7lnlys3 r8lnlys3 r9lnlys3

*****是否有爱好
*r5hobby r6hobby r7hobby r8hobby r9hobby
label values r5hobby r6hobby r7hobby r8hobby r9hobby yesno_

*****政党、工会或环保组织的成员
*r5group1 r6group1 r7group1 r8group1 r9group1
label values r5group1 r6group1 r7group1 r8group1 r9group1 yesno_

*****租户团体、居民团体或邻里守望组织的成员
*r5group2 r6group2 r7group2 r8group2 r9group2
label values r5group2 r6group2 r7group2 r8group2 r9group2 yesno_

*****教堂或其他宗教团体的成员
*r5group3 r6group3 r7group3 r8group3 r9group3
label values r5group3 r6group3 r7group3 r8group3 r9group3 yesno_

*****慈善协会的成员
*r5group4 r6group4 r7group4 r8group4 r9group4
label values r5group4 r6group4 r7group4 r8group4 r9group4 yesno_

*****教育、艺术或音乐团体或夜校的成员
*r5group5 r6group5 r7group5 r8group5 r9group5
label values r5group5 r6group5 r7group5 r8group5 r9group5 yesno_

*****社交俱乐部的成员
*r5group6 r6group6 r7group6 r8group6 r9group6
label values r5group6 r6group6 r7group6 r8group6 r9group6 yesno_

*****体育俱乐部、健身房或锻炼班的成员
*r5group7 r6group7 r7group7 r8group7 r9group7
label values r5group7 r6group7 r7group7 r8group7 r9group7 yesno_

*****其他组织、俱乐部或社团的成员
*r5group8 r6group8 r7group8 r8group8 r9group8
label values r5group8 r6group8 r7group8 r8group8 r9group8 yesno_

*****是否使用天然气
*r5usesgas r6usesgas r7usesgas r8usesgas r9usesgas
label values r5usesgas r6usesgas r7usesgas r8usesgas r9usesgas yesno_

*****是否使用电力
*r5useselec r6useselec r7useselec r8useselec r9useselec
label values r5useselec r6useselec r7useselec r8useselec r9useselec yesno_

*****是否使用煤
*r5usescoal r6usescoal r7usescoal r8usescoal r9usescoal
label values r5usescoal r6usescoal r7usescoal r8usescoal r9usescoal yesno_

*****是否使用煤油
*r5usespara r6usespara r7usespara r8usespara r9usespara
label values r5usespara r6usespara r7usespara r8usespara r9usespara yesno_

*****是否使用石油
*r5usesoil r6usesoil r7usesoil r8usesoil r9usesoil
label values r5usesoil r6usesoil r7usesoil r8usesoil r9usesoil yesno_

*****是否使用木材
*r5useswood r6useswood r7useswood r8useswood r9useswood
label values r5useswood r6useswood r7useswood r8useswood r9useswood yesno_

*****是否使用其他燃料
*r5usesotherf r6usesotherf r7usesotherf r8usesotherf r9usesotherf
label values r5usesotherf r6usesotherf r7usesotherf r8usesotherf r9usesotherf yesno_

*****幸福感: 总体而言，你昨天的快乐感受如何？
*r6happiness r7happiness r8happiness r9happiness

*****是否至少每周使用互联网
*r6internet r7internet r8internet r9internet
label values r6internet r7internet r8internet r9internet yesno_

*****牙齿数量
*r7teeth_num
label define teeth_num 1 "没有" 2 "1~9颗" 3 "10~19颗" 4 "20颗以上"
label values r7teeth_num teeth_num

*****是否佩戴假牙
*r7teeth
label values r7teeth yesno_


keep h1atotb h2atotb h3atotb h4atotb h5atotb h6atotb h7atotb h8atotb h9atotb  ///
h1coresd h2coresd h3coresd h4coresd h5coresd h6coresd h7coresd h8coresd h9coresd ///
h1hhres h2hhres h3hhres h4hhres h5hhres h6hhres h7hhres h8hhres h9hhres ///
h1hownrnt h2hownrnt h3hownrnt h4hownrnt h5hownrnt h6hownrnt h7hownrnt h8hownrnt h9hownrnt ///
h1itot h2itot h3itot h4itot h5itot h6itot h7itot h8itot h9itot ///
hh1hhid hh2hhid hh3hhid hh4hhid hh5hhid hh6hhid hh7hhid hh8hhid hh9hhid ///
hh1hhidc hh2hhidc hh3hhidc hh4hhidc hh5hhidc hh6hhidc hh7hhidc hh8hhidc hh9hhidc ///
hh2cperc hh3cperc hh4cperc hh5cperc hh6cperc hh7cperc hh8cperc hh9cperc ///
idauniqc ///
inw1 inw2 inw3 inw4 inw5 inw6 inw7 inw8 inw9 ///
inw1sc inw2sc inw3sc inw4sc inw5sc inw6sc inw7sc inw8sc inw9sc ///
r1adltot6 r2adltot6 r3adltot6 r4adltot6 r5adltot6 r6adltot6 r7adltot6 r8adltot6 r9adltot6 ///
r1agey r2agey r3agey r4agey r5agey r6agey r7agey r8agey r9agey ///
r1alzhe r2alzhe r3alzhe r4alzhe r5alzhe r6alzhe r7alzhe r8alzhe r9alzhe ///
r1angin r2angin r3angin r4angin r5angin r6angin r7angin r8angin r9angin ///
r1angine r2angine r3angine r4angine r6angine r7angine r8angine r9angine ///
r1armsa r2armsa r3armsa r4armsa r5armsa r6armsa r7armsa r8armsa r9armsa ///
r1arthre r2arthre r3arthre r4arthre r5arthre r6arthre r7arthre r8arthre r9arthre ///
r1asthmae r2asthmae r3asthmae r4asthmae r5asthmae r6asthmae r7asthmae r8asthmae r9asthmae ///
r1batha r2batha r3batha r5batha r6batha r7batha r8batha r9batha ///
r1beda r2beda r3beda r4beda r5beda r6beda r7beda r8beda r9beda ///
r1breath_e r2breath_e r3breath_e r4breath_e r5breath_e ///
r1cancre r2cancre r3cancre r4cancre r5cancre r6cancre r7cancre r8cancre r9cancre ///
r1cantril r2cantril r3cantril r4cantril r5cantril r6cantril r7cantril r8cantril r9cantril ///
r1catracte r2catracte r3catracte r4catracte r5catracte r6catracte r7catracte r8catracte r9catracte ///
r1catrcte r2catrcte r3catrcte r4catrcte r5catrcte r6catrcte r7catrcte r8catrcte r9catrcte ///
r1cesd r2cesd r3cesd r4cesd r5cesd r6cesd r7cesd r8cesd r9cesd ///
r1chaira r2chaira r3chaira r4chaira r5chaira r6chaira r7chaira r8chaira r9chaira ///
r1child r2child r3child r4child r5child r6child r7child r8child r9child ///
r1clim1a r2clim1a r3clim1a r4clim1a r5clim1a r6clim1a r7clim1a r8clim1a r9clim1a ///
r1climsa r2climsa r3climsa r4climsa r5climsa r6climsa r7climsa r8climsa r9climsa ///
r1cogimp r2cogimp r3cogimp r4cogimp r5cogimp r6cogimp r7cogimp r8cogimp r9cogimp ///
r1cogothp r2cogothp r3cogothp r4cogothp r5cogothp r6cogothp r7cogothp r8cogothp r9cogothp ///
r1conhrtfe r2conhrtfe r3conhrtfe r4conhrtfe r5conhrtfe r6conhrtfe r7conhrtfe r8conhrtfe r9conhrtfe ///
r1dadliv r2dadliv r3dadliv r4dadliv r5dadliv r6dadliv r7dadliv r8dadliv r9dadliv ///
r1dau r2dau r3dau r4dau r5dau r6dau r7dau r8dau r9dau ///
r1demene r2demene r3demene r4demene r5demene r6demene r7demene r8demene r9demene ///
r1diabe r2diabe r3diabe r4diabe r5diabe r6diabe r7diabe r8diabe r9diabe ///
r1dimea r2dimea r3dimea r4dimea r5dimea r6dimea r7dimea r8dimea r9dimea ///
r1dlrc r2dlrc r3dlrc r4dlrc r5dlrc r6dlrc r7dlrc r8dlrc r9dlrc ///
r1dressa r2dressa r3dressa r4dressa r5dressa r6dressa r7dressa r8dressa r9dressa ///
r1drink r2drink r3drink r4drink r5drink r6drink r7drink r8drink r9drink ///
r1dsight r2dsight r3dsight r4dsight r5dsight r6dsight r7dsight r8dsight r9dsight ///
r1dw r2dw r3dw r4dw r5dw r6dw r7dw r8dw r9dw ///
r1dy r2dy r3dy r4dy r5dy r6dy r7dy r8dy r9dy ///
r1eata r2eata r3eata r4eata r5eata r6eata r7eata r8eata r9eata ///
r1fagey r2fagey r3fagey r4fagey r5fagey r6fagey r7fagey r8fagey r9fagey ///
r1fall r2fall r3fall r5fall r6fall r7fall r8fall r9fall ///
r1falleq r2falleq r3falleq r4falleq r5falleq r6falleq r7falleq r8falleq r9falleq ///
r1fallinj r2fallinj r3fallinj r4fallinj r5fallinj r6fallinj r7fallinj r8fallinj r9fallinj ///
r1fallnum r2fallnum r3fallnum r5fallnum r6fallnum r7fallnum r8fallnum r9fallnum ///
r1hearing r2hearing r3hearing r4hearing r5hearing r6hearing r7hearing r8hearing r9hearing ///
r1hearte r3hearte r4hearte r5hearte r6hearte r7hearte r8hearte r9hearte  ///
r1hibpe r2hibpe r3hibpe r4hibpe r5hibpe r6hibpe r7hibpe r8hibpe r9hibpe ///
r1hipe r2hipe r3hipe r4hipe r5hipe r6hipe r7hipe r8hipe r9hipe ///
r1hipr r2hipr ///
r1hipre r2hipre r3hipre r4hipre r5hipre r6hipre r7hipre r8hipre r9hipre ///
r1hipriv r2hipriv r3hipriv r4hipriv r5hipriv r6hipriv r7hipriv r8hipriv r9hipriv ///
r1housewka r2housewka r3housewka r4housewka r5housewka r6housewka r7housewka r8housewka r9housewka ///
r1hownrnt r2hownrnt r3hownrnt r4hownrnt r5hownrnt r6hownrnt r7hownrnt r8hownrnt r9hownrnt ///
r1hrtatt r2hrtatt r3hrtatt r4hrtatt r5hrtatt r6hrtatt r7hrtatt r8hrtatt r9hrtatt ///
r1hrtatte r2hrtatte r3hrtatte r4hrtatte r5hrtatte r6hrtatte r7hrtatte r8hrtatte r9hrtatte ///
r1hrtmre r2hrtmre r3hrtmre r4hrtmre r5hrtmre r6hrtmre r7hrtmre r8hrtmre r9hrtmre ///
r1hrtrhme r2hrtrhme r3hrtrhme r4hrtrhme r5hrtrhme r6hrtrhme r7hrtrhme r8hrtrhme r9hrtrhme ///
r1imrc r2imrc r3imrc r4imrc r5imrc r6imrc r7imrc r8imrc r9imrc ///
r1itearn r2itearn r3itearn r4itearn r5itearn r6itearn r7itearn r8itearn r9itearn ///
r1iwindm r2iwindm r3iwindm r4iwindm r5iwindm r6iwindm r7iwindm r8iwindm r9iwindm ///
r1iwindy r2iwindy r3iwindy r4iwindy r5iwindy r6iwindy r7iwindy r8iwindy r9iwindy ///
r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat r6iwstat r7iwstat r8iwstat r9iwstat ///
r1jcpen r2jcpen r3jcpen r4jcpen r5jcpen r6jcpen r7jcpen r8jcpen r9jcpen ///
r1jointre r2jointre r3jointre r4jointre r5jointre r6jointre r7jointre r8jointre r9jointre ///
r1lbrf_e r2lbrf_e r3lbrf_e r4lbrf_e r5lbrf_e r6lbrf_e r7lbrf_e r8lbrf_e r9lbrf_e ///
r1lifta r2lifta r3lifta r4lifta r5lifta r6lifta r7lifta r8lifta r9lifta ///
r1liv10 r2liv10 r3liv10 r4liv10 r5liv10 r6liv10 r7liv10 r8liv10 r9liv10 ///
r1ltactx_e r2ltactx_e r3ltactx_e r4ltactx_e r5ltactx_e r6ltactx_e r7ltactx_e r8ltactx_e r9ltactx_e ///
r1lunge r2lunge r3lunge r4lunge r5lunge r6lunge r7lunge r8lunge r9lunge ///
r1mapa r2mapa r3mapa r4mapa r5mapa r6mapa r7mapa r8mapa r9mapa ///
r1mdactx_e r2mdactx_e r3mdactx_e r4mdactx_e r5mdactx_e r6mdactx_e r7mdactx_e r8mdactx_e r9mdactx_e ///
r1mealsa r2mealsa r3mealsa r4mealsa r5mealsa r6mealsa r7mealsa r8mealsa r9mealsa ///
r1medsa r2medsa r3medsa r4medsa r5medsa r6medsa r7medsa r8medsa r9medsa ///
r1memrye r2memrye r3memrye r4memrye r5memrye r6memrye r7memrye r8memrye r9memrye ///
r1mo r2mo r3mo r4mo r5mo r6mo r7mo r8mo r9mo ///
r1momliv r2momliv r3momliv r4momliv r5momliv r6momliv r7momliv r8momliv r9momliv ///
r1moneya r2moneya r3moneya r4moneya r5moneya r6moneya r7moneya r8moneya ///
r1mstath r2mstath r3mstath r4mstath r5mstath r6mstath r7mstath r8mstath r9mstath ///
r1nsight r2nsight r3nsight r4nsight r5nsight r6nsight r7nsight r8nsight r9nsight ///
r1numer_e r4numer_e r6numer_e r7numer_e r8numer_e r9numer_e ///
r1orient r2orient r3orient r4orient r5orient r6orient r7orient r8orient r9orient ///
r1osteoe r2osteoe r3osteoe r4osteoe r5osteoe r6osteoe r7osteoe r8osteoe r9osteoe ///
r1painfr r2painfr r3painfr r4painfr r5painfr r6painfr r7painfr r8painfr r9painfr ///
r1painlv r2painlv r3painlv r4painlv r5painlv r6painlv r7painlv r8painlv r9painlv ///
r1parkine r2parkine r3parkine r4parkine r5parkine r6parkine r7parkine r8parkine r9parkine ///
r1peninc r2peninc r3peninc r4peninc r5peninc r6peninc r7peninc r8peninc r9peninc ///
r1phonea r2phonea r3phonea r4phonea r5phonea r6phonea r7phonea r8phonea r9phonea ///
r1prmt1 r2prmt1 r3prmt1 r4prmt1 r5prmt1 ///
r1prmt2 ///
r1psych r2psych r3psych r4psych r5psych r6psych r7psych r8psych r9psych ///
r1psyche r2psyche r3psyche r4psyche r5psyche r6psyche r7psyche r8psyche r9psyche ///
r1pubpen r2pubpen r3pubpen r4pubpen r5pubpen r6pubpen r7pubpen r8pubpen r9pubpen ///
r1pusha r2pusha r3pusha r4pusha r5pusha r6pusha r7pusha r8pusha r9pusha ///
r1readrc r2readrc r3readrc r4readrc r5readrc r6readrc r7readrc r8readrc r9readrc ///
r1retage r2retage r3retage r4retage r5retage r6retage r7retage r8retage r9retage ///
r1retemp r2retemp r3retemp r4retemp r5retemp r6retemp r7retemp r8retemp r9retemp ///
r1rxasthma r2rxasthma r3rxasthma r4rxasthma r5rxasthma r6rxasthma r7rxasthma r8rxasthma r9rxasthma ///
r1rxdiab r2rxdiab r3rxdiab r4rxdiab r5rxdiab r6rxdiab r7rxdiab r8rxdiab r9rxdiab ///
r1rxdiabi r2rxdiabi r3rxdiabi r4rxdiabi r5rxdiabi r6rxdiabi r7rxdiabi r8rxdiabi r9rxdiabi ///
r1rxdiabo r2rxdiabo r3rxdiabo r4rxdiabo r5rxdiabo r6rxdiabo r7rxdiabo r8rxdiabo r9rxdiabo ///
r1rxhibp r2rxhibp r3rxhibp r4rxhibp r5rxhibp r6rxhibp r7rxhibp r8rxhibp r9rxhibp  ///
r1rxlung r2rxlung r3rxlung r4rxlung r5rxlung r6rxlung r7rxlung r8rxlung r9rxlung ///
r1shlt r2shlt r4shlt r5shlt r6shlt r7shlt r8shlt r9shlt ///
r1shopa r2shopa r3shopa r4shopa r5shopa r6shopa r7shopa r8shopa r9shopa ///
r1sight r2sight r3sight r4sight r5sight r6sight r7sight r8sight r9sight ///
r1sita r2sita r3sita r4sita r5sita r6sita r7sita r8sita r9sita ///
r1slfemp r2slfemp r3slfemp r4slfemp r5slfemp r6slfemp r7slfemp r8slfemp r9slfemp ///
r1slfmem r2slfmem r3slfmem r4slfmem r7slfmem r8slfmem r9slfmem ///
r1smokef r2smokef r3smokef r4smokef r5smokef r6smokef r7smokef r8smokef r9smokef ///
r1smoken r2smoken r3smoken r4smoken r5smoken r6smoken r7smoken r8smoken r9smoken ///
r1smokev r2smokev r3smokev r4smokev r5smokev r6smokev r7smokev r8smokev r9smokev ///
r1socyr r2socyr r3socyr r4socyr r5socyr r6socyr r7socyr r8socyr r9socyr ///
r1son r2son r3son r4son r5son r6son r7son r8son r9son ///
r1stoopa r2stoopa r3stoopa r4stoopa r5stoopa r6stoopa r7stoopa r8stoopa r9stoopa ///
r1stroke r2stroke r3stroke r4stroke r5stroke r6stroke r7stroke r8stroke r9stroke ///
r1toilta r2toilta r3toilta r4toilta r5toilta r6toilta r7toilta r8toilta r9toilta ///
r1tr20 r2tr20 r3tr20 r4tr20 r5tr20 r6tr20 r7tr20 r8tr20 r9tr20 ///
r1trcancr r2trcancr r3trcancr r4trcancr r5trcancr r6trcancr r7trcancr r8trcancr r9trcancr ///
r1urinai r2urinai r3urinai r4urinai r5urinai r6urinai r7urinai r8urinai r9urinai ///
r1verbf r2verbf r3verbf r4verbf r5verbf r7verbf r8verbf r9verbf ///
r1vgactx_e r2vgactx_e r3vgactx_e r4vgactx_e r5vgactx_e r6vgactx_e r7vgactx_e r8vgactx_e r9vgactx_e ///
r1walk100a r2walk100a r3walk100a r4walk100a r5walk100a r6walk100a r7walk100a r8walk100a r9walk100a ///
r1walkcomp r2walkcomp r3walkcomp r4walkcomp r5walkcomp r6walkcomp r7walkcomp r8walkcomp r9walkcomp ///
r1walkra r2walkra r3walkra r4walkra r5walkra r6walkra r7walkra r8walkra r9walkra ///
r1wheeze_e r2wheeze_e r3wheeze_e r4wheeze_e r5wheeze_e ///
r1work r2work r3work r4work r5work r6work r7work r8work r9work ///
r1wspeed r2wspeed r3wspeed r4wspeed r5wspeed r6wspeed r7wspeed r8wspeed r9wspeed ///
r1wspeed1 r2wspeed1 r3wspeed1 r4wspeed1 r5wspeed1 r6wspeed1 r7wspeed1 r8wspeed1 r9wspeed1 ///
r1wspeed2 r2wspeed2 r3wspeed2 r4wspeed2 r5wspeed2 r6wspeed2 r7wspeed2 r8wspeed2 r9wspeed2 ///
r1yr r2yr r3yr r4yr r5yr r6yr r7yr r8yr r9yr ///
r2chr10sec r4chr10sec r6chr10sec ///
r2chr1comp r4chr1comp r6chr1comp ///
r2chr5sec r4chr5sec r6chr5sec ///
r2chrcomp r4chrcomp r6chrcomp ///
r2chrnum r4chrnum r6chrnum ///
r2diasto r4diasto r6diasto r8diasto ///
r2diasto1 r4diasto1 r6diasto1 r8diasto1 ///
r2diasto2 r4diasto2 r6diasto2 r8diasto2 ///
r2diasto3 r4diasto3 r6diasto3 r8diasto3 ///
r2domhand r4domhand r6domhand r8domhand ///
r2drinkd_e r3drinkd_e r4drinkd_e r5drinkd_e r6drinkd_e r7drinkd_e r8drinkd_e r9drinkd_e ///
r2drinkn_e r3drinkn_e ///
r2fev r4fev ///
r2fev1 r4fev1 ///
r2fev2 r4fev2 ///
r2fev3 r4fev3 ///
r2fullcomp_e r4fullcomp_e r6fullcomp_e ///
r2fulldone_e r4fulldone_e r6fulldone_e ///
r2fulltan_e r4fulltan_e r6fulltan_e ///
r2fvc r4fvc ///
r2fvc1 r4fvc1 ///
r2fvc2 r4fvc2 /// ///
r2fvc3 r4fvc3 ///
r2gripsum r4gripsum r6gripsum r8gripsum ///
r2hchole r3hchole r4hchole r5hchole r6hchole r7hchole r8hchole r9hchole ///
r2hip r3hip r4hip r5hip r6hip r7hip r8hip r9hip ///
r2hipcomp r4hipcomp ///
r2htcomp r4htcomp r6htcomp ///
r2legrocomp r4legrocomp r6legrocomp ///
r2legrores r4legrores r6legrores ///
r2legrosec r4legrosec r6legrosec ///
r2legrscomp r4legrscomp r6legrscomp ///
r2legrsres r4legrsres r6legrsres ///
r2legrssec r4legrssec r6legrssec ///
r2lgrip r4lgrip r6lgrip r8lgrip ///
r2lgrip1 r4lgrip1 r6lgrip1 r8lgrip1 ///
r2lgrip2 r4lgrip2 r6lgrip2 r8lgrip2 ///
r2lgrip3 r4lgrip3 r6lgrip3 r8lgrip3 ///
r2mbmi r4mbmi r6mbmi r8mbmi ///
r2mbmicat r4mbmicat r6mbmicat r8mbmicat ///
r2mheight r4mheight r6mheight r8mheight ///
r2mhip r4mhip ///
r2msithght r4msithght ///
r2mwaist r4mwaist r6mwaist ///
r2mweight r4mweight r6mweight r8mweight r9mweight ///
r2mwhratio r4mwhratio ///
r2puff r4puff ///
r2puff1 r4puff1 ///
r2puff2 r4puff2 ///
r2puff3 r4puff3 ///
r2puffcomp r4puffcomp ///
r2puffinhl r4puffinhl ///
r2puffrinf r4puffrinf ///
r2pulse r4pulse r6pulse r8pulse ///
r2pulse1 r4pulse1 r6pulse1 r8pulse1 ///
r2pulse2 r4pulse2 r6pulse2 r8pulse2 ///
r2pulse3 r4pulse3 r6pulse3 r8pulse3 ///
r2rgrip r4rgrip r6rgrip r8rgrip ///
r2rgrip1 r4rgrip1 r6rgrip1 r8rgrip1 ///
r2rgrip2 r4rgrip2 r6rgrip2 r8rgrip2 ///
r2rgrip3 r4rgrip3 r6rgrip3 r8rgrip3 ///
r2rxbldthn r3rxbldthn r4rxbldthn r5rxbldthn r6rxbldthn r7rxbldthn r8rxbldthn r9rxbldthn ///
r2rxdepres r4rxdepres r8rxdepres ///
r2rxhrtat r5rxhrtat ///
r2rxosteo r5rxosteo r6rxosteo r7rxosteo r8rxosteo r9rxosteo ///
r2satlife_e r3satlife_e r4satlife_e r5satlife_e r6satlife_e r7satlife_e r8satlife_e r9satlife_e ///
r2satlifez r3satlifez r4satlifez r5satlifez r6satlifez r7satlifez r8satlifez r9satlifez ///
r2sbscomp r4sbscomp r6sbscomp ///
r2sbsdone r4sbsdone r6sbsdone ///
r2sbstan r4sbstan r6sbstan ///
r2semicomp r4semicomp r6semicomp ///
r2semidone r4semidone r6semidone ///
r2semitan r4semitan r6semitan ///
r2sthtcomp r4sthtcomp ///
r2systo r4systo r6systo r8systo ///
r2systo1 r4systo1 r6systo1 r8systo1 ///
r2systo2 r4systo2 r6systo2 r8systo2 ///
r2systo3 r4systo3 r6systo3 r8systo3 ///
r2trdepres r4trdepres r8trdepres ///
r2trhchol r5trhchol r6trhchol ///
r2watcomp r4watcomp r6watcomp ///
r2wtcomp r4wtcomp r6wtcomp r8wtcomp r9wtcomp ///
r3dentalh r5dentalh r7dentalh r8dentalh r9dentalh ///
r3nhmliv r4nhmliv r5nhmliv r6nhmliv r7nhmliv r8nhmliv r9nhmliv ///
r3noteeth r5noteeth ///
r3rxhchol r4rxhchol r5rxhchol r6rxhchol r7rxhchol r8rxhchol r9rxhchol ///
r4communa r5communa r6communa r7communa r8communa r9communa ///
r4dangera r5dangera r6dangera r7dangera r8dangera r9dangera ///
r4drinkwn_e r5drinkwn_e r6drinkwn_e r7drinkwn_e r8drinkwn_e r9drinkwn_e ///
r4fall1y ///
r4fallnum1y ///
r4hystere r6hystere r7hystere ///
r4iadltot2_e r5iadltot2_e r6iadltot2_e r7iadltot2_e r8iadltot2_e r9iadltot2_e ///
r4lstmnspd r6lstmnspd r7lstmnspd r8lstmnspd r9lstmnspd ///
r5mammog r6mammog r7mammog ///
r5mammoge r6mammoge r7mammoge r8mammoge r9mammoge ///
r5prost r6prost r7prost ///
r5proste r6proste r7proste r8proste r9proste ///
r6fev_e ///
r6fvc_e ///
r6puffcomp_e ///
r6puffinhl_e ///
r6puffrinf_e ///
r7bwc20 r8bwc20 r9bwc20 ///
r7cact r8cact r9cact ///
r7mnrc r8mnrc r9mnrc ///
r7pm r8pm r9pm ///
r7pres r8pres r9pres ///
r7scis r8scis r9scis ///
r7ser7 r8ser7 r9ser7 ///
raattackch ///
raattacke ///
rabcountry ///
rabyear  ///
raccbath ///
raccbooks ///
raccheating ///
raccnpeople ///
raccrooms ///
racctoilet ///
raccwaterc ///
raccwaterh ///
rachallerg ///
rachappdcts ///
rachasthma  ///
rachbones ///
rachcancer ///
rachdiab ///
rachearpr ///
rachepilepsy ///
rachhdache ///
rachheart ///
rachinfect  ///
rachleuk ///
rachpsych ///
rachresp ///
rachshlt ///
racombatch ///
racombate ///
radiagalzh ///
radiagangin ///
radiagarthr ///
radiagcancr ///
radiagchf ///
radiagdemen ///
radiagdiab ///
radiagparkin ///
radiagpsych ///
radiagstrok ///
radyear ///
raeduc_e  ///
raeducl ///
raedyrs_e ///
rafrhrtatt ///
ragender ///
ralifethch ///
ralifethe ///
ralivdiffch ///
ralsevent_e ///
ramaoccup ///
ramischlth  ///
ranadisch ///
ranadise ///
rapabused  ///
rapadivch ///
rapadrug ///
raracem ///
rarelig_e ///
rasepmom ///
rasfnhch ///
rasfnhe ///
r5hobby r6hobby r7hobby r8hobby r9hobby ///
r7dementia r8dementia r9dementia ///
r5memory_z r6memory_z r7memory_z r8memory_z r9memory_z ///
r5orient_z r6orient_z r7orient_z r8orient_z r9orient_z ///
r5executive_z r6executive_z r7executive_z r8executive_z r9executive_z ///
r5tcog_z_z r6tcog_z_z r7tcog_z_z r8tcog_z_z r9tcog_z_z ///
r5dependency r6dependency r7dependency r8dependency r9dependency ///
r7frailty r8frailty r9frailty ///
r5complac r6complac r7complac r8complac r9complac ///
r5leftout r6leftout r7leftout r8leftout r9leftout ///
r5isolate r6isolate r7isolate r8isolate r9isolate ///
r5intune r6intune r7intune r8intune r9intune ///
r5lnlys r6lnlys r7lnlys r8lnlys r9lnlys ///
r5lnlys3 r6lnlys3 r7lnlys3 r8lnlys3 r9lnlys3 ///
r5group1 r6group1 r7group1 r8group1 r9group1 ///
r5group2 r6group2 r7group2 r8group2 r9group2 ///
r5group3 r6group3 r7group3 r8group3 r9group3 ///
r5group4 r6group4 r7group4 r8group4 r9group4 ///
r5group5 r6group5 r7group5 r8group5 r9group5 ///
r5group6 r6group6 r7group6 r8group6 r9group6 ///
r5group7 r6group7 r7group7 r8group7 r9group7 ///
r5group8 r6group8 r7group8 r8group8 r9group8 ///
r5usesgas r6usesgas r7usesgas r8usesgas r9usesgas ///
r5useselec r6useselec r7useselec r8useselec r9useselec ///
r5usescoal r6usescoal r7usescoal r8usescoal r9usescoal ///
r5usespara r6usespara r7usespara r8usespara r9usespara ///
r5usesoil r6usesoil r7usesoil r8usesoil r9usesoil ///
r5useswood r6useswood r7useswood r8useswood r9useswood ///
r5usesotherf r6usesotherf r7usesotherf r8usesotherf r9usesotherf ///
r6happiness r7happiness r8happiness r9happiness ///
r6internet r7internet r8internet r9internet ///
r7teeth_num ///
r7teeth ///
r5depressive r6depressive r7depressive r8depressive r9depressive 

reshape long h@atotb h@coresd h@hhres h@hownrnt h@itot hh@hhid hh@hhidc ///
hh@cperc inw@ inw@sc r@adltot6 r@agey r@alzhe r@angin r@angine r@armsa /// 
r@arthre r@asthmae r@batha r@beda r@breath_e r@cancre r@cantril r@catracte /// 
r@catrcte r@cesd r@chaira r@child r@clim1a r@climsa r@cogothp r@conhrtfe ///
r@dadliv r@dau r@demene r@diabe r@dimea r@dlrc r@dressa r@drink r@dsight /// 
r@dw r@dy r@eata r@fagey r@fall r@falleq r@fallinj r@fallnum r@hearing  ///
r@hearte r@hibpe r@hipe r@hipr r@hipre r@hipriv r@housewka r@hownrnt r@hrtatt /// 
r@hrtatte r@hrtmre r@hrtrhme r@imrc r@itearn r@iwindm r@iwindy r@iwstat  ///
r@jcpen r@jointre r@lbrf_e r@lifta r@liv10 r@ltactx_e r@lunge r@mapa /// 
r@mdactx_e r@mealsa r@medsa r@memrye r@mo r@momliv r@moneya r@mstath  ///
r@nsight r@numer_e r@orient r@osteoe r@painfr r@painlv r@parkine r@peninc  ///
r@phonea r@prmt1 r@prmt2 r@psych r@psyche r@pubpen r@pusha r@readrc r@retage  ///
r@retemp r@rxasthma r@rxdiab r@rxdiabi r@rxdiabo r@rxhibp r@rxlung r@shlt  ///
r@shopa r@sight r@sita r@slfemp r@slfmem r@smokef r@smoken r@smokev r@socyr  ///
r@son r@stoopa r@stroke r@toilta r@tr20 r@trcancr r@urinai r@verbf r@vgactx_e  ///
r@walk100a r@walkcomp r@walkra r@wheeze_e r@work r@wspeed r@wspeed1 r@wspeed2 /// 
r@yr r@chr10sec r@chr1comp r@chr5sec r@chrcomp r@chrnum r@diasto r@diasto1  ///
r@diasto2 r@diasto3 r@domhand r@drinkd_e r@drinkn_e r@fev r@fev1 r@fev2 r@fev3 /// 
r@fullcomp_e r@fulldone_e r@fulltan_e r@fvc r@fvc1 r@fvc2 r@fvc3 r@gripsum  ///
r@hchole r@hip r@hipcomp r@htcomp r@legrocomp r@legrores r@legrosec r@legrscomp  ///
r@legrsres r@legrssec r@lgrip r@lgrip1 r@lgrip2 r@lgrip3 r@mbmi r@mbmicat  ///
r@mheight r@mhip r@msithght r@mwaist r@mweight r@mwhratio r@puff r@puff1  ///
r@puff2 r@puff3 r@puffcomp r@puffinhl r@puffrinf r@pulse r@pulse1 r@pulse2  ///
r@pulse3 r@rgrip r@rgrip1 r@rgrip2 r@rgrip3 r@rxbldthn r@rxdepres r@rxhrtat  ///
r@rxosteo r@satlife_e r@satlifez r@sbscomp r@sbsdone r@sbstan r@semicomp  ///
r@semidone r@semitan r@sthtcomp r@systo r@systo1 r@systo2 r@systo3 r@trdepres  ///
r@trhchol r@watcomp r@wtcomp r@dentalh r@nhmliv r@noteeth r@rxhchol r@communa  ///
r@dangera r@drinkwn_e r@fall1y r@fallnum1y r@hystere r@iadltot2_e r@lstmnspd  ///
r@mammog r@mammoge r@prost r@proste r@fev_e r@fvc_e r@puffcomp_e r@puffinhl_e ///
r@puffrinf_e r@bwc20 r@cact r@mnrc r@pm r@pres r@scis r@ser7 r@cogimp r@hobby ///
r@dementia r@memory_z r@orient_z r@executive_z r@tcog_z_z r@dependency ///
r@frailty r@complac r@leftout r@isolate r@intune r@lnlys r@lnlys3 ///
r@group1 r@group2 r@group3 r@group4 r@group5 r@group6 r@group7 r@group8 ///
r@usesgas r@useselec r@usescoal r@usespara r@usesoil r@useswood r@usesotherf ///
r@happiness r@internet r@teeth_num r@teeth r@depressive,i(idauniqc) j(wave)

rename (idauniqc wave hhhhid hhhhidc inw inwsc riwstat riwindm riwindy rabyear ///
radyear ragey rfagey ragender raracem raeduc_e raedyrs_e raeducl rmstath ///
rabcountry rarelig_e rnhmliv rshlt rwalkra rdressa rbatha reata rbeda rtoilta ///
rmapa rphonea rmedsa rshopa rmealsa rhousewka rdangera rcommuna rwalk100a ///
rsita rchaira rclimsa rclim1a rstoopa rlifta rdimea rarmsa rpusha radltot6 ///
riadltot2_e rhibpe rdiabe rcancre rlunge rhearte rstroke rpsyche rarthre ///
rasthmae rhchole rcatracte rparkine rhipe rangine rhrtatte rconhrtfe rhrtmre ///
rhrtrhme rosteoe rangin rhrtatt rpsych rrxhibp rrxdiabi rrxdiabo rrxdiab ///
rrxlung rrxasthma rtrcancr rrxbldthn rrxosteo rrxhchol radiagangin rafrhrtatt ///
radiagchf radiagdiab radiagstrok radiagarthr radiagcancr radiagparkin ///
radiagpsych ralzhe rdemene rmemrye radiagalzh radiagdemen rjointre rhipre ///
rsight rdsight rnsight rcatrcte rhearing rdentalh rfall rfallinj rfallnum ///
rfalleq rhip rlstmnspd rpainfr rpainlv rurinai rmammoge rproste rvgactx_e ///
rmdactx_e rltactx_e rdrink rdrinkd_e rdrinkwn_e rsmokev rsmoken rsmokef ///
rhipriv rcogimp rcogothp rslfmem rreadrc rimrc rdlrc rtr20 rmo rdy ryr ///
rdw rorient rverbf rnumer_e rbwc20 rser7 rscis rcact rmnrc rpm rpres rhownrnt ///
hhownrnt hatotb ritearn hitot hhcperc hhhres rdau rson rchild rmomliv rdadliv ///
hcoresd rsocyr rwork rslfemp rlbrf_e rretemp rretage rliv10 rpubpen rpeninc ///
rjcpen rwspeed1 rwspeed2 rwspeed rwalkcomp rmweight rwtcomp ramischlth ///
rapabused rapadrug ranadise racombate raattacke ralifethe ranadisch racombatch ///
raattackch ralifethch rasfnhe rasfnhch ralivdiffch rapadivch rasepmom ralsevent_e ///
raccrooms raccnpeople raccbooks raccbath raccwaterc raccwaterh racctoilet ///
raccheating ramaoccup rachshlt rachinfect rachasthma rachresp rachallerg ///
rachearpr rachhdache rachepilepsy rachpsych rachbones rachappdcts rachdiab ///
rachheart rachleuk rachcancer rcesd rsatlife_e rsatlifez rcantril rbreath_e ///
rhipr rmoneya rprmt1 rprmt2 rwheeze_e rchr10sec rchr1comp rchr5sec rchrcomp ///
rchrnum rdiasto rdiasto1 rdiasto2 rdiasto3 rdomhand rdrinkn_e rfev rfev1 rfev2 ///
rfev3 rfullcomp_e rfulldone_e rfulltan_e rfvc rfvc1 rfvc2 rfvc3 rgripsum ///
rhipcomp rhtcomp rlegrocomp rlegrores rlegrosec rlegrscomp rlegrsres rlegrssec ///
rlgrip rlgrip1 rlgrip2 rlgrip3 rmbmi rmbmicat rmheight rmhip rmsithght rmwaist ///
rmwhratio rpuff rpuff1 rpuff2 rpuff3 rpuffcomp rpuffinhl rpuffrinf rpulse ///
rpulse1 rpulse2 rpulse3 rrgrip rrgrip1 rrgrip2 rrgrip3 rrxdepres rrxhrtat ///
rsbscomp rsbsdone rsbstan rsemicomp rsemidone rsemitan rsthtcomp rsysto ///
rsysto1 rsysto2 rsysto3 rtrdepres rtrhchol rwatcomp rnoteeth rfall1y ///
rfallnum1y rhystere rmammog rprost rfev_e rfvc_e rpuffcomp_e rpuffinhl_e ///
rpuffrinf_e rhobby rdementia rmemory_z rorient_z rexecutive_z rtcog_z_z rdependency ///
rfrailty rcomplac rleftout risolate rintune rlnlys rlnlys3 ///
rgroup1 rgroup2 rgroup3 rgroup4 rgroup5 rgroup6 rgroup7 rgroup8 ///
rusesgas ruseselec rusescoal rusespara rusesoil ruseswood rusesotherf ///
rhappiness rinternet rteeth_num rteeth rdepressive) ///
(idauniqc wave hhhhid hhidc inw inwsc iwstat iwindm iwindy rabyear ///
radyear agey fagey ragender raracem raeduc_e raedyrs_e raeducl mstath ///
rabcountry rarelig_e nhmliv shlt walkra dressa batha eata beda toilta ///
mapa phonea medsa shopa mealsa housewka dangera communa walk100a ///
sita chaira climsa clim1a stoopa lifta dimea armsa pusha adltot6 ///
iadltot2_e hibpe diabe cancre lunge hearte stroke psyche arthre ///
asthmae hchole catracte parkine hipe angine hrtatte conhrtfe hrtmre ///
hrtrhme osteoe angin hrtatt psych rxhibp rxdiabi rxdiabo rxdiab ///
rxlung rxasthma trcancr rxbldthn rxosteo rxhchol radiagangin rafrhrtatt ///
radiagchf radiagdiab radiagstrok radiagarthr radiagcancr radiagparkin ///
radiagpsych alzhe demene memrye radiagalzh radiagdemen jointre hipre ///
sight dsight nsight catrcte hearing dentalh fall fallinj fallnum ///
falleq hip lstmnspd painfr painlv urinai mammoge proste vgactx_e ///
mdactx_e ltactx_e drink drinkd_e drinkwn_e smokev smoken smokef ///
hipriv cogimp cogothp slfmem readrc imrc dlrc tr20 mo dy yr ///
dw orient verbf numer_e bwc20 ser7 scis cact mnrc pm pres hownrnt ///
hhownrnt hatotb itearn hitot hhcperc hhhres dau son child momliv dadliv ///
coresd socyr work slfemp lbrf_e retemp retage liv10 pubpen peninc ///
jcpen wspeed1 wspeed2 wspeed walkcomp mweight wtcomp ramischlth ///
rapabused rapadrug ranadise racombate raattacke ralifethe ranadisch racombatch ///
raattackch ralifethch rasfnhe rasfnhch ralivdiffch rapadivch rasepmom ralsevent_e ///
raccrooms raccnpeople raccbooks raccbath raccwaterc raccwaterh racctoilet ///
raccheating ramaoccup rachshlt rachinfect rachasthma rachresp rachallerg ///
rachearpr rachhdache rachepilepsy rachpsych rachbones rachappdcts rachdiab ///
rachheart rachleuk rachcancer cesd satlife_e satlifez cantril breath_e ///
hipr moneya prmt1 prmt2 wheeze_e chr10sec chr1comp chr5sec chrcomp ///
chrnum diasto diasto1 diasto2 diasto3 domhand drinkn_e fev fev1 fev2 ///
fev3 fullcomp_e fulldone_e fulltan_e fvc fvc1 fvc2 fvc3 gripsum ///
hipcomp htcomp legrocomp legrores legrosec legrscomp legrsres legrssec ///
lgrip lgrip1 lgrip2 lgrip3 mbmi mbmicat mheight mhip msithght mwaist ///
mwhratio puff puff1 puff2 puff3 puffcomp puffinhl puffrinf pulse ///
pulse1 pulse2 pulse3 rgrip rgrip1 rgrip2 rgrip3 rxdepres rxhrtat ///
sbscomp sbsdone sbstan semicomp semidone semitan sthtcomp systo ///
systo1 systo2 systo3 trdepres trhchol watcomp noteeth fall1y ///
fallnum1y hystere mammog prost fev_e fvc_e puffcomp_e puffinhl_e ///
puffrinf_e hobby dementia memory_z orient_z executive_z tcog_z_z dependency ///
frailty complac leftout isolate intune lnlys lnlys3 ///
group1 group2 group3 group4 group5 group6 group7 group8 ///
usesgas useselec usescoal usespara usesoil useswood usesotherf ///
happiness internet teeth_num teeth depressive) 

label var adltot6 "ADL总分"
label var agey "年龄"
label var alzhe "医生是否告诉受访者患有阿尔茨海默病"
label var angin "过去2年内是否报告有心绞痛"
label var angine "医生是否诊断患有心绞痛"
label var armsa "其他功能限制/手臂超过肩膀是否困难"
label var arthre "医生是否诊断患有关节炎"
label var asthmae "医生是否诊断患有哮喘"
label var batha "ADL/洗澡和淋浴是否困难"
label var beda "ADL/上下床是否困难"
label var breath_e "是否行走时经历过呼吸短促"
label var bwc20 "认知/是否能够成功地从20开始连续倒数10个数字2分"
label var cact "认知/是否能够正确地命名仙人掌1分"
label var cancre "医生是否诊断患有癌症或恶性肿瘤"
label var cantril "自己在社会中的地位的评价"
label var catracte "医生是否诊断患有白内障"
label var catrcte "是否做过白内障手术"
label var cesd "CESD-8分"
label var chaira "其他功能限制/长时间坐着从椅子上站起来是否困难"
label var child "健在子女数"
label var chr10sec "完成10个椅子架所花费的秒数"
label var chr1comp "是否愿意并且能够在不使用手臂的情况下完成单个椅架"
label var chr5sec "完成5个椅子架所花费的秒数"
label var chrcomp "是否愿意并且能够在不使用手臂的情况下完成5或10张椅子的站立测试"
label var chrnum "完成的椅架总数"
label var clim1a "其他功能限制/不休息地爬一段楼梯是否困难"
label var climsa "其他功能限制/不休息地爬几段楼梯是否困难"
label var cogimp "认知/是否报告了认知测试"
label var cogothp "认知/认知测试时是否有其他人在场"
label var communa "IADL/通过语言、听觉或视觉进行交流是否困难"
label var conhrtfe "医生是否诊断患有充血性心力衰竭"
label var coresd "是否与子女同住"
label var dadliv "父亲是否还活着"
label var dangera "IADL/识别身体危险是否困难"
label var dau "健在女儿数"
label var demene "医生是否告诉受访者患有痴呆症"
label var dentalh "自评的牙齿健康状况"
label var diabe "医生是否诊断患有糖尿病"
label var diasto "舒张压读数的平均值"
label var diasto1 "第一次舒张压读数"
label var diasto2 "第二次舒张压读数"
label var diasto3 "第三次舒张压读数"
label var dimea "其他功能限制/桌子捡起硬币是否困难"
label var dlrc "认知/延迟词回忆10分"
label var domhand "优势手"
label var dressa "ADL/穿衣是否困难"
label var drink "过去12个月内是否喝过酒"
label var drinkd_e "过去7天内饮酒的天数"
label var drinkn_e "前一周喝得最多的那一天所报告的饮酒量"
label var drinkwn_e "过去7天内报告饮用的饮料数量"
label var dsight "远视视力"
label var dw "认知/是否能够正确报告周1分"
label var dy "认知/是否能够正确报告日1分"
label var eata "ADL/吃饭是否困难"
label var fagey "年龄是否顶部编码为90"
label var fall "最近2年内是否跌倒过"
label var fall1y "过去一年中是否摔倒过"
label var falleq "跌倒后是否使用个人警报来寻求帮助"
label var fallinj "是否曾经严重受伤，需要医疗"
label var fallnum "过去2年中跌倒的次数"
label var fallnum1y "过去一年中跌倒的次数"
label var fev "用力呼气量最大值"
label var fev_e "用力呼气量最大值(仅限wave6)"
label var fev1 "第一次用力呼气量"
label var fev2 "第二次用力呼气量"
label var fev3 "第三次用力呼气量"
label var fullcomp_e "是否愿意并能够完成双脚前后成一直线站立平衡测试"
label var fulldone_e "双脚前后成一直线站立是否保持10秒平衡"
label var fulltan_e "双脚前后成一直线站立平衡测试的时间"
label var fvc "强制肺活量最大值"
label var fvc_e "强制肺活量最大值(仅限wave6)"
label var fvc1 "第一次强制肺活量"
label var fvc2 "第二次强制肺活量"
label var fvc3 "第三次强制肺活量"
label var gripsum "优势手的最大测量值"
label var hatotb "家庭总财富"
label var hchole "医生是否诊断患有高胆固醇"
label var hearing "自评的听力"
label var hearte "医生是否诊断患有心脏问题"
label var hhcperc "家庭人均消费"
label var hhhres "家庭规模"
label var hhid "家庭标识符/数值型"
label var hhidc "家庭标识符/字符型"
label var hhownrnt "夫妻级是否拥有他们目前的住所"
label var hibpe "医生是否诊断患有高血压"
label var hip "过去两年是否髋部骨折"
label var hipcomp "是否愿意和能够完成腰围和臀围测量"
label var hipe "医生是否诊断患有髋部骨折"
label var hipr "过去2年内是否做过髋关节置换术"
label var hipre "是否做过髋关节置换术"
label var hipriv "是否有私人保险"
label var hitot "夫妻层面的收入"
label var housewka "IADL/在房屋或花园周围工作是否困难"
label var hownrnt "是否拥有他们目前的住所"
label var hrtatt "过去2年内是否报告有心脏病发作或心肌梗死"
label var hrtatte "医生是否诊断患有心脏病发作(包括心肌梗死或冠状动脉血栓形成)"
label var hrtmre "医生是否诊断患有心脏杂音"
label var hrtrhme "医生是否诊断患有心律异常"
label var htcomp "是否愿意和能够完成站立高度测量"
label var hystere "是否做过子宫或子宫切除手术"
label var iadltot2_e "IADL总分"
label var idauniqc "个人标识符"
label var imrc "认知/即时单词记忆10分"
label var inw "是否参与本期调查"
label var inwsc "是否参与自我完成调查部分"
label var itearn "税后个人收入"
label var iwindm "受访月份"
label var iwindy "受访年份"
label var iwstat "是否死亡"
label var jcpen "是否是职业养老金计划的成员"
label var jointre "是否曾经做过关节置换手术"
label var puffcomp_e "是否愿意并且能够完成Wave 6中的呼吸测试"
label var lbrf_e "劳动力状况"
label var legrocomp "是否愿意并且能够睁着眼睛完成抬腿测试"
label var legrores "是否睁着眼睛抬腿30秒"
label var legrosec "睁着眼睛抬腿时间"
label var legrscomp "是否愿意并且能够闭着眼睛完成抬腿测试"
label var legrsres "是否闭着眼睛抬腿30秒"
label var legrssec "闭着眼睛抬腿时间"
label var lgrip "左手的最大握力测量值"
label var lgrip1 "左手第一次握力测量"
label var lgrip2 "左手第二次握力测量"
label var lgrip3 "左手第三次握力测量"
label var lifta "其他功能限制/举起或搬运超过10磅的重物是否困难"
label var liv10 "再多活10年的概率"
label var lstmnspd "最后一次月经的年龄"
label var ltactx_e "轻度体力活动的频率"
label var lunge "医生是否诊断患有慢性肺部疾病"
label var mammog "过去两年内是否进行过乳房x光检查"
label var mammoge "是否报告进行过乳房x光检查"
label var mapa "IADL/使用地图是否困难"
label var mbmi "BMI"
label var mbmicat "测量BMI分类"
label var mealsa "IADL/准备饭菜是否困难"
label var medsa "IADL/服用药物是否困难"
label var memrye "是否报告患有记忆障碍"
label var mheight "测量身高m"
label var mhip "测量的臀围"
label var mnrc "认知/是否能够正确说出英国现任君主1分"
label var mo "认知/是否能够正确报告月1分"
label var momliv "母亲是否还活着"
label var moneya "IADL/理财是否困难"
label var msithght "测量坐高m"
label var mstath "婚姻状况"
label var mwaist "测量的腰围"
label var mweight "测量体重kg"
label var mwhratio "测量的腰臀比"
label var nhmliv "访谈时是否住在护理机构中"
label var noteeth "牙齿是否全部脱落"
label var nsight "近视视力"
label var numer_e "认知/数学表现能力6分"
label var orient "认知/是否能够正确报告日期4分"
label var osteoe "医生是否诊断患有骨质疏松症"
label var painfr "是否经常感到疼痛"
label var painlv "疼痛程度"
label var parkine "医生是否诊断患有帕金森病"
label var peninc "目前是否领取任何私人或雇主养老金"
label var phonea "IADL/使用电话是否困难"
label var pm "认知/是否能够正确说出英国首相1分"
label var pres "认知/是否能够正确说出美国总统1分"
label var prmt1 "认知/能够记住执行正确第一项任务的程度"
label var prmt2 "认知/能够记住执行正确的第二项任务的程度"
label var prost "过去两年内是否进行过前列腺检查"
label var proste "是否报告进行过前列腺检查"
label var psych "过去2年内是否报告有任何情绪、神经或精神问题"
label var psyche "医生是否诊断患有任何情绪、神经或精神问题"
label var pubpen "目前是否在无残疾情况下领取公共养老金"
label var puff "呼吸峰流速"
label var puff1 "第一次呼吸峰流速"
label var puff2 "第二次呼吸峰流速"
label var puff3 "第三次呼吸峰流速"
label var puffcomp "是否愿意并能够完成呼吸测试"
label var puffinhl "过去24小时内是否使用了吸入器、喷雾器或任何药物来呼吸"
label var puffinhl_e "Wave 6的过去24小时内是否使用了吸入器、呼吸器或任何药物来呼吸"
label var puffrinf "过去三周内是否有呼吸道感染"
label var puffrinf_e "Wave 6过去三周内是否有呼吸道感染"
label var pulse "脉冲读数的平均值"
label var pulse1 "第一次脉冲读数"
label var pulse2 "第二次脉冲读数"
label var pulse3 "第三次脉冲读数"
label var pusha "其他功能限制/推拉大型物体是否困难"
label var raattackch "在16岁之前是否遭受过严重的身体攻击或攻击"
label var raattacke "是否是严重身体攻击或攻击的受害者"
label var rabcountry "出生地是否为英国"
label var rabyear "出生年份"
label var raccbath "10岁时住所是否有固定的浴室"
label var raccbooks "10岁时居住的地方的书籍数量"
label var raccheating "10岁时的住所是否有集中供暖"
label var raccnpeople "10岁时家中居住的人数"
label var raccrooms "10岁时家庭在住所中占用的卧室数量"
label var racctoilet "10岁时的住所是否有内部厕所"
label var raccwaterc "10岁时住所是否有冷自来水供应"
label var raccwaterh "10岁时其住所是否有热水供应"
label var rachallerg "16岁前是否患有除哮喘以外的过敏"
label var rachappdcts "16岁前是否患有阑尾炎"
label var rachasthma "16岁前是否患有患有哮喘"
label var rachbones "16岁前是否患有骨折"
label var rachcancer "16岁前是否患有癌症或恶性肿瘤"
label var rachdiab "16岁前是否患有儿童糖尿病或高血糖"
label var rachearpr "16岁前是否患有慢性耳部问题"
label var rachepilepsy "16岁前是否患有癫痫、发作或癫痫发作"
label var rachhdache "16岁前是否患有严重的头痛或偏头痛"
label var rachheart "16岁前是否患有心脏病"
label var rachinfect "16岁前是否患有传染病"
label var rachleuk "16岁前是否患有白血病或淋巴瘤"
label var rachpsych "16岁前是否患有情绪、紧张或精神问题"
label var rachresp "16岁前是否患有除哮喘以外的呼吸系统疾病(如支气管炎)"
label var rachshlt "16岁之前的自评健康状况"
label var racombatch "在16岁之前是否曾经在战斗中使用过武器或在战斗中被射击"
label var racombate "是否曾经在战斗中使用过武器或在战斗中被射击过"
label var radiagalzh "首次被诊断患有阿尔茨海默病的年龄"
label var radiagangin "首次被诊断为心绞痛的年龄"
label var radiagarthr "首次被诊断关节炎的年龄"
label var radiagcancr "首次被诊断癌症或恶性肿瘤的年龄"
label var radiagchf "首次被诊断为充血性心力衰竭的年龄"
label var radiagdemen "首次被诊断患有痴呆症的年龄"
label var radiagdiab "首次被诊断为糖尿病的年龄"
label var radiagparkin "首次被诊断帕金森病的年龄"
label var radiagpsych "首次被诊断有情绪、神经或精神问题的年龄"
label var radiagstrok "首次被诊断为中风的年龄"
label var radyear "死亡年份"
label var raeduc_e "教育程度"
label var raeducl "统一可比的教育程度"
label var raedyrs_e "教育年限"
label var rafrhrtatt "首次被诊断为心脏病发作的年龄"
label var ragender "性别"
label var ralifethch "在16岁之前是否有过威胁生命的疾病或事故"
label var ralifethe "是否有过威胁生命的疾病或事故"
label var ralivdiffch "在16岁之前是否经历过困难的生活安排"
label var ralsevent_e "一生中经历过多少压力事件的计数"
label var ramaoccup "14岁时主要家庭供养者的职业"
label var ramischlth "16岁之前是否因为健康问题缺课一个月"
label var ranadisch "在16岁之前是否经历过重大火灾、洪水、地震或其他自然灾害"
label var ranadise "是否曾经经历过重大火灾、洪水、地震或其他自然灾害"
label var rapabused "16岁之前是否受到过父母的身体虐待"
label var rapadivch "父母是否在16岁之前分居或离婚"
label var rapadrug "父母是否在16岁之前酗酒、吸毒或有精神健康问题"
label var raracem "是否白人"
label var rarelig_e "宗教"
label var rasepmom "在16岁之前是否与母亲分开超过6个月"
label var rasfnhch "在16岁之前是否经历过严重的经济困难"
label var rasfnhe "是否经历过严重的经济困难"
label var readrc "认知/由计算机还是面试官读单词回忆表"
label var retage "退休年龄"
label var retemp "自报是否退休"
label var rgrip "右手的最大握力测量值"
label var rgrip1 "右手第一次握力测量"
label var rgrip2 "右手第二次握力测量"
label var rgrip3 "右手第三次握力测量"
label var rxasthma "是否服用哮喘药物"
label var rxbldthn "是否正在服用稀释血液的药物"
label var rxdepres "是否正在服用抑郁症药物"
label var rxdiab "是否服用口服药物或使用胰岛素注射治疗糖尿病"
label var rxdiabi "是否注射糖尿病胰岛素"
label var rxdiabo "是否口服糖尿病药物"
label var rxhchol "是否正在服用治疗高胆固醇的药物"
label var rxhibp "是否服用高血压药物"
label var rxhrtat "是否正在服用β受体阻滞剂来诊断心脏病发作"
label var rxlung "是否服用慢性肺部疾病的药物"
label var rxosteo "是否正在服用骨质疏松药物"
label var satlife_e "生活满意度7分"
label var satlifez "生活满意度z评分"
label var sbscomp "是否愿意并能够完成双脚并拢站立平衡测试"
label var sbsdone "双脚并拢站立是否保持10秒平衡"
label var sbstan "双脚并拢平衡测试的时间"
label var scis "认知/是否能够正确地命名剪刀1分"
label var semicomp "是否愿意并能够完成双脚半前后站立平衡测试"
label var semidone "双脚半前后站立是否保持10秒平衡"
label var semitan "双脚半前后站立平衡测试的时间"
label var ser7 "认知/正确减法的个数5分"
label var shlt "自评健康"
label var shopa "IADL/购买杂货是否困难"
label var sight "自评视力"
label var sita "其他功能限制/坐约2小时是否困难"
label var slfemp "是否自雇"
label var slfmem "认知/自报记忆"
label var smokef "平均每天抽多少支烟"
label var smoken "现在是否报告吸烟"
label var smokev "是否报告曾经吸烟"
label var socyr "是否为某个组织、俱乐部或社团的成员，并且在一年内至少参加一次委员会会议"
label var son "健在儿子数"
label var sthtcomp "是否愿意和能够完成站立坐姿高度测量"
label var stoopa "其他功能限制/弯腰跪下或蹲下是否困难"
label var stroke "医生是否诊断患有中风"
label var systo "收缩压读数的平均值"
label var systo1 "第一次收缩压读数"
label var systo2 "第二次收缩压读数"
label var systo3 "第三次收缩压读数"
label var toilta "ADL/上厕所是否困难"
label var tr20 "认知/总单词记忆10分"
label var trcancr "在过去两年内是否接受过任何癌症治疗"
label var trdepres "是否正在接受抑郁症咨询"
label var trhchol "是否正在接受高胆固醇治疗"
label var urinai "过去12个月内是否经历过尿失禁"
label var verbf "认知/语言流利度分数"
label var vgactx_e "剧烈体力活动的频率"
label var mdactx_e "中等体力活动的频率"
label var walk100a "其他功能限制/步行100码是否困难"
label var walkcomp "是否愿意并且能够完成步行速度测试"
label var walkra "ADL/房间里走动是否困难"
label var watcomp "是否愿意和能够完成腰围和臀围测量"
label var wheeze_e "是否经历持续喘息、咳嗽或痰"
label var work "是否从事有偿工作"
label var wspeed "行走速度的平均值"
label var wspeed1 "第一次行走速度"
label var wspeed2 "第二次行走速度"
label var wtcomp "是否愿意和能够完成站立体重测量"
label var yr "认知/是否能够正确报告年1分"
label var hobby "爱好"
label var happiness "幸福感11分"
label var wave "第几次调查"
label define wave_ 1 "第1轮" 2 "第2轮" 3 "第3轮" 4 "第4轮" 5 "第5轮" ///
 6 "第6轮" 7 "第7轮" 8 "第8轮" 9 "第9轮"
label values wave wave_
label var complac "家庭标识符" 
label var complac "感到缺乏陪伴的频率" 
label var leftout "感到被忽略的频率"
label var isolate "感到被他人孤立的频率"
label var intune "感觉与周围人合拍的频率"
label var lnlys "四个不同的孤独问题的平均值"
label var lnlys3 "三个不同的孤独问题的平均值"
label var usesgas "是否使用天然气"
label var useselec "是否使用电力"
label var usescoal "是否使用煤"
label var usespara "是否使用煤油"
label var usesoil "是否使用石油"
label var useswood "是否使用木材"
label var usesotherf "是否使用其他燃料"
label var group1 "政党、工会或环保组织的成员"
label var group2 "租户团体、居民团体或邻里守望组织的成员"
label var group3 "教堂或其他宗教团体的成员"
label var group4 "慈善协会的成员"
label var group5 "教育、艺术或音乐团体或夜校的成员"
label var group6 "社交俱乐部的成员" 
label var group7 "体育俱乐部、健身房或锻炼班的成员" 
label var group8 "其他组织、俱乐部或社团的成员" 
label var internet "是否至少每周使用互联网" 
label var depressive "是否抑郁" 
label var dementia "是否痴呆" 
label var memory_z "记忆的z标准化(ref基线)" 
label var orient_z "定向的z标准化(ref基线)" 
label var executive_z "执行的z标准化(ref基线)" 
label var tcog_z_z "总体认知能力z标准化(ref基线)" 
label var dependency "按需求间隔依赖性分类划分的功能依赖性" 
label var frailty "衰弱指数"
label var teeth_num "牙齿数量" 
label var teeth "是否佩戴假牙"

*****所有缺失值类型转为.
mvencode _all, mv(-999.99) 
mvdecode _all, mv(-999.99)

*****保留参与受访的个体
keep if inw==1

*****final sort
sort idauniqc

*****compress dataset
compress	

*****add label
label data "Shawn老师 @丁点帮你"

*****add notes
notes drop _dta
note: Shawn老师->微信公众账号@丁点帮你
save "$working_data/elsa.dta",replace

