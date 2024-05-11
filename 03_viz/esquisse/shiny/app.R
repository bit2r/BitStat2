library(esquisse)
library(shiny)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Graph with esquisse"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose CSV File",
                accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
      radioButtons(
        inputId = "data",
        label = "Select data to use:",
        choices = c("mpg", "diamonds", "economics", "Uploaded Data" = "uploaded_data")
      )
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(
          title = "esquisse",
          esquisse_ui(
            id = "esquisse",
            header = FALSE # dont display gadget title
          )
        ),
        tabPanel(
          title = "output",
          tags$b("Code:"),
          verbatimTextOutput("code"),
          tags$b("Filters:"),
          verbatimTextOutput("filters"),
          tags$b("Data:"),
          verbatimTextOutput("data")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  data_r <- reactiveValues(data = iris, name = "iris")

  observeEvent(input$file, {
    req(input$file)
    data_r$data <- read.csv(input$file$datapath)
    data_r$name <- "uploaded_data"
  })

  observe({
    if (input$data != "uploaded_data") {
      data_r$data <- get(input$data)
      data_r$name <- input$data
    }
  })

  results <- esquisse_server(
    id = "esquisse",
    data_rv = data_r
  )

  output$code <- renderPrint({
    results$code_plot
  })

  output$filters <- renderPrint({
    results$code_filters
  })

  output$data <- renderPrint({
    str(results$data)
  })
}

shinyApp(ui, server)
