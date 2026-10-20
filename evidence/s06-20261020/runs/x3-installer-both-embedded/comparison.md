# Benchmark comparison: TAS vs OpenStudio

Independent comparison of two engine-neutral benchmark documents. Tolerance bands are
**provisional reporting buckets**, not validated thresholds. The overall gate is the worst of
the numerical, coverage, provenance and reconciliation statuses. Peak-hour bands and the two
whole-model peak-load bands are informational and are excluded from the numerical status — they are
still calculated and shown, and rows carrying such a band are marked in the Note column;
reconciliation is a separate within-document diagnostic status that also contributes to the
overall gate.

Presentation: engineering quantities, absolute differences and normalized percentages are shown to
two decimals. `comparison.csv` and `comparison-summary.json` keep full precision. `n/a` = not
reported by at least one engine; `—` = not applicable (for example, no percentage for a circular
hour). Neither marker is ever zero. Hour-of-year values and hour differences are integers.

## Summary

| Field | Value |
| --- | --- |
| Tolerance profile | default |
| Gate status (overall) | Fail |
| Numerical status | Fail |
| Coverage status | Warn |
| Provenance status | Pass |
| Reconciliation status | Pass |
| Metrics matched | 6 |
| Metrics warned | 1 |
| Metrics failed (all bands) | 9 |
| Fail rows contributing to numerical status | 3 |
| Fail rows informational (excluded) | 6 |
| Metrics not applicable | 2 |
| Required metrics compared | 16 of 18 |
| Required metrics unavailable | 2 |
| TAS schema version | 1.0.0 |
| OpenStudio schema version | 1.0.0 |

Band counts include informational rows: 6 of the 9 Fail rows are informational and excluded from the numerical status; 3 contribute to it.

## Coverage

How much of the two runs was actually compared. Required metrics are the whole-model metrics plus
the metrics of uniquely matched spaces; the metrics of one-sided, duplicated or ambiguous spaces are
not counted here because those spaces are reported under space alignment instead. An unavailable
metric is never a numerical failure, so it is recorded here — otherwise missing results could read as
a clean pass.

| Field | Value |
| --- | --- |
| Coverage status | Warn |
| Required metrics | 18 |
| Compared | 16 |
| Unavailable (not compared) | 2 |
| Unmatched spaces | 0 |
| Ambiguous (split) space names | 0 |
| Duplicated space identities | 0 |

**Coverage is INCOMPLETE**, so this comparison must not be described as a complete result:

- 2 of 18 required metrics were unavailable on at least one side (reported as N/A, never as a numerical failure).

## Provenance compatibility

Compatible: both runs share the same canonical model, weather and design-day basis, with the expected engine and route on each side.

## Tolerance profile

Provisional reporting bands (not validated thresholds). Recorded so a changed profile is never hidden behind an unchanged name.

| Setting | Value |
| --- | --- |
| Name | default |
| Warn (relative) | 5.00% |
| Fail (relative) | 15.00% |
| Peak-hour warn (h) | 1 |
| Peak-hour fail (h) | 24 |
| Default near-zero floor | 0.00 |
| Near-zero floor (kWh) | 1.00 |
| Near-zero floor (Wh) | 1000.00 |
| Near-zero floor (kW) | 0.01 |
| Near-zero floor (W) | 10.00 |
| Near-zero floor (m2) | 0.01 |
| Near-zero floor (m3) | 0.01 |
| Near-zero floor (h) | 0.50 |

## Difference definition

Normalized difference (%) = 100 × |OpenStudio − TAS| / max(|TAS|, |OpenStudio|, applicable near-zero floor).

It is unsigned and is **not** percentage change against TAS. Peak-hour metrics use the circular hour
difference and have no percentage. Bands use the stored fractions, shown here as Match < 5.00%, Warn 5.00% to < 15.00%, Fail >= 15.00% (provisional).

## Provenance

| Field | TAS | OpenStudio |
| --- | --- | --- |
| Engine kind | TAS | OpenStudio |
| Engine name | Tas | EnergyPlus |
| Engine version | 9.5.7.0 | 25.1.0 |
| SDK version |  | 3.10.0 |
| Route | Native-TAS | Native-OpenStudio |
| Weather | weather | weather |
| Design-day source | None | None |
| Run state | Success | Success |
| Source model | 000000_SAM_AnalyticalModel | 000000_SAM_AnalyticalModel |
| Source model GUID | 1988f7b93ec047d0b87bf9cb345d9eab | 1988f7b93ec047d0b87bf9cb345d9eab |
| SAM commit | 717533c | 717533c |

`Design-day source: None` means no design-day source was supplied; sizing-period runs stay disabled.

> **Input limitation:** Matching canonical model, weather and design-day metadata does not prove that the two engines received equivalent converted inputs. Per-engine input manifests are unavailable (SAM_OpenStudio#30, SAM_UI#230).

## Engine warnings and notes

These are the producers' own diagnostics; they are not comparison results and do not change a band.

### TAS

- **Note:** Shared gbXML was exported from the source model (no --gbxml supplied).

### OpenStudio

- **Warning:** [SAM-OS-IC-001] Warning: Pollutant generation is not converted (EnergyPlus generic contaminant modelling is out of scope) (SAM InternalCondition 9e54af09-65fb-4f64-98d7-200db3be2457) → SAM_InternalCondition_S39_OfficeOpen_30b69a1f
- **Note:** [SAM-OS-RUN-002] Information: Annual weather source: explicit EPW (weather.epw)
- **Note:** [SAM-OS-RUN-002] Information: Ground temperatures taken from the SAM model WeatherData (depth 0.5 m set, 12 monthly values)
- **Note:** [SAM-OS-RUN-002] Information: No design-day source supplied; sizing-period runs stay disabled unless OpenStudioConversionOptions.RunSizingPeriods overrides

## Model metrics

> **Caveats (apply even when values pass):** whole-model peak-load semantics differ between
> engines — OpenStudio reports a coincident total, TAS a building-profile maximum — so peak-load
> comparisons are informational, not equivalence claims. `peakHeatingLoad` and `peakCoolingLoad`
> are therefore banded and shown below but **excluded from the numerical status**, exactly like the
> peak-hour metrics; promoting them into the gate needs the B4 corpus and energy-modeller review.
> Every other metric — annual energy, per-space peak loads, unmet hours, geometry — gates normally.
> The primary conditioning pairing (OpenStudio Ideal Loads — TAS thermostats + IZAMs + TBD sizing)
> is a **candidate** pending validation. A tolerance profile cannot remove these limitations.

| Metric | Unit | TAS | OpenStudio | Abs diff | Normalized difference (%) | Band | Note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| consumptionHeating | kWh | 220.63 | 2081.90 | 1861.27 | 89.40 | Fail |  |
| consumptionCooling | kWh | 5540.31 | 4731.62 | 808.69 | 14.60 | Warn |  |
| peakHeatingLoad | kW | 1.42 | 3.19 | 1.77 | 55.36 | Fail | Informational — excluded from numerical status |
| peakHeatingHour | hourOfYear | 775 | 8455 | 1080 | — | Fail | Circular hour difference; Informational — excluded from numerical status |
| peakCoolingLoad | kW | 3.13 | 5.39 | 2.26 | 42.00 | Fail | Informational — excluded from numerical status |
| peakCoolingHour | hourOfYear | 3901 | 5029 | 1128 | — | Fail | Circular hour difference; Informational — excluded from numerical status |
| floorArea | m2 | 50.00 | 50.00 | 0.00 | 0.00 | Match |  |
| volume | m3 | 150.00 | 150.00 | 0.00 | 0.00 | Match |  |

## Model-total vs sum-of-spaces reconciliation

Additive quantities only; non-additive peak loads are not reconciled. Only uniquely-matched spaces are summed; unmatched or ambiguous spaces make a reconciliation incomplete.

| Engine | Quantity | Unit | Model total | Sum of spaces | Abs diff | Normalized difference (%) | Band | Used/Missing/Excluded | Complete |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TAS | floorArea | m2 | 50.00 | 50.00 | 0.00 | 0.00 | Match | 1/0/0 | yes |
| TAS | volume | m3 | 150.00 | 150.00 | 0.00 | 0.00 | Match | 1/0/0 | yes |
| OpenStudio | floorArea | m2 | 50.00 | 50.00 | 0.00 | 0.00 | Match | 1/0/0 | yes |
| OpenStudio | volume | m3 | 150.00 | 150.00 | 0.00 | 0.00 | Match | 1/0/0 | yes |

## Space alignment

| Field | Value |
| --- | --- |
| TAS spaces | 1 |
| OpenStudio spaces | 1 |
| Matched by GUID | 1 |
| Matched by name | 0 |

**Only in TAS:** none

**Only in OpenStudio:** none

**Duplicate TAS GUIDs:** none

**Duplicate OpenStudio GUIDs:** none

**Duplicate TAS names:** none

**Duplicate OpenStudio names:** none

**Ambiguous (split) name matches:** none

## Space metrics

| Space | GUID | Match | Metric | Unit | TAS | OpenStudio | Abs diff | Normalized difference (%) | Band | Note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Office | cb68bed195af496bb255a13ffa5c58e9 | Guid | area | m2 | 50.00 | 50.00 | 0.00 | 0.00 | Match |  |
| Office | cb68bed195af496bb255a13ffa5c58e9 | Guid | volume | m3 | 150.00 | 150.00 | 0.00 | 0.00 | Match |  |
| Office | cb68bed195af496bb255a13ffa5c58e9 | Guid | heating.designLoad | W | 1927.01 | n/a | n/a | n/a | N/A | Unavailable (Tas only) |
| Office | cb68bed195af496bb255a13ffa5c58e9 | Guid | heating.peakLoad | W | 1926.95 | 3189.84 | 1262.89 | 39.59 | Fail |  |
| Office | cb68bed195af496bb255a13ffa5c58e9 | Guid | heating.peakHour | hourOfYear | 936 | 8455 | 1241 | — | Fail | Circular hour difference; Informational — excluded from numerical status |
| Office | cb68bed195af496bb255a13ffa5c58e9 | Guid | heating.unmetHours | h | 0.00 | 0.00 | 0.00 | 0.00 | Match |  |
| Office | cb68bed195af496bb255a13ffa5c58e9 | Guid | cooling.designLoad | W | 3415.62 | n/a | n/a | n/a | N/A | Unavailable (Tas only) |
| Office | cb68bed195af496bb255a13ffa5c58e9 | Guid | cooling.peakLoad | W | 3415.46 | 5390.59 | 1975.14 | 36.64 | Fail |  |
| Office | cb68bed195af496bb255a13ffa5c58e9 | Guid | cooling.peakHour | hourOfYear | 4358 | 5029 | 671 | — | Fail | Circular hour difference; Informational — excluded from numerical status |
| Office | cb68bed195af496bb255a13ffa5c58e9 | Guid | cooling.unmetHours | h | 0.00 | 0.00 | 0.00 | 0.00 | Match |  |

