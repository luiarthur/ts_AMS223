---
title: "Time Series Final"
author: Arthur Lui
date: "17 March 2017"
geometry: margin=1in
fontsize: 12pt

# Uncomment if using natbib:

bibliography: final.bib
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
    - \newcommand{\I}{\mathrm{\mathbf{I}}}
    #
    - \allowdisplaybreaks
    - \def\M{\mathcal{M}}
    #
    - \def\dt{\delta_{\text{trend}}}
    - \def\ds{\delta_{\text{season}}}
---

## Previous Model ($\M_0$)

Previously, the model $\M_0$ (as follows) was fit to the UCSC web-search dataset:

$$
\begin{array}{rcll}
y_t &=& \theta_t + \nu_t, &\nu_t\sim \N(0,v) \\
\theta_t &=& \theta_{t-1} + w_t, &w_t\sim \N(0,vW_t) \\
\end{array}
$$

with $W_t$ specified by a discount factor and $v$ unknown (modeled by an 
inverse-gamma prior).

Figure \ref{fig:M0} summarizes the distribution of the parameters in $\M_0$.

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/M0.pdf}
\caption{$(\M_0)$ Filtering, smoothing, and forecasting distributions of the polynomial trend model of order one fitted on the UCSC dataset.}
\label{fig:M0}
\endmyfig


## DLM Form for Model $\M_1$

To improve the model, $\M_1$ introduces a trend component as well as all the
harmonic components into the time-invariant DLM. The resulting model is:

$$
\begin{array}{rcll}
y_t &=& \bm{F}'\bm\theta_t + \nu_t, &\nu_t\sim \N(0,v) \\
\bm\theta_t &=& \bm{G}\bm\theta_{t-1} + \bm{w_t}, &\bm{w_t}\sim \N(0,v\bm{W_t}) \\
\end{array}
$$

where $\bm F' = (\bm{E}_2, \cdots, \bm{E}_2, 1)$, 
$\bm G = \text{block-diagonal}\bc{\bm{J}_2(1), \bm{J}_2(1,\omega), \bm{J}_2(1,2\omega), \cdots, \bm{J}_2(1,5\omega), -1}$,
$v$ is unknown and modeled by an inverse-gamma prior, and $W_t$ is specified by
**two** discount factors -- one for the trend component ($\dt$) and the other
for the harmonic components ($\ds$).


## Optimal $\hat\delta$ for $\M_1$

In selecting the optimal discount factors, let $\delta = (\dt,\ds)$ be the
discount factors for the trend and seasonal components respectively.

Using the one-step-ahead forecasting distribution $Y_t | D_{t-1}$, which
follows a $T$ distribution, the observed predictive log-density can be computed
as 

$$\suml \log p(Y_t|D_{t-1}).$$

Figure \ref{fig:delta} shows the observed predictive log-density for a 2-D grid
of values for $\delta$. The $\delta$ which maximizes the log-density is
approximately $\hat\delta = \bm{(0.9,0.95)}$ (where the grey X-mark is).

\beginmyfig
\includegraphics[height=0.8\textwidth]{img/delta.pdf}
\caption{($\M_1$) Observed predictive Log density computed at different discount factors $\delta$}
\label{fig:delta}
\endmyfig

## Summary of Distributions ($\M_1$)

Figure \ref{fig:dist1} summarizes the forecasting distributions (one-step ahead at
each time and 12-step prediction) and the filtering and smoothing trend 
distributions for $\mathcal{M}_1$. In comparison to $\mathcal{M}_0$ the 
credible intervals for each distribution are much narrower. 
Moreover, the forecasting distributions capture the trend and seasonal nature
of the data much better.

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/dist1.pdf}
\caption{($\M_1$) One-step ahead $(y_t|D_{t-1})$ mean (red solid line). 12-step forecast mean (red dotted line). Filtering $(\theta_t|D_t)$ trend component mean (blue). Smoothing $(\theta_t|D_T)$ trend component mean (orange). All estimates are accompanied by 90\% credible intervals.}
\label{fig:dist1}
\endmyfig

By isolating the harmonic components for the filtering distribution (Figure
\ref{fig:filtHarm}) and the smoothing distribution (Figure \ref{fig:smHarm}),
we see that the harmonic components are being captured with narrow credible
intervals. The smoothing distribution has intervals which are more narrow.

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/filtHarm.pdf}
\caption{($M_1$) Harmonic Components of Filtering Distribution. The solid lines are the posterior means and the shaded regions are 90\% credible intervals}
\label{fig:filtHarm}
\endmyfig

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/smHarm.pdf}
\caption{($M_1$) Harmonic Components of Smoothing Distribution. The solid lines are the posterior means and the shaded regions are 90\% credible intervals}
\label{fig:smHarm}
\endmyfig

## Importance of Harmonics

Following the procedures outlined in section 8.6.7 by @west1997bayesian, the
probability of retention of each of the harmonics is computed. Harmonics
with high retention probabilities are to be kept in a reduced model.
The table below provides the retention probabilities of each harmonic.

\input{img/fprob.tex}



## Reduced Model ($\mathcal{M}_2$)

Harmonics with high retention probabilities (1,2,5, and 6, according to the table
above) are kept in a reduced model $\M_2$ (which is otherwise the same as $\M_1$).
The optimal discount factors were computed using the same grid-search technique
described previously to be $\hat\delta=(.91,.97)$ The same distributions
previously summarized are now summarized for $\M_2$ in Figure \ref{fig:dist2}.

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/dist2.pdf}
\caption{One-step ahead $(y_t|D_{t-1})$ mean (red solid line). 12-step forecast mean (red dotted line). Filtering $(\theta_t|D_t)$ trend component mean (blue). Smoothing $(\theta_t|D_T)$ trend component mean (orange). All estimates are accompanied by 90\% credible intervals.}
\label{fig:dist2}
\endmyfig

The filtering and smoothing distribution of the harmonic components are
summarized in Figures \ref{fig:filtHarm2} and \ref{fig:smHarm2} repectively.

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/filtHarm2.pdf}
\caption{Harmonic Components of Filtering Distribution. The solid lines are the posterior means and the shaded regions are 90\% credible intervals}
\label{fig:filtHarm2}
\endmyfig

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/smHarm2.pdf}
\caption{Harmonic Components of Smoothing Distribution. The solid lines are the posterior means and the shaded regions are 90\% credible intervals}
\label{fig:smHarm2}
\endmyfig

According to these figures, even with fewer parameters (harmonics), $\M_2$ and
$\M_1$ provide similar inferences. This provides some justification for using a
slightly more parsimonious model ($\M_2$).


## DLM with Autoregressive State ($\M_3$)

A DLM with an autoregressive state ($\M_3$) having the following form is now considered:

$$
\begin{array}{rcll}
y_t &=& \alpha + \beta t + x_t + \epsilon_t, &\epsilon_t\sim \N(0,v) \\
x_t &=& \sum_{j=1}^q \phi_j x_{t-1} + \nu_t, &\nu_t\sim \N(0,30) \\
\end{array}
$$

with $\alpha\sim\N(0,vw)$ and $\beta\sim\N(0,vw)$. Furthermore, conjugate
priors are chosen for $v,w$, and $\phi$. Specifically, $v\sim IG(.5,.5)$,
$w\sim IG(2,1)$, and $p(\phi) \propto 1$ (which while not conjugate is amenable
to a Gibbs update). 

Rewriting the model as follows provides greater clarity on the model structure:

$$
\begin{array}{rcll}
y_t &=& \bm{F}'\bm\theta_t + \epsilon_t, &\epsilon_t\sim \N(0,v) \\
\bm\theta_t &=& \bm{G_\phi}\bm\theta_{t-1} + \bm{\nu_t}, &\bm{\nu_t}\sim \N(0,30\I_p) \\
\end{array}
$$

with $\bm{F}' = (1,0,\cdots,0)$, $\bm G$ as written in equation (2.6) of 
@prado2010time, and $\theta_t = (x_t,...,x_{t-q+1})'$
. 

### Sampling Scheme for $\M_3$

The posterior distribution for the parameters in this model
can be sampled from using MCMC. This can be achieved via Gibbs sampling by 
iterating between the two conditional posteriors

$$
p(\theta_{1:T} \mid \bm{\phi}, v, \alpha, \beta, w, D_T) \leftrightarrow
p(\bm{\phi}, v, \alpha, \beta, w\mid \theta_{1:T} , D_T).
$$

The forward filtering backward sampling (FFBS) algorithm 
(by @fruhwirth1994data and @carter1994gibbs) can be used to sample from 
$p(\theta_{1:T} \mid \bm{\phi}, v, \alpha, \beta, w, D_T)$.
Since the full conditionals for each of the parameters on the right-hand side
(above) are available in closed-form and is easy to sample from, they can simply
be sampled from the full conditionals sequentially. Specifically,

$$
\begin{split}
\alpha \mid \bm{\phi},\beta,v,w,\bm\theta_{1:T}, D_T &\sim \N\p{\frac{w\sum_{t=1}^T(y_t-\beta t - \bm{F}'\bm\theta_t)}{1+wT}, \frac{wv}{1+wT}}\\
\beta \mid \bm{\phi},\alpha,v,w,\bm\theta_{1:T}, D_T &\sim \N\p{\frac{w\sum_{t=1}^T(y_t-\alpha - \bm{F}'\bm\theta_t)t}{1+w\sum_{t=1}^T t^2}, \frac{wv}{1+w\sum_{t=1}^T t^2}}\\
v \mid \bm{\phi},\alpha,\beta,w,\bm\theta_{1:T}, D_T &\sim IG\p{a_v+\frac{T}{2},
b+\frac{\sum_{t=1}^T(y_t-\alpha-\beta t - \bm{F}'\bm\theta_t)^2}{2}}\\
w \mid \bm{\phi},\alpha,\beta,v,\bm\theta_{1:T}, D_T &\sim IG\p{a_w+1,b_w+\frac{\alpha^2+\beta^2}{2v}}\\
\bm\phi \mid \alpha,\beta,v,w,\bm\theta_{1:T}, D_T &\sim\N_q
\p{(\bm\theta_{t-1}'\bm\theta_{t-1})^{-1}\bm\theta_{t-1}\bm\theta_t, 
30(\bm\theta_{t-1}'\bm\theta_{t-1})^{-1}}\\
\end{split}
$$

### Distributional Summary for $\M_3$

Figure \ref{fig:x} provides the posterior mean (solid line) and 90\% credible
interval (grey region) for $x_t$ for $t=1:T$. The process appears stationary.

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/x.pdf}
\caption{Posterior mean and 90\% CI for $x_t$}
\label{fig:x}
\endmyfig

Figure \ref{fig:ab} provides the posterior distribution for $(\alpha,\beta)$.
The equal-tailed 95\% credible intervals for $\alpha$ and $\beta$ are 
(81, 87) and (-0.31,-0.24) respectively. Neither intervals contain 0.

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/ab.pdf}
\caption{Posterior mean and 95\% CI for $\alpha$ and $\beta$.}
\label{fig:ab}
\endmyfig

Figure \ref{fig:vw} provides the posterior distribution for $(v,w)$.  The
equal-tailed 95\% credible intervals for $v$ and $w$ are (20,45) and
(15,221) respectively. The prior variance $w$ (for $\alpha,\beta$) being
large is reasonably as the prior mean for $(\alpha,\beta)$ was 0, but the
posterior mean for $\alpha$ was very far from 0.

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/vw.pdf}
\caption{Posterior mean and 95\% CI for $v$ and $w$. }
\label{fig:vw}
\endmyfig

Figure \ref{fig:root} summarizes the distribution for the moduli and periods
of the quasi-periodic roots of the characteristic polynomial ordered by period.
The plots show the posterior means with accompanying 95\% credible intervals.

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/root.pdf}
\caption{Posterior mean and 95\% CI for the moduli and periods.}
\label{fig:root}
\endmyfig

Note that I used $q=15$ because the partial autocorrelation of the
of the data seemed to start tapper off at 15 lags. (In reality I would
use a greater number of lags, but settled on 15 to reduce computation time.)
Figure \ref{fig:pacf} shows the partial autocorrelation of the data.

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/pacf.pdf}
\caption{Partial autocorrelation function of UCSC data.}
\label{fig:pacf}
\endmyfig

Figure \ref{fig:M3} summarizes the forecast distribution $(y_{T+12}|D_T)$.
The dotted line represents the posterior mean and the red region is
the accompanying 90\% credible interval. For comparison, the distribution
$(y_t | D_T)$ is also included.

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/M3.pdf}
\caption{Distribution of $(y_{T+12}|D_T)$ with posterior mean (dotted line) and
90\% credible interval (red shaded region).}
\label{fig:M3}
\endmyfig

## Discussion of $\M_1$, $\M_2$, and $\M_3$

$\M_3$ appears to capture the trend of the process. Smoothing enables the process
to capture the seasonal trends. However, compared to $\M_1$ and $\M_2$, it does
not predict future observations as convincingly with seasonal behavior. 
Moreover, computation time is much greater for $\M_3$ and has more parameters. 
One may be more likely to favor the more parsimonious models $\M_2$.

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


