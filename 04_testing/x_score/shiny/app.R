library(shiny)
library(ggplot2)
library(showtext)
showtext_auto()

# Define UI for application that draws a histogram
ui <- fluidPage(
  # Application title
  titlePanel("통계 검정에 중요한 점수의 변화에 따른 확률 계산"),

  tags$div(HTML("<script type='text/x-mathjax-config' >
            MathJax.Hub.Config({
            tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}
            });
            </script >
            ")),

  # Sidebar with inputs and options
  sidebarLayout(
    sidebarPanel(
      radioButtons("scoreType", "점수 선택:",
                   c("Z-score" = "z",
                     "T-score" = "t",
                     "Chi-square 점수" = "chisq")),
      conditionalPanel(
        condition = "input.scoreType == 'z'",
        sliderInput("z", "Z-score", min = -5, max = 5, step = 0.01, ticks = TRUE, value = 1.96)
      ),
      conditionalPanel(
        condition = "input.scoreType == 't'",
        sliderInput("t", "T-score", min = -5, max = 5, step = 0.01, ticks = TRUE, value = 1.96),
        numericInput("df_t", "자유도", value = 10, min = 1, step = 1)
      ),
      conditionalPanel(
        condition = "input.scoreType == 'chisq'",
        sliderInput("chisq", "Chi-square 점수", min = 0, max = 20, step = 0.01, ticks = TRUE, value = 3.84),
        numericInput("df_chisq", "자유도", value = 1, min = 1, step = 1)
      ),
      withMathJax(),
      p("$P(X \\leq x) =$"),
      textOutput("prob"),
      hr(),
      p("신뢰수준 (양측):"),
      textOutput("conf_level"),
      p("대응하는 점수:"),
      textOutput("score")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("plot")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  score <- reactive({
    switch(input$scoreType,
           "z" = input$z,
           "t" = input$t,
           "chisq" = input$chisq)
  })

  output$prob <- renderPrint({
    switch(input$scoreType,
           "z" = pnorm(score()),
           "t" = pt(score(), df = input$df_t),
           "chisq" = pchisq(score(), df = input$df_chisq))
  })

  library(ggplot2)
  library(gridExtra)

  # manually save colors
  col1 <- "#3B429F"
  col2 <- "#76BED0"
  col3 <- "#F55D3E"

  output$plot <- renderPlot({
    # useful "shader" function taken from: https://t-redactyl.io/blog/2016/03/creating-plots-in-r-using-ggplot2-part-9-function-plots.html
    funcShaded <- function(x) {
      y <- switch(input$scoreType,
                  "z" = dnorm(x),
                  "t" = dt(x, df = input$df_t),
                  "chisq" = dchisq(x, df = input$df_chisq))
      y[x > score()] <- NA
      return(y)
    }

    p1 <- ggplot(data.frame(x = c(ifelse(input$scoreType == "chisq", 0, -20), 20)), aes(x = x)) +
      stat_function(fun=funcShaded, geom="area", fill=col2, alpha=0.6) +
      stat_function(fun = switch(input$scoreType,
                                 "z" = dnorm,
                                 "t" = function(x) dt(x, df = input$df_t),
                                 "chisq" = function(x) dchisq(x, df = input$df_chisq)),
                    color=col1, size = 1.4) +
      ggtitle(switch(input$scoreType,
                     "z" = "표준정규분포 확률 밀도 함수",
                     "t" = "t 분포 확률 밀도 함수",
                     "chisq" = "카이제곱 분포 확률 밀도 함수")) +
      labs(x="", y="") +
      theme_bw() +
      scale_x_continuous(limits = c(ifelse(input$scoreType == "chisq", 0, -5),
                                    ifelse(input$scoreType == "chisq", max(20, score() + 2), 5)),
                         expand = c(0, 0)) +
      scale_y_continuous(limits = c(0, 0.5), expand = c(0, 0)) +
      geom_vline(xintercept=score(), lty=2, size=1.2, color=col3) +
      annotate("text", x=ifelse(score()<0 | input$scoreType == "chisq", score() + 0.4, score() - 0.4),
               y=funcShaded(score()) + 0.05, label=toupper(input$scoreType),
               parse=TRUE, size=5, color=col3) +
      theme(axis.line = element_line(size=1, colour = "black"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            plot.title = element_text(size = 20, family = "Tahoma", face = "bold"),
            text=element_text(family="Tahoma"),
            axis.text.x=element_text(colour="black", size = 11),
            axis.text.y=element_text(colour="black", size = 11))

    p2 <- ggplot(data.frame(x = c(ifelse(input$scoreType == "chisq", 0, -20), 20)), aes(x = x)) +
      annotate("segment", x=score(), xend=score(),
               y=0, yend=switch(input$scoreType,
                                "z" = pnorm(score()),
                                "t" = pt(score(), df = input$df_t),
                                "chisq" = pchisq(score(), df = input$df_chisq)),
               color=col3, lty=2, size=1.4) +
      annotate("segment", x=ifelse(input$scoreType == "chisq", 0, -5), xend=score(),
               y=switch(input$scoreType,
                        "z" = pnorm(score()),
                        "t" = pt(score(), df = input$df_t),
                        "chisq" = pchisq(score(), df = input$df_chisq)),
               yend=switch(input$scoreType,
                           "z" = pnorm(score()),
                           "t" = pt(score(), df = input$df_t),
                           "chisq" = pchisq(score(), df = input$df_chisq)),
               color=col2, lty=2, size=1.4) +
      stat_function(fun = switch(input$scoreType,
                                 "z" = pnorm,
                                 "t" = function(x) pt(x, df = input$df_t),
                                 "chisq" = function(x) pchisq(x, df = input$df_chisq)),
                    color=col1, size = 1.4) +
      ggtitle(switch(input$scoreType,
                     "z" = "표준정규분포 누적 분포 함수",
                     "t" = "t 분포 누적 분포 함수",
                     "chisq" = "카이제곱 분포 누적 분포 함수")) +
      labs(x="", y="") +
      theme_bw() +
      scale_x_continuous(limits = c(ifelse(input$scoreType == "chisq", 0, -5),
                                    ifelse(input$scoreType == "chisq", max(20, score() + 2), 5)),
                         expand = c(0, 0)) +
      scale_y_continuous(limits = c(0, 1.14), breaks=c(0, 0.2, 0.4, 0.6, 0.8, 1), expand = c(0, 0)) +
      annotate("text", x=score() + 0.4,
               y=switch(input$scoreType,
                        "z" = pnorm(score()),
                        "t" = pt(score(), df = input$df_t),
                        "chisq" = pchisq(score(), df = input$df_chisq)) - 0.1,
               label=toupper(input$scoreType),
               parse=TRUE, size=5, color=col3) +
      annotate("text", x=ifelse(input$scoreType == "chisq", 1, -3),
               y=(switch(input$scoreType,
                         "z" = pnorm(score()),
                         "t" = pt(score(), df = input$df_t),
                         "chisq" = pchisq(score(), df = input$df_chisq)) + 0.05),
               label=("'P(X' <= x ~ ')'"),
               parse=TRUE, size=5, color=col2) +
      theme(axis.line = element_line(size=1, colour = "black"),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            panel.background = element_blank(),
            plot.title = element_text(size = 20, family = "Tahoma", face = "bold"),
            text=element_text(family="Tahoma"),
            axis.text.x=element_text(colour="black", size = 11),
            axis.text.y=element_text(colour="black", size = 11))

    grid.arrange(p1, p2, nrow=1)
  })

  # 신뢰수준 계산
  output$conf_level <- renderText({
    conf_level <- round((1 - 2 * (1 - switch(input$scoreType,
                                             "z" = pnorm(abs(score())),
                                             "t" = pt(abs(score()), df = input$df_t),
                                             "chisq" = pchisq(score(), df = input$df_chisq)))) * 100, 2)
    paste0(conf_level, "%")
  })

  # 양측 검정에서의 점수 계산
  output$score <- renderText({
    conf_level <- (1 - 2 * (1 - switch(input$scoreType,
                                       "z" = pnorm(abs(score())),
                                       "t" = pt(abs(score()), df = input$df_t),
                                       "chisq" = pchisq(score(), df = input$df_chisq))))
    score_val <- round(switch(input$scoreType,
                              "z" = qnorm(1 - (1 - conf_level) / 2),
                              "t" = qt(1 - (1 - conf_level) / 2, df = input$df_t),
                              "chisq" = qchisq(conf_level, df = input$df_chisq)), 2)
    paste0(score_val)
  })
}

# Run the application
shinyApp(ui = ui, server = server)
