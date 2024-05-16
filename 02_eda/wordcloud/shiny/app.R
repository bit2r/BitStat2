library(shiny)
library(wordcloud2)
library(colourpicker)
library(tidytext)
library(dplyr)
library(DT)
library(stringr)
library(janeaustenr)

# 워드 클라우드 생성 함수
create_wordcloud <- function(text, min_freq, num_words, background, language, filter_single_char) {
  # 티블 생성
  text_df <- tibble(text = text)

  # 텍스트 전처리
  tidy_words <- text_df %>%
    unnest_tokens(word, text, token = "words", drop = TRUE) %>%
    filter(
      if (language == "english") str_detect(word, "[a-zA-Z]")
      else if (language == "korean") str_detect(word, "[가-힣]")
    ) %>%
    filter(!word %in% stop_words$word) %>%
    count(word, sort = TRUE) %>%
    ungroup()

  # 한글에서 한 글자 단어 필터링
  if (language == "korean" && filter_single_char) {
    tidy_words <- tidy_words %>%
      filter(str_length(word) > 1)
  }

  # 최소 빈도에 따른 단어 필터링
  filtered_words <- tidy_words %>%
    filter(n >= min_freq) %>%
    top_n(num_words, wt = n)

  # 필터링된 데이터프레임과 워드 클라우드 반환
  if (nrow(filtered_words) <= 1) {
    return(list(
      wordcloud = NULL,
      table = data.frame()
    ))
  } else {
    return(list(
      wordcloud = wordcloud2(filtered_words, backgroundColor = background),
      table = filtered_words
    ))
  }
}

# 워드 클라우드용 샘플 데이터
sample_data <- list(
  "없음" = "",
  "오만과 편견" = paste(janeaustenr::prideprejudice, collapse = " ")
)

ui <- fluidPage(
  h1("워드 클라우드"),
  sidebarLayout(
    sidebarPanel(
      selectInput("dataset", "데이터셋 선택:", choices = names(sample_data)),
      textAreaInput("text", "텍스트 입력:", "", rows = 5),
      radioButtons("language", "언어:",
                   choices = c("영어" = "english", "한글" = "korean"),
                   selected = "english"),
      conditionalPanel(
        condition = "input.language == 'korean'",
        checkboxInput("filter_single_char", "한 글자 단어 제외", value = TRUE)
      ),
      sliderInput("min_freq", "최소 빈도:", min = 1, max = 10, value = 1),
      sliderInput("num", "최대 단어 수:", min = 5, max = 200, value = 100),
      colourInput("col", "배경색:", value = "white")
    ),
    mainPanel(
      splitLayout(
        cellWidths = c("70%", "30%"),
        wordcloud2Output("cloud"),
        DTOutput("table")
      )
    )
  )
)

server <- function(input, output) {
  wordcloud_data <- reactive({
    req(input$text != "" | input$dataset != "없음") # 텍스트 입력 또는 데이터셋이 비어있지 않은지 확인
    text <- if (input$dataset != "없음") sample_data[[input$dataset]] else input$text
    create_wordcloud(text, input$min_freq, input$num, input$col, input$language, input$filter_single_char)
  })

  output$cloud <- renderWordcloud2({
    wordcloud_data()$wordcloud
  })

  output$table <- renderDT({
    datatable(wordcloud_data()$table, options = list(pageLength = 10))
  })
}

shinyApp(ui = ui, server = server)
