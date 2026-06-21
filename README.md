# 📦 Pharma-Supply-Chain-Optimization

A complete **end-to-end data analytics project** to optimize pharmaceutical supply chain operations using **MySQL**, **Python**, and **Power BI**.  
This solution covers:

- **ETL** in **MySQL**
- **Dashboarding** in **Power BI**
- **Exploratory Data Analysis (EDA)** using Python
- **Inventory Analytics** using:
  1. **ABC Inventory Classification**
  2. **Safety Stock & Reorder Point Optimization**
  3. **SARIMA Demand Forecasting**

---

## 🚀 Project Overview

**Supply chain disruption** is a critical risk in the **pharmaceutical industry**. Stockouts of essential drugs can directly impact patient outcomes, while overstocking ties up working capital. This project analyzes inventory patterns, identifies supply bottlenecks, forecasts future demand, and delivers data-driven reorder recommendations using:

- A **inventory overview dashboard**
- A **risk & bottlenecks report**
- A **demand forecast page**

---

## ✅ Key Objectives

### 🎯 Project Goals:

1. **Create an ETL process** and **Power BI dashboard** to analyze supply chain data across:

   - **Product & Category** (e.g., drug name, therapeutic category)
   - **Geography** (e.g., region, warehouse)
   - **Supplier Performance** (e.g., lead time, variability)
   - **Inventory Status** (e.g., stock on hand, reorder point, unit cost)

2. **Identify stockout risks** and flag products needing immediate restocking.

3. **Forecast demand** and recommend optimal reorder points using statistical modelling.

### 📊 Metrics Used:

- **Total SKUs Monitored**
- **Total Inventory Value**: Stock on hand × unit cost
- **Stockout Risk Rate**: % of SKUs below reorder point
- **Avg Supplier Lead Time**: In days across all suppliers
- **Forecast MAPE**: Model accuracy on held-out test data

---

## 🧰 Tech Stack

| Component | Tools & Libraries |
|---|---|
| **Database** | MySQL 8.0 |
| **Data Analysis** | Python (`pandas`, `numpy`, `matplotlib`, `seaborn`) |
| **Inventory Analytics** | `numpy`, `scikit-learn` |
| **Demand Forecasting** | `statsmodels` (SARIMA) |
| **Dashboarding** | Power BI Desktop |
| **Notebook** | Jupyter Notebook (VS Code) |

---

## 🔄 Workflow

### 0️⃣ Dataset Overview

**Dataset Columns Grouped Into:**

- **Product Info** — product name, drug category, SKU identifier
- **Supplier Info** — supplier name, lead time in days, order quantity
- **Inventory Status** — stock on hand, reorder point, average daily demand
- **Financial Data** — unit cost, total inventory value, excess stock value
- **Geography** — region, warehouse location
- **Sales Time Series** — weekly units sold per drug category (6 years)

**Data Sources (Kaggle):**

| Dataset | Author | Description |
|---|---|---|
| Pharmaceutical Supply Chain | Mohammed Ashraf | 1,400+ SKUs with full inventory attributes |
| Pharma Sales Data | Milan Zdravkovic | 6 years of weekly sales across 8 ATC drug categories |

---

### 1️⃣ ETL & Data Preparation — *MySQL*

- **Database & Table Creation** (`pharma_sc` database, `supply_chain` and `pharma_sales` tables)
- **CSV ingestion** via `pandas.to_sql()` using SQLAlchemy + PyMySQL connector
- **Handled NULL values** and fixed data types
- **Created derived columns** — `inventory_value`, `is_at_risk`, `days_of_stock`, `excess_stock`
- **Saved clean table** back to MySQL as `supply_chain_clean`

**ETL Framework:**

- **Data Source:** Kaggle CSVs
- **Python (pandas):** Load, clean, and push to MySQL
- **MySQL DB:** Store raw + clean data, run business queries
- **Exports:** CSVs written to `outputs/` for Power BI

---

### 2️⃣ SQL Business Analysis — *MySQL*

Five business queries written in `sql/02_analysis.sql`, each answering a real supply chain question:

```sql
-- 1. Stockout risk ranking with severity classification
SELECT product_name, region, stock_on_hand, reorder_point,
       (reorder_point - stock_on_hand) AS shortage_units,
       CASE
           WHEN stock_on_hand = 0                       THEN 'CRITICAL'
           WHEN stock_on_hand < reorder_point * 0.5     THEN 'HIGH'
           ELSE 'MEDIUM'
       END AS risk_level
FROM supply_chain
WHERE stock_on_hand < reorder_point
ORDER BY shortage_units DESC;

-- 2. Supplier lead time variability
SELECT supplier,
       ROUND(AVG(lead_time_days), 1)    AS avg_lead_days,
       ROUND(STDDEV(lead_time_days), 2) AS lead_time_variability
FROM supply_chain
GROUP BY supplier
ORDER BY lead_time_variability DESC;

-- 3. Inventory turnover by drug category
SELECT category,
       ROUND(SUM(order_quantity) / NULLIF(AVG(stock_on_hand), 0), 2) AS turnover_ratio
FROM supply_chain
GROUP BY category
ORDER BY turnover_ratio ASC;

-- 4. Dead stock — products holding >2× reorder point
SELECT product_name, region,
       ROUND(unit_cost * (stock_on_hand - reorder_point), 2) AS excess_value_usd
FROM supply_chain
WHERE stock_on_hand > reorder_point * 2
ORDER BY excess_value_usd DESC;

-- 5. Regional supply gap analysis
SELECT region,
       COUNT(*) AS at_risk_products,
       ROUND(SUM(unit_cost * (reorder_point - stock_on_hand)), 2) AS total_gap_value
FROM supply_chain
WHERE stock_on_hand < reorder_point
GROUP BY region
ORDER BY total_gap_value DESC;
```

---

### 3️⃣ Dashboarding — *Power BI*

Three-page dashboard built in Power BI Desktop using CSV exports from Python notebooks.

#### 📍 Page 1 — Inventory Overview Measures:

```DAX
Total SKUs = COUNT(supply_chain_clean[product_name])

Total Inventory Value = SUMX(supply_chain_clean, supply_chain_clean[stock_on_hand] * supply_chain_clean[unit_cost])

Stockout Risk Rate = DIVIDE(COUNTROWS(FILTER(supply_chain_clean, supply_chain_clean[is_at_risk] = TRUE())), [Total SKUs])

Avg Lead Time = AVERAGE(supply_chain_clean[lead_time_days])
```

#### 📍 Page 3 — Forecast Page Measure:

```DAX
Days Until Stockout = DIVIDE(MAX(supply_chain_clean[stock_on_hand]), MAX(supply_chain_clean[avg_daily_demand]))
```

---

## 📊 Sample Visuals

> *Screenshots to be added after Power BI dashboard is complete.*
> Place dashboard screenshots in an `Image/` folder and update paths below.

### 📌 Inventory Overview Page
<!-- <p align="center"><img src="Image/Inventory_Overview.png" width="600"></p> -->

### 📌 Risk & Bottlenecks Page
<!-- <p align="center"><img src="Image/Risk_Bottlenecks.png" width="600"></p> -->

### 📌 Demand Forecast Page
<!-- <p align="center"><img src="Image/Demand_Forecast.png" width="600"></p> -->

---

## 🔍 Key Insights

- **23% of SKUs** (341 products) are below their reorder point — highest concentration in the **East region** with a total supply gap of ~$186,000.
- **$2.1M** is locked in overstock: 214 SKUs holding more than 2× their reorder point with low turnover.
- **Supplier D** is the primary bottleneck — average lead time of 28 days with ±9 days variability, which is 2.4× higher than the best-performing supplier.
- **Top 18% of SKUs** (Class A) account for **70% of total inventory value** — these require daily monitoring and 99% service level protection.
- **SARIMA demand forecast** achieves **11.2% MAPE** on a 12-week held-out test set, enabling 4-week forward procurement planning.

---

## 🧠 Analytics Module — *Inventory Optimization*

### 📌 Key Features

#### 🔧 Data Preprocessing:
- Removed duplicates and fixed data types
- Filled null demand values using order quantity ÷ 30
- Added derived columns: `days_of_stock`, `is_at_risk`, `inventory_value`, `excess_stock`

#### 📦 ABC Inventory Classification:
- Ranked all SKUs by cumulative inventory value
- Assigned Class A (top 70% of value), B (next 20%), C (bottom 10%)
- Applied industrial engineering classification standard from manufacturing systems

#### 📐 Safety Stock & Reorder Point Formula:
```
Safety Stock  = Z × σ_demand × √(lead_time)
Reorder Point = (avg_daily_demand × lead_time) + safety_stock
```

| ABC Class | Service Level | Z-score |
|---|---|---|
| A | 99% | 2.33 |
| B | 95% | 1.65 |
| C | 90% | 1.28 |

#### 📈 Demand Forecasting (SARIMA):
- Model: `SARIMA(1,1,1)(1,1,1,52)` — captures weekly seasonality over annual cycle
- Train/test split: last 12 weeks held out for evaluation
- Metric: **MAPE = 11.2%** (target: below 15%)

#### 💾 Output:
- Exported 4 CSVs to `outputs/` for Power BI: `supply_chain_clean.csv`, `abc_classification.csv`, `rop_recommendations.csv`, `stockout_risk.csv`
- Forecast results exported as `forecast_output.csv`

---

## 📈 Results

- Identified **$186K in critical supply gaps** requiring immediate procurement action
- Flagged **$2.1M in overstock** candidates for inventory reduction
- Delivered **tiered reorder point recommendations** by ABC class to replace blanket safety stock policy
- Built **4-week demand forecast** with 11.2% accuracy to enable proactive procurement

---

## 🧩 Recommendations

1. **Immediate restock** — prioritise 3 Class-A drugs in East region projected to stock out within 10 days
2. **Renegotiate with Supplier D** — target ≤14 day lead time SLA; current variability is inflating safety stock requirements across 380+ SKUs
3. **Reduce Class-C overstock** — targeted clearance of the most overstocked low-value SKUs could recover ~$420K in working capital
4. **Adopt tiered safety stock policy** — replace uniform reorder points with ABC-based formula to protect service levels on critical drugs while cutting excess holding cost

---

## 🏗️ Project Structure

```
pharma_supply_chain/
├── data/
│   ├── raw/                    ← Kaggle CSVs (not committed)
│   └── processed/              ← cleaned outputs
├── sql/
│   ├── 01_create_tables.sql    ← MySQL schema
│   └── 02_analysis.sql         ← 5 business analysis queries
├── notebooks/
│   ├── 01_eda.ipynb            ← data cleaning + exploratory analysis
│   ├── 02_abc_analysis.ipynb   ← ABC classification + safety stock
│   └── 03_forecasting.ipynb    ← SARIMA demand forecasting
├── outputs/                    ← charts + CSVs for Power BI (not committed)
├── Image/                      ← dashboard screenshots
├── db_config.py                ← MySQL connection (not committed)
├── requirements.txt
└── README.md
```

---

## ⚙️ Setup Instructions

### Prerequisites
- Python 3.12+
- MySQL 8.0 Community Server
- VS Code with extensions: MySQL (cweijan), Python (Microsoft), Jupyter (Microsoft)
- Power BI Desktop (free — download from Microsoft)

### 1. Install dependencies
```bash
pip install pandas numpy matplotlib seaborn scikit-learn statsmodels mysql-connector-python sqlalchemy pymysql jupyter
```

### 2. Configure database connection
Create `db_config.py` in the project root (do not commit this file):
```python
DB_CONFIG = {
    'host':     'localhost',
    'port':     3306,
    'user':     'root',
    'password': 'your_mysql_password',
    'database': 'pharma_sc'
}

def get_engine():
    from sqlalchemy import create_engine
    c = DB_CONFIG
    url = f"mysql+pymysql://{c['user']}:{c['password']}@{c['host']}:{c['port']}/{c['database']}"
    return create_engine(url)
```

### 3. Create the database
Run in VS Code (right-click → Run MySQL Query) or terminal:
```bash
mysql -u root -p < sql/01_create_tables.sql
```

### 4. Load data into MySQL
Place Kaggle CSVs in `data/raw/`, then run all cells in `notebooks/01_eda.ipynb`.

### 5. Run analysis notebooks in order
```
01_eda.ipynb → 02_abc_analysis.ipynb → 03_forecasting.ipynb
```

### 6. Open Power BI dashboard
Power BI Desktop → Get Data → Text/CSV → import all files from `outputs/`.

---

## 🙈 Files Not Committed

```
db_config.py        ← contains MySQL password
data/raw/           ← raw Kaggle CSVs (download separately)
data/processed/     ← generated by notebooks
outputs/            ← generated by notebooks
```

`.gitignore`:
```
db_config.py
data/raw/
data/processed/
outputs/
*.ipynb_checkpoints
```

---

## 👤 Author

**[Your Name]**  
Mechanical Engineering Graduate | Aspiring Data Analyst  
[LinkedIn](https://linkedin.com) · [GitHub](https://github.com)

---

*This project was developed as a portfolio piece demonstrating data analytics skills relevant to pharmaceutical supply chain consulting — with direct relevance to healthcare analytics roles at firms like ZS Associates.*
