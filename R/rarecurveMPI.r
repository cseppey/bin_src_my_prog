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
      require(vegan)
      foldNumber <- task$foldNumber
      rep_sample <- task$x_i

      
      n <- seq(1, tot[foldNumber], by = step)
      if (n[length(n)] != tot[foldNumber]) 
        n <- c(n, tot[foldNumber])
      sub_out <- drop(rarefy(rep_sample, n))


      results <- list(foldNumber=foldNumber, sub_out=sub_out)
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

require(vegan)
source('~/bin/src/my_prog/R/linestack2.r')

args <- commandArgs(trailingOnly=T)

x <- as.matrix(read.table(args[1], row.names=1, h=T, sep='\t'))

step <- 100
xlab <- 'Samples Size'
ylab <- 'OTUs number'
label <- TRUE

tot <- rowSums(x)
S <- specnumber(x)
nr <- nrow(x)


# Now, send the data to the slaves

mpi.bcast.Robj2slave(step)
mpi.bcast.Robj2slave(tot)
mpi.bcast.Robj2slave(nr)

# Send the function to the slaves
mpi.bcast.Robj2slave(foldslave)

# Call the function in all the slaves to get them ready to
# undertake tasks
mpi.bcast.cmd(foldslave())

# Create task list
tasks <- vector('list')
out <- NULL
for (i in 1:nr) {
  tasks[[i]] <- list(foldNumber=i, x_i=x[i,])
  out[[i]] <- NULL
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
      print(paste('job', tasks[[1]]$foldNumber, 'sended'))
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
    out[[foldNumber]] <- message$sub_out
    print(paste('job', foldNumber, 'received'))
  }
  # slave sai he is closed
  else if (tag == 3) { 
    closed_slaves <- closed_slaves + 1 
  } 
} 

# end and graf

pdf(paste(args[2], 'rarecurveMPI_OP.pdf', sep='_'),
    paper='special', width=7.5, height=3.5)
par(mar=c(5,4,2,6))

Nmax <- sapply(out, function(x) max(attr(x, "Subsample")))
Smax <- sapply(out, max)
plot(c(1, max(Nmax)), c(1, max(Smax)), xlab = xlab, ylab = ylab, type = "n")
#if (!missing(sample)) {
#  abline(v = sample)
#  rare <- sapply(out, function(z) approx(x = attr(z, "Subsample"), 
#  y = z, xout = sample, rule = 1)$y)
#  abline(h = rare, lwd = 0.5)
#}
for (ln in seq_len(length(out))) {
  N <- attr(out[[ln]], "Subsample")
  lines(N, out[[ln]])
}
#if (label) {
#  ordilabel(cbind(tot, S), labels = rownames(x))
#}
#invisible(out)

linestack2(S, labels=row.names(x), at=par('usr')[2], add=T, air=1.8, fact_correc=-3)

dev.off()


mpi.close.Rslaves()
mpi.quit(save="no")





# original function (vegan 2.0-10)

#function (x, step = 1, sample, xlab = "Sample Size", ylab = "Species", label = TRUE, ...) {
#  tot <- rowSums(x)
#  S <- specnumber(x)
#  nr <- nrow(x)
#  out <- lapply(seq_len(nr), function(i) {
#    n <- seq(1, tot[i], by = step)
#    if (n[length(n)] != tot[i]) 
#    n <- c(n, tot[i])
#    drop(rarefy(x[i, ], n))
#  })
#  Nmax <- sapply(out, function(x) max(attr(x, "Subsample")))
#  Smax <- sapply(out, max)
#  plot(c(1, max(Nmax)), c(1, max(Smax)), xlab = xlab, ylab = ylab, 
#  type = "n", ...)
#  if (!missing(sample)) {
#    abline(v = sample)
#    rare <- sapply(out, function(z) approx(x = attr(z, "Subsample"), 
#    y = z, xout = sample, rule = 1)$y)
#    abline(h = rare, lwd = 0.5)
#  }
#  for (ln in seq_len(length(out))) {
#    N <- attr(out[[ln]], "Subsample")
#    lines(N, out[[ln]], ...)
#  }
#  if (label) {
#    ordilabel(cbind(tot, S), labels = rownames(x), ...)
#  }
#  invisible(out)
#}




