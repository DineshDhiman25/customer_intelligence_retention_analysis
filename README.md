# Customer Intelligence & Retention Analytics

## Project Overview

This project analyzes customer purchasing behavior, retention patterns, and customer value using transactional e-commerce data.

The analysis focuses on identifying repeat customers, high-value customers, customer acquisition trends, customer inactivity, and customer segmentation.

The project is primarily SQL and Tableau focused, with Python used for minimal data preprocessing.

## Business Objective

The objective of this project is to answer key customer intelligence questions:

- How many customers actively purchase from the business?
- What percentage of customers make repeat purchases?
- Who are the highest-value customers?
- How does customer activity change over time?
- How many new customers are acquired each month?
- Which customers are inactive or at risk?
- How can customers be segmented based on purchasing behavior?
- What are the customer retention patterns across monthly cohorts?

## Dataset

The project uses the Online Retail dataset containing transactional e-commerce data.

The original dataset contained 541,909 transaction records.

After data cleaning and preprocessing, 392,692 valid customer transaction records were retained for analysis.

## Data Preprocessing

Python and Pandas were used for minimal data preprocessing.

The following cleaning steps were performed:

- Removed duplicate transaction records
- Removed transactions with missing Customer IDs
- Removed cancelled invoices
- Removed transactions with invalid quantity or unit price values
- Converted Customer ID into an integer format
- Created a Revenue field using Quantity × Unit Price
- Exported the cleaned dataset for SQL and Tableau analysis

## SQL Analysis

15 SQL business analysis queries were developed using MySQL.

The analysis includes:

- Dataset and customer KPI analysis
- Customer purchase behavior
- Repeat vs one-time customer analysis
- Customer percentage contribution
- Top customers by revenue
- Customer revenue contribution
- Monthly active customers
- Monthly customer acquisition
- Customer purchase frequency
- Customer recency analysis
- RFM customer metrics
- RFM scoring using NTILE
- Customer segmentation
- At-risk and inactive customer identification
- Monthly cohort retention analysis

Advanced SQL concepts used include:

- Common Table Expressions (CTEs)
- Window Functions
- NTILE
- CASE Statements
- Date Functions
- Conditional Classification
- Percentage Contribution Analysis
- Customer-Level Aggregation

## Tableau Dashboard

An interactive Customer Intelligence dashboard was developed in Tableau.
![alt text](<dasboard images/customer_rentention.png>)

The dashboard includes:

- Total Customers KPI
- Total Revenue KPI
- Total Orders KPI
- Repeat Customer Rate
- Repeat vs One-Time Customer Analysis
- Monthly Active Customer Trend
- New Customer Acquisition Trend
- Customer Segment Distribution
- Customer Status Analysis
- Top Customers by Revenue

## Tools & Technologies

- Python
- Pandas
- MySQL
- SQL
- Tableau
- Jupyter Notebook
- Git
- GitHub

## Project Structure

```text
customer-intelligence-retention-analytics/
│
├── data/
│   ├── Online Retail.xlsx
│   └── customer_transactions_cleaned.csv
│
├── notebooks/
│   └── customer_intelligence_analysis.ipynb
│
├── sql/
│   └── customer_intelligence_analysis.sql
│
├── tableau/
│
├── dashboard_images/
│
└── README.md
