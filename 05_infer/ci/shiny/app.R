library(shiny)
library(ggplot2)
library(tidyverse)
library(showtext)
showtext_auto()

ui <- fluidPage(
  title = "신뢰구간 모의실험",

  fluidRow(
    column(3,
           h2('신뢰구간'),
           hr(),
           radioButtons("case", "평균과 비율 추정 선택:",
                        choices = c("모집단 평균", "모집단 비율"),
                        inline = TRUE,
                        selected = "모집단 평균"),
           hr(),
           conditionalPanel(
             condition = "input.case == '모집단 비율'",
             sliderInput("pop_prop",
                         "모집단 비율:",
                         min = 0,
                         max = 1,
                         step = 0.05,
                         value = 0.4)
           ),
           conditionalPanel(
             condition = "input.case == '모집단 평균'",
             numericInput("pop_mean", "모집단 평균:", value = 10),
             numericInput("pop_sd", "모집단 표준편차:", value = 5, min = 0)
           ),
           hr(),
           sliderInput("sample_size",
                       "표본 크기:",
                       min = 10,
                       max = 1000,
                       step = 10,
                       value = 100),
           sliderInput("n_samples",
                       "표본 수:",
                       min = 0,
                       max = 500,
                       step = 10,
                       value = 10),
           sliderInput("conf_level",
                       "신뢰 수준:",
                       min = 5,
                       max = 99,
                       step = 1,
                       value = 95)
    ),
    column(8,
           mainPanel(
             plotOutput('IntervalPlot', height = '500px'),
             verbatimTextOutput("summary"),
             verbatimTextOutput("ci")
           )
    )
  )
)

server <- function(input, output) {

  output$IntervalPlot <- renderPlot({
    n_samples = input$n_samples
    sample_size = input$sample_size
    alpha = 1 - (input$conf_level / 100)

    if (input$case == "모집단 비율") {
      n_population <- 100000
      population <- rbernoulli(n_population, p = input$pop_prop)
      true_value <- mean(population)

      sample_stats <- vector('numeric', n_samples)
      upper_cis <- vector('numeric', n_samples)
      lower_cis <- vector('numeric', n_samples)
      contains_true_value <- vector('numeric', n_samples)
      for (i in 1:n_samples) {
        sample <- sample(population, sample_size, replace = FALSE)
        sample_stat <- mean(sample)
        sample_std <- (sqrt(sample_stat * (1 - sample_stat)) / sqrt(sample_size))
        z_value <- qnorm(alpha/2, lower.tail = FALSE)
        margin_of_error <- z_value * sample_std

        sample_stats[i] <- sample_stat
        upper_cis[i] <- sample_stat + margin_of_error
        lower_cis[i] <- sample_stat - margin_of_error
        contains_true_value[i] <- ifelse(true_value >= lower_cis[i] & true_value <= upper_cis[i], 1, 0)
      }

      title_text <- paste(input$conf_level, "% 신뢰구간 (모집단 비율)", sep = " ")
      y_label <- "표본 비율"

    } else if (input$case == "모집단 평균") {
      n_population <- 100000
      population <- rnorm(n_population, mean = input$pop_mean, sd = input$pop_sd)
      true_value <- mean(population)

      sample_stats <- vector('numeric', n_samples)
      upper_cis <- vector('numeric', n_samples)
      lower_cis <- vector('numeric', n_samples)
      contains_true_value <- vector('numeric', n_samples)
      for (i in 1:n_samples) {
        sample <- sample(population, sample_size, replace = FALSE)
        sample_stat <- mean(sample)
        sample_std <- sd(sample) / sqrt(sample_size)
        t_value <- qt(alpha/2, df = sample_size - 1, lower.tail = FALSE)
        margin_of_error <- t_value * sample_std

        sample_stats[i] <- sample_stat
        upper_cis[i] <- sample_stat + margin_of_error
        lower_cis[i] <- sample_stat - margin_of_error
        contains_true_value[i] <- ifelse(true_value >= lower_cis[i] & true_value <= upper_cis[i], 1, 0)
      }

      title_text <- paste(input$conf_level, "% 신뢰구간 (모집단 평균)", sep = " ")
      y_label <- "표본 평균"
    }

    subtitle_text <- paste0('관측된 포함률: ',
                            round(mean(contains_true_value), 2) * 100, '%')

    contains_true_value_f <- ifelse(contains_true_value==1, "포함", "미포함")
    contains_true_value_f <- factor(contains_true_value_f)

    p <- tibble(
      sample_stat = sample_stats,
      upper_ci = upper_cis,
      lower_ci = lower_cis) %>%
      mutate(sample_number = as.factor(row_number())) %>%
      ggplot(aes(x = sample_number, y = sample_stat)) +
      coord_flip() +
      ggtitle(title_text, subtitle = subtitle_text) +
      ylab(y_label) +
      xlab("") +
      theme_minimal() +
      theme(axis.text.y = element_blank(),
            axis.ticks.y = element_blank(),
            axis.line.x = element_line(color="black", size = 0.5),
            legend.position = "none") +
      scale_x_discrete(breaks = NULL)

    p <- p + geom_hline(aes(yintercept = true_value),
                        linetype = 'dashed', size = 1)
    p <- p +
      geom_linerange(aes(ymin = lower_ci, ymax = upper_ci, color=contains_true_value_f)) +
      geom_point(aes(color=contains_true_value_f), size=2) +
      scale_color_manual(values=c("포함" = "#009E73", "미포함" = "#D55E00"))


    p
  })

  output$summary <- renderPrint({
    n_samples = input$n_samples
    sample_size = input$sample_size

    if (input$case == "모집단 비율") {
      n_population <- 100000
      population <- rbernoulli(n_population, p = input$pop_prop)

      sample_stats <- vector('numeric', n_samples)
      for (i in 1:n_samples) {
        sample <- sample(population, sample_size, replace = FALSE)
        sample_stats[i] <- mean(sample)
      }

      cat("표본 비율의 평균(점추정):\n")
      print(mean(sample_stats))

    } else if (input$case == "모집단 평균") {
      n_population <- 100000
      population <- rnorm(n_population, mean = input$pop_mean, sd = input$pop_sd)

      sample_stats <- vector('numeric', n_samples)
      for (i in 1:n_samples) {
        sample <- sample(population, sample_size, replace = FALSE)
        sample_stats[i] <- mean(sample)
      }

      cat("표본 평균의 평균(점 추정):\n")
      print(mean(sample_stats))
    }
  })

  output$ci <- renderPrint({
    n_samples = input$n_samples
    sample_size = input$sample_size
    alpha = 1 - (input$conf_level / 100)

    if (input$case == "모집단 비율") {
      n_population <- 100000
      population <- rbernoulli(n_population, p = input$pop_prop)

      sample_stats <- vector('numeric', n_samples)
      for (i in 1:n_samples) {
        sample <- sample(population, sample_size, replace = FALSE)
        sample_stats[i] <- mean(sample)
      }

      se <- sqrt(mean(sample_stats) * (1 - mean(sample_stats)) / sample_size)
      lower_ci <- mean(sample_stats) - qnorm(1 - alpha/2) * se
      upper_ci <- mean(sample_stats) + qnorm(1 - alpha/2) * se

      cat(paste0(input$conf_level, "% 신뢰구간 (모집단 비율):\n"))
      cat(paste0("[", round(lower_ci, 2), ", ", round(upper_ci, 2), "]"))

    } else if (input$case == "모집단 평균") {
      n_population <- 100000
      population <- rnorm(n_population, mean = input$pop_mean, sd = input$pop_sd)

      sample_stats <- vector('numeric', n_samples)
      for (i in 1:n_samples) {
        sample <- sample(population, sample_size, replace = FALSE)
        sample_stats[i] <- mean(sample)
      }

      se <- sd(sample_stats) / sqrt(n_samples)
      lower_ci <- mean(sample_stats) - qt(1 - alpha/2, df = n_samples - 1) * se
      upper_ci <- mean(sample_stats) + qt(1 - alpha/2, df = n_samples - 1) * se

      cat(paste0(input$conf_level, "% 신뢰구간 (모집단 평균):\n"))
      cat(paste0("[", round(lower_ci, 2), ", ", round(upper_ci, 2), "]"))
    }
  })
}

shinyApp(ui = ui, server = server)
