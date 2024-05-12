library(shiny)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Discrete Distributions"),
  sidebarLayout(
    sidebarPanel(
      radioButtons("dist", "Select Distribution:",
                   choices = c("Bernoulli", "Binomial", "Poisson", "Geometric"),
                   inline = TRUE),
      conditionalPanel(
        condition = "input.dist == 'Bernoulli'",
        sliderInput("bern_p", "Probability of Success (p):", min = 0, max = 1, value = 0.5, step = 0.01)
      ),
      conditionalPanel(
        condition = "input.dist == 'Binomial'",
        sliderInput("bin_n", "Number of Trials (n):", min = 1, max = 50, value = 10),
        sliderInput("bin_p", "Probability of Success (p):", min = 0, max = 1, value = 0.5, step = 0.01)
      ),
      conditionalPanel(
        condition = "input.dist == 'Poisson'",
        sliderInput("pois_lambda", "Lambda (λ):", min = 0, max = 10, value = 2, step = 0.1)
      ),
      conditionalPanel(
        condition = "input.dist == 'Geometric'",
        sliderInput("geom_p", "Probability of Success (p):", min = 0, max = 1, value = 0.2, step = 0.01)
      ),
      uiOutput("x_range_slider")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("PMF Plot", plotOutput("pmf_plot")),
        tabPanel("CMF Plot", plotOutput("cmf_plot")),
        tabPanel("Table", tableOutput("table"))
      ),
      h4("Usage Instructions:"),
      tags$ol(
        tags$li("Select a distribution type using the radio buttons."),
        tags$li("Adjust the parameters of the selected distribution using the sliders."),
        tags$li("Use the 'Range of x' slider to control the range of the x-axis."),
        tags$li("Explore the PMF and CMF plots in their respective tabs."),
        tags$li("View the numerical values of the PMF and CMF in the 'Table' tab.")
      )
    )
  )
)

server <- function(input, output) {
  x_range_values <- reactive({
    if (input$dist == "Bernoulli") {
      list(min = 0, max = 1, value = 1)
    } else {
      list(min = 0, max = 50, value = 10)
    }
  })

  output$x_range_slider <- renderUI({
    sliderInput("x_range", "Range of x:", min = x_range_values()$min, max = x_range_values()$max, value = x_range_values()$value)
  })

  dist_data <- reactive({
    x <- 0:input$x_range
    if (input$dist == "Bernoulli") {
      data.frame(x = x,
                 pmf = dbinom(x, 1, input$bern_p),
                 cmf = pbinom(x, 1, input$bern_p))
    } else if (input$dist == "Binomial") {
      data.frame(x = x,
                 pmf = dbinom(x, input$bin_n, input$bin_p),
                 cmf = pbinom(x, input$bin_n, input$bin_p))
    } else if (input$dist == "Poisson") {
      data.frame(x = x,
                 pmf = dpois(x, input$pois_lambda),
                 cmf = ppois(x, input$pois_lambda))
    } else if (input$dist == "Geometric") {
      data.frame(x = x,
                 pmf = dgeom(x, input$geom_p),
                 cmf = pgeom(x, input$geom_p))
    }
  })

  output$pmf_plot <- renderPlot({
    ggplot(dist_data(), aes(x = x, y = pmf)) +
      geom_bar(stat = "identity", fill = "steelblue") +
      labs(title = paste(input$dist, "Distribution - PMF"),
           x = "x", y = "Probability")
  })

  output$cmf_plot <- renderPlot({
    ggplot(dist_data(), aes(x = x, y = cmf)) +
      geom_step(color = "steelblue") +
      labs(title = paste(input$dist, "Distribution - CMF"),
           x = "x", y = "Cumulative Probability")
  })

  output$table <- renderTable({
    dist_data()
  })
}

shinyApp(ui, server)
