function [x y] = loaddata(f)

%LOADDATA - loads features (AUs) and labels (emotions) from a text file
%
% AUTHOR:	M.F. Valstar
% CREATED:	24082006
%
%IN:  f: filename [string]
%OUT: x: sparse, binary featureset of aus [N x 45]
%     y: emotion labels 
fid = fopen(f, 'rt');
eof = 0;
x = [];
y = [];
while 1
	A = zeros(1, 45);
	s = textscan(fid, '%s', 1); 
	if isempty(s{1})
		return
	end
	e = textscan(fid, '%s', 1); 
	a = textscan(fid, '%u', 'delimiter', '\t');
	A(a{1}) = 1;
	y = vertcat(y, str2emolab(char(e{1}))); 
	x = vertcat(x, A);
end