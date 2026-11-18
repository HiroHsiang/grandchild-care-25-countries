# Data corrections

The analysis first submitted for peer review used study panel files assembled by an earlier data-preparation pipeline. To release the code, every analysis variable was rebuilt from the files distributed by the studies (the `<study>.do` scripts in this repository). The rebuilt variables were compared with the earlier files variable by variable and person-wave by person-wave. The comparison found the errors below. They were corrected, all 25 countries were re-estimated with the code in this repository, and all numbers in the revised paper and Appendix come from this re-analysis.

## Errors found and corrected

| Study | Error in the earlier files | Correction |
|---|---|---|
| ELSA | Self-rated health in waves 1, 2 and 4 was coded in the opposite direction to waves 5–9. | All waves coded 1 = poor … 5 = excellent (13,409 person-waves changed). |
| ELSA | Wave 2 count of chronic conditions omitted heart disease. | The same eight conditions counted in every wave (1,247 person-waves +1). |
| MHAS | Self-rated health was not reversed (higher = worse, opposite to the other studies). | Higher = better, as in the other studies. |
| MHAS | Heart problems were counted only in waves 4–5. | The same five conditions counted in every wave; heart problems left out because the 2012 questionnaire did not ask everyone about them. |
| MHAS | Age was missing in waves 1–2, and the analytic window (2012, 2015, 2018) followed only indirectly from this. | Age taken from the harmonised file; the three waves are selected explicitly in `models.do` (same sample). |
| HRS | Memory scores for 2018 were not included (RAND HRS stores web and telephone/face-to-face scores separately from 2018). | Both sources combined (11,541 person-waves added). |
| HRS | Don't-know and refused codes in care hours. | Set to missing. |
| KLoSA | Memory scores for the continuing panel in wave 5 (2014) were not merged (the continuing panel and the refresh sample are in separate files). | Both files read (4,956 person-waves added). |
| CHARLS | 2018 count of chronic conditions counted stroke twice. | Counted once (947 person-waves −1). |
| CHARLS | Care hours reported for the respondent's spouse were not attributed to the spouse; impossible numbers of weeks or hours were kept. | Hours attributed to the person they refer to; impossible values set to missing (intensive-care person-waves 7,218 → 12,165). |
| CHARLS | 2020 life satisfaction was taken from the item on satisfaction with children. | The life-satisfaction item is used (affects only the standardisation constants). |
| CHARLS | The complete-case estimates for memory, depressive symptoms and life satisfaction had been computed on an early imputed dataset. | True complete-case estimates. |

The SHARE data were not affected: the complete-case results for the 20 SHARE countries are identical to the earlier ones, and the multiple-imputation results differ by at most 0.006 SD because the imputations were redrawn.

## Effect on the main results

| Result | Before correction | After correction |
|---|---|---|
| Memory, pooled (SD, 95% CI) | 0.034 (0.027 to 0.040); I² = 0% | 0.030 (0.023 to 0.038); I² = 0% |
| Countries with a positive memory estimate | 24 of 25 | 24 of 25 |
| Memory, in years of age-related decline | 0.7 to 1.2 | 0.7 to 1.1 |
| Depressive symptoms, pooled | −0.007 (−0.025 to 0.010) | −0.008 (−0.025 to 0.010) |
| Mobility limitations, pooled | 0.002 (−0.012 to 0.017) | 0.002 (−0.012 to 0.016) |
| Life satisfaction, pooled | 0.021 (0.006 to 0.036) | 0.021 (0.006 to 0.036) |
| Self-rated health, pooled | 0.017 (0.006 to 0.029) | 0.020 (0.008 to 0.031) |
| Mobility limitations and households of three or more (univariable slope) | 0.111 (0.048 to 0.173) | 0.108 (0.046 to 0.170) |
| Mobility limitations and female labour-force participation (per 10 points, univariable) | −0.025 (−0.038 to −0.013) | −0.025 (−0.037 to −0.013) |

Estimates that changed in substance:

- South Korea, memory: −0.063 (−0.153 to 0.027) became −0.091 (−0.170 to −0.011), after the wave-5 memory scores were added.
- Self-rated health, difference between women and men: p = 0.20 became p = 0.049.
- Self-rated health, joint test of the three country variables: p = 0.030 (R² 54%) became p = 0.080 (R² 20%); the childcare coefficient was unchanged (0.010, 0.002 to 0.017).
- Study-level placebo estimates: three rather than four of 28 are significant.

## Reproducibility

The earlier imputations were drawn without a fixed sort seed and cannot be reproduced value for value. The code in this repository fixes both the random-number seed and the sort seed, so each country's imputed datasets depend only on the data and the code (checked by running the same country in different subsets).
