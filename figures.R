# Figures: country-specific estimates (Figs 2 and 3), participant flow (Fig. A1), grandchild care by wave
# (Fig. A2) and mobility limitations against two country characteristics (Fig. A3)
# Reads results/*.csv from models.do and country_variables.csv; writes PDF and PNG files to figures/.

library(ggplot2)
library(dplyr)
library(patchwork)
library(metafor)

res <- "results"
out <- "figures"
dir.create(out, showWarnings = FALSE)

est <- read.csv(file.path(res, "estimates.csv"))
t1 <- read.csv(file.path(res, "table1.csv"))
dsc <- read.csv(file.path(res, "country_descriptors.csv"))
cty <- read.csv("country_variables.csv")

mi <- est[est$kind == "mi", c("unit", "outc", "b", "se", "n")]
d <- reshape(mi, idvar = "unit", timevar = "outc", direction = "wide")
d <- merge(d, t1[t1$unit != "SHARE", c("unit", "changers")], by = "unit")
d <- merge(d, dsc[, c("unit", "coresid3")], by = "unit")
d <- merge(d, cty[, c("country", "flfp")], by.x = "unit", by.y = "country")
names(d)[names(d) == "unit"] <- "clab"

region <- c(Denmark = 1, Sweden = 1, Netherlands = 1, Switzerland = 1, France = 1, Belgium = 1, Germany = 1,
            Austria = 1, Luxembourg = 1, England = 2, `United States` = 2, Estonia = 3, Czechia = 3, Slovenia = 3,
            Poland = 3, Hungary = 3, Croatia = 3, Israel = 4, Spain = 4, Italy = 4, Greece = 4, Portugal = 4,
            China = 5, `South Korea` = 5, Mexico = 6)
REG <- c("Nordic & Continental Europe", "Anglophone", "Central & Eastern Europe", "Southern Europe & Israel",
         "East Asia", "Latin America")
d$regime <- factor(REG[region[d$clab]], levels = REG)

BINCOL <- c("#C9DEEC", "#8FBEDA", "#5595BF", "#2A6A99", "#123F63")
CORLAB <- c("<10%", "10-15%", "15-25%", "25-35%", ">=35%")
CORBRK <- c(-Inf, 0.10, 0.15, 0.25, 0.35, Inf)
NEUTRAL <- "#5595BF"
INK <- "grey15"; INK2 <- "grey45"; POOL <- "grey8"; SURF <- "#FCFCFB"
BAND <- c("#F4F5F6", "#FBFBFA")

save_fig <- function(p, file, w, h) {
  ggsave(file.path(out, paste0(file, ".pdf")), p, width = w, height = h, units = "mm", device = grDevices::pdf, bg = SURF)
  ggsave(file.path(out, paste0(file, ".png")), p, width = w, height = h, units = "mm", dpi = 600, bg = SURF)
}
theme_base <- function() {
  theme_void(base_size = 7.5, base_family = "sans") +
    theme(plot.margin = margin(2, 2, 2, 2, "pt"), legend.position = "none")
}
pooled <- function(b, se) {
  ok <- !is.na(b)
  f <- rma(yi = b[ok], sei = se[ok], method = "REML", test = "knha")
  p <- predict(f)
  list(est = as.numeric(f$b), ci = c(f$ci.lb, f$ci.ub), pi = c(p$pi.lb, p$pi.ub))
}

# Layout: countries grouped by region, sorted by estimate within region
lay <- function(df, b, se) {
  df$est <- df[[b]]; df$se <- df[[se]]
  df <- df %>% filter(!is.na(est)) %>% mutate(lo = est - 1.96 * se, hi = est + 1.96 * se, w = 1 / se^2)
  rows <- list(); hdrs <- list(); bands <- list(); y <- 0; k <- 0
  for (r in REG) {
    sub <- df %>% filter(regime == r) %>% arrange(desc(est))
    if (!nrow(sub)) next
    k <- k + 1; top <- y; y <- y - 1.25
    hdrs[[r]] <- data.frame(regime = r, y = y)
    sub$y <- y - seq_len(nrow(sub)); y <- min(sub$y)
    bands[[r]] <- data.frame(regime = r, ymin = y - 0.5, ymax = top - 0.1, fill = BAND[1 + (k %% 2)])
    y <- y - 0.55; rows[[r]] <- sub
  }
  list(rows = bind_rows(rows), hdr = bind_rows(hdrs), band = bind_rows(bands), ypool = y - 1.1, ymin = y - 2.0, ymax = 0.2)
}
# Second outcome in the row order of a first layout
relay <- function(L, df, b, se) {
  r <- L$rows[, c("clab", "y", "regime", "changers")]
  r$est <- df[[b]][match(r$clab, df$clab)]; r$se <- df[[se]][match(r$clab, df$clab)]
  L$rows <- r %>% filter(!is.na(est)) %>% mutate(lo = est - 1.96 * se, hi = est + 1.96 * se, w = 1 / se^2)
  L
}
band_layer <- function(L) {
  geom_rect(data = L$band, aes(xmin = -Inf, xmax = Inf, ymin = ymin, ymax = ymax), fill = L$band$fill, inherit.aes = FALSE)
}
panel_left <- function(L, nlab = NULL) {
  rows <- L$rows
  p <- ggplot() + band_layer(L) +
    geom_text(data = L$hdr, aes(x = 0, y = y, label = toupper(regime)), hjust = 0, size = 1.95,
              fontface = "bold", colour = "grey35", family = "sans") +
    geom_text(data = rows, aes(x = 0.05, y = y, label = clab), hjust = 0, size = 2.4, colour = INK, family = "sans") +
    geom_text(data = rows, aes(x = 1.0, y = y, label = format(changers, big.mark = ",")), hjust = 1, size = 2.2,
              colour = INK2, family = "sans") +
    annotate("text", x = 0.05, y = 0.9, label = "Country", hjust = 0, size = 2.3, fontface = "bold", family = "sans") +
    annotate("text", x = 1.0, y = 0.9, label = "Changers", hjust = 1, size = 2.3, fontface = "bold", family = "sans") +
    annotate("text", x = 0.05, y = L$ypool, label = "Pooled estimate", hjust = 0, size = 2.45, fontface = "bold",
             colour = POOL, family = "sans")
  if (!is.null(nlab)) {
    p <- p + geom_text(data = rows, aes(x = 0.66, y = y, label = format(nobs, big.mark = ",")), hjust = 1, size = 2.2,
                       colour = INK2, family = "sans") +
      annotate("text", x = 0.66, y = 0.9, label = nlab, hjust = 1, size = 2.3, fontface = "bold", family = "sans")
  }
  p + coord_cartesian(xlim = c(0, 1.02), ylim = c(L$ymin, L$ymax + 1.0), clip = "off") + theme_base()
}
panel_forest <- function(L, xlim, xbreaks, xlab, P, cols, title = NULL) {
  rows <- L$rows %>% mutate(lo_c = pmax(lo, xlim[1]), hi_c = pmin(hi, xlim[2]), t_lo = lo < xlim[1], t_hi = hi > xlim[2],
                            inr = est >= xlim[1] & est <= xlim[2])
  dia <- data.frame(x = c(P$ci[1], P$est, P$ci[2], P$est), y = L$ypool + c(0, 0.42, 0, -0.42))
  ar <- arrow(length = unit(1.5, "pt"), type = "closed")
  p <- ggplot() + band_layer(L) +
    geom_vline(xintercept = 0, linewidth = 0.32, colour = "grey55", linetype = "22") +
    geom_segment(data = rows, aes(x = lo_c, xend = hi_c, y = y, yend = y), linewidth = 0.34, colour = INK2, lineend = "round")
  if (any(rows$t_lo)) p <- p + geom_segment(data = filter(rows, t_lo), aes(x = xlim[1] + 0.025 * diff(xlim), xend = xlim[1],
                                            y = y, yend = y), linewidth = 0.34, colour = INK2, arrow = ar)
  if (any(rows$t_hi)) p <- p + geom_segment(data = filter(rows, t_hi), aes(x = xlim[2] - 0.025 * diff(xlim), xend = xlim[2],
                                            y = y, yend = y), linewidth = 0.34, colour = INK2, arrow = ar)
  p <- p + geom_point(data = filter(rows, inr), aes(x = est, y = y, size = w, fill = fbin), shape = 22, colour = "grey15",
                      stroke = 0.42) +
    scale_fill_manual(values = cols, drop = FALSE) + scale_size_continuous(range = c(1.8, 4.6))
  if (any(!rows$inr)) p <- p + geom_text(data = filter(rows, !inr), aes(x = ifelse(est > xlim[2], xlim[2] - 0.06 * diff(xlim),
                                         xlim[1] + 0.06 * diff(xlim)), y = y, label = sprintf("%.2f", est)),
                                         size = 1.95, colour = INK, vjust = -0.95, family = "sans")
  p <- p + annotate("segment", x = max(P$pi[1], xlim[1]), xend = min(P$pi[2], xlim[2]), y = L$ypool, yend = L$ypool,
                    linewidth = 1.0, colour = "grey72", lineend = "round") +
    geom_polygon(data = dia, aes(x = x, y = y), fill = POOL) +
    annotate("segment", x = xlim[1], xend = xlim[2], y = L$ymin + 0.75, yend = L$ymin + 0.75, linewidth = 0.32) +
    annotate("segment", x = xbreaks, xend = xbreaks, y = L$ymin + 0.75, yend = L$ymin + 0.62, linewidth = 0.32) +
    annotate("text", x = xbreaks, y = L$ymin + 0.30, label = sprintf("%g", xbreaks), size = 2.2, family = "sans") +
    annotate("text", x = mean(xlim), y = L$ymin - 0.45, label = xlab, size = 2.5, family = "sans") +
    coord_cartesian(xlim = xlim, ylim = c(L$ymin, L$ymax + 1.0), clip = "off") + theme_base()
  if (!is.null(title)) p <- p + annotate("text", x = xlim[1], y = 0.9, label = title, hjust = 0, size = 2.5, fontface = "bold",
                                         family = "sans")
  p
}
panel_right <- function(L, P) {
  rows <- L$rows %>% mutate(txt = sprintf("%.3f (%.3f, %.3f)", est, lo, hi))
  ggplot() + band_layer(L) +
    geom_text(data = rows, aes(x = 1, y = y, label = txt), hjust = 1, size = 2.2, colour = INK, family = "sans") +
    annotate("text", x = 1, y = 0.9, label = "Coefficient (95% CI)", hjust = 1, size = 2.3, fontface = "bold", family = "sans") +
    annotate("text", x = 1, y = L$ypool, label = sprintf("%.3f (%.3f, %.3f)", P$est, P$ci[1], P$ci[2]), hjust = 1, size = 2.3,
             fontface = "bold", colour = POOL, family = "sans") +
    coord_cartesian(xlim = c(0, 1), ylim = c(L$ymin, L$ymax + 1.0), clip = "off") + theme_base()
}
legend_bins <- function(title) {
  g <- data.frame(lab = factor(CORLAB, levels = CORLAB), x = seq(0.40, 0.86, by = 0.115))
  ggplot(g) +
    annotate("text", x = 0.38, y = 0, hjust = 1, size = 2.15, colour = "grey25", family = "sans", label = title) +
    geom_point(aes(x = x, y = 0, fill = lab), shape = 22, size = 3.2, colour = "grey15", stroke = 0.42) +
    geom_text(aes(x = x, y = -0.42, label = lab), size = 2.0, colour = "grey30", family = "sans") +
    scale_fill_manual(values = setNames(BINCOL, CORLAB)) +
    coord_cartesian(xlim = c(0, 1), ylim = c(-0.75, 0.5), clip = "off") + theme_base()
}

# Fig. 2: memory
d$fbin <- factor("all", levels = "all")
d$nobs <- d$n.cog
P <- pooled(d$b.cog, d$se.cog)
L <- lay(d, "b.cog", "se.cog")
p <- (panel_left(L, "Obs.") |
        panel_forest(L, c(-0.12, 0.12), c(-0.10, -0.05, 0, 0.05, 0.10),
                     "Within-person association of grandchild care with memory (s.d.)", P, c(all = NEUTRAL)) |
        panel_right(L, P)) + plot_layout(widths = c(2.5, 3.5, 1.9))
save_fig(p, "fig2_memory", 180, 170)

# Fig. 3: depressive symptoms and mobility limitations
Pd <- pooled(d$b.dep, d$se.dep)
Pm <- pooled(d$b.mob, d$se.mob)
Ld <- lay(d, "b.dep", "se.dep")
Lm <- relay(Ld, d, "b.mob", "se.mob")
Lm$rows$fbin <- cut(d$coresid3[match(Lm$rows$clab, d$clab)], breaks = CORBRK, labels = CORLAB, right = FALSE)
xl <- c(-0.20, 0.20); xb <- c(-0.20, -0.10, 0, 0.10, 0.20)
p <- (panel_left(Ld) |
        panel_forest(Ld, xl, xb, "Depressive symptoms (s.d.)", Pd, c(all = NEUTRAL), "a  Depressive symptoms") |
        panel_right(Ld, Pd) |
        panel_forest(Lm, xl, xb, "Mobility limitations (s.d.)", Pm, setNames(BINCOL, CORLAB), "b  Mobility limitations") |
        panel_right(Lm, Pm)) + plot_layout(widths = c(2.35, 2.45, 1.5, 2.45, 1.5))
p <- p / legend_bins("Panel b colour: adults 50+ living in households of 3 or more persons") + plot_layout(heights = c(1, 0.05))
save_fig(p, "fig3_depression_mobility", 180, 175)

# Fig. A3: mobility limitations against the household indicator and female labour-force participation
bubble <- function(xvar, xlab, labs_show, letter, per, xfmt = identity, ylim = c(-0.09, 0.13)) {
  df <- d %>% filter(!is.na(b.mob), !is.na(.data[[xvar]])) %>% mutate(w = 1 / se.mob^2)
  f <- rma(yi = df$b.mob, sei = df$se.mob, mods = ~ df[[xvar]], method = "REML", test = "knha")
  xs <- seq(min(df[[xvar]]), max(df[[xvar]]), length.out = 60)
  line <- data.frame(x = xs, y = f$b[1] + f$b[2] * xs)
  df$fbin <- cut(df$coresid3, breaks = CORBRK, labels = CORLAB, right = FALSE)
  cap <- df %>% filter(b.mob > ylim[2])
  ptxt <- ifelse(f$pval[2] < 0.001, "P < 0.001", sprintf("P = %.3f", f$pval[2]))
  p <- ggplot(df, aes(x = .data[[xvar]], y = b.mob)) +
    geom_hline(yintercept = 0, linetype = "22", linewidth = 0.3, colour = "grey60") +
    geom_line(data = line, aes(x = x, y = y), colour = "#123F63", linewidth = 0.65) +
    geom_point(data = filter(df, b.mob <= ylim[2]), aes(size = w, fill = fbin), shape = 21, colour = "grey15", stroke = 0.4,
               alpha = 0.95) +
    scale_fill_manual(values = setNames(BINCOL, CORLAB), drop = FALSE) +
    geom_text(data = filter(df, clab %in% labs_show), aes(label = clab), size = 2.1, colour = "grey20", family = "sans",
              nudge_y = 0.012) +
    scale_size_continuous(range = c(1.4, 6.5), guide = "none") +
    scale_x_continuous(labels = xfmt) + coord_cartesian(ylim = ylim) +
    labs(x = xlab, y = "Grandchild-care coefficient on mobility limitations",
         title = sprintf("%s  slope = %+.3f per %s, %s, R² = %.0f%%", letter, f$b[2] * ifelse(per == "unit", 1, 10), per, ptxt, f$R2)) +
    theme_classic(base_size = 7.5, base_family = "sans") +
    theme(axis.line = element_line(linewidth = 0.3), axis.ticks = element_line(linewidth = 0.3),
          axis.text = element_text(size = 7, colour = "black"), plot.title = element_text(size = 7.5, face = "bold"),
          legend.position = "none", plot.margin = margin(4, 8, 4, 4, "pt"))
  if (nrow(cap)) p <- p + annotate("text", x = cap[[xvar]], y = ylim[2] - 0.012, label = sprintf("%s (%.2f)", cap$clab, cap$b.mob),
                                   size = 2.0, colour = "grey35", family = "sans")
  p
}
pa <- bubble("coresid3", "Share of adults 50+ living in households of 3 or more persons",
             c("Mexico", "China", "Poland", "Sweden", "Netherlands", "United States", "Czechia"), "a", "unit",
             function(x) paste0(round(100 * x), "%"))
pb <- bubble("flfp", "Female labour-force participation rate, age 15-64 (%)",
             c("Mexico", "Italy", "Sweden", "Netherlands", "United States", "Czechia"), "b", "10 points")
p <- (pa | pb) / legend_bins("Colour: share of adults 50+ living in households of 3 or more persons") +
  plot_layout(heights = c(1, 0.08))
save_fig(p, "figA3_mobility_context", 180, 88)

# Fig. A2: share of analytic observations reporting grandchild care, by wave
bw <- read.csv(file.path(res, "bywave.csv"))
studylab <- c(charls = "CHARLS (China)", elsa = "ELSA (England)", hrs = "HRS (United States)", klosa = "KLoSA (South Korea)",
              mhas = "MHAS (Mexico)", share = "SHARE (Europe and Israel)")
bw <- bw[bw$study != "share" | bw$unit == "SHARE", ]
bw$study <- factor(studylab[bw$study], levels = studylab)
p <- ggplot(bw, aes(year_m, 100 * care, colour = study, group = study)) +
  geom_line(linewidth = 0.6) + geom_point(size = 1.4) +
  scale_colour_manual(values = setNames(c("#C8102E", "#123F63", "#2A6A99", "#8FBEDA", "#E8A33D", "#5B8C5A"), studylab), name = NULL) +
  scale_x_continuous(breaks = seq(2000, 2020, 4)) +
  labs(x = "Interview year", y = "Providing grandchild care, % of analytic observations") +
  theme_classic(base_size = 7.5, base_family = "sans") +
  theme(axis.line = element_line(linewidth = 0.3), axis.ticks = element_line(linewidth = 0.3),
        axis.text = element_text(size = 7, colour = "black"), legend.position = c(0.83, 0.55),
        legend.text = element_text(size = 6.5), legend.key.height = unit(8, "pt"), plot.margin = margin(4, 8, 4, 4, "pt"))
save_fig(p, "figA2_care_by_wave", 120, 75)

# Fig. A1: participant flow
fl <- read.csv(file.path(res, "flow.csv"))
steplab <- c(all = "All observations in harmonized panel",
             age50to105 = "Aged 50-105 years", grandchild = "Has at least one grandchild",
             care = "Grandchild-care status observed", analytic = "Grandchild-care status observed (analytic sample)")
fl$lab <- steplab[fl$step]
fl$lab[fl$study == "share" & fl$step == "analytic"] <- "In the 20 countries analysed (analytic sample)"
fl <- fl %>% group_by(study) %>% mutate(k = row_number()) %>% ungroup() %>%
  mutate(study = factor(studylab[study], levels = studylab[c("charls", "elsa", "hrs", "klosa", "mhas", "share")]),
         txt = sprintf("%s\n%s observations, %s persons", lab, format(obs, big.mark = ","), format(persons, big.mark = ",")))
arrows <- fl %>% group_by(study) %>% filter(k < max(k)) %>% ungroup()
p <- ggplot(fl) +
  geom_rect(aes(xmin = 0, xmax = 1, ymin = -k - 0.42, ymax = -k + 0.42), fill = "#F4F5F6", colour = "grey40", linewidth = 0.3) +
  geom_text(aes(x = 0.5, y = -k, label = txt), size = 2.0, family = "sans", lineheight = 0.95) +
  geom_segment(data = arrows, aes(x = 0.5, xend = 0.5, y = -k - 0.42, yend = -k - 0.58),
               arrow = arrow(length = unit(3, "pt"), type = "closed"), linewidth = 0.3, colour = "grey40") +
  facet_wrap(~study, ncol = 3) + coord_cartesian(xlim = c(-0.02, 1.02), ylim = c(-5.5, -0.5)) + theme_void(base_size = 7.5) +
  theme(strip.text = element_text(size = 7.5, face = "bold", margin = margin(2, 0, 3, 0)), plot.margin = margin(4, 4, 4, 4, "pt"))
save_fig(p, "figA1_flow", 180, 126)
