# ParseRegex
This is a program to visualise two character regexes as a DFA

## Installation
Download the a.out file, which can be directly run as a binary

## Usage
Run the ./a.out < file, where file contains the regex you want to parse and build the DFA for.
Copy paste the output in http://www.webgraphviz.com/ to generate the graph.

## Overview
This project implements a parser using Bison, designed to generate and process syntax trees for regular expressions. The code focuses on constructing a Deterministic Finite Automaton (DFA) by computing the firstpos, lastpos, and followpos sets for each node in the syntax tree. The operations in regex supported are concatenation, or and kleine star. Precedence can be imposed in the form of brackets.
