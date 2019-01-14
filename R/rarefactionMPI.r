#! /home/seppeyc/bin/Rscript

#####
# rarefaction
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

      
      raref <- rep(NA, nb_pioche+1)
      raref[1] <- 0
      otu_pioche <- NULL

      vec_reps <- mr[foldNumber,which(mr[foldNumber,] != 0)]
      nb_otu <- length(vec_reps)
      for(i in 1:nb_pioche) {
        ind_pioche <- sample(1:length(vec_reps), 1)
        vec_reps[ind_pioche] <- vec_reps[ind_pioche]-1
        
        if(names(vec_reps)[ind_pioche] %in% otu_pioche) {
          raref[i+1] <- raref[i]
        }
        else{
          raref[i+1] <- raref[i]+1
          otu_pioche <- c(otu_pioche, names(vec_reps)[ind_pioche])
        }

        if(vec_reps[ind_pioche] == 0 ) {
          vec_reps <- vec_reps[-ind_pioche]
        }

        if(length(otu_pioche) == nb_otu) {
          break
        }

      }

      results <- list(foldNumber=foldNumber, raref=raref)
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

args <- commandArgs(trailingOnly=T)

mr <- read.table(args[1], row.names=1, h=T, sep=',')

nb_pioche <- max(rowSums(mr))
mat.raref <- matrix(0, nrow=nrow(mr), ncol=nb_pioche+1)

print(dim(mr))

# Now, send the data to the slaves

mpi.bcast.Robj2slave(mr)
mpi.bcast.Robj2slave(nb_pioche)

# Send the function to the slaves
mpi.bcast.Robj2slave(foldslave)

# Call the function in all the slaves to get them ready to
# undertake tasks
mpi.bcast.cmd(foldslave())

# Create task list
tasks <- vector('list')
for (i in 1:nrow(mr)) {
  tasks[[i]] <- list(foldNumber=i)
}

# Create data structure to store the results

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
    mat.raref[foldNumber,] <- message$raref
    print(foldNumber)
  }
  # slave sai he is closed
  else if (tag == 3) { 
    closed_slaves <- closed_slaves + 1 
  } 
} 

row.names(mat.raref) <- row.names(mr)

nb_NA_min <- min(apply(mat.raref, 1, function(x) length(which(is.na(x)==T))))
mat.raref <- mat.raref[,1:(ncol(mat.raref)-nb_NA_min)]

# plot the results
write.table(mat.raref, args[2], quote=F, sep='\t')

mpi.close.Rslaves()
mpi.quit(save="no")


