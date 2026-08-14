# Freshwater fish phylogenetic super tree (peer review version)

# Anonymous peer review version
 
## Overview

This repository contains the code and documentation used to construct
a time-calibrated informal super tree for the freshwater fish species in the FishScales
data base.

The resulting tree integrates phylogenetic information from 11 published
phylogenetic studies and contains 815 species.

**NOTE:** The tree was constructed for use in diversity studies. As information in
super tree is compiled from multiple sources with differing methodologies,
this tree is not suited for evolutionary analyses

## Data access

The released phylogenetic tree is archived on Zenodo:

[DOI / Zenodo badge]

Available formats:

- Nexus (.nex)
- R object (.rds)

We provide the following data in this repository:

* `data/tree_source.csv` - Basic summary, citations, and download location of
raw phylogenetic trees used in super tree construction
* `data/species_source.csv` - List of all species in super tree, and their data
sources.
* `data/tree_appendix.pdf` - Detailed methodology for super tree creation.

## Tree construction

The super tree was constructed using the methods of 
[Castiglione et al. (2022)](https://doi.org/10.1111/pala.12588) with the 
tree.merger function from the [‘RRphylo’ R package](https://doi.org/10.32614/CRAN.package.RRphylo). 
In this manner, one tree acts as the backbone tree in 
which nodes and tips are added using the other trees as a reference for node 
position and age. For detailed methodology, see `data/tree_appendix`.

The complete construction workflow is contained in:

`scripts/01_construct_supertree.R`

## Source phylogenies

| Source | Number of tree tips |Percent of tree |  Reference |
|:---:|:---:|:---:|:---:|
| Fish Tree of life |715| 87.9% |Rabosky et al., (2018) |
| TimeTree 5 | 33|4.1% |Kumar et al., (2022)|
| Taxon-specific trees | 32|3.9% |`data/source_trees.csv`|
| non-time calibrated trees |19 |2.3% |`data/source_trees.csv`|
| literature review |16 |2.0% |`data/species_source`|

We used the [Fish Tree of Life (Rabosky et al., 2018)](https://fishtreeoflife.org), 
an extensive phylogeny of the class Actinopterygii, as the backbone tree. This 
tree contained ~89% of the species (726) in the FishScales dataset. These data
are called in using the `fishtree_phylogeny` function from the `fishtree' 
[R package](https://doi.org/10.32614/CRAN.package.fishtree).

The remaining 89 species were filled in with phylogenetic data from 
[TimeTree 5 (Kumar et al., 2022)](https://timetree.org), 
other smaller taxon-specific trees (chronograms),
position in non-time calibrated trees (phylograms or cladograms), or from
literature review. 

Eleven tips in Fish Tree of Life were swapped out for those in 
taxon-specific trees when entire genera needed to be replaced, reducing the
Fish Tree of Life to 87.7% of the tree tips (715).

The original source trees are not redistributed in this repository; 
see `data/source_trees.csv` for complete source information, including citations 
and links. For detailed information on what species were sourced from which
tree, and full citations,  see `data/species_source` 
and `data/tree_appendix.pdf`.

## Tree characteristics

- Number of tips: 815
- Number of internal nodes: 814
- Rooting: Outgroup = class Petromyzontida
- Branch lengths: chronogram
- Taxonomic coverage: Actinopterygii and Petromyzontida
- version: peer review version
- Construction method: time-calibrated informal super tree

## Reproducibility

The tree can be reconstructed using the R script in `scripts/`. Users must first
download all source trees before running script.
Raw trees can be downloaded from sources indicated in `data/source_trees.csv`,
and placed into `raw_data_files/`. Ensure that each file is renamed to match the
naming scheme in `data/source_trees.csv`.

### Software
**R version:** 4.5.0

R packages

* ```'ape'``` version: 5.8.1
* ```'dplyr'``` version: 1.1.4
* ```'fishtree'``` version: 0.3.4’
* ```'picante'``` version: 1.8.2
* ```'RRphylo'``` version: 3.0.2
* ```'stringr'``` version: 1.5.1

## Citation

If you use this phylogenetic super tree, please cite:

[super tree citation]


BLANK. Null models reveal differing drivers of multidimensional beta diversity 
change in invaded metacommunities. in review

BLANK. Invasion syndromes based on changes in multidimensional beta diversity.
in review

## Contact
For questions about these data, please contact:

```bash
Name: William K. Annis

Email: wannis@fsu.edu, williamkannis@gmail.com

OrcID: 0009-0003-3541-8503
```

## Related publications

> “Null models reveal differing drivers of multidimensional beta diversity change in invaded metacommunities”

> "Invasion syndromes based on changes in multidimensional beta diversity" 

## License

[license]