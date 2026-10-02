# 1. Install and load the required package
if(!require(metafor)) install.packages("metafor")
library(metafor)

# 2. Load the data
path <- rstudioapi::selectFile(caption = "Select csv File",
                               filter = "Spreadsheets (*.csv)",
                               existing = TRUE)

# 3. Load the dataset
within_data <- read.csv2(path)

within_data$yi <- as.numeric(as.character(within_data$yi))
within_data$vi <- as.numeric(as.character(within_data$vi))

# 2. Fit the random-effects model for within-group data
res_within_keta <- rma(
  yi = yi, 
  vi = vi, 
  data = within_data, 
  method = "REML"
)

# 3. Main meta-analysis summary
summary(res_within_keta)

# 4. Generate Funnel Plot
funnel(res_within_keta, main = "Funnel Plot: working memory executive function (Within-Group Ketamine)")

# 5. Egger's Regression Test (for k >= 10)
eggar_test <- regtest(res_within_keta, model = "lm")
print(eggar_test)

# 6. Trim and Fill Analysis
tf_test <- trimfill(res_within_keta)
summary(tf_test)
funnel(tf_test, main = "Working memory, executive function, cognitive flexibility")

