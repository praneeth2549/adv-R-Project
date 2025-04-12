library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(dplyr)
library(forcats)

# UI ---------------------------------------------------------------------------
ui <- dashboardPage(
  dashboardHeader(title = "IPL Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Match Predictor", tabName = "predictor", icon = icon("robot")),
      menuItem("Match Insights", tabName = "match_insights", icon = icon("chart-bar")),
      menuItem("Ball-by-Ball Analysis", tabName = "ball_analysis", icon = icon("baseball")),
      menuItem("Player Stats", tabName = "player_stats", icon = icon("users")),
      menuItem("Data Tables", tabName = "data_tables", icon = icon("table"))
    )
  ),
  
  dashboardBody(
    tabItem(
      tabName = "predictor",
      fluidRow(
        box(title = "Match Prediction Inputs", width = 4, solidHeader = TRUE, status = "primary",
            selectInput("team1", "Select Team 1", choices = unique(c(match_info$team1, match_info$team2))),
            selectInput("team2", "Select Team 2", choices = unique(c(match_info$team1, match_info$team2))),
            selectInput("venue", "Select Venue", choices = unique(match_info$venue)),
            selectInput("toss_winner", "Toss Winner", choices = unique(match_info$toss_winner)),
            selectInput("toss_decision", "Toss Decision", choices = c("bat", "field")),
            actionButton("predict", "Predict Winner", icon = icon("magic"))
        ),
        box(title = "Prediction Result", width = 8, solidHeader = TRUE, status = "success",
            verbatimTextOutput("predictionResult"))
      )
    ),
    tabItems(
      tabItem(
        tabName = "match_insights",
        fluidRow(
          box(title = "Total Wins by Team", width = 6, solidHeader = TRUE, status = "primary",
              plotOutput("winPlot")),
          box(title = "Impact of Toss on Winning", width = 6, solidHeader = TRUE, status = "primary",
              plotOutput("tossImpactPlot"))
        ),
        fluidRow(
          box(title = "Toss Decision Distribution", width = 12, solidHeader = TRUE, status = "info",
              plotOutput("tossDecisionPlot"))
        )
      ),
      tabItem(
        tabName = "ball_analysis",
        fluidRow(
          box(title = "Top 10 Batsmen by Total Runs", width = 6, solidHeader = TRUE, status = "success",
              plotOutput("topRunsPlot")),
          box(title = "Total Extras by Year", width = 6, solidHeader = TRUE, status = "success",
              plotOutput("extrasPlot"))
        )
      ),
      tabItem(
        tabName = "player_stats",
        fluidRow(
          box(title = "Top 10 Wicket Takers", width = 6, solidHeader = TRUE, status = "warning",
              plotOutput("wicketsPlot")),
          box(title = "Top 10 Most Sixes in an Innings", width = 6, solidHeader = TRUE, status = "warning",
              plotOutput("sixesPlot"))
        )
      ),
      tabItem(
        tabName = "data_tables",
        fluidRow(
          box(title = "Match Info Table", width = 12, solidHeader = TRUE, status = "danger",
              DTOutput("matchTable"))
        )
      )
    )
  )
)

# Server -----------------------------------------------------------------------
server <- function(input, output) {
  output$predictionResult <- renderText({
    input$predict  # trigger
    
    req(input$team1, input$team2, input$toss_winner, input$toss_decision)
    
    isolate({
      # Filter for past matches between the two teams
      head_to_head <- match_info %>%
        filter((team1 == input$team1 & team2 == input$team2) |
                 (team1 == input$team2 & team2 == input$team1))
      
      if (nrow(head_to_head) == 0) {
        return("No historical data available for this team matchup.")
      }
      
      # Filter based on toss winner and decision
      filtered <- head_to_head %>%
        filter(toss_winner == input$toss_winner, toss_decision == input$toss_decision)
      
      if (nrow(filtered) == 0) {
        return("No historical match data with the given toss winner and decision.")
      }
      
      # Count number of wins by each team
      win_counts <- filtered %>%
        filter(!is.na(winner)) %>%
        count(winner, sort = TRUE)
      
      predicted_winner <- win_counts$winner[1]
      
      paste("🏏 Based on historical data, the predicted winner is:", predicted_winner)
    })
  })
  
  output$winPlot <- renderPlot({
    match_info %>%
      filter(!is.na(winner)) %>%
      count(winner, sort = TRUE) %>%
      ggplot(aes(x = fct_reorder(winner, n), y = n)) +
      geom_col(fill = "steelblue") +
      coord_flip() +
      labs(title = "Total Wins by Team", x = "Team", y = "Wins")
  })
  
  output$tossImpactPlot <- renderPlot({
    match_info %>%
      mutate(toss_win_is_win = toss_winner == winner) %>%
      count(toss_win_is_win) %>%
      ggplot(aes(x = toss_win_is_win, y = n, fill = toss_win_is_win)) +
      geom_col() +
      labs(title = "Impact of Toss on Winning", x = "Toss Win = Match Win", y = "Count")
  })
  
  output$tossDecisionPlot <- renderPlot({
    match_info %>%
      count(toss_decision) %>%
      ggplot(aes(x = toss_decision, y = n, fill = toss_decision)) +
      geom_col() +
      labs(title = "Toss Decision Distribution", x = "Decision", y = "Count")
  })
  
  output$topRunsPlot <- renderPlot({
    combined_data %>%
      filter(!is.na(striker)) %>%
      group_by(striker) %>%
      summarise(total_runs = sum(runs_off_bat, na.rm = TRUE)) %>%
      arrange(desc(total_runs)) %>%
      head(10) %>%
      ggplot(aes(x = reorder(striker, total_runs), y = total_runs)) +
      geom_col(fill = "tomato") +
      coord_flip() +
      labs(title = "Top 10 Batsmen by Total Runs", x = "Batsman", y = "Runs")
  })
  
  output$extrasPlot <- renderPlot({
    combined_data %>%
      mutate(
        year = lubridate::year(date),
        extras = coalesce(wides, 0) + coalesce(noballs, 0) + coalesce(byes, 0) + coalesce(legbyes, 0) + coalesce(penalty, 0)
      ) %>%
      group_by(year) %>%
      summarise(total_extras = sum(extras, na.rm = TRUE)) %>%
      ggplot(aes(x = year, y = total_extras)) +
      geom_line(color = "purple", linewidth = 1.2) +
      labs(title = "Total Extras by Year", x = "Year", y = "Extras")
  })
  
  output$wicketsPlot <- renderPlot({
    most_wickets %>%
      group_by(Player) %>%
      summarise(Wkts = sum(Wkts, na.rm = TRUE)) %>%           
      ungroup() %>%
      slice_max(Wkts, n = 10) %>%
      mutate(Player = factor(Player, levels = unique(Player))) %>%
      ggplot(aes(x = Player, y = Wkts)) +
      geom_col(fill = "darkgreen") +
      coord_flip() +
      labs(title = "Top 10 Wicket Takers", x = "Player", y = "Wkts")
  })
  
  output$sixesPlot <- renderPlot({
    sixes %>%
      group_by(Player) %>%
      summarise(Max_Sixes = max(X6s, na.rm = TRUE)) %>%
      ungroup() %>%
      slice_max(Max_Sixes, n = 10) %>%
      mutate(Player = factor(Player, levels = unique(Player))) %>%
      ggplot(aes(x = Player, y = Max_Sixes)) +
      geom_col(fill = "darkred") +
      coord_flip() +
      labs(title = "Top 10 Most Sixes in a Single Innings", x = "Player", y = "Sixes")
  })
  
  output$matchTable <- renderDT({
    datatable(match_info, options = list(scrollX = TRUE))
  })
}

# Run --------------------------------------------------------------------------
shinyApp(ui, server)