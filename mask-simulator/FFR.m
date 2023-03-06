classdef FFR
  % A class representing an FFR.
  properties
    ffrLayers = [];
  end

  methods
    function obj = FFR(config)
      % The config 'c' is a struct of the form:
      % c.nLayers = number of layers in FFR
      % c.ffrLayerConfigs = list of structs defining each FFRLayer

      % Store list of structs which are the configs of the FFRLayers.
      % Each FFRLayer struct holds the data to make that FFR layer.
      ffrLayerConfigs = config.ffrLayerConfigs;

      % Create FFRLayers
      for l = 1:config.nLayers
        %disp("Create FFRLayer " + q)
        ffrLayer = FFRLayer(ffrLayerConfigs(l));
        obj.ffrLayers = [obj.ffrLayers; ffrLayer];
      end
    end
  end
end
