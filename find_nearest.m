function y=find_nearest(A,b)
[Asort,index]=sort(abs(A(:)-b));
y=sort([index(1) index(2)]);