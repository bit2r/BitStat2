library(shiny)
library(ggplot2)

# UI 정의
ui <- fluidPage(
  titlePanel("중심극한정리"),

  sidebarLayout(
    sidebarPanel(
      selectInput("distribution",
                  "분포 선택:",
                  choices = c("정규 분포" = "norm",
                              "지수 분포" = "exp",
                              "균등 분포" = "unif")),
      sliderInput("n",
                  "표본 크기:",
                  min = 10,
                  max = 100,
                  value = 30),
      sliderInput("num_samples",
                  "표본 수:",
                  min = 100,
                  max = 10000,
                  value = 1000),
      hr(),
      h3("중심극한정리 확인방법"),
      p("1. '분포 선택'에서 원하는 분포 유형(정규, 지수, 균등분포 중 하나)을 선택하세요. 선택된 분포에서 무작위 표본이 추출됩니다."),
      p("2. '표본 크기'와 '표본 수'를 조정하여 실험할 표본 크기와 표본 수를 결정하세요."),
      p("2-1. '표본 크기'는 각각의 표본에서 추출할 데이터 수를 결정합니다. 예를 들어, 100명의 학생 중 10명을 무작위로 선택하여 키를 측정한다면, 표본 크기는 10입니다."),
      p("2-2. '표본 수'는 실험에 사용될 전체 표본의 수를 결정합니다. 예를 들어, 100명의 학생 중 10명을 무작위로 선택하는 과정을 30번 반복한다면, 표본 수는 30입니다."),
      p("3. 왼쪽 그래프는 선택한 분포의 확률 밀도 함수(PDF)를 보여줍니다."),
      p("4. 오른쪽 그래프는 추출된 표본의 평균이 어떻게 정규 분포에 접근하는지를 보여줍니다. 이는 중심극한정리를 시각적으로 나타냅니다."),
      p("5. '표본 크기'와 '표본 수'를 변경하며 중심극한정리가 다양한 상황에서 어떻게 적용되는지 관찰하세요.")
    ),

    mainPanel(
      fluidRow(
        column(6, plotOutput("distPlot")),
        column(6, plotOutput("cltPlot"))
      )
    )
  )
)

# 서버 로직
server <- function(input, output) {
  output$cltPlot <- renderPlot({
    n <- input$n
    num_samples <- input$num_samples
    distribution <- input$distribution

    # 선택된 분포에 따라 무작위 표본 생성
    if (distribution == "norm") {
      samples <- matrix(rnorm(n * num_samples), nrow = n)
      mu <- 0
      sigma <- 1
    } else if (distribution == "exp") {
      samples <- matrix(rexp(n * num_samples, rate = 1), nrow = n)
      mu <- 1
      sigma <- 1
    } else if (distribution == "unif") {
      samples <- matrix(runif(n * num_samples), nrow = n)
      mu <- 0.5
      sigma <- sqrt(1/12)
    }

    # 각 표본의 평균 계산
    sample_means <- colMeans(samples)

    # 이론적 정규 분포 계산
    x_seq <- seq(min(sample_means), max(sample_means), length.out = 100)
    y_dnorm <- dnorm(x_seq, mean = mu, sd = sigma / sqrt(n))

    # ggplot을 사용한 시각화
    ggplot() +
      geom_histogram(aes(x = sample_means, y = ..density..), bins = 30, fill = "blue", alpha = 0.5) +
      geom_line(aes(x = x_seq, y = y_dnorm), color = "red") +
      ggtitle(paste(input$distribution, "표본 평균의 분포")) +
      xlab("표본 평균") + ylab("밀도")
  })

  output$distPlot <- renderPlot({
    distribution <- input$distribution

    # 분포에 따라 PDF를 계산하고 x 범위를 설정
    if (distribution == "norm") {
      x <- seq(-3, 3, length.out = 100)
      y <- dnorm(x)
      main_title <- "정규 분포의 PDF"
    } else if (distribution == "exp") {
      x <- seq(0, 5, length.out = 100)
      y <- dexp(x, rate = 1)
      main_title <- "지수 분포의 PDF"
    } else if (distribution == "unif") {
      x <- seq(-0.1, 1.1, length.out = 100)
      y <- dunif(x, min = 0, max = 1)
      main_title <- "균등 분포의 PDF"
    }

    # PDF를 그래프로 표시
    ggplot() + geom_line(aes(x, y)) + ggtitle(main_title) +
      xlab("x 값") + ylab("밀도")
  })
}

# Shiny 앱 실행
shinyApp(ui = ui, server = server)
