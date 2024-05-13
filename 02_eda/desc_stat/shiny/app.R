library(shiny)
library(ggplot2)

# UI 정의
ui <- fluidPage(
  titlePanel("기술통계"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("numSelect",
                  "1~100 사이 무작위 추출할 데이터수:",
                  min = 1,
                  max = 100,
                  value = 10),
      checkboxInput("replace", "복원추출", value = FALSE)
    ),
    mainPanel(
      plotOutput("numberPlot"),
      uiOutput("stats")
    )
  )
)

# 서버 로직
server <- function(input, output) {
  selectedNumbers <- reactive({
    sample(1:100, input$numSelect, replace = input$replace)
  })

  output$numberPlot <- renderPlot({
    data <- data.frame(value = selectedNumbers())
    mean_val <- mean(data$value)
    std_dev <- sd(data$value)

    ggplot(data, aes(x = factor(1), y = value)) +
      geom_point(stat = "identity", position = position_dodge(width = 0.2), size = 4) +
      annotate("segment", x = 0.8, xend = 1.2, y = mean_val, yend = mean_val, color = "blue", linewidth = 1.5) +
      geom_errorbar(aes(ymin = mean_val - std_dev, ymax = mean_val + std_dev, x = factor(1)), width = 0.2, color = "red") +
      labs(title = paste0("추출된", length(selectedNumbers()), "개 데이터와 통계"), y = "", x = "") +
      theme_minimal() +
      coord_flip() +
      theme(
        aspect.ratio = 1/5,
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()
      )
  })

  output$stats <- renderUI({
    data <- selectedNumbers()
    if (length(data) > 0) {
      mean_val <- mean(data)
      sd_val <- sd(data)
      max_val <- max(data)
      min_val <- min(data)

      tags$ul(
        tags$li(HTML(paste("<b>추출된 숫자:</b> ", paste(data, collapse = ", ")))),
        tags$li(HTML(paste("<b>평균:</b> ", round(mean_val, 2)))),
        tags$li(HTML(paste("<b>표준편차:</b> ", round(sd_val, 2)))),
        tags$li(HTML(paste("<b>최대값:</b> ", max_val))),
        tags$li(HTML(paste("<b>최소값:</b> ", min_val)))
      )
    } else {
      "숫자를 선택하세요."
    }
  })
}

# 앱 실행
shinyApp(ui, server)
