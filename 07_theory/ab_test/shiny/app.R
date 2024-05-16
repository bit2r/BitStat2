library(shiny)
library(ggplot2)
library(bslib)
library(DT)
library(tidyverse)
library(greekLetters)
library(shinyhelper)
library(shinyBS)

ui <- fluidPage(
  theme = bslib::bs_theme(bootswatch = "flatly"),

  tabsetPanel(
    tabPanel("평균에 대한 표본크기",
             titlePanel("평균에 대한 쌍대 검정을 위한 표본크기"),
             fluidRow(
               column(10,
                      textOutput("mean_description")
               )),
             br(),
             fluidRow(
               column(4,
                      fluidRow(
                        column(6,
                               numericInput("mu1", "평균 1", value = 132.85, min = 0, step = 0.001),
                               numericInput("s1", "표준편차 1", value = 15.34, min = 0, step = 0.001)),
                        column(6,
                               numericInput("mu2", "평균 2", value = 127.44, min = 0, step = 0.001),
                               numericInput("s2", "표준편차 2", value = 18.23, min = 0, step = 0.001))),
                      numericInput("alpha", label = paste(greeks("alpha"), " (유의수준)"), value = 0.05, min = 0.001, max = 0.05, step = 0.001),
                      numericInput("power", label = paste("1-", greeks("beta"), " (검정력)"), value = 0.8, min = 0.001, max = .999, step = 0.001),
                      helper(actionButton('calculate', "계산"), title = '', icon = "question-circle", type = "inline",
                             content = "입력된 값은 0보다 크고 지정된 범위 내에 있어야 합니다."
                      )
               ),

               column(8,
                      plotOutput("plotnorm"),
                      textOutput("n_norm"))
             )
    ),

    tabPanel("비율에 대한 표본크기",
             titlePanel("두 이항 비율의 쌍대 검정을 위한 표본크기"),
             fluidRow(
               column(10,
                      textOutput("bin_description")
               )),
             br(),
             fluidRow(
               column(4,
                      numericInput("p1", label = "비율 1", value = 0.15, min = 0, max = 1, step = 0.001),
                      numericInput("p2", label = "비율 2", value = 0.12, min = 0, max = 1, step = 0.001),
                      numericInput("k", label = "k", value = 1, min = 1, step = 0.25),
                      numericInput("alpha_bin", label = paste(greeks("alpha"), " (유의수준)"), value = 0.05, min = 0.001, max = 0.05, step = 0.001),
                      numericInput("power_bin", label = paste("1-", greeks("beta"), " (검정력)"), value = 0.8, min = 0.001, max = 0.999, step = 0.001),
                      helper(actionButton('calculate_bin', "계산"), title = '', icon = "question-circle", type = "inline",
                             content = "입력된 값은 0보다 크고 지정된 범위 내에 있어야 합니다."
                      )
               ),
               column(8,
                      plotOutput("plotbin"),
                      textOutput("n_bin"),
                      textOutput("kn_bin")
               )
             )
    )
  )
)

server <- function(input, output, session) {

  v <- reactiveValues(data = iris,
                      plotnorm = NULL,
                      text = NULL)

  vbin <- reactiveValues(data = iris,
                         plotbin = NULL,
                         text = NULL)

  output$mean_description = renderText({
    "여기서는 두 정규 분포에 대한 평균의 쌍대 검정을 위한 표본크기를 계산합니다. 두 표본의 크기는 동일하다고 가정합니다. 사용자는 각 분포의 평균과 표준편차, 검정의 유의수준, 원하는 검정력을 입력해야 합니다. 이 웹 앱은 각 그룹의 표본크기를 계산하고 시각적 비교를 위해 정규 밀도를 겹쳐 그린 히스토그램 플롯을 제공합니다."
  })

  output$n_norm = renderText({
    n_norm = round(n_norm_reactive(), digits = 3)
    paste("그룹당 표본크기: ", n_norm)
  })

  n_norm_reactive = eventReactive(input$calculate, {
    zalpha = qnorm(1 - input$alpha/2, 0, 1)
    zbeta = qnorm(input$power, 0, 1)
    n_norm_reactive = (((input$s1*input$s1 + input$s2*input$s2)*(zalpha+zbeta)^2)/(input$mu2-input$mu1)^2)
    n_norm_reactive
  })

  observeEvent(input$calculate, {
    norm_data = data.frame(1:(n_norm_reactive()), rnorm(n_norm_reactive(), input$mu1, input$s1), rnorm(n_norm_reactive(), input$mu2, input$s2))
    big_norm_data = data.frame(big = 1:1000000, bignormvalues1 = rnorm(1000000, input$mu1, input$s1), bignormvalues2 = rnorm(1000000, input$mu2, input$s2))
    colnames(norm_data) = c("subjects", "normvalues1", "normvalues2")
    v$plotnorm = ggplot(, geom = 'blank') +
      geom_line(aes(x = big_norm_data$bignormvalues1, y = ..density.., color = '모집단 1', col = "#1B9E77"), stat = 'density') +
      geom_line(aes(x = big_norm_data$bignormvalues2, y = ..density.., color = '모집단 2', col = "#D95F02"), stat = 'density') +
      geom_histogram(aes(x = norm_data$normvalues1, y = ..density..), alpha = 0.4, fill = "#1B9E77", col = "#1B9E77") +
      geom_histogram(aes(x = norm_data$normvalues2, y = ..density..), alpha = 0.4, fill = "#D95F02", col = "#D95F02") +
      xlab("값") +
      ylab("빈도") +
      theme(panel.background = element_rect(fill = "transparent"),
            plot.background = element_rect(fill = "transparent", color = NA))+
      labs(colour = "모집단", title = "표본크기에 따른 두 표본의 히스토그램과 정규 밀도 겹침")
  })

  output$plotnorm = renderPlot({
    if(is.null(v$plotnorm)) return()
    v$plotnorm
  })

  output$bin_description = renderText({
    "여기서는 표본 2의 크기가 표본 1의 크기의 k배인 두 이항 분포의 비율에 대한 쌍대 검정의 표본크기를 계산합니다. 사용자는 각 분포의 예상 비율, k, 유의수준, 원하는 검정력을 입력해야 합니다. 이 웹 앱은 각 그룹의 표본크기를 계산하고 시각적 비교를 위해 이항 분포를 근사하는 정규 밀도를 겹쳐 그린 히스토그램 플롯을 제공합니다."
  })

  output$n_bin = renderText({
    n_bin = round(n_bin_reactive(), digits = 3)
    paste("그룹 1의 표본크기: ", n_bin)
  })

  output$kn_bin = renderText({
    kn_bin = round(input$k * n_bin_reactive(), digits = 3)
    paste("그룹 2의 표본크기: ", kn_bin)
  })

  n_bin_reactive = eventReactive(input$calculate_bin, {
    q1 = 1 - input$p1
    q2 = 1 - input$p2
    zalpha = qnorm(1 - input$alpha_bin/2, 0, 1)
    zbeta = qnorm(input$power_bin, 0, 1)
    p = (input$p1 + input$k*input$p2) / (1 + input$k)
    q = 1 - p
    num = sqrt(p*q*(1 + 1/input$k))*zalpha + sqrt(input$p1*q1 + input$p2*q2/input$k)*zbeta
    n_bin_reactive = num^2 / (input$p1 - input$p2)^2
    n_bin_reactive
  })

  output$plotbin = renderPlot({
    if(is.null(vbin$plotbin)) return()
    vbin$plotbin
  })

  observeEvent(input$calculate_bin, {
    success = 0:(floor(n_bin_reactive()))
    prob1 = dbinom((0:floor(n_bin_reactive())), floor(n_bin_reactive()), input$p1)
    data_bin = data.frame(success, prob1)
    success2 = 0:(floor((input$k) * (n_bin_reactive())))
    prob2 = dbinom((0:floor((input$k) * n_bin_reactive())), floor((input$k) * n_bin_reactive()), input$p2)
    data_bin2 = data.frame(success2, prob2)
    big_norm_data2 = data.frame(bignormvalues1 = rnorm(1000000, floor(n_bin_reactive())*(input$p1), sqrt(floor(n_bin_reactive()*(input$p1)*(1-input$p1)))),
                                bignormvalues2 =  rnorm(1000000, (floor(n_bin_reactive())*(input$p2)), sqrt(floor(n_bin_reactive())*(input$p2)*(1-input$p2))))

    vbin$plotbin = ggplot(, geom = 'blank') +
      geom_line(aes(x = (big_norm_data2$bignormvalues1), y = ..density..), col = "#1B9E77", stat = 'density') +
      geom_line(aes(x = (big_norm_data2$bignormvalues2), y = ..density..), col = "#D95F02", stat = 'density') +
      geom_col(aes(x = data_bin$success, y = data_bin$prob1), alpha = 0.4, fill = "#1B9E77", col = "#1B9E77") +
      geom_col(aes(x = data_bin2$success2, y = data_bin2$prob2), alpha = 0.4, fill = "#D95F02", col = "#D95F02") +
      xlab("값") +
      ylab("빈도") +
      theme(panel.background = element_rect(fill = "transparent"),
            plot.background = element_rect(fill = "transparent", color = NA),
            legend.position = "none") +
      labs(colour = "모집단", title = "표본크기에 따른 두 표본의 히스토그램과 정규 밀도 겹침")
  })

  addTooltip(session = session, id = "calculate", title = "입력된 값은 0보다 크고 지정된 범위 내에 있어야 합니다.")
  addTooltip(session = session, id = "calculate_bin", title = "입력된 값은 0보다 크고 지정된 범위 내에 있어야 합니다.")
}

shinyApp(ui = ui, server = server)
