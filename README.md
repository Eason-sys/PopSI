# PopSI

This repository provides MATLAB code and datasets for the paper:  
**"Towards Popularity-Aware Recommendation: A Multi-Behavior Enhanced Framework with Orthogonality Constraint"**.

## Introduction

**PopSI** is a novel framework for building popularity-aware top-K recommendations by integrating multi-behavior side information with an orthogonality constraint.  
The core idea behind our approach is that leveraging multi-behavior feedback enables more accurate estimation of latent item features, while constructing a popularity-invariant item feature space helps improve debiasing performance.

## Datasets

We evaluate PopSI on three datasets: **Beibei**, **Tmall**, and **Yelp**.  
For all datasets, **purchase behavior** is treated as the target behavior. Users and items with very few interactions are filtered out to ensure data quality.

You may also refer to the raw data here:

- [Beibei](https://github.com/akaxlh/MB-GMN/tree/main/Datasets/beibei)
- [Tmall](https://tianchi.aliyun.com/dataset/46)
- [Yelp](https://business.yelp.com/data/resources/open-dataset/)

## Running PopSI

All required utility functions and datasets are included in this directory. To reproduce the experimental results, simply run:

```matlab
run_Tmall.m
