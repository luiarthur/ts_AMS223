---
title: "AMS 233 -- Time Series Midterm"
author: Arthur Lui
date: " 1 March 2017"
geometry: margin=1in
fontsize: 12pt

# Uncomment if using natbib:

bibliography: midterm.bib
bibliographystyle: plain 

# This is how you use bibtex refs: @nameOfRef
# see: http://www.mdlerch.com/tutorial-for-pandoc-citations-markdown-to-latex.html

header-includes: 
    - \usepackage{bm}
    - \usepackage{bbm}
    - \usepackage{graphicx}
    - \pagestyle{empty}
    - \newcommand{\norm}[1]{\left\lVert#1\right\rVert}
    - \newcommand{\p}[1]{\left(#1\right)}
    - \newcommand{\bk}[1]{\left[#1\right]}
    - \newcommand{\bc}[1]{ \left\{#1\right\} }
    - \newcommand{\abs}[1]{ \left|#1\right| }
    - \newcommand{\mat}{ \begin{pmatrix} }
    - \newcommand{\tam}{ \end{pmatrix} }
    - \newcommand{\suml}{ \sum_{i=1}^n }
    - \newcommand{\prodl}{ \prod_{i=1}^n }
    - \newcommand{\ds}{ \displaystyle }
    - \newcommand{\df}[2]{ \frac{d#1}{d#2} }
    - \newcommand{\ddf}[2]{ \frac{d^2#1}{d{#2}^2} }
    - \newcommand{\pd}[2]{ \frac{\partial#1}{\partial#2} }
    - \newcommand{\pdd}[2]{\frac{\partial^2#1}{\partial{#2}^2} }
    - \newcommand{\N}{ \mathcal{N} }
    - \newcommand{\E}{ \text{E} }
    - \def\given{~\bigg|~}
    # Figures in correct place
    - \usepackage{float}
    - \def\beginmyfig{\begin{figure}[H]\center}
    - \def\endmyfig{\end{figure}}
    - \newcommand{\iid}{\overset{iid}{\sim}}
    - \newcommand{\ind}{\overset{ind}{\sim}}
    #
    - \allowdisplaybreaks
    - \def\M{\mathcal{M}}
---

## UCSC Web searches (from Google Trends)

\beginmyfig
\includegraphics[height=0.7\textwidth]{img/ucsc.pdf}
\caption{Google Trends data of UCSC web searches over the years 2004 to 2016
(top), and the same data after first differencing (bottom).}
\label{fig:ucsc}
\endmyfig

\newpage

[//]: (4a. Perform a Bayesian spectral analysis of the first differences of
           these data based on a single component harmonic regression model. 
           Discuss your results.) 

## Bayesian Spectral Analysis of First Differences

A Bayesian spectral analysis of the first differences of the original dataset
was performed to investigate the periodicity of the data. The procedures 
in Section 3.1.1 of the text by @prado2010time were followed to perform
the analysis. Figure \ref{fig:spec} summarizes the results of the analysis.
The top figure is the posterior log density of the angular frequency $\omega$ 
evaluated at the Fourier frequencies $\omega_k = 2\pi k/T$. The 
posterior log density of the corresponding wavelengths $\lambda = 2\pi / \omega$
(in the lower figure) shows that that the posterior mode of the wavelength
is 6. This indicates that there the data may very well have a periodicity of 
6 months.

\beginmyfig
\includegraphics[height=0.7\textwidth]{img/spec.pdf}
\caption{Posterior log density of $\omega$ at the angular frequencies (top) and wavelengths $\lambda = 2\pi/\omega$ (bottom).}
\label{fig:spec}
\endmyfig

\newpage

## Fitting a Polynomial Trend Model of Order One

[//]: (4b. Fit a polynomial trend model of order one to the original date.
           Consider a model of the form $\bc{1,1,V,V W_t}$, where $v$ is unknown 
           and $W_t$ is specified by a discount factor $0<\delta:le1$.)

Consider the following model:

$$
\begin{aligned}
y_t      | v &= \theta_t + \nu_t,    &\nu_t &\sim \N(0,v)  \\
\theta_t | v &= \theta_{t-1} + w_t,  &w_t &\sim \N(0,vW_t) \\
\end{aligned}
$$

where $v | D_0 \sim IG\p{ \frac{n_0}{2},\frac{d_0}{2} }$ and $W_1 = \p{\frac{1-\delta}{\delta}} C_{0}$, and $n_0,d_0,C_0$ are specified constants.


[//]: (
In moving from time $t-1$ to time $t$, the parameters of the inverse gamma 
distribution for $v$ are updated as 
$$
\begin{cases}
d_t = d_{t-1} + (Y_t-f_t)^2/q_t \\
n_t = n_{t-1} + 1. \\
\end{cases}
$$
The initial values $(n_0,d_0)$ are chosen to be $n_0=d_0=1$ so that the prior mean
for $v$ at time $t=0$ is 1.
)

### Optimal Value Discount Factor $\hat\delta$

Using the one-step-ahead forecasting distribution $Y_t | D_{t-1}$, which follows a
$T$ distribution (the specific form is provided in the next section), the 
observed predictive log-density can be computed as 

$$\suml \log p(Y_t|D_{t-1}).$$

Figure \ref{fig:delta} shows the observed predictive log-density for a range
of values for $\delta$. The $\delta$ which maximizes the log-density is 
approximately $\hat\delta = \bm{0.867}$.

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/delta.pdf}
\caption{Observed predictive Log density of discount factor $\delta$}
\label{fig:delta}
\endmyfig

\newpage

### Filtering, Smoothing, and Forecasting Distributions

The filtering distribution and one-step ahead forecast distribution are
as follows:

$$
\begin{aligned}
\theta_{t-1} \mid D_{t-1} &\sim T_{n_{t-1}}(m_{t-1}, C_{t-1}) \\
\theta_{t} \mid D_{t-1} &\sim T_{n_{t-1}}(m_{t-1}, R_t) \\
y_t \mid D_{t-1} &\sim T_{n_{t-1}}(m_{t-1}, Q_t) \\
\theta_t \mid D_t &\sim T_{n_t}(m_t, C_t) \\
\end{aligned}
$$

where 

- $W_t = C_{t-1} \ds\p{\frac{1-\hat\delta}{\hat\delta}}$
- $R_t = C_{t-1} + W_t$
- $Q_t = R_t + S_{t-1}$
- $e_t = y_t - m_{t-1}$
- $A_t = R_t / Q_t$
- $C_t = S_t A_t$
- $n_t = n_{t-1} + 1$
- $S_t = \ds S_{t-1} + \frac{S_{t-1}}{n_t}\p{\frac{e_t^2}{Q_t}-1}$
- $m_t = m_{t-1} + A_te_t$.


The smoothing distribution is

$$
\theta_{t-k} | D_t \sim T_{n_t}\p{a_t(-k), \p{\frac{S_t}{S_{t-k}}}R_t(-k)}, ~ k \ge 0,
$$

where $S_t$ and the functions $a_t(-k)$ and $R_t(-k)$ are defined in Theorem 4.4 in 
@prado2010time.

The forecasting distributions for $y$ and $\theta$ are

$$
\begin{split}
\theta_{t+k} | D_t &\sim T_{n_t}\p{a_t(k), R_t(k)} \\
y_{t+k} | D_t &\sim T_{n_t}\p{f_t(k), Q_t(k)}, \\
\end{split}
$$

where the functions $a_t(k), R_t(k), f_t(k), Q_t(k)$ are defined in 
Summary 4.6 in @prado2010time.

\newpage

Figure \ref{fig:inference} summarizes the filtering, smoothing, and forecasting 
distributions for this model fitted to the UCSC dataset.

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/inference.pdf}
\caption{Filtering, smoothing, and forecasting distributions of the polynomial trend model of order one fitted on the UCSC dataset.}
\label{fig:inference}
\endmyfig

First note that the posterior mean for the filtering distribution is the same
as that of the one-step ahead distribution, and is simply $m_{t-1}$. This is 
represented by the blue and orange line. The 95% credible intervals for the
filtering distribution and one-step ahead distribution are shaded in blue and
orange respectively.

The posterior mean and 95% credible interval smoothing distribution is represented
by the red line and red shaded region respectively. 

Compared to the filtering and one-step ahead distributions, the credible
interval of the smoothing distribution is narrower, and the posterior mean is
smoother. Moreover, the credible interval for the forecasting distribution
is the widest.

The 12-steps ahead forecasting distributions for $\theta_t$ and $y_t$ are
represented in yellow and green respectively. The posterior means are the same
for the distributions and is represented by the dark green line with yellow dots
(which starts a little after year 2017). The 95% credible intervals for 
$\theta_t$ and $y_t$ are shaded in green and yellow respectively. The latter 
being wider. They both have constantly increasing credible intervals, with the 
interval for $\theta_{t+k}$ widening faster than that of $y_{t+k}$.


### Discussion of Model Fit

Clearly, while the distributions follow the trend of the data, they do not
capture well the entire structure of the data. An improved model would take
into account a seasonal / cyclical component as the data clearly exhibits
seasonal behavior.  Moreover, from the spectral analysis done at the beginning,
one could speculate that an important harmonic would be 6 months. This follows
from observing an accentuated peak in the posterior log density of the
wavelength at 6 months. In summary, I would consider fitting a DLM of the form 

$$\bc{F,G,V,W_t},$$

where

- $F=(1~E_2)'$, 

- $G=\text{block-diagonal}\bc{1, J_2(\lambda,\omega)}$, 

- $V | D_0 \sim IG(n_0/2,d_0/2)$, and 

- $W_t=C_{t-1} \p{\frac{1-\delta}{\delta}}$.



[//]: # ( example image embedding
\beginmyfig
\includegraphics[height=0.5\textwidth]{path/to/img/img.pdf}
\caption{some caption}
\label{fig:mylabel}
% reference by: \ref{fig:mylabel}
\endmyfig
)
[//]: # ( example image embedding
> ![some caption.\label{mylabel}](path/to/img/img.pdf){ height=70% }
)

[//]: # ( example two figs side-by-side
\begin{figure*}
  \begin{minipage}{.45\linewidth}
    \centering \includegraphics[height=1\textwidth]{img1.pdf}
    \caption{some caption}
    \label{fig:myLabel1}
  \end{minipage}\hfill
  \begin{minipage}{.45\linewidth}
    \centering \includegraphics[height=1\textwidth]{img2.pdf}
    \caption{some caption}
    \label{fig:myLabel2}
  \end{minipage}
\end{figure*}
)


[//]: # (Footnotes:)


