# =============================================================================
# Supplementary figures (style inherited from figures_A.R)
#   figS1 cognition, intensive care vs none (K=24)
#   figS2 depression, intensive care vs none (K=24)
#   figS3 sex-stratified coefficients (6 cohorts x 5 outcomes)
# =============================================================================
suppressPackageStartupMessages({
  library(ggplot2); library(dplyr); library(patchwork)
})
BASE <- "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/figures"
TMP  <- "D:/跨国数据/.claude/worktrees/topicA-grandchild-care/Analysis_topicA_grandchild_care/Temp"
OUT  <- file.path(BASE, "final")

d0 <- read.csv(file.path(TMP, "intensity_meta_input.csv"), fileEncoding = "UTF-8")
ext <- read.csv(file.path(BASE, "moderators_external.csv"), fileEncoding = "UTF-8")
pd <- read.csv(file.path(BASE, "plotdata_A.csv"), fileEncoding = "UTF-8")
d0 <- left_join(d0, ext[, c("clab", "idv")], by = "clab") %>%
  left_join(pd[, c("clab", "coresid3")], by = "clab")

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
BINLAB <- c("<30", "30-50", "50-65", "65-80", ">=80")
BINBRK <- c(-Inf, 30, 50, 65, 80, Inf)
INK <- "grey15"; INK2 <- "grey45"; POOL <- "grey8"; SURF <- "#FCFCFB"
BAND <- c("#F4F5F6", "#FBFBFA")
d0$regime <- factor(unname(reg_map[d0$clab]), levels = REG)
d0$fbin <- cut(d0$idv, breaks = BINBRK, labels = BINLAB, right = FALSE)

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
panel_left <- function(L) {
  rows <- L$rows
  ggplot() + band_layer(L) +
    geom_text(data = L$hdr, aes(x = 0, y = y, label = toupper(regime)),
              hjust = 0, size = 2.05, fontface = "bold", colour = "grey35", family = "sans") +
    geom_text(data = rows, aes(x = 0.05, y = y, label = clab),
              hjust = 0, size = 2.4, colour = INK, family = "sans") +
    geom_text(data = rows, aes(x = 1.0, y = y, label = format(n, big.mark = ",")),
              hjust = 1, size = 2.2, colour = INK2, family = "sans") +
    annotate("text", x = 0.05, y = 0.9, label = "Country", hjust = 0, size = 2.3,
             fontface = "bold", family = "sans") +
    annotate("text", x = 1.0, y = 0.9, label = "Obs.", hjust = 1, size = 2.3,
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
legend_bins <- function(title = "Hofstede individualism index (higher = more individualist)",
                        labs = BINLAB) {
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
make_fig <- function(d, est, se, xlim, xbreaks, xlab, pooled, ci, pi, file, h_mm = 176,
                     legtitle = "Hofstede individualism index (higher = more individualist)") {
  L <- lay(d, est, se)
  p <- (panel_left(L) | panel_forest(L, xlim, xbreaks, xlab, pooled, ci, pi) |
          panel_right(L, pooled, ci)) + plot_layout(widths = c(2.2, 3.8, 1.9))
  p <- p / legend_bins(legtitle, levels(L$rows$fbin)) + plot_layout(heights = c(1, 0.05))
  ggsave(file.path(OUT, paste0(file, ".pdf")), p, width = 180, height = h_mm,
         units = "mm", device = cairo_pdf, bg = SURF)
  ggsave(file.path(OUT, paste0(file, ".png")), p, width = 180, height = h_mm,
         units = "mm", dpi = 600, bg = SURF)
}

dcog <- d0 %>% filter(outc == "cog")
ddep <- d0 %>% filter(outc == "dep")

# figS1: cognition, intensive vs none
make_fig(dcog, "b2", "se2", c(-0.22, 0.22), c(-0.2, -0.1, 0, 0.1, 0.2),
  "Intensive grandchild care vs none: cognition (s.d.)",
  0.0458, c(0.0242, 0.0672), c(-0.006, 0.098), "figS1_cog_intensive")

# figS2: depression, intensive vs none
make_fig(ddep, "b2", "se2", c(-0.30, 0.30), c(-0.3, -0.15, 0, 0.15, 0.3),
  "Intensive grandchild care vs none: depressive symptoms (s.d.)",
  0.0150, c(-0.0100, 0.0400), c(-0.041, 0.071), "figS2_dep_intensive")

# figS3: mobility, intensive vs none (colour = household-size (3+ persons) bins, as figA3)
CORLAB <- c("<10%", "10-15%", "15-25%", "25-35%", ">=35%")
CORBRK <- c(-Inf, 0.10, 0.15, 0.25, 0.35, Inf)
dmob <- d0 %>% filter(outc == "mob")
dmob$fbin <- cut(dmob$coresid3, breaks = CORBRK, labels = CORLAB, right = FALSE)
make_fig(dmob, "b2", "se2", c(-0.25, 0.25), c(-0.2, -0.1, 0, 0.1, 0.2),
  "Intensive grandchild care vs none: mobility limitations (s.d.)",
  0.0144, c(-0.0040, 0.0329), c(-0.027, 0.056), "figS3_mob_intensive",
  legtitle = "Adults 50+ living in households of 3 or more persons")

# ---- figS4: sex-stratified coefficients + pooled row ----
sx <- read.csv(file.path(TMP, "sex_stratified.csv"), fileEncoding = "UTF-8") %>%
  mutate(lo = b - 1.96 * se, hi = b + 1.96 * se, pooled = FALSE) %>%
  select(cohort, outc, sex, b, lo, hi, pooled)
sp <- read.csv(file.path(TMP, "sex_pooled.csv"), fileEncoding = "UTF-8") %>%
  transmute(cohort = "Pooled (meta)", outc, sex, b = th, lo, hi, pooled = TRUE)
sx <- bind_rows(sx, sp) %>%
  mutate(outlab = factor(outc, levels = c("dep", "cog", "mob", "ls", "srh"),
                         labels = c("Depressive symptoms", "Cognition",
                                    "Mobility limitations", "Life satisfaction",
                                    "Self-rated health")),
         cohort = factor(cohort, levels = rev(c("CHARLS", "KLoSA", "MHAS",
                                                "SHARE", "ELSA", "HRS",
                                                "Pooled (meta)"))),
         sexl = factor(sex, levels = c("male", "female"),
                       labels = c("Grandfathers", "Grandmothers")))
pS3 <- ggplot(sx, aes(y = cohort, x = b, colour = sexl)) +
  geom_vline(xintercept = 0, linetype = "22", linewidth = 0.3, colour = "grey60") +
  geom_linerange(aes(xmin = lo, xmax = hi), position = position_dodge(width = 0.55),
                 linewidth = 0.45) +
  geom_point(aes(shape = pooled, size = pooled), position = position_dodge(width = 0.55)) +
  scale_shape_manual(values = c(`FALSE` = 16, `TRUE` = 18), guide = "none") +
  scale_size_manual(values = c(`FALSE` = 1.7, `TRUE` = 2.6), guide = "none") +
  scale_colour_manual(values = c(Grandfathers = "#8FBEDA", Grandmothers = "#123F63"),
                      name = NULL) +
  facet_wrap(~outlab, ncol = 5) +
  coord_cartesian(xlim = c(-0.22, 0.32)) +
  labs(x = "Within-person association of grandchild care with outcome (s.d.)", y = NULL) +
  theme_classic(base_size = 7.5, base_family = "sans") +
  theme(axis.line = element_line(linewidth = 0.3),
        axis.ticks = element_line(linewidth = 0.3),
        axis.text = element_text(size = 7, colour = "black"),
        strip.background = element_blank(),
        strip.text = element_text(size = 7.5, face = "bold", colour = "grey25"),
        legend.position = "bottom", legend.key.size = unit(8, "pt"),
        panel.spacing.x = unit(6, "pt"),
        plot.margin = margin(4, 8, 2, 4, "pt"))
ggsave(file.path(OUT, "figS4_sex_stratified.pdf"), pS3, width = 180, height = 76,
       units = "mm", device = cairo_pdf, bg = SURF)
ggsave(file.path(OUT, "figS4_sex_stratified.png"), pS3, width = 180, height = 76,
       units = "mm", dpi = 600, bg = SURF)

# ---- figS5: cognition x individualism bubble — the flat line of universality ----
pd2 <- pd %>% left_join(ext[, c("clab", "idv")], by = "clab") %>%
  filter(!is.na(bcog), !is.na(secog), !is.na(idv)) %>%
  mutate(w = 1 / secog^2,
         fbin = cut(idv, breaks = BINBRK, labels = BINLAB, right = FALSE))
line5 <- data.frame(idv = seq(min(pd2$idv), max(pd2$idv), length.out = 60)) %>%
  mutate(bcog = 0.0341412 - 0.0000749 * idv)
lab5 <- pd2 %>% filter(clab %in% c("China", "South Korea", "Austria", "Estonia",
                                   "United States", "England", "Mexico",
                                   "Croatia", "Germany")) %>%
  mutate(ny = case_when(clab %in% c("Germany", "South Korea") ~ -0.020,
                        TRUE ~ 0.020),
         nx = case_when(clab == "United States" ~ -9,
                        clab == "South Korea" ~ 5, TRUE ~ 0))
p5c <- ggplot(pd2, aes(idv, bcog)) +
  geom_hline(yintercept = 0, linetype = "22", linewidth = 0.3, colour = "grey60") +
  geom_line(data = line5, colour = "#123F63", linewidth = 0.65) +
  geom_point(aes(size = w, fill = fbin),
             shape = 21, colour = "grey15", stroke = 0.4, alpha = 0.95) +
  scale_fill_manual(values = setNames(BINCOL, BINLAB), name = NULL) +
  geom_text(data = lab5, aes(x = idv + nx, y = bcog + ny, label = clab),
            size = 2.15, colour = "grey20", family = "sans") +
  scale_size_continuous(range = c(1.4, 6.5), guide = "none") +
  coord_cartesian(ylim = c(-0.13, 0.22)) +
  labs(x = "Hofstede individualism index",
       y = "Grandchild-care coefficient on cognition") +
  theme_classic(base_size = 7.5, base_family = "sans") +
  theme(axis.line = element_line(linewidth = 0.3),
        axis.ticks = element_line(linewidth = 0.3),
        axis.text = element_text(size = 7.5, colour = "black"),
        legend.position = "none", plot.margin = margin(4, 8, 4, 4, "pt"))
ggsave(file.path(OUT, "figS5_bubble_cognition.pdf"), p5c, width = 120, height = 80,
       units = "mm", device = cairo_pdf, bg = SURF)
ggsave(file.path(OUT, "figS5_bubble_cognition.png"), p5c, width = 120, height = 80,
       units = "mm", dpi = 600, bg = SURF)
cat("SUPP FIGURES DONE\n")
