function [mesh] = MSH2Mjoinstructm(mesh1,mesh2,s1,s2)

  ## -*- texinfo -*-
  ## @deftypefn {Function File} {[@var{mesh}]} = MSH2Mjoinstructm(@var{mesh1},@var{mesh2},@var{s1},@var{s2})
  ##
  ## Join two consequents meshes. Gives as output the PDE-tool like mesh structure.
  ##
  ## Input:
  ## @itemize @minus
  ## @item @var{mesh1}, @var{mesh2}: standard PDEtool-like mesh, with field "p", "e", "t".
  ## @item @var{s1}, @var{s2}: number of the corresponding geometrical border edge for respectively mesh1 and mesh2.
  ## @end itemize
  ##
  ## Output:
  ## @itemize @minus
  ## @item @var{mesh}: standard PDEtool-like mesh, with field "p", "e", "t".
  ## @end itemize 
  ##
  ## WARNING: on the common edge the two meshes must share the same vertexes.
  ##
  ## @seealso{MSH2Mstructmesh,MSH2Mgmsh,MSH2Msubmesh}
  ## @end deftypefn

  ## This file is part of 
  ##
  ##                   MSH - Meshing Software Package for Octave
  ##      -------------------------------------------------------------------
  ##              Copyright (C) 2007  Carlo de Falco and Culpo Massimiliano
  ## 
  ##   MSH is free software; you can redistribute it and/or modify
  ##   it under the terms of the GNU General Public License as published by
  ##   the Free Software Foundation; either version 2 of the License, or
  ##   (at your option) any later version.
  ## 
  ##   MSH is distributed in the hope that it will be useful,
  ##   but WITHOUT ANY WARRANTY; without even the implied warranty of
  ##   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ##   GNU General Public License for more details.
  ## 
  ##   You should have received a copy of the GNU General Public License
  ##   along with MSH; if not, write to the Free Software
  ##   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
  ##   USA
  ##
  ##
  ##   MAIN AUTHOR:
  ##   Carlo de Falco
  ##   Bergische Universität Wuppertal
  ##   Fachbereich C - Mathematik und Naturwissenschaften
  ##   Arbeitsgruppe für Angewandte MathematD-42119 Wuppertal  Gaußstr. 20 
  ##   D-42119 Wuppertal, Germany
  ##
  ##   AID IN PROGRAMMING AND CLEANING THE CODE: 
  ##   Culpo Massimiliano
  ##   Bergische Universität Wuppertal
  ##   Fachbereich C - Mathematik und Naturwissenschaften
  ##   Arbeitsgruppe für Angewandte MathematD-42119 Wuppertal  Gaußstr. 20 
  ##   D-42119 Wuppertal, Germany

  ## make sure that the outside world is always 
  ## on the same side of the boundary of mesh1
  [mesh1.e(6:7,:),I] = sort(mesh1.e(6:7,:));
  for ic=1:size(mesh1.e,2)
    mesh1.e(1:2,ic) = mesh1.e(I(:,ic),ic);
  end

  intnodes1=[];
  intnodes2=[];


  j1=[];j2=[];
  for is=1:length(s1)    
    side1 = s1(is);side2 = s2(is);
    [i,j] = find(mesh1.e(5,:)==side1);
    j1=[j1 j];
    [i,j] = find(mesh2.e(5,:)==side2);
    oldregion(side1) = max(max(mesh2.e(6:7,j)));
    j2=[j2 j];
  end

  intnodes1=[mesh1.e(1,j1),mesh1.e(2,j1)];
  intnodes2=[mesh2.e(1,j2),mesh2.e(2,j2)];

  intnodes1 = unique(intnodes1);
  [tmp,I] = sort(mesh1.p(1,intnodes1));
  intnodes1 = intnodes1(I);
  [tmp,I] = sort(mesh1.p(2,intnodes1));
  intnodes1 = intnodes1(I);

  intnodes2 = unique(intnodes2);
  [tmp,I] = sort(mesh2.p(1,intnodes2));
  intnodes2 = intnodes2(I);
  [tmp,I] = sort(mesh2.p(2,intnodes2));
  intnodes2 = intnodes2(I);

  ##delete redundant edges
  mesh2.e(:,j2) = [];

  ## change edge numbers
  indici=[];consecutivi=[];
  indici = unique(mesh2.e(5,:));
  consecutivi (indici) = [1:length(indici)]+max(mesh1.e(5,:));
  mesh2.e(5,:)=consecutivi(mesh2.e(5,:));


  ##change node indices in connectivity matrix
  ##and edge list
  indici=[];consecutivi=[];
  indici  = 1:size(mesh2.p,2);
  offint  = setdiff(indici,intnodes2);
  consecutivi (offint) = [1:length(offint)]+size(mesh1.p,2);
  consecutivi (intnodes2) = intnodes1;
  mesh2.e(1:2,:)=consecutivi(mesh2.e(1:2,:));
  mesh2.t(1:3,:)=consecutivi(mesh2.t(1:3,:));


  ##delete redundant points
  mesh2.p(:,intnodes2) = [];

  ##set region numbers
  regions = unique(mesh1.t(4,:));
  newregions(regions) = 1:length(regions);
  mesh1.t(4,:) = newregions(mesh1.t(4,:));

  ##set region numbers
  regions = unique(mesh2.t(4,:));
  newregions(regions) = [1:length(regions)]+max(mesh1.t(4,:));
  mesh2.t(4,:) = newregions(mesh2.t(4,:));
  ##set adjacent region numbers in edge structure 2
  [i,j] = find(mesh2.e(6:7,:));
  i = i+5;
  mesh2.e(i,j) = newregions(mesh2.e(i,j));
  ##set adjacent region numbers in edge structure 1
  mesh1.e(6,j1) = newregions(oldregion(mesh1.e(5,j1)));

  ##make the new p structure
  mesh.p = [mesh1.p mesh2.p];
  mesh.e = [mesh1.e mesh2.e];
  mesh.t = [mesh1.t mesh2.t];

endfunction

%!test
%! [mesh1] = MSH2Mstructmesh(0:.5:1, 0:.5:1, 1, 1:4, 'left');
%! [mesh2] = MSH2Mstructmesh(1:.5:2, 0:.5:1, 1, 1:4, 'left');
%! [mesh] = MSH2Mjoinstructm(mesh1,mesh2,2,4);
%! p = [0.00000   0.00000   0.00000   0.50000   0.50000   0.50000   1.00000   1.00000   1.00000   1.50000   1.50000   1.50000   2.00000   2.00000   2.00000
%!      0.00000   0.50000   1.00000   0.00000   0.50000   1.00000   0.00000   0.50000   1.00000   0.00000   0.50000   1.00000   0.00000   0.50000   1.00000];
%! e = [1    4    7    8    3    6    1    2    7   10   13   14    9   12
%!      4    7    8    9    6    9    2    3   10   13   14   15   12   15
%!      0    0    0    0    0    0    0    0    0    0    0    0    0    0
%!      0    0    0    0    0    0    0    0    0    0    0    0    0    0
%!      1    1    2    2    3    3    4    4    5    5    6    6    7    7
%!      0    0    2    2    0    0    0    0    0    0    0    0    0    0
%!      1    1    1    1    1    1    1    1    2    2    2    2    2    2];
%! t = [1    2    4    5    2    3    5    6    7    8   10   11    8    9   11   12
%!      4    5    7    8    4    5    7    8   10   11   13   14   10   11   13   14
%!      2    3    5    6    5    6    8    9    8    9   11   12   11   12   14   15
%!      1    1    1    1    1    1    1    1    2    2    2    2    2    2    2    2];
%! toll = 1e-4;
%! assert(mesh.p,p,toll);
%! assert(mesh.p,p,toll);
%! assert(mesh.p,p,toll);
