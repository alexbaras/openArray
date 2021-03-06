processQPCR <- function(d,nCPU) {

  # modeling constraints
  Cstr = list()
  Cstr$U = matrix(NA,6,5)
  Cstr$C = matrix(NA,6,1)
  Cstr$U[1,] = c(0,0,0,-1,log(2)); Cstr$C[1,1] = 0 # max per cycle change is 2x
  Cstr$U[2,] = c(0,0,0,1,0); Cstr$C[2,1] = 0.001 # slope parameter must be > 0 
  Cstr$U[3,] = c(0,0,0,0,1); Cstr$C[3,1] = 0.001 # acentrality parameter must be > 0
  Cstr$U[4,] = c(0,0,1,0,0); Cstr$C[4,1] = 0 # calculated expression index is between 0 and 60 cycles
  Cstr$U[5,] = c(0,0,-1,0,0); Cstr$C[5,1] = -60
  Cstr$U[6,] = c(0,1,0,0,0); Cstr$C[6,1] = 0.001 # amplitude of pcr reaction must be > 0

  # For all ChipID x ChipWell combinations
  nodes = makeForkCluster(nnodes=nCPU)
  m = clusterApplyLB(cl=nodes,x=d,fun=modelQPCR,Cstr=Cstr)
  stopCluster(nodes)
  
  u = data.frame()
  for (j in 1:length(d)) {
      u[j,"Chip.Id"] = d[[j]]$Chip.Id[1]
      u[j,"Chip.Well"] = d[[j]]$Chip.Well[1]
      u[j,"Sample.Id"] = d[[j]]$Sample.Id[1]
      u[j,"Feature.Set"] = d[[j]]$Feature.Set[1]
      u[j,"Feature.Id"] = d[[j]]$Feature.Id[1]
      u[j,"p1"] = m[[j]]$modelFit$parameters[1]
      u[j,"p2"] = m[[j]]$modelFit$parameters[2]
      u[j,"p3"] = m[[j]]$modelFit$parameters[3]
      u[j,"p4"] = m[[j]]$modelFit$parameters[4]
      u[j,"p5"] = m[[j]]$modelFit$parameters[5]
      u[j,"r2"] = m[[j]]$modelFit$Rsq
  }
  
  return(u)
}
