# ==============================================================================
# 05 - PUBLICATION BIAS (between- or within-group, domains with k >= 10)
# Funnel plot, Egger's regression test for funnel-plot asymmetry and
# Duval & Tweedie trim-and-fill. Run once per analysis x cognitive domain.
#
# Input CSV (semicolon-separated): one row per study with
#   yi, vi - effect size (Hedges' g / standardized mean change) and variance,
#            the same values used in script 01 (between) or 02 (within)
#   (optional) study - study label
# ==============================================================================

if (!require(metafor)) install.packages("metafor")
library(metafor)

# ---- Settings ----------------------------------------------------------------
DATA_FILE   <- NULL         # e.g. "data/within/ketamine_working_memory.csv"; NULL = choose interactively
ANALYSIS    <- "Within-group"   # "Between-group" or "Within-group" (used in titles)
DOMAIN_NAME <- "Working memory, executive function, cognitive flexibility"
DRUG        <- "Ketamine"
K_MIN       <- 10

# ---- Load data ---------------------------------------------------------------
if (is.null(DATA_FILE)) {
  DATA_FILE <- rstudioapi::selectFile(caption = "Select csv file",
                                      filter = "Spreadsheets (*.csv)", existing = TRUE)
}
pb_data <- read.csv2(DATA_FILE)
for (col in c("yi", "vi")) pb_data[[col]] <- as.numeric(gsub(",", ".", as.character(pb_data[[col]])))

k <- sum(!is.na(pb_data$yi))
if (k < K_MIN) warning("k = ", k, " < ", K_MIN, ": tests for funnel-plot asymmetry have low power ",
                       "and were not performed for such domains in the paper.")

# ---- Random-effects model ----------------------------------------------------
res <- rma(yi = yi, vi = vi, data = pb_data, method = "REML")
cat("\n===", ANALYSIS, "|", DRUG, "|", DOMAIN_NAME, "| k =", k, "===\n")
summary(res)

# ---- Funnel plot -------------------------------------------------------------
funnel(res, main = paste0("Funnel plot: ", DOMAIN_NAME, " (", ANALYSIS, ", ", DRUG, ")"))

# ---- Egger's regression test -------------------------------------------------
# Classical Egger test (weighted linear regression of effect on its SE)
cat("\n--- Egger's regression test ---\n")
egger_test <- regtest(res, model = "lm")
print(egger_test)

# ---- Trim-and-fill -----------------------------------------------------------
cat("\n--- Trim-and-fill (Duval & Tweedie) ---\n")
tf_test <- trimfill(res)
summary(tf_test)
funnel(tf_test, main = DOMAIN_NAME)   # open circles = imputed studies
