classdef carrier
%CARRIER neat object to represents a carrier signal in kspace
%
% Copyright (c) 2017 Sander Wildeman
% Distributed under the MIT License, see LICENSE file
    
    properties
        k
        krad
        mask
        ccsgn
    end
    
    methods
        function c = gpuArray(c)
            c.mask = gpuArray(c.mask);
            c.ccsgn = gpuArray(c.ccsgn);
        end
        
        function [varargout] = plot(c, varargin)
           th = linspace(0,2*pi,100);
           circX = c.k(1) + c.krad*cos(th);
           circY = c.k(2) + c.krad*sin(th);
           
           h = plot(c.k(1), c.k(2), '+', circX, circY, '-', varargin{:});
           
           if nargout > 0
            varargout{1} = h;
           end
        end
        
    end
    
end

