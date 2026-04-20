make_kobe_fup <- function(replist_s1){
  
  years <- seq(replist_s1$startyr, replist_s1$endyr, 1)
  
  SSB_years <- paste0("SSB_", years)
  F_years <- paste0("F_", years)
  
  SSB_year <- replist_s1$derived_quants %>%
    dplyr::filter(Label %in% SSB_years)
  
  F_year <- replist_s1$derived_quants %>%
    dplyr::filter(Label %in% F_years)
  
  SSB_msy <-replist_s1$derived_quants$Value[replist_s1$derived_quants$Label == "SSB_Btgt"]
  F_msy <-replist_s1$derived_quants$Value[replist_s1$derived_quants$Label == "annF_MSY"]
  
  kobe.dat<-data.frame(years = years,
                       SSB_SSBmsy = SSB_year$Value/SSB_msy,
                       F_Fmsy = F_year$Value/F_msy)
  
  colores <- ggsci::pal_igv("default", alpha = 0.1)(10)
  
  
  xl <- c(0, round(max(kobe.dat$SSB_SSBmsy)+0.1, 1))
  yl <-  c(0, round(max(kobe.dat$F_Fmsy)+0.1,1))
  
  kobe <- ggplot(kobe.dat, aes(SSB_SSBmsy, F_Fmsy)) + scale_x_continuous(limits=xl) + scale_y_continuous(limits=yl)
  kobe <- kobe +
    geom_rect(xmin = 0, xmax = 0.5, ymin = 0, ymax = yl[2], fill = colores[2]) +
    geom_rect(xmin = 0.5, xmax = 0.95, ymin = 0, ymax = 1, fill = colores[4]) +
    geom_rect(xmin = 1.05, xmax = xl[2], ymin = 1, ymax = yl[2], fill = '#E5E5E5') +
    geom_rect(xmin = 1.05, xmax = xl[2], ymin = 0, ymax = 1, fill = colores[9]) +
    geom_rect(xmin = 0.95, xmax = 1.05, ymin = 0, ymax = 1, fill = colores[3]) +
    geom_rect(xmin = 0.95, xmax = 1.05, ymin = 1, ymax = yl[2], fill = '#D4D4D4') +
    geom_rect(xmin = 0.5, xmax = 0.95, ymin = 1, ymax = yl[2], fill = '#B5B5B5') +
    geom_rect(xmin = 0, xmax = 0.5, ymin = 1, ymax = yl[2], fill = '#9F9F9F') +
    # geom_segment(aes(x = 0.95, y = 0, xend = 0.95, yend = 1, colour = 1), data = kobe_df)  +
    # geom_segment(aes(x = 1.05, y = 0, xend = 1.05, yend = 1, colour = 1), data = kobe_df) +
    geom_hline(yintercept = 1, linewidth=.3, linetype="dotted") +
    geom_vline(xintercept = 1, linewidth=.3, linetype="dotted") +
    geom_path(linetype = 2, linewidth = 0.3) +
    geom_point(size = 2, alpha = 0.5, shape = 21, fill= "grey22") +
    geom_text(aes(label=kobe.dat[,1]), size=2, hjust=-0.4, vjust=0.3) +
    theme(axis.text=element_text(size=18), axis.title=element_text(size=22), legend.title = element_text(size=12)) + theme(legend.text=element_text(size=10)) +
    labs(x=expression(B/B[RMS]), y=expression(F/F[RMS])) +
    theme(strip.text = element_text( size = 18, color = "black"), strip.background = element_rect(color="grey85", fill="grey85")) +
    scale_fill_manual(values = c("grey22", "tomato")) + 
    ggthemes::theme_few()
  
  return(kobe)
}

# Function to read summaries, extract likelihoods, and create a summary table with limited decimals
create_summary_table <- function(model_paths, decimals = 2) {
  # Read the summary files for all models
  summaries <- lapply(model_paths, function(path) {
    SS_read_summary(file = paste0(path, "/ss_summary.sso"), verbose = FALSE)
  })
  
  # Extract the likelihoods from all summaries
  likelihoods <- lapply(summaries, function(summary) summary$likelihoods)
  
  # Combine the likelihoods into one data frame
  combined_lik <- do.call(cbind, likelihoods)
  
  # Create column names for the combined likelihoods
  colnames(combined_lik) <- paste0("S", seq_along(model_paths))
  
  # Round the values to the specified number of decimal places
  combined_lik <- round(combined_lik, decimals)
  
  # Create a summary table with knitr and kableExtra
  kable_table <- knitr::kable(combined_lik, caption = "Summary Table") %>%
    kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"), full_width = FALSE)
  
  return(kable_table)
}

calculate_prob_catch <- function(model_SS_output) {
  
  DerQuants = model_SS_output$derived_quants
  indxForeCatch <- grep("ForeCatch_", DerQuants$Label)
  ForeCatch <- DerQuants[indxForeCatch, 1:3]
  init_year <- head(ForeCatch, n = 1)
  last_year <- tail(ForeCatch, n = 1)
  FistYrPrj <- as.numeric(sub("ForeCatch_", "", init_year$Label))
  LastYrPrj <- as.numeric(sub("ForeCatch_", "", last_year$Label))
  
  ssb_Prj <- DerQuants[DerQuants$Label %in% paste0("SSB_", FistYrPrj:LastYrPrj),1:3]
  catch_Prj = DerQuants[DerQuants$Label %in% paste0("ForeCatch_", FistYrPrj:LastYrPrj),1:3]
  
  # Calculate Bmsy_mean
  SSB_MSY = DerQuants[DerQuants$Label %in% "SSB_MSY",1:3]
  SSBmsy_mean <- SSB_MSY$Value
  
  # Set up scenarios and results list
  ## RL: more scenarios could be added here (only 1 for now)
  scenarios <- c("Fmsy")
  prob_results <- vector("list", length(scenarios))
  names(prob_results) <- scenarios
  
  for(i in 1:length(scenarios)) {
    
    ## Calculate probability for SSB
    ssb_probs <- (1 - pnorm(SSBmsy_mean, ssb_Prj[,"Value"], ssb_Prj[,"StdDev"])) * 100
    
    # Combine results
    prob_results[[i]] <- cbind(
      Year = FistYrPrj:LastYrPrj ,
      SSB_prob = round(ssb_probs, 2),
      Catch = round(catch_Prj[,"Value"], 2),
      SSB = round(ssb_Prj[,"Value"], 2),
      SD = round(ssb_Prj[,"Value"], 2)
    )
  }
  
  
  return(prob_results)
}


plot_prSSBAboveBmsy_catch <- function(results, maintex="",
                                      scenarios_to_plot = c("0.75x", "Fmsy", "0x"),
                                      end_year = 2041) {
  ## RL: it depends from outputs from calculate_prob_catch()
  available_scenarios <- names(results)
  valid_scenarios <- scenarios_to_plot[scenarios_to_plot %in% available_scenarios]
  
  if(length(valid_scenarios) == 0) {
    stop("None of the requested scenarios found in results")
  }
  
  plot_data <- do.call(rbind, lapply(valid_scenarios, function(scenario) {
    data <- data.frame(
      Year = results[[scenario]][,"Year"],
      SSB_prob = results[[scenario]][,"SSB_prob"],
      Catch = results[[scenario]][,"Catch"],
      Scenario = scenario
    )
    # Filter data up to end_year
    data[data$Year <= end_year, ]
  }))
  
  # Calculate max values for scaling
  max_catch <- max(plot_data$Catch)
  
  p <- ggplot(plot_data, aes(x = Year)) +
    # SSB probability lines
    geom_line(aes(y = SSB_prob, color = Scenario), linewidth = 1) +
    geom_point(aes(y = SSB_prob, color = Scenario), size = 2) +
    # Catch lines (dashed)
    geom_line(aes(y = Catch * 100/max_catch, color = Scenario), 
              linewidth = 1, linetype = "dashed") +
    # Primary axis (SSB probability)
    scale_y_continuous(
      name = "Probability SBt above SBmsy (%)",
      breaks = seq(0, 100, by = 10),
      limits = c(0, NA),
      sec.axis = sec_axis(~ . * max_catch/100,
                          name = "Catch (mt)",
                          breaks = round(seq(0, max_catch, length.out = 11),0))
    ) +
    scale_x_continuous(breaks = seq(min(plot_data$Year), max(plot_data$Year), by = 2)) +
    labs(
      x = "Year",
      title = paste0("SSB Probability and Catch by Scenario: ", maintex),
      color = "Scenario"
    ) +
    theme_bw() +
    theme(
      text = element_text(size = 14),
      axis.title.y = element_text(size = 16, color = "black"),
      axis.title.y.right = element_text(size = 16, color = "black"),
      axis.title.x = element_text(size = 16),
      axis.text = element_text(size = 12),
      legend.title = element_text(size = 14),
      legend.text = element_text(size = 12),
      plot.title = element_text(size = 18),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
  
  return(p)
}

getMSY_RP <- function(model_SS_output) {
  DerQuants <- model_SS_output$derived_quants
  Fmsy <- DerQuants[DerQuants$Label %in% "annF_MSY", 1:3]
  SSB_MSY <- DerQuants[DerQuants$Label %in% "SSB_MSY", 1:3]
  Catch_MSY <- DerQuants[DerQuants$Label %in% "Dead_Catch_MSY", 1:3]
  result_df <- data.frame(Fmsy = Fmsy$Value,
                          SSB_MSY = SSB_MSY$Value,
                          Catch_MSY = Catch_MSY$Value)
  
  rownames(result_df) <- NULL
  
  return(result_df)
}
