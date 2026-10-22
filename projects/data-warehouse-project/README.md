# Data Warehouse Project

Personal project: an end-to-end data warehouse built in SQL Server — source data staged, cleaned and transformed with T-SQL, and modelled into fact and dimension tables for analysis.

> **Status:** write-up in progress. Bracketed items to be completed with project specifics.

## Overview
- **Purpose:** [what questions the warehouse answers]
- **Source data:** [dataset(s), format, approximate size]
- **Stack:** SQL Server, SSMS, T-SQL

## Design
- Layered architecture: raw staging → cleaned → modelled (star schema)
- Fact table(s): [name + grain]
- Dimension table(s): [names]
- Schema diagram: see `docs/` [add diagram]

## Load process
1. [How source data lands in staging]
2. [Cleaning / transformation steps — SQL in `sql/`]
3. [How facts and dimensions are loaded/refreshed]

## Sample analysis
- [One or two example queries and what they show]

## What I learned
- [Key takeaways: modelling choices, data quality issues found, performance notes]
