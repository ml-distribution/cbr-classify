function a = str2emolab(b)
switch lower(b(1:4))
    case 'ange'
		a = 1;
    case 'disg'
		a = 2;
    case 'fear'
		a = 3;
    case 'happ'
		a = 4;
    case 'sadn'
		a = 5;
    case 'surp'
		a = 6;
    case 'neut';
		a = 7;
    otherwise
        error('Unknown emotion label: %d',b);
end