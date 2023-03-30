shinyUI(navbarPage(title='Propensity Score Analysis',
	
	##### Header Panel
	#headerPanel("Propensity Score Analsyis"),
	
	##### Sidebar Panel
	tabPanel('PSA',
		sidebarPanel(width=3,
	
			selectInput("datafile", "Data:", c(names(datasets),
											   'Upload Data'='upload')),
			
			conditionalPanel("input.datafile == 'upload'",
				fileInput("file", "Upload data file:")
			),
			uiOutput('ui.treat'),
			uiOutput('ui.outcome'),
			uiOutput('ui.covariates'),
			
			hr(),
			
			sliderInput('nStrata', 'Number of Strata: ', min=5, max=10, value=5, step=1),
			uiOutput('ui.blockingVars'),
			
			hr(),
			
			actionButton('refresh', 'Refresh'), downloadButton('downloadData', 'Download Data')
		),
		
		##### Main Panel
		mainPanel(width=9,
			
			uiOutput('tabs')
	
		) # End mainPanel
	),
	
	tabPanel('About', includeMarkdown('about.md')),
	
	tabPanel('References', includeMarkdown('references.md') )
))
