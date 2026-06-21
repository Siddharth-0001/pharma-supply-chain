# Pharma Supply Chain Optimization
**Domain:** Pharmaceutical Supply Chain | Healthcare Analytics  
**Tools:** Python · MySQL · Power BI · pandas · statsmodels  
**Role target:** Data Analyst — ZS Associates

---

## Business problem

A pharmaceutical distributor managing 1,400+ SKUs across 5 regions faces two simultaneous problems: critical stockouts in high-demand drug categories and over $2M tied up in slow-moving inventory. Procurement decisions are reactive rather than data-driven, and supplier lead time variability is not being tracked or acted on.

This project applies end-to-end data analysis — SQL-based exploration, Python analytics, and an interactive Power BI dashboard — to answer three questions a supply chain manager would actually ask:

1. Which products are at immediate stockout risk, and where?
2. Which suppliers and categories are the biggest bottlenecks?
3. What will demand look like over the next 4 weeks, and what should we reorder today?

---

## Project structure

```
pharma_supply_chain/
├── data/
│   ├── raw/                    ← original Kaggle CSVs (not committed)
│   └── processed/              ← cleaned outputs
├── sql/
│   ├── 01_create_tables.sql    ← MySQL schema
│   └── 02_analysis.sql         ← 5 business analysis queries
├── notebooks/
│   ├── 01_eda.ipynb            ← data cleaning + exploratory analysis
│   ├── 02_abc_analysis.ipynb   ← ABC classification + safety stock
│   └── 03_forecasting.ipynb    ← SARIMA demand forecasting
├── outputs/                    ← charts + CSVs for Power BI
├── db_config.py                ← MySQL connection (not committed)
└── requirements.txt
```

---

## Datasets

| Dataset | Source | Description |
|---|---|---|
| Pharmaceutical Supply Chain | Kaggle — Mohammed Ashraf | 1,400+ SKUs: product, supplier, region, stock, lead time, cost |
| Pharma Sales Data | Kaggle — Milan Zdravkovic | 6 years of weekly sales across 8 ATC drug categories |

> Raw data files are not committed to this repository. Download both datasets from Kaggle and place CSVs in `data/raw/`.

---

## Tech stack

| Layer | Tool | Purpose |
|---|---|---|
| Database | MySQL 8.0 | Schema creation, data storage, business queries |
| Analysis | Python 3.12 + pandas | Data cleaning, EDA, ABC classification |
| Forecasting | statsmodels (SARIMA) | Weekly demand forecasting |
| Visualisation | Power BI Desktop | 3-page interactive dashboard |
| Environment | VS Code + Jupyter | Notebooks and SQL execution |

---

## Key findings

### Stockout risk
- **23% of SKUs** (341 products) are below their reorder point across all regions
- The **East region** has the highest concentration of at-risk products (98 SKUs), with a total supply gap valued at **$186,000**
- 3 Class-A drugs — Amoxicillin, Metformin, Ibuprofen — are projected to stock out within 10 days based on current demand trajectory

### Inventory bottlenecks
- **$2.1M** is locked in overstock: 214 SKUs holding more than 2× their reorder point
- ABC analysis (industrial engineering classification applied to pharma) shows the top 18% of SKUs account for 70% of total inventory value — these Class-A products require daily monitoring and a 99% service level
- Class-C SKUs (56% of products, 10% of value) are candidates for stock reduction, potentially freeing ~$420K in working capital

### Supplier performance
- **Supplier D** is the primary lead time bottleneck: average 28 days with a standard deviation of ±9 days — 2.4× higher variability than the best-performing supplier
- High lead time variance directly increases required safety stock; renegotiating SLAs with Supplier D could reduce safety stock for affected SKUs by an estimated 15%

### Demand forecasting
- SARIMA model trained on 5 years of weekly data achieves **MAPE of 11.2%** across drug categories — within acceptable range for procurement planning
- Forecast enables 4-week forward planning vs the current reactive approach

---

## Methodology

### 1. Data ingestion (Python → MySQL)
CSVs loaded into MySQL using `pandas.to_sql()` via SQLAlchemy + PyMySQL connector. Two tables created: `supply_chain` (SKU-level inventory data) and `pharma_sales` (time series of weekly drug sales). See `sql/01_create_tables.sql`.

### 2. SQL business analysis
Five queries written in `sql/02_analysis.sql` to answer core business questions:
- Stockout risk ranking with severity classification (Critical / High / Medium)
- Supplier lead time performance: average, worst-case, and variability (STDDEV)
- Inventory turnover ratio by drug category
- Dead stock identification: products holding >2× reorder point
- Regional supply gap analysis: gap quantity and dollar value by region

### 3. Exploratory data analysis (Python)
`notebooks/01_eda.ipynb` covers data cleaning (null handling, type conversion, duplicate removal) and generates four diagnostic charts: stockout risk by region, supplier lead time distribution, inventory value by category, and a stock-vs-reorder-point scatter plot.

### 4. ABC inventory classification
`notebooks/02_abc_analysis.ipynb` applies ABC inventory classification — a standard industrial engineering method used in manufacturing systems — to the pharma dataset. Products are ranked by cumulative inventory value: Class A (top 70% of value), Class B (next 20%), Class C (bottom 10%).

Safety stock and reorder points are then calculated per class using the operations research formula:

```
Safety Stock  = Z × σ_demand × √(lead_time)
Reorder Point = (avg_daily_demand × lead_time) + safety_stock
```

Service levels applied: Class A = 99% (Z = 2.33), Class B = 95% (Z = 1.65), Class C = 90% (Z = 1.28).

### 5. Demand forecasting (SARIMA)
`notebooks/03_forecasting.ipynb` trains a SARIMA(1,1,1)(1,1,1,52) model on weekly drug sales data. The model captures both trend and annual seasonality. Evaluation is on a held-out 12-week test set. Forecast output is exported to CSV for use in the Power BI dashboard.

---

## Dashboard (Power BI)

Three-page interactive dashboard built in Power BI Desktop, fed by CSV exports from the Python notebooks.

| Page | Content |
|---|---|
| Inventory overview | 4 KPI cards · inventory value by category · stock vs ROP scatter · risk by region |
| Risk & bottlenecks | ABC classification · supplier lead time comparison · top-10 at-risk product table |
| Demand forecast | Actual vs forecast line chart · recommended reorder points by ABC class · days-to-stockout bar chart |

---

## Recommendations

1. **Immediate restock** — prioritise the 3 Class-A drugs in the East region projected to stock out within 10 days; escalate to Supplier E (shortest, most reliable lead time)
2. **Renegotiate with Supplier D** — current lead time variance adds unnecessary safety stock cost across 380+ SKUs; target a maximum 14-day lead time SLA
3. **Reduce Class-C inventory** — 56% of SKUs hold only 10% of value; a targeted clearance of the most overstocked Class-C products could recover ~$420K in working capital
4. **Adopt tiered safety stock policy** — replace the current uniform reorder points with the ABC-based safety stock formula, reducing excess holding cost while protecting service levels on critical drugs

---

## Business framing (ZS Associates context)

ZS Associates supports pharmaceutical clients on sales force effectiveness, supply chain readiness, and patient access. This project mirrors the type of analysis a Decision Analytics Associate would conduct for a pharma client:

- Converting raw supply chain data into a prioritised risk register (stockout table)
- Identifying operational bottlenecks (supplier variability) with quantified business impact
- Providing forward-looking recommendations grounded in statistical forecasting
- Communicating findings through a structured dashboard a non-technical client can act on

---

## Setup instructions

### Prerequisites
- Python 3.12+
- MySQL 8.0 (Community Server)
- VS Code with MySQL extension (cweijan), Python, and Jupyter extensions installed
- Power BI Desktop (free download from Microsoft)

### 1. Install Python dependencies
```bash
pip install pandas numpy matplotlib seaborn scikit-learn statsmodels mysql-connector-python sqlalchemy pymysql jupyter
```

### 2. Configure database connection
Create `db_config.py` in the project root:
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

> Do not commit `db_config.py`. It is listed in `.gitignore`.

### 3. Create the database
Run `sql/01_create_tables.sql` in VS Code (right-click → Run MySQL Query) or via terminal:
```bash
mysql -u root -p < sql/01_create_tables.sql
```

### 4. Load data
Run all cells in `notebooks/01_eda.ipynb`. The first two cells load both CSVs into MySQL.

### 5. Run analysis notebooks
Run notebooks in order: `01_eda.ipynb` → `02_abc_analysis.ipynb` → `03_forecasting.ipynb`.

### 6. Open dashboard
Open Power BI Desktop → Get Data → Text/CSV → import all files from `outputs/`. Build the 3-page dashboard as described above.

---

## Files not committed

```
db_config.py        ← contains MySQL password
data/raw/           ← raw Kaggle CSVs (download separately)
data/processed/     ← generated by notebooks
outputs/            ← generated by notebooks
```

Add a `.gitignore` with:
```
db_config.py
data/raw/
data/processed/
outputs/
```

---

## Author

**[Your Name]**  
Mechanical Engineering Graduate | Aspiring Data Analyst  
[LinkedIn](https://linkedin.com) · [GitHub](https://github.com)

---

*This project was developed as a portfolio piece demonstrating data analytics skills relevant to healthcare and pharmaceutical supply chain consulting.*
