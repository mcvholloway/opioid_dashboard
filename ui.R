shinyUI(
  dashboardPage( skin = 'red',
    dashboardHeader(title = 'Opioid Medicare Claims Data', titleWidth = 300),
    dashboardSidebar(
      selectInput("year", label = "Year:", choices = c(2013, 2014, 2015, 2016),
                   selected = 2013),
      selectInput("drug", label = "Drug:", choices = drugs, selected = 'Hydrocodone'),
      "Data Source: Medicare Provider Utilization and Payment Data: Part D Prescriber, 
      https://www.cms.gov/Research-Statistics-Data-and-Systems/Statistics-Trends-and-Reports/Medicare-Provider-Charge-Data/Part-D-Prescriber.html "
    ),
    dashboardBody(
      # tags$head(
      #   tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css")
      # ),
      fluidRow(
      box( width = 8,status = "primary", plotlyOutput("boxplot", height = 400)),
      box(width = 4, 
        infoBoxOutput("CountBox", width = 200),
        valueBoxOutput("RankBox", width = 400),
        valueBoxOutput("StateBox", width = 200)
        # infoBoxOutput("SpecialtyClaimsBox", width = 400)
      )
      ),
      fluidRow(
        uiOutput("box1")
        # box(width = 12, status = 'primary', 
        #     title = 'Medicare Claims by Specialty',
        #     'Click on column name to sort.',
        #     dataTableOutput("mytable"))
      )
    )
  )
)
