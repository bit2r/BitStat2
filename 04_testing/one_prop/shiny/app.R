library(shiny)
library(ggplot2)
library(dplyr)
library(PropCIs)
library(showtext)
library(gt)
# font_add_google(name = "Nanum Gothic", regular.wt = 400)
showtext_auto()

# 3. 1-표본 z-비율검정---------------
prop.z.test <- function(x, n, p0 = 0.5, conf.level = 0.95, alternative = "two.sided") {
  ts.z <- NULL
  cint <- NULL
  p.val <- NULL
  phat <- x / n
  qhat <- 1 - phat
  SE.phat <- sqrt((phat * qhat) / n)
  ts.z <- (phat - p0) / SE.phat
  p.val <- if (alternative == "two.sided") {
    2 * pnorm(abs(ts.z), lower.tail = FALSE)
  } else if (alternative == "less") {
    pnorm(ts.z, lower.tail = TRUE)
  } else {
    pnorm(ts.z, lower.tail = FALSE)
  }
  cint <- phat + c(
    -1 * ((qnorm(((1 - conf.level) / 2) + conf.level)) * SE.phat),
    ((qnorm(((1 - conf.level) / 2) + conf.level)) * SE.phat)
  )
  return(list(x = x, n = n, estimate = phat, null.value = p0, stderr = SE.phat, statistic = ts.z, p.value = p.val, conf.int = cint))
}
# 4. 2-표본 z-비율검정---------------

prop.z.test2 <- function(x1, x2, n1, n2, p0 = 0, pooled.stderr = TRUE, conf.level = 0.95, alternative = "two.sided") {
  ts.z <- NULL
  cint <- NULL
  p.val <- NULL
  phat1 <- x1 / n1
  qhat1 <- 1 - phat1
  phat2 <- x2 / n2
  qhat2 <- 1 - phat2
  pooled.phat <- ((n1 * phat1) + (n2 * phat2)) / (n1 + n2)
  pooled.qhat <- 1 - pooled.phat
  if (pooled.stderr == FALSE) {
    SE.phat <- sqrt((phat1 * qhat1) / n1 + (phat2 * qhat2) / n2)
  } else {
    SE.phat <- sqrt(pooled.phat * pooled.qhat * (1 / n1 + 1 / n2))
  }
  ts.z <- (phat1 - phat2 - p0) / SE.phat
  p.val <- if (alternative == "two.sided") {
    2 * pnorm(abs(ts.z), lower.tail = FALSE)
  } else if (alternative == "less") {
    pnorm(ts.z, lower.tail = TRUE)
  } else {
    pnorm(ts.z, lower.tail = FALSE)
  }
  cint <- (phat1 - phat2) + c(
    -1 * ((qnorm(((1 - conf.level) / 2) + conf.level)) * SE.phat),
    ((qnorm(((1 - conf.level) / 2) + conf.level)) * SE.phat)
  )
  return(list(x1 = x1, x2 = x2, n1 = n1, n2 = n2, estimate1 = phat1, estimate2 = phat2, null.value = p0, stderr = SE.phat, pooled.phat = pooled.phat, statistic = ts.z, p.value = p.val, conf.int = cint))
}

# 5. z-비율검정---------------
prop.z.test3 <- function(x, n, p0 = 0.5, conf.level = 0.95, alternative = "two.sided") {
  ts.z <- NULL
  cint <- NULL
  p.val <- NULL
  phat <- x / n
  qhat <- 1 - phat
  SE.phat <- sqrt((p0 * (1-p0)) / n)
  ts.z <- (phat - p0) / SE.phat
  p.val <- if (alternative == "two.sided") {
    2 * pnorm(abs(ts.z), lower.tail = FALSE)
  } else if (alternative == "less") {
    pnorm(ts.z, lower.tail = TRUE)
  } else {
    pnorm(ts.z, lower.tail = FALSE)
  }
  return(list(x = x, n = n, estimate = phat, null.value = p0, stderr = SE.phat, statistic = ts.z, p.value = p.val))
}

one_proportion_UI <- function(id) {

  ns <- NS(id)

  # 1. 메인 패널 ------------------------------------
  mainPanel <- mainPanel(
    width = 9,
    tabsetPanel(
      tabPanel("검정결과",
               uiOutput(ns("results_one_proportionn"))
      ),
      tabPanel("그래프",
               plotOutput(ns("plot_one_proportion"))
      ),
      tabPanel("표본 데이터",
               gt_output(ns("table_proportion"))
      )
    )
  )

  # 2. 옆 패널 --------------------------------------
  sidebarPanel <- sidebarPanel(width = 3,

     tags$br(),
     tags$b("데이터"),
     tags$br(),

     tags$h4("* 표본 크기"),
     numericInput(ns("n_oneprop"), "\\(n = \\)",
                  value = 30, min = 0, step = 1, width="100px"
     ),

     radioButtons(
       inputId = ns("propx_oneprop"),
       label = NULL,
       choices = c(
         "성공 비율 \\(\\hat{p}\\) " = "prop_true",
         "성공 횟수 \\(x\\) " = "prop_false"
       )
     ),

     conditionalPanel(
       # condition = "input.propx_oneprop == 'prop_true'",
       condition = paste0("input['", ns("propx_oneprop"), "'] == 'prop_true'"),
       tags$b("성공 비율"),
       numericInput( ns("p_oneprop"), "\\(\\hat{p} = \\)",
                     value = 0.2, min = 0, max = 1, step = 0.01, width="100px"
       )
     ),
     conditionalPanel(
       # condition = "input.propx_oneprop == 'prop_false'",
       condition = paste0("input['", ns("propx_oneprop"), "'] == 'prop_false'"),
       tags$b("성공 횟수"),
       numericInput( ns("x_oneprop"), "\\(x = \\)",
                     value = 10, min = 0, step = 1, width="100px"
       )
     ),

     tags$h4("* 가설검정"),

     tags$p("1. 귀무가설"),
     tags$p("\\( H_0 : p = \\)"),

     numericInput( ns("oneprop_h0"),
                   label = NULL,
                   value = 0.1, step = 0.1, width="100px"),

     tags$p("2. 검정방향"),
     radioButtons(
       inputId = ns("alternative"),
       label = "대립가설",
       inline = TRUE,
       choices = c(
         "\\( \\neq \\)" = "two.sided",
         "\\( > \\)" = "greater",
         "\\( < \\)" = "less"
       )
     ),


     tags$p("3. 유의수준"),
     sliderInput( ns("oneprop_alpha"),
                  "유의수준 \\(\\alpha = \\)",
                  min = 0.01,
                  max = 0.10,
                  value = 0.05,
                  step = 0.01
     )
  )

  # 레이아웃 -----------------------------------------------------------
  tagList(
    withMathJax(),
    tags$div(

      fluidPage(
        theme = shinythemes::shinytheme("flatly"),

        sidebarPanel,
        mainPanel
      )
    )
  )
}



one_proportion_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    output$results_one_proportionn <- renderUI({
      if ( input$propx_oneprop == "prop_true" ) {
        test <- prop.z.test(x = input$n_oneprop * input$p_oneprop, n = input$n_oneprop,
                            p0 = input$oneprop_h0, conf.level = 1 - input$oneprop_alpha, alternative = input$alternative)
        test2 <- prop.z.test3(x = input$n_oneprop * input$p_oneprop, n = input$n_oneprop,
                              p0 = input$oneprop_h0, conf.level = 1 - input$oneprop_alpha, alternative = input$alternative)
        test_confint <- prop.z.test(x = input$n_oneprop * input$p_oneprop, n = input$n_oneprop,
                                    p0 = input$oneprop_h0, conf.level = 1 - input$oneprop_alpha, alternative = "two.sided")
        withMathJax(
          tags$h3("데이터"),
          br(),
          paste0("\\(n =\\) ", round(test$n, 3)),
          br(),
          paste0("\\(\\hat{p} =\\) ", round(test$estimate, 3)),
          br(),
          paste0("\\(\\hat{q} = 1 - \\hat{p} =\\) ", round(1 - test$estimate, 3)),
          br(),
          helpText(paste0("\\( n\\hat{p} = \\) ", round(test$n * test$estimate, 3), " 와 \\( n(1-\\hat{p}) = \\) ", round(test$n * (1 - test$estimate), 3))),

          helpText(paste0(" \\( n\\hat{p} \\geq 5\\) 와 \\( n(1-\\hat{p}) \\geq 5\\)", ifelse(test$n * test$estimate >= 5 & test$n * (1 - test$estimate) >= 5, " 가정이 충족.", " 가정이 충족되지 않음."))),
          br(),
          tags$h3("신뢰구간 - 양측"),
          br(),
          paste0(
            (1 - input$oneprop_alpha) * 100, "% 신뢰구간: \\(p = \\hat{p} \\pm z_{\\alpha/2} \\sqrt{\\dfrac{\\hat{p}(1-\\hat{p})}{n}} = \\) ",
            round(test_confint$estimate, 3), "  \\( \\pm \\) ", "\\( ( \\)", round(qnorm(input$oneprop_alpha / 2, lower.tail = FALSE), 3), " * ", round(test_confint$stderr, 3), "\\( ) \\) ", "\\( = \\) ",
            "[", round(test_confint$conf.int[1], 3), "; ", round(test_confint$conf.int[2], 3), "]"
          ),
          br(),
          br(),
          tags$h3("가설검정"),
          br(),
          paste0("1. \\(H_0 : p = \\) ", test$null.value, " and \\(H_1 : p \\) ", ifelse(input$alternative == "two.sided", "\\( \\neq \\) ", ifelse(input$alternative == "greater", "\\( > \\) ", "\\( < \\) ")), test$null.value),
          br(),
          paste0(
            "2. 검정통계량 : \\(z_{obs} = \\dfrac{\\hat{p} - p_0}{\\sqrt{\\dfrac{p_0(1-p_0)}{n}}} = \\) ",
            "(", round(test2$estimate, 3), ifelse(test2$null.value >= 0, paste0(" - ", test2$null.value), paste0(" + ", abs(test2$null.value))), ") / ", round(test2$stderr, 3), " \\( = \\) ",
            ifelse(test2$null.value >= 0 & test2$null.value <= 1, round(test2$statistic, 3), "Error: \\( p_0 \\) must be \\( 0 \\leq p_0 \\leq 1\\)")
          ),
          br(),
          paste0(
            "3. 임계값 :", ifelse(input$alternative == "two.sided", " \\( \\pm z_{\\alpha/2} = \\pm z(\\)", ifelse(input$alternative == "greater", " \\( z_{\\alpha} = z(\\)", " \\( -z_{\\alpha} = -z(\\)")),
            ifelse(input$alternative == "two.sided", input$oneprop_alpha / 2, input$oneprop_alpha), "\\()\\)", " \\( = \\) ",
            ifelse(input$alternative == "two.sided", "\\( \\pm \\)", ifelse(input$alternative == "greater", "", " -")),
            ifelse(input$alternative == "two.sided", round(qnorm(input$oneprop_alpha / 2, lower.tail = FALSE), 3), round(qnorm(input$oneprop_alpha, lower.tail = FALSE), 3))
          ),
          br(),
          paste0("4. 결론 : ", ifelse(test2$p.value < input$oneprop_alpha, "\\(H_0\\) 기각.", "\\(H_0\\) 기각 못함.")),
          br(),
          br(),
          tags$h3("해석"),
          br(),
          paste0( input$oneprop_alpha * 100, "% 유의수준에서, ",
                  "참 모집단 비율이 ", test2$null.value, " 이라는 귀무가설을 ",
                  ifelse(test2$p.value < input$oneprop_alpha, "기각한다", "기각하지 않는다"),
                  " \\((p\\)-값 ", ifelse(test2$p.value < 0.001, "< 0.001", paste0("\\(=\\) ", round(test2$p.value, 3))), ")", ".")
        )
      } else if ( input$propx_oneprop == "prop_false") {
        test <- prop.z.test(x = input$x_oneprop, n = input$n_oneprop, p0 = input$oneprop_h0, conf.level = 1 - input$oneprop_alpha, alternative = input$alternative)
        test2 <- prop.z.test3(x = input$x_oneprop, n = input$n_oneprop, p0 = input$oneprop_h0, conf.level = 1 - input$oneprop_alpha, alternative = input$alternative)
        test_confint <- prop.z.test(x = input$x_oneprop, n = input$n_oneprop, p0 = input$oneprop_h0, conf.level = 1 - input$oneprop_alpha, alternative = "two.sided")
        withMathJax(
          tags$b("Data"),
          br(),
          paste0("\\(n =\\) ", round(test$n, 3)),
          br(),
          paste0("\\(\\hat{p} = \\dfrac{x}{n} = \\) ", test$x, " \\( / \\) ", test$n, " \\( = \\) ", round(test$estimate, 3)),
          br(),
          paste0("\\(\\hat{q} = 1 - \\hat{p} = \\) ", round(1 - test$estimate, 3)),
          br(),
          helpText(paste0("\\( n\\hat{p} = \\) ", round(test$n * test$estimate, 3), " and \\( n(1-\\hat{p}) = \\) ", round(test$n * (1 - test$estimate), 3))),
          helpText(paste0("\\( n\\hat{p} \\geq 5\\) 와 \\( n(1-\\hat{p}) \\geq 5\\) 가정이 ", ifelse(test$n * test$estimate >= 5 & test$n * (1 - test$estimate) >= 5, " 충족됨.", " 충족되지 않음."))),
          br(),
          tags$h2("신뢰구간 - 양측"),
          br(),
          paste0(
            (1 - input$oneprop_alpha) * 100, "% CI for \\(p = \\hat{p} \\pm z_{\\alpha/2} \\sqrt{\\dfrac{\\hat{p}(1-\\hat{p})}{n}} = \\) ",
            round(test_confint$estimate, 3), "  \\( \\pm \\) ", "\\( ( \\)", round(qnorm(input$oneprop_alpha / 2, lower.tail = FALSE), 3), " * ", round(test_confint$stderr, 3), "\\( ) \\) ", "\\( = \\) ",
            "[", round(test_confint$conf.int[1], 3), "; ", round(test_confint$conf.int[2], 3), "]"
          ),
          br(),
          br(),
          tags$h2("가설 검정"),
          br(),
          paste0("1. \\(H_0 : p = \\) ", test$null.value, " and \\(H_1 : p \\) ", ifelse(input$alternative == "two.sided", "\\( \\neq \\) ", ifelse(input$alternative == "greater", "\\( > \\) ", "\\( < \\) ")), test$null.value),
          br(),
          paste0(
            "2. 검정 통계량 : \\(z_{obs} = \\dfrac{\\hat{p} - p_0}{\\sqrt{\\dfrac{p_0(1-p_0)}{n}}} = \\) ",
            "(", round(test2$estimate, 3), ifelse(test2$null.value >= 0, paste0(" - ", test2$null.value), paste0(" + ", abs(test2$null.value))), ") / ", round(test2$stderr, 3), " \\( = \\) ",
            ifelse(test2$null.value >= 0 & test2$null.value <= 1, round(test2$statistic, 3), "오류: \\( p_0 \\) 값이 \\( 0 \\leq p_0 \\leq 1\\) 여야 됨")
          ),
          br(),
          paste0(
            "3. 임계값 :", ifelse(input$alternative == "two.sided", " \\( \\pm z_{\\alpha/2} = \\pm z(\\)", ifelse(input$alternative == "greater", " \\( z_{\\alpha} = z(\\)", " \\( -z_{\\alpha} = -z(\\)")),
            ifelse(input$alternative == "two.sided", input$oneprop_alpha / 2, input$oneprop_alpha), "\\()\\)", " \\( = \\) ",
            ifelse(input$alternative == "two.sided", "\\( \\pm \\)", ifelse(input$alternative == "greater", "", " -")),
            ifelse(input$alternative == "two.sided", round(qnorm(input$oneprop_alpha / 2, lower.tail = FALSE), 3), round(qnorm(input$oneprop_alpha, lower.tail = FALSE), 3))
          ),
          br(),
          paste0("4. 결론 : ", ifelse(test2$p.value < input$oneprop_alpha, "\\(H_0\\) 기각", "\\(H_0\\) 기각하지 못함")),
          br(),
          br(),
          tags$h1("해석"),
          br(),
          paste0( input$oneprop_alpha * 100, "% 유의수준에서, ",
                  "참 모집단 비율이 ", test2$null.value, " 이라는 귀무가설을 ",
                  ifelse(test2$p.value < input$oneprop_alpha, "기각한다", "기각하지 않는다"),
                  " \\((p\\)-값 ", ifelse(test2$p.value < 0.001, "< 0.001", paste0("\\(=\\) ", round(test2$p.value, 3))), ")", ".")
        )
      }
    })

    output$plot_one_proportion <- renderPlot({
      if (input$propx_oneprop == "prop_true") {
        test <- prop.z.test3(x = input$n_oneprop * input$p_oneprop, n = input$n_oneprop, p0 = input$oneprop_h0, conf.level = 1 - input$oneprop_alpha, alternative = input$alternative)
      } else {
        test <- prop.z.test3(x = input$x_oneprop, n = input$n_oneprop, p0 = input$oneprop_h0, conf.level = 1 - input$oneprop_alpha, alternative = input$alternative)
      }
      if (input$alternative == "two.sided") {
        funcShaded <- function(x) {
          y <- dnorm(x, mean = 0, sd = 1)
          y[x < qnorm(input$oneprop_alpha / 2, mean = 0, sd = 1, lower.tail = FALSE) & x > qnorm(input$oneprop_alpha / 2, mean = 0, sd = 1) ] <- NA
          return(y)
        }
      } else if (input$alternative == "greater") {
        funcShaded <- function(x) {
          y <- dnorm(x, mean = 0, sd = 1)
          y[x < qnorm(input$oneprop_alpha, mean = 0, sd = 1, lower.tail = FALSE) ] <- NA
          return(y)
        }
      } else if (input$alternative == "less") {
        funcShaded <- function(x) {
          y <- dnorm(x, mean = 0, sd = 1)
          y[x > qnorm(input$oneprop_alpha, mean = 0, sd = 1, lower.tail = TRUE) ] <- NA
          return(y)
        }
      }
      p <- ggplot(data.frame(x = c(qnorm(0.999, mean = 0, sd = 1, lower.tail = FALSE), qnorm(0.999, mean = 0, sd = 1, lower.tail = TRUE))), aes(x = x)) +

        stat_function( fun = dnorm, fill="gray90", args = list(mean = 0, sd = 1)) +
        stat_function( fun = funcShaded, geom = "area", fill = "sky blue", alpha = 0.8) +

        theme_minimal() +
        geom_vline(xintercept = test$statistic, color = "steelblue") +
        geom_text(aes(x = test$statistic, label = paste0("검정통계량 = ", round(test$statistic, 3)), y = 0.2), colour = "steelblue", angle = 90, vjust = 1.3, text = element_text(size = 11)) +
        ggtitle(paste0("정규분포 N(0,1)")) +
        theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
        ylab("밀도") +
        xlab("x")
      p
    })

    output$table_proportion <- render_gt({
      prop_dat <- rbinom(input$n_oneprop, 1, input$p_oneprop)

      tibble(변수1 = prop_dat) %>%
        mutate(순번 = row_number()) %>%
        relocate(순번, .before = 변수1) %>%
        gt()
    })

  })
}

ui <- fluidPage(
  titlePanel("단일 비율 가설 검정"),
  one_proportion_UI("one_prop")
)

server <- function(input, output, session) {
  one_proportion_server("one_prop")
}

shinyApp(ui, server)
