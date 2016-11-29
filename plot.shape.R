plot.shape = function(S, new.plot=TRUE)
  # This function plot a shape vector S into 3D model of the left ventricle
  # 
  #    plot.shape(S)
  #
  # Author: Avan Suinesiaputra - 2016
{
  require(rgl)
  
  # check the dimension of S
  # this should be 5046 points
  stopifnot(length(S)==5046)
  
  # read the surface_face
  load('data/surface_face.RData')
  
  # create new plot if necessary
  if( new.plot ) { open3d() }
  
  endo = tmesh3d(S, t(faces), homogeneous = FALSE)
  epi = tmesh3d(S, t(faces)+max(faces), homogeneous = FALSE)

  shade3d(endo, col='deeppink3', alpha=0.5)
  shade3d(epi, col='dodgerblue4', alpha=0.4)
}