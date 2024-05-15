library(shiny)
library(ggplot2)
library(GGally)

# 내장 데이터셋 리스트 (iris 제외)
datasets <- c("mtcars", "faithful", "ChickWeight")

# UI 정의
ui <- fluidPage(
  titlePanel("2변량 이상 기술통계 분석"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "CSV 파일 업로드", accept = ".csv"),
      radioButtons("dataset", "데이터셋 선택", choices = c("Uploaded Dataset", datasets)),
      uiOutput("variableInput"),
      verbatimTextOutput("variableType")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("시각화", plotOutput("plot")),
        tabPanel("요약 통계",
                 verbatimTextOutput("summary"),
                 verbatimTextOutput("correlation"),
                 plotOutput("correlationPlot")
        )
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
    } else if (input$dataset != "") {
      get(input$dataset)
    } else {
      NULL
    }
  })

  # 변수 선택 UI 생성
  output$variableInput <- renderUI({
    data <- selected_data()
    if (!is.null(data)) {
      vars <- names(data)
      checkboxGroupInput("variables", "변수 선택", choices = vars)
    }
  })

  # 선택된 변수
  selected_vars <- reactive({
    input$variables
  })

  # 선택된 변수들의 타입 출력
  output$variableType <- renderPrint({
    data <- selected_data()
    if (!is.null(data) && !is.null(selected_vars())) {
      sapply(data[, selected_vars(), drop = FALSE], class)
    }
  })

  # 선택된 변수가 수치형 변수인지 확인
  is_numeric <- reactive({
    data <- selected_data()
    sapply(data[, selected_vars(), drop = FALSE], is.numeric)
  })

  # 요약 통계 출력
  output$summary <- renderPrint({
    req(selected_vars())
    data <- selected_data()
    vars <- selected_vars()
    num_vars <- is_numeric()

    if (length(vars) >= 2 && all(num_vars)) {
      summary(data[, vars, drop = FALSE])
    } else if (length(vars) == 2 && sum(num_vars) == 1) {
      summary(data[, vars, drop = FALSE])
    } else {
      "2개 이상의 변수를 선택해주세요."
    }
  })

  # 상관관계 출력
  output$correlation <- renderPrint({
    req(selected_vars())
    data <- selected_data()
    vars <- selected_vars()
    num_vars <- is_numeric()
    if (length(vars) >= 2 && all(num_vars)) {
      cor_matrix <- cor(data[, vars, drop = FALSE], use = "pairwise.complete.obs")
      print(cor_matrix)
    } else {
      "2개 이상의 수치형 변수를 선택해주세요."
    }
  })

  # 상관관계 히트맵 출력
  output$correlationPlot <- renderPlot({
    req(selected_vars())
    data <- selected_data()
    vars <- selected_vars()
    num_vars <- is_numeric()
    if (length(vars) >= 2 && all(num_vars)) {
      cor_matrix <- cor(data[, vars, drop = FALSE], use = "pairwise.complete.obs")
      ggplot(data = as.data.frame(as.table(cor_matrix)), aes(Var1, Var2, fill = Freq)) +
        geom_tile() +
        scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
        theme_minimal() +
        labs(title = "Correlation Heatmap", x = "", y = "")
    } else {
      plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(1, 1, "2개 이상의 수치형 변수를 선택해주세요.")
    }
  })

  # 시각화 출력
  output$plot <- renderPlot({
    req(selected_vars())
    data <- selected_data()
    vars <- selected_vars()
    num_vars <- is_numeric()
    if (length(vars) == 2 && sum(num_vars) == 2) {
      ggplot(data, aes_string(x = vars[1], y = vars[2])) +
        geom_point() +
        labs(title = "Scatter Plot", x = vars[1], y = vars[2]) +
        theme_minimal()
    } else if (length(vars) == 2 && sum(num_vars) == 1) {
      numeric_var <- vars[num_vars]
      factor_var <- vars[!num_vars]
      ggplot(data, aes_string(x = factor_var, y = numeric_var)) +
        geom_boxplot() +
        labs(title = "Box Plot", x = factor_var, y = numeric_var) +
        theme_minimal()
    } else if (length(vars) > 2 && all(num_vars)) {
      ggpairs(data[, vars, drop = FALSE], title = "Pair Plot")
    } else {
      plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
      text(1, 1, "2개 이상의 변수를 선택해주세요.")
    }
  })
}

# 앱 실행
shinyApp(ui, server)
