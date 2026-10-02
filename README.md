# Cognitive effects of ketamine and esketamine in major depressive episodes

Analysis code and study-level data for the systematic review, meta-analysis and
meta-regression *"Domain-specific cognitive effects of ketamine and esketamine in
major depressive episodes"* (PROSPERO CRD420261286207).

## Scripts

| Script | Analysis |
|---|---|
| `R/01_between_meta-analysis.R` | Between-group (drug vs control) pooled Hedges' g, leave-one-out, forest plot |
| `R/02_within_meta-analysis.R` | Within-group (baseline → end of treatment) standardized mean change, leave-one-out, forest plot |
| `R/03_between_metaregression.R` | Univariate mixed-effects meta-regressions, between-group structure |
| `R/04_within_metaregression.R` | Univariate mixed-effects meta-regressions, within-group structure |
| `R/05_publication_bias.R` | Funnel plot, Egger's regression test and trim-and-fill (between- or within-group, k ≥ 10) |

Each script is run once per drug × cognitive domain (× analysis), on one CSV file.

## Methods implemented

- Effect sizes: Hedges' g, aligned so that positive values = cognitive improvement
- Random-effects models (REML); fixed-effect (inverse-variance) models when k ≤ 4
- Leave-one-out sensitivity analysis for every domain
- Publication bias (k ≥ 10 only): funnel plots, Egger's regression test, Duval & Tweedie trim-and-fill
- Meta-regression (ketamine, domains with k ≥ 10): one moderator per model (REML);
  QM, pseudo-R², residual I² and QE reported; studies missing a moderator are
  dropped from that model only

## Data

All data are study-level summary statistics extracted from published reports; no individual patient data are included.

```
data/
  extraction/        full extraction sheet (study design, population, dosing, outcomes)
  between/           one CSV per drug × domain: study, yi, vi, SE        → scripts 01, 05
  within/            one CSV per drug × domain: study, pre/post means, SDs, n, r → scripts 02, 05
  metaregression/    one CSV per domain (ketamine, k ≥ 10): yi, vi + moderators → scripts 03, 04
  data_dictionary.md column definitions, units and coding of categorical variables
```

## How to run

1. Install R (≥ 4.3) and the `metafor` package.
2. Open a script, set `DATA_FILE` (and `DOMAIN_NAME`) in the *Settings* block,
   or leave `DATA_FILE <- NULL` to pick the file interactively in RStudio.
3. Run the whole script. Results print to the console; plots go to the plot pane.
   In scripts 03–04, set `OUTPUT_FILE` to save the moderator summary table as CSV.
   For script 05, use the same CSV given to script 01 (between) or the yi/vi values from script 02 (within).

CSV files are semicolon-separated (`read.csv2`); decimal commas and points are both accepted.
The expected columns are described at the top of each script.

## Software

R 4.5.3 · metafor (Viechtbauer, 2010)

## Citation

[Authors]. Domain-specific cognitive effects of ketamine and esketamine in major
depressive episodes: a systematic review, meta-analysis and meta-regression. [Journal, year].
