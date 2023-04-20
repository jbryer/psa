function(input, output, session) {
    get_data <- reactive({
        X <- mvtnorm::rmvnorm(input$sample_size,
                              mean = c(0.5, 1, 0),
                              sigma = matrix(c(2, 1, 1,
                                               1, 1, 1,
                                               1, 1, 1), ncol = 3) )
        df <- tibble(
            x1 = X[, 1],
            x2 = X[, 2],
            x3 = X[, 3] > 0,
            treatment = as.numeric(- 0.5 + 0.25 * x1 + 0.75 * x2 + 0.05 * x3 + rnorm(input$sample_size, 0, 1) > 0),
            outcome = input$treatment_effect * treatment + rnorm(input$sample_size, 0, 1)
        )
        lr.out <- glm(treatment ~ x1 + x2 + x3, data = df, family = binomial(link='logit'))
        df$ps <- fitted(lr.out) # Get the propensity scores
        return(df)
    })
    
    output$scatterplot <- renderPlot({
        df <- get_data()
        ggplot(df, aes(x = x1, y = x2, shape = x3, color = factor(treatment))) + 
            geom_point() + 
            scale_color_manual('Treatment', values = palette2) +
            theme(legend.position = 'bottom')
        
    })
    
    output$loess_plot <- renderPlot({
        df <- get_data()
        psa::loess_plot(ps = df$ps,
                        treatment = df$treatment,
                        outcome = df$outcome)
    })
    
    output$matching_plot <- renderPlot({
        df <- get_data()
        match_out <- Matching::Match(Y = df$outcome,
                                     Tr = df$treatment,
                                     X = df$ps,
                                     caliper = input$caliper,
                                     replace = input$replace,
                                     estimand = input$estimand)
        
        psa::matching_plot(ps = df$ps,
                           treatment = df$treatment,
                           outcome = df$outcome,
                           index_treated = match_out$index.treated,
                           index_control = match_out$index.control)
    })
    
    output$weighting_plot <- renderPlot({
        df <- get_data()
        psa::weighting_plot(ps = df$ps,
                        treatment = df$treatment,
                        outcome = df$outcome,
                        estimand = input$estimand)
    })

    output$stratification_plot <- renderPlot({
        df <- get_data()
        psa::stratification_plot(ps = df$ps,
                                 treatment = df$treatment,
                                 outcome = df$outcome)
    })
}
