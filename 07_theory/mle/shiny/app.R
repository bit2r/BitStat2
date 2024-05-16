library(shiny)
library(ggplot2)

ui <- fluidPage(
  titlePanel("최대우도추정 (MLE)"),
  sidebarLayout(
    sidebarPanel(
      h3("모수 추정"),
      p("주어진 데이터에 대해 최대우도추정(MLE)을 수행하여 모수를 추정합니다."),
      p("표본 크기와 실제 모수 값을 조절해보세요."),
      p("히스토그램은 생성된 데이터(표본 추출 데이터)를 나타냅니다."),
      p("파란색 점선은 최대우도추정을 통해 추정된 모수 값을, 오차 막대는 추정된 표준오차를 나타냅니다."),
      br(),
      h4("표본 추출"),
      sliderInput("sample_size", "표본 크기:", min = 10, max = 1000, value = 100),
      br()
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("정규분포",
                 h4("모집단(정규분포)"),
                 sliderInput("norm_mean", "실제 모평균:", min = 0, max = 10, value = 5, step = 0.1),
                 sliderInput("norm_sd", "실제 모표준편차:", min = 0.1, max = 5, value = 1, step = 0.1),
                 plotOutput("norm_plot"),
                 verbatimTextOutput("norm_result")
        ),
        tabPanel("포아송분포",
                 h4("모집단(포아송분포)"),
                 sliderInput("pois_lambda", "실제 모수 (λ):", min = 0.1, max = 10, value = 2, step = 0.1),
                 plotOutput("pois_plot"),
                 verbatimTextOutput("pois_result")
        ),
        tabPanel("이항분포",
                 h4("모집단(이항분포)"),
                 sliderInput("binom_size", "실제 모수 (n):", min = 1, max = 100, value = 10, step = 1),
                 sliderInput("binom_prob", "실제 모수 (p):", min = 0, max = 1, value = 0.5, step = 0.01),
                 plotOutput("binom_plot"),
                 verbatimTextOutput("binom_result")
        )
      )
    )
  )
)

server <- function(input, output) {
  norm_data <- reactive({
    req(input$sample_size, input$norm_mean, input$norm_sd)
    rnorm(input$sample_size, mean = input$norm_mean, sd = input$norm_sd)
  })

  norm_estimates <- reactive({
    list(
      mean = mean(norm_data()),
      sd = sd(norm_data()),
      se_mean = sd(norm_data()) / sqrt(input$sample_size),
      se_sd = sd(norm_data()) / sqrt(2 * input$sample_size)
    )
  })

  output$norm_plot <- renderPlot({
    ggplot(data.frame(x = norm_data()), aes(x)) +
      geom_histogram(aes(y = ..density..), bins = 30, fill = "lightblue", color = "white") +
      stat_function(fun = dnorm, args = list(mean = norm_estimates()$mean, sd = norm_estimates()$sd),
                    color = "red", size = 1.5) +
      geom_vline(xintercept = norm_estimates()$mean, linetype = "dashed", color = "blue", size = 1) +
      geom_errorbarh(aes(xmin = norm_estimates()$mean - norm_estimates()$se_mean,
                         xmax = norm_estimates()$mean + norm_estimates()$se_mean,
                         y = 0), color = "blue", height = 0.01, size = 1) +
      labs(title = "정규분포 MLE", x = "값", y = "밀도") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
  })

  output$norm_result <- renderText({
    paste0("MLE 추정결과:\n",
           "추정된 평균 = ", round(norm_estimates()$mean, 3), "\n",
           "추정된 표준편차 = ", round(norm_estimates()$sd, 3), "\n",
           "평균의 표준오차 = ", round(norm_estimates()$se_mean, 3), "\n",
           "표준편차의 표준오차 = ", round(norm_estimates()$se_sd, 3))
  })

  pois_data <- reactive({
    req(input$sample_size, input$pois_lambda)
    rpois(input$sample_size, lambda = input$pois_lambda)
  })

  pois_estimates <- reactive({
    list(
      lambda = mean(pois_data()),
      se_lambda = sqrt(mean(pois_data()) / input$sample_size)
    )
  })

  output$pois_plot <- renderPlot({
    ggplot(data.frame(x = pois_data()), aes(x, fill = "lightblue")) +
      geom_histogram(aes(y = ..count.. / sum(..count..)), bins = 30, color = "white") +
      geom_vline(xintercept = pois_estimates()$lambda, linetype = "dashed", color = "blue", size = 1) +
      geom_errorbarh(aes(xmin = pois_estimates()$lambda - pois_estimates()$se_lambda,
                         xmax = pois_estimates()$lambda + pois_estimates()$se_lambda,
                         y = 0), color = "blue", height = 0.01, size = 1) +
      labs(title = "포아송분포 MLE", x = "값", y = "확률") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
  })

  output$pois_result <- renderText({
    paste0("MLE 추정결과:\n",
           "추정된 λ = ", round(pois_estimates()$lambda, 3), "\n",
           "λ의 표준오차 = ", round(pois_estimates()$se_lambda, 3))
  })

  binom_data <- reactive({
    req(input$sample_size, input$binom_size, input$binom_prob)
    rbinom(input$sample_size, size = input$binom_size, prob = input$binom_prob)
  })

  binom_estimates <- reactive({
    list(
      prob = mean(binom_data()) / input$binom_size,
      se_prob = sqrt(mean(binom_data()) / input$binom_size * (1 - mean(binom_data()) / input$binom_size) / input$sample_size)
    )
  })

  output$binom_plot <- renderPlot({
    ggplot(data.frame(x = binom_data()), aes(x)) +
      geom_histogram(aes(y = ..count.. / sum(..count..)), bins = min(30, max(binom_data())), fill = "lightblue", color = "white") +
      geom_vline(xintercept = binom_estimates()$prob * input$binom_size, linetype = "dashed", color = "blue", size = 1) +
      geom_errorbarh(aes(xmin = (binom_estimates()$prob - binom_estimates()$se_prob) * input$binom_size,
                         xmax = (binom_estimates()$prob + binom_estimates()$se_prob) * input$binom_size,
                         y = 0), color = "blue", height = 0.01, size = 1) +
      labs(title = "이항분포 MLE", x = "값", y = "확률") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
  })

  output$binom_result <- renderText({
    paste0("MLE 추정결과:\n",
           "추정된 p = ", round(binom_estimates()$prob, 3), "\n",
           "p의 표준오차 = ", round(binom_estimates()$se_prob, 3))
  })
}

shinyApp(ui, server)
