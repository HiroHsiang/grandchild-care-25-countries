# Grandchild care and grandparents' health in 25 countries

Analysis code for:

> Xiang Y.\*, Xu Y.\*, Chen Y. *Grandchild care and grandparents' cognitive, mental and physical health in 25 countries.* (Manuscript submitted to *Nature Communications*.) \*Equal contribution.

The study harmonizes six ageing cohorts (CHARLS, ELSA, HRS, KLoSA, MHAS and SHARE; 168,203 adults aged 50 years and older with grandchildren) and estimates within-person associations between grandchild care and memory, depressive symptoms, mobility limitations, life satisfaction and self-rated health. Country-specific individual fixed-effects estimates are pooled by random-effects meta-analysis (REML, Knapp–Hartung), with pre-specified country-level meta-regressions.

This repository contains **code only**. No individual-level data are included or may be redistributed under the cohorts' conditions of use.

## Data access

All data are available free of charge after registration with each study:

| Cohort | Source |
|---|---|
| CHARLS (China) | https://charls.charlsdata.com |
| ELSA (England) | https://www.elsa-project.ac.uk (via the UK Data Service) |
| HRS (United States) | https://hrsdata.isr.umich.edu |
| KLoSA (South Korea) | https://survey.keis.or.kr/eng/klosa/klosa01.jsp |
| MHAS (Mexico) | https://www.mhasweb.org |
| SHARE (Europe and Israel), release 9.0.0 | https://share-eric.eu |
| Harmonized files | Gateway to Global Aging Data, https://g2aging.org |

Country-level variables and their sources are listed in Supplementary Table 4 of the paper.

## Repository structure

```
data_preparation/   Stata scripts that build the cohort panel files (Working_data/*.dta)
  CHARLS/ ELSA/ HRS/ KLoSA/ MHAS/ SHARE/
analysis/           Stata and R scripts for all estimates and figures
```

## Software

- Stata 18 (built-in `xtreg`, `mi`, `meta`)
- R 4.6 with `ggplot2`, `dplyr`, `patchwork`, `ggtext` and `metafor` (figures)

## Paths

The scripts were run on the authors' local machine and contain absolute paths. Before running them, replace these paths with the locations of your own data folder and analysis folder:

- the data folder holds one sub-folder per cohort (`CHARLS_中国/`, `ELSA_英国/`, `HRS_美国/`, `KLoSA_韩国/`, `MHAS_墨西哥/`, `SHARE_欧洲/`), each with `Raw_data/`, `Working_data/` and `Dofiles/`;
- the analysis folder holds these scripts, plus `Temp/` for intermediate files and `figures/` for outputs.

Most scripts set these locations through the Stata globals `$D`, `$T` and `$F`. Comments in the scripts are partly in Chinese.

## Workflow

1. **Build cohort panels** (`data_preparation/<cohort>/`): run the wave scripts, then the merge script (`数据合并.do` or `no.*_数据合并*.do`). This produces one long-format panel per cohort in `Working_data/`.
2. **Extract exposure and intensity** (`analysis/`): `01_extract_gkcare.do`, `01_extract_exposure.do`, `09_extract_intensity.do`, `11_elsa_intensity.do`.
3. **Main analysis, multiple imputation (M = 20)**: `23_mice_all.do`, run once per cohort through `run_mi_<cohort>.do` (`global COH …; global M 20`).
4. **Complete-case estimates and robustness checks**:
   - `12_percountry_meta.do`: country-specific estimates and meta-analysis
   - `19_sex_stratified.do`: sex-stratified estimates
   - `20_intensity_meta.do`: care-intensity meta-analysis
   - `21_sensitivity_pack.do`: sensitivity analyses
   - `22_review_fixes.do`: age-squared term, placebo tests, model without income; run through `run_klosa_tr6.do` and with `global COH …` for the other cohorts
5. **Country-level analyses**: `13_make_plotdata.do`, `14_metareg_careprev.do`, `15_internal_moderators.do`, `17_metareg_full.do`.
6. **Descriptive statistics** (Table 1, participant flow, age slopes): `24_descriptives.do` through `run_desc_all.do`.
7. **Figures**: `figures_MI.R` (Figs. 1–2), `figures_S.R` and `figures_A.R` (supplementary and exploratory figures).

The remaining scripts record earlier stages of the analysis and are kept for transparency:

| Scripts | Stage |
|---|---|
| `02`–`05` | Single-cohort pilots |
| `06` | Addition of life satisfaction and self-rated health |
| `07`, `08` | Early selection and lag checks |
| `10` | Four-cohort intensity models |
| `16` | Arellano–Bond diagnostics, reported as not supporting the dynamic-panel specification |
| `18*` | CHARLS-only imputation pilot, superseded by `23` |

## Licence

MIT (see `LICENSE`).

## Contact

Corresponding author: Yingyao Chen (yychen@shmu.edu.cn), School of Public Health, Fudan University, Shanghai, China. Questions about the code: Yuliang Xiang (ylxiang@fudan.edu.cn).
