# E-commerce Funnel & Revenue Analytics

## Project Overview
This project is an SQL-first business analytics study on an e-commerce funnel.  
It focuses on user behavior, conversion rates, and revenue trends.

## Datasets
The project uses simulated e-commerce data generated using the faker python library:
- `users.csv`
- `sessions.csv`
- `events.csv`
- `orders.csv`
- `payments.csv`

## Funnel Analysis
- Tracks users from session → view → add to cart → checkout → purchase.
- Conversion percentages are calculated at each stage.

![Funnel Chart](./Tableau%20Visualizations/Ecom_funnel_conversion.png)

## Revenue Analysis
- Daily revenue trends:

![Daily Revenue](./Tableau%20Visualizations/Daily_revenue_trend.png)

- Top users by revenue:

![Top Users](./Tableau%20Visualizations/Top_10_users_by_revenue.png)

- Revenue by new vs returning users:

![Revenue by User Type](./Tableau%20Visualizations/New_vs_returning_users_revenue.png)

## SQL Queries
All queries used in this project are in the `sql/` folder.

## Key Insights
- Conversion drop-off is highest at the add-to-cart → checkout stage.  
- Returning users contribute more revenue than new users.  
- Revenue shows seasonal trends over time.
