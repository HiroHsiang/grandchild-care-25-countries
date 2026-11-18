# Analysis decisions

This file records the choices made in building the variables and fitting the models, why they were made, and where each is implemented. Section and table numbers refer to the paper and its Appendix.

## 1. Data sources

| Choice | Reason | Where |
|---|---|---|
| Variables are taken from the harmonised files of the Gateway to Global Aging Data wherever possible (Harmonized CHARLS D, ELSA G.3, HRS D with the RAND HRS file, KLoSA E.2, MHAS C.2, SHARE F.2). | The harmonised files define the same items in the same way across studies, which is the basis for comparing countries. | `<study>.do` |
| Study files are used only where the harmonised files lack an item: CHARLS care hours (Family Transfer module) and the 2020 wave; ELSA care hours (waves 8 and 9); HRS care hours (RAND HRS Fat Files); KLoSA memory items (K-MMSE); SHARE life satisfaction (activities module) and frequency of care (social support module). | These items are needed for care intensity or for an outcome and are not harmonised. | `<study>.do` |
| Every variable is rebuilt from files that registered users can download, not from intermediate project files. | So that each variable can be reproduced from the distributed data. The rebuild was checked person-wave by person-wave against the files used earlier; the errors this found are listed in [data_corrections.md](data_corrections.md). | all |

## 2. Sample

| Choice | Reason | Where |
|---|---|---|
| Respondents aged 50 years and older with at least one grandchild, in waves in which their grandchild-care status was observed. | The question concerns grandparents; care status is needed in every wave that enters a within-person comparison. | `models.do`, `setup`, main loop |
| CHARLS: no count of grandchildren is used. Respondents without (young) grandchildren are coded `.g` on the care item and drop out with the restriction to observed care status. | The care item itself identifies respondents without grandchildren. | `models.do`, `setup`; `CHARLS.do` |
| Analytic waves: CHARLS 2013, 2015, 2018 (no care item in 2011; no care variable is built for 2020); ELSA waves 1–9; HRS waves 5–14 (2000–2018; the harmonised care item ends at wave 14); KLoSA waves 3–8; MHAS 2012, 2015, 2018; SHARE waves 1, 2 and 4–8 (no care item in wave 3, SHARELIFE). | Waves with the care item in the harmonised files (Appendix Tables A1 and A2). | `<study>.do`; `models.do` |
| SHARE is analysed by country. Countries with fewer than 1,500 observations with care status are not analysed (nine countries). | Each of the nine contributed a single wave of the care item (wave 8 in eight countries, wave 2 in Ireland), so nobody can be observed both with and without care. The analysis therefore covers 25 countries. | `models.do`, main loop |

## 3. Exposure

| Choice | Reason | Where |
|---|---|---|
| Binary indicator of grandchild care in the current wave, from each study's care item. | The common denominator across six differently worded items (Appendix Table A2). The items differ in reference period, level of reporting (household in CHARLS, HRS and MHAS; respondent elsewhere), grandchildren covered and hours counted. | `<study>.do` |
| No further harmonisation of the care items. | The differences cannot be removed after data collection. They are reported, and the analyses are repeated without England and South Korea, whose items are the narrowest (care in the last week; grandchildren under 10) and whose care prevalence is lowest. | `meta.R` |
| Care intensity: intensive = almost daily or 15 or more hours a week; otherwise low-to-moderate. | Follows Di Gessa, Glaser, and Tinker (2016). | `<study>.do`, `care3` |
| Study rules for intensity: CHARLS ≥ 780 hours in the past year, summed over children, own report preferred over the spouse's report; ELSA (waves 8–9 only) care in the last 12 months with ≥ 15 hours in an average week, from term-time, holiday, regular or irregular patterns; HRS ≥ 1,560 hours in two years; MHAS ≥ 780 hours a year (household); SHARE almost daily care of any grandchild; KLoSA has no hours item and is left out. | 780 hours a year and 1,560 hours in two years equal 15 hours a week. Impossible values (CHARLS weeks > 52 or hours a week > 168; HRS hours above the hours in two years) and don't-know or refused codes are set to missing. | `<study>.do` |

## 4. Outcomes

| Choice | Reason | Where |
|---|---|---|
| Memory: immediate plus delayed word recall (10-word lists in CHARLS, ELSA, HRS; 10- and 8-word lists in SHARE and MHAS; 3-word list in KLoSA). The KLoSA K-MMSE total is built as an alternative measure but not used in the main analysis. | Word recall is the memory measure available in all six studies. | `<study>.do` |
| HRS 2018 and 2020: recall is taken from the web score when the interview was by web and from the telephone/face-to-face score otherwise. | From 2018 RAND HRS stores recall separately by interview mode; each respondent has one of the two. | `HRS.do` |
| Depressive symptoms: CES-D (10 or 8 items) or EURO-D (SHARE). In KLoSA, the CES-D is harmonised for waves 3–4 only; later waves use a different response scale and are not used. | Comparability within study across waves. | `<study>.do` |
| Mobility limitations: number of difficulties with six tasks (getting up from a chair, climbing stairs, stooping, reaching, lifting, picking up a coin); missing unless all six are answered. KLoSA has no mobility items. | The same six tasks are asked in five studies; a partial count would not be comparable. | `models.do`, `setup` |
| Life satisfaction and self-rated health as additional outcomes; self-rated health and life satisfaction are reversed where needed so that higher is better. | Subjective health and well-being, linked to the expectations of the two role theories (Section 1.1). | `<study>.do` |
| All outcomes standardised within study (SHARE as a whole) to mean 0 and SD 1. | Coefficients become within-person differences in SD units and can be pooled across studies with different scales. | `models.do`, `setup` |

## 5. Covariates

| Choice | Reason | Where |
|---|---|---|
| Time-varying covariates: partnered, household size, in paid work, household income, home ownership, number of chronic conditions, ADL and IADL limitations, wave dummies. | The set used by Mak et al. (2023) for the same harmonised studies. In the model of intergenerational solidarity, work, partnership, health, income and home ownership are opportunity structures and household size a family structure. | `models.do`, `setup` |
| Income: inverse hyperbolic sine (log of income + 1 in CHARLS), deflated to 2010 prices in CHARLS. | Income is skewed and can be zero. | `<study>.do` |
| Home ownership is not used in HRS. | Not available in the files used. | `models.do`, `setup` |
| ADL and IADL are left out of the models for mobility limitations. | They measure physical function that overlaps with the outcome. | `models.do`, `$cvm` |
| Chronic conditions: the same conditions in every wave of a study. In MHAS heart problems are left out. | MHAS 2012 asks about heart problems only after a heart attack, so counting them would change the measure between waves. | `<study>.do` |
| Age, sex and education are not entered. | Linear change in age is absorbed by the individual and wave fixed effects (an age-squared term is added in a sensitivity analysis); sex and education do not change within a person. They are used for description and stratification. | `models.do` |

## 6. Model

| Choice | Reason | Where |
|---|---|---|
| Individual fixed-effects linear models within each country, with wave dummies and standard errors clustered by person. | Only changes in care status within a person identify the association, so characteristics that do not change (education, personality, long-standing health) cannot bias it. Factors that change together with care status are not accounted for. | `models.do`, `ccmodels`, `mimodels` |
| Exposure and outcome measured at the same wave. | The estimate does not then depend on the interval between waves, which differs between studies (Appendix Table A1). | `models.do` |
| Wave dummies. | They absorb changes common to all respondents of a country between waves, including period effects. | `models.do` |
| Only changers (respondents whose care status changed) contribute to the estimates; changers and non-changers are compared at their first analytic wave. | States the scope of inference (Appendix Table A8). | `models.do`, `changers1` |
| A dynamic-panel (Arellano–Bond) specification was examined at an earlier stage and not adopted. | Its diagnostics did not support the specification. | not in this release |

## 7. Missing data

| Choice | Reason | Where |
|---|---|---|
| Main analysis on multiply imputed data: chained equations, predictive mean matching (five nearest neighbours) for all variables, M = 20, combined by Rubin's rules. Complete-case estimates are reported alongside. | Income is missing for about 38% of observations in CHARLS, 33% in KLoSA and 10% in SHARE, so complete-case analysis would lose many observations. Predictive mean matching imputes observed values only, so counts and bounded scores stay within range. | `models.do`, `mimodels`, `ccmodels` |
| Imputation separately within each country; predictors are care status, age, wave and the fully observed covariates. | Each country's imputation model matches its own analysis model. | `models.do`, `mimodels` |
| Fixed random-number seed and sort seed (20260908). | Each country's imputations depend only on the data and the code, whichever subset of countries is run in a session. | `models.do`, `mimodels` |

## 8. Pooling across countries

| Choice | Reason | Where |
|---|---|---|
| Random-effects meta-analysis (REML) with the Knapp–Hartung adjustment; 95% CIs, I² and 95% prediction intervals. | Associations may differ between countries; the Knapp–Hartung adjustment allows for the uncertainty in the between-country variance when the number of countries is small; the prediction interval shows the range expected in a new country. | `meta.R`, `pool` |
| Memory expressed as years of age-related decline, using within-person age slopes from the five single-country studies; SHARE left out of this conversion only. | Aids interpretation. The SHARE age slope is much smaller (about −0.016 SD a year), possibly because of wave spacing and practice effects. | `models.do` (age slope); `meta.R` |
| Sex difference tested on the pooled estimates for women and men, with standard errors taken from their 95% confidence limits. | Pre-specified stratification. | `meta.R` |

## 9. National context

| Choice | Reason | Where |
|---|---|---|
| Three country variables entered together: formal childcare enrolment at age 0–2, female labour-force participation (age 15–64), Hofstede individualism index; per 10 points. | One variable for each area of the cultural–contextual structures in the model of intergenerational solidarity: welfare state, labour market, norms (Section 1.1, Hypothesis 3). Individualism is a proxy for family obligation norms, for which no measure covers all 25 countries. | `meta.R`, joint model |
| Collinearity assessed with pairwise correlations and variance inflation factors. | The three variables, and the household indicator, are correlated across countries. | `meta.R` |
| China is not in the joint models; its coefficients are predicted from models fitted to the other countries, using national figures, and compared with its estimates. | The OECD childcare figure does not exist for China. China combines large households with high female labour-force participation, so it is the one country that can tell apart the household indicator and female labour-force participation (correlated at −0.80 in the other countries). | `meta.R` |
| Twelve country variables in univariable meta-regressions (60 tests), with Benjamini–Hochberg control of the false discovery rate; permutation tests (2,000 permutations) for the two associations with q < 0.05. | Supplementary analyses. Many tests on 23–25 countries; permutation tests do not rely on normality of the slope estimates. | `meta.R` |
| Two of the twelve variables (share of observations with care; share of respondents in households of three or more) are computed from the study data; the others are national statistics (`country_variables.csv`). | — | `models.do`; `country_variables.csv` |

## 10. Sensitivity analyses

| Analysis | Question | Where |
|---|---|---|
| Next-wave care status as a placebo exposure. | Do healthier respondents start care? If so, future care would predict current outcomes. | `models.do`, `studymodels` |
| Age-squared term. | Does the association reflect non-linear ageing? | `models.do`, `ccmodels` |
| Without the income covariate. | Does the most often missing covariate drive the results? | `models.do`, `ccmodels` |
| Leave one country out (memory). | Does one country drive the pooled estimate? | `meta.R` |
| Complete-case against multiple imputation. | Does imputation drive the results? | `models.do`; `meta.R` |
| Without England and South Korea. | Do the two narrowest care measures drive the results or the heterogeneity? | `meta.R` |
| Without the waves collected in 2020 (KLoSA wave 8, last SHARE wave). | Parts of these waves were collected during the COVID-19 pandemic. | `models.do`, `mimodels`; `meta.R` |

## 11. Not used

| Choice | Reason |
|---|---|
| Survey weights. | The aim is within-study associations rather than population prevalence, as in earlier analyses of the harmonised studies (Gong et al., 2026; Mak et al., 2023). |
| Race and ethnicity. | Not recorded consistently across studies. |
