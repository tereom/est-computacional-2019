
data {
    int<lower=0> N;
    vector[N] y; 
}
parameters {
    real mu;
    real<lower=0> sigma2;
} 
model {
    y ~ normal(mu, sqrt(sigma2));
    mu ~ normal(1.5, 4);
    sigma2 ~ inv_gamma(3, 3);
}

