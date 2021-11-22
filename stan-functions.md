---
title: Stan Functions
category: Stan-lang
layout: 2017/sheet
tags: [WIP]
updated: 2021-11-22
intro: |
  Want to know more about Stan functions? Go to [Stan Functions Reference](https://mc-stan.org/docs/2_28/functions-reference/index.html).
---

## Getting started
{: .-three-column}

### Introduction
{: .-intro}

- [Basic Functions](https://mc-stan.org/docs/2_28/stan-users-guide/basic-functions.html) _(Stan User Guide: User Defined Functions)_
- [Helpful Functions Repository](https://github.com/spinkney/helpful_stan_functions) _(Lots of Examples)_

### Example
{: .-prime}

#### .stan
{: .-file}

```stan
functions {
  real add(real x, real y) {
    return x + y;
  }
  data {
      real x;
  }
  parameters {
      real y;
  }
  transformed parameters {
      real z = add(x, y);
  }
  model {
      y ~ std_normal();
  }
}
```

### Types of User Defined Functions

#### Basic Type Declarations

Typical variable types. No constraint types like `simplex[]`, `cholesky_factor_corr[]`, etc.!
```stan
real foo(real x);
vector foo(real x);
matrix foo(real x);
array[] real foo(real x);
array[ , ] real foo(real x);
array[ , , ] real foo(real x);
...
```

#### Void Type

These do not return any value.
```stan
void print_hello(real x) {
    print("hello");
}

void increment_lp(real x){
    target += 1;
}
```

#### Distribution Type

Keywords `_lpdf`, `_lpmf`, `_lcdf`  

```stan
functions {
    real my_normal_lpdf(real y, real mu, real sigma) {
        return normal_lpdf(y | mu, sigma);
    }
    real my_normal_lcdf(real y, real mu, real sigma) {
        return normal_lcdf(y | mu, sigma);   
    }
}
// ...
model {
    alpha ~ my_normal(mu, sigma);
    // or target += my_normal_lpdf(alpha | mu, sigma);
    target += my_normal_lcdf(x | mu, sigma);
}
```
#### Log-probability Type

Keyword `_lp`. These can access the log probability accumulator in the transformed parameters or model blocks.

```stan
functions {
  vector center_lp(vector beta_raw, real mu, real sigma) {
    beta_raw ~ std_normal();
    sigma ~ cauchy(0, 5);
    mu ~ cauchy(0, 2.5);
    return sigma * beta_raw + mu;
  }
  // ...
}
parameters {
  vector[K] beta_raw;
  real mu_beta;
  real<lower=0> sigma_beta;
  // ...
}
transformed parameters {
  vector[K] beta;
  // ...
  beta = center_lp(beta_raw, mu_beta, sigma_beta);
  // ...
}
```

#### Random number Type
Keywork `_rng`. Works in transformed data and generated quantities blocks.

```stan
real normal_lub_rng(real mu, real sigma, real lb, real ub) {
  real p_lb = normal_cdf(lb, mu, sigma);
  real p_ub = normal_cdf(ub, mu, sigma);
  real u = uniform_rng(p_lb, p_ub);
  real y = mu + sigma * inv_Phi(u);
  return y;
}
```

### Recursive Functions

```stan
matrix matrix_pow(matrix a, int n);

matrix matrix_pow(matrix a, int n) {
  if (n == 0) {
    return diag_matrix(rep_vector(1, rows(a)));
  } else {
    return a *  matrix_pow(a, n - 1);
  }
}
```
Although not a type, these require double declaration. Once with the signature and again with the function definition. See [Recursive Functions](https://mc-stan.org/docs/2_28/stan-users-guide/recursive-functions.html).

## Catching Errors
{: .-two-column}


### Reject statements

Detect bad or illegal outcomes.
```stan
real positive_number(real x) {
    if (x < 0) {
        reject("positive_number(x): x must be positive; found x = ", x);
    }

    return x;
}
```

### Print statements

Need to see what's happening in the function? Use print statements.

```stan
real sqrt_problem (real x) {
    real y = sqrt(x);

    // you forgot to check for negatives 
    // so you're debugging with print 
    // to see what's happening

    print("sqrt_problem: x is ", x, " return is ", y);

    return y;
}
```

## D
