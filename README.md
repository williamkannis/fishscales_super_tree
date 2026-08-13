# Freshwater fish phylogenetic super tree (v1.0.0)

 
## Overview

This repository contains the code and documentation used to construct
a time-calibrated informal supertree for the freshwater fish species in the FishScales
data base.

The resulting tree integrates phylogenetic information from 11 published
phylogenetic studies and contains 815 species.

**NOTE:** The tree was constructed for use in diversity studies. As information in
supertree is compiled from multiple sources with differing methodologies,
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
* `data/species_source.csv` - List of all species in supertree, and their data
sources.
* `data/tree_appendix.pdf` - Detailed methodology for super tree creation.

## Tree construction

The supertree was constructed using the methods of 
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
- version: v1.0.0
- Construction method: time-calibrated informal supertree

## Reproducibility

The tree can be reconstructed using the R script in `scripts/`. Users must first
download all source trees before running script.
Raw trees can be downloaded from sources indicated in `data/source_trees.csv`,
and placed into `raw_data_files/`. Ensure that each file is renamed to match the
naming scheme in `data/source_trees.csv`.

## Citation

If you use this phylogenetic supertree, please cite:

[supertree citation]

[MANUSCRIPT CITATION]

[MANUSCRIPT CITATION]

## Related publications

> Syndromes of multidimensional beta diversity change in invaded metacommunities

> “Drivers of multidimensional beta diversity change in invaded stream fish communities”

## License

[license]