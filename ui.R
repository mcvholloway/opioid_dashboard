shinyUI(
  dashboardPage( skin = 'red',
    dashboardHeader(title = 'Opioid Medicare Claims Data', titleWidth = 300),
    dashboardSidebar(
      selectInput("year", label = "Year:", choices = c(2013, 2014, 2015, 2016),
                   selected = 2013),
      selectInput("drug", label = "Drug:", choices = drugs, selected = 'Hydrocodone')
    ),
    dashboardBody(
      fluidRow(
      box( width = 8,status = "primary", plotlyOutput("boxplot", height = 300)),
      box(width = 4, 
        infoBoxOutput("CountBox", width = 400),
        valueBoxOutput("RankBox", width = 400)
        # infoBoxOutput("SpecialtyBox", width = 400),
        # infoBoxOutput("SpecialtyClaimsBox", width = 400)
      )
      ),
      fluidRow(
        box(width = 12, status = 'primary', title = 'Medicare Claims by Specialty',       
            dataTableOutput("mytable"))
      )
    )
  )
)
