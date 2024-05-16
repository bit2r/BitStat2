library(shiny)
library(ggplot2)
library(dplyr)
library(DT)
library(RColorBrewer)
library(showtext)
showtext_auto()

ui <- fluidPage(
  titlePanel('K-평균 군집분석과 PCA 시각화'),

  sidebarLayout(
    sidebarPanel(
      radioButtons('dataset', '데이터셋 선택',
                   choices = c('USArrests', 'iris', '업로드된 데이터셋')),
      conditionalPanel(
        condition = "input.dataset == '업로드된 데이터셋'",
        fileInput('file1', 'CSV 파일 선택',
                  accept = c('text/csv',
                             'text/comma-separated-values,text/plain',
                             '.csv'))
      ),
      uiOutput("varselect_ui"),
      sliderInput('clusters', '군집 개수', 3, min = 1, max = 10)
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("그래프", plotOutput('plot')),
        tabPanel("군집별 관측점수", tableOutput('table1')),
        tabPanel("군집별 요약통계", tableOutput('table2'))
      )
    )
  )
)

server <- function(input, output, session) {

  dataInput <- reactive({
    switch(input$dataset,
           'iris' = iris,
           'USArrests' = USArrests,
           '업로드된 데이터셋' = {
             req(input$file1)
             read.csv(input$file1$datapath)
           })
  })

  observe({
    req(dataInput())
    num_vars <- names(dataInput())[sapply(dataInput(), is.numeric)]
    updateSelectInput(session, 'xcol', choices = num_vars)
    updateSelectInput(session, 'ycol', choices = num_vars, selected = num_vars[2])
  })

  output$varselect_ui <- renderUI({
    req(dataInput())
    num_vars <- names(dataInput())[sapply(dataInput(), is.numeric)]
    list(
      selectInput('xcol', 'X 변수', num_vars),
      selectInput('ycol', 'Y 변수', num_vars, selected = num_vars[2])
    )
  })

  selectedData <- reactive({
    req(input$xcol, input$ycol)
    dataInput()[, c(input$xcol, input$ycol)]
  })

  pca <- reactive({
    req(selectedData())
    prcomp(selectedData(), scale. = TRUE)
  })

  cluster_results <- reactive({
    req(pca())
    kmeans(pca()$x[, 1:2], input$clusters)
  })

  output$plot <- renderPlot({
    req(cluster_results(), pca())

    df <- data.frame(pca()$x[, 1:2])

    ggplot(df, aes(x = PC1, y = PC2, color = factor(cluster_results()$cluster))) +
      geom_point(size = 3, show.legend = TRUE) +
      geom_text(data = data.frame(cluster_results()$centers),
                aes(label = "X"), size = 8, color = "black") +
      scale_color_brewer(type = "qual", palette = "Set2") +
      scale_shape_manual("클러스터", values = c(1:input$clusters)) +
      theme_bw() +
      labs(title = paste("K =", input$clusters, "인 K-평균 군집분석"),
           color = "군집")
  })

  output$table1 <- renderTable({
    req(cluster_results(), dataInput())
    df_res <- dataInput()
    df_res$cluster <- cluster_results()$cluster
    df_res %>%
      group_by(cluster) %>%
      tally(name = "개수") # 각 클러스터의 샘플 수 계산
  })

  output$table2 <- renderTable({
    req(cluster_results(), dataInput())
    df_res <- dataInput()
    df_res$cluster <- cluster_results()$cluster
    df_res %>% group_by(cluster) %>%
      summarise(관측점수 = n(),
                X_평균 = mean(get(input$xcol)),
                Y_평균 = mean(get(input$ycol)))
  })
}

shinyApp(ui = ui, server = server)
