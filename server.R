shinyServer(
  function(input, output) {
  
    output$boxplot <- renderPlotly({
      biggest = drugs_by_state %>% filter(Year == input$year) %>% select(Opioid_Death_Rate) %>% max(na.rm = TRUE)
      smallest = drugs_by_state %>% filter(Year == input$year) %>% select(Opioid_Death_Rate) %>% min(na.rm = TRUE)
      data <- drugs_by_state %>% filter(Year == input$year, Drug == toupper(input$drug)) %>% 
        mutate(X = 1) %>% mutate(size = 20/(biggest - smallest) * Opioid_Death_Rate + 5 - 20*smallest/(biggest - smallest))
      data %>%
        plot_ly() %>%
        add_trace(x = ~X ,y = ~Claims, type = "box", hoverinfo = 'name+y',boxpoints = FALSE) %>%
        add_markers(x = ~jitter(X, amount = 1/5), y = ~Claims,
                    alpha = .6, hoverinfo = "text", marker = list(size = ~size), 
                    text = ~paste0("State: ", State,
                                   "<br>Claims Per 100 Persons:  ", round(Claims, 2),
                                   "<br>Opioid Deaths Per 100,000: ", Opioid_Death_Rate),
                    showlegend = FALSE) %>%
        layout(
          showlegend = FALSE,
          xaxis = list(title = "", tickmode = 'array', nticks = 3, tickvals = c(1),
                       ticktext = c(input$drug), tickfont = list(size = 20)),
          yaxis = list(title = 'Claims Per 100 Persons', titlefont = list(size = 20), tickfont = list(size = 18)),
          titlefont = list(size = 24),
          title = paste('Medicare Claims Rate by State,', input$year),
          margin = list(t = 50),
          annotations = 
            list(x = .075, y = 1.05, text = "Point size is proportional to opioid overdose deaths per 100,000 persons.", 
                 showarrow = F, xref='paper', yref='paper', 
                 xanchor='left', yanchor='auto', xshift=0, yshift=0,
                 font=list(size=12))
        )
     }) 
    
    output$CountBox <- renderInfoBox({
      claims <- sum(drugs_by_specialty %>% filter(Year == input$year, Drug == input$drug) %>% 
        select(Total_Claims), na.rm = TRUE)
      infoBox(
        HTML(paste("Medicare Part D Claims", br(), paste0('for ', input$drug, br(), ' in ', input$year))),
        formatC(claims, format="d", big.mark=","), 
        icon = icon("pills"),
        color = "black"
      )
    })
    
    output$StateBox <- renderInfoBox({
      data <- drugs_by_state %>% 
        filter(Year == input$year, Drug == toupper(input$drug)) %>% 
        top_n(1, Claims)
      state <- data[[1, 'State']]
      claims <- data[[1, 'Claims']]
      total <- data[[1, 'Total_Claims']]
      valueBox(tags$p(state, style = "font-size: 90%;"),
              paste0('had the highest claims rate at ', round(claims,2), 
' claims per 100 persons and ', formatC(total, format="d", big.mark=","), ' total claims.'),
              icon = icon("pills"),
              color = "black"
      )
    })
    
    output$SpecialtyBox <- renderInfoBox({
      top_specialties <- drugs_by_specialty %>% 
        filter(Year == input$year, Drug == input$drug) %>% 
        top_n(3, Total_Claims) %>% arrange(desc(Total_Claims))
      spec1 = top_specialties[[1,'Specialty']]
      spec2 = top_specialties[[2,'Specialty']]
      spec3 = top_specialties[[3,'Specialty']]
      claims1 = top_specialties[[1,'Total_Claims']]
      claims2 = top_specialties[[2,'Total_Claims']]
      claims3 = top_specialties[[3,'Total_Claims']]
      
      infoBox('', HTML(paste("Top Specialties By", br(), "Number of Claims")),
        HTML(paste(
        paste0("1. ", spec1, ': ', formatC(claims1, format='d', big.mark=','), ' claims'), br(),
        paste0("2. ", spec2, ': ', formatC(claims2, format='d', big.mark=','), ' claims'), br(),
        paste0("3. ", spec3, ': ', formatC(claims3, format='d', big.mark=','), ' claims'))),
        icon = icon("list"),
        color = "purple"
      )
    })
    
    output$SpecialtyClaimsBox <- renderInfoBox({
      top_specialties <- drugs_by_specialty %>% 
        filter(Year == input$year, Drug == input$drug) %>% 
        top_n(3, Claims_Per_Prescriber) %>% arrange(desc(Claims_Per_Prescriber))
      spec1 = top_specialties[[1,'Specialty']]
      spec2 = top_specialties[[2,'Specialty']]
      spec3 = top_specialties[[3,'Specialty']]
      claims1 = top_specialties[[1,'Claims_Per_Prescriber']]
      claims2 = top_specialties[[2,'Claims_Per_Prescriber']]
      claims3 = top_specialties[[3,'Claims_Per_Prescriber']]
      
      infoBox('', HTML(paste("Top Specialties By", br(), "Claims Rate")),
              HTML(paste(
                paste0("1. ", spec1, ': ', formatC(claims1, format='d', big.mark=','), ' claims per prescriber'), br(),
                paste0("2. ", spec2, ': ', formatC(claims2, format='d', big.mark=','), ' claims per prescriber'), br(),
                paste0("3. ", spec3, ': ', formatC(claims3, format='d', big.mark=','), ' claims per prescriber'))),
              icon = icon("list"),
              color = "purple"
      )
    })
    
    output$mytable <- renderDataTable({ 
      drugs_by_specialty %>% 
        filter(Year == input$year, Drug == input$drug) %>% 
        select(Specialty, `Total Claims` = Total_Claims, `Claims Per Prescriber` = Claims_Per_Prescriber) %>% 
        mutate(`Claims Per Prescriber` = round(`Claims Per Prescriber`, 2)) %>% 
        arrange(desc(`Total Claims`)) %>% 
        mutate(`Total Claims` = formatC(`Total Claims`, format="d", big.mark=","))
      })
    
    output$box1 <- renderUI({
      box(width = 12, 
          title = paste0('Medicare Claims for ', input$drug, ' by Specialty'),
          'Click on column name to sort.',
          dataTableOutput("mytable"))
    })
    
    output$RankBox <- renderInfoBox({
      claims <- drugs_by_specialty %>% filter(Year == input$year) %>% group_by(Drug) %>% 
        summarize(Total_Claims = sum(Total_Claims)) %>% ungroup() %>% 
        arrange(desc(Total_Claims))
      claims$Rank = 1:nrow(claims)
      drug_rank = (claims %>% filter(Drug == input$drug))[[1,'Rank']]
      rank_translated = case_when(
        drug_rank == 1 ~ "",
        drug_rank == 2 ~ "2nd ",
        drug_rank == 3 ~ "3rd ",
        TRUE ~ paste0(drug_rank, 'th ')
      )
      valueBox(tags$p(paste0('Rank: ',drug_rank), style = "font-size: 90%;"),
               paste0(input$drug, ' was the ', rank_translated, 'most prescribed opioid in ', input$year, '.'),
        icon = icon("list"),
        color = "black"
      )
    })
    
  })
