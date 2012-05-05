function a = findArea(width,varargin)
   p = inputParser;
   defaultHeight = 1;
   defaultUnits = 'inches';
   defaultShape = 'rectangle';
   expectedShapes = {'square','rectangle','parallelogram'};

   addRequired(p,'width',@isnumeric);
   addOptional(p,'height',defaultHeight,@isnumeric);
   addParamValue(p,'units',defaultUnits);
   addParamValue(p,'shape',defaultShape,...
                 @(x) any(validatestring(x,expectedShapes)));

   parse(p,width,varargin{:});
   a = p.Results.width .* p.Results.height;