# Data dictionary

All files are semicolon-separated CSV with decimal commas (as exported by Excel with
Italian/European regional settings). One row = one study (or one independent cohort).

## File naming

`<Domain>_<Analysis>.csv`, e.g. `AffectiveProcessing_AttentionalBias_Between.csv`

Domains: GlobalCognition · ProcessingSpeed · AttentionVigilance · WorkingMemory_ExecutiveFunction ·
VerbalLearningMemory · VisualVisuospatialMemory · ReasoningProblemSolving ·
RetrogradeAutobiographicalMemory · SubjectiveMemory · AffectiveProcessing_AttentionalBias

Analysis: `Between` (drug vs control) or `Within` (baseline → end of treatment).

## Between-group files (scripts 01, 05)

| Column | Description |
|---|---|
| `Study` | First author and year, as shown on the forest plot (e.g. "Reed et al., 2018") |
| `yi` | Hedges' g, active drug vs control at end of treatment. Positive = better cognitive performance with the drug. When a study used several tests for the same domain, g is a composite (mean of the g values; variance adjusted assuming r = 0.5, Borenstein et al., 2009) |
| `vi` | Sampling variance of `yi` |
| `SE` | Standard error of `yi` (√vi); informative only, not used by the scripts |

## Within-group files (scripts 02, 05)

| Column | Description |
|---|---|
| `Study` | Study label |
| `m_pre` | Mean score at baseline (active-drug arm) |
| `m_post` | Mean score at end of treatment / follow-up |
| `sd_pre` | SD at baseline |
| `sd_post` | SD at end of treatment |
| `n` | Number of participants in the active-drug arm |
| `r` | Assumed pre–post correlation (0.5 unless reported) |
| `direction` | (optional) +1 if higher scores = better, −1 if lower = better (e.g. reaction times, TMT) |

## Meta-regression files (scripts 03, 04)

`yi`, `vi` as above (or the raw within-group columns), plus:

| Column | Type | Description / coding |
|---|---|---|
| `age_mean` | continuous | Mean age of participants (years) |
| `female_percent` | continuous | Female participants (%) |
| `ect_status` | categorical | Concomitant ECT with ketamine: [CODING — e.g. Y / N] |
| `study_length_days` | continuous | Study duration / follow-up (days) |
| `diagnosis_type` | categorical | Sample composition: [CODING — e.g. MDD / BD / Mixed] |
| `other_medication` | categorical | Background psychotropic polytherapy allowed: [CODING — e.g. Y / N] |
| `dose_mgkg` | continuous | Ketamine dose per administration (mg/kg) |
| `baseline_depression_severity` | continuous | Baseline depression score in MADRS equivalents |
| `control_type` | categorical | Between only. Comparator: [CODING — e.g. placebo / midazolam / propofol / thiopental / ECT] |
| `net_depression_advantage` | continuous | Between only. % depression reduction in drug arm minus % reduction in control arm |
| `frequency_total` | continuous | Within only. Total number of ketamine administrations |
| `depression_score_reduction` | continuous | Within only. % reduction in depression score from baseline to end of treatment |

Missing values: leave the cell empty (read as NA); the study is excluded only from the
meta-regression model for that moderator.
