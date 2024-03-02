% \NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{CompilerAssignment}[Template for Jinyi Xia's Compiler Report]
\PassOptionsToClass{a4paper}{article}
\LoadClassWithOptions{article}

\RequirePackage[fontsize=12pt]{fontsize}
\RequirePackage[margin=2.4cm]{geometry}
\RequirePackage{amsmath}
\RequirePackage{amsfonts}
\RequirePackage{amssymb}
\RequirePackage{mathrsfs}
\RequirePackage{graphicx}
\RequirePackage{subfig}
\RequirePackage{xcolor}
\RequirePackage{listings}
\RequirePackage{longtable}
\RequirePackage{booktabs,tabularx}
\RequirePackage{multirow}
\RequirePackage{fancyhdr}
\RequirePackage{lastpage}
\RequirePackage[hidelinks]{hyperref}
\RequirePackage{mathptmx}
\RequirePackage{parskip}
\RequirePackage{cleveref}
\RequirePackage{draftwatermark}

%\SetWatermarkText{github.com/XIA-Jinyi}
\SetWatermarkText{}
\SetWatermarkScale{0.5}

% \linespread{1.1}
% \setlength{\headheight}{15pt}
% \pagestyle{fancy}
% \fancyhead[L]{Compiler: \@title}
% \fancyhead[R]{Jinyi Xia}
% \fancyfoot[C]{Page \thepage \ of \pageref{LastPage}}

\definecolor{dkgreen}{rgb}{0,0.6,0}
\definecolor{Rhodamine}{rgb}{0.82,0.1,0.26}
\definecolor{mauve}{rgb}{0.58,0,0.82}

\lstset{
  showstringspaces=false,
  columns=flexible,
  framerule=0pt,
  basicstyle={\small\ttfamily},
  numbers=left,
  numberstyle=\footnotesize,
  keywordstyle=\bfseries\color{blue},
  commentstyle=\color{dkgreen},
  stringstyle=\color{mauve},
  emphstyle=\color{Rhodamine},
  breaklines=true,
  breakatwhitespace=true,
  tabsize=4,
  captionpos=b
}

\makeatletter
\renewcommand{\@maketitle}{
    {
      % \lineskip .5em
      \centering\small
      % \resizebox{\textwidth}{!}{
      \begin{tabular*}{\textwidth}{ll}
        \textsc{Name:} & Jinyi Xia \\
        \textsc{Student ID:} & 2021212057 \\
        \textsc{Class Number:} & 2021211802 \\
        % \textsc{Container Number:} & a4d4f6a5498a4e912a4d1a76a7fa36cf23af64b416688d222a8968a38b29a711 \\
        \bottomrule
      \end{tabular*}
      % }
      \par
    }
    \vskip 1.5em
    {\centering\bfseries\LARGE\textsc{\@title}\par}
    \vskip 0.5em
}
\makeatother
