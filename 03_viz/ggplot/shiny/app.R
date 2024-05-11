library(shiny)
library(ggplot2)
library(dplyr)

ui <- fluidPage(
  titlePanel("CSV Data Visualization"),

  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose CSV File",
                accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),

      selectInput("x_var", "X-axis Variable", choices = NULL),
      selectInput("y_var", "Y-axis Variable", choices = NULL),
      selectInput("color_var", "Color Variable", choices = NULL),

      checkboxInput("reg_line", "Add Regression Line", value = FALSE),
      sliderInput("alpha", "Point Transparency", min = 0, max = 1, value = 0.5, step = 0.1),

      downloadButton("download_plot", "Download Plot")
    ),

    mainPanel(
      plotOutput("plot"),
      br(),
      h4("Usage Instructions:"),
      tags$ol(
        tags$li("Upload a CSV file using the 'Choose CSV File' button."),
        tags$li("Select variables for the X-axis, Y-axis, and color (optional) from the dropdown menus."),
        tags$li("Customize the plot by adding a regression line or adjusting point transparency."),
        tags$li("The plot will automatically update based on your selections."),
        tags$li("Click the 'Download Plot' button to save the plot as a PNG file.")
      )
    )
  )
)

server <- function(input, output, session) {

  data <- reactive({
    req(input$file)
    read.csv(input$file$datapath)
  })

  observeEvent(data(), {
    updateSelectInput(session, "x_var", choices = names(data()))
    updateSelectInput(session, "y_var", choices = names(data()))
    updateSelectInput(session, "color_var", choices = c("None", names(data())))
  })

  output$plot <- renderPlot({
    req(input$x_var, input$y_var)

    p <- ggplot(data(), aes_string(x = input$x_var, y = input$y_var)) +
      geom_point(alpha = input$alpha)

    if (input$color_var != "None") {
      p <- p + aes_string(color = input$color_var)
    }

    if (input$reg_line) {
      p <- p + geom_smooth(method = "lm")
    }

    p
  })

  output$download_plot <- downloadHandler(
    filename = function() {
      paste("plot", Sys.Date(), ".png", sep = "_")
    },
    content = function(file) {
      ggsave(file, plot = last_plot(), device = "png", width = 8, height = 6, dpi = 300)
    }
  )
}

shinyApp(ui, server)
