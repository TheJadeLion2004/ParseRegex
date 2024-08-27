# ParseRegex
This is a program to visualise two character regexes as a DFA

## Installation
Download the a.out file, which can be directly run as a binary

## Usage
Run the ./a.out < file, where file contains the regex you want to parse and build the DFA for.
Copy paste the output in http://www.webgraphviz.com/ to generate the graph.

## Overview
This project implements a parser using Bison, designed to generate and process syntax trees for regular expressions. The code focuses on constructing a **Deterministic Finite Automaton (DFA)** by computing the _firstpos_, _lastpos_, and _followpos_ sets for each node in the syntax tree. The parser supports essential regex operations such as _concatenation_ (.), _union_ (|), and the _Kleene star_ (*), with precedence handled using brackets. The syntax tree is systematically analyzed to determine attributes like **nullable**, which indicates whether a node can produce an empty string, and the **DFA start state** (dfastart) is identified for automaton entry.

## Debugging Tools
A followpos map is provided, and functions to print the list of edge structs and node structs is provided.

## Footnote
For any comments/feedback, you can contact me at my email. I would love to collaborate on expanding this project to support more general regexes on a standard character set, and to support extended regexes. If anyone is interested in collaborating, please do reach out to me at my email.
