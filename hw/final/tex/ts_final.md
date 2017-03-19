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

## Previous Model

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/M0.pdf}
\caption{Filtering, smoothing, and forecasting distributions of the polynomial trend model of order one fitted on the UCSC dataset.}
\label{fig:M0}
\endmyfig


## DLM Form
FIXME

## Optimal $\hat\delta$

Let $\delta = (\dt,\ds)$ be the discount factors for the trend and seasonal
components respectively.

Using the one-step-ahead forecasting distribution $Y_t | D_{t-1}$, which follows a
$T$ distribution (the specific form is provided in the next section), the 
observed predictive log-density can be computed as 

$$\suml \log p(Y_t|D_{t-1}).$$

Figure \ref{fig:delta} shows the observed predictive log-density for a 2-D grid
of values for $\delta$. The $\delta$ which maximizes the log-density is
approximately $\hat\delta = \bm{(.9,.95)}$.

\beginmyfig
\includegraphics[height=0.6\textwidth]{img/delta.pdf}
\caption{Observed predictive Log density computed at different discount factors $\delta$}
\label{fig:delta}
\endmyfig

$\hat\delta = (\widehat\dt, \widehat\ds) = (0.9,0.94)$.

## Summary of Distributions

This section summarizes the following distributions

- Marginal Filtering Distributions $(\theta_t | D_t)$
    - trend component
    - each harmonic component
- Marginal Smoothing Distribution $(\theta_t | D_T)$
    - trend component
    - each harmonic component
- One-step ahead Forecast Distribution $(y_t \mid D_{t-1})$ for $t=1:T$
- Forecast Distribution $(y_{T+k} \mid D_T)$, for $k=1:12$

Figure \ref{fig:dist1} summarizes the forecasting distributions (one-step ahead at
each time and 12-step prediction) and the filtering and smoothing trend 
distributions for $\mathcal{M}_1$. In comparison to $\mathcal{M}_0$ the 
credible intervals for each distribution are much narrower. 
Moreover, the forecasting distributions capture the trend and seasonal nature
of the data much better.

\beginmyfig
\includegraphics[height=0.6\textwidth]{img/dist1.pdf}
\caption{One-step ahead $(y_t|D_{t-1})$ mean (red solid line). 12-step forecast mean (red dotted line). Filtering $(\theta_t|D_t)$ trend component mean (blue). Smoothing $(\theta_t|D_T)$ trend component mean (orange). All estimates are accompanied by 90\% credible intervals.}
\label{fig:dist1}
\endmyfig

By isolating the harmonic components for the filtering distribution (Figure
\ref{fig:filtHarm}) and the smoothing distribution (Figure \ref{fig:smHarm}),
we see that the harmonic components are being captured with narrow credible
intervals. The smoothing distribution has intervals which are more narrow.

\beginmyfig
\includegraphics[height=0.6\textwidth]{img/filtHarm.pdf}
\caption{Harmonic Components of Filtering Distribution. The solid lines are the posterior means and the shaded regions are 90\% credible intervals}
\label{fig:filtHarm}
\endmyfig

\beginmyfig
\includegraphics[height=0.6\textwidth]{img/smHarm.pdf}
\caption{Harmonic Components of Smoothing Distribution. The solid lines are the posterior means and the shaded regions are 90\% credible intervals}
\label{fig:smHarm}
\endmyfig

## Importance of Harmonics

Following the procedures outlined in section 8.6.7 by @west1997bayesian, the
probability of retention of each of the harmonics is computed. Harmonics
with high retention probabilities are to be kept in a reduced model.
The table below provides the retention probabilities of each harmonic.

\input{img/fprob.tex}

Consequently, harmonics 1,2,5, and 6 (the Nyquist frequency) are kept in the 
reduced model $(\mathcal{M}_2)$.


## Reduced Model ($\mathcal{M}_2$)

\beginmyfig
\includegraphics[height=0.6\textwidth]{img/dist2.pdf}
\caption{One-step ahead $(y_t|D_{t-1})$ mean (red solid line). 12-step forecast mean (red dotted line). Filtering $(\theta_t|D_t)$ trend component mean (blue). Smoothing $(\theta_t|D_T)$ trend component mean (orange). All estimates are accompanied by 90\% credible intervals.}
\label{fig:dist2}
\endmyfig

\beginmyfig
\includegraphics[height=0.6\textwidth]{img/filtHarm2.pdf}
\caption{Harmonic Components of Filtering Distribution. The solid lines are the posterior means and the shaded regions are 90\% credible intervals}
\label{fig:filtHarm2}
\endmyfig

\beginmyfig
\includegraphics[height=0.6\textwidth]{img/smHarm2.pdf}
\caption{Harmonic Components of Smoothing Distribution. The solid lines are the posterior means and the shaded regions are 90\% credible intervals}
\label{fig:smHarm2}
\endmyfig



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


