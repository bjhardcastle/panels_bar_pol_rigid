% makes a low contrast bright bar pattern with grayscale and row compression
bar_width = 6; % floored to nearest even value 
bar_brightness= 1;
pat_dir = cd;

pattern.x_num = 160; 	% There are 160 pixel around the display (12 actual columns, 8 missing)
pattern.y_num = 2; 		% y1 bar is visible, y2 bar is invisible
pattern.num_panels = 80; 	% This is the number of unique Panel IDs required.
pattern.gs_val = 4; 	% This pattern will use 16 intensity levels
pattern.row_compression = 1;

Pats = zeros(4, 160, pattern.x_num, pattern.y_num); 	%initializes the array with zeros
% make bright bar with starting position within 'invisible' mising LEDs at rear
Pats(:, 1:floor(0.5*bar_width), 1) = bar_brightness;
Pats(:, end-floor(0.5*bar_width)+1:end, 1) = bar_brightness;

for jj = 2:160 			%use ShiftMatrixPats to rotate stripe image
    Pats(:,:,jj,1) = ShiftMatrix(Pats(:,:,jj-1,1),1,'r','y');
end

pattern.Pats = Pats;

% For ben behaviour panels (new, blue panels, with full 20x8 arena simulated
% - same as 2p panel map for first 48 panels):
for i = 1:12
    for j = 1:4
        Panel_mat(j,i) = mod((i-1)*4,12) + ceil(i/3) + (j-1)*12;
    end
end
ct = max(Panel_mat(:));
for i = 13:20
    for j = 1:4
        ct = ct+1;
        Panel_mat(j,i) = ct;
    end
end
Panel_mat = circshift(Panel_mat,7,2);
mat = flipud(Panel_mat);
pattern.Panel_map = fliplr(mat);


% Convert
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

% Save
str = fullfile(pat_dir, ['Pattern_20x4_bright_bar_width_' num2str(bar_width) '_brightness_' num2str(bar_brightness) '.mat']);
save(str, 'pattern');
