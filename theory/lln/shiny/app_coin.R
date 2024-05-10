library(shiny)
library(shinyjs)

# UI 부분 정의
ui <- fluidPage(
  useShinyjs(),  # shinyjs 라이브러리 로드
  tags$head(
    tags$style(HTML("
      .red-circle { color: red; font-size: 30px; }
      .blue-circle { color: blue; font-size: 30px; }
    "))
  ),
  titlePanel("동전 던지기 모사"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("prob_heads", "앞면이 나올 확률 (%):",
                  min = 0, max = 100, value = 50),
      sliderInput("num_tosses", "동전 던지기 횟수 선택:",
                  min = 1, max = 20, value = 3),
      actionButton("toss_button", "동전 던지기 시작"),
      hr(),
      tags$h3("색상 표시:"),
      tags$p(HTML("<span class='red-circle'>&#x2B24;</span> 앞면 (빨간색)&nbsp;&nbsp;&nbsp;<span class='blue-circle'>&#x2B24;</span> 뒷면 (파란색)")),
      helpText("이 앱은 동전을 1회에서 20회까지 던져서 결과를 보여줍니다. 슬라이더를 조절하여 원하는 횟수만큼 동전을 던지고, 앞면이 나올 확률을 설정하세요. 각 동전 던지기는 설정한 확률에 따라 앞면과 뒷면이 나옵니다.")
    ),
    mainPanel(
      htmlOutput("coin_display"),  # HTML 출력 요소 추가
      textOutput("result")
    )
  )
)

# 서버 로직 정의
server <- function(input, output, session) {
  observeEvent(input$toss_button, {
    # 설정된 횟수만큼 동전을 던진다
    prob_heads <- input$prob_heads / 100  # 확률을 백분율에서 0-1 사이 값으로 변환
    results <- sample(c("red", "blue"), input$num_tosses, replace = TRUE, prob = c(prob_heads, 1 - prob_heads))
    coin_results <- paste0("<span class='", ifelse(results == "red", "red-circle", "blue-circle"), "'>&#x2B24;</span>")
    coin_results <- paste(coin_results, collapse = " ")
    output$coin_display <- renderUI({
      HTML(coin_results)
    })
    # 결과 통계 계산
    num_heads <- sum(results == "red")
    num_tails <- input$num_tosses - num_heads
    output$result <- renderText({
      paste("앞면 (빨간색):", num_heads, "번 / 뒷면 (파란색):", num_tails, "번")
    })
  })
}

# Shiny 앱 실행
shinyApp(ui = ui, server = server)
