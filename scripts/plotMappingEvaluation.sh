#!/usr/bin/env bash
# Run after collateSTatistics.py.
# Makes plots comparing the graphs in each region.

set -ex

# What plot filetype should we produce?
PLOT_FILETYPE="png"

# Grab the input directory to look in
INPUT_DIR=${1}

if [[ ! -d "${INPUT_DIR}" ]]
then
    echo "Specify input directory!"
    exit 1
fi

# Set up the plot parameters
# Include both versions of the 1kg SNPs graph name
PLOT_PARAMS=(
    --categories
    snp1kg
    snp1000g
    sbg
    cactus
    camel
    curoverse
    debruijn-k31
    debruijn-k63
    level1
    level2
    level3
    prg
    refonly
    simons
    trivial
    vglr
    haplo1kg30
    haplo1kg50
    shifted1kg
    --category_labels 
    1KG
    1KG
    7BG
    Cactus
    Camel
    Curoverse
    "De Bruijn 31"
    "De Bruijn 63"
    Level1
    Level2
    Level3
    PRG
    Primary
    SGDP
    Unmerged
    VGLR
    "1KG Haplo 30"
    "1KG Haplo 50"
    Scrambled
    --colors
    "#fb9a99"
    "#fb9a99"
    "#b15928"
    "#1f78b4"
    "#33a02c"
    "#a6cee3"
    "#e31a1c"
    "#ff7f00"
    "#FF0000"
    "#00FF00"
    "#0000FF"
    "#6a3d9a"
    "#000000"
    "#b2df8a"
    "#b1b300"
    "#cab2d6"
    "#00FF00"
    "#0000FF"
    "#FF0000"
    --font_size 20 --dpi 90 --no_n
)

# Color "#fdbf6f" from haplo1kg is free.

# Where are the stats files
STATS_DIR="${INPUT_DIR}/stats"

# Where do we put the plots?
PLOTS_ROOT_DIR="${INPUT_DIR}/plots"

for MODE in `ls ${PLOTS_ROOT_DIR}`
do
    # We have normalized and absolute modes

    if [ "${MODE}" == "cache" ]
    then
        # Skip the cache directory
        continue
    fi
    
    # We want to write different axis labels in different modes
    PORTION="Portion"
    SECONDS_WORD=" (seconds)"
    RATE="rate"
    # If we want absolute changes (in portion mapped) on absolute plots, we can
    # add --absolute_deviation here.
    DEVIATION=""
    if [ "${MODE}" == "normalized" ]
    then
        PORTION="Relative portion"
        SECONDS_WORD=" (relative)"
        RATE=" relative rate"
        DEVIATION=""
    fi


    # We may be doing absolute or normalized plotting
    PLOTS_DIR="${PLOTS_ROOT_DIR}/${MODE}"
    mkdir -p "${PLOTS_DIR}"

    # We need overall files for mapped and multimapped
    OVERALL_MAPPING_FILE="${PLOTS_DIR}/mapping.tsv"
    OVERALL_MAPPING_PLOT="${PLOTS_DIR}/${MODE}-mapping.ALL.${PLOT_FILETYPE}"
    OVERALL_PERFECT_FILE="${PLOTS_DIR}/perfect.tsv"
    OVERALL_PERFECT_PLOT="${PLOTS_DIR}/${MODE}-perfect.ALL.${PLOT_FILETYPE}"
    OVERALL_SINGLE_MAPPING_WELL_FILE="${PLOTS_DIR}/singlemapping.tsv"
    OVERALL_SINGLE_MAPPING_WELL_PLOT="${PLOTS_DIR}/${MODE}-singlemapping.ALL.${PLOT_FILETYPE}"
    OVERALL_SINGLE_MAPPING_AT_ALL_FILE="${PLOTS_DIR}/singlemappingatall.tsv"
    OVERALL_SINGLE_MAPPING_AT_ALL_PLOT="${PLOTS_DIR}/${MODE}-singlemappingatall.ALL.${PLOT_FILETYPE}"
    
    # And for perfect vs unique
    OVERALL_PERFECT_UNIQUE_FILE="${PLOTS_DIR}/perfect_vs_unique.ALL.tsv"
    OVERALL_PERFECT_UNIQUE_PLOT="${PLOTS_DIR}/${MODE}-perfect_vs_unique.ALL.${PLOT_FILETYPE}"

    for REGION in `ls ${PLOTS_DIR}/mapping.*.tsv | xargs -n 1 basename | sed 's/mapping.\(.*\).tsv/\1/'`
    do
        # For every region we ran
        
        # We have intermediate data files for plotting from
        MAPPING_FILE="${PLOTS_DIR}/mapping.${REGION}.tsv"
        MAPPING_PLOT="${PLOTS_DIR}/${MODE}-mapping.${REGION}.${PLOT_FILETYPE}"
        PERFECT_FILE="${PLOTS_DIR}/perfect.${REGION}.tsv"
        PERFECT_PLOT="${PLOTS_DIR}/${MODE}-perfect.${REGION}.${PLOT_FILETYPE}"
        SINGLE_MAPPING_WELL_FILE="${PLOTS_DIR}/singlemapping.${REGION}.tsv"
        SINGLE_MAPPING_WELL_PLOT="${PLOTS_DIR}/${MODE}-singlemapping.${REGION}.${PLOT_FILETYPE}"
        SINGLE_MAPPING_AT_ALL_FILE="${PLOTS_DIR}/singlemappingatall.${REGION}.tsv"
        SINGLE_MAPPING_AT_ALL_PLOT="${PLOTS_DIR}/${MODE}-singlemappingatall.${REGION}.${PLOT_FILETYPE}"
        ANY_MAPPING_FILE="${PLOTS_DIR}/anymapping.${REGION}.tsv"
        ANY_MAPPING_PLOT="${PLOTS_DIR}/${MODE}-anymapping.${REGION}.${PLOT_FILETYPE}"
        RUNTIME_FILE="${PLOTS_DIR}/runtime.${REGION}.tsv"
        RUNTIME_PLOT="${PLOTS_DIR}/${MODE}-runtime.${REGION}.${PLOT_FILETYPE}"
        
        NOINDEL_FILE="${PLOTS_DIR}/noindels.${REGION}.tsv"
        NOINDEL_PLOT="${PLOTS_DIR}/${MODE}-noindels.${REGION}.${PLOT_FILETYPE}"
        SUBSTRATE_FILE="${PLOTS_DIR}/substrate.${REGION}.tsv"
        SUBSTRATE_PLOT="${PLOTS_DIR}/${MODE}-substrate.${REGION}.${PLOT_FILETYPE}"
        INDELRATE_FILE="${PLOTS_DIR}/indelrate.${REGION}.tsv"
        INDELRATE_PLOT="${PLOTS_DIR}/${MODE}-indelrate.${REGION}.${PLOT_FILETYPE}"
        
        PERFECT_UNIQUE_FILE="${PLOTS_DIR}/perfect_vs_unique.${REGION}.tsv"
        PERFECT_UNIQUE_PLOT="${PLOTS_DIR}/${MODE}-perfect_vs_unique.${REGION}.${PLOT_FILETYPE}"
        
        echo "Plotting ${REGION^^}..."
        
        # Remove underscores from region names to make them human readable
        HR_REGION=`echo ${REGION^^} | sed 's/_/ /g'`
        
        # TODO: you need to run collateStatistics.py to build the per-region-and-
        # graph stats files. We expect them to exist and only concatenate the final
        # overall files and make the plots.
        
        ./scripts/boxplot.py "${MAPPING_FILE}" \
            --title "$(printf "Mapped (0.95 match)\nreads in ${HR_REGION} (${MODE})")" \
            --x_label "Graph" --y_label "${PORTION} mapped" --save "${MAPPING_PLOT}" \
            ${DEVIATION} \
            --x_sideways --hline_median refonly \
            --range --sparse_ticks --sparse_axes \
            "${PLOT_PARAMS[@]}"
            
        ./scripts/boxplot.py "${PERFECT_FILE}" \
            --title "$(printf "Perfectly mapped\nreads in ${HR_REGION}")" \
            --x_label "Graph" --y_label "$(printf "${PORTION}\nperfectly mapped")" --save "${PERFECT_PLOT}" \
            ${DEVIATION} \
            --x_sideways --hline_median refonly --hline_ticks \
            --range --sparse_ticks --sparse_axes \
            "${PLOT_PARAMS[@]}"
            
        # Set single mapping limits by region, since range is huge
        UNIQUE_LIMITS=""
        if [ "${MODE}" == "absolute" ]; then
            if [ "${REGION^^}" == "MHC" ]; then
                UNIQUE_LIMITS="--min 0.7"
            elif [ "${REGION^^}" == "BRCA1" ]; then
                UNIQUE_LIMITS="--min 0.8"
            elif [ "${REGION^^}" == "BRCA2" ]; then
                UNIQUE_LIMITS="--min 0.89"
            elif [ "${REGION^^}" == "SMA" ]; then
                UNIQUE_LIMITS=""
            elif [ "${REGION^^}" == "LRC_KIR" ]; then
                UNIQUE_LIMITS=""
            fi
        fi
            
        ./scripts/boxplot.py "${SINGLE_MAPPING_WELL_FILE}" \
            --title "$(printf "Uniquely mapped well\nreads in ${HR_REGION} (${MODE})")" \
            --x_label "Graph" --y_label "$(printf "${PORTION} uniquely\nmapped well")" --save "${SINGLE_MAPPING_WELL_PLOT}" \
            ${DEVIATION} \
            --x_sideways --hline_median refonly --hline_ticks \
            ${UNIQUE_LIMITS} \
            --range --sparse_ticks --sparse_axes \
            "${PLOT_PARAMS[@]}"
            
        ./scripts/boxplot.py "${SINGLE_MAPPING_AT_ALL_FILE}" \
            --title "$(printf "Uniquely mapped (any number of matches)\nreads in ${HR_REGION} (${MODE})")" \
            --x_label "Graph" --y_label "$(printf "${PORTION}\nuniquely mapped")" --save "${SINGLE_MAPPING_AT_ALL_PLOT}" \
            ${DEVIATION} \
            --x_sideways --hline_median refonly --hline_ticks \
            --range --sparse_ticks --sparse_axes \
            "${PLOT_PARAMS[@]}"
            
        ./scripts/boxplot.py "${ANY_MAPPING_FILE}" \
            --title "$(printf "Mapped (any number of matches)\nreads in ${HR_REGION} (${MODE})")" \
            --x_label "Graph" --y_label "${PORTION} mapped" --save "${ANY_MAPPING_PLOT}" \
            ${DEVIATION} \
            --x_sideways --hline_median refonly --hline_ticks \
            --range --sparse_ticks --sparse_axes \
            "${PLOT_PARAMS[@]}"
            
        ./scripts/boxplot.py "${RUNTIME_FILE}" \
            --title "$(printf "Per-read runtime\n in ${HR_REGION} (${MODE})")" \
            --x_label "Graph" --y_label "Runtime per read${SECONDS_WORD}" --save "${RUNTIME_PLOT}" \
            ${DEVIATION} \
            --x_sideways --max_max 0.006 \
            --range --sparse_ticks --sparse_axes \
            "${PLOT_PARAMS[@]}"
            
        ./scripts/boxplot.py "${NOINDEL_FILE}" \
            --title "$(printf "Mapped indel-free\nreads in ${HR_REGION} (${MODE})")" \
            --x_label "Graph" --y_label "${PORTION} mapped" --save "${NOINDEL_PLOT}" \
            ${DEVIATION} \
            --x_sideways --hline_median refonly --hline_ticks \
            --range --sparse_ticks --sparse_axes \
            "${PLOT_PARAMS[@]}"
        
        if [ "X${MAIN_TEXT:-}" == "X1"]; then
            # In the main text we want some limits to cut off the invisible
            # range lines.
            if [ "${MODE}" == "absolute" ]
            then
                # Limit max Y for absolute substitution rates
                if [ "${REGION^^}" == "BRCA1" ]
                then
                    SUBSTRATE_LIMIT="--max 0.006"
                elif [ "${REGION^^}" == "BRCA2" ]
                then
                    SUBSTRATE_LIMIT="--max 0.004"
                elif [ "${REGION^^}" == "MHC" ]
                then
                    SUBSTRATE_LIMIT="--max 0.008"
                elif [ "${REGION^^}" == "SMA" ]
                then
                    SUBSTRATE_LIMIT="--max 0.005"
                elif [ "${REGION^^}" == "LRC_KIR" ]
                then
                    SUBSTRATE_LIMIT="--max 0.008"
                elif [ "${REGION^^}" == "CENX" ]
                then
                    SUBSTRATE_LIMIT=""
                else
                    SUBSTRATE_LIMIT=""
                fi
            else
                # Set limits by region
                if [ "${REGION^^}" == "BRCA2" ]
                then
                    SUBSTRATE_LIMIT="--max 1.5 --min 0.5"
                elif [ "${REGION^^}" == "MHC" ]
                then
                    SUBSTRATE_LIMIT="--max 2 --min 0"
                else
                    SUBSTRATE_LIMIT="--max 2 --min 0"
                fi
            fi
        else
            SUBSTRATE_LIMIT=""
        fi
        
        
        ./scripts/boxplot.py "${SUBSTRATE_FILE}" \
            --title "$(printf "Substitution rate\nin ${HR_REGION} (${MODE})")" \
            --x_label "Graph" --y_label "Substitution ${RATE}" --save "${SUBSTRATE_PLOT}" \
            --x_sideways --hline_median refonly ${SUBSTRATE_LIMIT} --best_low \
            ${DEVIATION} \
            --hline_median refonly --hline_ticks \
            --range --sparse_ticks --sparse_axes \
            --scientific \
            "${PLOT_PARAMS[@]}"
            
        if [ "${MODE}" == "absolute" ]
        then
            # Limit max Y for absolute indel rates
            if [ "${REGION^^}" == "MHC" ]
            then
                INDELRATE_LIMIT="--max 0.0004"
            elif [ "${REGION^^}" == "BRCA2" ]
            then
                INDELRATE_LIMIT="--max 0.0002"
            else
                INDELRATE_LIMIT=""
            fi
        else
            # Set limits by region
            if [ "${REGION^^}" == "BRCA2" ]
            then
                INDELRATE_LIMIT="--max 1.5 --min 0.5"
            elif [ "${REGION^^}" == "MHC" ]
            then
                INDELRATE_LIMIT="--max 2 --min 0"
            else
                INDELRATE_LIMIT="--max 2 --min 0"
            fi
        fi
            
        ./scripts/boxplot.py "${INDELRATE_FILE}" \
            --title "$(printf "Indels per base\nin ${HR_REGION} (${MODE})")" \
            --x_label "Graph" --y_label "Indel ${RATE}" --save "${INDELRATE_PLOT}" \
            ${DEVIATION} \
            --x_sideways --hline_median refonly --hline_ticks --best_low \
            --range --sparse_ticks --sparse_axes ${INDELRATE_LIMIT} \
            "${PLOT_PARAMS[@]}"

        # Plot perfect vs unique mapping
        scripts/scatter.py "${PERFECT_UNIQUE_FILE}" \
            --save "${PERFECT_UNIQUE_PLOT}" \
            --title "$(printf "Perfect vs. Unique\nMapping in ${REGION^^}")" \
            --x_label "Portion Uniquely Mapped Well" \
            --y_label "Portion Perfectly Mapped" \
            --markers "o" \
            --annotate --no_legend \
            ${PERFECT_UNIQUE_LIMITS} \
            "${PLOT_PARAMS[@]}"
            
        
    done

    # Aggregate the overall files
    cat "${PLOTS_DIR}"/mapping.*.tsv > "${OVERALL_MAPPING_FILE}"
    cat "${PLOTS_DIR}"/perfect.*.tsv > "${OVERALL_PERFECT_FILE}"
    cat "${PLOTS_DIR}"/singlemapping.*.tsv > "${OVERALL_SINGLE_MAPPING_WELL_FILE}"
    cat "${PLOTS_DIR}"/singlemappingatall.*.tsv > "${OVERALL_SINGLE_MAPPING_AT_ALL_FILE}"
    # Perfect vs unique overall file is generated by the collator, since we
    # don't want to weight each region equally.

    # Make the overall plots
    ./scripts/boxplot.py "${OVERALL_MAPPING_FILE}" \
        --title "$(printf "Mapped (0.95 match)\nreads (${MODE})")" \
        --x_label "Graph" --y_label "Portion mapped" --save "${OVERALL_MAPPING_PLOT}" \
        ${DEVIATION} \
        --x_sideways  --hline_median refonly --hline_ticks \
        --range --sparse_ticks --sparse_axes \
        "${PLOT_PARAMS[@]}"
        
    ./scripts/boxplot.py "${OVERALL_PERFECT_FILE}" \
        --title "$(printf "Perfectly mapped\nreads (${MODE})")" \
        --x_label "Graph" --y_label "Portion perfectly mapped" --save "${OVERALL_PERFECT_PLOT}" \
        ${DEVIATION} \
        --x_sideways --hline_median refonly --hline_ticks \
        --range --sparse_ticks --sparse_axes \
        "${PLOT_PARAMS[@]}"
        
    ./scripts/boxplot.py "${OVERALL_SINGLE_MAPPING_WELL_FILE}" \
        --title "$(printf "Uniquely mapped well\nreads (${MODE})")" \
        --x_label "Graph" --y_label "Portion uniquely mapped well" --save "${OVERALL_SINGLE_MAPPING_WELL_PLOT}" \
        ${DEVIATION} \
        --x_sideways --hline_median refonly --hline_ticks \
        --range --sparse_ticks --sparse_axes \
        "${PLOT_PARAMS[@]}"
        
    ./scripts/boxplot.py "${OVERALL_SINGLE_MAPPING_AT_ALL_FILE}" \
        --title "$(printf "Uniquely mapped (any number of matches)\nreads (${MODE})")" \
        --x_label "Graph" --y_label "Portion uniquely mapped" --save "${OVERALL_SINGLE_MAPPING_AT_ALL_PLOT}" \
        ${DEVIATION} \
        --x_sideways --hline_median refonly --hline_ticks \
        --range --sparse_ticks --sparse_axes \
        "${PLOT_PARAMS[@]}"
        
    # Maybe just cut off K31 DBG for this plot?
    if [[ "${MODE}" == "absolute" ]]; then
        ./scripts/scatter.py "${OVERALL_PERFECT_UNIQUE_FILE}" \
            --save "${OVERALL_PERFECT_UNIQUE_PLOT}" \
            --title "$(printf "Perfect vs. Unique\nMapping (${MODE})")" \
            --x_label "Portion Uniquely Mapped Well" \
            --y_label "Portion Perfectly Mapped" \
            --min_x 0.55 --min_y 0.55 --max_x 0.8 --max_y 0.8 \
            --sparse_ticks --sparse_axes --markers "o" \
            --annotate --no_legend \
            "${PLOT_PARAMS[@]}"
    fi
        
done

