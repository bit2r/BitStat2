library(shiny)
library(ggplot2)
library(plotly)
library(DT)
library(broom)
library(showtext)
showtext_auto()

# UI 정의
ui <- shiny::tagList(
  withMathJax(),
  titlePanel(
    title = "선형 회귀분석",
    windowTitle = "단순 선형 회귀분석"
  ),
  fluidPage(
    theme = shinythemes::shinytheme("flatly"),
    sidebarLayout(
      sidebarPanel(
        radioButtons("data_type", "데이터 입력 방식:",
                     c("직접 입력" = "manual",
                       "CSV 업로드" = "csv"),
                     selected = "manual"),
        conditionalPanel(
          condition = "input.data_type == 'manual'",
          tags$b("데이터:"),
          textInput("x", "x", value = "90, 100, 90, 80, 87, 75, 85, 95, 78, 88", placeholder = "쉼표로 구분된 값을 입력하세요. 소수점은 점(.)을 사용하세요. 예: 4.2, 4.4, 5, 5.03 등"),
          textInput("y", "y", value = "950, 1000, 850, 750, 950, 775, 800, 970, 770, 920", placeholder = "쉼표로 구분된 값을 입력하세요. 소수점은 점(.)을 사용하세요. 예: 4.2, 4.4, 5, 5.03 등")
        ),
        conditionalPanel(
          condition = "input.data_type == 'csv'",
          fileInput("file", "CSV 파일 업로드", accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
          selectInput("x_var", "X 변수 선택:", ""),
          selectInput("y_var", "Y 변수 선택:", "")
        ),
        hr(),
        tags$b("그래프:"),
        checkboxInput("se", "회귀선 주변에 신뢰구간 추가", TRUE),
        textInput("xlab", label = "축 레이블:", value = "x", placeholder = "x 레이블"),
        textInput("ylab", label = NULL, value = "y", placeholder = "y 레이블"),
        hr(),
        tags$div(
          tags$span(property = "cc:attributionName", "RShiny@UCLouvain"), " 코드를 참조하여 개발되었습니다.",
          tags$a(href = "http://creativecommons.org/licenses/by/2.0/be/", target = "_blank", "Creative Commons Attribution 2.0 Belgium license"),
          tags$img(alt = "Licence Creative Commons", style = "border-width:0", src = "http://i.creativecommons.org/l/by/2.0/be/80x15.png")
        ),
      ),
      mainPanel(
        tabsetPanel(
          tabPanel("데이터",
                   br(),
                   DT::dataTableOutput("tbl"),
                   br(),
                   uiOutput("data")
          ),
          tabPanel("손으로 계산",
                   br(),
                   uiOutput("by_hand")
          ),
          tabPanel("R 계산 및 해석",
                   br(),
                   h4("회귀 모형 요약"),
                   verbatimTextOutput("summary"),
                   br(),
                   h4("모형 요약"),
                   DT::dataTableOutput("model_table"),
                   h4("회귀 계수"),
                   DT::dataTableOutput("coef_table"),
                   h4("해석"),
                   uiOutput("interpretation")
          ),
          tabPanel("회귀 그래프",
                   br(),
                   uiOutput("results"),
                   plotlyOutput("plot")
          ),
          tabPanel("가정",
                   br(),
                   plotOutput("assumptions")
          )
        )
      )
    )
  )
)

# 서버 로직 정의
server <- function(input, output, session) {
  data <- reactive({
    if (input$data_type == "manual") {
      x <- extract(input$x)
      y <- extract(input$y)
      data.frame(x, y)
    } else {
      req(input$file)
      read.csv(input$file$datapath, header = TRUE)
    }
  })

  observe({
    if (input$data_type == "csv") {
      updateSelectInput(session, "x_var", choices = names(data()))
      updateSelectInput(session, "y_var", choices = names(data()))
    }
  })

  extract <- function(text) {
    text <- gsub(" ", "", text)
    split <- strsplit(text, ",", fixed = FALSE)[[1]]
    as.numeric(split)
  }

  # 데이터 출력
  output$tbl <- DT::renderDataTable({
    DT::datatable(data(),
                  extensions = "Buttons",
                  options = list(
                    lengthChange = FALSE,
                    dom = "Blfrtip",
                    buttons = c("copy", "csv", "excel", "pdf", "print")
                  )
    )
  })

  output$data <- renderUI({
    req(data())
    x <- data()[[ifelse(input$data_type == "manual", "x", input$x_var)]]
    y <- data()[[ifelse(input$data_type == "manual", "y", input$y_var)]]
    if (anyNA(x) | length(x) < 2 | anyNA(y) | length(y) < 2) {
      "잘못된 입력이거나 관측치가 충분하지 않습니다."
    } else if (length(x) != length(y)) {
      "x와 y의 관측치 수는 동일해야 합니다."
    } else {
      withMathJax(
        paste0("\\(\\bar{x} =\\) ", round(mean(x), 3)),
        br(),
        paste0("\\(\\bar{y} =\\) ", round(mean(y), 3)),
        br(),
        paste0("\\(n =\\) ", length(x))
      )
    }
  })

  output$by_hand <- renderUI({
    req(data())
    x <- data()[[ifelse(input$data_type == "manual", "x", input$x_var)]]
    y <- data()[[ifelse(input$data_type == "manual", "y", input$y_var)]]
    fit <- lm(y ~ x)
    withMathJax(
      paste0("\\(\\hat{\\beta}_1 = \\dfrac{\\big(\\sum^n_{i = 1} x_i y_i \\big) - n \\bar{x} \\bar{y}}{\\sum^n_{i = 1} (x_i - \\bar{x})^2} = \\) ", round(fit$coef[[2]], 3)),
      br(),
      paste0("\\(\\hat{\\beta}_0 = \\bar{y} - \\hat{\\beta}_1 \\bar{x} = \\) ", round(fit$coef[[1]], 3)),
      br(),
      br(),
      paste0("\\( \\Rightarrow y = \\hat{\\beta}_0 + \\hat{\\beta}_1 x = \\) ", round(fit$coef[[1]], 3), " + ", round(fit$coef[[2]], 3), "\\( x \\)")
    )
  })

  output$summary <- renderPrint({
    req(data())
    x <- data()[[ifelse(input$data_type == "manual", "x", input$x_var)]]
    y <- data()[[ifelse(input$data_type == "manual", "y", input$y_var)]]
    fit <- lm(y ~ x)
    summary(fit)
  })

  output$model_table <- DT::renderDataTable({
    req(data())
    x <- data()[[ifelse(input$data_type == "manual", "x", input$x_var)]]
    y <- data()[[ifelse(input$data_type == "manual", "y", input$y_var)]]
    fit <- lm(y ~ x)
    ## 모형요약
    model_df <- broom::glance(fit) |>
      mutate(across(where(is.numeric), ~ round(.x, digits = 1)))
    DT::datatable(model_df,
                  options = list(
                    lengthChange = FALSE,
                    dom = "t",
                    scrollX = TRUE
                  ),
                  rownames = FALSE)
  })

  output$coef_table <- DT::renderDataTable({
    req(data())
    x <- data()[[ifelse(input$data_type == "manual", "x", input$x_var)]]
    y <- data()[[ifelse(input$data_type == "manual", "y", input$y_var)]]
    fit <- lm(y ~ x)
    ## 계수
    coef_df <- broom::tidy(fit, conf.int = TRUE) |>
      mutate(across(where(is.numeric), ~ round(.x, digits = 1)))
    names(coef_df) <- c("항", "추정치", "표준오차", "t 값", "P-값", "2.5% 신뢰구간", "97.5% 신뢰구간")
    DT::datatable(coef_df,
                  options = list(
                    lengthChange = FALSE,
                    dom = "t",
                    scrollX = TRUE
                  ),
                  rownames = FALSE)
  })

  output$results <- renderUI({
    req(data())
    x <- data()[[ifelse(input$data_type == "manual", "x", input$x_var)]]
    y <- data()[[ifelse(input$data_type == "manual", "y", input$y_var)]]
    fit <- lm(y ~ x)
    withMathJax(
      paste0(
        "수정된 \\( R^2 = \\) ", round(summary(fit)$adj.r.squared, 3),
        ", \\( \\beta_0 = \\) ", round(fit$coef[[1]], 3),
        ", \\( \\beta_1 = \\) ", round(fit$coef[[2]], 3),
        ", P-값 ", "\\( = \\) ", signif(summary(fit)$coef[2, 4], 3)
      )
    )
  })

  output$interpretation <- renderUI({
    req(data())
    x <- data()[[ifelse(input$data_type == "manual", "x", input$x_var)]]
    y <- data()[[ifelse(input$data_type == "manual", "y", input$y_var)]]
    fit <- lm(y ~ x)
    if (summary(fit)$coefficients[1, 4] < 0.05 & summary(fit)$coefficients[2, 4] < 0.05) {
      withMathJax(
        paste0("해석: (계수를 해석하기 전에 선형 회귀분석의 가정(독립성, 선형성, 동분산성, 이상치 및 정규성)이 충족되는지 확인하세요.)"),
        br(),
        br(),
        paste0(input$xlab, "의 (가상의) 값이 0일 때, ", input$ylab, "의 평균은 ", round(fit$coef[[1]], 3), "입니다."),
        br(),
        br(),
        paste0(input$xlab, "이 한 단위 증가할 때, ", input$ylab, ifelse(round(fit$coef[[2]], 3) >= 0, "은 (평균적으로) ", "은 (평균적으로) "), abs(round(fit$coef[[2]], 3)), ifelse(round(fit$coef[[2]], 3) >= 0, " 단위 증가합니다.", " 단위 감소합니다.")),
        br(),
        br(),
        paste0("회귀모형의 적합도(수정된 \\(R^2\\))는 ", round(summary(fit)$adj.r.squared, 3), "으로, ", input$xlab, "에 의해 ", input$ylab, "의 변동이 ", round(summary(fit)$adj.r.squared * 100, 1), "%만큼 설명됩니다.")
      )
    } else if (summary(fit)$coefficients[1, 4] < 0.05 & summary(fit)$coefficients[2, 4] >= 0.05) {
      withMathJax(
        paste0("해석: (계수를 해석하기 전에 선형 회귀분석의 가정(독립성, 선형성, 동분산성, 이상치 및 정규성)이 충족되는지 확인하세요.)"),
        br(),
        br(),
        paste0(input$xlab, "의 (가상의) 값이 0일 때, ", input$ylab, "의 평균은 ", round(fit$coef[[1]], 3), "입니다."),
        br(),
        br(),
        paste0("\\( \\beta_1 \\)", "은 0과 유의미하게 다르지 않습니다 (p-값 = ", round(summary(fit)$coefficients[2, 4], 3), "). 따라서 ", input$xlab, "과 ", input$ylab, " 사이에 유의미한 관계가 없습니다.")
      )
    } else if (summary(fit)$coefficients[1, 4] >= 0.05 & summary(fit)$coefficients[2, 4] < 0.05) {
      withMathJax(
        paste0("해석: (계수를 해석하기 전에 선형 회귀분석의 가정(독립성, 선형성, 동분산성, 이상치 및 정규성)이 충족되는지 확인하세요.)"),
        br(),
        br(),
        paste0("\\( \\beta_0 \\)", "은 0과 유의미하게 다르지 않습니다 (p-값 = ", round(summary(fit)$coefficients[1, 4], 3), "). 따라서 ", input$xlab, "이 0일 때, ", input$ylab, "의 평균은 0과 유의미하게 다르지 않습니다."),
        br(),
        br(),
        paste0(input$xlab, "이 한 단위 증가할 때, ", input$ylab, ifelse(round(fit$coef[[2]], 3) >= 0, "은 (평균적으로) ", "은 (평균적으로) "), abs(round(fit$coef[[2]], 3)), ifelse(round(fit$coef[[2]], 3) >= 0, " 단위 증가합니다.", " 단위 감소합니다.")),
        br(),
        br(),
        paste0("회귀모형의 적합도(수정된 \\(R^2\\))는 ", round(summary(fit)$adj.r.squared, 3), "으로, ", input$xlab, "에 의해 ", input$ylab, "의 변동이 ", round(summary(fit)$adj.r.squared * 100, 1), "%만큼 설명됩니다.")
      )
    } else {
      withMathJax(
        paste0("해석: (계수를 해석하기 전에 선형 회귀분석의 가정(독립성, 선형성, 동분산성, 이상치 및 정규성)이 충족되는지 확인하세요.)"),
        br(),
        br(),
        paste0("\\( \\beta_0 \\)", "과 ", "\\( \\beta_1 \\)", "은 0과 유의미하게 다르지 않습니다 (p-값 = ", round(summary(fit)$coefficients[1, 4], 3), "와 ", round(summary(fit)$coefficients[2, 4], 3), "). 따라서 ", input$ylab, "의 평균은 0과 유의미하게 다르지 않습니다."),
        br(),
        br(),
        paste0("회귀모형의 적합도(수정된 \\(R^2\\))는 ", round(summary(fit)$adj.r.squared, 3), "으로, ", input$xlab, "과 ", input$ylab, " 사이에 유의미한 관계가 없습니다.")
      )
    }
  })

  output$assumptions <- renderPlot({
    req(data())
    x <- data()[[ifelse(input$data_type == "manual", "x", input$x_var)]]
    y <- data()[[ifelse(input$data_type == "manual", "y", input$y_var)]]
    fit <- lm(y ~ x)
    par(mfrow = c(2, 2))
    plot(fit, which = c(1:3, 5))
  })

  output$plot <- renderPlotly({
    req(data())
    x <- data()[[ifelse(input$data_type == "manual", "x", input$x_var)]]
    y <- data()[[ifelse(input$data_type == "manual", "y", input$y_var)]]
    fit <- lm(y ~ x)
    dat <- data.frame(x, y)
    p <- ggplot(dat, aes(x = x, y = y)) +
      geom_point() +
      stat_smooth(method = "lm", se = input$se) +
      ylab(input$ylab) +
      xlab(input$xlab) +
      theme_minimal()
    ggplotly(p)
  })

}

# 애플리케이션 실행
shinyApp(ui = ui, server = server)
