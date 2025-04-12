# adv-R-Project
# 🏏 IPL Match Outcome Prediction Dashboard

Welcome to our CS5610 Advanced R for Data Science final project! This repository features an interactive Shiny dashboard that predicts IPL match winners and provides analytical insights using historical data.

🔗 **Live App**: [https://advancerprojectiplwinpredictor.shinyapps.io/r_project_adv/](https://advancerprojectiplwinpredictor.shinyapps.io/r_project_adv/)

---

## 📊 Features

- **Match Predictor**: Predicts likely winner using historical matchups, venue, toss outcome, and toss decision.
- **Match Insights**: Visualizations of total wins by teams, toss decisions, and win-toss correlations.
- **Ball-by-Ball Analysis**: Shows trends in player performances and match extras.
- **Player Stats**: Displays top wicket takers and players with most sixes in an innings.
- **Data Table**: Explore raw match-level data in an interactive table.

---

## 🧠 Machine Learning

We used:
- **Random Forest**
- **XGBoost**

These models were trained on engineered features like:
- Home advantage
- Venue strength
- Team total runs and wickets
- Toss winner and decision

Model evaluation included confusion matrix and feature importance plots.

---

## 📁 Project Structure

- `app.R`: Full Shiny app code (UI + Server)
- `R_project_final.Rmd`: Detailed R Markdown report documenting the process
- `data/`: External CSV files uploaded both in github and drive
- `word document/`: knitted version of rmd file

---

## 📂 Datasets Used

- `ipl_match_info_data.csv`
- `ipl_match_ball_by_ball_data.csv`
- Player stats from multiple CSVs (Most Runs, Most Wickets, Sixes, etc.)
- Custom player-to-team mapping

Download full dataset here: [Google Drive Link](https://drive.google.com/drive/folders/1YxPej6-Ezt56-W0s_fwWssnFEGaHqCg4?usp=sharing)

---

## 🚀 How to Run Locally

1. Clone the repo
2. Place datasets in a `data/` folder
3. Run the app from RStudio:
```r
shiny::runApp("app.R")
