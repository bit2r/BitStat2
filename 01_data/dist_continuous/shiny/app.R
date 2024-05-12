library(shiny)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Continuous Distributions"),
  sidebarLayout(
    sidebarPanel(
      radioButtons("dist", "Select Distribution:",
                   choices = c("Uniform", "Normal", "Exponential", "Gamma", "Beta"),
                   inline = TRUE),
      conditionalPanel(
        condition = "input.dist == 'Uniform'",
        sliderInput("unif_min", "Minimum (a):", min = -10, max = 0, value = -1, step = 0.1),
        sliderInput("unif_max", "Maximum (b):", min = 0, max = 10, value = 1, step = 0.1)
      ),
      conditionalPanel(
        condition = "input.dist == 'Normal'",
        sliderInput("norm_mean", "Mean (μ):", min = -10, max = 10, value = 0, step = 0.1),
        sliderInput("norm_sd", "Standard Deviation (σ):", min = 0.1, max = 5, value = 1, step = 0.1),
        sliderInput("x_range_norm", "Range of x:", min = -10, max = 10, value = c(-5, 5), step = 0.1)
      ),
      conditionalPanel(
        condition = "input.dist == 'Exponential'",
        sliderInput("exp_rate", "Rate (λ):", min = 0.1, max = 5, value = 1, step = 0.1),
        sliderInput("x_range_exp", "Range of x:", min = 0, max = 10, value = c(0, 5), step = 0.1)
      ),
      conditionalPanel(
        condition = "input.dist == 'Gamma'",
        sliderInput("gamma_shape", "Shape (α):", min = 0.1, max = 5, value = 1, step = 0.1),
        sliderInput("gamma_rate", "Rate (β):", min = 0.1, max = 5, value = 1, step = 0.1),
        sliderInput("x_range_gamma", "Range of x:", min = 0, max = 10, value = c(0, 5), step = 0.1)
      ),
      conditionalPanel(
        condition = "input.dist == 'Beta'",
        sliderInput("beta_shape1", "Shape 1 (α):", min = 0.1, max = 5, value = 1, step = 0.1),
        sliderInput("beta_shape2", "Shape 2 (β):", min = 0.1, max = 5, value = 1, step = 0.1),
        sliderInput("x_range_beta", "Range of x:", min = 0, max = 1, value = c(0, 1), step = 0.01)
      )
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("PDF Plot", plotOutput("pdf_plot")),
        tabPanel("CDF Plot", plotOutput("cdf_plot"))
      ),
      h4("Usage Instructions:"),
      tags$ol(
        tags$li("Select a distribution type using the radio buttons."),
        tags$li("Adjust the parameters of the selected distribution using the sliders."),
        tags$li("Use the 'Range of x' slider to control the range of the x-axis."),
        tags$li("Explore the PDF and CDF plots in their respective tabs.")
      )
    )
  )
)

server <- function(input, output) {

  dist_data <- reactive({
    if (input$dist == "Uniform") {
      x <- seq(input$unif_min-1, input$unif_max+1, length.out = 500)
      data.frame(x = x, pdf = dunif(x, min = input$unif_min, max = input$unif_max),
                 cdf = punif(x, min = input$unif_min, max = input$unif_max))
    } else if (input$dist == "Normal") {
      x <- seq(input$x_range_norm[1], input$x_range_norm[2], length.out = 500)
      data.frame(x = x, pdf = dnorm(x, mean = input$norm_mean, sd = input$norm_sd),
                 cdf = pnorm(x, mean = input$norm_mean, sd = input$norm_sd))
    } else if (input$dist == "Exponential") {
      x <- seq(input$x_range_exp[1], input$x_range_exp[2], length.out = 500)
      data.frame(x = x, pdf = dexp(x, rate = input$exp_rate),
                 cdf = pexp(x, rate = input$exp_rate))
    } else if (input$dist == "Gamma") {
      x <- seq(input$x_range_gamma[1], input$x_range_gamma[2], length.out = 500)
      data.frame(x = x, pdf = dgamma(x, shape = input$gamma_shape, rate = input$gamma_rate),
                 cdf = pgamma(x, shape = input$gamma_shape, rate = input$gamma_rate))
    } else if (input$dist == "Beta") {
      x <- seq(input$x_range_beta[1], input$x_range_beta[2], length.out = 500)
      data.frame(x = x, pdf = dbeta(x, shape1 = input$beta_shape1, shape2 = input$beta_shape2),
                 cdf = pbeta(x, shape1 = input$beta_shape1, shape2 = input$beta_shape2))
    }
  })

  output$pdf_plot <- renderPlot({
    ggplot(dist_data(), aes(x = x, y = pdf)) +
      geom_line(color = "steelblue") +
      labs(title = paste(input$dist, "Distribution - PDF"),
           x = "x", y = "Density")
  })

  output$cdf_plot <- renderPlot({
    ggplot(dist_data(), aes(x = x, y = cdf)) +
      geom_line(color = "steelblue") +
      labs(title = paste(input$dist, "Distribution - CDF"),
           x = "x", y = "Cumulative Probability")
  })
}

shinyApp(ui, server)
