# Pooling of the country-specific estimates and country-level meta-regressions
# Reads results/estimates.csv, results/country_descriptors.csv, results/age_slope.csv (from models.do)
# and country_variables.csv; writes results/meta_*.csv.
# The reasons for the choices made here are set out in docs/analysis_decisions.md.

library(metafor)

res <- "results"
est <- read.csv(file.path(res, "estimates.csv"))
cty <- read.csv("country_variables.csv")
dsc <- read.csv(file.path(res, "country_descriptors.csv"))
slope <- read.csv(file.path(res, "age_slope.csv"))

outcomes <- c("cog", "dep", "mob", "srh", "ls")
studies <- c(charls = "China", elsa = "England", hrs = "United States", mhas = "Mexico", klosa = "South Korea")

# Random-effects model (REML) with the Knapp-Hartung adjustment, which widens the confidence interval to allow for
# the uncertainty in the between-country variance when the number of countries is small; the prediction interval
# shows the range of associations expected in a new country.
pool <- function(b, se) {
  ok <- !is.na(b) & !is.na(se) & se > 0
  f <- rma(yi = b[ok], sei = se[ok], method = "REML", test = "knha")
  p <- predict(f)
  data.frame(K = f$k, est = as.numeric(f$b), se = f$se, lb = f$ci.lb, ub = f$ci.ub, p = f$pval,
             I2 = f$I2, tau2 = f$tau2, pi_lb = p$pi.lb, pi_ub = p$pi.ub)
}
pool_kind <- function(kind, units = NULL, col = "b", secol = "se") {
  do.call(rbind, lapply(outcomes, function(y) {
    d <- est[est$kind == kind & est$outc == y, ]
    if (!is.null(units)) d <- d[d$unit %in% units, ]
    if (nrow(d) < 2) return(NULL)
    cbind(kind = kind, outc = y, pool(d[[col]], d[[secol]]))
  }))
}

# Pooled associations: multiple imputation (main) and complete case
units <- unique(est$unit[est$kind == "mi"])
main <- rbind(pool_kind("mi"), pool_kind("cc"))
write.csv(main, file.path(res, "meta_pooled.csv"), row.names = FALSE)

# Memory in years of age-related decline (five single-country studies). SHARE is left out of this conversion only:
# its within-person age slope is much smaller (about -0.016 SD a year), possibly because of wave spacing and
# practice effects.
mem <- main[main$kind == "mi" & main$outc == "cog", "est"]
slope5 <- slope[slope$study %in% names(studies), ]
write.csv(data.frame(study = slope5$study, slope = slope5$b, years = mem / abs(slope5$b)),
          file.path(res, "meta_years.csv"), row.names = FALSE)

# Leave one country out (memory)
loo <- do.call(rbind, lapply(units, function(u) {
  d <- est[est$kind == "mi" & est$outc == "cog" & est$unit != u, ]
  cbind(left_out = u, pool(d$b, d$se))
}))
write.csv(loo, file.path(res, "meta_leave_one_out.csv"), row.names = FALSE)

# Care intensity (complete case): low-to-moderate and intensive care against no care, and their difference
int <- rbind(pool_kind("int", col = "b", secol = "se"), pool_kind("int", col = "b2", secol = "se2"),
             pool_kind("int", col = "bd", secol = "sed"))
int$contrast <- rep(c("low_moderate", "intensive", "difference"), each = nrow(int) / 3)
write.csv(int, file.path(res, "meta_intensity.csv"), row.names = FALSE)

# Without the income covariate, with age squared, next-wave care status (study level)
rob <- rbind(pool_kind("noinc"), pool_kind("agesq"), pool_kind("placebo"))
write.csv(rob, file.path(res, "meta_robustness.csv"), row.names = FALSE)

# Women and men (study level) and the test of their difference
sx <- merge(pool_kind("women"), pool_kind("men"), by = "outc", suffixes = c("_w", "_m"))
# standard errors taken from the 95% confidence limits of the pooled estimates
se_w <- (sx$ub_w - sx$lb_w) / (2 * qnorm(0.975))
se_m <- (sx$ub_m - sx$lb_m) / (2 * qnorm(0.975))
sx$z <- (sx$est_w - sx$est_m) / sqrt(se_w^2 + se_m^2)
sx$p_diff <- 2 * pnorm(-abs(sx$z))
write.csv(sx, file.path(res, "meta_sex.csv"), row.names = FALSE)

# Without England and South Korea, whose care items are the narrowest (care in the last week; grandchildren under
# 10) and whose care prevalence is lowest; without the waves collected in 2020 (COVID-19 pandemic)
mi <- est[est$kind == "mi", ]
ex20 <- rbind(est[est$kind == "excl2020", ], mi[!mi$unit %in% est$unit[est$kind == "excl2020"], ])
ex20$kind <- "excl2020"
excl <- rbind(pool_kind("mi", units = setdiff(units, c("England", "South Korea"))),
              do.call(rbind, lapply(outcomes, function(y) {
                d <- ex20[ex20$outc == y, ]
                cbind(kind = "excl2020", outc = y, pool(d$b, d$se))
              })))
excl$sample <- c(rep("without England and South Korea", length(outcomes)), rep("without 2020 waves", length(outcomes)))
write.csv(excl, file.path(res, "meta_exclusions.csv"), row.names = FALSE)

# Country-level data
w <- reshape(mi[, c("unit", "outc", "b", "se")], idvar = "unit", timevar = "outc", direction = "wide")
d <- merge(merge(w, dsc[, c("unit", "careprev", "coresid3")], by = "unit"), cty, by.x = "unit", by.y = "country")
d$lgdp <- log(d$gdppc)
d$childcare10 <- d$childcare02 / 10
d$flfp10 <- d$flfp / 10
d$idv10 <- d$idv / 10
d$coresid10 <- d$coresid3 * 10
fit <- function(dat, y, mods) {
  dat <- dat[!is.na(dat[[paste0("b.", y)]]), ]
  dat <- dat[complete.cases(dat[, all.vars(mods), drop = FALSE]), ]
  rma(yi = dat[[paste0("b.", y)]], sei = dat[[paste0("se.", y)]], mods = mods, data = dat,
      method = "REML", test = "knha")
}
tidy <- function(f, y, model) {
  data.frame(model = model, outc = y, term = rownames(f$b), K = f$k, b = as.numeric(f$b), se = f$se,
             lb = f$ci.lb, ub = f$ci.ub, p = f$pval, F = f$QM, F_p = f$QMp, R2 = f$R2, I2_res = f$I2)
}

# Univariable meta-regressions: 12 country variables x 5 outcomes, Benjamini-Hochberg over the 60 tests
# (supplementary; the false discovery rate is controlled because many tests are run on 23-25 countries)
vars <- c("careprev", "coresid3", "lgdp", "childcare02", "flfp", "idv", "gini", "famspend", "le65f",
          "retagew", "pop65", "matemp")
grid <- do.call(rbind, lapply(outcomes, function(y) do.call(rbind, lapply(vars, function(v) {
  f <- fit(d, y, as.formula(paste("~", v)))
  data.frame(outc = y, variable = v, K = f$k, b = f$b[2], lb = f$ci.lb[2], ub = f$ci.ub[2], p = f$pval[2], R2 = f$R2)
}))))
grid$q <- p.adjust(grid$p, method = "BH")
write.csv(grid, file.path(res, "meta_univariable.csv"), row.names = FALSE)

# Permutation tests (2,000 permutations) for the two associations shown in Appendix Fig. A3
perm <- do.call(rbind, lapply(c("coresid3", "flfp"), function(v) {
  f <- fit(d, "mob", as.formula(paste("~", v)))
  set.seed(20261113)
  data.frame(outc = "mob", variable = v, p = f$pval[2], p_perm = permutest(f, iter = 2000, progbar = FALSE)$pval[2])
}))
write.csv(perm, file.path(res, "meta_permutation.csv"), row.names = FALSE)

# Joint model: formal childcare, female labour-force participation, individualism (per 10 points)
# One variable for each area of the cultural-contextual structures in the model of intergenerational solidarity:
# welfare state (childcare), labour market (women's employment) and norms (individualism, a proxy for family
# obligation norms, for which no measure covers all countries). Entered together, so that each is adjusted for the
# others; collinearity is checked with correlations and variance inflation factors below.
# China is not in these models because the OECD childcare figure does not exist for it (see below).
J <- ~ childcare10 + flfp10 + idv10
joint <- lapply(setNames(outcomes, outcomes), function(y) fit(d, y, J))
write.csv(do.call(rbind, lapply(outcomes, function(y) tidy(joint[[y]], y, "joint"))),
          file.path(res, "meta_joint.csv"), row.names = FALSE)

# Collinearity in the countries of the joint model
d24 <- d[complete.cases(d[, c("childcare02", "flfp", "idv")]), ]
write.csv(round(cor(d24[, c("childcare02", "flfp", "idv", "coresid3")]), 3), file.path(res, "meta_correlations.csv"))
write.csv(do.call(rbind, lapply(outcomes, function(y) {
  v <- vif(joint[[y]])$vif
  data.frame(outc = y, term = names(v), vif = sapply(v, function(z) z$vif))
})), file.path(res, "meta_vif.csv"), row.names = FALSE)

# China: national figures for formal childcare (children aged 0-2, 2021) and female labour-force participation (2018)
# China combines large households with high female labour-force participation, so its estimate can tell apart the
# household indicator and female labour-force participation, which are strongly correlated (r = -0.80) elsewhere.
# Its coefficients are predicted from models fitted to the other countries and compared with the estimate.
china <- c(childcare02 = 5.5, flfp = 68.8)
dc <- d[d$unit == "China", ]
pred <- function(f, nx, y) {
  p <- predict(f, newmods = nx)
  ob <- dc[[paste0("b.", y)]]
  se <- dc[[paste0("se.", y)]]
  # estimate minus prediction, allowing for the uncertainty of both and the residual heterogeneity
  z <- (ob - p$pred) / sqrt(se^2 + p$se^2 + f$tau2)
  data.frame(outc = y, predicted = p$pred, pi_lb = p$pi.lb, pi_ub = p$pi.ub,
             observed = ob, se_observed = se, p_diff = 2 * pnorm(-abs(z)))
}
chn <- rbind(
  cbind(model = "joint", do.call(rbind, lapply(outcomes, function(y)
    pred(joint[[y]], c(china["childcare02"] / 10, china["flfp"] / 10, dc$idv / 10), y)))),
  cbind(model = "household", do.call(rbind, lapply(c("mob", "dep", "srh", "ls"), function(y)
    pred(fit(d[d$unit != "China", ], y, ~ coresid3), dc$coresid3, y)))),
  cbind(model = "flfp", do.call(rbind, lapply(c("mob", "dep", "srh", "ls"), function(y)
    pred(fit(d[d$unit != "China", ], y, ~ flfp), china["flfp"], y)))))
write.csv(chn, file.path(res, "meta_china.csv"), row.names = FALSE)

d25 <- d
d25$childcare10[d25$unit == "China"] <- china["childcare02"] / 10
d25$flfp10[d25$unit == "China"] <- china["flfp"] / 10
withchina <- do.call(rbind, c(
  lapply(outcomes, function(y) tidy(fit(d25, y, J), y, "joint, with China")),
  lapply(c("mob", "dep", "srh", "ls"), function(y) tidy(fit(d25[d25$unit != "China", ], y, ~ flfp10 + coresid10), y,
                                                        "flfp + household, without China")),
  lapply(c("mob", "dep", "srh", "ls"), function(y) tidy(fit(d25, y, ~ flfp10 + coresid10), y,
                                                        "flfp + household, with China")),
  lapply(c("mob", "dep", "srh", "ls"), function(y) tidy(fit(d25[d25$unit != "China", ], y, update(J, ~ . + coresid10)), y,
                                                        "three variables + household, without China")),
  lapply(c("mob", "dep", "srh", "ls"), function(y) tidy(fit(d25, y, update(J, ~ . + coresid10)), y,
                                                        "three variables + household, with China"))))
write.csv(withchina, file.path(res, "meta_china_models.csv"), row.names = FALSE)

# Joint model without England and South Korea
dx <- d[!d$unit %in% c("England", "South Korea"), ]
write.csv(do.call(rbind, lapply(outcomes, function(y) tidy(fit(dx, y, J), y, "joint, without England and South Korea"))),
          file.path(res, "meta_joint_excl.csv"), row.names = FALSE)
