# README

## Phylogenetic super tree
The released phylogenetic tree is archived on Zenodo:

[DOI / Zenodo badge]

Available formats:


- Nexus (.nex)
- R object (.rds)

We provide the following data in this repository:

## `data/tree_source.csv` 
* <ins>Purpose:</ins> Basic summary, citations, and download location of
raw phylogenetic trees used in super tree construction
* <ins>Columns:</ins>
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
    

## `data/species_source.csv`
* <ins>Purpose:</ins> List of all species in super tree, and their data
sources.
* <ins>Columns:</ins>
  * `species` Scientific name of species.
  * `$source` Name of tree file.
  * `$type` Type of tree: "chronogram" - time, "phylogram" - base pair substitutions,
  "cladogram" - no branch lengths, "literature review" - no tree available. Citations
  are given for cladograms and literature review, and refer to full citations
  in `data/tree_appendix.pdf`


# `data/tree_appendix.pdf` 
* <ins>Purpose:</ins> Detailed methodology and citations for super tree creation.

