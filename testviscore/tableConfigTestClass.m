classdef tableConfigTestClass < hgsetget & viscore.tableConfig
    % Wrapper for viscore.tableConfig for testing 

    methods
        function obj = tableConfigTestClass(selector, title)
            obj = obj@viscore.tableConfig(selector, title);      
        end % TestClass constructor
        
        function s = getMakeConfig(obj)
            objList = obj.getCurrentManager().getObjects();
            s = obj.makeConfig(objList);
        end %testGetConfig
        
    end % public methods      
end % tableConfigTestClass
