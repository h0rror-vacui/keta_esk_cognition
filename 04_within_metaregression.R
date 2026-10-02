# ==============================================================================
# 04 - WITHIN-GROUP META-REGRESSION (ketamine only, domains with k >= 10)
# Univariate mixed-effects meta-regressions (REML), one moderator at a time.
#
# Input: one CSV per cognitive domain with one row per study containing
#   EITHER yi, vi - within-group standardized mean change and its variance
#   OR     m_pre, m_post, sd_pre, sd_post, n, r (+ optional direction) - the
#          raw pre/post data, from which yi and vi are computed as in script 02
#   + the moderator columns listed in MODERATORS below.
# Comparator type and net advantage over control do not exist without a control
# arm; number of infusions and % depression reduction are tested instead.
# Studies with a missing value for a moderator are dropped from THAT model only
# (case deletion); the other models keep the full sample.
# ==============================================================================

if (!require(metafor)) install.packages("metafor")
library(metafor)

# ---- Settings ----------------------------------------------------------------
DATA_FILE   <- NULL   # e.g. "data/metaregression/within_verbal_memory.csv"; NULL = choose interactively
DOMAIN_NAME <- "Cognitive domain"
OUTPUT_FILE <- NULL   # e.g. "results/within_verbal_memory_metareg.csv"; NULL = don't save
K_MIN       <- 10
MEASURE     <- "SMCR"   # only used if yi/vi must be computed; keep identical to script 02

# Moderators tested in the WITHIN-GROUP structure.
# column = name in the CSV; type = "continuous" or "categorical"
MODERATORS <- data.frame(
  label  = c("Mean age (years)", "Female (%)", "Concomitant ECT",
             "Study duration (days)", "Diagnostic composition", "Total number of infusions",
             "Background polytherapy", "Ketamine dose (mg/kg)",
             "Baseline depression severity (MADRS-eq.)",
             "Depression score reduction from baseline (%)"),
  column = c("age_mean", "female_percent", "ect_status",
             "study_length_days", "diagnosis_type", "frequency_total",
             "other_medication", "dose_mgkg",
             "baseline_depression_severity",
             "depression_score_reduction"),
  type   = c("continuous", "continuous", "categorical",
             "continuous", "categorical", "continuous",
             "categorical", "continuous",
             "continuous",
             "continuous"),
  stringsAsFactors = FALSE
)

# ---- Load data ---------------------------------------------------------------
if (is.null(DATA_FILE)) {
  DATA_FILE <- rstudioapi::selectFile(caption = "Select within-group meta-regression csv",
                                      filter = "Spreadsheets (*.csv)", existing = TRUE)
}
my_data <- read.csv2(DATA_FILE)
num <- function(v) as.numeric(gsub(",", ".", as.character(v)))

if (!all(c("yi", "vi") %in% names(my_data))) {
  # compute within-group effect sizes from raw pre/post data (same as script 02)
  for (col in intersect(c("m_pre", "m_post", "sd_pre", "sd_post", "n", "r", "direction"), names(my_data)))
    my_data[[col]] <- num(my_data[[col]])
  if (!"direction" %in% names(my_data)) my_data$direction <- 1
  my_data$direction[is.na(my_data$direction)] <- 1
  my_data <- escalc(measure = MEASURE, m1i = m_post, m2i = m_pre, sd1i = sd_pre, sd2i = sd_post,
                    ni = n, ri = r, data = my_data)
  my_data$yi <- my_data$yi * my_data$direction
  my_data <- as.data.frame(my_data)
} else {
  for (col in c("yi", "vi")) my_data[[col]] <- num(my_data[[col]])
}

k_total <- sum(!is.na(my_data$yi))
cat("\n=== WITHIN-GROUP META-REGRESSION:", DOMAIN_NAME, "| k =", k_total, "===\n")
if (k_total < K_MIN) warning("k = ", k_total, " < ", K_MIN, ": below the pre-specified threshold for meta-regression.")

# ---- Run one univariate meta-regression per moderator ------------------------
run_metareg <- function(label, column, type) {
  if (!column %in% names(my_data)) {
    message("Skipped '", label, "': column '", column, "' not found in the CSV.")
    return(NULL)
  }
  x <- my_data[[column]]
  x <- if (type == "continuous") as.numeric(gsub(",", ".", as.character(x))) else factor(x)
  d <- data.frame(yi = my_data$yi, vi = my_data$vi, x = x)
  d <- d[complete.cases(d), ]                     # case deletion for this model only
  if (type == "categorical") d$x <- droplevels(d$x)
  if (nrow(d) < 3 || (type == "categorical" && nlevels(d$x) < 2)) {
    message("Skipped '", label, "': not enough studies or only one category.")
    return(NULL)
  }

  m <- rma(yi = yi, vi = vi, mods = ~ x, data = d, method = "REML")
  cat("\n--- ", label, " (k = ", m$k, ") ---\n", sep = "")
  print(m)

  data.frame(
    domain       = DOMAIN_NAME,
    moderator    = label,
    k            = m$k,
    QM           = round(m$QM, 3),
    QM_df        = m$QMdf[1],
    QM_p         = signif(m$QMp, 3),
    R2_percent   = round(ifelse(is.null(m$R2), NA, m$R2), 2),
    I2_residual  = round(m$I2, 2),
    QE           = round(m$QE, 3),
    QE_p         = signif(m$QEp, 3),
    coefficients = paste(sprintf("%s: b = %.3f (p = %.4f)", sub("^x", "", rownames(m$beta))[-1],
                                 m$beta[-1], m$pval[-1]), collapse = "; "),
    stringsAsFactors = FALSE
  )
}

results <- do.call(rbind, Map(run_metareg, MODERATORS$label, MODERATORS$column, MODERATORS$type))
rownames(results) <- NULL

cat("\n=== SUMMARY ===\n")
print(results[, c("moderator", "k", "QM", "QM_p", "R2_percent", "I2_residual", "QE_p")])
if (!is.null(OUTPUT_FILE)) write.csv2(results, OUTPUT_FILE, row.names = FALSE)
