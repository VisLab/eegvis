classdef propertyTestClass < hgsetget & visprops.configurable
    % property test class for testing and illustrating configurable objects
    properties
        Background;              % Example of a color property
        BlockName;               % Example of a string property
        BlockSize = 500;         % Example of a double property
        BoxColors;               % Example of a color list property
        BoxLimits;               % Example of an interval property
        Counter;                 % Example of an unsigned property
        LogicalFlag;             % Example of a logical property
        SimpleInteger;           % Example of a integer property
        StringList;              % Example of a string list property
        Vector;                  % Example of a vector
        WindowType;              % Example of a enumerated property
        
        PropSelect               % Selector for testing GUI configuration
        
    end % public properties
  
    methods
        function obj = propertyTestClass()
            obj = obj@visprops.configurable([]);
            obj.PropSelect = viscore.dataSelector('visprops.propertyConfig');
            addlistener(obj.PropSelect, 'StateChanged', @obj.updateOnPropertyChange);
            propsObj = viscore.managedObj(class(obj), ...
                propertyTestClass.getDefaultProperties());
            obj.PropSelect.putObject(class(obj), propsObj);
            visprops.property.updateProperties(obj, obj.PropSelect.getManager());
            obj.printPropertyValues('Constructor settings');
        end % constructor  
        
        function updateOnPropertyChange(obj, src, evtdata) %#ok<INUSD>
               visprops.property.updateProperties(obj, obj.PropSelect.getManager());
               obj.printPropertyValues('On settings change');
        end % updateOnPropertyChange
        
        function printPropertyValues(obj, msg)
            % Output a formatted version of configurable properties
            fprintf('\n%s:\n', msg);
            propertyTestClass.printVector(obj.Background, 'Background');
            fprintf('BlockName: %s\n', obj.BlockName);
            fprintf('BlockSize: %g\n', obj.BlockSize);
            propertyTestClass.printVector(obj.BoxColors(1, :), 'BoxColors(1)');
            propertyTestClass.printVector(obj.BoxColors(2, :), 'BoxColors(2)');
            propertyTestClass.printVector(obj.BoxLimits, 'BoxLimits');
            fprintf('Counter: %g\n', obj.Counter);
            fprintf('SimpleInteger: %g\n', obj.SimpleInteger);
            fprintf('WindowType: %s\n', obj.WindowType);
            if obj.LogicalFlag
                mString = 'true';
            else
                mString = 'false';
            end
            fprintf('LogicalFlag: %s\n', mString);
            fprintf('String list: {%s', obj.StringList{1});
            for k = 2:length(obj.StringList)
                fprintf(', %s', obj.StringList{k});
            end
            fprintf('}\n'); 
            propertyTestClass.printVector(obj.Vector, 'Vector');
        end % printPropertyValues
    end % methods
    
    methods (Static = true)
         function settings = getDefaultProperties()
            % Field name, class name, class modifier, display name, type, default, options,
            % descriptions
            cName = 'visprops.propertyTestClass';
            settings = struct( ...
                 'Enabled',  {true, true, true, true, true, true, true, true, true, true, true}, ...
                 'Category', {cName, cName, cName, cName, cName, cName, cName, cName, cName, cName, cName}, ...
                 'DisplayName',   {'Block name', ...
                                   'Block size', ...
                                   'Window type', ...
                                   'Box plot colors', ...
                                   'Box plot limits', ...
                                   'Background color', ...
                                   'Count', ...
                                   'Simple Integer', ...
                                   'Logical Value', ...
                                   'String list', ...
                                   'Vector'}, ...
                 'FieldName',     {'BlockName', ...
                                   'BlockSize', ...
                                   'WindowType', ...
                                   'BoxColors', ...
                                   'BoxLimits', ...
                                   'Background', ...
                                   'Counter',  ...
                                   'SimpleInteger', ...
                                   'LogicalFlag', ...
                                   'StringList', ...
                                   'Vector'}, ... 
                 'Value',         {'Window', ...
                                    1000, ...
                                    'Blocked', ...
                                    [0.7, 0.7, 0.7; 1, 0, 1], ...
                                    [-inf, inf],  ...
                                    [0.7, 0.7, 0.7], ...
                                    0, ...
                                    1, ...
                                    true, ...
                                    {'Eyes', 'Ears', 'Nose', 'Throat'}, ...
                                    [1, 2, 3, 4]}, ...
                 'Type',          {'visprops.stringProperty', ...
                                   'visprops.doubleProperty', ...
                                   'visprops.enumeratedProperty', ...
                                   'visprops.colorListProperty', ...
                                   'visprops.intervalProperty', ...
                                   'visprops.colorProperty', ...
                                   'visprops.unsignedIntegerProperty', ...
                                   'visprops.integerProperty', ...
                                   'visprops.logicalProperty', ...
                                   'visprops.stringListProperty', ...
                                   'visprops.vectorProperty'}, ...
                 'Editable',      {true, true, true, true, true, true, true, true, true, true, true}, ...
                 'Options',       {'', [0, inf], {'Blocked', 'Epoched'}, '', '', '', [0, inf], '', '', '', [1 4]}, ...
                 'Description',   {'Block name or label (e.g. ''Window'')', ...
                                   'Block size for computation (must be positive)', ...
                                   'Window type must be either ''Window'' or ''Epoch''', ...
                                   'blockBoxPlot alternating box colors (cannot be empty)', ...
                                   'blockBoxPlot limits', ...
                                   'Background color designating no activity', ...
                                   'Counter of objects', ...
                                   'Integer example', ...
                                   'Example of a logical flag', ...
                                   'Example of a configurable string list', ...
                                   'Example of a vector - items must be numeric'} ...
                                   );
        end % getDefaultProperties


        function printVector(list, message)
            % Utility for printing a vector on one line with a message
            fprintf('%s: [ ', message);
            for k = 1:length(list(:))
                fprintf('%g ', list(k));
            end
            fprintf(']\n');
        end % printList
    end % static methods
    
end % propertyTestClass
