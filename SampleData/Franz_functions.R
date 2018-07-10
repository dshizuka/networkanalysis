#================================================================================
# Network-based diffusion analysis
#================================================================================

# function that calculates the log-likelihood for the social learning model for a specific parameterization
# this function is used as input for an optimization routine that is provided in R
log_lik_sm <- function(tau, social_network, diffusion_data, time_max)
{
  log_lik <- 0
  group_size <- dim(social_network)[1]
  for (time in 1:time_max)    #for each time step
  {
    skilled <- diffusion_data < time    #individuals that were already skilled in the previous time step
    learning_rates <- 1 - exp(-1 * tau * colSums( ((skilled %*% matrix(1,1,group_size)) * social_network) ) )
      
    log_lik <- log_lik + sum( log(learning_rates * (diffusion_data == time) + (diffusion_data != time)) )    # individuals that learned in this time step, all learning rates of individuals that did not learn in this time step are automatically set to 1, thus they do not affect the log-likelihood
    log_lik <- log_lik + sum( log(( 1 - learning_rates) * (diffusion_data > time) + (diffusion_data <= time)))    # individuals that did not yet learn, all learning rates of individuals that are already skilled are automatically set to 1, thus they do not affect the log-likelihood
  }
  
  return(log_lik)
}

# function that calculates the log-likelihood for the asocial learning model for a specific parameterization
# this function is used as input for an optimization routine that is provided in R
log_lik_am <- function(alr, diffusion_data, time_max)
{
  log_lik <- 0
  for (time in 1:time_max)    #for each time step
  {      
    log_lik <- log_lik + sum(diffusion_data == time) * log(alr)     # individuals that learned in this time step
    log_lik <- log_lik + sum(diffusion_data > time) * log(1 - alr)    # individuals that did not yet learn 
  }
  
  return(log_lik)
}



# function that calculates AIC values and Akaike weights given the observed diffusion data and a network
nbda <- function(social_network, diffusion_data, tau_max, time_max)
{

  #maximum likelihood estimation for the asocial learning model
  alr_ml <- optimize(f = log_lik_am, lower = 0, upper = 1, maximum = TRUE, tol = 0.001, diffusion_data  = diffusion_data, time_max = time_max)
  max_log_lik_a <- alr_ml$objective

  #maximum likelihood estimation for the social learning model
  tau_ml <- optimize(f = log_lik_sm, lower = 0, upper = tau_max, maximum = TRUE, tol = 0.001, social_network = social_network, diffusion_data  = diffusion_data, time_max = time_max)
  max_log_lik_s <- tau_ml$objective
  

  #calculate AIC values and Akaike weights
  results = data.frame(AIC = c(0,0), Akaike_weight = c(0,0), Parameter_estimate = c(0,0), row.names =c("social learning model", "asocial learning model") )

  results$AIC[1] =  -2 * max_log_lik_s + 2
  results$AIC[2] =  -2 * max_log_lik_a + 2

  results$Akaike_weight[1] = exp(-0.5*(results$AIC[1] - min(results$AIC))) / ( exp(-0.5*(results$AIC[1] - min(results$AIC))) + exp(-0.5*(results$AIC[2] - min(results$AIC))) )
  results$Akaike_weight[2] = 1  - results$Akaike_weight[1]
  
  results$Parameter_estimate[1] = tau_ml$maximum    
  results$Parameter_estimate[2] = alr_ml$maximum 

  return(results)
}

#================================================================================


