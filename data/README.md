# Freshwater fish phylogenetic super tree (v1.0.0)

 
## Overview

This repository contains data for a time-calibrated informal super tree, constructed for 
the freshwater fish species in the FishScales data base.The resulting tree 
integrates phylogenetic information from 11 published phylogenetic studies and 
contains 815 species. This repository contains the tree in RDS and nexus file 
formats, data source csv files, and a pdf containing detailed methodology

**NOTE:** The tree was constructed for use in diversity studies. As information in
super tree is compiled from multiple sources with differing methodologies,
this tree is not suited for evolutionary analyses.

## Tree characteristics

- Number of tips: 815
- Number of internal nodes: 814
- Rooting: Outgroup = class Petromyzontida
- Branch lengths: chronogram
- Taxonomic coverage: Actinopterygii and Petromyzontida
- version: v1.0.0
- Construction method: time-calibrated informal super tree

## Files

### `fishscales_super_phylo_tree.nex`  
Nexus file containing the super tree

### `fishscales_super_phylo_tree.rds`
RDS file containing the super tree

### `tree_source.csv` 
Basic summary, citations, and download location of
raw phylogenetic trees used in super tree construction

<ins>Columns:</ins>

* `$source` Name of tree file.
* `$taxa` Represented taxonomic group.
* `$type` Type of branch lengths: "chronogram" - time, "phylogram" - base pair substitutions,
"cladogram" - no branch lengths.
* `$rooted` TRUE or FALSE. Does tree have a root?
* `$total_tips` Number of tree tips in tree.
* `$tips_used` Number of tips used in super tree.
* `$percent_of_tree` Percent of the super tree made up of tips from this
tree
* `$reference` Short-hand citation for tree. See `data/tree_appendix` for full
citation
* `$doi` DOI of citation
* `$download_link` Location to download tree files, when available
* `$notes` Additional information needed to download tree files.
    

### `species_source.csv`
List of all species in super tree, and their data
sources.

<ins>Columns:</ins>

* `species` Scientific name of species.
* `$source` Name of tree file.
* `$type` Type of tree: "chronogram" - time, "phylogram" - base pair substitutions,
"cladogram" - no branch lengths, "literature review" - no tree available. Citations
are given for cladograms and literature review, and refer to full citations
in `data/tree_appendix.pdf`


### `tree_appendix.pdf` 
Detailed methodology and citations for super tree creation.

## Tree construction

The super tree was constructed using the methods of 
[Castiglione et al. (2022)](https://doi.org/10.1111/pala.12588) with the 
tree.merger function from the [‘RRphylo’ R package](https://doi.org/10.32614/CRAN.package.RRphylo). 
In this manner, one tree acts as the backbone tree in 
which nodes and tips are added using the other trees as a reference for node 
position and age. For detailed methodology, see `data/tree_appendix`.

For super tree construction source code, visit the github [repository](BLANK)


## Source phylogenies

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
see `source_trees.csv` for complete source information, including citations 
and links. For detailed information on what species were sourced from which
tree, and full citations,  see `species_source` 
and `tree_appendix.pdf`.


## Citation

If you use this phylogenetic super tree, please cite:

[super tree citation]

[MANUSCRIPT CITATION]

[MANUSCRIPT CITATION]

## Related publications

> Syndromes of multidimensional beta diversity change in invaded metacommunities

> “Drivers of multidimensional beta diversity change in invaded stream fish communities”

## License

[license]