library(shiny)
library(ggplot2)

# Define the user interface for the application
ui <- fluidPage(
  titlePanel("Dynamic One-Sample t-Test Simulation"),

  sidebarLayout(
    sidebarPanel(
      numericInput("trueMean", "True Population Mean:", value = 20),
      numericInput("hypoMean", "Hypothesized Mean:", value = 21),
      numericInput("stdDev", "Population Standard Deviation:", value = 4, min = 1),
      sliderInput("sampleSize", "Sample Size:", min = 10, max = 50, value = 30),
      sliderInput("alpha", "Significance Level:", min = 0.01, max = 0.10, value = 0.05, step = 0.01),
      actionButton("runTest", "Run Test")
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Plot", plotOutput("plot")),
        tabPanel("Summary", verbatimTextOutput("summary"))
      )
    )
  )
)

# Define the server logic required to perform the t-test and create plots
server <- function(input, output) {

  observeEvent(input$runTest, {
    # Simulate data from a normal distribution
    set.seed(123)
    data <- rnorm(input$sampleSize, mean = input$trueMean, sd = input$stdDev)

    # Perform the t-test
    test <- t.test(data, mu = input$hypoMean)

    # Output the summary of the t-test
    output$summary <- renderText({
      capture.output(summary(test))
    })

    # Plot the histogram of the data with the hypothesized mean
    output$plot <- renderPlot({
      hist(data, breaks = 20, main = "Histogram of Sample Data",
           xlab = "Data", col = "lightblue", border = "white")
      abline(v = input$hypoMean, col = "red", lwd = 2, lty = 2)
      legend("topright", legend = paste("Hypothesized mean:", input$hypoMean),
             col = "red", lty = 2, lwd = 2)
    })
  })
}

# Run the application
shinyApp(ui = ui, server = server)
