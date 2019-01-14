#! /home/seppeyc/bin/Rscript

#####
# mntd
#####

# Initialize MPI
library("Rmpi")
library("stats")

# Notice we just say "give us all the slaves you've got."
mpi.spawn.Rslaves()

if (mpi.comm.size() < 2) {
  print("More slave processes are required.")
  mpi.quit()
}

.Last <- function(){
  if (is.loaded("mpi_initialize")){
    if (mpi.comm.size(1) > 0){
      print("Please use mpi.close.Rslaves() to close slaves.")
      mpi.close.Rslaves()
    }
    print("Please use mpi.quit() to quit R")
    .Call("mpi_finalize")
  }
}

#####
# Slave
#####

foldslave <- function() {
  # Note the use of the tag for sent messages: 
  #     1=ready_for_task, 2=done_task, 3=exiting 
  # Note the use of the tag for received messages: 
  #     1=task, 2=done_tasks 
  junk <- 0 
  
  done <- 0 
  while (done != 1) {
    # Signal being ready to receive a new task 
    mpi.send.Robj(junk,0,1) 
    
    # Receive a task 
    task <- mpi.recv.Robj(mpi.any.source(),mpi.any.tag()) 
    task_info <- mpi.get.sourcetag() 
    tag <- task_info[2] 
    
    if (tag == 1) {
      foldNumber <- task$foldNumber

      run <- mntd(samp, taxaShuffle(dis), abundance.weighted = abundance.weighted)

      run <- switch(null.model,
        taxa.labels = mntd(samp, taxaShuffle(dis), abundance.weighted), 
        richness =  mntd(randomizeMatrix(samp, null.model = "richness"), dis, abundance.weighted), 
        frequency =  mntd(randomizeMatrix(samp, null.model = "frequency"), dis, abundance.weighted), 
        sample.pool =  mntd(randomizeMatrix(samp, null.model = "richness"), dis, abundance.weighted), 
        phylogeny.pool =  mntd(randomizeMatrix(samp, null.model = "richness"), taxaShuffle(dis), abundance.weighted), 
        independentswap =  mntd(randomizeMatrix(samp, null.model = "independentswap", iterations), dis, abundance.weighted),
        trialswap =  mntd(randomizeMatrix(samp, null.model = "trialswap", iterations), dis, abundance.weighted))

      results <- list(foldNumber=foldNumber, run=run)
      mpi.send.Robj(results,0,2)
    }

    else if (tag == 2) {
      done <- 1
    }

  }
  
  mpi.send.Robj(junk,0,3)
}

#####
# Parent
#####

require(picante)
require(vegan)

args <- commandArgs(trailingOnly=T)

#---
# download

samp <- read.csv(args[1], row.names=1, h=T)
samp <- decostand(samp, 'hell')

tree <- read.tree(args[2])
dis <- cophenetic(tree)

null.model <- args[3]

abundance.weighted <- as.logical(args[4])

runs <- as.numeric(args[5])

iterations <- as.numeric(args[6])

output <- args[7]


# Now, send the data to the slaves
mpi.bcast.Robj2slave(samp)
mpi.bcast.Robj2slave(dis)
mpi.bcast.Robj2slave(null.model)
mpi.bcast.Robj2slave(abundance.weighted)
mpi.bcast.Robj2slave(iterations)

# Send the function to the slaves
mpi.bcast.Robj2slave(foldslave)
mpi.bcast.Robj2slave(mntd)
mpi.bcast.Robj2slave(taxaShuffle)
mpi.bcast.Robj2slave(randomizeMatrix)

# Call the function in all the slaves to get them ready to
# undertake tasks
mpi.bcast.cmd(foldslave())

# Create task list
tasks <- vector('list')
for (i in 1:runs) {
  tasks[[i]] <- list(foldNumber=i)
}

# Create data structure to store the results

# pre-loop part
dis <- as.matrix(dis)
mntd.obs <- mntd(samp, dis, abundance.weighted = abundance.weighted)
null.model <- match.arg(null.model, c("taxa.labels", "richness", 
  "frequency", "sample.pool", "phylogeny.pool", "independentswap", 
    "trialswap"))

# container
mntd.rand <- matrix(0, nrow=runs, ncol=nrow(samp))

junk <- 0 
closed_slaves <- 0 
n_slaves <- mpi.comm.size()-1 


while (closed_slaves < n_slaves) { 
  # Receive a message from a slave 
  message <- mpi.recv.Robj(mpi.any.source(),mpi.any.tag()) 
  message_info <- mpi.get.sourcetag() 
  slave_id <- message_info[1] 
  tag <- message_info[2] 
  # slave ready to work
  if (tag == 1) { 
    # send a task to slave and remove task from task list and task left
    if (length(tasks) > 0) { 
      mpi.send.Robj(tasks[[1]], slave_id, 1); 
      tasks[[1]] <- NULL 
    }
    # say to slave there is no more task
    else { 
      mpi.send.Robj(junk, slave_id, 2) 
    } 
  } 
  # slave send a result
  else if (tag == 2) { 
    foldNumber <- message$foldNumber
    print(c('recep', foldNumber))
    mntd.rand[foldNumber,] <- message$run
  }
  # slave sai he is closed
  else if (tag == 3) { 
    closed_slaves <- closed_slaves + 1 
  } 
} 

mntd.rand.mean <- apply(X = mntd.rand, MARGIN = 2, FUN = mean, 
  na.rm = TRUE)
mntd.rand.sd <- apply(X = mntd.rand, MARGIN = 2, FUN = sd, 
  na.rm = TRUE)
mntd.obs.z <- (mntd.obs - mntd.rand.mean)/mntd.rand.sd
mntd.obs.rank <- apply(X = rbind(mntd.obs, mntd.rand), MARGIN = 2, 
  FUN = rank)[1, ]
mntd.obs.rank <- ifelse(is.na(mntd.rand.mean), NA, mntd.obs.rank)

write.table(data.frame(ntaxa = specnumber(samp), mntd.obs, mntd.rand.mean,
                       mntd.rand.sd, mntd.obs.rank, mntd.obs.z,
                       mntd.obs.p = mntd.obs.rank/(runs + 1), runs = runs,
                       row.names = row.names(samp)),
            output, quote=F, sep=';')


print('putz')


mpi.close.Rslaves()
mpi.quit(save="no")


