# ==============================================================================
# 02 - WITHIN-GROUP META-ANALYSIS (baseline -> end of treatment, active-drug arm)
# Ketamine / esketamine and cognition in major depressive episodes
#
# Run once per drug x cognitive domain. Effect sizes (standardized mean change,
# Hedges-corrected) are computed here from pre/post means and SDs.
#
# Expected CSV columns (semicolon-separated, decimal comma or point), in order:
#   1 study    - label shown on the forest plot
#   2 m_pre    - baseline mean
#   3 m_post   - end-of-treatment mean
#   4 sd_pre   - baseline SD
#   5 sd_post  - end-of-treatment SD
#   6 n        - sample size of the active arm
#   7 r        - assumed pre-post correlation (e.g. 0.5)
#   8 direction (optional) - +1 if higher score = better, -1 if lower = better
#                            (e.g. reaction times, TMT); flips the sign so that
#                            POSITIVE values always = cognitive improvement
# ==============================================================================

if (!require(metafor)) install.packages("metafor")
library(metafor)

# ---- Settings ----------------------------------------------------------------
DATA_FILE   <- NULL   # e.g. "data/within/esketamine_working_memory.csv"; NULL = choose interactively
DOMAIN_NAME <- "Cognitive domain"
K_FIXED_MAX <- 4

# Effect-size measure:
#   "SMCR" = change standardized by the BASELINE SD (raw-score standardization)
#   "SMCC" = change standardized by the SD of the CHANGE scores (uses sd_pre, sd_post and r)
# !! Set this to the measure actually used for the published results !!
MEASURE <- "SMCR"

# ---- Load data ---------------------------------------------------------------
if (is.null(DATA_FILE)) {
  DATA_FILE <- rstudioapi::selectFile(caption = "Select within-group csv file",
                                      filter = "Spreadsheets (*.csv)", existing = TRUE)
}
dat <- read.csv2(DATA_FILE)
colnames(dat)[1:7] <- c("study", "m_pre", "m_post", "sd_pre", "sd_post", "n", "r")
if (ncol(dat) >= 8) colnames(dat)[8] <- "direction"

numeric_cols <- intersect(c("m_pre", "m_post", "sd_pre", "sd_post", "n", "r", "direction"), names(dat))
for (col in numeric_cols) dat[[col]] <- as.numeric(gsub(",", ".", as.character(dat[[col]])))
if (!"direction" %in% names(dat)) dat$direction <- 1
dat$direction[is.na(dat$direction)] <- 1
study_labels <- as.character(dat$study)

# ---- Effect sizes: standardized mean change (post - pre) ----------------------
dat <- escalc(measure = MEASURE,
              m1i  = m_post, m2i = m_pre,     # change = post - pre
              sd1i = sd_pre,                  # SMCR: standardized by baseline SD
              sd2i = sd_post,                 # needed only for SMCC
              ni   = n, ri = r,
              data = dat)
dat$yi <- dat$yi * dat$direction              # positive = improvement
print(dat[, c("study", "yi", "vi")])
k <- sum(!is.na(dat$yi))

# ---- Pooled model ------------------------------------------------------------
model_method <- if (k <= K_FIXED_MAX) "FE" else "REML"
res <- rma(yi = yi, vi = vi, method = model_method, data = dat)
cat("\n=== WITHIN-GROUP:", DOMAIN_NAME, "| k =", k, "| model:", model_method, "| measure:", MEASURE, "===\n")
print(res)

# ---- Sensitivity: leave-one-out ----------------------------------------------
cat("\n--- Leave-one-out ---\n")
print(leave1out(res))

# Publication bias (Egger's test, trim-and-fill, funnel plots): see 05_publication_bias.R

# ---- Forest plot -------------------------------------------------------------
forest(res,
       xlim   = c(-3.5, 3.5),
       at     = c(-2.0, -1.0, 0, 1.0, 2.0),
       digits = c(3, 3),
       header = c("Author(s) and Year", "SMC Hedges' g [95% CI]"),
       slab   = study_labels,
       theme  = "bold",
       addfit = TRUE,
       psize  = 1)
abline(v = 0, lty = "dotted", col = "gray40")   # line of no change from baseline
