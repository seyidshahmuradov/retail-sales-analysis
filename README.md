# Retail Receipts Analysis: Sales, Profit & Anomalies (R)

Analysis of 10M+ supermarket receipt lines from Azerbaijani retail chains (spring 2024). The project cleans messy product names, joins receipts to a product/margin reference table, and analyzes sales, profit, and data anomalies.

Final project for the Data Analytics course at **Code Academy**.

## Data

The data files (`fp_receipts.rds`, `fp_map.rds`) are **not included** in this repository. They were provided as part of a university course, so I do not redistribute them. The structure is described below.

| Table | Rows | Description |
|---|---|---|
| `fp_receipts` | 10,000,909 | Receipt lines: store (`pos`), date, receipt ID, product name, quantity, unit price |
| `fp_map` | 118,118 | Reference table: period, product, FOOD / NON-FOOD type, profit margin |
| `full_tab` (joined) | 640,815 | Cleaned and joined working table (11 columns) |

Raw data: ~676K distinct product names and 6,596 distinct store names. After cleaning and joining: 43,091 products and 969 stores.

**Expected input columns** (to run with your own data, place files with the same structure in `data/`):

| File | Columns |
|---|---|
| `fp_receipts.rds` | `pos`, `rec_date`, `rec_id`, `product_name`, `qnt`, `unit_price` |
| `fp_map.rds` | `period`, `product_type`, `product`, `profit_margin` |

## What I did

- **Text normalization of product names**: fixed encoding artifacts, unified units (KG, QR, LT, ML), pack-size notation (`X6`, `*6`, `6 PCS` → `6 EDED`), decimals, punctuation and Azerbaijani characters, so names from receipts match names in the reference table.
- **Store (POS) and receipt ID cleaning**: standardized store names and receipt ID prefixes per chain (BRAVO, OBA, ARAZ, BAZARSTORE, RAHAT, BIZIM, MEGASTORE).
- **Join** on cleaned product name + month using `data.table` keyed joins (fast on 10M rows).
- **Derived metrics**: `total_sales = qnt × unit_price`, `profit = total_sales × profit_margin`.
- **Descriptive analysis**: summary statistics and distributions (custom-computed boxplots, because extreme outliers made default `ggplot` boxplots unreadable).
- **Anomaly analysis**: day of week, top stores, daily receipt counts.
- **Regression and correlation** between sales and profit.

## Key results

| Metric | Value |
|---|---|
| Median line-item sales | 6.32 AZN (mean 7.66, max 3,000 AZN) |
| Median line-item profit | 1.25 AZN (some negative values, min −76.16 AZN) |
| Top store chain | BRAVO: 2.23M AZN sales, 541K AZN profit (about 2.3× the #2 chain, OBA, at 948K AZN) |
| Sales–profit correlation | r = 0.85 |

**Anomalies found**
1. **Friday spike**: Friday sales (1.70M AZN) far exceeded every other weekday.
2. **19 April 2024 spike**: 142,612 receipts and 1.15M AZN in sales on a single day, versus roughly 15–25K receipts on a typical day. The dataset starts on 19 April, while the reference table covers March–May, so earlier sales were most likely loaded in bulk under this date. The Friday spike is likely the same artifact, since 19 April 2024 was a Friday.
3. **BRAVO dominance**: likely reflects a larger store network, but could also reflect differences in how the data was recorded.

## Limitations

- Only about 6.4% of receipt lines (640,815 of 10M) matched the reference table after cleaning, so results describe the matched subset, not all sales.
- `profit` is defined as `total_sales × profit_margin`, so the regression of profit on sales and margin (R² ≈ 0.80) describes that relationship rather than predicting real-world profit.

## Repository structure

```
├── data_cleaning.R      # cleaning functions, join, derived metrics
├── final_report.Rmd     # full report (knit to HTML)
├── slides/              # project presentation
└── data/                # not included, see Data section
```

## How to run

1. Clone the repo and open it in RStudio.
2. Add `fp_receipts.rds` and `fp_map.rds` to `data/` (not included in the repo, see Data section).
3. Run `data_cleaning.R`, or knit `final_report.Rmd`.

**R packages:** data.table, dplyr, tidyr, stringr, lubridate, plotly, DT, knitr, rmarkdown

The report commentary is written in Azerbaijani.

## Author

Seyidshah Muradov
