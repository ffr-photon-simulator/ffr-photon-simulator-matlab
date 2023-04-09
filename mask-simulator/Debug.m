classdef Debug
  properties (Constant)
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
      Debug.msgIfLevel(msg + "\n", level);
      Debug.dispIfLevel(item, level)
    end

    function item(item, level)
      Debug.dispIfLevel(item, level)
    end

    function newline()
      fprintf("\n");
    end

    function alert(msg, level)
      warning(msg);
    end

    function error(msg)
      error(msg);
    end

    function s = coordToString(coord)
      s = string(coord(1)) + ", " + string(coord(2));
    end

  end
end
