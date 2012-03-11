classdef dataConfigTestClass < hgsetget & viscore.dataConfig
    % Settings test class
    properties
        Background;
        BlockName;
        BlockSize;
        BoxColors;
        BoxLimits;
        Counter;
        SimpleInteger;
        WindowType;
    end % properties
      
    methods
        function obj = dataConfigTestClass(selector, title)
            obj = obj@viscore.dataConfig(selector, title);
            
        end % TestClass constructor
        
        function s = getMakeConfig(obj)
            objList = obj.getCurrentManager().getObjects();
            s = obj.makeConfig(objList);

        end
    end % public methods      
end % dataConfigTestClass
