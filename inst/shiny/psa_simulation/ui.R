shinyUI(navbarPage(
    title = 'Propensity Score Analysis Simulation',

    tabPanel(
        title = 'PSA',
        
        ##### Sidebar Panel
        sidebarPanel(
            width = 3,
            numericInput(inputId = 'sample_size',
                         label = 'Sample size',
                         value = 500,
                         min = 30,
                         max = 1000,
                         step = 10),
            numericInput(inputId = 'treatment_effect',
                         label = 'Treatment effect',
                         value = 1.5,
                         step = 0.25),
            selectInput(inputId = 'estimand',
                        label = 'Estimand',
                        choices = c('ATE', 'ATT', 'ATC', 'ATM'),
                        selected = 'ATE'),
            hr(), 
            strong('Matching parameters'),
            numericInput(inputId = 'caliper',
                         label = 'Caliper',
                         value = 0.1,
                         min = 0.01,
                         step = 0.05),
            checkboxInput(inputId = 'replace',
                          label = 'Allow replacement',
                          value = FALSE)
        ),
        
        ##### Main Panel
        mainPanel(
            width = 9,
            tabsetPanel(
                tabPanel(
                    title = 'Scatterplot',
                    plotOutput('scatterplot', height = fig_height)
                ),
                tabPanel(
                    title = 'Stratification',
                    plotOutput('stratification_plot', height = fig_height)
                ),
                tabPanel(
                    title = 'Matching',
                    plotOutput('matching_plot', height = fig_height)
                ),
                tabPanel(
                    title = 'Weighting',
                    plotOutput('weighting_plot', height = fig_height)
                )
            )
        ) # End mainPanel
    ),
    
    tabPanel('About', includeMarkdown('about.md'))
))
