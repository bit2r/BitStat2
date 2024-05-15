library(shiny)

ui <- fluidPage(
  titlePanel("Correlation and Simple Linear Regression"),

  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose CSV File",
                accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      tags$br(),
      checkboxInput("header", "Header", TRUE),
      radioButtons("sep", "Separator",
                   choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
                   selected = ","),
      selectInput("x_var", "X Variable:", ""),
      selectInput("y_var", "Y Variable:", "")
    ),

    mainPanel(
      plotOutput("scatterplot"),
      verbatimTextOutput("correlation"),
      verbatimTextOutput("regression")
    )
  )
)

server <- function(input, output, session) {

  df <- reactive({
    req(input$file)
    read.csv(input$file$datapath, header = input$header, sep = input$sep)
  })

  observe({
    updateSelectInput(session, "x_var", choices = names(df()))
    updateSelectInput(session, "y_var", choices = names(df()))
  })

  output$scatterplot <- renderPlot({
    req(input$x_var, input$y_var)
    plot(df()[[input$x_var]], df()[[input$y_var]],
         xlab = input$x_var, ylab = input$y_var,
         main = "Scatter Plot")
    abline(lm(df()[[input$y_var]] ~ df()[[input$x_var]]), col = "red")
  })

  output$correlation <- renderPrint({
    req(input$x_var, input$y_var)
    cor_val <- cor(df()[[input$x_var]], df()[[input$y_var]])
    paste("Correlation:", round(cor_val, 3))
  })

  output$regression <- renderPrint({
    req(input$x_var, input$y_var)
    lm_model <- lm(df()[[input$y_var]] ~ df()[[input$x_var]])
    summary(lm_model)
  })

}

shinyApp(ui, server)
