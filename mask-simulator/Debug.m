classdef Debug
  % Provides debugging helper functions.
  properties (Constant)
    % Message importance levels:
    % 0 - high
    % 1 - medium
    % 2 - low
    % Setting the level to 1 will show high and medium messages,
    % but not low messages.
    LEVEL = 0;
  end
  methods (Static)
    function msgIfLevel(msg, level)
      if Debug.LEVEL >= level
        fprintf("\nDEBUG: " + msg);
      end
    end

    function dispIfLevel(item, level)
      if Debug.LEVEL >= level
        disp(item)
      end
    end

    function msg(msg, level)
      Debug.msgIfLevel(msg, level);
    end

    function msgStruct(msg, struct, level)
      Debug.msgWithItem(msg, struct, level);
    end

    function msgArray(msg, array, level)
      Debug.msgWithItem(msg, array, level);
    end

    function msgWithItem(msg, item, level)
      % Display some item that can't be concatenated with a string.
      Debug.msgIfLevel(msg + "\n", level);
      Debug.dispIfLevel(item, level)
    end

    function item(item, level)
      % Display some non-string item.
      Debug.dispIfLevel(item, level)
    end

    function newline()
      fprintf("\n");
    end

    function alert(msg, level)
      % Use the 'warning' builtin (orange text output).
      warning(msg);
    end

    function error(msg)
      % Use the 'error' builtin (red text output and stops program).
      error(msg);
    end

    function s = coordToString(coord)
      % Return a string representation of a coordinate pair.
      s = string(coord(1)) + ", " + string(coord(2));
    end
  end
  methods
    function obj = Debug()
    end
  end
end
