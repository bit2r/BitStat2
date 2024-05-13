library(shiny)
library(ggplot2)

# 내장 데이터셋 리스트 (iris 제외)
datasets <- c("mtcars", "faithful", "ChickWeight")

# UI 정의
ui <- fluidPage(
  titlePanel("단변량 기술통계"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "CSV 파일 업로드", accept = ".csv"),
      radioButtons("dataset", "데이터셋 선택", choices = c("Uploaded Dataset", datasets)),
      uiOutput("variableInput"),
      verbatimTextOutput("variableType")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("시각화",
                 fluidRow(
                   column(6, plotOutput("plot1")),
                   column(6, plotOutput("plot2"))
                 )
        ),
        tabPanel("요약 통계", verbatimTextOutput("summary"))
      )
    )
  )
)

# 서버 로직
server <- function(input, output, session) {
  # 업로드된 CSV 파일을 데이터프레임으로 변환
  uploaded_data <- reactive({
    req(input$file)
    read.csv(input$file$datapath)
  })

  # 선택된 데이터셋
  selected_data <- reactive({
    if (input$dataset == "Uploaded Dataset") {
      req(input$file)
      uploaded_data()
    } else {
      get(input$dataset)
    }
  })

  # 선택된 변수
  selected_variable <- reactive({
    req(input$variable)
    input$variable
  })

  # 변수 선택 UI 생성
  output$variableInput <- renderUI({
    selectInput("variable", "변수 선택", choices = names(selected_data()))
  })

  # 변수 유형 출력
  output$variableType <- renderPrint({
    variable <- selected_variable()
    data <- selected_data()

    if (is.numeric(data[[variable]])) {
      "선택된 변수는 연속형 변수입니다."
    } else {
      "선택된 변수는 범주형 변수입니다."
    }
  })

  # 요약 통계 출력
  output$summary <- renderPrint({
    data <- selected_data()
    variable <- selected_variable()

    if (is.numeric(data[[variable]])) {
      # 연속형 변수의 경우
      summary_stats <- summary(data[[variable]])
      names(summary_stats) <- c("최솟값", "1분위수", "중앙값", "평균", "3분위수", "최댓값")
      cat("요약 통계:\n")
      print(summary_stats)
      cat("\n")
      cat("결측값 개수:", sum(is.na(data[[variable]])), "\n")
    } else {
      # 범주형 변수의 경우
      freq_table <- table(data[[variable]])
      prop_table <- prop.table(freq_table)
      cat("범주별 빈도와 비율:\n")
      print(cbind(freq_table, round(prop_table, 4)))
      cat("\n")
      cat("결측값 개수:", sum(is.na(data[[variable]])), "\n")
    }
  })

  # 시각화 출력 - 연속형 변수
  output$plot1 <- renderPlot({
    data <- selected_data()
    variable <- selected_variable()

    if (is.numeric(data[[variable]])) {
      # Boxplot + Dot
      ggplot(data, aes(x = factor(0), y = .data[[variable]])) +
        geom_boxplot(fill = "lightblue", color = "black", outlier.shape = 16, outlier.size = 2) +
        geom_point(position = position_jitter(width = 0.1), size = 2, alpha = 0.6) +
        labs(title = "Boxplot + Dot", x = "", y = variable) +
        theme_minimal()
    } else {
      # 범주형 변수의 경우 - 막대 그래프
      ggplot(data, aes(x = .data[[variable]])) +
        geom_bar(fill = "lightblue", color = "black") +
        labs(title = "Bar Plot", x = variable, y = "Count") +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    }
  })

  output$plot2 <- renderPlot({
    data <- selected_data()
    variable <- selected_variable()

    if (is.numeric(data[[variable]])) {
      # Density Plot + Histogram
      ggplot(data, aes(x = .data[[variable]])) +
        geom_density(fill = "lightblue", alpha = 0.6) +
        geom_histogram(aes(y = ..density..), color = "black", fill = "white", alpha = 0.6, bins = 30) +
        labs(title = "Density Plot + Histogram", x = variable, y = "Density") +
        theme_minimal()
    } else {
      # 범주형 변수의 경우 - 원 그래프
      ggplot(data, aes(x = "", fill = .data[[variable]])) +
        geom_bar(width = 1) +
        coord_polar("y", start = 0) +
        labs(title = "Pie Chart", fill = variable) +
        theme_void() +
        theme(legend.position = "bottom")
    }
  })


}

# 앱 실행
shinyApp(ui, server)
