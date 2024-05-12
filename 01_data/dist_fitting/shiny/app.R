library(ggplot2)
library(moments)
library(palmerpenguins)

ui <- fluidPage(
  titlePanel("Continuous Distribution Fitting"),
  sidebarLayout(
    sidebarPanel(
      radioButtons("data_source", "Select Data Source",
                   choices = c("Upload CSV", "penguins", "mtcars"),
                   inline = TRUE),
      conditionalPanel(
        condition = "input.data_source == 'Upload CSV'",
        fileInput("file", "Choose CSV File",
                  accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv"))
      ),
      selectInput("variable", "Select Variable", choices = NULL),
      radioButtons("distribution", "Select Distribution",
                   choices = c("Uniform", "Normal", "Exponential"))
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Summary", verbatimTextOutput("summary")),
        tabPanel("Histogram", plotOutput("histogram")),
        tabPanel("Q-Q Plot", plotOutput("qqplot")),
        tabPanel("CDF Plot", plotOutput("cdfplot"))
      ),
      h4("Usage Instructions:"),
      tags$ol(
        tags$li("Select a data source (Upload CSV, penguins, or mtcars)."),
        tags$li("If 'Upload CSV' is selected, choose a CSV file to upload."),
        tags$li("Select a continuous variable from the dropdown menu."),
        tags$li("Choose a distribution to fit (Uniform, Normal, or Exponential)."),
        tags$li("The fitting results will be automatically updated based on your selection."),
        tags$li("Explore the summary statistics, histogram, Q-Q plot, and CDF plot in the respective tabs.")
      )
    )
  )
)

server <- function(input, output, session) {
  data <- reactive({
    if (input$data_source == "Upload CSV") {
      req(input$file)
      read.csv(input$file$datapath)
    } else if (input$data_source == "penguins") {
      penguins[, c("bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g")]
    } else if (input$data_source == "mtcars") {
      mtcars[, c("mpg", "disp", "hp", "drat", "wt", "qsec")]
    }
  })

  observe({
    req(data())
    updateSelectInput(session, "variable", choices = names(data()))
  })

  variable <- reactive({
    req(input$variable)
    data()[[input$variable]]
  })

  fit_result <- reactive({
    req(input$distribution, variable())
    distribution <- tolower(input$distribution)

    if (distribution == "uniform") {
      min_val <- min(variable(), na.rm = TRUE)
      max_val <- max(variable(), na.rm = TRUE)
      test_result <- ks.test(variable(), "punif", min = min_val, max = max_val)
    } else if (distribution == "normal") {
      test_result <- shapiro.test(variable())
    } else if (distribution == "exponential") {
      rate_val <- 1/mean(variable(), na.rm = TRUE)
      test_result <- ks.test(variable(), "pexp", rate = rate_val)
    }

    list(
      distribution = distribution,
      test_result = test_result,
      params = switch(distribution,
                      "uniform" = list(min = min_val, max = max_val),
                      "normal" = list(mean = mean(variable(), na.rm = TRUE), sd = sd(variable(), na.rm = TRUE)),
                      "exponential" = list(rate = rate_val))
    )
  })

  output$summary <- renderPrint({
    req(fit_result())
    cat("Selected Distribution:", fit_result()$distribution, "\n\n")
    cat("Descriptive Statistics:\n")
    print(summary(variable()))
    cat("\nSkewness:", skewness(variable()), "\n")
    cat("Kurtosis:", kurtosis(variable()), "\n\n")

    if (fit_result()$distribution == "uniform") {
      cat("Kolmogorov-Smirnov Test for Uniform Distribution\n")
    } else if (fit_result()$distribution == "normal") {
      cat("Shapiro-Wilk Normality Test\n")
    } else if (fit_result()$distribution == "exponential") {
      cat("Kolmogorov-Smirnov Test for Exponential Distribution\n")
    }

    cat("p-value:", fit_result()$test_result$p.value, "\n")
  })

  output$histogram <- renderPlot({
    req(fit_result())
    distribution <- fit_result()$distribution
    params <- fit_result()$params
    ggplot(data.frame(x = variable()), aes(x)) +
      geom_histogram(aes(y = ..density..), bins = 30, color = "black", fill = "lightblue") +
      stat_function(fun = switch(distribution,
                                 "uniform" = dunif,
                                 "normal" = dnorm,
                                 "exponential" = dexp),
                    args = params,
                    color = "red", size = 1) +
      labs(title = "Histogram with Fitted Distribution",
           x = input$variable, y = "Density")
  })

  output$qqplot <- renderPlot({
    req(fit_result())
    distribution <- fit_result()$distribution
    params <- fit_result()$params
    ggplot(data.frame(x = variable()), aes(sample = x)) +
      stat_qq(distribution = switch(distribution,
                                    "uniform" = qunif,
                                    "normal" = qnorm,
                                    "exponential" = qexp),
              dparams = unlist(params),
              color = "blue") +
      stat_qq_line(distribution = switch(distribution,
                                         "uniform" = qunif,
                                         "normal" = qnorm,
                                         "exponential" = qexp),
                   dparams = unlist(params),
                   color = "red") +
      labs(title = paste("Q-Q Plot for", distribution),
           x = "Theoretical Quantiles", y = "Sample Quantiles")
  })

  output$cdfplot <- renderPlot({
    req(fit_result())
    distribution <- fit_result()$distribution
    params <- fit_result()$params
    ggplot(data.frame(x = variable()), aes(x)) +
      stat_ecdf(geom = "step", color = "blue", size = 1) +
      stat_function(fun = switch(distribution,
                                 "uniform" = punif,
                                 "normal" = pnorm,
                                 "exponential" = pexp),
                    args = unlist(params),
                    color = "red", size = 1) +
      labs(title = paste("Empirical and Theoretical CDF for", distribution),
           x = input$variable, y = "Cumulative Probability")
  })


}

shinyApp(ui, server)
