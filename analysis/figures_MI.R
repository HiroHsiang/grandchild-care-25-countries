# =============================================================================
# Topic A — manuscript figures on the multiple-imputation (M=20) main analysis
#   fig1_memory_mi          25-country forest, memory (neutral single colour)
#   fig2_dep_mob_mi         shared-label two-outcome forest: depression | mobility
#                           (mobility panel colour = share of households 3+ persons;
#                            meta-regression q=0.041 after BH; depression panel neutral)
#   figS_bubbles_mobility   (a) mobility ~ household-size share (b) mobility ~ female LFP
#   figS_exposure_by_wave   grandchild-care share by wave, six cohorts
#   figS_flow               participant flow, six cohorts
# Reuses the forest machinery of figures_A.R (functions only; nothing re-drawn).
# Data: figures/plotdata_A_mi.csv (per-country MI estimates + CC + moderators)
# =============================================================================
suppressPackageStartupMessages({ library(metafor) })
src <- readLines("D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/figures_A.R")
cut_at <- grep("^# ---- Fig A1", src)[1]
eval(parse(text = src[1:(cut_at - 1)]))          # functions, palettes, regime map, d0 (old) loaded
TMP <- "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"

dm <- read.csv(file.path(BASE, "plotdata_A_mi.csv"), fileEncoding = "UTF-8")
ext2 <- read.csv(file.path(BASE, "moderators_external.csv"), fileEncoding = "UTF-8")
dm <- dm[, !(names(dm) %in% setdiff(names(ext2), "clab"))]      # avoid duplicate moderator cols
dm <- left_join(dm, ext2, by = "clab")
dm$regime <- factor(unname(reg_map[dm$clab]), levels = REG)
stopifnot(!any(is.na(dm$regime)))
CORLAB <- c("<10%", "10-15%", "15-25%", "25-35%", ">=35%")
CORBRK <- c(-Inf, 0.10, 0.15, 0.25, 0.35, Inf)
NEUTRAL <- "#5595BF"

pooled <- function(b, se) { f <- rma(yi = b, sei = se, method = "REML", test = "knha"); pr <- predict(f)
  list(est = as.numeric(f$b[1]), ci = c(f$ci.lb, f$ci.ub), pi = c(pr$pi.lb, pr$pi.ub), I2 = f$I2) }

# ---------- left panel with country + changers only (shared by two forests) ----------
panel_left2 <- function(L) {
  rows <- L$rows
  ggplot() + band_layer(L) +
    geom_text(data = L$hdr, aes(x = 0, y = y, label = toupper(regime)),
              hjust = 0, size = 1.85, fontface = "bold", colour = "grey35", family = "sans") +
    geom_text(data = rows, aes(x = 0.05, y = y, label = clab),
              hjust = 0, size = 2.4, colour = INK, family = "sans") +
    geom_text(data = rows, aes(x = 1.0, y = y, label = format(changers, big.mark = ",")),
              hjust = 1, size = 2.2, colour = INK2, family = "sans") +
    annotate("text", x = 0.05, y = 0.9, label = "Country", hjust = 0, size = 2.3, fontface = "bold", family = "sans") +
    annotate("text", x = 1.0, y = 0.9, label = "Changers", hjust = 1, size = 2.3, fontface = "bold", family = "sans") +
    annotate("text", x = 0.05, y = L$ypool, label = "Pooled estimate", hjust = 0,
             size = 2.45, fontface = "bold", colour = POOL, family = "sans") +
    coord_cartesian(xlim = c(0, 1.02), ylim = c(L$ymin, L$ymax + 1.0), clip = "off") + theme_base()
}
# forest panel with a panel letter / title and optional neutral fill
panel_forest2 <- function(L, xlim, xbreaks, xlab, P, title, cols) {
  p <- panel_forest(L, xlim, xbreaks, xlab, P$est, P$ci, P$pi)
  p <- p + scale_fill_manual(values = cols, drop = FALSE) +
    annotate("text", x = xlim[1], y = 0.9, label = title, hjust = 0, size = 2.5, fontface = "bold", family = "sans")
  suppressMessages(p)
}
# derive a second-outcome layout that keeps the row order/y of a reference layout
relay <- function(L, df, est, se) {
  r <- L$rows[, c("clab", "y", "regime", "changers")]
  r$est <- df[[est]][match(r$clab, df$clab)]; r$se <- df[[se]][match(r$clab, df$clab)]
  r <- r %>% filter(!is.na(est), !is.na(se)) %>% mutate(lo = est - 1.96 * se, hi = est + 1.96 * se, w = 1 / se^2)
  L2 <- L; L2$rows <- r; L2
}

# ================= Fig 1: memory (MI), neutral colour =================
d1 <- dm; d1$fbin <- factor("all", levels = "all")
P1 <- pooled(d1$bcog_mi, d1$secog_mi)
cat(sprintf("Fig1 memory MI: %.4f (%.4f, %.4f) PI (%.3f, %.3f) I2=%.1f\n", P1$est, P1$ci[1], P1$ci[2], P1$pi[1], P1$pi[2], P1$I2))
L1 <- lay(d1, "bcog_mi", "secog_mi")
p1 <- (panel_left(L1, "ncog_mi", "Obs.") |
       panel_forest(L1, c(-0.12, 0.12), c(-0.10, -0.05, 0, 0.05, 0.10),
                    "Within-person association of grandchild care with memory (s.d.)", P1$est, P1$ci, P1$pi) +
         scale_fill_manual(values = c(all = NEUTRAL)) |
       panel_right(L1, P1$est, P1$ci)) + plot_layout(widths = c(2.5, 3.5, 1.9))
p1 <- suppressMessages(p1)
ggsave(file.path(OUT, "fig1_memory_mi.pdf"), p1, width = 180, height = 170, units = "mm", device = cairo_pdf, bg = SURF)
ggsave(file.path(OUT, "fig1_memory_mi.png"), p1, width = 180, height = 170, units = "mm", dpi = 600, bg = SURF)

# ================= Fig 2: depression | mobility, shared labels =================
d2 <- dm; d2$fbin <- factor("all", levels = "all")
Pd <- pooled(d2$bdep_mi, d2$sedep_mi)
okm <- !is.na(d2$bmob_mi); Pm <- pooled(d2$bmob_mi[okm], d2$semob_mi[okm])
cat(sprintf("Fig2 dep MI: %.4f (%.4f, %.4f) PI (%.3f, %.3f) I2=%.1f | mob MI: %.4f (%.4f, %.4f) PI (%.3f, %.3f) I2=%.1f\n",
            Pd$est, Pd$ci[1], Pd$ci[2], Pd$pi[1], Pd$pi[2], Pd$I2, Pm$est, Pm$ci[1], Pm$ci[2], Pm$pi[1], Pm$pi[2], Pm$I2))
Ld <- lay(d2, "bdep_mi", "sedep_mi")
Lm <- relay(Ld, d2, "bmob_mi", "semob_mi")
Lm$rows$fbin <- cut(d2$coresid3[match(Lm$rows$clab, d2$clab)], breaks = CORBRK, labels = CORLAB, right = FALSE)
XL <- c(-0.20, 0.20); XB <- c(-0.20, -0.10, 0, 0.10, 0.20)
pf_d <- panel_forest2(Ld, XL, XB, "Depressive symptoms (s.d.)", Pd, "a  Depressive symptoms", c(all = NEUTRAL))
pf_m <- panel_forest2(Lm, XL, XB, "Mobility limitations (s.d.)", Pm, "b  Mobility limitations", setNames(BINCOL, CORLAB))
p2 <- (panel_left2(Ld) | pf_d | panel_right(Ld, Pd$est, Pd$ci) | pf_m | panel_right(Lm, Pm$est, Pm$ci)) +
  plot_layout(widths = c(2.35, 2.45, 1.5, 2.45, 1.5))
p2 <- p2 / legend_bins(CORLAB, "Panel b colour: adults 50+ living in households of 3 or more persons") +
  plot_layout(heights = c(1, 0.05))
ggsave(file.path(OUT, "fig2_dep_mob_mi.pdf"), p2, width = 180, height = 175, units = "mm", device = cairo_pdf, bg = SURF)
ggsave(file.path(OUT, "fig2_dep_mob_mi.png"), p2, width = 180, height = 175, units = "mm", dpi = 600, bg = SURF)

# ================= Fig S: two bubbles (mobility ~ household-size share; ~ female LFP) =================
bubble <- function(df, xvar, yvar, sevar, xlab, ylab, xfmt = identity, ylim = c(-0.09, 0.13), labs_show, letter) {
  df <- df %>% filter(!is.na(.data[[yvar]]), !is.na(.data[[sevar]]), !is.na(.data[[xvar]])) %>% mutate(w = 1 / .data[[sevar]]^2)
  f <- rma(yi = df[[yvar]], sei = df[[sevar]], mods = ~ df[[xvar]], method = "REML", test = "knha")
  cat(sprintf("  %s: slope=%.5f p=%.4f R2=%.1f K=%d\n", xvar, f$b[2], f$pval[2], f$R2, f$k))
  xs <- seq(min(df[[xvar]]), max(df[[xvar]]), length.out = 60)
  line <- data.frame(x = xs, y = f$b[1] + f$b[2] * xs)
  df$fbin <- cut(df$coresid3, breaks = CORBRK, labels = CORLAB, right = FALSE)
  cap <- df %>% filter(.data[[yvar]] > ylim[2])
  lab <- df %>% filter(clab %in% labs_show)
  p <- ggplot(df, aes(x = .data[[xvar]], y = .data[[yvar]])) +
    geom_hline(yintercept = 0, linetype = "22", linewidth = 0.3, colour = "grey60") +
    geom_line(data = line, aes(x = x, y = y), colour = "#123F63", linewidth = 0.65) +
    geom_point(data = filter(df, .data[[yvar]] <= ylim[2]), aes(size = w, fill = fbin), shape = 21, colour = "grey15", stroke = 0.4, alpha = 0.95) +
    scale_fill_manual(values = setNames(BINCOL, CORLAB), name = NULL, drop = FALSE) +
    geom_text(data = lab, aes(label = clab), size = 2.1, colour = "grey20", family = "sans", nudge_y = 0.012) +
    scale_size_continuous(range = c(1.4, 6.5), guide = "none") +
    scale_x_continuous(labels = xfmt) + coord_cartesian(ylim = ylim) +
    labs(x = xlab, y = ylab, title = sprintf("%s  slope = %+.3f per unit, %s, R² = %.0f%%", letter, f$b[2] * ifelse(xvar == "coresid3", 1, 10), ifelse(f$pval[2] < 0.001, "P < 0.001", sprintf("P = %.3f", f$pval[2])), f$R2)) +
    theme_classic(base_size = 7.5, base_family = "sans") +
    theme(axis.line = element_line(linewidth = 0.3), axis.ticks = element_line(linewidth = 0.3),
          axis.text = element_text(size = 7, colour = "black"), plot.title = element_text(size = 7.5, face = "bold"),
          legend.position = "none", plot.margin = margin(4, 8, 4, 4, "pt"))
  if (nrow(cap)) p <- p + annotate("text", x = cap[[xvar]], y = ylim[2] - 0.012, label = sprintf("%s (%.2f)", cap$clab, cap[[yvar]]), size = 2.0, colour = "grey35", family = "sans")
  p
}
cat("Fig S bubbles (MI):\n")
pb1 <- bubble(dm, "coresid3", "bmob_mi", "semob_mi", "Share of adults 50+ living in households of 3 or more persons",
              "Grandchild-care coefficient on mobility limitations", xfmt = function(x) paste0(round(100 * x), "%"),
              labs_show = c("Mexico", "China", "Poland", "Sweden", "Netherlands", "United States", "Czechia"), letter = "a")
pb2 <- bubble(dm, "flfp", "bmob_mi", "semob_mi", "Female labour-force participation rate, age 15-64 (%)",
              "Grandchild-care coefficient on mobility limitations",
              labs_show = c("Mexico", "Italy", "Sweden", "Netherlands", "United States", "Czechia"), letter = "b")
pb2 <- pb2 + labs(title = sub("per unit", "per 10 points", pb2$labels$title))
pb <- (pb1 | pb2) / legend_bins(CORLAB, "Colour: share of adults 50+ living in households of 3 or more persons") + plot_layout(heights = c(1, 0.08))
ggsave(file.path(OUT, "figS_bubbles_mobility_mi.pdf"), pb, width = 180, height = 88, units = "mm", device = cairo_pdf, bg = SURF)
ggsave(file.path(OUT, "figS_bubbles_mobility_mi.png"), pb, width = 180, height = 88, units = "mm", dpi = 600, bg = SURF)

# ================= Fig S: exposure share by wave =================
bw <- read.csv(file.path(TMP, "desc_bywave_all.csv"), fileEncoding = "UTF-8")
coh <- c("China", "England", "United States", "South Korea", "Mexico", "SHARE")
cohlab <- c(China = "CHARLS (China)", England = "ELSA (England)", `United States` = "HRS (United States)",
            `South Korea` = "KLoSA (South Korea)", Mexico = "MHAS (Mexico)", SHARE = "SHARE (Europe)")
bw <- bw %>% filter(unit %in% coh) %>% mutate(unit = factor(cohlab[unit], levels = cohlab))
COHCOL <- c("#C8102E", "#123F63", "#2A6A99", "#8FBEDA", "#E8A33D", "#5B8C5A"); names(COHCOL) <- cohlab
pe <- ggplot(bw, aes(year, 100 * care_share, colour = unit, group = unit)) +
  geom_line(linewidth = 0.6) + geom_point(size = 1.4) +
  scale_colour_manual(values = COHCOL, name = NULL) +
  scale_x_continuous(breaks = seq(2000, 2020, 4)) +
  labs(x = "Interview year", y = "Providing grandchild care, % of analytic observations") +
  theme_classic(base_size = 7.5, base_family = "sans") +
  theme(axis.line = element_line(linewidth = 0.3), axis.ticks = element_line(linewidth = 0.3),
        axis.text = element_text(size = 7, colour = "black"), legend.position = c(0.83, 0.55),
        legend.text = element_text(size = 6.5), legend.key.height = unit(8, "pt"), plot.margin = margin(4, 8, 4, 4, "pt"))
ggsave(file.path(OUT, "figS_exposure_by_wave.pdf"), pe, width = 120, height = 75, units = "mm", device = cairo_pdf, bg = SURF)
ggsave(file.path(OUT, "figS_exposure_by_wave.png"), pe, width = 120, height = 75, units = "mm", dpi = 600, bg = SURF)

# ================= Fig S: participant flow =================
fl <- read.csv(file.path(TMP, "desc_flow_all.csv"), fileEncoding = "UTF-8") %>% filter(unit %in% coh)
steps <- c("0_all", "1_age50plus", "2_has_grandchild", "4_analytic")
slab <- c("All observations in harmonized panel", "Aged 50-105 years", "Has at least one grandchild",
          "Grandchild-care status observed (analytic sample)")
fl <- fl %>% filter(step %in% steps) %>% mutate(unit = factor(cohlab[unit], levels = cohlab),
                                                 k = match(step, steps), lab = slab[k],
                                                 txt = sprintf("%s\n%s observations, %s persons", lab, format(n_obs, big.mark = ","), format(n_persons, big.mark = ",")))
pfl <- ggplot(fl) +
  geom_rect(aes(xmin = 0, xmax = 1, ymin = -k - 0.42, ymax = -k + 0.42), fill = "#F4F5F6", colour = "grey40", linewidth = 0.3) +
  geom_text(aes(x = 0.5, y = -k, label = txt), size = 2.0, family = "sans", lineheight = 0.95) +
  geom_segment(data = data.frame(k = 1:3), aes(x = 0.5, xend = 0.5, y = -k - 0.42, yend = -k - 0.58),
               arrow = arrow(length = unit(3, "pt"), type = "closed"), linewidth = 0.3, colour = "grey40") +
  facet_wrap(~unit, ncol = 3) + coord_cartesian(xlim = c(-0.02, 1.02), ylim = c(-4.5, -0.5)) + theme_void(base_size = 7.5) +
  theme(strip.text = element_text(size = 7.5, face = "bold", margin = margin(2, 0, 3, 0)), plot.margin = margin(4, 4, 4, 4, "pt"))
ggsave(file.path(OUT, "figS_flow.pdf"), pfl, width = 180, height = 105, units = "mm", device = cairo_pdf, bg = SURF)
ggsave(file.path(OUT, "figS_flow.png"), pfl, width = 180, height = 105, units = "mm", dpi = 600, bg = SURF)
cat("MI FIGURES DONE\n")
