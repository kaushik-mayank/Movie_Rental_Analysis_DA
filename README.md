# Movie Rental Analytics Project

[![SQL](https://img.shields.io/badge/SQL-339933?style=flat&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=flat&logo=microsoft-power-bi&logoColor=white)](https://powerbi.microsoft.com/)
[![Excel](https://img.shields.io/badge/Excel-217346?style=flat&logo=microsoft-excel&logoColor=white)](https://www.microsoft.com/en-us/microsoft-365/excel)

---

## Introduction

This project analyzes a **Movie Rental Database** using **SQL**, **Excel**, and **Power BI**.  
The aim was to understand **customer behavior, film inventory, staff efficiency, and store performance**, and present actionable insights through a **dynamic dashboard**.

---

## Project Demo
[![Watch the video](path/to/thumbnail.jpg)](https://drive.google.com/file/d/1R-QlMHpdKjwqgw4LrdKoKZ3Po9vLUpLJ/view?usp=sharing)

## Project Workflow

### 1 Data Extraction & Cleaning (SQL)

* Queried multiple tables: Customers, Films, Rentals, Payments, Staff, Stores
* Merged related tables (customer → address → city → country)
* Removed duplicates and handled missing values
* Created **fact and dimension tables** to support a star schema

### 2 Exploratory Data Analysis (EDA)

* Answered 15+ business questions: customer loyalty, seasonal trends, film demand, staff impact
* Exported results to **Excel** for visualization and trend analysis
* Used charts instead of raw tables for better clarity

### 3 Dashboard Building in Power BI

#### Data Model

* Designed a **Star Schema**:
  * **Fact Tables:** Rentals, Payments  
  * **Dimension Tables:** Customers, Staff, Stores, Films, Dates  
* Merged lookup tables (address, city, country, category, language) into dimension tables
* Simplified relationships to improve **DAX performance**

#### Key Measures (DAX)

* `Total Revenue` → SUM of payments  
* `Total Rentals` → COUNT of rentals  
* `On-Time Return %` → ratio of rentals returned before due date  
* `Revenue per Customer` → AVG revenue per unique customer  
* `Rentals per Copy` → inventory efficiency  

#### Dashboard Pages

1. **Executive Overview** – KPIs, Revenue Trends  
2. **Customers & Segments** – RFM Segmentation, Top Customers  
3. **Films & Inventory** – Rentals by Category, Film × Store Matrix  
4. **Staff & Store Performance** – Staff Efficiency, Revenue by Store  
5. **Recommendations** – Summary of insights with action points  

#### Visual Design

* Consistent **color theme** (green = growth, red = issues, yellow = neutral)  
* Applied **slicers** for time, store, category  
* Storytelling layout: KPIs at top → Trends → Detailed tables

---

## Challenges in Power BI

* Many-to-many relationships (films ↔ categories, films ↔ actors)  
* Custom time intelligence using `dim_date` table  
* Ratio measures (rentals per copy, on-time %)  
* Avoiding cluttered visuals  
* Balancing **business readability with technical accuracy**

---

## EDA Key Insights

### Customer Behavior

* Repeat customers drive higher revenue  
* Younger customers prefer family/animation films  
* 30–40 age group prefers drama and action  

### Films & Inventory

* Action and Animation are most in-demand  
* English films dominate, regional preferences exist  
* Popular categories face stock shortages  

### Staff & Store Performance

* Staff efficiency correlates with customer ratings  
* Stores near customers have 2.5× higher rental frequency  
* Evenings & weekends are peak rental times  

### Seasonal & Regional Trends

* Rentals peak in **summer holidays** and **December**  
* Romance films popular in Europe, Action in the US  
* Cultural events influence viewing behavior  

---

## Conclusion & Learnings

* Applied **MECE framework** for structured analysis  
* Built **end-to-end workflow:** SQL → Excel → Power BI  
* Dashboard highlights trends in revenue, loyalty, inventory, and operations  
* Improved **SQL, DAX, Power BI, and storytelling skills**  

 Data was converted into a **clear business story** that decision-makers can act on.

---

## Author  

**Mayank Kaushik**  
📧 Email: dksmayank03@gmail.com  
🌐 [LinkedIn](https://www.linkedin.com/in/mayank-kaushik-880153262/)
