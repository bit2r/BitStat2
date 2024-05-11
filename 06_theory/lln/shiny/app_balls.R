library(shiny)
library(ggplot2)
library(dplyr)
library(moderndive)
library(patchwork)

ui <- fluidPage(
  titlePanel("대수의 법칙 시각화"),

  sidebarLayout(
    sidebarPanel(
      h3("설명"),
      p("표본 추출과 대수의 법칙을 시각화하는 앱입니다."),
      p("모집단에서 표본을 반복적으로 추출하여 파란색 공의 비율을 계산합니다."),
      p("파란색 공의 비율, 표본 크기, 반복 횟수를 조정하여 대수의 법칙을 확인할 수 있습니다."),

      h4("모수 설정"),
      sliderInput("blue_prop", "파란색 공의 비율:", min = 0.1, max = 0.9, value = 0.6, step = 0.1),
      hr(),
      h4("표본 크기와 반복 횟수"),
      sliderInput("sample_size", "표본 크기:", min = 10, max = 500, value = 100),
      sliderInput("num_reps", "반복 횟수:", min = 10, max = 1000, value = 100)
    ),

    mainPanel(
      plotOutput("combined_plot"),
      verbatimTextOutput("summary_stats")
    )
  )
)

server <- function(input, output) {

  balls <- reactive({
    red_prop <- 1 - input$blue_prop
    positions <- tibble(
      x = runif(1000, -1, 1),
      y = runif(1000, -1, 1),
      color = c(rep("red", round(1000 * red_prop)), rep("blue", round(1000 * input$blue_prop)))
    )

    positions %>%
      rep_sample_n(size = input$sample_size, reps = input$num_reps) %>%
      mutate(is_blue = color == "blue") %>%
      group_by(replicate) %>%
      summarise(비율 = mean(is_blue)) %>%
      ungroup()
  })

  output$combined_plot <- renderPlot({
    hist_plot <- balls() %>%
      ggplot(aes(x = 비율)) +
      geom_histogram(binwidth = 0.05, fill = "blue") +
      labs(title = "파란색 공의 비율 히스토그램", x = "비율", y = "빈도")

    box_plot <- balls() %>%
      ggplot(aes(x = "", y = 비율)) +
      geom_boxplot(fill = "blue") +
      labs(title = "파란색 공의 비율 상자그림", x = "", y = "비율")

    hist_plot + box_plot
  })

  output$summary_stats <- renderPrint({
    balls() %>%
      summarise(
        최소값 = min(비율),
        평균 = mean(비율),
        최대값 = max(비율),
        분산  = var(비율),
        표준편차 = sd(비율)
      )
  })
}

shinyApp(ui, server)
