################################################################################
#' @title Make a boxplot of a feature
#' @description
#' This function uses the ggplot2 package to generate a boxplot from a givin
#' \code{\link{mSet-class}} object by specifying a feature id. The feature id
#' must come from the feature names
#' @param object An \code{\link{mSet-class}} object
#' @param x A character string indicating the x variable. Must be one of the
#' sample data variables.
#' @param feature A character indicating the feature name to plot. Must be one
#' of the feature names.
#' @param rows A character string indicating the variable defines faceting
#' groups on columns. Must be one of the sample data variables.
#' @param cols A character string indicating the variable defines faceting
#' groups on columns. Must be one of the sample data variables.
#' @param line A character string indicating the variable used to draw lines
#' between points. Must be one of the sample data variables.
#' @param color A character string indicating the variable defines the color
#' of lines or points. Must be one of the sample data variables.
#' @param ... Other arguments see \code{\link{ggboxplot}}
#' @author Chenghao Zhu
#' @import ggplot2
#' @export
plot_boxplot = function(object, x, feature, rows, cols, line, color, ...){

    if(!requireNamespace("ggmetaplots")){
        stop("[ Metabase ] Can't find the ggmetaplot package. Please install it using:\n\n    devtools::install_github('zhuchcn/ggmetaplot')",
             call. = FALSE)
    }

    args = as.list(match.call())[-c(1:2)]
    names(args)[names(args) == "feature"] = "y"

    sample_vars = unique(c(args$x, args$rows, args$cols, args$color, args$line))

    df = data.frame(
        Concentration = object@conc_table[feature,]
    ) %>%
        cbind(object@sample_table[,sample_vars])
    colnames(df)[-1] = sample_vars

    args$data = df
    args = args[names(args)!="feature"]
    args$y = "Concentration"

    do.call(ggmetaplots::ggboxplot, args)

}
################################################################################
#' @title Plot Histogram of Missing Values
#' @description This function takes a mSet object and print a histogram of
#' missing values. The x axis is the number of missing values per feature, and
#' the y axis is number of features with specific number of missing values.
#' This is usful when filling NAs.
#'
#' @param object A \code{\link{mSet-class}} or derived object.
#' @param include.zero Logic value whether to include zero in the histogram.
#' Default is FALSE.
#' @export
#' @return A ggplot object
#' @examples
#' # ADD_EXAMPLES_HERE
plot_hist_NA = function(object, include.zero = FALSE){
    if(!inherits(object, "mSet"))
        stop("Input object must inherit from mSet")

    df = data.frame(
        num_na = apply(object@conc_table, 1, function(x) sum(is.na(x)))) %>%
        rownames_to_column("feature_id")
    if(sum(df$num_na >0) == 0)
        stop("No NA detected. You are good to go!", call. = FALSE)

    if(!include.zero)
        df = filter(df, num_na > 0)

    df = sapply(seq(0, max(df$num_na), 1), function(x){
        c(x, sum(df$num_na == x))
    }) %>% t %>% as.data.frame %>%
        setNames(c("num_na", "count")) %>%
        mutate(text.position = count + max(count)/20,
               text = ifelse(count == 0, NA, count))

    ggplot(df) +
        geom_col(aes(x = num_na, y = count), width = 1) +
        geom_text(aes(x = num_na, y = text.position, label = text)) +
        scale_x_continuous(limits = c(0, max(df$num_na)+1),
                           breaks = seq(0, max(df$num_na)+1, 1)) +
        labs(x = "number of missing values per feature",
             y = "count of features",
             title = "Totel feature number: " %+% nfeatures(object)) +
        theme_bw() +
        theme(plot.title = element_text(hjust = 0.5))
}
################################################################################
#' @title Plot quality control from a MetabolomcisSet object
#'
#' @description This function takes a MetabolomicsSet object and makes scatter plots using quality control samples
#'
#' @param object A \code{\link{MetabolomicsSet-class}} object.
#' @param mean A character string indicating the feature_data column of qc means.
#' @param sd A character string indicating the feature_data column of qc standard deviation.
#' @param cv A character string indicating the feature_data column of qc coefficient of variance.
#' @param log A logic variable whether to log-transfer mean or sd.
#' @export
#' @author Chenghao Zhu
plot_qc = function(object,
                   mean = "qc_mean",
                   sd = "sd_mean",
                   cv = "cv_mean",
                   log=TRUE){
    if(!inherits(object, "MetabolomicsSet"))
        stop("Only MetabolomicsSet or derieved classes supported",
             call. = TRUE)
    if(missing(mean)){
        stop("mean is required", call. = FALSE)
    }else if(!missing(sd) & missing(cv)){
        p = plot_qc_sd(object = object, mean = mean, sd = sd, log = log)
    }else if(missing(sd) & !missing(cv)){
        p = plot_qc_cv(object = object, mean = mean, cv = cv, log = log)
    }else if(!missing(sd) & !missing(cv)){
        p1 = plot_qc_sd(object = object, mean = mean, sd = sd, log = log)
        p2 = plot_qc_cv(object = object, mean = mean, cv = cv, log = log)
        p = cowplot::plot_grid(p1, p2, nrow = 1)
    }else{
        stop("At least either of sd or cv needs to be specified",
             call. = FALSE)
    }
    return(p)
}
#' @keywords internal
plot_qc_sd = function(object, mean, sd, log=TRUE){
    df = object@feature_data[,c(mean, sd)]
    if(log){
        df[, mean] = log(df[, mean] + 1)
        df[, sd]   = log(df[, sd]   + 1)
    }
    xlab = "Mean, Quality Controls"
    if(log) xlab = xlab %+% " (log)"
    ylab = "SD, Quality Controls"
    if(log) ylab = ylab %+% " (log)"
    ggplot(df) +
        geom_point(aes_string(x = mean, y = sd), alpha = 0.8) +
        labs(x = xlab, y = ylab) +
        theme_bw()
}
#' @keywords internal
plot_qc_cv = function(object, mean, cv, log=TRUE){
    df = object@feature_data[,c(mean, cv)]
    if(log) df[, mean] = log(df[, mean] + 1)
    xlab = "Mean, Quality Controls"
    if(log) xlab = xlab %+% " (log)"
    ggplot(df) +
        geom_point(aes_string(x = mean, y = cv), alpha = 0.8) +
        scale_y_continuous(limits = c(0,100)) +
        labs(x = xlab, y = "CV (%), Quality Controls")+
        theme_bw()
}






