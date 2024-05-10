library(shiny)

ui <- fluidPage(
  titlePanel("대수의 법칙 - 동전 던지기"),

  sidebarLayout(
    sidebarPanel(
      sliderInput("n_trials", "시행 횟수:", min = 1, max = 1000, value = 100),
      sliderInput("n_coins", "동전 개수:", min = 1, max = 100, value = 1),
      actionButton("simulate", "동전 던지기 시작")
    ),

    mainPanel(
      plotOutput("coin_plot"),
      br(),
      p("이 앱은 동전 던지기 예시를 통해 대수의 법칙을 보여줍니다."),
      p("동전을 반복해서 던질 때, 시행 횟수가 늘어날수록 앞면이 나올 확률이 0.5에 가까워지는 것을 확인할 수 있습니다."),
      p("시행 횟수와 동전 개수를 조절하고 시뮬레이션을 시작해보세요!")
    )
  )
)

server <- function(input, output) {

  coin_flips <- reactiveValues(data = NULL)

  observeEvent(input$simulate, {
    coin_flips$data <- replicate(input$n_coins, {
      cumsum(sample(c(0, 1), input$n_trials, replace = TRUE)) / (1:input$n_trials)
    })
  })

  output$coin_plot <- renderPlot({
    if (!is.null(coin_flips$data)) {
      matplot(coin_flips$data, type = "l", lty = 1, col = rainbow(input$n_coins),
              xlab = "시행 횟수", ylab = "앞면 비율", main = "동전 던지기 모의실험",
              ylim = c(0, 1))
      abline(h = 0.5, lty = 2, col = "blue")
      legend("topright", legend = c("이론적 확률 (0.5)", paste0("동전 ", 1:input$n_coins)),
             lty = c(2, rep(1, input$n_coins)), col = c("red", rainbow(input$n_coins)))
    }
  })
}

shinyApp(ui, server)
