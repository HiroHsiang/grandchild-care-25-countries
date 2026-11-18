# Grandchild care and grandparents' health in 25 countries

Code for the paper *Grandchild care and the cognitive, mental, and physical health of grandparents in 25 countries: findings from six longitudinal panel studies*.

The analyses use six longitudinal panel studies of ageing: the China Health and Retirement Longitudinal Study (CHARLS), the English Longitudinal Study of Ageing (ELSA), the Health and Retirement Study (HRS), the Korean Longitudinal Study of Aging (KLoSA), the Mexican Health and Aging Study (MHAS) and the Survey of Health, Ageing and Retirement in Europe (SHARE). Within-person associations of grandchild care with memory, depressive symptoms, mobility limitations, life satisfaction and self-rated health are estimated by individual fixed-effects models in each of 25 countries, pooled by random-effects meta-analysis, and related to national context by meta-regression.

This repository contains **code only**. The data may not be redistributed.

## Files

| File | Content |
|---|---|
| `CHARLS.do`, `ELSA.do`, `HRS.do`, `KLoSA.do`, `MHAS.do`, `SHARE.do` | Build the analysis variables of each study (one row per person and interview wave) from the files listed under *Input files*. |
| `models.do` | Individual fixed-effects models by country: multiple imputation (main analysis) and complete-case estimates, care intensity, sensitivity analyses, stratification by sex, and descriptive statistics. |
| `meta.R` | Random-effects meta-analysis of the country-specific estimates and country-level meta-regressions. |
| `figures.R` | Figures 2 and 3 and Appendix Figures A1 to A3. |
| `country_variables.csv` | Country-level variables used in the meta-regressions (sources below). |
| [`docs/analysis_decisions.md`](docs/analysis_decisions.md) | The choices made in building the variables and fitting the models, and the reasons for them. |
| [`docs/data_corrections.md`](docs/data_corrections.md) | Errors found in the earlier data files when the code was prepared for release, their correction, and the effect on the results. |

## Data access

The data are available free of charge to registered users from each study and from the Gateway to Global Aging Data.

| Study | Source |
|---|---|
| CHARLS (China) | https://charls.charlsdata.com |
| ELSA (England) | https://www.elsa-project.ac.uk (via the UK Data Service) |
| HRS (USA) | https://hrsdata.isr.umich.edu |
| KLoSA (South Korea) | https://survey.keis.or.kr/eng/klosa/klosa01.jsp |
| MHAS (Mexico) | https://www.mhasweb.org |
| SHARE (Europe and Israel), release 9.0.0 | https://share-eric.eu |
| Harmonised files | Gateway to Global Aging Data, https://g2aging.org |

## Input files

Place the files of each study in a sub-folder of one data folder, with the file names under which the studies distribute them:

| Folder | Files |
|---|---|
| `CHARLS/` | `H_CHARLS_D_Data.dta` (Harmonized CHARLS, version D); `2013/`, `2015/`, `2018/Family_Transfer.dta`; `2020/Demographic_Background.dta`, `Health_Status_and_Functioning.dta`, `Individual_Income.dta`, `Work_Retirement.dta`, `Weights.dta`, `COVID_Module.dta` |
| `ELSA/` | `h_elsa_g3.dta` (Harmonized ELSA, version G.3); `wave_8_elsa_data_eul_v2.dta`; `wave_9_elsa_data_eul_v1.dta` |
| `HRS/` | `randhrs1992_2020v2.dta` (RAND HRS Longitudinal File 2020, version 2); `H_HRS_d.dta` (Harmonized HRS, version D); RAND HRS Fat Files `h06f4a.dta`, `h08f3a.dta`, `hd10f6a.dta`, `h12f3a.dta`, `h14f2b.dta`, `h16f2c.dta`, `h18f2b.dta`, `h20f1a.dta` |
| `KLoSA/` | `H_KLoSA_e2.dta` (Harmonized KLoSA, version E.2); `e_imp_w03.dta`, `e_imp_w04.dta`, `e_imp_w05.dta`, `e_imp_w05_new.dta`, `e_imp_w06.dta`, `e_imp_w07.dta` |
| `MHAS/` | `H_MHAS_c2.dta` (Harmonized MHAS, version C.2) |
| `SHARE/` | `H_SHARE_f2.dta` (Harmonized SHARE, version F.2); release 9.0.0 modules `sharew<w>_rel9-0-0_sp.dta` (waves 1, 2, 4–8) and `sharew<w>_rel9-0-0_ac.dta` (waves 2, 4–8) |

## Running the code

In Stata (StataNow 19.5 was used), set three folders and run the study files, then `models.do`:

```stata
global data "<data folder>"
global work "<folder for the derived files>"
global results "<repository folder>/results"
foreach s in CHARLS ELSA HRS KLoSA MHAS SHARE {
    do `s'.do
}
do models.do
```

`models.do` writes the imputed datasets (20 per country, seed 20260908) to the work folder and the estimates and descriptive statistics to the results folder. Multiple imputation takes several hours. Subsets can be run in separate Stata sessions by setting, for example, `global studies "elsa mhas"`, or `global studies "share"` with `global countries "Austria Belgium"`, before `do models.do`; each country's imputations are the same whichever subset it is run in.

Then, in R (version 4.6.1, with metafor 5.2.1, ggplot2 4.0.3, dplyr 1.2.1 and patchwork 1.3.2) and with the repository folder as working directory:

```r
source("meta.R")
source("figures.R")
```

`meta.R` writes the pooled estimates and meta-regressions to `results/meta_*.csv`; `figures.R` writes the figures to `figures/`.

## Country-level variables (`country_variables.csv`)

| Variable | Definition and source |
|---|---|
| `gdppc` | GDP per capita, PPP (constant 2021 international $); World Bank, World Development Indicators |
| `childcare02` | Enrolment rate in formal childcare, age 0–2 (%); OECD Family Database, PF3.2 |
| `flfp` | Female labour-force participation rate, age 15–64 (%); World Bank / ILO modelled estimates |
| `idv` | Individualism index (0–100); Hofstede Insights, national culture dimensions |
| `gini` | Gini index of disposable income; World Bank (Mexico: 2016) |
| `famspend` | Public spending on family benefits (% of GDP); OECD Social Expenditure Database |
| `le65f` | Life expectancy at age 65, women (years); OECD Health Statistics / WHO |
| `retagew` | Effective age of labour-market exit, women (years); OECD, Ageing and Employment Policies |
| `pop65` | Population aged 65 and over (% of total); World Bank, World Development Indicators |
| `matemp` | Employment rate of mothers with a child under 3 (%); OECD Family Database, LMF1.2 |

Values refer to the most recent year available within the survey period. For China, the formal childcare and female labour-force figures are national figures (2021 and 2018) set in `meta.R`. Two further country variables, the share of observations with grandchild care and the share of respondents in households of three or more persons, are computed from the study data in `models.do`.

## Licence

MIT (see `LICENSE`).

## Contact

Corresponding author: Yingyao Chen (yychen@shmu.edu.cn), School of Public Health, Fudan University, Shanghai, China. Questions about the code: Yuliang Xiang (ylxiang@fudan.edu.cn).
