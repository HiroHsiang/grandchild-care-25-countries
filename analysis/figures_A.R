# =============================================================================
# Topic A figures — table-style forest plots (style inherited from mother
# project figures_final.R): 3-panel layout, regime bands, sequential-blue bins
# keyed to grandchild-care prevalence, weight-sized square markers, pooled
# diamond + 95% prediction interval bar. 180 mm two-column, PDF + 600dpi PNG.
#   figA1  cognition (25 countries)  — headline, near-homogeneous benefit
#   figA2  depression (25 countries) — pooled null, I2 = 60%
# =============================================================================
suppressPackageStartupMessages({
  library(ggplot2); library(dplyr); library(patchwork); library(ggtext)
})

BASE <- "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/figures"
OUT  <- file.path(BASE, "final")
dir.create(OUT, showWarnings = FALSE)
d0 <- read.csv(file.path(BASE, "plotdata_A.csv"), fileEncoding = "UTF-8")
ext <- read.csv(file.path(BASE, "moderators_external.csv"), fileEncoding = "UTF-8")
d0 <- left_join(d0, ext, by = "clab")

reg_map <- c(
  Denmark = "Nordic & Continental Europe", Sweden = "Nordic & Continental Europe",
  Netherlands = "Nordic & Continental Europe", Switzerland = "Nordic & Continental Europe",
  France = "Nordic & Continental Europe", Belgium = "Nordic & Continental Europe",
  Germany = "Nordic & Continental Europe", Austria = "Nordic & Continental Europe",
  Luxembourg = "Nordic & Continental Europe",
  England = "Anglophone", `United States` = "Anglophone",
  Estonia = "Central & Eastern Europe", Czechia = "Central & Eastern Europe",
  Slovenia = "Central & Eastern Europe", Poland = "Central & Eastern Europe",
  Hungary = "Central & Eastern Europe", Croatia = "Central & Eastern Europe",
  Israel = "Southern Europe & Israel", Spain = "Southern Europe & Israel",
  Italy = "Southern Europe & Israel", Greece = "Southern Europe & Israel",
  Portugal = "Southern Europe & Israel",
  China = "East Asia", `South Korea` = "East Asia", Mexico = "Latin America")
REG <- c("Nordic & Continental Europe", "Anglophone", "Central & Eastern Europe",
         "Southern Europe & Israel", "East Asia", "Latin America")

BINCOL <- c("#C9DEEC", "#8FBEDA", "#5595BF", "#2A6A99", "#123F63")
# 色键(meta-regression 定):心理结局=Hofstede 个人主义(抑郁 R2=34.8%, p=.013)
BINLAB <- c("<30", "30-50", "50-65", "65-80", ">=80")
BINBRK <- c(-Inf, 30, 50, 65, 80, Inf)

INK <- "grey15"; INK2 <- "grey45"; POOL <- "grey8"; SURF <- "#FCFCFB"
BAND <- c("#F4F5F6", "#FBFBFA")

d0$regime <- factor(unname(reg_map[d0$clab]), levels = REG)
d0$fbin <- cut(d0$idv, breaks = BINBRK, labels = BINLAB, right = FALSE)
stopifnot(!any(is.na(d0$regime)), !any(is.na(d0$fbin)))

theme_base <- function(base = 7.5) {
  theme_void(base_size = base, base_family = "sans") +
    theme(plot.margin = margin(2, 2, 2, 2, "pt"), legend.position = "none")
}

lay <- function(df, est, se) {
  df$est <- df[[est]]; df$se <- df[[se]]
  df <- df %>% filter(!is.na(est), !is.na(se)) %>%
    mutate(lo = est - 1.96 * se, hi = est + 1.96 * se, w = 1 / se^2)
  rows <- list(); hdrs <- list(); bands <- list(); y <- 0; k <- 0
  for (r in REG) {
    sub <- df %>% filter(regime == r) %>% arrange(desc(est))
    if (!nrow(sub)) next
    k <- k + 1; top <- y; y <- y - 1.25
    hdrs[[r]] <- data.frame(regime = r, y = y)
    sub$y <- y - seq_len(nrow(sub)); y <- min(sub$y)
    bands[[r]] <- data.frame(regime = r, ymin = y - 0.5, ymax = top - 0.1,
                             fill = BAND[1 + (k %% 2)])
    y <- y - 0.55; rows[[r]] <- sub
  }
  list(rows = bind_rows(rows), hdr = bind_rows(hdrs), band = bind_rows(bands),
       ypool = y - 1.1, ymin = y - 2.0, ymax = 0.2)
}

band_layer <- function(L)
  geom_rect(data = L$band, aes(xmin = -Inf, xmax = Inf, ymin = ymin, ymax = ymax),
            fill = L$band$fill, inherit.aes = FALSE)

panel_left <- function(L, ncol = "ncog", nlab = "Obs.") {
  rows <- L$rows
  rows$nshow <- rows[[ncol]]
  ggplot() + band_layer(L) +
    geom_text(data = L$hdr, aes(x = 0, y = y, label = toupper(regime)),
              hjust = 0, size = 2.05, fontface = "bold", colour = "grey35", family = "sans") +
    geom_text(data = rows, aes(x = 0.05, y = y, label = clab),
              hjust = 0, size = 2.4, colour = INK, family = "sans") +
    geom_text(data = rows, aes(x = 0.66, y = y, label = format(nshow, big.mark = ",")),
              hjust = 1, size = 2.2, colour = INK2, family = "sans") +
    geom_text(data = rows, aes(x = 1.0, y = y, label = format(changers, big.mark = ",")),
              hjust = 1, size = 2.2, colour = INK2, family = "sans") +
    annotate("text", x = 0.05, y = 0.9, label = "Country", hjust = 0, size = 2.3,
             fontface = "bold", family = "sans") +
    annotate("text", x = 0.66, y = 0.9, label = nlab, hjust = 1, size = 2.3,
             fontface = "bold", family = "sans") +
    annotate("text", x = 1.0, y = 0.9, label = "Changers", hjust = 1, size = 2.3,
             fontface = "bold", family = "sans") +
    annotate("text", x = 0.05, y = L$ypool, label = "Pooled estimate", hjust = 0,
             size = 2.45, fontface = "bold", colour = POOL, family = "sans") +
    coord_cartesian(xlim = c(0, 1.02), ylim = c(L$ymin, L$ymax + 1.0), clip = "off") +
    theme_base()
}

panel_forest <- function(L, xlim, xbreaks, xlab, pooled, ci, pi) {
  rows <- L$rows %>%
    mutate(lo_c = pmax(lo, xlim[1]), hi_c = pmin(hi, xlim[2]),
           t_lo = lo < xlim[1], t_hi = hi > xlim[2],
           inr = est >= xlim[1] & est <= xlim[2])
  dia <- data.frame(x = c(ci[1], pooled, ci[2], pooled),
                    y = L$ypool + c(0, 0.42, 0, -0.42))
  ar <- arrow(length = unit(1.5, "pt"), type = "closed")
  p <- ggplot() + band_layer(L) +
    geom_vline(xintercept = 0, linewidth = 0.32, colour = "grey55", linetype = "22") +
    geom_segment(data = rows, aes(x = lo_c, xend = hi_c, y = y, yend = y),
                 linewidth = 0.34, colour = INK2, lineend = "round")
  if (any(rows$t_lo)) p <- p + geom_segment(data = filter(rows, t_lo),
      aes(x = xlim[1] + 0.025 * diff(xlim), xend = xlim[1], y = y, yend = y),
      linewidth = 0.34, colour = INK2, arrow = ar)
  if (any(rows$t_hi)) p <- p + geom_segment(data = filter(rows, t_hi),
      aes(x = xlim[2] - 0.025 * diff(xlim), xend = xlim[2], y = y, yend = y),
      linewidth = 0.34, colour = INK2, arrow = ar)
  p <- p + geom_point(data = filter(rows, inr),
                      aes(x = est, y = y, size = w, fill = fbin),
                      shape = 22, colour = "grey15", stroke = 0.42) +
    scale_fill_manual(values = setNames(BINCOL, levels(L$rows$fbin)), drop = FALSE)
  if (any(!rows$inr)) p <- p + geom_text(data = filter(rows, !inr),
      aes(x = ifelse(est > xlim[2], xlim[2] - 0.06 * diff(xlim), xlim[1] + 0.06 * diff(xlim)),
          y = y, label = sprintf("%.2f", est)),
      size = 1.95, colour = INK, vjust = -0.95, family = "sans")
  p + scale_size_continuous(range = c(1.8, 4.6)) +
    annotate("segment", x = max(pi[1], xlim[1]), xend = min(pi[2], xlim[2]),
             y = L$ypool, yend = L$ypool, linewidth = 1.0, colour = "grey72",
             lineend = "round") +
    geom_polygon(data = dia, aes(x = x, y = y), fill = POOL) +
    annotate("segment", x = xlim[1], xend = xlim[2], y = L$ymin + 0.75,
             yend = L$ymin + 0.75, linewidth = 0.32, colour = "black") +
    annotate("segment", x = xbreaks, xend = xbreaks, y = L$ymin + 0.75,
             yend = L$ymin + 0.62, linewidth = 0.32, colour = "black") +
    annotate("text", x = xbreaks, y = L$ymin + 0.30, label = sprintf("%g", xbreaks),
             size = 2.2, colour = "black", family = "sans") +
    annotate("text", x = mean(xlim), y = L$ymin - 0.45, label = xlab,
             size = 2.5, colour = "black", family = "sans") +
    coord_cartesian(xlim = xlim, ylim = c(L$ymin, L$ymax + 1.0), clip = "off") +
    theme_base()
}

panel_right <- function(L, pooled, ci, digits = 3) {
  fmt <- paste0("%.", digits, "f")
  rows <- L$rows %>%
    mutate(txt = sprintf(paste0(fmt, " (", fmt, ", ", fmt, ")"), est, lo, hi))
  ggplot() + band_layer(L) +
    geom_text(data = rows, aes(x = 1, y = y, label = txt), hjust = 1,
              size = 2.2, colour = INK, family = "sans") +
    annotate("text", x = 1, y = 0.9, label = "Coefficient (95% CI)", hjust = 1,
             size = 2.3, fontface = "bold", family = "sans") +
    annotate("text", x = 1, y = L$ypool,
             label = sprintf(paste0(fmt, " (", fmt, ", ", fmt, ")"), pooled, ci[1], ci[2]),
             hjust = 1, size = 2.3, fontface = "bold", colour = POOL, family = "sans") +
    coord_cartesian(xlim = c(0, 1), ylim = c(L$ymin, L$ymax + 1.0), clip = "off") +
    theme_base()
}

legend_bins <- function(labs = BINLAB, title = "Share providing grandchild care (study-specific measure)") {
  g <- data.frame(lab = factor(labs, levels = labs),
                  x = seq(0.40, 0.40 + 0.115 * 4, by = 0.115))
  ggplot(g) +
    annotate("text", x = 0.38, y = 0, hjust = 1, size = 2.15, colour = "grey25",
             family = "sans", label = title) +
    geom_point(aes(x = x, y = 0, fill = lab), shape = 22, size = 3.2,
               colour = "grey15", stroke = 0.42) +
    geom_text(aes(x = x, y = -0.42, label = lab), size = 2.0, colour = "grey30",
              family = "sans") +
    scale_fill_manual(values = setNames(BINCOL, labs)) +
    coord_cartesian(xlim = c(0, 1), ylim = c(-0.75, 0.5), clip = "off") +
    theme_base()
}

make_fig <- function(d, est, se, xlim, xbreaks, xlab, pooled, ci, pi,
                     file, h_mm = 180, digits = 3, ncol = "ncog", nlab = "Obs.",
                     legtitle = "Share providing grandchild care (study-specific measure)") {
  L <- lay(d, est, se)
  p <- (panel_left(L, ncol, nlab) | panel_forest(L, xlim, xbreaks, xlab, pooled, ci, pi) |
          panel_right(L, pooled, ci, digits)) + plot_layout(widths = c(2.5, 3.5, 1.9))
  p <- p / legend_bins(levels(L$rows$fbin), legtitle) + plot_layout(heights = c(1, 0.05))
  ggsave(file.path(OUT, paste0(file, ".pdf")), p, width = 180, height = h_mm,
         units = "mm", device = cairo_pdf, bg = SURF)
  ggsave(file.path(OUT, paste0(file, ".png")), p, width = 180, height = h_mm,
         units = "mm", dpi = 600, bg = SURF)
}

# ---- Fig A1: cognition (headline; IDV colour shows NO sorting => universal) ----
make_fig(d0, "bcog", "secog", c(-0.12, 0.12), c(-0.10, -0.05, 0, 0.05, 0.10),
  "Within-person association of grandchild care with cognition (s.d.)",
  0.0288, c(0.0176, 0.0400), c(0.007, 0.050),
  "figA1_cognition", ncol = "ncog", nlab = "Obs.",
  legtitle = "Hofstede individualism index (higher = more individualist)")

# ---- Fig A2: depression (IDV = winning moderator, R2 = 34.8%) ----
make_fig(d0, "bdep", "sedep", c(-0.20, 0.20), c(-0.20, -0.10, 0, 0.10, 0.20),
  "Within-person association of grandchild care with depressive symptoms (s.d.)",
  0.0007, c(-0.0184, 0.0197), c(-0.064, 0.066),
  "figA2_depression", ncol = "ndep", nlab = "Obs.",
  legtitle = "Hofstede individualism index (higher = more individualist)")

# ---- Fig A3: mobility limitations, colour keyed to share of households with 3+ persons (coresid3; NOT three-generation co-residence) ----
# meta-regression backing: b_mob ~ coresid3: +0.108 (p=.009), R2=53.5%
CORLAB <- c("<10%", "10-15%", "15-25%", "25-35%", ">=35%")
CORBRK <- c(-Inf, 0.10, 0.15, 0.25, 0.35, Inf)
d1 <- d0
d1$fbin <- cut(d1$coresid3, breaks = CORBRK, labels = CORLAB, right = FALSE)
stopifnot(!any(is.na(d1$fbin[!is.na(d1$bmob)])))
make_fig(d1, "bmob", "semob", c(-0.12, 0.12), c(-0.10, -0.05, 0, 0.05, 0.10),
  "Within-person association of grandchild care with mobility limitations (s.d.)",
  0.0081, c(-0.0086, 0.0249), c(-0.049, 0.065),
  "figA3_mobility", ncol = "nmob", nlab = "Obs.",
  legtitle = "Adults 50+ living in households of 3 or more persons")

# ---- Fig A4: meta-regression bubble — mobility effect vs household-size share (coresid3) ----
db <- d1 %>% filter(!is.na(bmob), !is.na(semob), !is.na(coresid3)) %>%
  mutate(w = 1 / semob^2)
line_df <- data.frame(coresid3 = seq(min(db$coresid3), max(db$coresid3), length.out = 60)) %>%
  mutate(bmob = -0.0158895 + 0.1078905 * coresid3)
YCAP <- 0.13
prt <- filter(db, clab == "Portugal")
labdf <- db %>% filter(clab %in% c("Mexico", "China", "Poland", "Sweden",
                                   "Netherlands", "United States", "England",
                                   "Croatia", "Czechia")) %>%
  mutate(ny = case_when(clab %in% c("Netherlands", "Czechia") ~ -0.012,
                        clab == "United States" ~ -0.020,
                        TRUE ~ 0.012),
         nx = case_when(clab == "England" ~ -0.045,
                        TRUE ~ 0))
p4 <- ggplot(db, aes(coresid3, bmob)) +
  geom_hline(yintercept = 0, linetype = "22", linewidth = 0.3, colour = "grey60") +
  geom_line(data = line_df, colour = "#123F63", linewidth = 0.65) +
  geom_point(data = filter(db, bmob <= YCAP), aes(size = w, fill = fbin),
             shape = 21, colour = "grey15", stroke = 0.4, alpha = 0.95) +
  scale_fill_manual(values = setNames(BINCOL, CORLAB), name = NULL) +
  annotate("segment", x = prt$coresid3, xend = prt$coresid3,
           y = YCAP - 0.014, yend = YCAP - 0.003,
           linewidth = 0.35, colour = "grey45",
           arrow = arrow(length = unit(1.8, "pt"), type = "closed")) +
  annotate("text", x = prt$coresid3, y = YCAP - 0.020,
           label = sprintf("Portugal (%.2f)", prt$bmob),
           size = 2.0, colour = "grey35", family = "sans") +
  geom_text(data = labdf, aes(x = coresid3 + nx, y = bmob + ny, label = clab),
            size = 2.15, colour = "grey20", family = "sans") +
  scale_size_continuous(range = c(1.4, 6.5), guide = "none") +
  scale_x_continuous(labels = function(x) paste0(round(100 * x), "%")) +
  coord_cartesian(ylim = c(-0.09, YCAP)) +
  labs(x = "Share of adults 50+ living in households of 3 or more persons",
       y = "Grandchild-care coefficient on mobility limitations") +
  theme_classic(base_size = 7.5, base_family = "sans") +
  theme(axis.line = element_line(linewidth = 0.3),
        axis.ticks = element_line(linewidth = 0.3),
        axis.text = element_text(size = 7.5, colour = "black"),
        legend.position = "none", plot.margin = margin(4, 8, 4, 4, "pt"))
ggsave(file.path(OUT, "figA4_bubble_mobility.pdf"), p4, width = 120, height = 80,
       units = "mm", device = cairo_pdf, bg = SURF)
ggsave(file.path(OUT, "figA4_bubble_mobility.png"), p4, width = 120, height = 80,
       units = "mm", dpi = 600, bg = SURF)

# ---- Fig A5: meta-regression bubble — depression effect vs individualism ----
db5 <- d0 %>% filter(!is.na(bdep), !is.na(sedep), !is.na(idv)) %>%
  mutate(w = 1 / sedep^2)
line5 <- data.frame(idv = seq(min(db5$idv), max(db5$idv), length.out = 60)) %>%
  mutate(bdep = 0.0603832 - 0.0009817 * idv)
lab5 <- db5 %>% filter(clab %in% c("China", "South Korea", "Mexico", "England",
                                   "United States", "Croatia", "Hungary",
                                   "Germany", "Sweden", "Portugal")) %>%
  mutate(ny = case_when(clab %in% c("Croatia", "Germany", "Sweden") ~ -0.020,
                        TRUE ~ 0.020),
         nx = case_when(clab == "United States" ~ -9,
                        clab == "South Korea" ~ 5, TRUE ~ 0))
p5 <- ggplot(db5, aes(idv, bdep)) +
  geom_hline(yintercept = 0, linetype = "22", linewidth = 0.3, colour = "grey60") +
  geom_line(data = line5, colour = "#123F63", linewidth = 0.65) +
  geom_point(aes(size = w, fill = fbin),
             shape = 21, colour = "grey15", stroke = 0.4, alpha = 0.95) +
  scale_fill_manual(values = setNames(BINCOL, BINLAB), name = NULL) +
  geom_text(data = lab5, aes(x = idv + nx, y = bdep + ny, label = clab),
            size = 2.15, colour = "grey20", family = "sans") +
  scale_size_continuous(range = c(1.4, 6.5), guide = "none") +
  coord_cartesian(ylim = c(-0.19, 0.17)) +
  labs(x = "Hofstede individualism index",
       y = "Grandchild-care coefficient on depressive symptoms") +
  theme_classic(base_size = 7.5, base_family = "sans") +
  theme(axis.line = element_line(linewidth = 0.3),
        axis.ticks = element_line(linewidth = 0.3),
        axis.text = element_text(size = 7.5, colour = "black"),
        legend.position = "none", plot.margin = margin(4, 8, 4, 4, "pt"))
ggsave(file.path(OUT, "figA5_bubble_depression.pdf"), p5, width = 120, height = 80,
       units = "mm", device = cairo_pdf, bg = SURF)
ggsave(file.path(OUT, "figA5_bubble_depression.png"), p5, width = 120, height = 80,
       units = "mm", dpi = 600, bg = SURF)

cat("TOPIC A FIGURES DONE\n")
