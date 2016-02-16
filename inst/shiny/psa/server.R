shinyServer(function(input, output) {
	filedata <- reactive({
		infile <- input$file
		if(is.null(infile)) {
			return(NULL)
		}
		file <- NULL
		ext <- tools::file_ext(tolower(infile$name))
		if(ext %in% c('xls', 'xlsx')) {
			file <- gdata::read.xls(infile$datapath)
		} else if(ext == 'csv') {
			file <- read.csv(infile$datapath)
		} else if(ext %in% c('sav','sps')) {
			file <- foreign::read.spss(infile$datapath)
		}
		return(file)
	})
	
	output$ui.treat <- renderUI({
		df <- filedata()
		si <- NULL
		if(input$datafile == 'upload' & !is.null(df)) {
			si <- selectInput('treat', 'Treatment variable: ',
							  getTwoLevelVars(df))
		} else if(input$datafile != 'upload') {
			thedata <- datasets[[input$datafile]]
			si <- selectInput('treat', 'Treatment variable: ',
							  getTwoLevelVars(thedata$data),
							  selected = thedata$treat)
		}
		return(si)
	})
	
	output$ui.outcome <- renderUI({
		df <- filedata()
		si <- NULL
		if(input$datafile == 'upload' & !is.null(df)) {
			si <- selectInput('outcome', 'Outcome variable: ', names(df))
		} else if(input$datafile != 'upload') {
			thedata <- datasets[[input$datafile]]
			si <- selectInput('outcome', 'Outcome variable: ',
							  names(thedata$data),
							  selected = thedata$outcome)
		}
		return(si)
	})
	
	output$ui.covariates <- renderUI({
		df <- filedata()
		si <- NULL
		if(input$datafile == 'upload' & !is.null(df)) {
			si <- selectInput('covariates', 'Covariates: ', names(df), 
							  multiple=TRUE, selectize=FALSE, 
							  size=min(ncol(df), 10))
		} else if(input$datafile != 'upload') {
			thedata <- datasets[[input$datafile]]
			si <- selectInput('covariates', 'Covariates: ', names(thedata$data),
							  multiple=TRUE, selectize=FALSE, 
							  size=min(ncol(thedata$data), 10),
							  selected=thedata$covariates)
		}
		return(si)
	})
	
	output$ui.blockingVars <- renderUI({
		if(!is.null(input$covariates) & length(input$covariates) > 1) {
			checkboxGroupInput('blockingVars', 'Exact matching:',
							   input$covariates)
		} else {
			NULL
		}
	})
	
	output$datatable <- renderDataTable({
		df <- filedata()
		if(is.null(df)) {
			if(input$datafile != 'upload') {
				return(datasets[[input$datafile]]$data)
			}
		}
		if(!is.null(df)) {
			return(df)
		}
		return(NULL)
	})
	
	output$downloadData <- downloadHandler(
		filename = {
			if(input$datafile != 'upload') {
				paste0(input$datafile, '.csv')
			} else {
				paste0(input$file$name, '.csv')
			}
		},
		content = function(file) {
			if(input$datafile != 'upload') {
				df <- datasets[[input$datafile]]$data
			} else {
				df <- filedata()
			}
			write.csv(df, file, row.names=FALSE)
		}
	)
	
	output$tabs <- renderUI({
		df <- NULL
		
		input$refresh
		
		if(input$datafile == 'upload') {
			df <- filedata()
		} else {
			df <- datasets[[input$datafile]]$data
		}
		
############# Conduct PSA ######################################################
		if(FALSE) { # For testing in interactive R
			ds <- 3
			df <- datasets[[ds]]$data
			input <- list(
				treat = datasets[[ds]]$treat,
				outcome = datasets[[ds]]$outcome,
				covariates = datasets[[ds]]$covariates,
				nStrata = 5,
				blockingVars = character()
			)
		} # END TESTING
		
		formu <- lr.out <- NULL
		test <- !is.null(df) &
			!is.null(input$treat) &
			!is.null(input$outcome) &
			!is.null(input$covariates) &
			length(input$covariates) > 1 & # Make sure there are at least two covariates
			input$treat != input$outcome &
			input$treat %in% names(df) &
			all(input$covariates %in% names(df))

		if(length(test) > 0) { if(test) { # These cannot be combined or an error 
			                              # will be printed when starting the app
			formu <- as.formula(paste(input$treat, '~', 
									  paste(input$covariates, collapse=' + ')))
			lr.out <- glm(formu, data=df, family=binomial())
			
			n.strata <- 5
			exact <- list()
			if(!is.null(input$blockingVars) & length(input$blockingVars) > 0) {
				for(i in input$blockingVars) {
					if(is.numeric(df[,i]) & length(unique(df[,i])) > 2) {
						q <- quantile(df[,i], seq(0, 1, 1/n.strata))
						if(length(unique(q)) != (n.strata + 5)) { 
							# breaks would not be unique so we'll treat as a qualitative covariate
							exact[[i]] <- df[,i]
						} else {
							exact[[i]] <- cut(df[,i], q, include.lowest=TRUE, 
											  labels=letters[1:n.strata])
						}
					} else {
						exact[[i]] <- df[,i]
					}
				}
			}

			df.ps <- data.frame(
				ps = fitted(lr.out),
				tr = as.factor(df[,input$treat]),
				tr.logical = as.logical(df[,input$treat]),
				Y = df[,input$outcome],
				stringsAsFactors = FALSE
			)
			df.ps$strata <- cut(df.ps$ps, 
								quantile(df.ps$ps, seq(0, 1, 1/input$nStrata)),
								include.lowest=TRUE,
								labels = letters[1:input$nStrata])
			
			if(length(exact) > 0) {
				match.out <- Matchby(Y = df.ps$Y,
									 Tr = df.ps$tr.logical,
									 X = df.ps$ps,
									 by = exact)
			} else {
				match.out <- Match(Y = df.ps$Y,
								   Tr = df.ps$tr.logical,
								   X = df.ps$ps)
			}
			
			output$match.summary <- renderPrint(summary(match.out))
			
			output$lr.summary <- renderPrint(stargazer(lr.out, type='html',
										title='Logistic Regression Summary',
										single.row = TRUE, # TODO: doesn't work with report!
										report = "vc*t",
										intercept.bottom = FALSE,
										digits = 2
										))

			output$circ.psa <- renderPlot(
				circ.psa(response = df.ps$Y, 
						 treatment = df.ps$tr.logical,
						 strata = df.ps$strata)
			)

			output$circ.psa.sum.tab <- renderTable({
				circ <- circ.psa(response = df.ps$Y, 
								 treatment = df.ps$tr.logical,
								 strata = df.ps$strata)
				circ$summary.strata
			})
			
			output$circ.psa.sum <- renderText({
				circ <- circ.psa(response = df.ps$Y, 
								 treatment = df.ps$tr.logical,
								 strata = df.ps$strata)
				paste0(
					'ATE = ', prettyNum(circ$ATE, digits=2), '<br />',
					'CI = ', paste0(prettyNum(circ$CI.95, digits=2), collapse=', '), '<br />',
					't = ', prettyNum(circ$approx.t, digits=2)
				)
			})
			
			output$ds.plot <- renderPlot(
				granovagg.ds(data.frame(control=df[match.out$index.control,input$outcome],
										treated=df[match.out$index.treated,input$outcome]))
			)
			
			output$ps.density <- renderPlot(
				ggplot(df.ps, aes_string(x='ps', color='tr')) + 
					geom_density() +
					scale_color_hue('Treatment') + 
					xlab('Propensity Score') + ylab('Density') +
					ggtitle('Density Distribution of Propensity Scores')
			)
			
			output$ps.boxplot <- renderPlot({
				p <- ggplot(df.ps, aes_string(y='ps', x='tr', color='tr')) + 
					geom_boxplot() +
					coord_flip() +
					scale_color_hue('Treatment') + 
					xlab('Propensity Score') + ylab('Density') +
					ggtitle('Boxplot of Propensity Scores')
				if(nrow(df.ps) < 500) {
					p <- p + geom_jitter(alpha=0.3)
				}
				p
			})
			
			output$cv.bal.psa <- renderPlot({
				df.matrix <- model.matrix(formu, data=df)
				df.matrix <- df.matrix[,-1] # Remove the intercept
				
				cv.bal.psa(covariates = df.matrix,
						   treatment = df.ps$tr.logical,
						   propensity = df.ps$ps,
						   strata = input$nStrata) # TODO: make strata a input
			})
			
			output$balancePlot <- renderPlot({
				plot(psa::MatchBalance(df, formu, exact.covs=names(exact)))
			})
			
			output$loess <- renderPlot({
				multilevelPSA::loess.plot(df.ps$ps,
						   response = df.ps$Y,
						   treatment = df.ps$tr.logical)
			})
			
			output$datatable <- renderDataTable({
				cbind(df.ps, df)
			})
			
			
			# output$downloadData <- downloadHandler(
			# 	filename = {
			# 		if(input$datafile != 'upload') {
			# 			paste0(input$datafile, '.csv')
			# 		} else {
			# 			paste0(input$file$name, '.csv')
			# 		}
			# 	},
			# 	content = function(file) {
			# 		if(input$datafile != 'upload') {
			# 			df <- datasets[[input$datafile]]$data
			# 		} else {
			# 			df <- filedata()
			# 		}
			# 		write.csv(cbind(df.ps, df), file, row.names=FALSE)
			# 	}
			# )
		} }
############# End PSA ##########################################################
		
		##### Build the tabs
		mytabs <- list(
			tabPanel('Overview', br(), includeMarkdown('overview.md'),
					 hr(),
			{
				if(input$datafile != 'upload') {
					tabPanel('About Data',
							 includeMarkdown(datasets[[input$datafile]]$help.file))
				} else { NULL }
			}),
			{ ##### PS Summary tab #############################################
				if(!is.null(df) & !is.null(lr.out)) {
					tabPanel('PS Estimate', 
							 fluidRow(
							 	column(width=4, htmlOutput('lr.summary')),
							 	column(width=8, plotOutput('ps.density', height='300px'),
							 		   plotOutput('ps.boxplot', height='300px'))
							 )
					)
				} else { NULL }
			},
			{ ##### Balance tab ################################################
				if(!is.null(df) & !is.null(lr.out)) {
					tabPanel('Balance',
							 plotOutput('cv.bal.psa'),
							 plotOutput('balancePlot')
					)
				} else { NULL }
			},
			{ ##### Matching Results ###########################################
				if(!is.null(df) & !is.null(lr.out)) {
					tabPanel('Matching',
							 plotOutput('ds.plot'),
							 hr(),
							 verbatimTextOutput('match.summary')
					)
				} else { NULL }
			},
			{ ##### Loess Plot #################################################
				if(!is.null(df) & !is.null(lr.out)) {
					tabPanel('Loess',
							 plotOutput('loess')
					)
				} else { NULL }
			},
			{ ##### Stratification #############################################
				if(!is.null(df) & !is.null(lr.out)) {
					tabPanel('Stratification',
							 plotOutput('circ.psa'),
							 br(),
							 htmlOutput('circ.psa.sum'),
							 br(),
							 tableOutput('circ.psa.sum.tab'))
				} else { NULL } 
			}, 
			{ ##### Data tab ###################################################
				if(!is.null(df)) {
					tabPanel('Data', 
							 dataTableOutput('datatable')
					)
				} else { NULL }
			}
		)
		# Clean up the NULL tabs
		mytabs <- mytabs[!sapply(mytabs, is.null)]
		return(do.call(tabsetPanel, mytabs))
	}) #### End Tabs
})
