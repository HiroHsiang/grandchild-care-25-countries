
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
use "$raw_data\H_KLoSA\H_KLoSA_e2.dta",clear
merge 1:1 pid using "$temp_data\w03.dta",nogen nolabel
merge 1:1 pid using "$temp_data\w04.dta",nogen nolabel
merge 1:1 pid using "$temp_data\w05.dta",nogen nolabel
merge 1:1 pid using "$temp_data\w06.dta",nogen nolabel
merge 1:1 pid using "$temp_data\w07.dta",nogen nolabel
merge 1:1 pid using "$temp_data\w08.dta",nogen nolabel
*sample 1
label drop _all

*****保留特定变量
keep h1child h2child h3child h4child h5child h6child h7child h8child ///
h1coresd h2coresd h3coresd h4coresd h5coresd h6coresd h7coresd h8coresd /// 
h1fcamt h2fcamt h3fcamt h4fcamt h5fcamt h6fcamt h7fcamt h8fcamt /// 
h1fcany h2fcany h3fcany h4fcany h5fcany h6fcany h7fcany h8fcany /// 
h1fpamt h2fpamt h3fpamt h4fpamt h5fpamt h6fpamt h7fpamt h8fpamt ///
h1fpany h2fpany h3fpany h4fpany h5fpany h6fpany h7fpany h8fpany ///
h1hhres h2hhres h3hhres h4hhres h5hhres h6hhres h7hhres h8hhres /// 
h1tcamt h2tcamt h3tcamt h4tcamt h5tcamt h6tcamt h7tcamt h8tcamt /// 
h1tcany h2tcany h3tcany h4tcany h5tcany h6tcany h7tcany h8tcany /// 
h1tpamt h2tpamt h3tpamt h4tpamt h5tpamt h6tpamt h7tpamt h8tpamt /// 
h1tpany h2tpany h3tpany h4tpany h5tpany h6tpany h7tpany h8tpany ///
hh1hhidc hh2hhidc hh3hhidc hh4hhidc hh5hhidc hh6hhidc hh7hhidc hh8hhidc ///
hh2cperc hh3cperc hh4cperc hh5cperc hh6cperc hh7cperc hh8cperc /// 
hh2ctot hh3ctot hh4ctot hh5ctot hh6ctot hh7ctot hh8ctot /// 
inw1 inw2 inw3 inw4 inw5 inw6 inw7 inw8   ///
pid  ///
r1agey r2agey r3agey r4agey r5agey r6agey r7agey r8agey ///
r1arthre r2arthre r3arthre r4arthre r5arthre r6arthre r7arthre r8arthre /// 
r1atotb r2atotb r3atotb r4atotb r5atotb r6atotb r7atotb r8atotb ///
r1bathb r2bathb r3bathb r4bathb r5bathb r6bathb r7bathb r8bathb /// 
r1bedb_k r2bedb_k r3bedb_k r4bedb_k r5bedb_k r6bedb_k r7bedb_k r8bedb_k /// 
r1bmi r2bmi r3bmi r4bmi r5bmi r6bmi r7bmi r8bmi /// 
r1bmicat r2bmicat r3bmicat r4bmicat r5bmicat r6bmicat r7bmicat r8bmicat  ///
r1brushb r2brushb r3brushb r4brushb r5brushb r6brushb r7brushb r8brushb /// 
r1cancre r2cancre r3cancre r4cancre r5cancre r6cancre r7cancre r8cancre  ///
r1catrcte r2catrcte r3catrcte r4catrcte r5catrcte r6catrcte r7catrcte r8catrcte  ///
r1cesd10a r2cesd10a r3cesd10a r4cesd10a  ///
r1dadliv r2dadliv r3dadliv r4dadliv r5dadliv r6dadliv r7dadliv r8dadliv /// 
r1diabe r2diabe r3diabe r4diabe r5diabe r6diabe r7diabe r8diabe /// 
r1dressb r2dressb r3dressb r4dressb r5dressb r6dressb r7dressb r8dressb /// 
r1drink r2drink r3drink r4drink r5drink r6drink r7drink r8drink /// 
r1drinkev r2drinkev r3drinkev r4drinkev r5drinkev r6drinkev r7drinkev r8drinkev  ///
r1drinkn_k r2drinkn_k r3drinkn_k r4drinkn_k r5drinkn_k r6drinkn_k r7drinkn_k r8drinkn_k /// 
r1drinkx r2drinkx r3drinkx r4drinkx r5drinkx r6drinkx r7drinkx r8drinkx /// 
r1dsighta r2dsighta r3dsighta r4dsighta r5dsighta r6dsighta r7dsighta r8dsighta  ///
r1eatb r2eatb r3eatb r4eatb r5eatb r6eatb r7eatb r8eatb  ///
r1fall r2fall r3fall r4fall r5fall r6fall r7fall r8fall  ///
r1fallinj r2fallinj r3fallinj r4fallinj r5fallinj r6fallinj r7fallinj r8fallinj /// 
r1fallnum r2fallnum r3fallnum r4fallnum r5fallnum r6fallnum r7fallnum r8fallnum  ///
r1glaucoma r2glaucoma r3glaucoma r4glaucoma r5glaucoma r6glaucoma r7glaucoma r8glaucoma  ///
r1gooutb r2gooutb r3gooutb r4gooutb r5gooutb r6gooutb r7gooutb r8gooutb  ///
r1gripast r2gripast r3gripast r4gripast r5gripast r6gripast r7gripast r8gripast /// 
r1gripcomp r2gripcomp r3gripcomp r4gripcomp r5gripcomp r6gripcomp r7gripcomp r8gripcomp  ///
r1gripsum r2gripsum r3gripsum r4gripsum r5gripsum r6gripsum r7gripsum r8gripsum /// 
r1groomb r2groomb r3groomb r4groomb r5groomb r6groomb r7groomb r8groomb  ///
r1hearaid r2hearaid r3hearaid r4hearaid r5hearaid r6hearaid r7hearaid r8hearaid  ///
r1hearinga r2hearinga r3hearinga r4hearinga r5hearinga r6hearinga r7hearinga r8hearinga  ///
r1hearlmt r2hearlmt r3hearlmt r4hearlmt r5hearlmt r6hearlmt r7hearlmt r8hearlmt ///
r1hearte r2hearte r3hearte r4hearte r5hearte r6hearte r7hearte r8hearte ///
r1height r2height r3height r4height r5height r6height r7height r8height  ///
r1hibpe r2hibpe r3hibpe r4hibpe r5hibpe r6hibpe r7hibpe r8hibpe  ///
r1higovt_k r2higovt_k r3higovt_k r4higovt_k r5higovt_k r6higovt_k r7higovt_k r8higovt_k ///
r1hipe_k r2hipe_k r3hipe_k r4hipe_k r5hipe_k r6hipe_k r7hipe_k r8hipe_k  ///
r1hipriv r2hipriv r3hipriv r4hipriv r5hipriv r6hipriv r7hipriv r8hipriv ///
r1housewkb r2housewkb r3housewkb r4housewkb r5housewkb r6housewkb r7housewkb r8housewkb  ///
r1injlmt r2injlmt r3injlmt r4injlmt r5injlmt r6injlmt r7injlmt r8injlmt ///
r1itearn r2itearn r3itearn r4itearn r5itearn r6itearn r7itearn r8itearn /// 
r1itot r2itot r3itot r4itot r5itot r6itot r7itot r8itot  ///
r1itothhinc r2itothhinc r3itothhinc r4itothhinc r5itothhinc r6itothhinc r7itothhinc r8itothhinc  ///
r1iwm r2iwm r3iwm r4iwm r5iwm r6iwm r7iwm r8iwm  ///
r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat r6iwstat r7iwstat r8iwstat ///
r1iwy r2iwy r3iwy r4iwy r5iwy r6iwy r7iwy r8iwy ///
r1laundryb r2laundryb r3laundryb r4laundryb r5laundryb r6laundryb r7laundryb r8laundryb /// 
r1lbrf_k r2lbrf_k r3lbrf_k r4lbrf_k r5lbrf_k r6lbrf_k r7lbrf_k r8lbrf_k ///
r1lgrip r2lgrip r3lgrip r4lgrip r5lgrip r6lgrip r7lgrip r8lgrip  ///
r1lgrip1 r2lgrip1 r3lgrip1 r4lgrip1 r5lgrip1 r6lgrip1 r7lgrip1 r8lgrip1 ///
r1lgrip2 r2lgrip2 r3lgrip2 r4lgrip2 r5lgrip2 r6lgrip2 r7lgrip2 r8lgrip2  ///
r1livere r2livere r3livere r4livere r5livere r6livere r7livere r8livere  ///
r1lunge r2lunge r3lunge r4lunge r5lunge r6lunge r7lunge r8lunge  ///
r1mealsb r2mealsb r3mealsb r4mealsb r5mealsb r6mealsb r7mealsb r8mealsb  ///
r1medsb r2medsb r3medsb r4medsb r5medsb r6medsb r7medsb r8medsb  ///
r1metrop_k r2metrop_k r3metrop_k r4metrop_k r5metrop_k r6metrop_k r7metrop_k r8metrop_k  ///
r1momliv r2momliv r3momliv r4momliv r5momliv r6momliv r7momliv r8momliv  ///
r1moneyb r2moneyb r3moneyb r4moneyb r5moneyb r6moneyb r7moneyb r8moneyb  ///
r1mstath r2mstath r3mstath r4mstath r5mstath r6mstath r7mstath r8mstath ///
r1nsighta r2nsighta r3nsighta r4nsighta r5nsighta r6nsighta r7nsighta r8nsighta  ///
r1obese r2obese r3obese r4obese r5obese r6obese r7obese r8obese  ///
r1paina r2paina r3paina r4paina r5paina r6paina r7paina r8paina  ///
r1painfr r2painfr r3painfr r4painfr r5painfr r6painfr r7painfr r8painfr  ///
r1painhlv r2painhlv r3painhlv r4painhlv r5painhlv r6painhlv r7painhlv r8painhlv  ///
r1phoneb r2phoneb r3phoneb r4phoneb r5phoneb r6phoneb r7phoneb r8phoneb  ///
r1psyche r2psyche r3psyche r4psyche r5psyche r6psyche r7psyche r8psyche ///
r1quitsmok r2quitsmok r3quitsmok r4quitsmok r5quitsmok r6quitsmok r7quitsmok r8quitsmok  ///
r1region_k r2region_k r3region_k r4region_k r5region_k r6region_k r7region_k r8region_k /// 
r1relgwk r2relgwk r3relgwk r4relgwk r5relgwk r6relgwk r7relgwk r8relgwk ///
r1relig_k r2relig_k r3relig_k r4relig_k r5relig_k r6relig_k r7relig_k r8relig_k ///
r1rgrip r2rgrip r3rgrip r4rgrip r5rgrip r6rgrip r7rgrip r8rgrip ///
r1rgrip1 r2rgrip1 r3rgrip1 r4rgrip1 r5rgrip1 r6rgrip1 r7rgrip1 r8rgrip1 ///
r1rgrip2 r2rgrip2 r3rgrip2 r4rgrip2 r5rgrip2 r6rgrip2 r7rgrip2 r8rgrip2 ///
r1rural r2rural r3rural r4rural r5rural r6rural r7rural r8rural  ///
r1rxarthr r2rxarthr r3rxarthr r4rxarthr r5rxarthr r6rxarthr r7rxarthr r8rxarthr /// 
r1rxcancr r2rxcancr r3rxcancr r4rxcancr r5rxcancr r6rxcancr r7rxcancr r8rxcancr ///
r1rxdiab r2rxdiab r3rxdiab r4rxdiab r5rxdiab r6rxdiab r7rxdiab r8rxdiab  ///
r1rxheart r2rxheart r3rxheart r4rxheart r5rxheart r6rxheart r7rxheart r8rxheart  ///
r1rxhibp r2rxhibp r3rxhibp r4rxhibp r5rxhibp r6rxhibp r7rxhibp r8rxhibp  ///
r1rxliver r2rxliver r3rxliver r4rxliver r5rxliver r6rxliver r7rxliver r8rxliver /// 
r1rxlung r2rxlung r3rxlung r4rxlung r5rxlung r6rxlung r7rxlung r8rxlung  ///
r1rxpsych r2rxpsych r3rxpsych r4rxpsych r5rxpsych r6rxpsych r7rxpsych r8rxpsych  ///
r1rxstrok r2rxstrok r3rxstrok r4rxstrok r5rxstrok r6rxstrok r7rxstrok r8rxstrok /// 
r1shlt r2shlt r3shlt r4shlt r5shlt r6shlt r7shlt r8shlt  ///
r1shlta r2shlta r3shlta r4shlta r5shlta r6shlta r7shlta r8shlta ///
r1shopb r2shopb r3shopb r4shopb r5shopb r6shopb r7shopb r8shopb  ///
r1sighta r2sighta r3sighta r4sighta r5sighta r6sighta r7sighta r8sighta /// 
r1sightlmt r2sightlmt r3sightlmt r4sightlmt r5sightlmt r6sightlmt r7sightlmt r8sightlmt ///
r1slfemp r2slfemp r3slfemp r4slfemp r5slfemp r6slfemp r7slfemp r8slfemp ///
r1smokef r2smokef r3smokef r4smokef r5smokef r6smokef r7smokef r8smokef /// 
r1smoken r2smoken r3smoken r4smoken r5smoken r6smoken r7smoken r8smoken ///
r1smokev r2smokev r3smokev r4smokev r5smokev r6smokev r7smokev r8smokev  ///
r1socrelg_k r2socrelg_k r3socrelg_k r4socrelg_k r5socrelg_k r6socrelg_k r7socrelg_k r8socrelg_k /// 
r1socwk r2socwk r3socwk r4socwk r5socwk r6socwk r7socwk r8socwk /// 
r1stroke r2stroke r3stroke r4stroke r5stroke r6stroke r7stroke r8stroke /// 
r1strtsmok r2strtsmok r3strtsmok r4strtsmok r5strtsmok r6strtsmok r7strtsmok r8strtsmok ///
r1toiltb r2toiltb r3toiltb r4toiltb r5toiltb r6toiltb r7toiltb r8toiltb  ///
r1transb r2transb r3transb r4transb r5transb r6transb r7transb r8transb  ///
r1urinaf r2urinaf r3urinaf r4urinaf r5urinaf r6urinaf r7urinaf r8urinaf ///
r1urinai r2urinai r3urinai r4urinai r5urinai r6urinai r7urinai r8urinai ///
r1urinb r2urinb r3urinb r4urinb r5urinb r6urinb r7urinb r8urinb  ///
r1urinpad r2urinpad r3urinpad r4urinpad r5urinpad r6urinpad r7urinpad r8urinpad ///
r1vigact r2vigact r3vigact r4vigact r5vigact r6vigact r7vigact r8vigact  ///
r1vigactf_k r2vigactf_k r3vigactf_k r4vigactf_k r5vigactf_k r6vigactf_k r7vigactf_k r8vigactf_k  ///
r1weight r2weight r3weight r4weight r5weight r6weight r7weight r8weight  ///
r1work r2work r3work r4work r5work r6work r7work r8work ///
r2catrct r3catrct r4catrct r5catrct r6catrct r7catrct r8catrct  ///
r2dentim r3dentim r4dentim r5dentim r6dentim r7dentim r8dentim  ///
r2dentst r3dentst r4dentst r5dentst r6dentst r7dentst r8dentst  ///
r2doctim r3doctim r4doctim r5doctim r6doctim r7doctim r8doctim  ///
r2doctor r3doctor r4doctor r5doctor r6doctor r7doctor r8doctor  /// 
r2drugs r3drugs r4drugs r5drugs r6drugs r7drugs r8drugs  ///
r2hcfcl2y r3hcfcl2y r4hcfcl2y r5hcfcl2y r6hcfcl2y r7hcfcl2y r8hcfcl2y /// 
r2hcfnit2y r3hcfnit2y r4hcfnit2y r5hcfnit2y r6hcfnit2y r7hcfnit2y r8hcfnit2y /// 
r2hcftim2y r3hcftim2y r4hcftim2y r5hcftim2y r6hcftim2y r7hcftim2y r8hcftim2y /// 
r2hctim r3hctim r4hctim r5hctim r6hctim r7hctim r8hctim  ///
r2homcar r3homcar r4homcar r5homcar r6homcar r7homcar r8homcar  ///
r2ncatrct r3ncatrct r4ncatrct r5ncatrct r6ncatrct r7ncatrct r8ncatrct /// 
r2oopden r3oopden r4oopden r5oopden r6oopden r7oopden r8oopden  ///
r2oopdoc r3oopdoc r4oopdoc r5oopdoc r6oopdoc r7oopdoc r8oopdoc  ///
r2oopdrug r3oopdrug r4oopdrug r5oopdrug r6oopdrug r7oopdrug r8oopdrug /// 
r2oophmcr r3oophmcr r4oophmcr r5oophmcr r6oophmcr r7oophmcr r8oophmcr ///
r2oophos r3oophos r4oophos r5oophos r6oophos r7oophos r8oophos /// 
r2oopmd r3oopmd r4oopmd r5oopmd r6oopmd r7oopmd r8oopmd  ///
r2ooptrdmd r3ooptrdmd r4ooptrdmd r5ooptrdmd r6ooptrdmd r7ooptrdmd r8ooptrdmd /// 
r2trdmdtim2y r3trdmdtim2y r4trdmdtim2y r5trdmdtim2y r6trdmdtim2y r7trdmdtim2y r8trdmdtim2y /// 
r2trdmed2y r3trdmed2y r4trdmed2y r5trdmed2y r6trdmed2y r7trdmed2y r8trdmed2y /// 
r5cesd10b r6cesd10b r7cesd10b r8cesd10b  ///
r5digeste r6digeste r7digeste r8digeste  ///
r5hiltca_k r6hiltca_k r7hiltca_k r8hiltca_k ///
r5hiltc_k r6hiltc_k r7hiltc_k r8hiltc_k ///
r5rxdigest r6rxdigest r7rxdigest r8rxdigest ///
rabyear rabmonth ///
radadeducl ///
radiaghibp radiagdiab radiagcancr radiaglung radiagheart radiagstrok /// 
radiagpsych radiagarthr radiagliver radiagdigest ///
radyear radmonth ///
raeduc_k ///
raeducl ///
ragender ///
ramomeducl ///
r3act1 r3act2 r3act3 r3act4 r3act5 r3act6 r3act7 ///
r3freq_1 r3freq_2 r3freq_3 r3freq_4 r3freq_5 r3freq_6 r3freq_7 ///
r4act1 r4act2 r4act3 r4act4 r4act5 r4act6 r4act7 ///
r4freq_1 r4freq_2 r4freq_3 r4freq_4 r4freq_5 r4freq_6 r4freq_7 ///
r5act1 r5act2 r5act3 r5act4 r5act5 r5act6 r5act7 ///
r5freq_1 r5freq_2 r5freq_3 r5freq_4 r5freq_5 r5freq_6 r5freq_7 ///
r6act1 r6act2 r6act3 r6act4 r6act5 r6act6 r6act7 ///
r6freq_1 r6freq_2 r6freq_3 r6freq_4 r6freq_5 r6freq_6 r6freq_7 ///
r7act1 r7act2 r7act3 r7act4 r7act5 r7act6 r7act7  ///
r7freq_1 r7freq_2 r7freq_3 r7freq_4 r7freq_5 r7freq_6 r7freq_7 ///
r8act1 r8act2 r8act3 r8act4 r8act5 r8act6 r8act7  ///
r8freq_1 r8freq_2 r8freq_3 r8freq_4 r8freq_5 r8freq_6 r8freq_7 ///
r3vigact_minute r4vigact_minute r5vigact_minute r6vigact_minute r7vigact_minute r8vigact_minute ///
r3pain_1 r3pain_2 r3pain_3 r3pain_4 r3pain_5 r3pain_6 r3pain_7 r3pain_8 r3pain_9 r3pain_10 r3pain_11 r3pain_12 r3pain_13 /// 
r3painlv_1 r3painlv_2 r3painlv_3 r3painlv_4 r3painlv_5 r3painlv_6 r3painlv_7 r3painlv_8 r3painlv_9 r3painlv_10 r3painlv_11 r3painlv_12 r3painlv_13 ///
r4pain_1 r4pain_2 r4pain_3 r4pain_4 r4pain_5 r4pain_6 r4pain_7 r4pain_8 r4pain_9 r4pain_10 r4pain_11 r4pain_12 r4pain_13  ///
r4painlv_1 r4painlv_2 r4painlv_3 r4painlv_4 r4painlv_5 r4painlv_6 r4painlv_7 r4painlv_8 r4painlv_9 r4painlv_10 r4painlv_11 r4painlv_12 r4painlv_13 ///
r5pain_1 r5pain_2 r5pain_3 r5pain_4 r5pain_5 r5pain_6 r5pain_7 r5pain_8 r5pain_9 r5pain_10 r5pain_11 r5pain_12 r5pain_13  ///
r5painlv_1 r5painlv_2 r5painlv_3 r5painlv_4 r5painlv_5 r5painlv_6 r5painlv_7 r5painlv_8 r5painlv_9 r5painlv_10 r5painlv_11 r5painlv_12 r5painlv_13 ///
r6pain_1 r6pain_2 r6pain_3 r6pain_4 r6pain_5 r6pain_6 r6pain_7 r6pain_8 r6pain_9 r6pain_10 r6pain_11 r6pain_12 r6pain_13  ///
r6painlv_1 r6painlv_2 r6painlv_3 r6painlv_4 r6painlv_5 r6painlv_6 r6painlv_7 r6painlv_8 r6painlv_9 r6painlv_10 r6painlv_11 r6painlv_12 r6painlv_13 ///
r7pain_1 r7pain_2 r7pain_3 r7pain_4 r7pain_5 r7pain_6 r7pain_7 r7pain_8 r7pain_9 r7pain_10 r7pain_11 r7pain_12 r7pain_13  ///
r7painlv_1 r7painlv_2 r7painlv_3 r7painlv_4 r7painlv_5 r7painlv_6 r7painlv_7 r7painlv_8 r7painlv_9 r7painlv_10 r7painlv_11 r7painlv_12 r7painlv_13 ///
r8pain_1 r8pain_2 r8pain_3 r8pain_4 r8pain_5 r8pain_6 r8pain_7 r8pain_8 r8pain_9 r8pain_10 r8pain_11 r8pain_12 r8pain_13  ///
r8painlv_1 r8painlv_2 r8painlv_3 r8painlv_4 r8painlv_5 r8painlv_6 r8painlv_7 r8painlv_8 r8painlv_9 r8painlv_10 r8painlv_11 r8painlv_12 r8painlv_13  ///
r3dw r4dw r5dw r6dw r7dw  ///
r3dat r4dat r5dat r6dat r7dat ///
r3place r4place r5place r6place r7place  ///
r3cgdaddr r4cgdaddr r5cgdaddr r6cgdaddr r7cgdaddr  ///
r3imrc3 r4imrc3 r5imrc3 r6imrc3 r7imrc3 /// 
r3ser7 r4ser7 r5ser7 r6ser7 r7ser7 /// 
r3dlrc3 r4dlrc3 r5dlrc3 r6dlrc3 r7dlrc3 ///
r3tr6 r4tr6 r5tr6 r6tr6 r7tr6 ///
r3object1 r4object1 r5object1 r6object1 r7object1 ///
r3object2 r4object2 r5object2 r6object2 r7object2 /// 
r3rpsnt r4rpsnt r5rpsnt r6rpsnt r7rpsnt  ///
r3execu r4execu r5execu r6execu r7execu ///
r3task r4task r5task r6task r7task  ///
r3write r4write r5write r6write r7write  ///
r3draw r4draw r5draw r6draw r7draw ///
r3cog_total r4cog_total r5cog_total r6cog_total r7cog_total ///
r3dementia r4dementia r5dementia r6dementia r7dementia ///
r1atotf r2atotf r3atotf r4atotf r5atotf r6atotf r7atotf r8atotf ///
c2006cpindex c2008cpindex c2010cpindex c2012cpindex c2014cpindex c2016cpindex c2018cpindex c2020cpindex 

*****所有缺失值类型转为.
mvencode _all, mv(-999) 
mvdecode _all, mv(-999)

*****个体编码
*pid 
*hh1hhidc hh2hhidc hh3hhidc hh4hhidc hh5hhidc hh6hhidc hh7hhidc hh8hhidc

*****是否参与本次调查
*inw1 inw2 inw3 inw4 inw5 inw6 inw7 inw8  
label define yesno_ 0 "否" 1 "是"
label values inw1 inw2 inw3 inw4 inw5 inw6 inw7 inw8 yesno_  

*****是否死亡
*r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat r6iwstat r7iwstat r8iwstat
forvalues i=1/8 {
 recode r`i'iwstat (0 1 4=0) (5 6=1) (9=.)
}
label values r1iwstat r2iwstat r3iwstat r4iwstat r5iwstat r6iwstat r7iwstat r8iwstat yesno_ 

*****个体层面横截面权重
*r1wtresp r2wtresp r3wtresp r4wtresp r5wtresp r6wtresp r7wtresp r8wtresp

*****个体层面纵向权重
*r2lwtresp r3lwtresp r4lwtresp r5lwtresp r6lwtresp r7lwtresp r8lwtresp

*****调查年份和月份
*r1iwm r2iwm r3iwm r4iwm r5iwm r6iwm r7iwm r8iwm 
*r1iwy r2iwy r3iwy r4iwy r5iwy r6iwy r7iwy r8iwy

*****出生年份和月份
*rabyear rabmonth

*****死亡年份和月份
*radyear radmonth

*****年龄
*r1agey r2agey r3agey r4agey r5agey r6agey r7agey r8agey

*****性别
*ragender
recode ragender (1=1) (2=0)
label define ragender_ 0 "女性" 1 "男性"
label values ragender ragender_

*****教育程度
*raeduc_k
label define raeduc_k_ 1 "文盲" 2 "可以读写" 3 "小学" 4 "初中" 5 "高中" 6 "专科" ///
7 "大学" 8 "硕士研究生" 9 "博士研究生"
label values raeduc_k raeduc_k_

*****统一可比的教育程度
*raeducl
label define raeducl_ 1 "低于初中学历" 2 "高中及职业培训" 3 "高等教育"
label values raeducl raeducl_

*****婚姻状况
*r1mstath r2mstath r3mstath r4mstath r5mstath r6mstath r7mstath r8mstath
label define mstath_ 1 "已婚或同居" 4 "分居" 5 "离婚" 7 "丧偶" 8 "从未结婚"
label values r1mstath r2mstath r3mstath r4mstath r5mstath r6mstath r7mstath r8mstath mstath_

*****被调查者居住的地区
*r1region_k r2region_k r3region_k r4region_k r5region_k r6region_k r7region_k r8region_k 
label define region_   ///
	11 "Seoul"      ///
	21 "Busan"      /// 
	22 "Daegu"      /// 
	23 "Incheon"    /// 
	24 "GwangJu"    /// 
	25 "Daejeon"    /// 
	26 "Ulsan"      /// 
	27 "Sejong"     /// 
	31 "Gyeonggi"   /// 
	32 "Gangwon"    ///
	33 "Chungbuk"   ///
	34 "Chungnam"   ///
	35 "Jeonbuk"    ///
	36 "Jeonam"     ///
    37 "Gyeonbuk"   ///
	38 "Gyeongnam"
label values r1region_k r2region_k r3region_k r4region_k r5region_k r6region_k r7region_k r8region_k region_
	
*****受访者居住在农村还是城市地区
*r1rural r2rural r3rural r4rural r5rural r6rural r7rural r8rural 
label define rural_ 0 "城市" 1 "农村"
label values r1rural r2rural r3rural r4rural r5rural r6rural r7rural r8rural  rural_

*****受访者是否居住大都市地区、城市或城镇
*r1metrop_k r2metrop_k r3metrop_k r4metrop_k r5metrop_k r6metrop_k r7metrop_k r8metrop_k 
label define metrop_ 1 "大都市" 2 "城市" 3 "城镇"
label values r1metrop_k r2metrop_k r3metrop_k r4metrop_k r5metrop_k r6metrop_k r7metrop_k r8metrop_k metrop_ 

*****宗教信仰
*r1relig_k r2relig_k r3relig_k r4relig_k r5relig_k r6relig_k r7relig_k r8relig_k
label define relig_ 1 "基督教" 2 "天主教" 3 "佛教" 4 "圆佛教" 5 "其他宗教" 6 "没有"
label values r1relig_k r2relig_k r3relig_k r4relig_k r5relig_k r6relig_k r7relig_k r8relig_k relig_

*****自评健康(差/非常好)
*r1shlt r2shlt r3shlt r4shlt r5shlt r6shlt r7shlt r8shlt 
forvalues i=1/8 {
 recode r`i'shlt (1=5) (2=4) (3=3) (4=2) (5=1)
}
label define shlt_ 1 "差" 2 "一般" 3 "好" 4 "很好" 5 "非常好" 
label values r1shlt r2shlt r3shlt r4shlt r5shlt r6shlt r7shlt r8shlt  shlt_

*****自评健康(非常差/很好)
*r1shlta r2shlta r3shlta r4shlta r5shlta r6shlta r7shlta r8shlta
forvalues i=1/8 {
 recode r`i'shlta (1=5) (2=4) (3=3) (4=2) (5=1)
}
label define shlta_ 1 "非常差" 2 "差" 3 "一般" 4 "好" 5 "很好"
label values r1shlta r2shlta r3shlta r4shlta r5shlta r6shlta r7shlta r8shlta shlta_

*****ADL/穿衣需要帮助
*r1dressb r2dressb r3dressb r4dressb r5dressb r6dressb r7dressb r8dressb 
label values r1dressb r2dressb r3dressb r4dressb r5dressb r6dressb r7dressb r8dressb yesno_

*****ADL/洗澡需要帮助
*r1bathb r2bathb r3bathb r4bathb r5bathb r6bathb r7bathb r8bathb 
label values r1bathb r2bathb r3bathb r4bathb r5bathb r6bathb r7bathb r8bathb  yesno_

*****ADL/吃饭需要帮助
*r1eatb r2eatb r3eatb r4eatb r5eatb r6eatb r7eatb r8eatb 
label values r1eatb r2eatb r3eatb r4eatb r5eatb r6eatb r7eatb r8eatb yesno_

*****ADL/上厕所需要帮助
*r1toiltb r2toiltb r3toiltb r4toiltb r5toiltb r6toiltb r7toiltb r8toiltb 
label values r1toiltb r2toiltb r3toiltb r4toiltb r5toiltb r6toiltb r7toiltb r8toiltb  yesno_

*****ADL/上下床需要帮助
*r1bedb_k r2bedb_k r3bedb_k r4bedb_k r5bedb_k r6bedb_k r7bedb_k r8bedb_k 
label values r1bedb_k r2bedb_k r3bedb_k r4bedb_k r5bedb_k r6bedb_k r7bedb_k r8bedb_k  yesno_

*****ADL/刷牙需要帮助
*r1brushb r2brushb r3brushb r4brushb r5brushb r6brushb r7brushb r8brushb 
label values r1brushb r2brushb r3brushb r4brushb r5brushb r6brushb r7brushb r8brushb  yesno_

*****ADL/大小便需要帮助
*r1urinb r2urinb r3urinb r4urinb r5urinb r6urinb r7urinb r8urinb 
label values r1urinb r2urinb r3urinb r4urinb r5urinb r6urinb r7urinb r8urinb  yesno_

*****IADL/做饭需要帮助
*r1mealsb r2mealsb r3mealsb r4mealsb r5mealsb r6mealsb r7mealsb r8mealsb 
label values r1mealsb r2mealsb r3mealsb r4mealsb r5mealsb r6mealsb r7mealsb r8mealsb  yesno_

*****IADL/购物
*r1shopb r2shopb r3shopb r4shopb r5shopb r6shopb r7shopb r8shopb 
label values r1shopb r2shopb r3shopb r4shopb r5shopb r6shopb r7shopb r8shopb yesno_

*****IADL/吃药
*r1medsb r2medsb r3medsb r4medsb r5medsb r6medsb r7medsb r8medsb 
label values r1medsb r2medsb r3medsb r4medsb r5medsb r6medsb r7medsb r8medsb  yesno_

*****IADL/管钱
*r1moneyb r2moneyb r3moneyb r4moneyb r5moneyb r6moneyb r7moneyb r8moneyb 
label values r1moneyb r2moneyb r3moneyb r4moneyb r5moneyb r6moneyb r7moneyb r8moneyb  yesno_

*****IADL/使用电话
*r1phoneb r2phoneb r3phoneb r4phoneb r5phoneb r6phoneb r7phoneb r8phoneb 
label values r1phoneb r2phoneb r3phoneb r4phoneb r5phoneb r6phoneb r7phoneb r8phoneb  yesno_

*****IADL/交通工具
*r1transb r2transb r3transb r4transb r5transb r6transb r7transb r8transb 
label values r1transb r2transb r3transb r4transb r5transb r6transb r7transb r8transb yesno_

*****IADL/短距离外出
*r1gooutb r2gooutb r3gooutb r4gooutb r5gooutb r6gooutb r7gooutb r8gooutb 
label values r1gooutb r2gooutb r3gooutb r4gooutb r5gooutb r6gooutb r7gooutb r8gooutb yesno_

*****IADL/洗衣服
*r1laundryb r2laundryb r3laundryb r4laundryb r5laundryb r6laundryb r7laundryb r8laundryb 
label values r1laundryb r2laundryb r3laundryb r4laundryb r5laundryb r6laundryb r7laundryb r8laundryb yesno_

*****IADL/做家务
*r1housewkb r2housewkb r3housewkb r4housewkb r5housewkb r6housewkb r7housewkb r8housewkb 
label values r1housewkb r2housewkb r3housewkb r4housewkb r5housewkb r6housewkb r7housewkb r8housewkb yesno_

*****IADL/梳妆
*r1groomb r2groomb r3groomb r4groomb r5groomb r6groomb r7groomb r8groomb 
label values r1groomb r2groomb r3groomb r4groomb r5groomb r6groomb r7groomb r8groomb yesno_

*****是否被医生诊断为高血压
*r1hibpe r2hibpe r3hibpe r4hibpe r5hibpe r6hibpe r7hibpe r8hibpe 
label values r1hibpe r2hibpe r3hibpe r4hibpe r5hibpe r6hibpe r7hibpe r8hibpe yesno_

*****是否被医生诊断为糖尿病
*r1diabe r2diabe r3diabe r4diabe r5diabe r6diabe r7diabe r8diabe 
label values r1diabe r2diabe r3diabe r4diabe r5diabe r6diabe r7diabe r8diabe yesno_

*****是否被医生诊断为癌症
*r1cancre r2cancre r3cancre r4cancre r5cancre r6cancre r7cancre r8cancre 
label values r1cancre r2cancre r3cancre r4cancre r5cancre r6cancre r7cancre r8cancre yesno_

*****是否被医生诊断为肺病
*r1lunge r2lunge r3lunge r4lunge r5lunge r6lunge r7lunge r8lunge 
label values r1lunge r2lunge r3lunge r4lunge r5lunge r6lunge r7lunge r8lunge yesno_

*****是否被医生诊断为心脏病
*r1hearte r2hearte r3hearte r4hearte r5hearte r6hearte r7hearte r8hearte
label values r1hearte r2hearte r3hearte r4hearte r5hearte r6hearte r7hearte r8hearte yesno_

*****是否被医生诊断为中风(脑血管疾病)
*r1stroke r2stroke r3stroke r4stroke r5stroke r6stroke r7stroke r8stroke 
label values r1stroke r2stroke r3stroke r4stroke r5stroke r6stroke r7stroke r8stroke yesno_
 
*****是否被医生诊断为心理问题
*r1psyche r2psyche r3psyche r4psyche r5psyche r6psyche r7psyche r8psyche
label values r1psyche r2psyche r3psyche r4psyche r5psyche r6psyche r7psyche r8psyche yesno_
 
*****是否被医生诊断为风湿病
*r1arthre r2arthre r3arthre r4arthre r5arthre r6arthre r7arthre r8arthre 
label values r1arthre r2arthre r3arthre r4arthre r5arthre r6arthre r7arthre r8arthre yesno_

*****是否被医生诊断为肝脏疾病 
*r1livere r2livere r3livere r4livere r5livere r6livere r7livere r8livere 
label values r1livere r2livere r3livere r4livere r5livere r6livere r7livere r8livere yesno_
 
*****是否被医生诊断为消化系统紊乱 
*r5digeste r6digeste r7digeste r8digeste 
label values r5digeste r6digeste r7digeste r8digeste yesno_
 
*****诊断为某疾病的年龄 
*radiaghibp radiagdiab radiagcancr radiaglung radiagheart radiagstrok 
*radiagpsych radiagarthr radiagliver radiagdigest

*****是否服用药物或正在接受高血压治疗
*r1rxhibp r2rxhibp r3rxhibp r4rxhibp r5rxhibp r6rxhibp r7rxhibp r8rxhibp 
label values r1rxhibp r2rxhibp r3rxhibp r4rxhibp r5rxhibp r6rxhibp r7rxhibp r8rxhibp yesno_
 
*****是否服用药物或正在接受糖尿病治疗
*r1rxdiab r2rxdiab r3rxdiab r4rxdiab r5rxdiab r6rxdiab r7rxdiab r8rxdiab 
label values r1rxdiab r2rxdiab r3rxdiab r4rxdiab r5rxdiab r6rxdiab r7rxdiab r8rxdiab yesno_

*****是否服用药物或正在接受癌症治疗
*r1rxcancr r2rxcancr r3rxcancr r4rxcancr r5rxcancr r6rxcancr r7rxcancr r8rxcancr
label values r1rxcancr r2rxcancr r3rxcancr r4rxcancr r5rxcancr r6rxcancr r7rxcancr r8rxcancr yesno_

*****是否服用药物或正在接受肺部疾病治疗
*r1rxlung r2rxlung r3rxlung r4rxlung r5rxlung r6rxlung r7rxlung r8rxlung 
label values r1rxlung r2rxlung r3rxlung r4rxlung r5rxlung r6rxlung r7rxlung r8rxlung yesno_

*****是否服用药物或正在接受心脏问题的治疗
*r1rxheart r2rxheart r3rxheart r4rxheart r5rxheart r6rxheart r7rxheart r8rxheart 
label values r1rxheart r2rxheart r3rxheart r4rxheart r5rxheart r6rxheart r7rxheart r8rxheart yesno_

*****是否服用药物或正在接受中风治疗
*r1rxstrok r2rxstrok r3rxstrok r4rxstrok r5rxstrok r6rxstrok r7rxstrok r8rxstrok 
label values r1rxstrok r2rxstrok r3rxstrok r4rxstrok r5rxstrok r6rxstrok r7rxstrok r8rxstrok yesno_

*****是否服用药物或正在接受精神病学或心理治疗 
*r1rxpsych r2rxpsych r3rxpsych r4rxpsych r5rxpsych r6rxpsych r7rxpsych r8rxpsych 
label values r1rxpsych r2rxpsych r3rxpsych r4rxpsych r5rxpsych r6rxpsych r7rxpsych r8rxpsych yesno_

*****是否服用药物或正在接受关节炎或风湿病的治疗
*r1rxarthr r2rxarthr r3rxarthr r4rxarthr r5rxarthr r6rxarthr r7rxarthr r8rxarthr 
label values r1rxarthr r2rxarthr r3rxarthr r4rxarthr r5rxarthr r6rxarthr r7rxarthr r8rxarthr yesno_

*****是否服用药物或正在接受肝病治疗
*r1rxliver r2rxliver r3rxliver r4rxliver r5rxliver r6rxliver r7rxliver r8rxliver 
label values r1rxliver r2rxliver r3rxliver r4rxliver r5rxliver r6rxliver r7rxliver r8rxliver yesno_

*****是否服用药物或正在接受消化系统疾病的治疗
*r5rxdigest r6rxdigest r7rxdigest r8rxdigest
label values r5rxdigest r6rxdigest r7rxdigest r8rxdigest yesno_

*****自报BMI
*r1bmi r2bmi r3bmi r4bmi r5bmi r6bmi r7bmi r8bmi 

*****自报身高
*r1height r2height r3height r4height r5height r6height r7height r8height 

*****自报体重
*r1weight r2weight r3weight r4weight r5weight r6weight r7weight r8weight 

*****自报BMI分类
*r1bmicat r2bmicat r3bmicat r4bmicat r5bmicat r6bmicat r7bmicat r8bmicat 
label define bmicat_ 1 "体重不足" 2 "正常体重" 3 "肥胖前期" 4 "肥胖等级1" ///
  5 "肥胖等级2" 6 "肥胖等级3" 
label values r1bmicat r2bmicat r3bmicat r4bmicat r5bmicat r6bmicat r7bmicat r8bmicat bmicat_

*****是否肥胖
*r1obese r2obese r3obese r4obese r5obese r6obese r7obese r8obese 
label values r1obese r2obese r3obese r4obese r5obese r6obese r7obese r8obese yesno_

*****自评视力
*r1sighta r2sighta r3sighta r4sighta r5sighta r6sighta r7sighta r8sighta 
label define sighta_ 0 "失明" 1 "很差" 2 "差" 3 "一般" 4 "好" 5 "很好"
label values r1sighta r2sighta r3sighta r4sighta r5sighta r6sighta r7sighta r8sighta sighta_

*****远视视力
*r1dsighta r2dsighta r3dsighta r4dsighta r5dsighta r6dsighta r7dsighta r8dsighta 
label values r1dsighta r2dsighta r3dsighta r4dsighta r5dsighta r6dsighta r7dsighta r8dsighta sighta_

*****近视视力
*r1nsighta r2nsighta r3nsighta r4nsighta r5nsighta r6nsighta r7nsighta r8nsighta 
label values r1nsighta r2nsighta r3nsighta r4nsighta r5nsighta r6nsighta r7nsighta r8nsighta sighta_

*****是否曾报告做过白内障手术
*r1catrcte r2catrcte r3catrcte r4catrcte r5catrcte r6catrcte r7catrcte r8catrcte 
label values r1catrcte r2catrcte r3catrcte r4catrcte r5catrcte r6catrcte r7catrcte r8catrcte yesno_

*****是否在过去两年内做过白内障手术
*r2catrct r3catrct r4catrct r5catrct r6catrct r7catrct r8catrct 
label values r2catrct r3catrct r4catrct r5catrct r6catrct r7catrct r8catrct yesno_

*****过去两年中接受过白内障手术的眼睛数量
*r2ncatrct r3ncatrct r4ncatrct r5ncatrct r6ncatrct r7ncatrct r8ncatrct 

*****是否曾经接受过青光眼治疗
*r1glaucoma r2glaucoma r3glaucoma r4glaucoma r5glaucoma r6glaucoma r7glaucoma r8glaucoma 
label values r1glaucoma r2glaucoma r3glaucoma r4glaucoma r5glaucoma r6glaucoma r7glaucoma r8glaucoma  yesno_
 
*****视力是否限制了应答者的日常活动
*r1sightlmt r2sightlmt r3sightlmt r4sightlmt r5sightlmt r6sightlmt r7sightlmt r8sightlmt
label values r1sightlmt r2sightlmt r3sightlmt r4sightlmt r5sightlmt r6sightlmt r7sightlmt r8sightlmt yesno_

*****自评听力
*r1hearinga r2hearinga r3hearinga r4hearinga r5hearinga r6hearinga r7hearinga r8hearinga 
forvalues i=1/8 {
 recode r`i'hearinga (1=5) (2=4) (3=3) (4=2) (5=1)	
}
label define hearinga_ 1 "很差" 2 "差" 3 "一般" 4 "好" 5 "很好"
label values r1hearinga r2hearinga r3hearinga r4hearinga r5hearinga r6hearinga r7hearinga r8hearinga hearinga_

*****是否佩戴过助听器
*r1hearaid r2hearaid r3hearaid r4hearaid r5hearaid r6hearaid r7hearaid r8hearaid 
label values r1hearaid r2hearaid r3hearaid r4hearaid r5hearaid r6hearaid r7hearaid r8hearaid yesno_

*****听力是否限制了被告的日常活动
*r1hearlmt r2hearlmt r3hearlmt r4hearlmt r5hearlmt r6hearlmt r7hearlmt r8hearlmt
label values r1hearlmt r2hearlmt r3hearlmt r4hearlmt r5hearlmt r6hearlmt r7hearlmt r8hearlmt yesno_

*****过去2年内是否跌倒
*r1fall r2fall r3fall r4fall r5fall r6fall r7fall r8fall 
label values r1fall r2fall r3fall r4fall r5fall r6fall r7fall r8fall yesno_

*****过去两年中跌倒的次数
*r1fallnum r2fallnum r3fallnum r4fallnum r5fallnum r6fallnum r7fallnum r8fallnum 

*****在跌倒中受伤是否严重到需要医疗
*r1fallinj r2fallinj r3fallinj r4fallinj r5fallinj r6fallinj r7fallinj r8fallinj 
label values r1fallinj r2fallinj r3fallinj r4fallinj r5fallinj r6fallinj r7fallinj r8fallinj yesno_

*****是否曾因跌倒而髋部骨折
*r1hipe_k r2hipe_k r3hipe_k r4hipe_k r5hipe_k r6hipe_k r7hipe_k r8hipe_k 
label values r1hipe_k r2hipe_k r3hipe_k r4hipe_k r5hipe_k r6hipe_k r7hipe_k r8hipe_k yesno_

*****因跌倒而受伤或骨折是否限制了被调查者的日常活动
*r1injlmt r2injlmt r3injlmt r4injlmt r5injlmt r6injlmt r7injlmt r8injlmt
label values r1injlmt r2injlmt r3injlmt r4injlmt r5injlmt r6injlmt r7injlmt r8injlmt yesno_

*****过去12个月里是否有过尿失禁的经历
*r1urinai r2urinai r3urinai r4urinai r5urinai r6urinai r7urinai r8urinai
label values r1urinai r2urinai r3urinai r4urinai r5urinai r6urinai r7urinai r8urinai yesno_

*****上个月经历尿失禁的天数
*r1urinaf r2urinaf r3urinaf r4urinaf r5urinaf r6urinaf r7urinaf r8urinaf

*****是否曾经使用过任何吸收性产品治疗尿失禁
*r1urinpad r2urinpad r3urinpad r4urinpad r5urinpad r6urinpad r7urinpad r8urinpad
label values r1urinpad r2urinpad r3urinpad r4urinpad r5urinpad r6urinpad r7urinpad r8urinpad yesno_

*****当前是否经历疼痛
*r1painfr r2painfr r3painfr r4painfr r5painfr r6painfr r7painfr r8painfr 
label values r1painfr r2painfr r3painfr r4painfr r5painfr r6painfr r7painfr r8painfr  yesno_

*****最高疼痛程度
*r1painhlv r2painhlv r3painhlv r4painhlv r5painhlv r6painhlv r7painhlv r8painhlv  
label define painhlv_ 0 "没有疼痛" 1 "轻度" 2 "中度" 3 "严重"
label values r1painhlv r2painhlv r3painhlv r4painhlv r5painhlv r6painhlv r7painhlv r8painhlv painhlv_
 
*****疼痛是否干扰了正常的活动
*r1paina r2paina r3paina r4paina r5paina r6paina r7paina r8paina 
label values r1paina r2paina r3paina r4paina r5paina r6paina r7paina r8paina  yesno_
 
*****是否锻炼
*r1vigact r2vigact r3vigact r4vigact r5vigact r6vigact r7vigact r8vigact 
label values r1vigact r2vigact r3vigact r4vigact r5vigact r6vigact r7vigact r8vigact yesno_
 
*****锻炼的频率
*r1vigactf_k r2vigactf_k r3vigactf_k r4vigactf_k r5vigactf_k r6vigactf_k r7vigactf_k r8vigactf_k 
 
*****是否曾经喝过酒
*r1drinkev r2drinkev r3drinkev r4drinkev r5drinkev r6drinkev r7drinkev r8drinkev 
label values r1drinkev r2drinkev r3drinkev r4drinkev r5drinkev r6drinkev r7drinkev r8drinkev yesno_
 
*****目前是否喝酒
*r1drink r2drink r3drink r4drink r5drink r6drink r7drink r8drink 
label values r1drink r2drink r3drink r4drink r5drink r6drink r7drink r8drink yesno_
 
*****饮酒的频率
*r1drinkx r2drinkx r3drinkx r4drinkx r5drinkx r6drinkx r7drinkx r8drinkx 
label define drinkx_ 0 "每月1次或少于1次" 1 "每月至少一次" 2 "每周至少一次" 3 "每周大部分时间" 4 "每周每天"
label values r1drinkx r2drinkx r3drinkx r4drinkx r5drinkx r6drinkx r7drinkx r8drinkx drinkx_  

*****单次饮用的最大数量
*r1drinkn_k r2drinkn_k r3drinkn_k r4drinkn_k r5drinkn_k r6drinkn_k r7drinkn_k r8drinkn_k 
 
*****是否曾经抽过烟
*r1smokev r2smokev r3smokev r4smokev r5smokev r6smokev r7smokev r8smokev 
label values r1smokev r2smokev r3smokev r4smokev r5smokev r6smokev r7smokev r8smokev yesno_
 
*****现在是否吸烟
*r1smoken r2smoken r3smoken r4smoken r5smoken r6smoken r7smoken r8smoken
label values r1smoken r2smoken r3smoken r4smoken r5smoken r6smoken r7smoken r8smoken yesno_ 
 
*****每天抽多少支烟
*r1smokef r2smokef r3smokef r4smokef r5smokef r6smokef r7smokef r8smokef 
 
*****开始吸烟的年龄
*r1strtsmok r2strtsmok r3strtsmok r4strtsmok r5strtsmok r6strtsmok r7strtsmok r8strtsmok
 
*****戒烟的年龄
*r1quitsmok r2quitsmok r3quitsmok r4quitsmok r5quitsmok r6quitsmok r7quitsmok r8quitsmok 
 
*****过去两年是否在医院、疗养院、疗养院或其他长期卫生保健机构住院
*r2hcfcl2y r3hcfcl2y r4hcfcl2y r5hcfcl2y r6hcfcl2y r7hcfcl2y r8hcfcl2y 
label values r2hcfcl2y r3hcfcl2y r4hcfcl2y r5hcfcl2y r6hcfcl2y r7hcfcl2y r8hcfcl2y yesno_ 
 
*****过去两年在医院、疗养院、疗养院或其他长期卫生保健机构住院的次数
*r2hcftim2y r3hcftim2y r4hcftim2y r5hcftim2y r6hcftim2y r7hcftim2y r8hcftim2y 

*****过去两年在医院、疗养院、疗养院或其他长期卫生保健机构住院的天数
*r2hcfnit2y r3hcfnit2y r4hcfnit2y r5hcfnit2y r6hcfnit2y r7hcfnit2y r8hcfnit2y 
 
*****过去两年是否去过公共卫生诊所
*r2doctor r3doctor r4doctor r5doctor r6doctor r7doctor r8doctor 
 
*****过去两年公共卫生诊所和医生就诊次数的总和
*r2doctim r3doctim r4doctim r5doctim r6doctim r7doctim r8doctim 
 
*****过去两年是否看过传统医学
*r2trdmed2y r3trdmed2y r4trdmed2y r5trdmed2y r6trdmed2y r7trdmed2y r8trdmed2y 
label values r2trdmed2y r3trdmed2y r4trdmed2y r5trdmed2y r6trdmed2y r7trdmed2y r8trdmed2y yesno_ 
 
*****过去两年看过传统医学的次数
*r2trdmdtim2y r3trdmdtim2y r4trdmdtim2y r5trdmdtim2y r6trdmdtim2y r7trdmdtim2y r8trdmdtim2y 
label values r2trdmdtim2y r3trdmdtim2y r4trdmdtim2y r5trdmdtim2y r6trdmdtim2y r7trdmdtim2y r8trdmdtim2y yesno_  

*****过去两年是否接受过任何家庭护理服务
*r2homcar r3homcar r4homcar r5homcar r6homcar r7homcar r8homcar 
label values r2homcar r3homcar r4homcar r5homcar r6homcar r7homcar r8homcar yesno_ 

*****过去两年家庭护理服务次数
*r2hctim r3hctim r4hctim r5hctim r6hctim r7hctim r8hctim 
 
*****过去两年是否接受过牙科护理
*r2dentst r3dentst r4dentst r5dentst r6dentst r7dentst r8dentst 
label values r2dentst r3dentst r4dentst r5dentst r6dentst r7dentst r8dentst yesno_
 
*****过去两年接受过牙科护理次数 
*r2dentim r3dentim r4dentim r5dentim r6dentim r7dentim r8dentim 

*****过去两年是否定期服用处方药 
*r2drugs r3drugs r4drugs r5drugs r6drugs r7drugs r8drugs 
label values r2drugs r3drugs r4drugs r5drugs r6drugs r7drugs r8drugs yesno_

*****过去两年住院和医院护理人员的自付支出 
*r2oophos r3oophos r4oophos r5oophos r6oophos r7oophos r8oophos 

*****过去两年牙科护理自付支出
*r2oopden r3oopden r4oopden r5oopden r6oopden r7oopden r8oopden 
 
*****过去两年传统医学自费支出 
*r2ooptrdmd r3ooptrdmd r4ooptrdmd r5ooptrdmd r6ooptrdmd r7ooptrdmd r8ooptrdmd 

*****过去两年去看医生和急诊室的自费 
*r2oopdoc r3oopdoc r4oopdoc r5oopdoc r6oopdoc r7oopdoc r8oopdoc 

*****过去两年家庭护理的自费支出  
*r2oophmcr r3oophmcr r4oophmcr r5oophmcr r6oophmcr r7oophmcr r8oophmcr
 
*****过去两年处方药费用的自付支出  
*r2oopdrug r3oopdrug r4oopdrug r5oopdrug r6oopdrug r7oopdrug r8oopdrug 
 
*****过去两年自付支出的总和 
*r2oopmd r3oopmd r4oopmd r5oopmd r6oopmd r7oopmd r8oopmd 
 
*****参加的政府健康保险计划的类型 
*r1higovt_k r2higovt_k r3higovt_k r4higovt_k r5higovt_k r6higovt_k r7higovt_k r8higovt_k
label define higovt_k_ 1 "国民健康保险计划" 2 "医疗援助保险计划"
label values r1higovt_k r2higovt_k r3higovt_k r4higovt_k r5higovt_k r6higovt_k r7higovt_k r8higovt_k higovt_k_

*****是否有任何私人健康保险  
*r1hipriv r2hipriv r3hipriv r4hipriv r5hipriv r6hipriv r7hipriv r8hipriv
label values r1hipriv r2hipriv r3hipriv r4hipriv r5hipriv r6hipriv r7hipriv r8hipriv yesno_

*****是否申请了长期护理保险 
*r5hiltca_k r6hiltca_k r7hiltca_k r8hiltca_k
label values r5hiltca_k r6hiltca_k r7hiltca_k r8hiltca_k yesno_

*****是否使用长期护理保险 
*r5hiltc_k r6hiltc_k r7hiltc_k r8hiltc_k
label values r5hiltc_k r6hiltc_k r7hiltc_k r8hiltc_k yesno_

*****非住房金融财富净值
*r1atotf r2atotf r3atotf r4atotf r5atotf r6atotf r7atotf r8atotf

*****非住房金融财富净值(调至2010)
gen r1wealth = r1atotf/c2006cpindex*c2010cpindex
gen r2wealth = r2atotf/c2008cpindex*c2010cpindex
gen r3wealth = r3atotf/c2010cpindex*c2010cpindex
gen r4wealth = r4atotf/c2012cpindex*c2010cpindex
gen r5wealth = r5atotf/c2014cpindex*c2010cpindex
gen r6wealth = r6atotf/c2016cpindex*c2010cpindex
gen r7wealth = r7atotf/c2018cpindex*c2010cpindex
gen r8wealth = r8atotf/c2020cpindex*c2010cpindex

*****总净财富
*r1atotb r2atotb r3atotb r4atotb r5atotb r6atotb r7atotb r8atotb

*****过去一年的税后工资收入和兼职收入
*r1itearn r2itearn r3itearn r4itearn r5itearn r6itearn r7itearn r8itearn 

*****过去一年的总收入
*r1itot r2itot r3itot r4itot r5itot r6itot r7itot r8itot 

*****过去一年的家庭总收入(直接问题)
*r1itothhinc r2itothhinc r3itothhinc r4itothhinc r5itothhinc r6itothhinc r7itothhinc r8itothhinc 

*****家庭年消费
*hh2ctot hh3ctot hh4ctot hh5ctot hh6ctot hh7ctot hh8ctot 

*****家庭年人均消费
*hh2cperc hh3cperc hh4cperc hh5cperc hh6cperc hh7cperc hh8cperc 

*****家庭成员人数
*h1hhres h2hhres h3hhres h4hhres h5hhres h6hhres h7hhres h8hhres 

*****健在子女数
*h1child h2child h3child h4child h5child h6child h7child h8child

*****母亲是否健在
*r1momliv r2momliv r3momliv r4momliv r5momliv r6momliv r7momliv r8momliv 

*****父亲是否健在
*r1dadliv r2dadliv r3dadliv r4dadliv r5dadliv r6dadliv r7dadliv r8dadliv 

*****母亲的教育程度
*ramomeducl
label define ramomeducl_ 1 "低于初中学历" 2 "高中和职业培训" 3 "高等教育"
label values ramomeducl ramomeducl_

*****父亲的教育程度
*radadeducl
label define radadeducl_ 1 "低于初中学历" 2 "高中和职业培训" 3 "高等教育"
label values radadeducl radadeducl_

*****是否与子女同住
*h1coresd h2coresd h3coresd h4coresd h5coresd h6coresd h7coresd h8coresd 
label values h1coresd h2coresd h3coresd h4coresd h5coresd h6coresd h7coresd h8coresd yesno_

*****是否参加每周的社会活动
*r1socwk r2socwk r3socwk r4socwk r5socwk r6socwk r7socwk r8socwk 
label values r1socwk r2socwk r3socwk r4socwk r5socwk r6socwk r7socwk r8socwk yesno_

*****参加教会或其他宗教活动的频率
*r1socrelg_k r2socrelg_k r3socrelg_k r4socrelg_k r5socrelg_k r6socrelg_k r7socrelg_k r8socrelg_k 
forvalues i=1/8 {
 recode r`i'socrelg_k (1=11) (2=10) (3=9) (4=8) (5=7) (6=6) (7=5) (8=4) (9=3) (10=2) (11=1)
}
label define socrelg_k_ 1 "没有参与" 2 "几乎没有" 3 "几乎一年都没有" 4 "一年一两次" ///
 5 "一年三到四次" 6 "一年五六次" 7 "每月一次" 8 "每月两次" 9 "一周一次" 10 "一周两三次" 11 "几乎每天"
label values r1socrelg_k r2socrelg_k r3socrelg_k r4socrelg_k r5socrelg_k r6socrelg_k r7socrelg_k r8socrelg_k socrelg_k_ 

*****是否参加每周一次的教会或其他宗教活动
*r1relgwk r2relgwk r3relgwk r4relgwk r5relgwk r6relgwk r7relgwk r8relgwk
label values r1relgwk r2relgwk r3relgwk r4relgwk r5relgwk r6relgwk r7relgwk r8relgwk yesno_

*****过去一年中是否给予子女、儿媳和/或孙辈任何经济帮助
*h1tcany h2tcany h3tcany h4tcany h5tcany h6tcany h7tcany h8tcany
label values h1tcany h2tcany h3tcany h4tcany h5tcany h6tcany h7tcany h8tcany yesno_

*****过去一年中给子女、儿媳、孙辈的资金总额
*h1tcamt h2tcamt h3tcamt h4tcamt h5tcamt h6tcamt h7tcamt h8tcamt 

*****过去一年中是否从子女、儿媳和/或孙辈那里获得任何经济帮助
*h1fcany h2fcany h3fcany h4fcany h5fcany h6fcany h7fcany h8fcany 
label values h1fcany h2fcany h3fcany h4fcany h5fcany h6fcany h7fcany h8fcany yesno_

*****过去一年中从子女、儿媳、孙辈那里获得的资金总额
*h1fcamt h2fcamt h3fcamt h4fcamt h5fcamt h6fcamt h7fcamt h8fcamt 

*****过去一年中是否向其母亲、父亲、婆婆或公公进行过任何财务转移
*h1tpany h2tpany h3tpany h4tpany h5tpany h6tpany h7tpany h8tpany
label values h1tpany h2tpany h3tpany h4tpany h5tpany h6tpany h7tpany h8tpany yesno_

*****过去一年中向父母支付的资金总额
*h1tpamt h2tpamt h3tpamt h4tpamt h5tpamt h6tpamt h7tpamt h8tpamt 

*****过去一年中是否从其母亲、父亲、岳母或岳父那里获得任何财务转移
*h1fpany h2fpany h3fpany h4fpany h5fpany h6fpany h7fpany h8fpany
label values h1fpany h2fpany h3fpany h4fpany h5fpany h6fpany h7fpany h8fpany yesno_

*****过去一年中从父母那里得到的资金总额
*h1fpamt h2fpamt h3fpamt h4fpamt h5fpamt h6fpamt h7fpamt h8fpamt

*****目前是否在领薪工作
*r1work r2work r3work r4work r5work r6work r7work r8work
label values r1work r2work r3work r4work r5work r6work r7work r8work yesno_

*****是否自雇
*r1slfemp r2slfemp r3slfemp r4slfemp r5slfemp r6slfemp r7slfemp r8slfemp
label values r1slfemp r2slfemp r3slfemp r4slfemp r5slfemp r6slfemp r7slfemp r8slfemp yesno_

*****劳动力状况
*r1lbrf_k r2lbrf_k r3lbrf_k r4lbrf_k r5lbrf_k r6lbrf_k r7lbrf_k r8lbrf_k
label define lbrf_k 1 "全职工作" 2 "兼职" 3 "自由职业者" 4 "每周为家庭提供18小时或更多的帮助" ///
5 "失业" 6 "部分退休" 7 "退休" 8 "残疾" 9 "不在劳动力市场"
label values r1lbrf_k r2lbrf_k r3lbrf_k r4lbrf_k r5lbrf_k r6lbrf_k r7lbrf_k r8lbrf_k lbrf_k

*****左手第一只手力量测量值
*r1lgrip1 r2lgrip1 r3lgrip1 r4lgrip1 r5lgrip1 r6lgrip1 r7lgrip1 r8lgrip1 

*****左手第二只手力量测量值
*r1lgrip2 r2lgrip2 r3lgrip2 r4lgrip2 r5lgrip2 r6lgrip2 r7lgrip2 r8lgrip2 
 
*****右手第一只手力量测量值
*r1rgrip1 r2rgrip1 r3rgrip1 r4rgrip1 r5rgrip1 r6rgrip1 r7rgrip1 r8rgrip1
 
*****右手第一只手力量测量值
*r1rgrip2 r2rgrip2 r3rgrip2 r4rgrip2 r5rgrip2 r6rgrip2 r7rgrip2 r8rgrip2
 
*****左手最大手部力量测量值
*r1lgrip r2lgrip r3lgrip r4lgrip r5lgrip r6lgrip r7lgrip r8lgrip 
 
*****右手的最大手部力量测量值
*r1rgrip r2rgrip r3rgrip r4rgrip r5rgrip r6rgrip r7rgrip r8rgrip

*****优势手握力
*r1gripsum r2gripsum r3gripsum r4gripsum r5gripsum r6gripsum r7gripsum r8gripsum 

*****是否愿意并且能够完成握力测试
*r1gripcomp r2gripcomp r3gripcomp r4gripcomp r5gripcomp r6gripcomp r7gripcomp r8gripcomp 
label values r1gripcomp r2gripcomp r3gripcomp r4gripcomp r5gripcomp r6gripcomp r7gripcomp r8gripcomp yesno_

*****在进行握力测试时是否得到了支持
*r1gripast r2gripast r3gripast r4gripast r5gripast r6gripast r7gripast r8gripast 
label values r1gripast r2gripast r3gripast r4gripast r5gripast r6gripast r7gripast r8gripast yesno_
 
*****(分数越高越抑郁)
*r1cesd10a r2cesd10a r3cesd10a r4cesd10a 
*r5cesd10b r6cesd10b r7cesd10b r8cesd10b 

*****是否参加各种组织活动以及频率
*r3act1 r3act2 r3act3 r3act4 r3act5 r3act6 r3act7
*r3freq_1 r3freq_2 r3freq_3 r3freq_4 r3freq_5 r3freq_6 r3freq_7
*r4act1 r4act2 r4act3 r4act4 r4act5 r4act6 r4act7
*r4freq_1 r4freq_2 r4freq_3 r4freq_4 r4freq_5 r4freq_6 r4freq_7
*r5act1 r5act2 r5act3 r5act4 r5act5 r5act6 r5act7
*r5freq_1 r5freq_2 r5freq_3 r5freq_4 r5freq_5 r5freq_6 r5freq_7
*r6act1 r6act2 r6act3 r6act4 r6act5 r6act6 r6act7
*r6freq_1 r6freq_2 r6freq_3 r6freq_4 r6freq_5 r6freq_6 r6freq_7
*r7act1 r7act2 r7act3 r7act4 r7act5 r7act6 r7act7 
*r7freq_1 r7freq_2 r7freq_3 r7freq_4 r7freq_5 r7freq_6 r7freq_7
*r8act1 r8act2 r8act3 r8act4 r8act5 r8act6 r8act7 
*r8freq_1 r8freq_2 r8freq_3 r8freq_4 r8freq_5 r8freq_6 r8freq_7
label values r3act1 r3act2 r3act3 r3act4 r3act5 r3act6 r3act7 ///
r4act1 r4act2 r4act3 r4act4 r4act5 r4act6 r4act7 ///
r5act1 r5act2 r5act3 r5act4 r5act5 r5act6 r5act7 ///
r6act1 r6act2 r6act3 r6act4 r6act5 r6act6 r6act7 ///
r7act1 r7act2 r7act3 r7act4 r7act5 r7act6 r7act7 ///
r8act1 r8act2 r8act3 r8act4 r8act5 r8act6 r8act7 yesno_


*****每次身体锻炼多长时间
*r3vigact_minute r4vigact_minute r5vigact_minute r6vigact_minute r7vigact_minute r8vigact_minute 

*****疼痛
*r3pain_1 r3pain_2 r3pain_3 r3pain_4 r3pain_5 r3pain_6 r3pain_7 r3pain_8 r3pain_9 r3pain_10 r3pain_11 r3pain_12 r3pain_13 
*r3painlv_1 r3painlv_2 r3painlv_3 r3painlv_4 r3painlv_5 r3painlv_6 r3painlv_7 r3painlv_8 r3painlv_9 r3painlv_10 r3painlv_11 r3painlv_12 r3painlv_13
*r4pain_1 r4pain_2 r4pain_3 r4pain_4 r4pain_5 r4pain_6 r4pain_7 r4pain_8 r4pain_9 r4pain_10 r4pain_11 r4pain_12 r4pain_13 
*r4painlv_1 r4painlv_2 r4painlv_3 r4painlv_4 r4painlv_5 r4painlv_6 r4painlv_7 r4painlv_8 r4painlv_9 r4painlv_10 r4painlv_11 r4painlv_12 r4painlv_13
*r5pain_1 r5pain_2 r5pain_3 r5pain_4 r5pain_5 r5pain_6 r5pain_7 r5pain_8 r5pain_9 r5pain_10 r5pain_11 r5pain_12 r5pain_13 
*r5painlv_1 r5painlv_2 r5painlv_3 r5painlv_4 r5painlv_5 r5painlv_6 r5painlv_7 r5painlv_8 r5painlv_9 r5painlv_10 r5painlv_11 r5painlv_12 r5painlv_13
*r6pain_1 r6pain_2 r6pain_3 r6pain_4 r6pain_5 r6pain_6 r6pain_7 r6pain_8 r6pain_9 r6pain_10 r6pain_11 r6pain_12 r6pain_13 
*r6painlv_1 r6painlv_2 r6painlv_3 r6painlv_4 r6painlv_5 r6painlv_6 r6painlv_7 r6painlv_8 r6painlv_9 r6painlv_10 r6painlv_11 r6painlv_12 r6painlv_13
*r7pain_1 r7pain_2 r7pain_3 r7pain_4 r7pain_5 r7pain_6 r7pain_7 r7pain_8 r7pain_9 r7pain_10 r7pain_11 r7pain_12 r7pain_13 
*r7painlv_1 r7painlv_2 r7painlv_3 r7painlv_4 r7painlv_5 r7painlv_6 r7painlv_7 r7painlv_8 r7painlv_9 r7painlv_10 r7painlv_11 r7painlv_12 r7painlv_13
*r8pain_1 r8pain_2 r8pain_3 r8pain_4 r8pain_5 r8pain_6 r8pain_7 r8pain_8 r8pain_9 r8pain_10 r8pain_11 r8pain_12 r8pain_13 
*r8painlv_1 r8painlv_2 r8painlv_3 r8painlv_4 r8painlv_5 r8painlv_6 r8painlv_7 r8painlv_8 r8painlv_9 r8painlv_10 r8painlv_11 r8painlv_12 r8painlv_13 
label values r3pain_1 r3pain_2 r3pain_3 r3pain_4 r3pain_5 r3pain_6 r3pain_7 r3pain_8 r3pain_9 r3pain_10 r3pain_11 r3pain_12 r3pain_13 ///
r4pain_1 r4pain_2 r4pain_3 r4pain_4 r4pain_5 r4pain_6 r4pain_7 r4pain_8 r4pain_9 r4pain_10 r4pain_11 r4pain_12 r4pain_13 ///
r5pain_1 r5pain_2 r5pain_3 r5pain_4 r5pain_5 r5pain_6 r5pain_7 r5pain_8 r5pain_9 r5pain_10 r5pain_11 r5pain_12 r5pain_13 ///
r6pain_1 r6pain_2 r6pain_3 r6pain_4 r6pain_5 r6pain_6 r6pain_7 r6pain_8 r6pain_9 r6pain_10 r6pain_11 r6pain_12 r6pain_13 ///
r7pain_1 r7pain_2 r7pain_3 r7pain_4 r7pain_5 r7pain_6 r7pain_7 r7pain_8 r7pain_9 r7pain_10 r7pain_11 r7pain_12 r7pain_13 ///
r8pain_1 r8pain_2 r8pain_3 r8pain_4 r8pain_5 r8pain_6 r8pain_7 r8pain_8 r8pain_9 r8pain_10 r8pain_11 r8pain_12 r8pain_13 yesno_

label define pain_ 0 "无" 1 "轻微" 2 "严重" 3 "非常严重"
label values r3painlv_1 r3painlv_2 r3painlv_3 r3painlv_4 r3painlv_5 r3painlv_6 r3painlv_7 r3painlv_8 r3painlv_9 ///
r3painlv_10 r3painlv_11 r3painlv_12 r3painlv_13 r4painlv_1 r4painlv_2 r4painlv_3 r4painlv_4 r4painlv_5 r4painlv_6 ///
r4painlv_7 r4painlv_8 r4painlv_9 r4painlv_10 r4painlv_11 r4painlv_12 r4painlv_13 r5painlv_1 r5painlv_2 r5painlv_3 ///
r5painlv_4 r5painlv_5 r5painlv_6 r5painlv_7 r5painlv_8 r5painlv_9 r5painlv_10 r5painlv_11 r5painlv_12 r5painlv_13 ///
r6painlv_1 r6painlv_2 r6painlv_3 r6painlv_4 r6painlv_5 r6painlv_6 r6painlv_7 r6painlv_8 r6painlv_9 r6painlv_10 ///
r6painlv_11 r6painlv_12 r6painlv_13 r7painlv_1 r7painlv_2 r7painlv_3 r7painlv_4 r7painlv_5 r7painlv_6 r7painlv_7 ///
r7painlv_8 r7painlv_9 r7painlv_10 r7painlv_11 r7painlv_12 r7painlv_13 r8painlv_1 r8painlv_2 r8painlv_3 r8painlv_4 ///
r8painlv_5 r8painlv_6 r8painlv_7 r8painlv_8 r8painlv_9 r8painlv_10 r8painlv_11 r8painlv_12 r8painlv_13 pain_

*****认知
*r3dw r4dw r5dw r6dw r7dw 
*r3dat r4dat r5dat r6dat r7dat
*r3ssn r4ssn r5ssn r6ssn r7ssn 
*r3place r4place r5place r6place r7place 
*r3cgdaddr r4cgdaddr r5cgdaddr r6cgdaddr r7cgdaddr 
*r3imrc3 r4imrc3 r5imrc3 r6imrc3 r7imrc3 
*r3ser7 r4ser7 r5ser7 r6ser7 r7ser7 
*r3dlrc3 r4dlrc3 r5dlrc3 r6dlrc3 r7dlrc3
*r3tr6 r4tr6 r5tr6 r6tr6 r7tr6
*r3object1 r4object1 r5object1 r6object1 r7object1
*r3object2 r4object2 r5object2 r6object2 r7object2 
*r3rpsnt r4rpsnt r5rpsnt r6rpsnt r7rpsnt 
*r3execu r4execu r5execu r6execu r7execu
*r3task r4task r5task r6task r7task 
*r3write r4write r5write r6write r7write 
*r3draw r4draw r5draw r6draw r7draw
*r3cog_total r4cog_total r5cog_total r6cog_total r7cog_total
*r3dementia r4dementia r5dementia r6dementia r7dementia 
label define dementia 1 "痴呆" 2 "认知缺陷" 3 "正常"
label values r3dementia r4dementia r5dementia r6dementia r7dementia  dementia
 
reshape long h@child h@coresd h@fcamt h@fcany h@fpamt h@fpany h@hhres h@tcamt h@tcany ///
h@tpamt h@tpany hh@hhidc hh@cperc hh@ctot inw@ r@agey r@arthre r@atotb ///
r@bathb r@bedb_k r@bmi r@bmicat r@brushb r@cancre r@catrcte r@cesd10a /// 
r@dadliv r@diabe r@dressb r@drink r@drinkev r@drinkn_k r@drinkx r@dsighta /// 
r@eatb r@fall r@fallinj r@fallnum r@glaucoma r@gooutb r@gripast r@gripcomp /// 
r@gripsum r@groomb r@hearaid r@hearinga r@hearlmt r@hearte r@height /// 
r@hibpe r@higovt_k r@hipe_k r@hipriv r@housewkb r@injlmt r@itearn  ///
r@itot r@itothhinc r@iwm r@iwstat r@iwy r@laundryb r@lbrf_k r@lgrip  ///
r@lgrip1 r@lgrip2 r@livere r@lunge r@mealsb r@medsb r@metrop_k  ///
r@momliv r@moneyb r@mstath r@nsighta r@obese r@paina r@painfr  ///
r@painhlv r@phoneb r@psyche r@quitsmok r@region_k r@relgwk r@relig_k /// 
r@rgrip r@rgrip1 r@rgrip2 r@rural r@rxarthr r@rxcancr r@rxdiab r@rxheart /// 
r@rxhibp r@rxliver r@rxlung r@rxpsych r@rxstrok r@shlt r@shlta r@shopb /// 
r@sighta r@sightlmt r@slfemp r@smokef r@smoken r@smokev r@socrelg_k /// 
r@socwk r@stroke r@strtsmok r@toiltb r@transb r@urinaf r@urinai /// 
r@urinb r@urinpad r@vigact r@vigactf_k r@weight r@work r@catrct /// 
r@dentim r@dentst r@doctim r@doctor r@drugs r@hcfcl2y r@hcfnit2y /// 
r@hcftim2y r@hctim r@homcar r@ncatrct r@oopden r@oopdoc r@oopdrug /// 
r@oophmcr r@oophos r@oopmd r@ooptrdmd r@trdmdtim2y r@trdmed2y r@cesd10b /// 
r@digeste r@hiltca_k r@hiltc_k r@rxdigest r@act1 r@act2 r@act3 r@act4 ///  
r@act5 r@act6 r@act7 r@freq_1 r@freq_2 r@freq_3 r@freq_4 r@freq_5 r@freq_6 ///  
r@freq_7 r@vigact_minute r@pain_1 r@pain_2 r@pain_3 r@pain_4 r@pain_5 ///  
r@pain_6 r@pain_7 r@pain_8 r@pain_9 r@pain_10 r@pain_11 r@pain_12 r@pain_13 ///  
r@painlv_1 r@painlv_2 r@painlv_3 r@painlv_4 r@painlv_5 r@painlv_6 r@painlv_7 ///  
r@painlv_8 r@painlv_9 r@painlv_10 r@painlv_11 r@painlv_12 r@painlv_13 r@dw ///  
r@dat r@ssn r@place r@cgdaddr r@imrc3 r@ser7 r@dlrc3 r@tr6 r@object1 r@object2 /// 
r@rpsnt  r@execu r@task r@write r@draw r@cog_total r@dementia r@wealth r@atotf, i(pid) j(wave) 

rename (pid wave hhhhidc inw riwstat riwm riwy rabyear rabmonth radyear radmonth ///
ragey ragender raeduc_k raeducl rmstath rregion_k rrural rmetrop_k rrelig_k rshlt /// 
rshlta rdressb rbathb reatb rtoiltb rbedb_k rbrushb rurinb rmealsb rshopb rmedsb /// 
rmoneyb rphoneb rtransb rgooutb rlaundryb rhousewkb rgroomb rhibpe rdiabe rcancre /// 
rlunge rhearte rstroke rpsyche rarthre rlivere rdigeste radiaghibp radiagdiab /// 
radiagcancr radiaglung radiagheart radiagstrok radiagpsych radiagarthr radiagliver /// 
radiagdigest rrxhibp rrxdiab rrxcancr rrxlung rrxheart rrxstrok rrxpsych rrxarthr /// 
rrxliver rrxdigest rbmi rheight rweight rbmicat robese rsighta rdsighta rnsighta /// 
rcatrcte rcatrct rncatrct rglaucoma rsightlmt rhearinga rhearaid rhearlmt rfall /// 
rfallnum rfallinj rhipe_k rinjlmt rurinai rurinaf rurinpad rpainfr rpainhlv rpaina  ///
rvigact rvigactf_k rdrinkev rdrink rdrinkx rdrinkn_k rsmokev rsmoken rsmokef  ///
rstrtsmok rquitsmok rhcfcl2y rhcftim2y rhcfnit2y rdoctor rdoctim rtrdmed2y  ///
rtrdmdtim2y rhomcar rhctim rdentst rdentim rdrugs roophos roopden rooptrdmd  ///
roopdoc roophmcr roopdrug roopmd rhigovt_k rhipriv rhiltca_k rhiltc_k ratotb  ///
ritearn ritot ritothhinc hhctot hhcperc hhhres hchild rmomliv rdadliv ramomeducl /// 
radadeducl hcoresd rsocwk rsocrelg_k rrelgwk htcany htcamt hfcany hfcamt htpany /// 
htpamt hfpany hfpamt rwork rslfemp rlbrf_k rlgrip1 rlgrip2 rrgrip1 rrgrip2 rlgrip /// 
rrgrip rgripsum rgripcomp rgripast rcesd10b rcesd10a ract1 ract2 ract3 ract4 ///  
ract5 ract6 ract7 rfreq_1 rfreq_2 rfreq_3 rfreq_4 rfreq_5 rfreq_6 ///  
rfreq_7 rvigact_minute rpain_1 rpain_2 rpain_3 rpain_4 rpain_5 ///  
rpain_6 rpain_7 rpain_8 rpain_9 rpain_10 rpain_11 rpain_12 rpain_13 ///  
rpainlv_1 rpainlv_2 rpainlv_3 rpainlv_4 rpainlv_5 rpainlv_6 rpainlv_7 ///  
rpainlv_8 rpainlv_9 rpainlv_10 rpainlv_11 rpainlv_12 rpainlv_13 rdw ///  
rdat rssn rplace rcgdaddr rimrc3 rser7 rdlrc3 rtr6 robject1 robject2 /// 
rrpsnt  rexecu rtask rwrite  rdraw rcog_total rdementia rwealth ratotf) ///
(pid wave hhidc inw iwstat iwm iwy rabyear rabmonth radyear radmonth ///
agey ragender raeduc_k raeducl mstath region_k rural metrop_k relig_k shlt /// 
shlta dressb bathb eatb toiltb bedb_k brushb urinb mealsb shopb medsb /// 
moneyb phoneb transb gooutb laundryb housewkb groomb hibpe diabe cancre /// 
lunge hearte stroke psyche arthre livere digeste radiaghibp radiagdiab /// 
radiagcancr radiaglung radiagheart radiagstrok radiagpsych radiagarthr radiagliver /// 
radiagdigest rxhibp rxdiab rxcancr rxlung rxheart rxstrok rxpsych rxarthr /// 
rxliver rxdigest bmi height weight bmicat obese sighta dsighta nsighta /// 
catrcte catrct ncatrct glaucoma sightlmt hearinga hearaid hearlmt fall /// 
fallnum fallinj hipe_k injlmt urinai urinaf urinpad painfr painhlv paina  ///
vigact vigactf_k drinkev drink drinkx drinkn_k smokev smoken smokef  ///
strtsmok quitsmok hcfcl2y hcftim2y hcfnit2y doctor doctim trdmed2y  ///
trdmdtim2y homcar hctim dentst dentim drugs oophos oopden ooptrdmd  ///
oopdoc oophmcr oopdrug oopmd higovt_k hipriv hiltca_k hiltc_k atotb  ///
itearn itot itothhinc ctot cperc hres child momliv dadliv ramomeducl /// 
radadeducl coresd socwk socrelg_k relgwk tcany tcamt fcany fcamt tpany /// 
tpamt fpany fpamt work slfemp lbrf_k lgrip1 lgrip2 rgrip1 rgrip2 lgrip /// 
rgrip gripsum gripcomp gripast cesd10b cesd10a act1 act2 act3 act4 ///  
act5 act6 act7 freq_1 freq_2 freq_3 freq_4 freq_5 freq_6 ///  
freq_7 vigact_minute pain_1 pain_2 pain_3 pain_4 pain_5 ///  
pain_6 pain_7 pain_8 pain_9 pain_10 pain_11 pain_12 pain_13 ///  
painlv_1 painlv_2 painlv_3 painlv_4 painlv_5 painlv_6 painlv_7 ///  
painlv_8 painlv_9 painlv_10 painlv_11 painlv_12 painlv_13 dw ///  
dat ssn place cgdaddr imrc3 ser7 dlrc3 tr6 object1 object2 /// 
rpsnt execu task write draw cog_total dementia wealth atotf) ///
 
*****只保留参与每一轮调查的样本
keep if inw==1   //只保留参与调查的个体
drop inw
keep if wave==3 | wave==4 | wave==5 | wave==6 | wave==7 | wave==8 

*****赋予变量标签  
label var child "健在子女数" 
label var radiagarthr "首诊高血压的年龄首诊高血压的年龄"
label var radiagcancr "首诊癌症的年龄"
label var radiagdiab "首诊糖尿病的年龄"
label var radiagdigest "首诊高血压的年龄"
label var radiagheart "首诊高血压的年龄"
label var radiaghibp "首诊高血压的年龄"
label var radiagliver "首诊高血压的年龄"
label var radiaglung "首诊肺病的年龄"
label var radiagpsych "首诊高血压的年龄首诊高血压的年龄首诊高血压的年龄"
label var radiagstrok "首诊高血压的年龄首诊高血压的年龄首诊高血压的年龄首诊高血压的年龄"
label var agey "年龄"
label var arthre "是否被医生诊断为风湿病"
label var atotb "总净财富"
label var bathb "ADL/洗澡需要帮助"
label var bedb_k "ADL/上下床需要帮助"
label var bmi "自报BMI"
label var bmicat "自报BMI分类"
label var brushb "ADL/刷牙需要帮助"
label var cancre "是否被医生诊断为癌症"
label var catrct "是否在过去两年内做过白内障手术"
label var catrcte "是否曾报告做过白内障手术"
label var cesd10a "CESD10(分数越高越抑郁)"
label var cesd10b "CESD10(分数越高越抑郁)"
label var coresd "是否与子女同住"
label var cperc "家庭年人均消费"
label var ctot "家庭年消费"
label var dadliv "父亲是否健在"
label var dentim "过去两年接受过牙科护理次数" 
label var dentst "过去两年是否接受过牙科护理"
label var diabe "是否被医生诊断为糖尿病"
label var digeste "是否被医生诊断为消化系统紊乱"
label var doctim "过去两年公共卫生诊所和医生就诊次数的总和"
label var doctor "过去两年是否去过公共卫生诊所" 
label var dressb "ADL/穿衣需要帮助"
label var drink "目前是否喝酒"
label var drinkev "是否曾经喝酒"
label var drinkn_k "单次饮用的最大数量" 
label var drugs "过去两年是否定期服用处方药" 
label var dsighta "远视视力"
label var eatb "ADL/吃饭需要帮助"
label var fall "过去2年内是否跌倒"
label var fallinj "在跌倒中受伤是否严重到需要医疗"
label var fallnum "过去两年中跌倒的次数"
label var fcamt  "过去一年中从子女、儿媳、孙辈那里获得的资金总额"
label var fcany "过去一年中是否从子女、儿媳和/或孙辈那里获得任何经济帮助"
label var fpamt "过去一年中从父母那里得到的资金总额"
label var fpany "过去一年中是否从其母亲、父亲、岳母或岳父那里获得任何财务转移" 
label var glaucoma "是否曾经接受过青光眼治疗"
label var gooutb "IADL/短距离外出"
label var gripast "在进行握力测试时是否得到了支持"
label var gripcomp "是否愿意并且能够完成握力测试"
label var gripsum "优势手握力"
label var groomb "IADL/梳妆"
label var hcfcl2y "过去两年是否在医院、疗养院、疗养院或其他长期卫生保健机构住院"
label var hcfnit2y "过去两年在医院、疗养院、疗养院或其他长期卫生保健机构住院的天数"
label var hcftim2y "过去两年在医院、疗养院、疗养院或其他长期卫生保健机构住院的次数" 
label var hctim "过去两年家庭护理服务次数"
label var hearaid "是否佩戴过助听器"
label var hearinga "自评听力"
label var hearlmt "听力是否限制了被告的日常活动"
label var hearte "是否被医生诊断为心脏病"
label var height "自报身高m"
label var hhidc "每期家庭标识符"
label var hres "家庭成员人数"
label var hibpe "是否被医生诊断为高血压"
label var higovt_k "参加的政府健康保险计划的类型"
label var hiltca_k "是否申请了长期护理保险"
label var hiltca_k "是否使用长期护理保险"
label var hipe_k "是否曾因跌倒而髋部骨折"
label var hipriv "是否有任何私人健康保险" 
label var homcar "过去两年是否接受过任何家庭护理服务"
label var housewkb "IADL/做家务"
label var injlmt "因跌倒而受伤或骨折是否限制了被调查者的日常活动"
label var itearn "过去一年的税后工资收入和兼职收入"
label var itot  "过去一年的总收入"
label var itothhinc "过去一年的家庭总收入(直接问题)"
label var iwm "受访月份"
label var iwstat "本期是否存活"
label var iwy "受访年份"
label var laundryb "IADL/洗衣服"
label var lbrf_k "劳动力状况"
label var lgrip "左手最大手部力量测量值"
label var lgrip1 "左手第一只手力量测量值" 
label var lgrip2 "左手第二只手力量测量值"
label var livere "是否被医生诊断为肝脏疾病"
label var lunge "是否被医生诊断为肺病"
label var mstath "婚姻状况"
label var mealsb "IADL/做饭需要帮助"
label var medsb "IADL/吃药"
label var metrop_k "大都市/城市/城镇"
label var momliv "母亲是否健在"
label var moneyb "IADL/管钱"
label var ncatrct "过去两年中接受过白内障手术的眼睛数量"
label var nsighta "近视视力"
label var obese "是否肥胖"
label var oopden "过去两年牙科护理自付支出" 
label var oopdoc "过去两年去看医生和急诊室的自费"
label var oopdrug "过去两年处方药费用的自付支出"
label var oophmcr "过去两年家庭护理的自费支出"
label var oophos "过去两年住院和医院护理人员的自付支出" 
label var oopmd "自付支出的总和"
label var ooptrdmd "过去两年传统医学自费支出" 
label var paina "疼痛是否干扰了正常的活动"
label var painfr "当前是否经历疼痛"
label var painhlv "最高疼痛程度" 
label var phoneb "IADL/使用电话"
label var pid "唯一标识符"
label var psyche "是否被医生诊断为心理问题"
label var quitsmok "戒烟的年龄" 
label var rabmonth "出生月份"
label var rabyear "出生年份"
label var radadeducl "父亲的教育程度"
label var radmonth "死亡月份"
label var radyear "死亡年份"
label var raeduc_k "教育程度"
label var raeducl "统一可比的教育程度"
label var ragender "性别"
label var ramomeducl "母亲的教育程度"
label var region_k "居住地区"
label var relgwk "是否参加每周一次的教会或其他宗教活动"
label var relig_k "宗教信仰"
label var rgrip "右手的最大手部力量测量值"
label var rgrip1 "右手第一只手力量测量值" 
label var rgrip2 "右手第一只手力量测量值"
label var rural "城市/农村"
label var rxarthr "是否服用药物或正在接受关节炎或风湿病的治疗"
label var rxcancr "是否服用药物或正在接受癌症治疗"
label var rxdiab "是否服用药物或正在接受糖尿病治疗"
label var rxdigest "是否服用药物或正在接受消化系统疾病的治疗"
label var rxheart "是否服用药物或正在接受心脏问题的治疗"
label var rxhibp "是否服用药物或正在接受高血压治疗"
label var rxliver "是否服用药物或正在接受肝病治疗"
label var rxlung "是否服用药物或正在接受肺部疾病治疗"
label var rxpsych "是否服用药物或正在接受精神病学或心理治疗 "
label var rxstrok "是否服用药物或正在接受中风治疗"
label var shlt "自评健康(差/非常好)"
label var shlta "自评健康(非常差/很好)"
label var shopb "IADL/购物"
label var sighta "自评视力"
label var sightlmt "视力是否限制了应答者的日常活动"
label var slfemp "是否自雇"
label var smokef "每天抽多少支烟"
label var smoken "现在是否吸烟"
label var smokev "是否曾经抽过烟"
label var socrelg_k "参加教会或其他宗教活动的频率"
label var socwk "是否参加每周的社会活动"
label var stroke "是否被医生诊断为中风"
label var strtsmok "开始吸烟的年龄"
label var tcamt "过去一年中给子女、儿媳、孙辈的资金总额"
label var tcany "过去一年中是否给予子女、儿媳和/或孙辈任何经济帮助" 
label var toiltb "ADL/上厕所需要帮助"
label var tpamt "过去一年中向父母支付的资金总额"
label var tpany "过去一年中是否向其母亲、父亲、婆婆或公公进行过任何财务转移" 
label var transb "IADL/交通工具"
label var trdmdtim2y "过去两年看过传统医学的次数"
label var trdmed2y "过去两年是否看过传统医学"
label var urinaf "上个月经历尿失禁的天数"
label var urinai "过去12个月里是否有过尿失禁的经历"
label var urinb "ADL/大小便需要帮助"
label var urinpad "是否曾经使用过任何吸收性产品治疗尿失禁"
label var vigact "是否每周锻炼"
label var vigactf_k "每周锻炼多少次"
label var weight "自报体重kg"
label var work "目前是否在领薪工作"
label var drinkx "饮酒的频率"
label define wave_ 1 "第1轮" 2 "第2轮" 3 "第3轮" 4 "第4轮" 5 "第5轮" ///
 6 "第6轮" 7 "第7轮" 8 "第8轮" 9 "第9轮" 10 "第10轮"
label values wave wave_
label var wave "第几轮调查"
label var act1 "宗教团体"
label var act2 "社交俱乐部"
label var act3 "休闲/文化/体育相关团体"
label var act4 "校友会、家乡社区"
label var act5 "志愿者团体"
label var act6 "政党、非政府组织、利益团体"
label var act7 "其他活动"
label var freq_1 "宗教团体"
label var freq_2 "社交俱乐部"
label var freq_3 "休闲/文化/体育相关团体"
label var freq_4 "校友会、家乡社区"
label var freq_5 "志愿者团体"
label var freq_6 "政党、非政府组织、利益团体"
label var freq_7 "其他活动"
label var vigact_minute "每次身体活动的分钟"
label var pain_1 "头痛"
label var pain_2 "肩部疼痛"
label var pain_3 "手臂疼"
label var pain_4 "手腕疼"
label var pain_5 "手指疼"
label var pain_6 "胸痛"
label var pain_7 "胃痛"
label var pain_8 "背痛"
label var pain_9 "髋部疼痛"
label var pain_10 "腿部疼"
label var pain_11 "膝盖疼"
label var pain_12 "脚踝疼"
label var pain_13 "脚趾疼"
label var painlv_1 "头痛"
label var painlv_2 "肩部疼痛"
label var painlv_3 "手臂疼"
label var painlv_4 "手腕疼"
label var painlv_5 "手指疼"
label var painlv_6 "胸痛"
label var painlv_7 "胃痛"
label var painlv_8 "背痛"
label var painlv_9 "髋部疼痛"
label var painlv_10 "腿部疼"
label var painlv_11 "膝盖疼"
label var painlv_12 "脚踝疼"
label var painlv_13 "脚趾疼"
label var dw "认知/星期几"
label var dat "认知/年月日"
label var ssn "认知/季节"
label var place "认知/地点"
label var cgdaddr "认知/完整的地址"
label var imrc3 "认知/即时记忆"
label var ser7 "认知/注意力和计算力"
label var dlrc3 "认知/延迟记忆"
label var tr6 "认知/两次记忆"
label var object1 "认知/命名"
label var object2 "认知/命名"
label var rpsnt "认知/重复句子"
label var execu "认知/执行力"
label var task "认知/闭眼说话"
label var write "认知/写一个完整的句子"
label var draw "认知/绘图"
label var cog_total "总认知得分"
label var dementia "认知障碍"
label var atotf "非住房金融财富净值"
label var wealth "非住房金融财富净值(调至2010)"

*****final sort
sort pid

*****compress dataset
compress	

*****add label
label data "Shawn老师 @丁点帮你"

*****add notes
notes drop _dta
note: Shawn老师->微信公众账号@丁点帮你

save "$working_data/klosa.dta",replace

*****单独保存每一期数据
local num_waves = 8 // 设置波次总数，这里是5个波次

forvalues wave = 3/`num_waves' {
    use "$working_data/klosa.dta", clear
    keep if wave == `wave'
    save "$working_data/klosa_wave`wave'.dta", replace
}

