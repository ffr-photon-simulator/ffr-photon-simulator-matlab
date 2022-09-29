[b1 b2] = myTestFunc();
%disp("b1: " + b1)
%disp("b2: " + b2)
%disp("out of function")

function [bool1 o2] = myTestFunc()
  for i = 3:6
    %disp("i=" + i)
    for j = 1:5
      %disp("j=" + j)
      if i > 8
          bool1 = true;
          o2 = [7,8];
          return;
      end
    end
  end
  bool1 = false;
  o2 = "no coords";
end
