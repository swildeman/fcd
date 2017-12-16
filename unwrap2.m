function [ phi ] = unwrap2( phi )
%UNWRAP2 very basic 2D unwrap, using Matlab's built-in 1D function twice
%replace with your own favorite unwrap algorithm

phi = unwrap(unwrap(phi,[],1),[],2);

end

