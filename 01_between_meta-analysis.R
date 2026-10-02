# ==============================================================================
# 01 - BETWEEN-GROUP META-ANALYSIS (drug vs control at end of treatment)
# Ketamine / esketamine and cognition in major depressive episodes
#
# Run once per drug x cognitive domain (publication bias: script 05). Each CSV holds one row per study with a
# pre-computed Hedges' g (yi) and its sampling variance (vi), aligned so that
# POSITIVE values = better cognitive performance in the active-drug arm.
#
# Expected CSV columns (semicolon-separated, decimal comma or point), in order:
#   1 study  - label shown on the forest plot (e.g. "Kumpf et al., 2025")
#   2 yi     - Hedges' g (drug minus control)
#   3 vi     - sampling variance of g
#   4 SE     - standard error (optional, not used)
# ==============================================================================

if (!require(metafor)) install.packages("metafor")
library(metafor)

# ---- Settings ----------------------------------------------------------------
DATA_FILE   <- NULL   # e.g. "data/between/ketamine_working_memory.csv"; NULL = choose interactively
DOMAIN_NAME <- "Cognitive domain"   # used in plot titles
K_FIXED_MAX <- 4      # k <= 4  -> fixed-effect (inverse-variance) model

# ---- Load data ---------------------------------------------------------------
if (is.null(DATA_FILE)) {
  DATA_FILE <- rstudioapi::selectFile(caption = "Select between-group csv file",
                                      filter = "Spreadsheets (*.csv)", existing = TRUE)
}
dat <- read.csv2(DATA_FILE)
colnames(dat)[1:3] <- c("study", "yi", "vi")
if (ncol(dat) >= 4) colnames(dat)[4] <- "SE"

# Force numeric (handles decimal comma vs point)
for (col in c("yi", "vi")) dat[[col]] <- as.numeric(gsub(",", ".", as.character(dat[[col]])))
study_labels <- as.character(dat$study)
k <- nrow(dat)

# ---- Pooled model ------------------------------------------------------------
# Random-effects (REML) by default; with very few studies tau^2 cannot be
# estimated reliably, so a fixed-effect model is used instead.
model_method <- if (k <= K_FIXED_MAX) "FE" else "REML"
res <- rma(yi = yi, vi = vi, method = model_method, data = dat)
cat("\n=== BETWEEN-GROUP:", DOMAIN_NAME, "| k =", k, "| model:", model_method, "===\n")
print(res)

# ---- Sensitivity: leave-one-out ----------------------------------------------
cat("\n--- Leave-one-out ---\n")
loo_results <- leave1out(res)
print(loo_results)

# Publication bias (Egger's test, trim-and-fill, funnel plots): see 05_publication_bias.R

# ---- Forest plot -------------------------------------------------------------
forest(res,
       xlim   = c(-3.5, 3.5),
       at     = c(-2.0, -1.0, 0, 1.0, 2.0),
       digits = c(3, 3),
       header = c("Author(s) and Year", "Hedges' g [95% CI]"),
       slab   = study_labels,
       theme  = "bold",
       addfit = TRUE,
       psize  = 1)
abline(v = 0, lty = "dotted", col = "gray40")   # line of no effect
