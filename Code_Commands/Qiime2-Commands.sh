Qiime2 Commands for Project Analysis


# Command run to download every sequence from the 
# premade accession.list file containing all desired SRR's. 
# Change out accession.list file name for each file you want 
# to run. 
cat corn-CANADA-accession.list | xargs ~/sratoolkit.3.0.1-ubuntu64/bin/fasterq-dump --split-files --skip-technical

# Listing all the sequences in that file path that end with 1.fastq
ls corn/corn-ASIA-F/*1.fastq

# Saving the list generated above into a viewable file
ls corn/*/*1.fastq > corn2.manifest.tsv

# Adds the full filepath to the sequence file generated
ls /home/carolinegardner/data/corn/*/*1.fastq > corn2.manifest.tsv

# Adds tab spacing to the file and saves it as a temporary file
cat corn2.manifest.tsv | tr ' ' '\t' > temp


# All steps above were repeated for each desired file

# Imports desired sequences into Qiime2 artifacts
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path corn2.manifest.tsv \
  --input-format PairedEndFastqManifestPhred33V2 \
  --output-path demux-corn2.qza

# Generates a summary of the demultiplexed results
qiime demux summarize \
  --i-data demux-corn2.qza \
  --o-visualization demux-corn2.qzv
  
# Running sequence quality control and feature table construction
# Repeat command for soil, apple and corn
qiime dada2 denoise-single \
  --i-demultiplexed-seqs demux-soil.qza \
  --p-trim-left 0 \
  --p-trunc-len-f 258 \ 
  --p-trunc-len-r 241 \
  --o-representative-sequences rep-seqs-dada2-soil.qza \
  --o-table table-dada2-soil.qza \
  --o-denoising-stats stats-dada2-soil.qza
  

# Choosing where to trim on the left and right to obtain only quality sequence
qiime dada2 denoise-paired --i-demultiplexed-seqs demux-soil.qza --p-trunc-len-f 258 --p-trunc-len-r 241 --p-trim-left-f 0 --p-trim-left-r 6 --o-representative-sequences rep-seqs-dada2-soil.qza --o-table table-dada2-soil.qza --o-denoising-stats stats-dada2-soil.qza
  
# running same command for apple
qiime dada2 denoise-paired --i-demultiplexed-seqs demux-apple.qza --p-trunc-len-f 250 --p-trunc-len-r 250 --p-trim-left-f 0 --p-trim-left-r 0 --o-representative-sequences rep-seqs-dada2-apple.qza --o-table table-dada2-apple.qza --o-denoising-stats stats-dada2-apple.qza

# same command for corn
qiime dada2 denoise-paired --i-demultiplexed-seqs demux-corn2.qza --p-trunc-len-f 300 --p-trunc-len-r 300 --p-trim-left-f 0 --p-trim-left-r 0 --o-representative-sequences rep-seqs-dada2-corn2.qza --o-table table-dada2-corn2.qza --o-denoising-stats stats-dada2-corn2.qza


# Turn resulting files into visualization
qiime metadata tabulate \
  --m-input-file stats-dada2-soil.qza \
  --o-visualization stats-dada2-soil.qzv

# same for apple
qiime metadata tabulate \
  --m-input-file stats-dada2-apple.qza \
  --o-visualization stats-dada2-apple.qzv

# same for corn
qiime metadata tabulate \
  --m-input-file stats-dada2-corn2.qza \
  --o-visualization stats-dada2-corn2.qzv
  
# If you’d like to continue the tutorial using this FeatureTable
# (opposed to the Deblur feature table generated in Option 2),
# run the following commands.
  
mv rep-seqs-dada2-soil.qza rep-seqs-soil.qza
mv table-dada2-soil.qza table-soil.qza

mv rep-seqs-dada2-apple.qza rep-seqs-apple.qza
mv table-dada2-apple.qza table-apple.qza

mv rep-seqs-dada2-corn2.qza rep-seqs-corn2.qza
mv table-dada2-corn2.qza table-corn2.qza
  

# After the quality filtering step completes, 
# you’ll want to explore the resulting data. 
# You can do this using the following two commands,
# which will create visual summaries of the data.
# The feature-table summarize command will give
# you information on how many sequences are associated
# with each sample and with each feature, histograms 
# of those distributions, and some related summary
# statistics. The feature-table tabulate-seqs command
# will provide a mapping of feature IDs to sequences,
# and provide links to easily BLAST each sequence
# against the NCBI nt database. The latter visualization
# will be very useful later in the tutorial, when you
# want to learn more about specific features that are 
# important in the data set.
  
qiime feature-table summarize \
  --i-table table-soil.qza \
  --o-visualization table-soil.qzv \
  --m-sample-metadata-file metadata_soil.txt
qiime feature-table tabulate-seqs \
  --i-data rep-seqs-soil.qza \
  --o-visualization rep-seqs-soil.qzv
  
  
qiime feature-table summarize \
  --i-table table-apple.qza \
  --o-visualization table-apple.qzv \
  --m-sample-metadata-file metadata_apple.txt
qiime feature-table tabulate-seqs \
  --i-data rep-seqs-apple.qza \
  --o-visualization rep-seqs-apple.qzv

  
qiime feature-table summarize \
  --i-table table-corn2.qza \
  --o-visualization table-corn2.qzv \
  --m-sample-metadata-file metadata_corn.txt
qiime feature-table tabulate-seqs \
  --i-data rep-seqs-corn2.qza \
  --o-visualization rep-seqs-corn2.qzv
  
  
# Generate a tree for phylogenetic diversity analyses
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs-soil.qza \
  --o-alignment aligned-rep-seqs-soil.qza \
  --o-masked-alignment masked-aligned-rep-seqs-soil.qza \
  --o-tree unrooted-tree-soil.qza \
  --o-rooted-tree rooted-tree-soil.qza
  
  
# Generate a tree for phylogenetic diversity analyses
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs-apple.qza \
  --o-alignment aligned-rep-seqs-apple.qza \
  --o-masked-alignment masked-aligned-rep-seqs-apple.qza \
  --o-tree unrooted-tree-apple.qza \
  --o-rooted-tree rooted-tree-apple.qza
  
  
# Generate a tree for phylogenetic diversity analyses
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences rep-seqs-corn2.qza \
  --o-alignment aligned-rep-seqs-corn2.qza \
  --o-masked-alignment masked-aligned-rep-seqs-corn2.qza \
  --o-tree unrooted-tree-corn2.qza \
  --o-rooted-tree rooted-tree-corn2.qza
  
  
  
# Uses metadata associated with the sequences to test for associations between categorical columns and metadata
# Alpha and beta diversity analysis				
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree-soil.qza \
  --i-table table-soil.qza \
  --p-sampling-depth 16818 \
  --m-metadata-file metadata_soil.txt \
  --output-dir core-metrics-results-soil
  
  
# Alpha and beta diversity analysis				
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree-apple.qza \
  --i-table table-apple.qza \
  --p-sampling-depth 11612 \
  --m-metadata-file metadata_apple.txt \
  --output-dir core-metrics-results-apple
  
  
# Alpha and beta diversity analysis				 
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree-corn2.qza \
  --i-table table-corn2.qza \
  --p-sampling-depth 7137 \
  --m-metadata-file metadata_corn.txt \
  --output-dir core-metrics-results-corn2
  
  
# Transforms soil qza alpha diversity file into viewable qzv
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results-soil/faith_pd_vector.qza \
  --m-metadata-file metadata_soil.txt \
  --o-visualization core-metrics-results-soil/faith-pd-group-significance.qzv
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results-soil/evenness_vector.qza \
  --m-metadata-file metadata_soil.txt \
  --o-visualization core-metrics-results-soil/evenness-group-significance.qzv
  

# Same command for apple
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results-apple/faith_pd_vector.qza \
  --m-metadata-file metadata_apple.txt \
  --o-visualization core-metrics-results-apple/faith-pd-group-significance.qzv
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results-apple/evenness_vector.qza \
  --m-metadata-file metadata_apple.txt \
  --o-visualization core-metrics-results-apple/evenness-group-significance.qzv
  
  
# Same command for corn
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results-corn2/faith_pd_vector.qza \
  --m-metadata-file metadata_corn.txt \
  --o-visualization core-metrics-results-corn2/faith-pd-group-significance.qzv
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results-corn2/evenness_vector.qza \
  --m-metadata-file metadata_corn.txt \
  --o-visualization core-metrics-results-corn2/evenness-group-significance.qzv
  
  

# Transforms soil qza beta diversity file into viewable qzv
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results-soil/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata_soil.txt \
  --m-metadata-column region \
  --o-visualization core-metrics-results-soil/unweighted-unifrac-body-site-significance.qzv \
  --p-pairwise
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results-soil/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata_soil.txt \
  --m-metadata-column region \
  --o-visualization core-metrics-results-soil/unweighted-unifrac-subject-group-significance.qzv \
  --p-pairwise
  
  
# Same command for apple
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results-apple/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata_apple.txt \
  --m-metadata-column region \
  --o-visualization core-metrics-results-apple/unweighted-unifrac-body-site-significance.qzv \
  --p-pairwise
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results-apple/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata_apple.txt \
  --m-metadata-column region \
  --o-visualization core-metrics-results-apple/unweighted-unifrac-subject-group-significance.qzv \
  --p-pairwise  
  
  
  
# Same command for corn
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results-corn2/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata_corn.txt \
  --m-metadata-column region \
  --o-visualization core-metrics-results-corn2/unweighted-unifrac-body-site-significance.qzv \
  --p-pairwise
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results-corn2/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file metadata_corn.txt \
  --m-metadata-column region \
  --o-visualization core-metrics-results-corn2/unweighted-unifrac-subject-group-significance.qzv \
  --p-pairwise  
  
  
  
# Taxonomic analysis

# In the next sections we’ll begin to explore the taxonomic composition of the samples,
# and again relate that to sample metadata. The first step in this process is to assign 
# taxonomy to the sequences in our FeatureData[Sequence] QIIME 2 artifact. We’ll do that 
# using a pre-trained Naive Bayes classifier and the q2-feature-classifier plugin. 
# This classifier was trained on the Greengenes 13_8 99% OTUs, where the sequences 
# have been trimmed to only include 250 bases from the region of the 16S that was 
# sequenced in this analysis (the V4 region, bound by the 515F/806R primer pair). 
# We’ll apply this classifier to our sequences, and we can generate a visualization
# of the resulting mapping from sequence to taxonomy.

# SOIL
qiime feature-classifier classify-sklearn \
  --i-classifier silva-138-99-nb-weighted-classifier.qza \
  --i-reads rep-seqs-soil.qza \
  --o-classification taxonomy-soil.qza
  
qiime metadata tabulate \
  --m-input-file taxonomy-soil.qza \
  --o-visualization taxonomy-soil.qzv
  
  
qiime taxa barplot \
  --i-table table-soil.qza \
  --i-taxonomy taxonomy-soil.qza \
  --m-metadata-file metadata_soil.txt \
  --o-visualization taxa-bar-plots-soil.qzv
  
# APPLE
 
qiime feature-classifier classify-sklearn \
  --i-classifier silva-138-99-nb-weighted-classifier.qza \
  --i-reads rep-seqs-apple.qza \
  --o-classification taxonomy-apple.qza
  
qiime metadata tabulate \
  --m-input-file taxonomy-apple.qza \
  --o-visualization taxonomy-apple.qzv 
  
qiime taxa barplot \
  --i-table table-apple.qza \
  --i-taxonomy taxonomy-apple.qza \
  --m-metadata-file metadata_apple.txt \
  --o-visualization taxa-bar-plots-apple.qzv
  

# CORN

qiime feature-classifier classify-sklearn \
  --i-classifier silva-138-99-nb-weighted-classifier.qza \
  --i-reads rep-seqs-corn2.qza \
  --o-classification taxonomy-corn.qza
  
qiime metadata tabulate \
  --m-input-file taxonomy-corn.qza \
  --o-visualization taxonomy-corn.qzv 
  
  
qiime taxa barplot \
  --i-table table-corn2.qza \
  --i-taxonomy taxonomy-corn.qza \
  --m-metadata-file metadata_corn.txt \
  --o-visualization taxa-bar-plots-corn.qzv

 
# All of the commands below were run on the data but the results did not prove useful and did not end up in the paper

#Differential abundance testing with ANCOM
# ANCOM is implemented in the q2-composition plugin. ANCOM assumes that few (less than about 25%) of the 
# features are changing between groups. If you expect that more features are changing between your groups,
# you should not use ANCOM as it will be more error-prone (an increase in both Type I and Type II errors
# is possible). Because we expect a lot of features to change in abundance across body sites, in this
# tutorial we’ll filter our full feature table to only contain gut samples. We’ll then apply ANCOM
# to determine which, if any, sequence variants and genera are differentially abundant across 
# the gut samples of our two subjects.

# We’ll start by creating a feature table that contains only the gut samples.
# (To learn more about filtering, see the Filtering Data tutorial.)

# SOIL
qiime feature-table filter-samples \
  --i-table table-soil.qza \
  --m-metadata-file metadata_soil.txt \
  --p-where "[region]='NA'" \
  --o-filtered-table NA-region-table-soil.qza
  
qiime metadata tabulate \
  --m-input-file NA-region-table-soil.qza \
  --o-visualization NA-region-table-soil.qzv
  
 
# Repeat but with Asia as region
qiime feature-table filter-samples \
  --i-table table-soil.qza \
  --m-metadata-file metadata_soil.txt \
  --p-where "[region]='ASIA'" \
  --o-filtered-table ASIA-region-table-soil.qza
  
qiime metadata tabulate \
  --m-input-file ASIA-region-table-soil.qza \
  --o-visualization ASIA-region-table-soil.qzv
  
qiime composition add-pseudocount \
  --i-table NA-region-table-soil.qza \
  --o-composition-table comp-NA-table.qza
  
qiime metadata tabulate \
  --m-input-file comp-NA-table.qza \
  --o-visualization comp-NA-table.qzv
  
qiime composition add-pseudocount \
  --i-table ASIA-region-table-soil.qza \
  --o-composition-table comp-ASIA-table.qza
  
  
# APPLE
qiime feature-table filter-samples \
  --i-table table-apple.qza \
  --m-metadata-file metadata_apple.txt \
  --p-where "[region]='NA'" \
  --o-filtered-table NA-region-table-apple.qza
  
qiime metadata tabulate \
  --m-input-file NA-region-table-apple.qza \
  --o-visualization NA-region-table-apple.qzv

# Repeat but with Asia as region
qiime feature-table filter-samples \
  --i-table table-apple.qza \
  --m-metadata-file metadata_apple.txt \
  --p-where "[region]='ASIA'" \
  --o-filtered-table ASIA-region-table-apple.qza

  
qiime metadata tabulate \
  --m-input-file ASIA-region-table-apple.qza \
  --o-visualization ASIA-region-table-apple.qzv
  
  
qiime composition add-pseudocount \
  --i-table NA-region-table-apple.qza \
  --o-composition-table comp-NA-table-apple.qza
  
qiime metadata tabulate \
  --m-input-file comp-NA-table-apple.qza \
  --o-visualization comp-NA-table-apple.qzv
  
qiime composition add-pseudocount \
  --i-table ASIA-region-table-apple.qza \
  --o-composition-table comp-ASIA-table-apple.qza
  
qiime metadata tabulate \
  --m-input-file comp-ASIA-table-apple.qza \
  --o-visualization comp-ASIA-table-apple.qzv
  

# CORN
qiime feature-table filter-samples \
  --i-table table-corn2.qza \
  --m-metadata-file metadata_corn.txt \
  --p-where "[region]='NA'" \
  --o-filtered-table NA-region-table-corn.qza
  
qiime metadata tabulate \
  --m-input-file NA-region-table-corn.qza \
  --o-visualization NA-region-table-corn.qzv

# Repeat but with Asia as region
qiime feature-table filter-samples \
  --i-table table-corn2.qza \
  --m-metadata-file metadata_corn.txt \
  --p-where "[region]='ASIA'" \
  --o-filtered-table ASIA-region-table-corn.qza

qiime metadata tabulate \
  --m-input-file ASIA-region-table-apple.qza \
  --o-visualization ASIA-region-table-apple.qzv
  
qiime composition add-pseudocount \
  --i-table NA-region-table-corn.qza \
  --o-composition-table comp-NA-table-corn.qza
  
qiime metadata tabulate \
  --m-input-file comp-NA-table-corn.qza \
  --o-visualization comp-NA-table-corn.qzv
  
qiime composition add-pseudocount \
  --i-table ASIA-region-table-corn.qza \
  --o-composition-table comp-ASIA-table-corn.qza
  
qiime metadata tabulate \
  --m-input-file comp-ASIA-table-apple.qza \
  --o-visualization comp-ASIA-table-apple.qzv
  