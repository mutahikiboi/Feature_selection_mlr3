task <- tsk("sonar")
 
task %>% view

task %>% autoplot

task
#we have 60  features hence we need to perform feature selection

#b
set.seed(42)

afs_random = AutoFSelector$new(
  learner = lrn("classif.kknn", predict_type = "prob"),
  resampling = rsmp("holdout"), #we can also go with cv  
  measure = msr("classif.auc"), #could als use classif.acc, classif.bacc
  terminator = trm("stagnation", iters =10),#could also use "evals", n_evals = 100
  fselector = fs("random_search"),
  store_models = TRUE
 )
afs_random$id <- "random_fs"

#we need to install a package
install.packages("genalg")
library(genalg)

afs_genetic = AutoFSelector$new(
  learner = lrn("classif.kknn", predict_type = "prob"),
  resampling = rsmp("cv", folds = 3), #we can also go with cv  
  measure = msr("classif.bacc"), #could als use classif.acc, classif.bacc
  terminator = trm("evals", n_evals = 10),#could also use "evals", n_evals = 10
  fselector = fs("genetic_search",
                 popSize = 10L,
                 elitism = 2L,
                 zeroToOneRatio = 2L),
  store_models = TRUE
)

afs_genetic$id <- "genetic_fs"
  
#c

outer_resampling <- rsmp("cv")
learners <- list(
                  afs_random,
                  afs_genetic,
                  lrn("classif.kknn"),
                  lrn("classif.featureless")
)

design <- benchmark_grid(task = task, learners=learners, resampling = outer_resampling)

bmr <- benchmark(design = design, store_models = TRUE)

bmr %>% autoplot


learner1 <- lrn("classif.ranger")
learner1

learner2 <- lrn("classif.rpart")
learner2$param_set

learner3 <- lrn('classif.kknn')
learner3$param_set

mlr_learners %>%
  as.data.table() %>%
  view()

#tunes the termination to 100 stagnation and evalutaions
set.seed(42)

afs_random_tuned = AutoFSelector$new(
  learner = lrn("classif.kknn", predict_type = "prob"),
  resampling = rsmp("holdout"), #we can also go with cv  
  measure = msr("classif.auc"), #could als use classif.acc, classif.bacc
  terminator = trm("stagnation", iters =100),#could also use "evals", n_evals = 100
  fselector = fs("random_search"),
  store_models = TRUE
)
afs_random_tuned$id <- "random_fs_tuned"

#we need to install a package
#install.packages("genalg")
#library(genalg)

afs_genetic_tuned = AutoFSelector$new(
  learner = lrn("classif.kknn", predict_type = "prob"),
  resampling = rsmp("cv", folds = 5), #we can also go with cv  
  measure = msr("classif.bacc"), #could als use classif.acc, classif.bacc
  terminator = trm("evals", n_evals = 100),#could also use "evals", n_evals = 10
  fselector = fs("genetic_search",
                 popSize = 10L,
                 elitism = 2L,
                 zeroToOneRatio = 2L),
  store_models = TRUE
)

afs_genetic_tuned$id <- "genetic_fs_tuned"

#c

outer_resampling <- rsmp("cv")
learners <- list(
  afs_random_tuned,
  afs_genetic_tuned,
  lrn("classif.kknn"),
  lrn("classif.featureless")
)

design <- benchmark_grid(task = task, learners=learners, resampling = outer_resampling)

bmr <- benchmark(design = design, store_models = TRUE)

bmr %>% autoplot
