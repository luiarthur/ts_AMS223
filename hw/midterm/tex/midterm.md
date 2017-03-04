---
title: "AMS 233 -- Time Series Midterm"
author: Arthur Lui
date: " 1 March 2017"
geometry: margin=1in
fontsize: 12pt

# Uncomment if using natbib:

# bibliography: BIB.bib
# bibliographystyle: plain 

# This is how you use bibtex refs: @nameOfRef
# see: http://www.mdlerch.com/tutorial-for-pandoc-citations-markdown-to-latex.html)

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

**4a) Perform a Bayesian spectral analysis of the first differences of these
data based on a single component harmonic regression model. Discuss your
results.**

**4b) Fit a polynomial trend model of order one to the original date.
Consider a model of the form:**

$$
\begin{aligned}
y_t      &= \theta_t + \nu_t,    &\nu_t &\sim \N(0,v)  \\
\theta_t &= \theta_{t-1} + w_t,  &w_t &\sim \N(0,vW_t) \\
\end{aligned}
$$

**where $v$ is unknown and $W_t$ is specified by a discount factor $\delta \in(0,1]$.**

Under the specified model the prior distribution for $v$ and the form of $W$ can 
be formulated as follows:
$$
\begin{split}
v|D_t &\sim IG\p{ \frac{n_t}{2},\frac{d_t}{2} } \\
W_t &= \p{\frac{1-\delta}{\delta}} C_{t-1} \\
\end{split}
$$

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

### Optimal Value $\hat\delta$

Figure \ref{fig:delta}

\beginmyfig
\includegraphics[height=0.5\textwidth]{img/delta.pdf}
\caption{some caption}
\label{fig:delta}
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


