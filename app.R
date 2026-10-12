# Household Water Leak and Usage Analyzer
# Run with: shiny::runApp("folder_containing_this_file")
# First install Shiny once: install.packages("shiny")

library(shiny)

default_usage <- c(420, 450, 430, 460, 440, 455, 470,
                   445, 460, 900, 435, 450, 480, 440)

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { background: #f2f7fc; color: #16324f; }
      .main-title { background: linear-gradient(110deg,#075985,#2563eb);
        color: white; padding: 22px; border-radius: 14px; margin-bottom: 18px; }
      .main-title h2 { margin-top: 0; font-weight: 700; }
      .panel { background: white; padding: 16px; border-radius: 12px;
        box-shadow: 0 2px 10px rgba(15,50,90,.08); margin-bottom: 15px; }
      .metric { background: #e4f2ff; border-left: 5px solid #1685d1;
        padding: 14px; border-radius: 8px; margin-bottom: 10px; min-height: 78px; }
      .metric strong { font-size: 22px; display: block; margin-top: 5px; }
      .warning { background: #fff0f0; border-left: 5px solid #dc2626;
        padding: 12px; border-radius: 8px; }
      .good { background: #eaf9ef; border-left: 5px solid #16a34a;
        padding: 12px; border-radius: 8px; }
      .btn-primary { background: #075985; border-color: #075985; }
    "))
  ),

  div(class = "main-title",
      h2("💧 Household Water Leak and Usage Analyzer"),
      p("Track consumption, flag unusual readings, and estimate your monthly water bill.")
  ),

  sidebarLayout(
    sidebarPanel(
      div(class = "panel",
          h4("Enter Daily Water Usage"),
          p("Enter the amount used each day in litres."),
          lapply(seq_len(14), function(i) {
            numericInput(paste0("day", i), paste("Day", i),
                         value = default_usage[i], min = 0, max = 100000, step = 1)
          }),
          numericInput("rate", "Water cost per kilolitre (Rs.)",
                       value = 30, min = 0, max = 100000, step = 1),
          actionButton("analyze", "Analyze Usage", class = "btn-primary"),
          actionButton("reset", "Reset Sample Data")
      ),
      width = 4
    ),

    mainPanel(
      div(class = "panel",
          h3("Analysis Results"),
          uiOutput("metrics"),
          h4("Leak Detection Report"),
          uiOutput("alerts"),
          plotOutput("usage_plot", height = "320px"),
          h4("Daily Usage Details"),
          tableOutput("usage_table")
      ),
      div(class = "panel",
          h4("💡 Water-Saving Suggestions"),
          tags$ul(
            tags$li("Repair leaking taps and pipes promptly."),
            tags$li("Check toilet flushes for hidden leaks."),
            tags$li("Turn off taps when not in use."),
            tags$li("Compare readings each day to spot unusual changes."),
            tags$li("Use water-efficient appliances where possible.")
          ),
          p(class = "text-muted",
            "A high reading is a warning to investigate, not proof of a leak. "
          )
      ),
      width = 8
    )
  ),
  tags$footer(
    style = "text-align:center;padding:18px;color:#52677c;",
    "Household Water Analyzer • Save Water, Save Future"
  )
)

server <- function(input, output, session) {

  observeEvent(input$reset, {
    for (i in seq_len(14)) {
      updateNumericInput(session, paste0("day", i), value = default_usage[i])
    }
    updateNumericInput(session, "rate", value = 30)
  })

  usage_data <- reactive({
    # Inputs are read live, so the results update when the user changes readings.
    usage <- vapply(seq_len(14), function(i) {
      value <- input[[paste0("day", i)]]
      if (is.null(value) || is.na(value)) 0 else max(0, value)
    }, numeric(1))
    list(days = seq_len(14), usage = usage)
  })

  results <- reactive({
    dat <- usage_data()
    usage <- dat$usage
    median_usage <- median(usage)
    threshold <- median_usage * 1.5
    high_days <- which(usage > threshold)
    avg <- mean(usage)
    monthly_litres <- avg * 30
    rate <- if (is.null(input$rate) || is.na(input$rate)) 0 else max(0, input$rate)
    list(
      usage = usage,
      total = sum(usage),
      average = avg,
      minimum = min(usage),
      maximum = max(usage),
      median = median_usage,
      threshold = threshold,
      high_days = high_days,
      monthly_litres = monthly_litres,
      monthly_kl = monthly_litres / 1000,
      monthly_cost = (monthly_litres / 1000) * rate
    )
  })

  output$metrics <- renderUI({
    r <- results()
    fluidRow(
      column(6, div(class = "metric", "Total Usage (14 days)",
                    strong(paste(format(round(r$total, 2), nsmall = 0), "litres")))),
      column(6, div(class = "metric", "Average Daily Usage",
                    strong(paste(round(r$average, 2), "litres")))),
      column(6, div(class = "metric", "Maximum Daily Usage",
                    strong(paste(round(r$maximum, 2), "litres")))),
      column(6, div(class = "metric", "Estimated Monthly Cost",
                    strong(paste0("Rs. ", format(round(r$monthly_cost, 2),
                                                 nsmall = 2, big.mark = ","))))
      )
    )
  })

  output$alerts <- renderUI({
    r <- results()
    if (length(r$high_days) > 0) {
      div(class = "warning",
          strong("Unusually high water usage detected."),
          p(paste("Threshold:", round(r$threshold, 2), "litres.")),
          tags$ul(lapply(r$high_days, function(d) {
            tags$li(paste("Check Day", d, "-", r$usage[d], "litres"))
          })),
          p("Inspect taps, pipes, and toilet flushes. This alert does not confirm a leak.")
      )
    } else {
      div(class = "good",
          strong("No unusually high readings detected using this threshold."),
          p("Continue monitoring daily consumption.")
      )
    }
  })

  output$usage_plot <- renderPlot({
    r <- results()
    bar_col <- ifelse(r$usage > r$threshold, "#ef4444", "#38a6f5")
    par(mar = c(5, 4.5, 3, 1))
    barplot(
      r$usage,
      names.arg = paste0("D", seq_along(r$usage)),
      col = bar_col,
      border = NA,
      main = "Daily Household Water Consumption",
      xlab = "Day",
      ylab = "Water Usage (Litres)"
    )
    abline(h = r$threshold, col = "#dc2626", lty = 2, lwd = 2)
    legend("topleft", legend = c("Normal reading", "Unusually high", "Threshold"),
           fill = c("#38a6f5", "#ef4444", NA),
           lty = c(NA, NA, 2), col = c(NA, NA, "#dc2626"),
           bty = "n", cex = 0.8)
  })

  output$usage_table <- renderTable({
    r <- results()
    data.frame(
      Day = seq_along(r$usage),
      `Water Usage (litres)` = r$usage,
      Status = ifelse(r$usage > r$threshold, "Check reading", "Within threshold"),
      check.names = FALSE
    )
  }, striped = TRUE, bordered = TRUE, hover = TRUE, digits = 2)
}

shinyApp(ui = ui, server = server)
