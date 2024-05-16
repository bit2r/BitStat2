library(shiny)
library(showtext)
showtext_auto()

ui <- fluidPage(
  titlePanel("상관분석과 단순 회귀분석"),

  sidebarLayout(
    sidebarPanel(
      fileInput("file", "CSV 파일 업로드", accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      radioButtons("dataset", "데이터셋 선택:",
                   choices = c("mtcars", "USArrests", "업로드 데이터셋"),
                   selected = "mtcars"),
      selectInput("y_var", "Y 변수 (종속변수):", ""),
      selectInput("x_var", "X 변수 (독립변수):", "")
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("산점도", plotOutput("scatterplot")),
        tabPanel("상관계수",
                 verbatimTextOutput("correlation"),
                 verbatimTextOutput("cor_test")),
        tabPanel("회귀분석", verbatimTextOutput("regression"))
      )
    )
  )
)

server <- function(input, output, session) {

  data <- reactive({
    if (input$dataset == "업로드 데이터셋") {
      req(input$file)
      read.csv(input$file$datapath, header = TRUE)
    } else {
      switch(input$dataset,
             "mtcars" = mtcars,
             "USArrests" = USArrests)
    }
  })

  observe({
    choices <- names(data())[sapply(data(), is.numeric)]
    updateSelectInput(session, "y_var", choices = choices)
    updateSelectInput(session, "x_var", choices = choices)
  })

  output$scatterplot <- renderPlot({
    req(input$y_var, input$x_var)
    plot(data()[[input$x_var]], data()[[input$y_var]],
         xlab = input$x_var, ylab = input$y_var,
         main = "회귀선이 포함된 산점도")
    abline(lm(data()[[input$y_var]] ~ data()[[input$x_var]]), col = "red", lwd = 2)
    legend("topleft", legend = "회귀선", col = "red", lwd = 2, bty = "n")
  })

  output$correlation <- renderPrint({
    req(input$y_var, input$x_var)
    cor_val <- cor(data()[[input$x_var]], data()[[input$y_var]])
    det_coef <- cor_val^2
    cat("상관계수:", round(cor_val, 3), "\n")
    cat("결정계수 (R-squared):", round(det_coef, 3))
  })

  output$cor_test <- renderPrint({
    req(input$y_var, input$x_var)
    cor.test(data()[[input$x_var]], data()[[input$y_var]])
  })

  output$regression <- renderPrint({
    req(input$y_var, input$x_var)
    lm_model <- lm(data()[[input$y_var]] ~ data()[[input$x_var]])
    names(lm_model$coefficients) <- c("절편", input$x_var)
    summary(lm_model)
  })

}

shinyApp(ui, server)
